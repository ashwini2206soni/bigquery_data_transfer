variable "project" {
  type = string
  description = "Project ID of the project to be used"  
}
variable "region" {
  type = string
  description = "Region of the project"
}
variable "access_key_id" {
  
}
variable "secret_access_key" {
  
}

variable "bq_dt_csv_config" {
  type = map
  description = "value"
}

variable "bq_dt_json_config" {
  type = map
  description= ""
}

variable "dataset" {
  type = map
  description = ""
}

variable "csv_table_id" {
  type = string
  description = ""
}

variable "json_table_id"{
  type = string
  description = ""
}
variable "dlp_inspect_template"{
    type = map
    description = ""
}
variable "dlp_job_trigger"{
    type = map
    description     = "Scanning transferred data"
    
}