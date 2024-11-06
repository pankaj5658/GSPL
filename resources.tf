
## Resource Groups
resource "azurerm_resource_group" "rg1" {
  name     = "rg-gspl-prod-sea-01"
  location = "Southeast Asia"
}

resource "azurerm_resource_group" "rg2" {
  name     = "rg-gspl-hub-sea-01"
  location = "Southeast Asia"
}

resource "azurerm_resource_group" "rg3" {
  name     = "rg-gspl-identity-sea-01"
  location = "Southeast Asia"
}

## Virtual Networks
resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet-gspl-identity-prod-sea-01"
  location            = azurerm_resource_group.rg3.location
  resource_group_name = azurerm_resource_group.rg3.name
  address_space       = ["10.50.0.0/22"]
  depends_on = [
    azurerm_resource_group.rg3
  ]

}
resource "azurerm_virtual_network" "vnet2" {
  name                = "vnet-gspl-fileshare-prod-sea-01"
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name
  address_space       = ["10.54.0.0/22"]
  depends_on = [
    azurerm_resource_group.rg2
  ]

}

## subnets

resource "azurerm_subnet" "subnet1" {
  name                 = "identity-subnet"
  resource_group_name  = azurerm_resource_group.rg3.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.50.0.0/24"]
  depends_on = [
    azurerm_resource_group.rg3,
    azurerm_virtual_network.vnet1
  ]

}

#Network Interfaces
resource "azurerm_network_interface" "nic1" {
  name                = "dc-prod-nic1"
  location            = azurerm_resource_group.rg3.location
  resource_group_name = azurerm_resource_group.rg3.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [
    azurerm_resource_group.rg3,
    azurerm_virtual_network.vnet1,
    azurerm_subnet.subnet1
  ]
}

resource "azurerm_network_interface" "nic2" {
  name                = "adc-prod-nic1"
  location            = azurerm_resource_group.rg3.location
  resource_group_name = azurerm_resource_group.rg3.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"

  }
  depends_on = [
    azurerm_resource_group.rg3,
    azurerm_virtual_network.vnet1,
    azurerm_subnet.subnet1
  ]


}


## virtual Machines

resource "azurerm_windows_virtual_machine" "vm1" {
  name                = "vm-gspl-dc-prod-sea-01"
  resource_group_name = azurerm_resource_group.rg3.name
  location            = azurerm_resource_group.rg3.location
  size                = "Standard_D4s_v3"
  admin_username      = "gspladmin"
  admin_password      = "Welcome@123"
  network_interface_ids = [
    azurerm_network_interface.nic1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
  depends_on = [
    azurerm_resource_group.rg3,
    azurerm_virtual_network.vnet1,
    azurerm_subnet.subnet1
  ]
}


resource "azurerm_windows_virtual_machine" "vm2" {
  name                = "vm-gspl-dc-prod-sea-02"
  resource_group_name = azurerm_resource_group.rg3.name
  location            = azurerm_resource_group.rg3.location
  size                = "Standard_D4s_v3"
  admin_username      = "gspladmin"
  admin_password      = "Welcome@123"
  network_interface_ids = [
    azurerm_network_interface.nic1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
  depends_on = [
    azurerm_resource_group.rg3,
    azurerm_virtual_network.vnet1,
    azurerm_subnet.subnet1
  ]

}

## Storage account


resource "azurerm_storage_account" "storageacct1" {
  name                     = "gsplprodstorage01"
  resource_group_name      = azurerm_resource_group.rg2.name
  location                 = azurerm_resource_group.rg2.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  depends_on = [
    azurerm_resource_group.rg2

  ]

}



resource "azurerm_storage_share" "fileshare1" {
  name                 = "fileshare-gspl-prod-sea-01"
  storage_account_name = azurerm_storage_account.storageacct1.name
  quota                = 50
}
