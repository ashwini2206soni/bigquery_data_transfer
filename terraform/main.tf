provider "google" {
  project     = "bigquerydatatransfer"
  region      = "us-central1"
  credentials = "credentials.json"
}

variable "access_key_id" {
  
}

variable "secret_access_key" {
  
}

data "google_project" "project" {
}

resource "google_project_iam_member" "permissions" {
  role   = "roles/storage.admin"
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-bigquerydatatransfer.iam.gserviceaccount.com"
}

resource "google_bigquery_data_transfer_config" "CSV_query_config" {
  depends_on = [google_bigquery_table.CSV_table]

  display_name   = "csv-data-transfer"
  location       = "us-central1"
  data_source_id = "amazon_s3"
  # schedule               = "every 24 hours"
  destination_dataset_id = google_bigquery_dataset.my_dataset.dataset_id
  params = {
    data_path                       = "s3://big-query-data-transfer-demo/*.csv"
    field_delimiter                 = ","
    file_format                     = "CSV"
    max_bad_records                 = 0
    skip_leading_rows               = 1
    destination_table_name_template = "CSV-big-query-table"
    access_key_id                   = var.access_key_id  
  }
  sensitive_params {
    secret_access_key = var.secret_access_key 
  }
}

# resource "google_bigquery_data_transfer_config" "JSON_query_config" {
#   depends_on = [google_bigquery_table.JSON_table]

#   display_name           = "json-data-transfer"
#   location               = "us-central1"
#   data_source_id         = "amazon_s3"
#   schedule               = "every 24 hours"
#   destination_dataset_id = google_bigquery_dataset.my_dataset.dataset_id
#   params = {
#     data_path                       = "s3://big-query-data-transfer-demo/*.json"
#     field_delimiter                 = ","
#     file_format                     = "JSON"
#     max_bad_records                 = 0
#     destination_table_name_template = "JSON-big-query-table"
#     access_key_id                   = var.access_key_id
#   }
#   sensitive_params {
#     secret_access_key = var.secret_access_key
#   }
# }

resource "google_bigquery_data_transfer_config" "JSON_query_config_GCS" {
  depends_on = [google_bigquery_table.JSON_table_Cloud_Storage, google_project_iam_member.permissions]

  display_name           = "json_GCS_data_transfer"
  location               = "us-central1"
  data_source_id         = "google_cloud_storage"
  schedule               = "every 24 hours"
  destination_dataset_id = google_bigquery_dataset.my_dataset.dataset_id
  params = {
    data_path_template       = "gs://bq-dt-test/*.json"
    field_delimiter = ","
    file_format     = "JSON"
    max_bad_records                 = 0
    skip_leading_rows               = 1
    destination_table_name_template = "JSON_big_query_GCS"
    write_disposition               = "APPEND"
  }
}


resource "google_bigquery_dataset" "my_dataset" {
  # depends_on = [google_project_iam_member.permissions]

  dataset_id    = "demo_dataset"
  friendly_name = "foo"
  description   = "bar"
  location      = "us-central1"
}


resource "google_bigquery_table" "CSV_table" {
  dataset_id = google_bigquery_dataset.my_dataset.dataset_id
  table_id   = "CSV-big-query-table"
  schema     = <<EOF
[
  {
    "name": "first_name",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "First Name"
  },
  {
    "name": "last_name",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Last Name"
  },
  {
    "name": "street",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Street name"
  },
  {
    "name": "city",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "City"
  },
  {
    "name": "state",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "State "
  },
  {
    "name": "zip_code",
    "type": "INTEGER",
    "mode": "NULLABLE",
    "description": "Zip Code"
  }
]
EOF

}

# resource "google_bigquery_table" "JSON_table" {
#   dataset_id = google_bigquery_dataset.my_dataset.dataset_id
#   table_id   = "JSON-big-query-table"
#   schema     = <<EOF

#   [
#    {
#     "name": "userId",        
#     "type":  "STRING",
#     "mode":  "REQUIRED" 
#    }
#   ,
#     {
#     "name": "jobTitleName",        
#     "type":  "STRING",
#     "mode":  "REQUIRED" 
#    },

#    {
#     "name": "firstName",        
#     "type":  "STRING",
#     "mode":  "REQUIRED" 
#    },

#    {
#     "name": "lastName",        
#     "type":  "STRING",
#     "mode":  "REQUIRED" 
#    },

#    {
#     "name": "phoneNumber",        
#     "type":  "STRING",
#     "mode":  "REQUIRED" 
#    },

#    {
#     "name": "emailAddress",        
#     "type":  "STRING",
#     "mode":  "REQUIRED" 
#    }

# ]

# EOF
# }


resource "google_bigquery_table" "JSON_table_Cloud_Storage" {
  dataset_id = google_bigquery_dataset.my_dataset.dataset_id
  table_id   = "JSON_big_query_GCS"
  schema     = <<EOF

  [
   {
    "name": "userId",        
    "type":  "STRING",
    "mode":  "REQUIRED" 
   }
  ,
    {
    "name": "jobTitleName",        
    "type":  "STRING",
    "mode":  "REQUIRED" 
   },

   {
    "name": "firstName",        
    "type":  "STRING",
    "mode":  "REQUIRED" 
   },

   {
    "name": "lastName",        
    "type":  "STRING",
    "mode":  "REQUIRED" 
   },

   {
    "name": "phoneNumber",        
    "type":  "STRING",
    "mode":  "REQUIRED" 
   },

   {
    "name": "emailAddress",        
    "type":  "STRING",
    "mode":  "REQUIRED" 
   }

]

EOF
}


resource "google_data_loss_prevention_inspect_template" "basic" {
    depends_on      = [google_bigquery_table.JSON_table_Cloud_Storage]
    parent          = "projects/bigquerydatatransfer"
    description     = "Basic user data identification"
    display_name    = "Basic User Data"

    inspect_config {
        info_types {
            name = "EMAIL_ADDRESS"
        }
        
        info_types {
            name = "PHONE_NUMBER"
        }
       
        min_likelihood = "LIKELY"
       

        limits {
            max_findings_per_item    = 0 
            max_findings_per_request = 12
        }
    }
}
resource "google_data_loss_prevention_job_trigger" "basic-bq-job" {
    depends_on      = [google_bigquery_table.JSON_table_Cloud_Storage]
    parent          = "projects/bigquerydatatransfer"
    description     = "Scanning transferred data"
    display_name    = "BigQuery Job"

    triggers {
        schedule {
            recurrence_period_duration = "86400s"
        }
    }

    inspect_job {
        inspect_template_name = google_data_loss_prevention_inspect_template.basic.id
        actions {
            save_findings {
                output_config {
                    table {
                        project_id = "bigquerydatatransfer"
                        dataset_id = "demo_dataset"
                    }
                }
            }
        }
        storage_config {
            
            
            big_query_options {
                table_reference {
                    project_id = "bigquerydatatransfer"
                    dataset_id = "demo_dataset"
                    table_id = "JSON_big_query_GCS"
                }
            } 
        }
    }
}
