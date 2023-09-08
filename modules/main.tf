terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.68.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}

data "azurerm_resource_group" "RAGHUVEER-RG" {
  name     = "RAGHUVEER-RG"
  
}

resource "azurerm_virtual_network" "RGHVNET" {
  name                = "RGHVNET"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.RAGHUVEER-RG.location
  resource_group_name = data.azurerm_resource_group.RAGHUVEER-RG.name
}

resource "azurerm_subnet" "RGHSN1" {
  name                 = "RGHSN1"
  resource_group_name  = data.azurerm_resource_group.RAGHUVEER-RG.name
  virtual_network_name = azurerm_virtual_network.RGHVNET.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "RGH-nic" {
  name                = "RGH-nic"
  location            = data.azurerm_resource_group.RAGHUVEER-RG.location
  resource_group_name = data.azurerm_resource_group.RAGHUVEER-RG.name

  ip_configuration {
    name                          = "RGH-config"
    subnet_id                     = azurerm_subnet.RGHSN1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "RGtest"{
  name                  = "RGtest"
  location              = data.azurerm_resource_group.RAGHUVEER-RG.location
  resource_group_name   = data.azurerm_resource_group.RAGHUVEER-RG.name
  network_interface_ids = [azurerm_network_interface.RGH-nic.id]
  vm_size               = "standard_b2ms"

  storage_os_disk {
    name              = "RGH-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "RAGvm"
    admin_username = "adminuser"
    admin_password = "Password12345!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}




