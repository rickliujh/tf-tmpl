locals {
  wif_id = "projects/${data.google_project.proj.number}/locations/global/workloadIdentityPools/${module.gh_actions_wif.workload_identity_pool_id}"
}


data "google_artifact_registry_repository" "gar" {
  repository_id = var.artifect_repository_id
  location      = local.region
  project       = var.project_id
}

data "google_iam_policy" "ci_gar_push" {
  binding {
    role = "roles/artifactregistry.writer"
    members = [
      "principalSet://iam.googleapis.com/${local.wif_id}/attribute.repository/${var.github_org}/${var.github_repo}",
    ]
  }
}

resource "google_artifact_registry_repository_iam_policy" "policy" {
  project     = var.project_id
  location    = data.google_artifact_registry_repository.gar.location
  repository  = data.google_artifact_registry_repository.gar.repository_id
  policy_data = data.google_iam_policy.ci_gar_push.policy_data
}

data "google_cloud_run_v2_service" "run_svc" {
  name     = var.cloud_run_service_name
  location = local.region
  project  = var.project_id
}

data "google_iam_policy" "ci_run_deploy" {
  binding {
    role = "roles/run.admin"
    members = [
      "principalSet://iam.googleapis.com/${local.wif_id}/attribute.repository/${var.github_org}/${var.github_repo}",
    ]
  }
}

resource "google_cloud_run_v2_service_iam_policy" "policy" {
  project     = var.project_id
  location    = data.google_cloud_run_v2_service.run_svc.location
  name        = data.google_cloud_run_v2_service.run_svc.name
  policy_data = data.google_iam_policy.ci_run_deploy.policy_data
}

data "google_service_account" "compute_default" {
  account_id = "${data.google_project.proj.number}-compute@developer.gserviceaccount.com"
}

data "google_iam_policy" "ci_sa_user" {
  binding {
    role = "roles/iam.serviceAccountUser"

    members = [
      "principalSet://iam.googleapis.com/${local.wif_id}/attribute.repository/${var.github_org}/${var.github_repo}",
    ]
  }
}

# grant access to default service account
resource "google_service_account_iam_policy" "wif_sa_user" {
  service_account_id = data.google_service_account.compute_default.name
  policy_data        = data.google_iam_policy.ci_sa_user.policy_data
}
