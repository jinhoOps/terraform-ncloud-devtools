output "sourcebuild_project_id" {
  description = "SourceBuild Project ID"
  value       = ncloud_sourcebuild_project.this.id
}

output "sourcebuild_project_no" {
  description = "SourceBuild Project ID (alias)"
  value       = ncloud_sourcebuild_project.this.project_no
}
