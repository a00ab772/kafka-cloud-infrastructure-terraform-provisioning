# Selecciona dónde quieres desplegar: "aws", "gcp" o "confluent"
cloud_provider = "aws"

# Credenciales y parámetros para AWS
aws_region   = "eu-central-1"
cluster_name = "production-msk-cluster"

# Credenciales y parámetros para GCP (si eliges "gcp")
gcp_project_id = "tu-proyecto-de-gcp"
gcp_region     = "eu-central1"

# Credenciales para Confluent Cloud (si eliges "confluent")
confluent_cloud_api_key    = "TU_API_KEY"
confluent_cloud_api_secret = "TU_API_SECRET"