import json
import psycopg2
import boto3
from datetime import datetime

# Database configuration
db_endpoint = "${db_endpoint}"
db_name = "${db_name}"
db_username = "${db_username}"
db_password = "${db_password}"

# Parse the endpoint to get host and port
db_host = db_endpoint.split(':')[0]
db_port = 5432  # Default PostgreSQL port

# S3 configuration
s3_bucket = "${s3_bucket}"
s3_key = "raw_landing_zone/orders/data.json"

# DynamoDB configuration
dynamo_table_name = "${dynamo_table}"
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(dynamo_table_name)

def default_serializer(obj):
    if isinstance(obj, datetime):
        return obj.strftime('%Y-%m-%d %H:%M:%S')

def insert_dynamo_log(table_name, filter_column, last_value, last_run_ts):
    # Insert a new row in DynamoDB after successful extraction
    table.put_item(Item={
        'table_name': table_name,
        'filter_column': filter_column,
        'last_extracted_value': last_value,
        'last_run_ts': last_run_ts
    })

def main():
    try:
        # Connect to the RDS database
        connection = psycopg2.connect(
            host=db_host,
            port=db_port,
            user=db_username,
            password=db_password,
            database=db_name
        )
        
        # Fetch settings from DynamoDB to get the latest filter value and filter column
        try:
            response = table.get_item(Key={'table_name': 'orders', 'filter_column': 'last_updated_ts'})
            filter_value = response['Item']['last_extracted_value'] if 'Item' in response else '2024-01-01 00:00:00.000000'
        except Exception as e:
            print(f"Error fetching from DynamoDB: {str(e)}")
            filter_value = '2024-01-01 00:00:00.000000'
        
        filter_column = 'last_updated_ts'
        table_name = 'orders'
        
        # Execute SQL query to fetch data
        with connection.cursor() as cursor:
            sql = f"SELECT * FROM {table_name} WHERE {filter_column} > '{filter_value}'"
            cursor.execute(sql)
            
            # Get column names from cursor description
            columns = [desc[0] for desc in cursor.description]
            
            # Fetch all rows
            rows = cursor.fetchall()
            
            # Convert to list of dictionaries
            result = []
            for row in rows:
                row_dict = {}
                for i, col in enumerate(columns):
                    row_dict[col] = row[i]
                result.append(row_dict)
        
        # Process result if not empty
        if result:
            print(f"Extracted {len(result)} rows from PostgreSQL")
            
            # Serialize the result
            serialized_result = json.dumps(result, default=default_serializer)
            
            # Find the maximum last_updated_ts value
            max_updated_date = max([row[filter_column] for row in result]) if filter_column in result[0] else datetime.now()
            
            # Current timestamp
            current_timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            
            # Write data to S3 (overwrite mode)
            s3 = boto3.client('s3')
            s3.put_object(Body=serialized_result, Bucket=s3_bucket, Key=s3_key)
            print(f"Data written to S3: s3://{s3_bucket}/{s3_key}")
            
            # Insert new log entry into DynamoDB
            max_date_str = max_updated_date.strftime('%Y-%m-%d %H:%M:%S') if isinstance(max_updated_date, datetime) else max_updated_date
            insert_dynamo_log(table_name, filter_column, max_date_str, current_timestamp)
            print('ETL log updated in DynamoDB')
        else:
            print("No new data to extract")
            
    except Exception as e:
        print(f'Error: {str(e)}')
    finally:
        if 'connection' in locals() and connection:
            connection.close()
            print("Database connection closed")

if __name__ == '__main__':
    main()