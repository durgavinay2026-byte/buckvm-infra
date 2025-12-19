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
  name     = "terraform-keyring-${random_id.suffix.hex}"
  location = var.region
}

resource "google_kms_crypto_key" "ck" {
  count    = var.create_kms ? 1 : 0
  name     = "terraform-key-v2"
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

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata = {
    startup-script = <<-EOT
      #!/bin/bash
      # Install dependencies
      apt-get update
      apt-get install -y python3-pip python3-venv

      # Create app directory
      mkdir -p /opt/time_app/templates
      cd /opt/time_app

      # Write requirements.txt
      cat <<EOF > requirements.txt
${file("${path.module}/app/requirements.txt")}
EOF

      # Write app.py (Logic)
      cat <<EOF > app.py
${file("${path.module}/app/app.py")}
EOF

      # Write templates/index.html (Design)
      cat <<EOF > templates/index.html
${file("${path.module}/app/templates/index.html")}
EOF

      # Write templates/students.html (New Template)
      cat <<EOF > templates/students.html
${file("${path.module}/app/templates/students.html")}
EOF

      # Create venv and install libraries
      python3 -m venv venv
      source venv/bin/activate
      pip install -r requirements.txt

      # Kill any old processes (if re-deploying)
      pkill gunicorn || true
      pkill streamlit || true

      # Run Gunicorn in background on port 8501 (Production Server)
      export GOOGLE_CLOUD_PROJECT="${var.project_id}"
      nohup gunicorn --bind 0.0.0.0:8501 app:app &
    EOT
  }

  tags = var.tags

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_compute_instance" "psychosaipriya" {
  name         = "psychosaipriya"
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
      echo "hello psychosaipriya" | tee /var/log/startup-script.log
    EOT
  }

  tags = var.tags

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = "school_dataset"
  friendly_name               = "School Dataset"
  description                 = "This is a dataset for school data"
  location                    = "US"
  default_table_expiration_ms = 3600000

  labels = {
    env = "default"
  }
}

resource "google_bigquery_table" "student" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "student"

  schema = <<EOF
[
  {
    "name": "student_id",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Unique ID for the student"
  },
  {
    "name": "name",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Name of the student"
  },
  {
    "name": "age",
    "type": "INTEGER",
    "mode": "NULLABLE",
    "description": "Age of the student"
  },
  {
    "name": "grade",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Grade of the student"
  },
  {
    "name": "email",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Email address of the student"
  }
]
EOF
}