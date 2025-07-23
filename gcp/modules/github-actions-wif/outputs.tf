output "workload_identity_pool_id" {
  value = google_iam_workload_identity_pool.github.workload_identity_pool_id
}

output "workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.provider.workload_identity_pool_provider_id
}

output "github_organization" {
  value = var.github_org
}
