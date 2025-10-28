# Enable required APIs
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

# Create a service account for Cloud Run
resource "google_service_account" "adk_sa" {
  account_id   = "adk-dataops-sa"
  display_name = "ADK DataOps Service Account"
}

# Grant IAM roles
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

# Create Artifact Registry (for container images)
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


# Deploy Cloud Run service (container to be built later)
resource "google_cloud_run_service" "adk_service" {
  name     = "adk-dataops-v4"
  location = "europe-west4"

  template {
    spec {
      service_account_name = google_service_account.adk_sa.email
      timeout_seconds = 300 # Increase timeout to 300 seconds
      containers {
        image = "europe-docker.pkg.dev/qwiklabs-gcp-00-a452125a4cae/adk-dataops-repo/adk-dataops:latest"
        ports {
          container_port = 8501
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_project_service.enabled_apis]
}

# Allow unauthenticated access (for demo)
resource "google_cloud_run_service_iam_member" "public_invoker" {
  location = "europe-west4"
  service  = google_cloud_run_service.adk_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}


# Grant Cloud Run service account Agent Engine role
resource "google_project_iam_member" "cr_role" {
  project = var.project_id
  role    = "roles/aiplatform.admin"
  member  = "serviceAccount:${google_service_account.adk_sa.email}"
}

# Allow the Cloud Run service account to use Vertex AI Reasoning Engine
resource "google_project_iam_member" "adk_aiplatform_user" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.adk_sa.email}"
}