module "sourcebuild_project" {
  source = "../../modules/sourcebuild-project"

  # 기본 정보
  name        = var.sb_project_name
  description = "dev build project"

  # 기존 저장소 지정 (이미 SourceCommit에 존재하는 이름)
  repository_name = var.repository_name
  # branch는 module 기본값 "master" 사용 ⇒ 필요 시 var.branch로 재정의 가능

  # 빌드 환경 (ID는 data 소스로 조회 or 임시 수치)
  compute_id         = var.sb_compute_id
  platform_type      = "SourceBuild"
  os_id              = var.sb_os_id
  runtime_id         = var.sb_runtime_id
  runtime_version_id = var.sb_runtime_version_id

  # 옵션들
  timeout              = 60
  docker_use           = false
  env_vars             = []
  enable_build_command = false
}
