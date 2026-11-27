resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github-deploy"
  display_name = "GitHub Actions deploy pool"
}
resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-main"
  display_name = "GitHub main branch"
  attribute_mapping = { "google.subject" = "assertion.sub", "attribute.repository" = "assertion.repository" }
  attribute_condition = "assertion.repository == 'example-org/ledgerline' && assertion.ref == 'refs/heads/main'"
  oidc { issuer_uri = "https://token.actions.githubusercontent.com" }
}
resource "google_service_account_iam_member" "github_deployer" {
  service_account_id = google_service_account.terraform_deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/123456789/locations/global/workloadIdentityPools/github-deploy/attribute.repository/example-org/ledgerline"
}
resource "google_project_iam_member" "deployer_cluster_view" {
  project = "demo-platform"
  role = "roles/container.clusterViewer"
  member = "serviceAccount:${google_service_account.terraform_deployer.email}"
}
