module "naming" {
  source  = "codectl/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
}

module "regions" {
  source  = "codectl/locations/azure"
  version = "~> 1.0"

  location = {
    primary = "westeurope"
  }
}

module "rg" {
  source  = "codectl/rg/azure"
  version = "~> 1.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = module.regions.location.primary.name
    }
  }
}

module "storage" {
  source  = "codectl/sa/azure"
  version = "~> 1.0"

  storage = {
    name                = module.naming.storage_account.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }
}


module "mag" {
  source  = "codectl/mag/azure"
  version = "~> 1.0"

  groups = {
    demo = {
      name                = "mag-demo-dev-email"
      resource_group_name = module.rg.groups.demo.name
      location            = "global"
      short_name          = "mag-email"

      email_receiver = {
        email1 = {
          name          = "send to demo"
          email_address = "email@demo-mag-email.nl"
        }
      }
    }
  }
}

module "alerts" {
  source  = "codectl/alerts/azure"
  version = "~> 1.0"

  alerts = {
    resource_group_name = module.rg.groups.demo.name
    location            = module.rg.groups.demo.location

    activity_log_alerts = {
      ala1 = {
        name   = "blabla1"
        scopes = [module.rg.groups.demo.id]

        criteria = {
          resource_id    = module.storage.account.id
          operation_name = "Microsoft.Storage/storageAccounts/write"
          category       = "Recommendation"
        }

        actions = {
          demo = {
            action_group_id = module.mag.groups.demo.id

            webhook_properties = {
              from = "terraform"
            }
          }
        }
      }
    }
  }
}
