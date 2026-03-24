variable "aws_region" {
  description = "La région AWS à utiliser"
  type        = string
  default     = "eu-west-3"
}

variable "project_name" {
  description = "Nom du projet (utilisé pour nommer les ressources)"
  type        = string
  default     = "devops-learning"
}

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "key_pair_name" {
  description = "Nom de la Key Pair AWS pour se connecter en SSH"
  type        = string
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t3.small"
}

variable "state_bucket_name" {
  description = "Nom unique du bucket S3 pour le state Terraform"
  type        = string
  default     = "devops-learning-tfstate-2026"
}