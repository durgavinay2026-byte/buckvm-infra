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
      # Install dependencies
      apt-get update
      apt-get install -y python3-pip python3-venv

      # Create app directory
      mkdir -p /opt/time_app
      cd /opt/time_app

      # Write app code
      cat <<EOF > app.py
import streamlit as st
from datetime import datetime
import pytz

st.title("Toronto to Vizag Time Converter")

# Input: Toronto Time
st.header("Select Toronto Time (EST/EDT)")
col1, col2, col3 = st.columns(3)
with col1:
    hour = st.selectbox("Hour", range(1, 13))
with col2:
    minute = st.selectbox("Minute", range(0, 60))
with col3:
    period = st.selectbox("AM/PM", ["AM", "PM"])

if st.button("Convert to Vizag Time"):
    # Logic to convert time
    toronto_tz = pytz.timezone('America/Toronto')
    vizag_tz = pytz.timezone('Asia/Kolkata')
    
    # Construct 24h format for calculation
    h_24 = hour
    if period == "PM" and hour != 12:
        h_24 += 12
    elif period == "AM" and hour == 12:
        h_24 = 0
        
    # Create naive datetime object for today with selected time
    now = datetime.now()
    dt_naive = datetime(now.year, now.month, now.day, h_24, minute)
    
    # Localize to Toronto
    dt_toronto = toronto_tz.localize(dt_naive)
    
    # Convert to Vizag
    dt_vizag = dt_toronto.astimezone(vizag_tz)
    
    st.success(f"Time in Vizag: {dt_vizag.strftime('%I:%M %p')}")
EOF

      # Create venv and install libraries
      python3 -m venv venv
      source venv/bin/activate
      pip install streamlit pytz

      # Run app in background on port 8501
      nohup streamlit run app.py --server.port 8501 --server.address 0.0.0.0 &
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