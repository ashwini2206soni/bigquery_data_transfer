terraform {
  backend "gcs" {
    bucket      = "backend_bg_dt"
    prefix      = "bq_dt-backend"
    credentials = "credentials.json"
  }
}