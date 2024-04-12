variable "name" {
  type        = string
  description = "ECR repo name."
}

variable "codestar_connection_arn" {
  type        = string
  description = "Link to GitHub to pull this repo."
}

variable "default_branch_name" {
  type        = string
  description = "Branch for code that's ready to release."
  default     = "main"
}

variable "repository" {
  type        = string
  description = "GitHub organization and repository in org/repo format."
}
