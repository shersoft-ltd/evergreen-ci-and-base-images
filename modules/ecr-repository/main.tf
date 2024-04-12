resource "aws_ecr_repository" "main" {
  name = var.name
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.id

  policy = jsonencode({
    "rules" : [
      {
        "rulePriority" : 1,
        "description" : "Retire draft images.",
        "selection" : {
          "tagStatus" : "tagged",
          "tagPrefixList" : [
            "draft"
          ],
          "countType" : "sinceImagePushed",
          "countUnit" : "days",
          "countNumber" : 1
        },
        "action" : {
          "type" : "expire"
        }
      },
      {
        "rulePriority" : 2,
        "description" : "Retire untagged images.",
        "selection" : {
          "tagStatus" : "untagged",
          "countType" : "sinceImagePushed",
          "countUnit" : "days",
          "countNumber" : 1
        },
        "action" : {
          "type" : "expire"
        }
      }
    ]
  })
}
