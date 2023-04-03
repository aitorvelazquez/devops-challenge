variable "project_name" {
  type    = string
  default = "devops-challenge"
}

variable "app_name" {
  type    = string
  default = "test-app"
}

variable "app_version" {
  type    = string
  default = "latest"
}

variable "gcp_pg_name" {
  type    = string
  default = "pg-instance"
}

variable "gcp_pg_name_timestamp" {
  type    = string
  default = ""
}

variable "gcp_pg_database_version" {
  type    = string
  default = "POSTGRES_13"
}

variable "gcp_region" {
  type    = string
  default = "europe-southwest1"
}

variable "gcp_zone" {
  type    = string
  default = "europe-southwest1-a"
}

variable "gcp_project_id" {
  type    = string
  default = "inbound-descent-382406"
}


variable "gcp_pg_tier" {
  type    = string
  default = "db-f1-micro"
}

variable "gcp_pg_db_flag_name" {
  type    = string
  default = "cloudsql.logical_decoding"
}

variable "gcp_pg_db_flag_value" {
  type    = string
  default = "on"
}