from pyspark.sql import SparkSession
from pyspark.sql.functions import col, from_json, schema_of_json
from pyspark.sql.types import StructType, StringType
from delta.tables import DeltaTable
import sys
import boto3
import json

# Initialize the Spark session with Delta Lake configuration
spark = SparkSession.builder \
    .appName("Delta Lake ETL Process") \
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog") \
    .config("spark.databricks.delta.retentionDurationCheck.enabled", "false") \
    .getOrCreate()

# Log level
spark.sparkContext.setLogLevel("INFO")

# Define S3 bucket paths
source_bucket = "${source_bucket}"
target_bucket = "${target_bucket}"

# Input and output paths
input_path = f"s3://{source_bucket}/raw_landing_zone/orders/data.json"
output_path = f"s3://{target_bucket}/delta_lake/orders"

def main():
    try:
        print(f"Reading data from {input_path}")
        
        # Read the JSON file from S3
        # First, read the raw data as a string to determine schema
        raw_df = spark.read.text(input_path)
        
        if raw_df.count() == 0:
            print("No data found in source location")
            return
            
        # Parse the JSON string
        json_str = raw_df.first()[0]
        parsed_data = json.loads(json_str)
        
        # Create a schema from the first record
        if len(parsed_data) > 0:
            schema = spark.read.json(spark.sparkContext.parallelize([json_str])).schema
            
            # Now read with the inferred schema
            df = spark.read.schema(schema).json(input_path)
            
            print(f"Read {df.count()} records from source")
            
            # Check if Delta table exists
            delta_table_exists = DeltaTable.isDeltaTable(spark, output_path)
            
            if delta_table_exists:
                print(f"Delta table exists at {output_path}, performing upsert operation")
                
                # Load the existing Delta table
                delta_table = DeltaTable.forPath(spark, output_path)
                
                # Get the join key - using order_id as the primary key
                join_key = "order_id"
                
                # Perform UPSERT (MERGE) operation
                delta_table.alias("target").merge(
                    df.alias("source"),
                    f"target.{join_key} = source.{join_key}"
                ).whenMatchedUpdateAll().whenNotMatchedInsertAll().execute()
                
                print(f"Upsert completed successfully to {output_path}")
            else:
                print(f"Delta table does not exist at {output_path}, creating new table")
                
                # Write the data as a new Delta table
                df.write.format("delta").mode("overwrite").save(output_path)
                
                print(f"Created new Delta table at {output_path}")
                
            # Display table stats
            print("Table statistics:")
            spark.read.format("delta").load(output_path).printSchema()
            print(f"Total records: {spark.read.format('delta').load(output_path).count()}")
            
        else:
            print("Parsed JSON data is empty")
            
    except Exception as e:
        print(f"Error in Delta Lake transformation: {str(e)}")
        raise e
    finally:
        # Stop the Spark session
        spark.stop()
        print("Spark session stopped")

if __name__ == "__main__":
    main()