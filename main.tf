terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0.0"
    }
    confluent = {
      source  = "confluentinc/confluent"
      version = "~> 2.0.0"
    }
  }
}

# --- PROVEEDORES ---
provider "aws" {
  region = var.aws_region
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

# --- OPCION 1: INFRAESTRUCTURA EN AWS (MSK) ---
resource "aws_vpc" "kafka_vpc" {
  count      = var.cloud_provider == "aws" ? 1 : 0
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "kafka-aws-vpc" }
}

# --- OPCION 2: INFRAESTRUCTURA EN GCP (GKE) ---
resource "google_compute_network" "vpc" {
  count                   = var.cloud_provider == "gcp" ? 1 : 0
  name                    = "kafka-gke-vpc"
  auto_create_subnetworks = false
}

# --- OPCION 3: INFRAESTRUCTURA EN CONFLUENT CLOUD ---
resource "confluent_environment" "production" {
  count        = var.cloud_provider == "confluent" ? 1 : 0
  display_name = "production-environment"
}