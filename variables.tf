variable "cloud_provider" {
  type        = string
  default     = "aws"
  description = "Elige la plataforma de destino: aws, gcp o confluent"
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "gcp_project_id" {
  type    = string
  default = "mi-proyecto-gcp"
}

variable "gcp_region" {
  type    = string
  default = "eu-central1"
}

variable "confluent_cloud_api_key" {
  type      = string
  default   = ""
  sensitive = true
}

variable "confluent_cloud_api_secret" {
  type      = string
  default   = ""
  sensitive = true
}