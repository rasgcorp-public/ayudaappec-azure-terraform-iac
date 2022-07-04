terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.12.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "terraform-backend-rg"
    storage_account_name = "azurebackendterraform"
    container_name       = "tfstate-ayudaappec"
    key                  = "terraform.tfstate"
  }
}
provider "azurerm" {
  features {
  }
}

resource "azurerm_resource_group" "ayudaappec_rg" {
  name     = "ayudaappec-rg"
  location = "eastus"
}

resource "azurerm_cosmosdb_account" "cosmosdb_acc" {
  name                = "ayudaappec-cosmosdb"
  location            = azurerm_resource_group.ayudaappec_rg.location
  resource_group_name = azurerm_resource_group.ayudaappec_rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  enable_automatic_failover = false

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level = "BoundedStaleness"
  }

  geo_location {
    location          = azurerm_resource_group.ayudaappec_rg.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "cosmosdb_db" {
  name                = "ayudaappec-catalog-db"
  resource_group_name = azurerm_resource_group.ayudaappec_rg.name
  account_name        = azurerm_cosmosdb_account.cosmosdb_acc.name
}

resource "azurerm_cosmosdb_sql_container" "cosmosdb_container" {
  name                  = "services-container"
  resource_group_name   = azurerm_resource_group.ayudaappec_rg.name
  account_name          = azurerm_cosmosdb_account.cosmosdb_acc.name
  database_name         = azurerm_cosmosdb_sql_database.cosmosdb_db.name
  partition_key_path    = "/id"
  partition_key_version = 1
}

