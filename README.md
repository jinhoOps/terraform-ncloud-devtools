# terraform-ncloud-devtools

Naver Cloud Platform(NCP) DevTools( SourceCommit / SourceBuild / SourceDeploy )를 Terraform으로 프로비저닝하기 위한 스켈레톤 레포입니다.  
멀티 환경(dev/prod) 디렉터리, S3 호환(Object Storage) 원격 상태 관리, 모듈 구조를 기본 제공합니다.

> ⚠️ 주의: `ncloud_sourcebuild_project` 리소스는 작성중으로 내용이 변경될 수 있습니다.

---

## 디렉터리 구조


```
terraform-ncloud-devtools/
├─ envs/
│  ├─ dev/
│  │  ├─ backend.tf          # 원격 상태 backend (s3 호환: NCP Object Storage)
│  │  ├─ providers.tf
│  │  ├─ versions.tf
│  │  ├─ main.tf             # 모듈 호출 예시 (dev)
│  │  └─ terraform.tfvars    # dev 변수값
│  └─ prod/ ...              # 동일한 패턴
├─ examples/
│  └─ terraform.tfvars.example
├─ modules/
│  ├─ sourcecommit-repo/
│  │  ├─ main.tf
│  │  └─ variables.tf
│  ├─ sourcebuild-project/
│  │  ├─ main.tf
│  │  └─ variables.tf
│  ├─ sourcedeploy-project/
│  │  ├─ main.tf
│  │  └─ variables.tf
│  └─ sourcedeploy-scenario/   # 시나리오 스켈레톤(placeholder)
│     ├─ main.tf
│     └─ variables.tf
└─ README.md
```


## ✅ 요구사항

- Terraform **>= 1.5.0**
- Provider: **NaverCloudPlatform/ncloud >= 4.0.0**
- NCP API 인증키(Access Key / Secret Key)
- (권장) 원격 상태용 NCP Object Storage 버킷


## 🚀 빠른 시작

```bash
# 1) 리포지토리 클론
git clone <YOUR_REPO_URL>
cd terraform-ncloud-devtools

# 2) 환경 폴더로 이동
cd envs/dev
````

### 원격 상태(Backend) 설정

Object Storage는 **S3 호환** endpoint를 사용합니다. `envs/dev/backend.tf` 예시(Partial config → 실제 값은 init 시 `-backend-config=`로 주입 권장):

```hcl
terraform {
  backend "s3" {
    # ↓ 실제 값은 init 시 -backend-config 로 안전하게 주입
    # bucket   = ""
    # key      = ""
    # region   = "kr-standard"
    # endpoint = "https://kr.object.ncloudstorage.com"

    skip_credentials_validation = true
    skip_region_validation      = true
    force_path_style            = true
  }
}
```

권장 init(민감정보 미노출):

```bash
# 자격증명 환경변수로 주입
export AWS_ACCESS_KEY_ID="<NCP_ACCESS_KEY>"
export AWS_SECRET_ACCESS_KEY="<NCP_SECRET_KEY>"
# (Windows PowerShell)
# $env:AWS_ACCESS_KEY_ID     = "<NCP_ACCESS_KEY>" #버킷
# $env:AWS_SECRET_ACCESS_KEY = "<NCP_SECRET_KEY>" #버킷
# $env:TF_VAR_access_key="<NCP_ACCESS_KEY>"
# $env:TF_VAR_secret_key="<NCP_SECRET_KEY>"
# $env:TF_VAR_tfstate_bucket = "<ncp_bucket>"

terraform init \
  -backend-config="bucket=<YOUR_BUCKET>" \
  -backend-config="key=states/dev/terraform.tfstate" \
  -backend-config="region=kr-standard" \
  -backend-config="endpoint=https://kr.object.ncloudstorage.com"
```

> 금융/공공 존은 endpoint가 다릅니다.
> 금융: `https://kr.object.fin-ncloudstorage.com` / 공공: `https://kr.object.gov-ncloudstorage.com`

---

## Provider 설정 (예시)

`envs/dev/providers.tf`:

```hcl
provider "ncloud" {
  support_vpc = true
  site        = "public" # SourceBuild Project는 public 전용
  region      = "KR"
  # 자격증명은 환경변수 사용 권장(NCP_ACCESS_KEY/NCP_SECRET_KEY 또는 AWS_* 변수)
}
```

`envs/dev/versions.tf`:

```hcl
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    ncloud = {
      source  = "NaverCloudPlatform/ncloud"
      version = ">= 4.0.0"
    }
  }
}
```

---

## 모듈 호출 예시(최소)

`envs/dev/main.tf`:

```hcl
module "sourcecommit_repo" {
  source = "../../modules/sourcecommit-repo"
  name   = var.repo_name
}

module "sourcebuild_project" {
  source        = "../../modules/sourcebuild-project"
  name          = var.sb_project_name
  description   = "dev build project"

  # Source (SourceCommit)
  repository_name = module.sourcecommit_repo.repository_name
  branch          = var.sb_branch

  # Env/Platform (빠른 테스트용으로 ID 직접 입력; 실무는 data 소스 권장)
  compute_id          = var.sb_compute_id
  platform_type       = "SourceBuild"
  os_id               = var.sb_os_id
  runtime_id          = var.sb_runtime_id
  runtime_version_id  = var.sb_runtime_version_id

  timeout              = 60
  docker_use           = false
  env_vars             = []
  enable_build_command = false
}
```

`examples/terraform.tfvars.example`:

```hcl
# SourceCommit
repo_name = "devtools-repo"

# SourceBuild
sb_project_name       = "devtools-sbproj-dev"
sb_branch             = "main"

# 임시 ID (data 소스로 조회하여 대체 권장)
sb_compute_id         = 1
sb_os_id              = 1
sb_runtime_id         = 1
sb_runtime_version_id = 1
```

> 실제 값은 `envs/dev/terraform.tfvars` 로 복사 후 수정하세요.
> **민감정보는 tfvars에 넣지 말고 환경변수로 주입**하시길 권장합니다.

---

## 명령어

```bash
# 형식/유효성
terraform fmt -recursive
terraform validate

# 계획/적용
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

---

## 베스트 프랙티스

* `*.tfvars`는 커밋하지 말고 **`*.tfvars.example`만** 커밋
* `.terraform.lock.hcl` **커밋 권장**(팀 간 프로바이더 버전 고정)
* 모듈 변경 시 **환경별 폴더에서 개별 plan/apply**(dev → prod 순)
* 금융/공공 존 사용 시 **endpoint/권한/서비스 지원 범위** 사전 확인

```

원하시면 같은 톤으로 `envs/prod` 템플릿도 만들어 드리겠습니다.
::contentReference[oaicite:0]{index=0}
```

