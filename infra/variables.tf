variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "github_repo" {
  description = "owner/repo allowed to deploy, e.g. colinkc/aws-secure-delivery-pipeline"
  type        = string
  # TODO (Stage 3): set in terraform.tfvars
}

variable "alert_email" {
  description = "Where budget + detection alerts go"
  type        = string
}

variable "ecr_repo_name" {
  type    = string
  default = "aws-secure-delivery-pipeline"
}

variable "function_name" {
  type    = string
  default = "secure-delivery-app"
}

variable "image_uri" {
  description = "Stage 4: ECR image digest from the first pipeline run. Empty = don't create Lambda yet."
  type        = string
  default     = ""
}
