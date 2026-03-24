# -----------------------------------------------------
# IAM Role
# Un Role c'est une identité AWS qu'on attache à une EC2
# Ca permet à l'EC2 d'appeler des services AWS (SSM, S3...)
# sans avoir besoin de stocker des credentials sur la VM
# -----------------------------------------------------
resource "aws_iam_role" "k3s" {
  name = "${var.project_name}-k3s-role"

  # assume_role_policy = "qui a le droit d'utiliser ce role ?"
  # Ici on dit : les EC2 (ec2.amazonaws.com) peuvent l'utiliser
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name        = "${var.project_name}-k3s-role"
    Environment = var.environment
  }
}

# On attache la politique SSM au role
# AmazonSSMFullAccess = lire ET écrire dans SSM Parameter Store
resource "aws_iam_role_policy_attachment" "k3s_ssm" {
  role       = aws_iam_role.k3s.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

# Instance Profile = le "conteneur" qui permet d'attacher un IAM Role à une EC2
resource "aws_iam_instance_profile" "k3s" {
  name = "${var.project_name}-k3s-profile"
  role = aws_iam_role.k3s.name
}
