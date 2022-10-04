# # https://www.terraform.io/language/settings/backends/gcs
terraform {
  backend "gcs" {
    bucket = "mikejoseph-tf-state-dev"
    prefix = "terraform/state"
  }
}
