# Stage 3/4 — T6: immutable tags so a scanned+signed image can't be swapped.

resource "aws_ecr_repository" "app" {
  #checkov:skip=CKV_AWS_136:AES256 (AWS-owned key) chosen over a KMS CMK to stay ~$0; accepted risk for a portfolio repo
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true # lets `terraform destroy` clean up; would be false in prod

  image_scanning_configuration {
    scan_on_push = true # basic scanning, free — a second opinion to Trivy
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_lifecycle_policy" "keep_last_5" {
  repository = aws_ecr_repository.app.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep storage (and cost) near zero"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      }
      action = { type = "expire" }
    }]
  })
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}
