provider "github" {
  owner = var.github_org
  token = data.google_secret_manager_secret_version.github_token.secret_data
}

data "google_secret_manager_secret_version" "github_token" {
  project = var.project_id
  secret  = "kickstart-gogrpc-ci-github-token"
}

resource "github_actions_variable" "gar_name" {
  repository    = var.github_repo
  variable_name = "GAR_REPO_NAME"
  value         = data.google_artifact_registry_repository.gar.repository_id
}

resource "github_actions_secret" "wif_id" {
  repository      = var.github_repo
  secret_name     = "GCP_WIF_PROVIDER"
  plaintext_value = "${local.wif_id}/providers/${module.gh_actions_wif.workload_identity_provider}"
}

data "google_cloud_run_v2_service" "cloud_run" {
  name     = var.cloud_run_service_name
  location = local.region
}

resource "local_file" "github_actions_cicd_workflow" {
  filename = "${path.root}/../.github/workflows/${local.github_workflow_file}"
  content = templatefile("${path.module}/templates/github_actions_workflow.yml.tmpl", {
    tf_source_dir = local.terraform_source_dir
    project_id    = var.project_id
    gcp_region    = local.region
    service_name  = data.google_cloud_run_v2_service.cloud_run.name
  })
}
