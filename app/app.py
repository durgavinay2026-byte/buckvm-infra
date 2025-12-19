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
