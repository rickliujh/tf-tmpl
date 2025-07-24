variable "project_id" {
  description = "(Required) GCP project ID"
  type        = string
}

variable "github_org" {
  description = "(Required) Name of the GitHub organization"
  type        = string
}

variable "github_org_id" {
  description = "(Required) ID of the GitHub organization"
  type        = string
}

variable "github_repo" {
  description = "(Required) The name of the GitHub repository to use"
  type        = string
}

variable "override_allow_pull_request" {
  description = "If allow workflow run on pull request to grant access to GCP resources on non-production environment, defaults to true"
  type        = bool
  default     = null
}

variable "github_prod_env_name" {
  description = "Override github prod envrionment name, defaults to prod"
  type        = string
  default     = null
}

variable "override_terraform_source_dir" {
  description = "Override the directory in the repo where the terraform code is, defaults to terraform/ - please include trailing slash in override"
  type        = string
  default     = null
}

variable "override_repository_default_branch_name" {
  description = "Override the default branch name, defaults to main"
  type        = string
  default     = null
}

variable "override_wif_pool_id" {
  description = "Override the default workload identity federation pool id, defaults to github-actions-pool"
  type        = string
  default     = null
}

variable "override_tags" {
  description = "Override tags to apply to GCP resources"
  type        = map(string)
  default     = null
}
