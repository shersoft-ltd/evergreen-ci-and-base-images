module "node" {
  source = "./modules/ecr-repository"

  name = "node"
}

module "node_ci_cd" {
  source = "./modules/ecr-repository"

  name = "node-ci-cd"
}

module "python" {
  source = "./modules/ecr-repository"

  name = "python"
}
