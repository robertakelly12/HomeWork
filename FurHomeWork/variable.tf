variable "vpc_cidr" {
    description = "the cidr of the my vpc"
  type = string
  default = "10.0.0.0/16"
}

variable "subnet1_cidr" {
  type = string
  description = "the cidr for my subnet"
  default = "10.0.0.0/24"
}

variable "subnet2_cidr" {
    type = string
    description = "cidr for my subnet2"
    default = "10.0.1.0/24"
}