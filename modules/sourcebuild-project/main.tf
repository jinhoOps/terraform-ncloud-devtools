resource "ncloud_sourcebuild_project" "this" {
  # 필수
  name        = var.name
  description = var.description

  # ── Source
  source {
    type = "SourceCommit"
    config {
      repository_name = var.repository_name
      branch          = var.branch
    }
  }

  # ── Env
  env {
    compute {
      id = var.compute_id
    }

    platform {
      type = var.platform_type

      # type = "SourceBuild"
      dynamic "config" {
        for_each = var.platform_type == "SourceBuild" ? [1] : []
        content {
          os {
            id = var.os_id
          }
          runtime {
            id = var.runtime_id
            version {
              id = var.runtime_version_id
            }
          }
        }
      }

      # type = "ContainerRegistry"
      dynamic "config" {
        for_each = var.platform_type == "ContainerRegistry" ? [1] : []
        content {
          registry = var.registry_name
          image    = var.image_name
          tag      = var.image_tag
        }
      }

      # type = "PublicRegistry"
      dynamic "config" {
        for_each = var.platform_type == "PublicRegistry" ? [1] : []
        content {
          image = var.image_name
          tag   = var.image_tag
        }
      }
    }

    timeout = var.timeout

    dynamic "docker_engine" {
      for_each = var.docker_use ? [1] : []
      content {
        use = true
        id  = var.docker_engine_id
      }
    }

    dynamic "env_var" {
      for_each = var.env_vars
      content {
        key   = env_var.value.key
        value = env_var.value.value
      }
    }
  }

  # ── Build Command (선택)
  dynamic "build_command" {
    for_each = var.enable_build_command ? [1] : []
    content {
      pre_build  = var.pre_build
      in_build   = var.in_build
      post_build = var.post_build

      dynamic "docker_image_build" {
        for_each = var.docker_image_build.use ? [1] : []
        content {
          use        = true
          dockerfile = var.docker_image_build.dockerfile
          registry   = var.docker_image_build.registry
          image      = var.docker_image_build.image
          tag        = var.docker_image_build.tag
          latest     = var.docker_image_build.latest
        }
      }
    }
  }

  # ── Artifact (선택)
  dynamic "artifact" {
    for_each = var.artifact.use ? [1] : []
    content {
      use  = true
      path = var.artifact.path

      object_storage_to_upload {
        bucket   = var.artifact.object_storage.bucket
        path     = var.artifact.object_storage.path
        filename = var.artifact.object_storage.filename
      }

      backup = var.artifact.backup
    }
  }

  # ── Build Image Upload (선택)
  dynamic "build_image_upload" {
    for_each = var.build_image_upload.use ? [1] : []
    content {
      use                     = true
      container_registry_name = var.build_image_upload.container_registry_name
      image_name              = var.build_image_upload.image_name
      tag                     = var.build_image_upload.tag
      latest                  = var.build_image_upload.latest
    }
  }

  # ── Linked (선택)
  dynamic "linked" {
    for_each = var.linked != null ? [1] : []
    content {
      cloud_log_analytics = var.linked.cloud_log_analytics
      file_safer          = var.linked.file_safer
    }
  }

  # ─────────────────────────────────────────
  # Pre-conditions (플랫폼/옵션별 필수값 검증)
  # ─────────────────────────────────────────
  lifecycle {
    precondition {
      condition     = var.platform_type != "SourceBuild" || (var.os_id != null && var.runtime_id != null && var.runtime_version_id != null)
      error_message = "platform_type=SourceBuild 인 경우 os_id, runtime_id, runtime_version_id 는 필수입니다."
    }
    precondition {
      condition     = var.platform_type != "ContainerRegistry" || (try(length(var.registry_name) > 0, false) && try(length(var.image_name) > 0, false) && try(length(var.image_tag) > 0, false))
      error_message = "platform_type=ContainerRegistry 인 경우 registry_name, image_name, image_tag 는 필수입니다."
    }
    precondition {
      condition     = var.platform_type != "PublicRegistry" || (try(length(var.image_name) > 0, false) && try(length(var.image_tag) > 0, false))
      error_message = "platform_type=PublicRegistry 인 경우 image_name, image_tag 는 필수입니다."
    }
    precondition {
      condition     = !var.docker_use || var.docker_engine_id != null
      error_message = "docker_use=true 인 경우 docker_engine_id 를 지정해야 합니다."
    }
    precondition {
      condition     = !var.enable_build_command || (alltrue([for c in concat(var.pre_build, var.in_build, var.post_build) : length(c) > 0]))
      error_message = "build_command 를 사용할 때는 pre/in/post 리스트 내에 빈 문자열이 있으면 안 됩니다."
    }
    precondition {
      condition     = !var.docker_image_build.use || (try(length(var.docker_image_build.dockerfile) > 0, false) && try(length(var.docker_image_build.registry) > 0, false) && try(length(var.docker_image_build.image) > 0, false) && try(length(var.docker_image_build.tag) > 0, false))
      error_message = "docker_image_build.use=true 인 경우 dockerfile, registry, image, tag 를 모두 지정해야 합니다."
    }
    precondition {
      condition     = !var.artifact.use || (try(length(var.artifact.path) > 0, false) && var.artifact.object_storage != null && try(length(var.artifact.object_storage.bucket) > 0, false) && try(length(var.artifact.object_storage.path) > 0, false) && try(length(var.artifact.object_storage.filename) > 0, false))
      error_message = "artifact.use=true 인 경우 path 및 object_storage_to_upload(bucket/path/filename) 이 필수입니다."
    }
    precondition {
      condition     = !var.build_image_upload.use || (try(length(var.build_image_upload.container_registry_name) > 0, false) && try(length(var.build_image_upload.image_name) > 0, false) && try(length(var.build_image_upload.tag) > 0, false))
      error_message = "build_image_upload.use=true 인 경우 container_registry_name, image_name, tag 가 필수입니다."
    }
    precondition {
      condition     = alltrue([for ev in var.env_vars : (length(ev.key) > 0 && length(ev.value) > 0)])
      error_message = "env_vars 의 key/value 는 빈 문자열일 수 없습니다."
    }
  }
}
