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

variable "artifect_repository_id" {
  description = "(Required) GCP artifect registory repository id"
  type        = string
}

variable "cloud_run_service_name" {
  description = "(Required) GCP cloud run service deploy name"
  type        = string
}

variable "github_token_secret_manager_key" {
  description = "(Required) The github token key for GCP secret manager"
  type        = string
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

variable "override_github_workflow_filename" {
  description = "Override the GitHub Actions workflow filename, defaults to ci.yaml"
  type        = string
  default     = null
}

variable "override_gcp_region" {
  description = "Override gcp region, defaults to us-central1"
  type        = string
  default     = null
}

variable "github_prod_env_name" {
  description = "Override github prod envrionment name, defaults to prod"
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

