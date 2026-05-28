output "alb_dns_endpoint" {
  value       = aws_lb.main.dns_name
  description = "URL publica del Balanceador para verificar con el profesor"
}