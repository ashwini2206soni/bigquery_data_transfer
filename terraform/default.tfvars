project     = "bigquerydatatransfer"
region      = "us-central1"


bq_dt_csv_config = {
    name = "csv-data-transfer"
    location = "us-central1"
    data_source_id = "amazon_s3"
}
bq_dt_json_config = {
    name = "json_GCS_data_transfer"
    location = "us-central1"
    data_source_id = "google_cloud_storage"
}
dataset={
  dataset_id    = "demo_dataset"
  friendly_name = "foo"
  description   = "bar"
  location      = "us-central1"
}
csv_table_id="CSV-big-query-table"

json_table_id= "JSON_big_query_GCS"

dlp_inspect_template={
    parent          = "projects/bigquerydatatransfer"
    description     = "Basic user data identification"
    display_name    = "Basic User Data"
}
dlp_job_trigger={
    parent          = "projects/bigquerydatatransfer"
    description     = "Scanning transferred data"
    display_name    = "BigQuery Job"
}