# 1️⃣ Enable required APIs
resource "google_project_service" "enabled_apis" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "bigquery.googleapis.com",
    "cloudbuild.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "aiplatform.googleapis.com"
  ])
  project = var.project_id
  service = each.key
}

# 2️⃣ Create a service account for Cloud Run
resource "google_service_account" "adk_sa" {
  account_id   = "adk-dataops-sa"
  display_name = "ADK DataOps Service Account"
}

# 3️⃣ Grant IAM roles
resource "google_project_iam_member" "adk_bq_user" {
  project = var.project_id
  role    = "roles/bigquery.user"
  member  = "serviceAccount:${google_service_account.adk_sa.email}"
}

resource "google_project_iam_member" "adk_run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.adk_sa.email}"
}

# Grant BigQuery Job User role to AI Platform Reasoning Engine service account
resource "google_project_iam_member" "aiplatform_bq_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:service-469827268895@gcp-sa-aiplatform-re.iam.gserviceaccount.com"
}

# 4️⃣ Create Artifact Registry (for container images)
resource "google_artifact_registry_repository" "repo" {
  location      = "europe"
  repository_id = "adk-dataops-repo"
  description   = "Artifact Registry for ADK app"
  format        = "DOCKER"
  depends_on = [ google_project_service.enabled_apis ]
}

resource "google_storage_bucket" "default" {
  name          = var.agent_bucket_name
  location      = "EU"
  force_destroy = true
}

# # 5️⃣ Create BigQuery dataset
# resource "google_bigquery_dataset" "adk_demo" {
#   dataset_id  = "adk_demo"
#   description = "Demo dataset for DataOps Assistant"
#   location    = "US"
# }


# 6️⃣ Deploy Cloud Run service (container to be built later)
# resource "google_cloud_run_service" "adk_service" {
#   name     = var.service_name
#   location = var.region

#   template {
#     spec {
#       service_account_name = google_service_account.adk_sa.email
#       containers {
#         image = "us-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}/adk-dataops:latest"
#         ports {
#           container_port = 8080
#         }
#       }
#     }
#   }

#   traffic {
#     percent         = 100
#     latest_revision = true
#   }
# }

# # 7️⃣ Allow unauthenticated access (for demo)
# resource "google_cloud_run_service_iam_member" "public_invoker" {
#   location = var.region
#   service  = google_cloud_run_service.adk_service.name
#   role     = "roles/run.invoker"
#   member   = "allUsers"
# }
