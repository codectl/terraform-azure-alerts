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

module "appi" {
  source  = "codectl/appi/azure"
  version = "~> 1.0"

  insights = {
    name                = module.naming.application_insights.name
    resource_group_name = module.rg.groups.demo.name
    location            = module.rg.groups.demo.location
    application_type    = "web"
  }
}

module "alerts" {
  source  = "codectl/alerts/azure"
  version = "~> 1.0"

  alerts = {
    resource_group_name = module.rg.groups.demo.name

    smart_detector_alert_rules = {
      sdar1 = {
        name               = "sdar1"
        severity           = "Sev0"
        scope_resource_ids = [module.appi.insights.id]
        frequency          = "PT1M"
        detector_type      = "FailureAnomaliesDetector"

        action_group = {
          ids = [module.mag.groups.demo.id]
        }
      }
    }
  }
}
