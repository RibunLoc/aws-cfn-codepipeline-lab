# NT548 - Lab 2: CI/CD với AWS CodePipeline, CodeBuild và CloudFormation

## Yêu cầu môi trường

- Tài khoản AWS đã được kích hoạt đầy đủ
- AWS CLI (đã cấu hình `aws configure`)
- Python 3.8+
- Git
- Quyền sử dụng các dịch vụ:
  - CodeCommit (nếu dùng)
  - CodePipeline, CodeBuild
  - CloudFormation
  - S3 (cho Taskcat)
  - IAM (tạo role)
---

## Cấu trúc thư mục

```bash
.
project/
├── modules/
│   ├── vpc.yaml                # Module VPC và subnet
│   ├── route-table.yaml        # Module Route Tables
│   ├── nat.yaml                # Module NAT Gateway
│   ├── security_groups.yaml    # Module Security Groups
│   ├── ec2.yaml                # Module EC2 Instances
|   ├── main.yaml               # Template chính để nối các module
├── tests/
│   └── test_templates.py       # Script kiểm tra template
├── scripts/
│   ├── deploy.sh               # Script triển khai
│   └── cleanup.sh              # Script dọn dẹp tài nguyên
├── buildspec.yml               # Script cho CodeBuild
├── .taskcat.yml                # Định nghĩa test cho taskcat
└── README.md                   # Hướng dẫn sử dụng
```

## Cách triển khai qua AWS CodePipeline
 1. Tạo CodeBuild project
- Sử dụng file buildspec.yml
- Gán IAM role có quyền S3 + CloudFormation
 2. Tạo CodePipeline
 - Source: GitHub
 - Build: CodeBuild project nt548-lab2-build
 - Deploy: CloudFormation

##  Kiểm tra kết quả triển khai

1. Trạng thái pipeline
- Vào AWS Console → CodePipeline → nt548-lab2-pipeline
- Kiểm tra trạng thái từng stage (Source, Build, Deploy)

2. Kiểm tra CloudFormation stack
- AWS Console → CloudFormation → Stack nt548-lab2-stack
- Kiểm tra Outputs, Events, Resources
