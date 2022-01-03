output "s3_bucket" {
    value = aws_s3_bucket.great.arn
}

output "iam_role" {
    value = aws_iam_role.access_role.id
  
}

output "iam_role_policy" {
    value = aws_iam_role_policy.test_policy.policy
  
}