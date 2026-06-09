output "alb_dns_name" {
  description = "ALB DNS name — use this to access your app"
  value       = module.alb.alb_dns_name
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = module.rds.rds_endpoint
}