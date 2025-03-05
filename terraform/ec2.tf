# 🔥 Criando um Security Group para permitir acesso SSH e tráfego necessário


resource "aws_security_group" "ec2_sg" {
  name        = "devsecops-sg"
  description = "Security Group para DevSecOps EC2"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permite acesso SSH de qualquer lugar (alterar para maior segurança)
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permite acesso HTTP caso necessário
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 🔥 Criando a EC2 com Docker e Docker Compose
resource "aws_instance" "devsecops_instance" {
  ami                    = var.ec2_ami
  instance_type          = var.ec2_instance_type
  key_name               = var.key_pair
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker amazon-ssm-agent
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo systemctl enable amazon-ssm-agent
              sudo systemctl start amazon-ssm-agent
              sudo usermod -aG docker ec2-user
              curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              EOF

  tags = {
    Name = "DevSecOps-EC2"
  }
}

# 🔥 Criando um parâmetro no AWS Systems Manager com o IP da EC2
resource "aws_ssm_parameter" "ec2_instance_ip" {
  name  = "/devsecops/ec2_instance_ip"
  type  = "String"
  value = aws_instance.devsecops_instance.public_ip
}

