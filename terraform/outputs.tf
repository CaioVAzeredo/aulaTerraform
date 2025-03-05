# 🔥 Captura o IP público da EC2 para ser utilizado no buildspec.yml
output "ec2_instance_ip" {
  value       = aws_instance.devsecops_instance.public_ip
  description = "Endereço IP público da instância EC2"
}

# 🔥 Mostra o nome do bucket S3
output "s3_bucket_name" {
  value       = aws_s3_bucket.artifact_bucket.id
  description = "Nome do bucket S3 usado no pipeline"
}

# 🔥 Mostra o nome do pipeline criado
output "pipeline_name" {
  value       = aws_codepipeline.my_pipeline.name
  description = "Nome do pipeline do CodePipeline"
}
