# GitHub Actions for GCP Artifact Registry and Cloud Run

Minimum configuration To use the module, the following needs to be specified:

```
module "github_actions" {
  source                 = "github.com/rickliujh/tf-tmpl//gcp/modules/github-actions"
  project_id             = google_project.proj.project_id
  github_org             = "rickliujh"
  github_repo            = "kickstart-gogrpc"
  github_org_id          = "36358701"
  artifect_repository_id = google_artifact_registry_repository.gar.repository_id
  cloud_run_service_name = google_cloud_run_v2_service.kickstart_svc.name
}

```

## MISC
This module apply custom claims condition on WIF provider level, you can also apply IAM policy condition through Service Account instead:

```terraform
data "google_iam_policy" "ci_gar_push" {
  binding {
    role = "roles/artifactregistry.writer"
    members = [
      "serviceAccount:serviceAccount:{projectid}.svc.id.goog[{namespace}/{kubernetes-sa}]",
    ]
    condition {
      title      = "${var.github_repo} specific"
      expression = <<EOT
    attribute.repository_owner_id == "${var.github_org_id}" &&
    attribute.repository == "${var.github_org}/${var.github_repo}" &&
    (
      (attribute.ref == "refs/heads/main" && attribute.ref_type == "branch") ||
      (attribute.environment != "${local.github_prod_env_name}" && attribute.ref_type == "pull_request")
    )
EOT
    }
  }
}
```
