output "Network_Load_Balancer_DNS_Name" {
  description = "Update the Fyde Access Proxy in the Console with this DNS name"
  value       = aws_lb.nlb.dns_name
}

output "Security_Group_for_Resources" {
  description = "Use this group to allow Fyde Access Proxy access to internal resources"
  value       = aws_security_group.resources.id
}
