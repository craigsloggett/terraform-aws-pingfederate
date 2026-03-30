output "pingfederate_admin_url" {
  description = "URL of the PingFederate admin console."
  value       = module.pingfederate.pingfederate_admin_url
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host."
  value       = module.pingfederate.bastion_public_ip
}

output "pingfederate_private_ip" {
  description = "Private IP of the PingFederate instance."
  value       = module.pingfederate.pingfederate_private_ip
}
