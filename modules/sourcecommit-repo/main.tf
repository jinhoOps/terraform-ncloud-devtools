resource "ncloud_sourcecommit_repository" "this" {
  name        = var.name
  description = var.description
}

output "repository_no" {
  # 일반적으로 번호/ID 속성이 제공됩니다. 실제 속성명은 리소스 스키마에 맞춰 조정하세요.
  value = ncloud_sourcecommit_repository.this.id
}
