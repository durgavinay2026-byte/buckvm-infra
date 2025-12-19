import os
from google.cloud import bigquery
from faker import Faker
import random

# Initialize Faker
fake = Faker()

# Configuration
PROJECT_ID = os.environ.get("GOOGLE_CLOUD_PROJECT", "buckvm") # Default to buckvm if env var not set, or update as needed
DATASET_ID = "school_dataset"
TABLE_ID = "student"
NUM_RECORDS = 20

def generate_student_data():
    students = []
    for i in range(1, NUM_RECORDS + 1):
        student = {
            "student_id": i,
            "name": fake.name(),
            "age": random.randint(18, 25),
            "grade": random.choice(["Freshman", "Sophomore", "Junior", "Senior"]),
            "email": fake.email()
        }
        students.append(student)
    return students

def load_data_to_bq(rows):
    client = bigquery.Client(project=PROJECT_ID)
    table_ref = f"{PROJECT_ID}.{DATASET_ID}.{TABLE_ID}"
    
    errors = client.insert_rows_json(table_ref, rows)
    
    if errors:
        print(f"Encountered errors while inserting rows: {errors}")
    else:
        print(f"Successfully inserted {len(rows)} records into {table_ref}.")

if __name__ == "__main__":
    print(f"Generating {NUM_RECORDS} student records...")
    data = generate_student_data()
    print("Loading data to BigQuery...")
    try:
        load_data_to_bq(data)
    except Exception as e:
        print(f"Error: {e}")
        print("Make sure you have set GOOGLE_CLOUD_PROJECT environment variable or update the script.")
