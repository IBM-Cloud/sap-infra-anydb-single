variable "ID_RSA_FILE_PATH" {
    default = "ansible/id_rsa"
    nullable = false
    description = "File path for PRIVATE_SSH_KEY. It will be automatically generated. If it is changed, it must contain the relative path from git repo folders. Example: ansible/id_rsa_path"
}


variable "PRIVATE_SSH_KEY" {
	type		= string
	description = "id_rsa private key content in OpenSSH format (Sensitive value). This private key should be used only during the provisioning and is recommended to be changed after the SAP deployment."
	nullable = false
	validation {
	condition = length(var.PRIVATE_SSH_KEY) >= 64 && var.PRIVATE_SSH_KEY != null && length(var.PRIVATE_SSH_KEY) != 0 || contains(["n.a"], var.PRIVATE_SSH_KEY )
	error_message = "The content for PRIVATE_SSH_KEY variable must be completed in OpenSSH format."
      }
}


variable "SSH_KEYS" {
	type	    = list(string)
	description = "List of SSH Keys UUIDs that are allowed to SSH as root to the VSI. Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys). Sample input (use your own SSH UUIDs from IBM Cloud): [ \"r010-57bfc315-f9e5-46bf-bf61-d87a24a9ce7a\" , \"r010-3fcd9fe7-d4a7-41ce-8bb3-d96e936b2c7e\" ]."
	validation {
		condition     = var.SSH_KEYS == [] ? false : true && var.SSH_KEYS == [""] ? false : true
		error_message = "At least one SSH KEY is needed to be able to access the VSI."
	}
}

variable "BASTION_FLOATING_IP" {
	type		= string
	description = "The BASTION FLOATING IP. It can be found at the end of the Bastion Server deployment log, in \"Outputs\", before \"Command finished successfully\" message."
	nullable = false
	validation {
        condition = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",var.BASTION_FLOATING_IP)) || contains(["localhost"], var.BASTION_FLOATING_IP ) && var.BASTION_FLOATING_IP!= null
        error_message = "Incorrect format for variable: BASTION_FLOATING_IP."
      }
}

variable "REGION" {
	type		= string
	description	= "The cloud region where to deploy the VSI. The regions and zones for VPC are available here: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. Supported locations in IBM Cloud Schematics: https://cloud.ibm.com/docs/schematics?topic=schematics-locations."
	validation {
		condition     = contains(["au-syd", "jp-osa", "jp-tok", "eu-de", "eu-gb", "ca-tor", "us-south", "us-east", "br-sao"], var.REGION )
		error_message = "The REGION must be one of: au-syd, jp-osa, jp-tok, eu-de, eu-gb, ca-tor, us-south, us-east, br-sao, please update input tfvars file."
	}
}

variable "ZONE" {
	type		= string
	description	= "Availability zone for VSI, in the same VPC. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc"
	validation {
		condition     = length(regexall("^(au-syd|jp-osa|jp-tok|eu-de|eu-gb|ca-tor|us-south|us-east|br-sao)-(1|2|3)$", var.ZONE)) > 0
		error_message = "The ZONE is not valid, please update input tfvars file."
	}
}

variable "VPC" {
	type		= string
	description = "The name of an EXISTING VPC. Must be in the same region as the VSI to be deployed. The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.VPC)) > 0
		error_message = "The VPC name is not valid, please update input tfvars file."
	}
}

variable "SUBNET" {
	type		= string
	description = "The name of an EXISTING Subnet, in the same VPC, region and zone as the VSI to be created. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets"
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SUBNET)) > 0
		error_message = "The SUBNET name is not valid, please update input tfvars file."
	}
}

variable "SECURITY_GROUP" {
	type		= string
	description = "The name of an EXISTING Security group for the same VPC. It can be found at the end of the Bastion Server deployment log, in \"Outputs\", before \"Command finished successfully\" message. The list of Security Groups is available here: https://cloud.ibm.com/vpc-ext/network/securityGroups."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SECURITY_GROUP)) > 0
		error_message = "The SECURITY_GROUP name is not valid, please update input tfvars file."
	}
}

variable "RESOURCE_GROUP" {
  type        = string
  description = "The name of an EXISTING Resource Group, previously created by the user. The list of Resource Groups is available here: https://cloud.ibm.com/account/resource-groups"
  default     = "Default"
}

variable "HOSTNAME" {
	type		= string
	description = "The hostname for VSI. The hostname should be up to 13 characters. "
	validation {
		condition     = length(var.HOSTNAME) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.HOSTNAME)) > 0
		error_message = "The HOSTNAME is not valid, please update input tfvars file."
	}
}

variable "PROFILE" {
	type		= string
	description = "The profile for the VSI. The list of available profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui. For more information, check SAP Note 2927211: \"SAP Applications on IBM Virtual Private Cloud\""
	default		= "bx2-4x16"
}

variable "IMAGE" {
	type		= string
	description = "The OS image for VSI. Supported OS images for APP VSIs: ibm-redhat-8-6-amd64-sap-applications-4, ibm-redhat-8-4-amd64-sap-applications-7, ibm-sles-15-4-amd64-sap-applications-6, ibm-sles-15-3-amd64-sap-applications-9. The list of available VPC Operating Systems supported by SAP: SAP note '2927211-SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images"
	default		= "ibm-redhat-8-6-amd64-sap-applications-4"
        validation {
         condition     = length(regexall("^(ibm-redhat-8-(4|6)-amd64-sap-applications|ibm-sles-15-(3|4)-amd64-sap-applications)-[0-9][0-9]*", var.IMAGE)) > 0
             error_message = "The OS SAP IMAGE must be one of \"ibm-redhat-8-4-amd64-sap-applications-x\", \"ibm-redhat-8-6-amd64-sap-applications-x\", \"ibm-sles-15-3-amd64-sap-applications-x\" or \"ibm-sles-15-4-amd64-sap-applications-x\"."
    }
}

variable "SWAP" {
	type		= string
	description = "The size of SWAP disk, in GB"
	default		= "48"
}

variable "VOL1" {
	type		= string
	description = "The size of Volume 1, in GB"
	default		= "10"
}
