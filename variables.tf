variable "aws_region" {
    default = "us-east-1"
}
variable "aws_dynamodb_table" {
  default = "tf-remote-state-lock"
}

variable "environment_version" {
  default = "v1.0.0"
}
