provider "aws" {
  region  = "${var.aws_region}"
}
resource "random_id" "tc-rmstate" {
  byte_length = 2
}
resource "aws_s3_bucket" "tfrmstate" {
  bucket        = "tc-remotestate-${random_id.tc-rmstate.dec}"
  acl           = "private"
  force_destroy = true

  tags = {
    Name = "tf remote state"
  }
}

resource "aws_s3_bucket_object" "rmstate_folder" {
  bucket = "${aws_s3_bucket.tfrmstate.id}"
  key = "terraform-aws/"
}

resource "aws_dynamodb_table" "terraform_statelock" {
  name = "${var.aws_dynamodb_table}"
  read_capacity = 20
  write_capacity = 20
  hash_key = "LockID"

  attribute {
      name = "LockID"
      type = "S"
  }
}

resource "aws_ssm_parameter" "paas_environment_version" {
  name        = "/PAAS/REPO/ENVIRONMENT_VERSION"
  description = "Pass Environment Repo Version"
  type        = "String"
  value       = var.environment_version

  tags = {
    environment = "dev"
    application = "kube_paas"
  }
}

resource "aws_ssm_document" "ansible_wrapper" {
  name          = "run_ansible_wrapper"
  document_type = "Command"

  content = <<DOC
  {
  "schemaVersion": "2.2",
  "description": "Command Document Example JSON Template",
  "mainSteps": [
    {
      "action": "aws:runShellScript",
      "name": "RunAnsibleWrapper",
      "inputs": {
        "runCommand": [
          "ansible-wrapper.sh"
        ]
      }
    }
  ]
}
DOC
}