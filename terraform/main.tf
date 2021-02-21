
data "google_project" "project" {
}

resource "google_project_iam_member" "permissions" {
  role   = "roles/storage.admin"
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-bigquerydatatransfer.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "permission" {
  role   = "roles/iam.serviceAccountShortTermTokenMinter"
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-bigquerydatatransfer.iam.gserviceaccount.com"
}

resource "google_bigquery_data_transfer_config" "CSV_query_config" {
  depends_on = [google_bigquery_table.CSV_table]

  display_name   = lookup(var.bq_dt_csv_config, "name", "")
  location       = lookup(var.bq_dt_csv_config, "location", "")
  data_source_id = lookup(var.bq_dt_csv_config, "data_source_id", "")
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


resource "google_bigquery_data_transfer_config" "JSON_query_config_GCS" {
  depends_on     = [google_bigquery_table.JSON_table_Cloud_Storage, google_project_iam_member.permissions]
  display_name   = lookup(var.bq_dt_json_config, "name", "")
  location       = lookup(var.bq_dt_json_config, "location", "")
  data_source_id = lookup(var.bq_dt_json_config, "data_source_id", "")
  # schedule               = "every 24 hours"
  destination_dataset_id = google_bigquery_dataset.my_dataset.dataset_id
  params = {
    data_path_template              = "gs://bq-dt-test/*.json"
    field_delimiter                 = ","
    file_format                     = "JSON"
    max_bad_records                 = 0
    skip_leading_rows               = 1
    destination_table_name_template = "JSON_big_query_GCS"
    write_disposition               = "APPEND"
  }
}


resource "google_bigquery_dataset" "my_dataset" {
  dataset_id    = lookup(var.dataset, "dataset_id", "")
  friendly_name = lookup(var.dataset, "friendly_name", "")
  description   = lookup(var.dataset, "description", "")
  location      = lookup(var.dataset, "location", "")
}


resource "google_bigquery_table" "CSV_table" {
  dataset_id = google_bigquery_dataset.my_dataset.dataset_id
  table_id   = var.csv_table_id
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


resource "google_bigquery_table" "JSON_table_Cloud_Storage" {
  dataset_id = google_bigquery_dataset.my_dataset.dataset_id
  table_id   = var.json_table_id
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
  depends_on   = [google_bigquery_table.JSON_table_Cloud_Storage]
  parent       = lookup(var.dlp_inspect_template, "parent", "")
  description  = lookup(var.dlp_inspect_template, "description", "")
  display_name = lookup(var.dlp_inspect_template, "display_name", "")

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
  depends_on   = [google_bigquery_table.JSON_table_Cloud_Storage]
  parent       = lookup(var.dlp_job_trigger, "parent", "")
  description  = lookup(var.dlp_job_trigger, "description", "")
  display_name = lookup(var.dlp_job_trigger, "display_name", "")

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
          table_id   = "JSON_big_query_GCS"
        }
      }
    }
  }
}
