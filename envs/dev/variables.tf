variable "access_key" {
  type      = string
}

variable "secret_key" {
  type      = string
  sensitive = true
}

variable "region" {
  type    = string
  default = "KR"
}

variable "site" {
  type    = string
  default = "public"
}

variable "tfstate_bucket" {
  type = string
}

variable "repository_name" {
  type = string
}

variable "sb_project_name" {
  type = string
}

variable "sb_branch" {
  type    = string
  default = "main"
}

variable "sb_compute_id" {
  type = number
}

variable "sb_os_id" {
  type = number
}

variable "sb_runtime_id" {
  type = number
}

variable "sb_runtime_version_id" {
  type = number
}

# variable "deploy_project_name" {
#   type = string
# }

# variable "scenario_name" {
#   type = string
# }

# variable "scenario_steps" {
#   type = any # 자유 형식(스켈레톤)
# }
