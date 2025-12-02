resource "google_cloudbuild_worker_pool" "deploy" {
  project = var.project_id
  location = local.worker_pool_config.location
  name     = local.worker_pool_config.name

  display_name = "Private pool for tenant builds and deployments"

  worker_config {
    machine_type   = local.worker_pool_config.machine_type
    disk_size_gb   = local.worker_pool_config.disk_size_gb
    no_external_ip = local.worker_pool_config.no_external_ip
  }

  network_config {
    peered_network = google_compute_network.primary.id
  }

  depends_on = [google_project_service.required]
}
