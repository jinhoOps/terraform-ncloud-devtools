# 현재 공개 스키마에서 시나리오 리소스가 분리되어 있지 않거나(또는 명칭/스키마 변동)
# 추후 확장 가능성을 고려해 placeholder로 구성합니다.
# 여기서는 선언적 의도를 보존하기 위해 terraform_data를 사용해
# 시나리오 정의를 상태에 저장하고, 필요 시 외부 연동(로컬/파이프라인)에서 활용합니다.

resource "terraform_data" "scenario" {
  input = {
    project_no    = var.project_no
    scenario_name = var.scenario_name
    steps         = var.steps
  }
}

output "scenario_def" {
  value = terraform_data.scenario.output
}
