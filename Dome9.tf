# Setup required variables for Azure and Dome9
variable "dome9_access_id" {
    type = string
}

variable "dome9_secret_key" {
    type = string
}

variable "azure_sub" {
    type = string
}

variable "azure_tenant" {
    type = string
}

variable "azure_client_id" {
    type = string
}

variable "azure_client_pass" {
    type = string
}

variable "aws_arn" {
    type = string
}

variable "aws_secret" {
    type = string
}

# Configure the Dome9 Provider
provider "dome9" {
  dome9_access_id     = var.dome9_access_id
  dome9_secret_key    = var.dome9_secret_key
}

# Setup new Azure Subscription
resource "dome9_cloudaccount_azure" "VisualStudio" {
  name            = "VisualStudio"
  operation_mode  = "Read"
  subscription_id = var.azure_sub
  tenant_id       = var.azure_tenant
  client_id       = var.azure_client_id
  client_password = var.azure_client_pass
}

resource "dome9_cloudaccount_aws" "AWS_CPX2020" {
  name  = "AWS_CPX2020"

  credentials  {
    arn    = var.aws_arn 
    secret = var.aws_secret 
    type   = "RoleBased"
  }

  net_sec {
    regions {
      new_group_behavior = "ReadOnly"
      region             = "us_east_1"
    }
    regions {
      new_group_behavior = "ReadOnly"
      region             = "us_west_1"
    }
    regions {
      new_group_behavior = "ReadOnly"
      region             = "eu_west_1"
    }
    regions {
      new_group_behavior = "ReadOnly"
      region             = "ap_southeast_1"
    }
    regions {
      new_group_behavior = "ReadOnly"
      region             = "ap_northeast_1"
    }
    regions {
      new_group_behavior = "ReadOnly"
      region             = "us_west_2"
    }
    regions {
      new_group_behavior = "ReadOnly"
      region             = "sa_east_1"
    }
    regions {
      new_group_behavior = "ReadOnly"
      region             = "ap_southeast_2"
    }
    regions {
      new_group_behavior = "ReadOnly"
      region             = "eu_central_1"
    }
    regions {
      new_group_behavior = "ReadOnly"
      region             = "ap_northeast_2"
    }
    regions {
      new_group_behavior = "ReadOnly"
      region             = "ap_south_1"
    }
    regions {
      new_group_behavior = "ReadOnly"
      region             = "us_east_2"
    }
    regions {
      new_group_behavior = "ReadOnly"
      region             = "ca_central_1"
    }
    regions {
      new_group_behavior = "ReadOnly"
      region             = "eu_west_2"
    }
    regions {
      new_group_behavior = "ReadOnly"
      region             = "eu_west_3"
    }
    regions {
      new_group_behavior = "ReadOnly"
      region             = "eu_north_1"
    }
    regions {
      new_group_behavior = "ReadOnly"
      region             = "ap_east_1"
    } 
    regions {
      new_group_behavior = "ReadOnly"
      region             = "me_south_1"
    } 
  }
}

resource "dome9_continuous_compliance_notification" "Ryan_ProjectBigfoot" {
  name           = "ryan at projectbigfoot"
  description    = "CPX2020_Email_1"
  alerts_console = true

  change_detection {
    email_sending_state                = "Enabled"
    email_per_finding_sending_state    = "Enabled"

    email_data {
      recipients = ["ryan@projectbigfoot.net"]
    }
     email_per_finding_data {
      recipients                 = ["ryan@projectbigfoot.net"]
      notification_output_format = "PlainText"
   }
  }
}

resource "dome9_continuous_compliance_notification" "Ryan_ProjectSasquatch" {
  name           = "ryan at projectsasquatch"
  description    = "CPX2020_Email_2"
  alerts_console = true
  scheduled_report {
    email_sending_state = "Enabled"
    schedule_data {
      cron_expression = "0 0 15 * * ?"
      type = "Detailed"
      recipients = ["ryan@projectsasquatch.net"]
    }
  }
  change_detection {
    email_sending_state                = "Enabled"
    email_per_finding_sending_state    = "Enabled"

    email_data {
      recipients = ["ryan@projectsasquatch.net"]
    }
    email_per_finding_data {
      recipients                 = ["ryan@projectsasquatch.net"]
      notification_output_format = "PlainText"
   }
  }
}

resource "dome9_continuous_compliance_policy" "Azure_CPX2020_Policy" {
  cloud_account_id    = dome9_cloudaccount_azure.VisualStudio.id
  external_account_id = dome9_cloudaccount_azure.VisualStudio.id
  bundle_id           = dome9_ruleset.newruleset.id
  cloud_account_type  = "Azure"
  notification_ids    = [dome9_continuous_compliance_notification.Ryan_ProjectBigfoot.id]
}

resource "dome9_ruleset" "newruleset" {
  name        = "Terraform_CPX2020_Azure_NSG_Rule"
  description = "Demo CPX Rule"
  cloud_vendor = "azure"
  language = "en"
  hide_in_compliance = false
  is_template = false
  rules {
    name = "CPX2020 Azure NSG Rule"
    logic = "VirtualMachine where isPublic=true should not have nics with [ networkSecurityGroup.name='no-NSG-attached' and subnet.securityGroup.name='no-NSG-attached' ]"
    severity = "High"
    description = "Attach a Network Security Group to each VM or subnet containing a VM. If no Network Security Group is attached to either the Virtual Machine or the subnet, the VM is not protected and can be accessed from the internet."
    compliance_tag = "Network Security"
    priority = "high"
    is_default = false
    remediation = "Attach a Network Security Group to the Virtual Machine or to the Subnet containing the VM. It is recommended to attach a Security Group to all relevant elements in Azure"
  }
}

resource "dome9_ruleset" "newruleset1" {
  name        = "Terraform_CPX2020_AWS_ELB_8090"
  description = "Demo CPX Rule for AWS"
  cloud_vendor = "aws"
  language = "en"
  hide_in_compliance = false
  is_template = false
  rules {
    name = "CPX2020 AWS ELB 8090 Rule"
    logic = "ApplicationLoadBalancer where isPublic=true and inboundRules contain [port <= 8090 and portTo >= 8090 and protocol in ('TCP','ALL')] should not have inboundRules contain [port <= 8090 and portTo >= 8090 and protocol in ('TCP','ALL') and scope isPublic() and scope='0.0.0.0/0']"
    severity = "High"
    description = "Services and databases store data that may be sensitive, protected by law, subject to regulatory requirements or compliance standards. It is highly recommended that access to data will be restricted to encrypted protocols. This rule detects network settings that may expose data via unencrypted protocol over the public internet or to a too wide local scope."
    compliance_tag = "Network Ports Security"
    priority = "high"
    is_default = false
    remediation = "Limit the access scope for ApplicationLoadBalancer with service 'Known internal web port to only allow access in internal networks and limited scope."
  }
}

resource "dome9_iplist" "iplist_1" {
  name        = "CPX2020_Example_List_1"
  description = "List Example #1"
  items  {
        ip = "10.2.0.0/16"
        comment = "Net 10 dot 2"
          }
  items  {
        ip = "10.9.0.0/16"
        comment = "Net 10 dot 9"
          }
  items  {
        ip = "192.168.1.3/32"
        comment = "My IP 192"
          }
}

