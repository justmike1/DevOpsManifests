# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-bucket"
#     dynamodb_table = "terraform-locks-test"
#     region         = "ap-northeast-1"
#     key            = "core/platform/terraform.tfstate"
#     encrypt        = true
#   }
# }

