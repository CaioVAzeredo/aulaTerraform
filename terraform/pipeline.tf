# 🔥 Criando Roles para o Pipeline
resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "codepipeline.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

# 🔥 Anexar a política AWSCodePipeline_FullAccess ao codepipeline_role
resource "aws_iam_policy_attachment" "codepipeline_policy" {
  name       = "codepipeline-policy"
  roles      = [aws_iam_role.codepipeline_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
}

# 🔥 Adicionar uma política personalizada para permitir acesso ao bucket S3
resource "aws_iam_policy" "codepipeline_s3_access" {
  name        = "CodePipelineS3AccessPolicy"
  description = "Permite ao CodePipeline acessar o bucket S3"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

# 🔥 Anexar a política personalizada ao codepipeline_role
resource "aws_iam_policy_attachment" "codepipeline_s3_access_attach" {
  name       = "codepipeline-s3-access-policy-attachment"
  roles      = [aws_iam_role.codepipeline_role.name]
  policy_arn = aws_iam_policy.codepipeline_s3_access.arn
}

# 🔥 Criar o IAM Role para o CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "codebuild.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

# 🔥 Anexar a política AdministratorAccess ao codebuild_role
resource "aws_iam_policy_attachment" "codebuild_policy" {
  name       = "codebuild-policy"
  roles      = [aws_iam_role.codebuild_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# 🔥 Permitir ao CodePipeline rodar builds no CodeBuild
resource "aws_iam_policy" "codepipeline_codebuild_policy" {
  name        = "CodePipelineCodeBuildPolicy"
  description = "Permite ao CodePipeline iniciar builds no CodeBuild"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
          "codebuild:StopBuild",
          "codebuild:GetBuild"
        ],
        Resource = aws_codebuild_project.trivy_scan.arn
      }
    ]
  })
}

# 🔥 Anexar a política ao codepipeline_role
resource "aws_iam_policy_attachment" "codepipeline_codebuild_policy_attach" {
  name       = "codepipeline-codebuild-policy-attachment"
  roles      = [aws_iam_role.codepipeline_role.name]
  policy_arn = aws_iam_policy.codepipeline_codebuild_policy.arn
}

# 🔥 Criando um CodeBuild para rodar Trivy
resource "aws_codebuild_project" "trivy_scan" {
  name          = var.build_project_name
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = "30"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "TRIVY_IMAGE"
      value = "alpine:latest"
    }
    environment_variable {
      name  = "SSH_PRIVATE_KEY"
      value = var.key_pair_ssh
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/CaioVAzeredo/aulaTerraform.git"
    git_clone_depth = 1
  }
}

# 🔥 Criando CodePipeline e garantindo que a EC2 exista antes do deploy
resource "aws_codepipeline" "my_pipeline" {
  name     = var.pipeline_name 
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = var.s3_bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name     = "GitHub_Source"
      category = "Source"
      owner    = "ThirdParty"
      provider = "GitHub"
      version  = "1"
      output_artifacts = ["source_output"]
      configuration = {
        Owner      = "CaioVAzeredo"
        Repo       = "aulaTerraform"
        Branch     = "main"
        OAuthToken = var.github_token
      }
    }
  }

  stage {
    name = "Security_Scan"

    action {
      name     = "Trivy_Scan"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"
      input_artifacts = ["source_output"]
      configuration = {
        ProjectName = aws_codebuild_project.trivy_scan.name
      }
    }
  }

  depends_on = [aws_instance.devsecops_instance]  # 🔥 Garante que a EC2 já foi criada
}