variable "project" {
  type        = string
  description = "Project ID of the project to be used"
}
variable "region" {
  type        = string
  description = "Region of the project"
}
variable "access_key_id" {

}
variable "secret_access_key" {

}

variable "bq_dt_csv_config" {
  type        = map(any)
  description = "value"
}

variable "bq_dt_json_config" {
  type        = map(any)
  description = ""
}

variable "dataset" {
  type        = map(any)
  description = ""
}

variable "csv_table_id" {
  type        = string
  description = ""
}

variable "json_table_id" {
  type        = string
  description = ""
}
variable "dlp_inspect_template" {
  type        = map(any)
  description = ""
}
variable "dlp_job_trigger" {
  type        = map(any)
  description = "Scanning transferred data"

}