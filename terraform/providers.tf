provider "google" {
  project     = var.project
  region      = var.region
  credentials = "credentials.json"
}