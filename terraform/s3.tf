# 🔥 Criando um Bucket S3 para armazenar artefatos do CodePipeline
resource "aws_s3_bucket" "artifact_bucket" {
  bucket = var.s3_bucket_name
  force_destroy = true  # Permite destruir o bucket automaticamente
}

# 🔥 Criando permissões para CodePipeline acessar o S3
resource "aws_iam_policy" "codepipeline_s3_policy" {
  name        = "CodePipelineS3Policy"
  description = "Permite ao CodePipeline acessar o bucket de artefatos"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::bucket-devsecops-camila",
          "arn:aws:s3:::bucket-devsecops-camila/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "codepipeline_s3_policy_attach" {
  name       = "codepipeline-s3-policy-attachment"
  roles      = [aws_iam_role.codepipeline_role.name]
  policy_arn = aws_iam_policy.codepipeline_s3_policy.arn
}