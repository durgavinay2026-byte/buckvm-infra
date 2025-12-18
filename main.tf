resource "random_id" "suffix" { byte_length = 4 }

resource "google_storage_bucket" "app" {
  name          = "${var.project_id}-app-${random_id.suffix.hex}"
  location      = var.region
  force_destroy = true
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

resource "google_kms_key_ring" "kr" {
  count    = var.create_kms ? 1 : 0
  name     = "terraform-keyring"
  location = var.region
}

resource "google_kms_crypto_key" "ck" {
  count    = var.create_kms ? 1 : 0
  name     = "terraform-key"
  key_ring = google_kms_key_ring.kr[0].id
  rotation_period = "2592000s" # 30 days
}

data "google_compute_image" "debian" {
  family  = "debian-11"
  project = "debian-cloud"
}

resource "google_compute_instance" "vm" {
  name         = var.vm_name
  machine_type = var.vm_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian.self_link
      size  = 10
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    startup-script = <<-EOT
      #!/bin/bash
      echo "hello world" | tee /var/log/startup-script.log
      echo "hello world" > /dev/ttyS0
    EOT
  }

  tags = var.tags

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_storage_bucket" "vinay_bucket" {
  name          = "vinayisgreat"
  location      = var.region
  force_destroy = true
  uniform_bucket_level_access = true
}

resource "google_compute_instance" "vinaysvm" {
  name         = "vinaysvm"
  machine_type = var.vm_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian.self_link
      size  = 10
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    startup-script = <<-EOT
      #!/bin/bash
      echo "hello vinay" | tee /var/log/startup-script.log
    EOT
  }

  tags = var.tags

  lifecycle {
    prevent_destroy = false
  }
}