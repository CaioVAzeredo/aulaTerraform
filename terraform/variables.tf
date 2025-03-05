variable "aws_region" {
  description = "Região da AWS onde os recursos serão criados"
  default     = "us-east-1"
}

variable "pipeline_name" {
  description = "Nome do CodePipeline"
  type        = string
  default     = "devsecops-pipeline-camila"
}

variable "ec2_instance_type" {
  description = "Tipo da instância EC2"
  default     = "t2.micro"
}

variable "ec2_ami" {
  description = "AMI da instância EC2"
  default     = "ami-05b10e08d247fb927"
}

variable "key_pair" {
  description = "Nome do par de chaves SSH para a EC2"
  default     = "terraform-key-pair" //Substitua por sua chave SSH
}
variable "key_pair_ssh" {
  description = "Nome do par de chaves SSH para a EC2"
  default     = "terraform-key-pair.pem" //Substitua por sua chave SSH
}

variable "s3_bucket_name" {
  description = "Nome do bucket S3 para armazenar os artefatos do CodePipeline"
  default     = "coloque-aqui-o-nome-do-seu-bucket-S3" //Substitua por seu bucket S3
}

variable "github_owner" {
  description = "Dono do repositório GitHub"
  default     = "coloque-aqui-seu-usuario-github" //Substitua por seu usuario github
}

variable "github_repo" {
  description = "Nome do repositório no GitHub"
  default     = "coloque-aqui-o-nome-do-seu-github" //Substitua por seu repositorio no GitHub
}

variable "github_branch" {
  description = "Branch do repositório GitHub"
  default     = "main"
}

variable "github_token" {
  description = "Token de acesso ao GitHub para o CodePipeline"
  type        = string
  sensitive   = true
}

variable "docker_username" {
  description = "Nome de usuário do Docker Hub"
  type        = string
}

variable "docker_password" {
  description = "Senha do Docker Hub"
  type        = string
  sensitive   = true
}

variable "build_project_name"{
  description = "Nome do projeto no codebuild"
  type = string
  default = "trivy-security-scanner"
}
