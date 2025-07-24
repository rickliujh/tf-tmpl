locals {
  terraform_source_dir           = coalesce(var.override_terraform_source_dir, "terraform/")
  repository_default_branch_name = coalesce(var.override_repository_default_branch_name, "main")
  region                         = coalesce(var.override_gcp_region, "us-central1")
  github_prod_env_name           = coalesce(var.github_prod_env_name, "prod")
  wif_pool_id                    = coalesce(var.override_wif_pool_id, "github-actions-pool")
  github_workflow_file           = coalesce(var.override_github_workflow_filename, "ci.yaml")
  tf_source_dir                  = coalesce(var.override_terraform_source_dir, "terraform/")

  tags = {
    name    = "tf-github-actions-gcp-run",
    module  = "github-actions",
    purpose = "cicd"
  }
}

provider "google" {
  project = var.project_id
}

data "google_project" "proj" {
  project_id = var.project_id
}

module "gh_actions_wif" {
  source = "github.com/rickliujh/tf-tmpl//gcp/modules/github-actions-wif"

  project_id                              = var.project_id
  github_org                              = var.github_org
  github_repo                             = var.github_repo
  github_org_id                           = var.github_org_id
  override_wif_pool_id                    = local.wif_pool_id
  override_repository_default_branch_name = local.repository_default_branch_name
}
