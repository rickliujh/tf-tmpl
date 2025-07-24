locals {
  terraform_source_dir           = coalesce(var.override_terraform_source_dir, "terraform/")
  repository_default_branch_name = coalesce(var.override_repository_default_branch_name, "main")
  github_prod_env_name           = coalesce(var.github_prod_env_name, "prod")
  allow_pull_request             = coalesce(var.override_allow_pull_request, true)
  wif_pool_id                    = coalesce(var.override_wif_pool_id, "github-actions-pool")

  aws_tags = {
    name    = "tf-github-actions-gcp-wif",
    module  = "github-actions",
    purpose = "cicd"
  }

  github_issuer = "https://token.actions.githubusercontent.com"
}

resource "google_iam_workload_identity_pool" "github" {
  provider = google-beta
  project  = var.project_id

  workload_identity_pool_id = local.wif_pool_id
  display_name              = "Github Actions Pool"
  description               = "Identity pool operates in FEDERATION_ONLY mode"
  disabled                  = false
  mode                      = "FEDERATION_ONLY"
}

resource "google_iam_workload_identity_pool_provider" "provider" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "prvdr-${var.github_repo}"
  display_name                       = "Provider ${var.github_repo}"
  description                        = "GitHub Actions identity pool provider for Repository ${var.github_repo}"
  disabled                           = false
  # Repository Owner ID
  # For user:
  # curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/users/YOUR_USERNAME
  # For org:
  # curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/orgs/YOUR_ORGANIZATION_NAME
  attribute_condition = <<EOT
    assertion.repository_owner_id == "${var.github_org_id}" &&
    attribute.repository == "${var.github_org}/${var.github_repo}" &&
    (
      (assertion.ref == "refs/heads/${local.repository_default_branch_name}" && assertion.ref_type == "branch") 
      ${local.allow_pull_request == true ? "|| (attribute.environment != \"${local.github_prod_env_name}\" && assertion.ref_type == \"pull_request\")" : ""}
    )
EOT
  attribute_mapping = {
    "google.subject"        = "assertion.sub"
    "attribute.actor"       = "assertion.actor"
    "attribute.aud"         = "assertion.aud"
    "attribute.repository"  = "assertion.repository"
    "attribute.environment" = "assertion.environment"
    "attribute.ref"         = "assertion.ref"
    "attribute.ref_type"    = "assertion.ref_type"
  }
  oidc {
    issuer_uri = local.github_issuer
  }
}
