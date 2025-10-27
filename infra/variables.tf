variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for deployment"
  type        = string
  default     = "us-central1"
}

variable "service_name" {
  description = "Name for the Cloud Run service"
  type        = string
  default     = "adk-dataops"
}

variable "agent_bucket_name" {
  description = "agent bucket name"
}