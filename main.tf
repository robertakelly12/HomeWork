resource "aws_s3_bucket" "great" {
  bucket = "tafs3-bucket"
  acl    = var.s3bucket

  tags = {
    Name        = "assign bucket"
    Environment = "Dev"
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.mykey.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_kms_key" "mykey" {
  description = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_iam_role" "access_role" {
  name = "access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "s3 role"
  }
}

resource "aws_iam_policy" "s3_policy" {
  name        = "Allow_all"
  path        = "/"
  description = "My s3 bucket role"


  policy = jsonencode({
     "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1638808262307",
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": "*",
      "Principal": "*"
    }
  ]
  })
}