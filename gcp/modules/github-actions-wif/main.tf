locals {
  terraform_source_dir           = coalesce(var.override_terraform_source_dir, "terraform/")
  repository_default_branch_name = coalesce(var.override_repository_default_branch_name, "main")

  aws_tags = {
    name    = "tf-github-actions-gcp-wif",
    module  = "github-actions",
    purpose = "cicd"
  }

  github_issuer = "https://token.actions.githubusercontent.com"
}

# Create the GitHub provider to use the GitHub token retrieved from SSM
resource "local_file" "tf_github_provider" {
  filename             = "${path.root}/provider-github.tf"
  directory_permission = "0666"
  file_permission      = "0666"
  content = templatefile("${path.module}/templates/provider-github.tf.tmpl", {
    github_organization = var.github_org
  })
}

resource "google_iam_workload_identity_pool" "github" {
  provider = google-beta
  project  = var.project_id

  workload_identity_pool_id = "github-actions-pool"
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
    assertion.ref == "refs/heads/main" &&
    assertion.ref_type == "branch"
EOT
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.aud"        = "assertion.aud"
    "attribute.repository" = "assertion.repository"
  }
  oidc {
    issuer_uri = local.github_issuer
  }
}
