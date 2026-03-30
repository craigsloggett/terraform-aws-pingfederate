output "pingfederate_admin_url" {
  description = "URL of the PingFederate admin console."
  value       = "https://${local.pingfederate_fqdn}:9999/pingfederate/app"
}

output "pingfederate_runtime_url" {
  description = "URL of the PingFederate runtime engine."
  value       = "https://${local.pingfederate_fqdn}:9031"
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host."
  value       = aws_instance.bastion.public_ip
}

output "pingfederate_private_ip" {
  description = "Private IP of the PingFederate instance."
  value       = aws_instance.pingfederate.private_ip
}

output "pingfederate_instance_id" {
  description = "Instance ID of the PingFederate instance."
  value       = aws_instance.pingfederate.id
}

output "ec2_ami_name" {
  description = "Name of the AMI used for EC2 instances."
  value       = var.ec2_ami.name
}
