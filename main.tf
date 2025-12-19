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
  name     = "terraform-keyring-v2"
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
flask
pytz
gunicorn
EOF

      # Write app.py (Logic)
      cat <<EOF > app.py
from flask import Flask, render_template, request
from datetime import datetime
import pytz

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def index():
    result = None
    if request.method == 'POST':
        try:
            hour = int(request.form.get('hour'))
            minute = int(request.form.get('minute'))
            period = request.form.get('period')

            # Toronto Timezone
            toronto_tz = pytz.timezone('America/Toronto')
            vizag_tz = pytz.timezone('Asia/Kolkata')

            # Convert to 24h format
            h_24 = hour
            if period == "PM" and hour != 12:
                h_24 += 12
            elif period == "AM" and hour == 12:
                h_24 = 0

            # Create localized time
            now = datetime.now()
            dt_naive = datetime(now.year, now.month, now.day, h_24, minute)
            dt_toronto = toronto_tz.localize(dt_naive)
            
            # Convert
            dt_vizag = dt_toronto.astimezone(vizag_tz)
            result = dt_vizag.strftime('%I:%M %p')
            
        except Exception as e:
            result = "Error: " + str(e)
            
    return render_template('index.html', result=result)
EOF

      # Write templates/index.html (Design)
      cat <<EOF > templates/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Toronto to Vizag Converter</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; display: flex; align-items: center; justify-content: center; height: 100vh; }
        .card { box-shadow: 0 4px 8px rgba(0,0,0,0.1); width: 400px; }
        .result-box { background-color: #d1e7dd; color: #0f5132; padding: 15px; border-radius: 5px; margin-top: 20px; text-align: center; font-weight: bold; }
    </style>
</head>
<body>
    <div class="card">
        <div class="card-header bg-primary text-white text-center">
            <h4>Time Converter</h4>
            <small>Toronto 🇨🇦 ➡️ Vizag 🇮🇳</small>
        </div>
        <div class="card-body">
            <form method="POST">
                <div class="mb-3">
                    <label class="form-label">Select Time (EST/EDT)</label>
                    <div class="input-group">
                        <select name="hour" class="form-select">
                            {% for i in range(1, 13) %}
                            <option value="{{ i }}">{{ i }}</option>
                            {% endfor %}
                        </select>
                        <select name="minute" class="form-select">
                            {% for i in range(0, 60, 5) %}
                            <option value="{{ i }}">{{ "%02d" % i }}</option>
                            {% endfor %}
                        </select>
                        <select name="period" class="form-select">
                            <option value="AM">AM</option>
                            <option value="PM">PM</option>
                        </select>
                    </div>
                </div>
                <button type="submit" class="btn btn-primary w-100">Convert</button>
            </form>

            {% if result %}
            <div class="result-box">
                Vizag Time: {{ result }}
            </div>
            {% endif %}
        </div>
    </div>
</body>
</html>
EOF

      # Create venv and install libraries
      python3 -m venv venv
      source venv/bin/activate
      pip install -r requirements.txt

      # Kill any old processes (if re-deploying)
      pkill gunicorn || true
      pkill streamlit || true

      # Run Gunicorn in background on port 8501 (Production Server)
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