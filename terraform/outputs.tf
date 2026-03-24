output "k3s_master_public_ip" {
  description = "IP publique du master K3s"
  value       = aws_instance.k3s_master.public_ip
}

output "k3s_worker_public_ip" {
  description = "IP publique du worker K3s"
  value       = aws_instance.k3s_worker.public_ip
}

output "vpc_id" {
  description = "ID du VPC"
  value       = aws_vpc.main.id
}