# Bucket S3 pour stocker le state
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  # Empêche la suppression accidentelle du bucket
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "${var.project_name}-terraform-state"
    Environment = var.environment
  }
}

# Activer le versioning sur le bucket
# → permet de revenir à un ancien state si besoin
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Bloquer tout accès public au bucket
# → le state contient des secrets, personne ne doit y accéder publiquement
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Chiffrement du bucket
# → les données sont chiffrées au repos sur S3
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Table DynamoDB pour le locking
# → évite que 2 personnes fassent un apply en même temps
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "${var.project_name}-terraform-lock"
  billing_mode = "PAY_PER_REQUEST" # pas de coût fixe, on paie par requête
  hash_key     = "LockID"          # clé requise par Terraform

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "${var.project_name}-terraform-lock"
    Environment = var.environment
  }
}