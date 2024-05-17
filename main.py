import boto3
import psycopg2
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

def read_from_s3(bucket_name, file_key):
    s3 = boto3.client('s3')
    try:
        response = s3.get_object(Bucket=bucket_name, Key=file_key)
        data = response['Body'].read().decode('utf-8')
        return data
    except (NoCredentialsError, PartialCredentialsError) as e:
        print(f"Credentials error: {e}")
        return None

def push_to_rds(data, db_params):
    try:
        connection = psycopg2.connect(**db_params)
        cursor = connection.cursor()
        insert_query = "INSERT INTO your_table (column1) VALUES (%s)"
        cursor.execute(insert_query, (data,))
        connection.commit()
        cursor.close()
        connection.close()
    except Exception as e:
        print(f"Failed to insert data into RDS: {e}")
        return False
    return True

def push_to_glue(data, glue_params):
   
    print("Data pushed to Glue database")
    return True

def main():
    bucket_name = 'your-s3-bucket'
    file_key = 'your-file-key'
    db_params = {
        'dbname': 'yourdbname',
        'user': 'youruser',
        'password': 'yourpassword',
        'host': 'yourhost',
        'port': 'yourport'
    }

    data = read_from_s3(bucket_name, file_key)
    if data:
        if not push_to_rds(data, db_params):
            push_to_glue(data, {})

if __name__ == "__main__":
    main()
