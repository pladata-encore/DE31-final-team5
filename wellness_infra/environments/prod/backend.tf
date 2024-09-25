terraform {
  backend "s3" {
    bucket         = "prod-wellness-terraform-state" # 환경에 맞는 S3 버킷 이름
    key            = "state/terraform.tfstate"       # 상태 파일 경로
    region         = "ap-northeast-2"                # S3 버킷이 생성된 리전
    dynamodb_table = "prod-terraform-lock"           # DynamoDB 테이블 이름
    encrypt        = true                            # 상태 파일 암호화
  }
}
