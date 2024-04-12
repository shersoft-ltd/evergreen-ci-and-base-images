resource "aws_codestarconnections_connection" "github" {
  name          = "github"
  provider_type = "GitHub"
}

locals {
  repository = "shersoft-ltd/evergreen-ci-and-base-images"
}

module "node" {
  source = "./modules/ecr-repository"

  name = "node"

  codestar_connection_arn = aws_codestarconnections_connection.github.arn
  repository              = local.repository
}

module "node_ci_cd" {
  source = "./modules/ecr-repository"

  name = "node-ci-cd"

  codestar_connection_arn = aws_codestarconnections_connection.github.arn
  repository              = local.repository
}

module "python" {
  source = "./modules/ecr-repository"

  name = "python"

  codestar_connection_arn = aws_codestarconnections_connection.github.arn
  repository              = local.repository
}
