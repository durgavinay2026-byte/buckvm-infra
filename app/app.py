from flask import Flask, render_template, request
from datetime import datetime
import pytz
import os
from google.cloud import bigquery

app = Flask(__name__)

# Initialize BigQuery Client
# Ensure GOOGLE_CLOUD_PROJECT env var is set or default to 'buckvm'
project_id = os.environ.get("GOOGLE_CLOUD_PROJECT", "buckvm")
bq_client = bigquery.Client(project=project_id)

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

@app.route('/students')
def students():
    try:
        query = f"SELECT * FROM `{project_id}.school_dataset.student` ORDER BY student_id"
        query_job = bq_client.query(query)
        students = [dict(row) for row in query_job]
        return render_template('students.html', students=students)
    except Exception as e:
        return render_template('students.html', students=[], error=str(e))
