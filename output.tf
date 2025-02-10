output "gke_sa_email" {
  value = google_service_account.gke-service-sa.email
}

output "gke_sa_key" {
  value = google_storage_bucket_object.service_account_key.media_link
}