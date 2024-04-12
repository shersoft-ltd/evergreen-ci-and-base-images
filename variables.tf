variable "resource_prefix" {
  type        = string
  default     = "evergreen-ci-and-base-images"
  description = "Used to identify resources this project creates."
}

variable "default_branch_name" {
  type        = string
  description = "Branch for code that's ready to release."
  default     = "main"
}

variable "repository" {
  type        = string
  description = "GitHub organization and repository in org/repo format."
  default     = "shersoft-ltd/evergreen-ci-and-base-images"
}
