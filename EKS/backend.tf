# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-researchef-dev"
#     dynamodb_table = "terraform-locks-test"
#     region         = "ap-northeast-1"
#     key            = "core/platform/terraform.tfstate"
#     encrypt        = true
#   }
# }

