output "final_app_url" {
  value       = aws_lb.external.dns_name
  description = "URL publica final para acceder a la aplicacion web balanceada a traves del ALB"
}

output "allocated_bucket_name" {
  value       = module.storage.bucket_name
  description = "Nombre del bucket S3 aprovisionado de forma segura"
}