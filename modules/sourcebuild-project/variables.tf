# 기본
variable "name" {
  type        = string
  description = "SourceBuild Project name (영문/숫자/-, _)"
  validation {
    condition     = can(regex("^[A-Za-z0-9_-]+$", var.name))
    error_message = "name 은 영문/숫자/-, _ 만 허용됩니다."
  }
}
variable "description" {
  type        = string
  default     = null
  description = "Project description"
}

# Source
variable "repository_name" {
  type        = string
  description = "SourceCommit repository name"
  validation {
    condition     = length(var.repository_name) > 0
    error_message = "repository_name 은 필수입니다."
  }
}
variable "branch" {
  type        = string
  default     = "master"   # ← 기본 브랜치
  description = "Branch name to build"
  validation {
    condition     = length(var.branch) > 0
    error_message = "branch 는 필수입니다."
  }
}

# Env
variable "compute_id" {
  type        = number
  description = "Compute type ID"
}
variable "platform_type" {
  type        = string
  description = "Build env type: SourceBuild | ContainerRegistry | PublicRegistry"
  validation {
    condition     = contains(["SourceBuild", "ContainerRegistry", "PublicRegistry"], var.platform_type)
    error_message = "platform_type must be one of: SourceBuild, ContainerRegistry, PublicRegistry."
  }
}

# SourceBuild 전용
variable "os_id" {
  type        = number
  default     = null
  description = "(SourceBuild) OS ID"
}
variable "runtime_id" {
  type        = number
  default     = null
  description = "(SourceBuild) Runtime ID"
}
variable "runtime_version_id" {
  type        = number
  default     = null
  description = "(SourceBuild) Runtime Version ID"
}

# ContainerRegistry/PublicRegistry 전용
variable "registry_name" {
  type        = string
  default     = null
  description = "(ContainerRegistry) registry name"
}
variable "image_name" {
  type        = string
  default     = null
  description = "(ContainerRegistry/PublicRegistry) image name"
}
variable "image_tag" {
  type        = string
  default     = null
  description = "(ContainerRegistry/PublicRegistry) image tag"
}

# 옵션
variable "timeout" {
  type        = number
  default     = 60
  description = "Build timeout in minutes (5~540)"
  validation {
    condition     = var.timeout >= 5 && var.timeout <= 540
    error_message = "timeout must be between 5 and 540 minutes."
  }
}

variable "docker_use" {
  type        = bool
  default     = false
  description = "Use docker engine"
}
variable "docker_engine_id" {
  type        = number
  default     = null
  description = "(optional) Docker engine ID when docker_use = true"
}

variable "env_vars" {
  description = "Environment variables list"
  type = list(object({
    key   = string
    value = string
  }))
  default = []
}

# build_command
variable "enable_build_command" {
  type        = bool
  default     = false
  description = "Enable build_command"
}
variable "pre_build" {
  type        = list(string)
  default     = []
  description = "pre_build commands (no empty strings)"
}
variable "in_build" {
  type        = list(string)
  default     = []
  description = "in_build commands (no empty strings)"
}
variable "post_build" {
  type        = list(string)
  default     = []
  description = "post_build commands (no empty strings)"
}

variable "docker_image_build" {
  description = "Docker image build config"
  type = object({
    use        = bool
    dockerfile = optional(string)
    registry   = optional(string)
    image      = optional(string)
    tag        = optional(string)
    latest     = optional(bool, false)
  })
  default = {
    use = false
  }
}

# artifact
variable "artifact" {
  description = "Artifact config"
  type = object({
    use   = bool
    path  = optional(string)
    object_storage = optional(object({
      bucket   = string
      path     = string
      filename = string
    }))
    backup = optional(bool, false)
  })
  default = {
    use = false
  }
}

# build_image_upload
variable "build_image_upload" {
  description = "Build environment image upload after build"
  type = object({
    use                     = bool
    container_registry_name = optional(string)
    image_name              = optional(string)
    tag                     = optional(string)
    latest                  = optional(bool, false)
  })
  default = {
    use = false
  }
}

# linked
variable "linked" {
  description = "Linkage to other services"
  type = object({
    cloud_log_analytics = optional(bool, false)
    file_safer          = optional(bool, false)
  })
  default = null
}
