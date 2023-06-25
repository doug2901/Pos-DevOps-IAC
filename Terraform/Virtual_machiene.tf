# Create Network
resource "azurerm_virtual_network" "Pos_Unyleya" {
  name                = "Pos_Unyleya"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.RG-VM.location
  resource_group_name = azurerm_resource_group.RG-VM.name
}
# Create Subnet
resource "azurerm_subnet" "Pos_Unyleya" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.RG-VM.name
  virtual_network_name = azurerm_virtual_network.Pos_Unyleya.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "Pos_Unyleya" {
  name                = "Pos_Unyleya"
  location            = azurerm_resource_group.RG-VM.location
  resource_group_name = azurerm_resource_group.RG-VM.name
  allocation_method   = "Dynamic"
}
# Create NIC for VM
resource "azurerm_network_interface" "Pos_Unyleya" {
  name                = "Pos_Unyleya"
  location            = azurerm_resource_group.RG-VM.location
  resource_group_name = azurerm_resource_group.RG-VM.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Pos_Unyleya.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.Pos_Unyleya.id
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "Pos_Unyleya" {
  name                = "Pos_Unyleya"
  location            = azurerm_resource_group.RG-VM.location
  resource_group_name = azurerm_resource_group.RG-VM.name

  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Ansible_WinRM_HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Ansible_WinRM_HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
security_rule {
    name                       = "HTTP"
    priority                   = 1004
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
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create VM
resource "azurerm_windows_virtual_machine" "Pos_Unyleya" {
  name                = "PosUnyleya"
  resource_group_name = azurerm_resource_group.RG-VM.name
  location            = azurerm_resource_group.RG-VM.location
  size                = "Standard_F2"
  admin_username      = "ansible"
  admin_password      = "Pa55w.rd"
  network_interface_ids = [
    azurerm_network_interface.Pos_Unyleya.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}