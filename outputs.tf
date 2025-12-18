output "vm_name" {
  value = google_compute_instance.vm.name
}

output "vm_ip" {
  value = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}

output "app_bucket" {
  value = google_storage_bucket.app.name
}