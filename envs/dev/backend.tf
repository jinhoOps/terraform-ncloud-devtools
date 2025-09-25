# terraform {
#   backend "s3" {
#     bucket     = var.tfstate_bucket
#     key        = "dev/devtools/terraform.tfstate"
#     region     = "KR" # 위치에 맞게
#     access_key = var.access_key
#     secret_key = var.secret_key

#     # AWS 인증 로직 우회 옵션 + S3 체크섬 스킵
#     skip_region_validation      = true
#     skip_requesting_account_id  = true
#     skip_credentials_validation = true
#     skip_metadata_api_check     = true
#     skip_s3_checksum            = true

#     # state locking
#     use_lockfile = true

#     endpoints = {
#       s3 = "https://kr.object.ncloudstorage.com"
#     }
#   }
# }

terraform {
  backend "s3" {
    # 실제 값은 init 시 -backend-config 로 주입
    # bucket   = ""
    # key      = ""
    # region   = "kr-standard"
    # endpoint = "https://kr.object.ncloudstorage.com"

    skip_credentials_validation = true
    skip_region_validation      = true
    force_path_style            = true
  }
}
