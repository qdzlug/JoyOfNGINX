output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "nginxlb_public_ip_address" {
  value = azurerm_linux_virtual_machine.nginx_lb.public_ip_address
}

output "nginxlb_address" {
  value = azurerm_linux_virtual_machine.nginx_lb.private_ip_address
}

output "nginx01_address"  {
  value = azurerm_linux_virtual_machine.upstream_nginx01.private_ip_address
}

output "nginx02_address"  {
  value = azurerm_linux_virtual_machine.upstream_nginx02.private_ip_address
}

output "nginx03_address"  {
  value = azurerm_linux_virtual_machine.upstream_nginx03.private_ip_address
}

output "openssh_private_key" {
  value     = tls_private_key.nginx_ssh.private_key_pem
  sensitive = true
}
