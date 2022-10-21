output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "nginx_public_ip_address" {
  value = azurerm_linux_virtual_machine.nginx.public_ip_address
}

output "nginx_address" {
  value = azurerm_linux_virtual_machine.nginx.private_ip_address
}

output "openssh_private_key" {
  value     = tls_private_key.nginx_ssh.private_key_pem
  sensitive = true
}
