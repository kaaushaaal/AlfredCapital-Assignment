provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  resource_provider_registrations = "all"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "nomad-demo-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnets
resource "azurerm_subnet" "public" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "private" {
  name                 = "private-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "nomad-demo-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow_ssh_from_ip"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = var.allowed_ip
    destination_port_range     = "22"
    source_port_range          = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_nomad_internal"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "VirtualNetwork"
    destination_port_range     = "4646-4648"
    source_port_range          = "*"
    destination_address_prefix = "*"
  }
}

# NSG association to public subnet
resource "azurerm_subnet_network_security_group_association" "public_assoc" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Public IP for Nomad server
resource "azurerm_public_ip" "server_pip" {
  name                = "nomad-server-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Network Interface for Nomad server
resource "azurerm_network_interface" "server_nic" {
  name                = "nomad-server-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.server_pip.id
  }
}


resource "azurerm_linux_virtual_machine" "nomad_server" {
  name                = "nomad-server-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "kaushalazure"
  network_interface_ids = [
    azurerm_network_interface.server_nic.id
  ]
  disable_password_authentication = true
  provision_vm_agent             = true
  custom_data                    = filebase64("cloud-init-server.yaml")

  admin_ssh_key {
    username   = "kaushalazure"
    public_key = file("C:/Users/kaush/azure.pub")
  }

  os_disk {
    name                 = "nomad-server-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "22.04.202510020"
  }
  tags = {
    Role = "server"
    Environment = "nomad-demo"
  }
}
resource "azurerm_linux_virtual_machine_scale_set" "client_vmss" {
  name                = "nomad-client-vmss"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard_B1s"
  instances            = 2
  admin_username      = "kaushalazure"
  disable_password_authentication = true
  single_placement_group = true
  overprovision        = true
  upgrade_mode         = "Manual"
  provision_vm_agent   = true
  custom_data          = filebase64("cloud-init-client.yaml")

  admin_ssh_key {
    username   = "kaushalazure"
    public_key = file("C:/Users/kaush/azure.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "22.04.202510020"
  }

  network_interface {
    name    = "client-vmss-nic"
    primary = true

    ip_configuration {
      name    = "client-ipcfg"
      subnet_id = azurerm_subnet.private.id
      primary = true
      version = "IPv4"
    }
  }
  identity {
    type = "SystemAssigned"
  }
}
# Bastion Public IP
resource "azurerm_public_ip" "bastion_pip" {
  name                = "nomad-bastion-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Azure Bastion Host
resource "azurerm_bastion_host" "bastion" {
  name                = "nomad-bastion"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_name            = "nomad-bastion"

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.public.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}
