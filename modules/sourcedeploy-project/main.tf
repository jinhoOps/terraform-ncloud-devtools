# SourceDeploy Project
resource "ncloud_sourcedeploy_project" "this" {
  name = var.name
  # 필요 시 description 등 확장
}

output "project_no" {
  value = ncloud_sourcedeploy_project.this.id
}
