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

module "alerts" {
  source  = "codectl/alerts/azure"
  version = "~> 1.0"

  alerts = {
    resource_group_name = module.rg.groups.demo.name

    alert_processing_rule_suppressions = {
      aprs1 = {
        name   = "aprs1"
        scopes = [module.rg.groups.demo.id]

        condition = {
          target_resource_type = {
            operator = "Equals"
            values   = ["Microsoft.Compute/VirtualMachines"]
          }
          severity = {
            operator = "Equals"
            values   = ["Sev0", "Sev1", "Sev2"]
          }
        }

        schedule = {
          effective_from  = "2026-01-01T01:02:03"
          effective_until = "2026-02-02T01:02:03"
          time_zone       = "Central Europe Standard Time"
          recurrence = {
            dailies = {
              nightly = {
                start_time = "17:00:00"
                end_time   = "09:00:00"
              }
            }
            weeklies = {
              weekend = {
                days_of_week = ["Saturday", "Sunday"]
              }
            }
          }
        }
      }
    }
  }
}
