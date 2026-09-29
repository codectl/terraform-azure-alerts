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

module "analytics" {
  source  = "codectl/law/azure"
  version = "~> 1.0"

  workspace = {
    name                = module.naming.log_analytics_workspace.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }
}

module "alerts" {
  source  = "codectl/alerts/azure"
  version = "~> 1.0"

  alerts = {
    resource_group_name = module.rg.groups.demo.name
    location            = module.rg.groups.demo.location

    scheduled_query_rules_logs = {
      sqrl1 = {
        name           = "sqrl1"
        data_source_id = module.analytics.workspace.id
        enabled        = true
        criteria = {
          metric_name = "Average_% Idle Time"
          dimensions = {
            computer = {
              name     = "Computer"
              operator = "Include"
              values   = ["targetVM"]
            }
          }
        }
      }
    }
  }
}
