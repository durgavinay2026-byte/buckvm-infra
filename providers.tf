variable "project_id" {
  type    = string
  default = "buckvm"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

provider "google" {
  project = var.project_id
  region  = var.region
}