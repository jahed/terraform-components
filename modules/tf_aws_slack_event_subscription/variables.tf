variable "region" {
  type = "string"
}

variable "account_id" {
  type = "string"
}

variable "source_code_hash" {
  type = "string"
}

variable "app_name" {
  type = "string"
}

variable "handler" {
  type = "string"
}

variable "runtime" {
  type = "string"
}

variable "timeout" {
  type = "string"
}

variable "api_id" {
  type = "string"
}

variable "root_resource_id" {
  type = "string"
}

variable "environment_variables" {
  type = "map"
  default = {}
}

variable "filename" {
  type = "string"
  default = ""
}

variable "s3_bucket" {
  type = "string",
  default = ""
}

variable "s3_key" {
  type = "string",
  default = ""
}