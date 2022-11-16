resource "google_pubsub_topic" "pubsub-topics" {
  for_each = var.environment == "prod" ? [] : toset(var.pubsub_topics)

  name    = "${each.key}-${var.environment}"
  project = var.project_id

  labels = {
    environment = var.environment
  }

  depends_on = [
    module.gke
  ]
}
