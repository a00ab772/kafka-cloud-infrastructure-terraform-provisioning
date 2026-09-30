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

# --- OPCIÓN 1: INFRAESTRUCTURA EN AWS (MSK) ---
resource "aws_vpc" "kafka_vpc" {
  count      = var.cloud_provider == "aws" ? 1 : 0
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "kafka-aws-vpc" }
}

# --- OPCIÓN 2: INFRAESTRUCTURA EN GCP (GKE) ---
resource "google_compute_network" "vpc" {
  count                   = var.cloud_provider == "gcp" ? 1 : 0
  name                    = "kafka-gke-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  count         = var.cloud_provider == "gcp" ? 1 : 0
  name          = "kafka-gke-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.gcp_region
  network       = google_compute_network.vpc[0].id
}

resource "google_container_cluster" "primary" {
  count                    = var.cloud_provider == "gcp" ? 1 : 0
  name                     = var.cluster_name
  location                 = var.gcp_region
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = google_compute_network.vpc[0].name
  subnetwork               = google_compute_subnetwork.subnet[0].name
}

resource "google_container_node_pool" "primary_nodes" {
  count      = var.cloud_provider == "gcp" ? 1 : 0
  name       = "${var.cluster_name}-node-pool"
  location   = var.gcp_region
  cluster    = google_container_cluster.primary[0].name
  node_count = 2

  node_config {
    machine_type = "e2-standard-4"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# --- OPCIÓN 3: INFRAESTRUCTURA EN CONFLUENT CLOUD ---
resource "confluent_environment" "production" {
  count        = var.cloud_provider == "confluent" ? 1 : 0
  display_name = "production-environment"
}

# --- OPCIÓN 4: INFRAESTRUCTURA EN AWS (EKS) ---
resource "aws_vpc" "eks_vpc" {
  count                = var.cloud_provider == "eks" ? 1 : 0
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "kafka-eks-vpc" }
}

resource "aws_subnet" "eks_subnet_one" {
  count             = var.cloud_provider == "eks" ? 1 : 0
  vpc_id            = aws_vpc.eks_vpc[0].id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "${var.aws_region}a"
  tags              = { Name = "kafka-eks-subnet-1" }
}

resource "aws_subnet" "eks_subnet_two" {
  count             = var.cloud_provider == "eks" ? 1 : 0
  vpc_id            = aws_vpc.eks_vpc[0].id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "${var.aws_region}b"
  tags              = { Name = "kafka-eks-subnet-2" }
}

resource "aws_iam_role" "eks_cluster_role" {
  count = var.cloud_provider == "eks" ? 1 : 0
  name  = "kafka-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  count      = var.cloud_provider == "eks" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role[0].name
}

resource "aws_eks_cluster" "primary" {
  count    = var.cloud_provider == "eks" ? 1 : 0
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role[0].arn

  vpc_config {
    subnet_ids = [
      aws_subnet.eks_subnet_one[0].id,
      aws_subnet.eks_subnet_two[0].id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}