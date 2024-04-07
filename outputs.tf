output "connect_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_connect_instance.main_contact_center.id
}

output "connect_instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_connect_instance.main_contact_center.arn
}

output "connect_instance_status" {
  description = "Status of the EC2 instance"
  value       = aws_connect_instance.main_contact_center.status
}

output "connect_instance_service_role" {
  description = "Service Role of the EC2 instance"
  value       = aws_connect_instance.main_contact_center.service_role
}