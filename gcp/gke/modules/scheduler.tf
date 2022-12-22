locals {
  job_names = toset([for job in keys(var.scheduler_jobs) : job])
}

resource "google_cloud_scheduler_job" "scheduler-jobs" {
  for_each = var.environment == "prod" ? [] : local.job_names

  name             = "${var.sub_domain}-${each.key}"
  description      = "${var.sub_domain} ${each.key} scheduler job"
  project          = var.project_id
  region           = var.region
  schedule         = var.scheduler_jobs[each.key][1]
  time_zone        = var.scheduler_jobs[each.key][2]
  attempt_deadline = "180s"

  retry_config {
    max_backoff_duration = "3600s"
    min_backoff_duration = "5s"
    max_retry_duration   = "0s"
    max_doublings        = 5
  }

  http_target {
    http_method = var.scheduler_jobs[each.key][0]
    uri         = "https://${local.full_dns}/v1/${each.key}/"
    oidc_token {
      service_account_email = google_service_account.scheduler-sa.email
    }
  }

  depends_on = [
    google_service_account.scheduler-sa,
    google_service_account_iam_member.gce-default-account-iam,
    module.gke
  ]
}
