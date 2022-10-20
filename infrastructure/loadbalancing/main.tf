# Resource group
resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

# General Networking
resource "azurerm_virtual_network" "nginx_network" {
  name                = "nginxVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "nginx_subnet" {
  name                 = "nginxSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.nginx_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Storage account
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }

  byte_length = 8
}

resource "azurerm_storage_account" "nginx_storage_account" {
  name                     = "diag${random_id.random_id.hex}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# SSH key for access
resource "tls_private_key" "nginx_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

## Loadbalancer Specific Code
resource "azurerm_public_ip" "nginx_public_ip" {
  name                = "nginxPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "nginx_nsg" {
  name                = "nginxNetworkSecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nginxlb_nic" {
  name                = "nginxNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "nginxlb_nic_configuration"
    subnet_id                     = azurerm_subnet.nginx_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.nginx_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nginxlb" {
  network_interface_id      = azurerm_network_interface.nginxlb_nic.id
  network_security_group_id = azurerm_network_security_group.nginx_nsg.id
}

resource "azurerm_linux_virtual_machine" "nginx_vm" {
  name                  = "nginxVM"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nginxlb_nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "nginxOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "nginxvm"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.nginx_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.nginx_storage_account.primary_blob_endpoint
  }
}

# NGINX Upstream nodes
resource "azurerm_network_interface" "upstream_nginx01" {
   name                = "nginxPrivate01"
   location            = azurerm_resource_group.rg.location
   resource_group_name = azurerm_resource_group.rg.name

   ip_configuration {
     name                          = "privateConfiguration"
     subnet_id                     = azurerm_subnet.nginx_subnet.id
     private_ip_address_allocation = "dynamic"
   }
 }

resource "azurerm_network_interface" "upstream_nginx02" {
  name                = "nginxPrivate02"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "privateConfiguration"
    subnet_id                     = azurerm_subnet.nginx_subnet.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_network_interface" "upstream_nginx03" {
  name                = "nginxPrivate03"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "privateConfiguration"
    subnet_id                     = azurerm_subnet.nginx_subnet.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "upstream_nginx01" {
  name                  = "upstream-nginx01"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.upstream_nginx01.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "upstreamOsDisk-01"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "nginx01"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.nginx_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.nginx_storage_account.primary_blob_endpoint
  }
}

resource "azurerm_linux_virtual_machine" "upstream_nginx02" {
  name                  = "upstream-nginx02"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.upstream_nginx02.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "upstreamOsDisk-02"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "nginx02"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.nginx_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.nginx_storage_account.primary_blob_endpoint
  }
}

resource "azurerm_linux_virtual_machine" "upstream_nginx03" {
  name                  = "upstream-nginx03"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.upstream_nginx03.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "upstreamOsDisk-03"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "nginx03"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.nginx_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.nginx_storage_account.primary_blob_endpoint
  }
}
