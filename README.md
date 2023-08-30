# Creating single-tier virtual private cloud for SAP by using Terraform

- [See full IBM Cloud Docs, single-tier virtual private cloud for SAP](https://cloud.ibm.com/docs/sap?topic=sap-create-terraform-single-tier-vpc-sap)

## Description

This automation solution is designed for the deployment of **Single Tier VPC** using IBM Cloud Schematics or using CLI. 
The SAP solution will be deployed on top of **Red Hat Enterprise Linux 8.6 for SAP** in an existing IBM Cloud Gen2 VPC, using an existing bastion host with secure remote SSH access.

Deployment can be done in two ways: 

1. Using CLI from a bastion server
2. Using schematics GUI from IBM Cloud 

This is a minimal terraform script for deploying a VPC and a VSI with SAP certified storage and network configuration.
The VPC contains one subnet and one security group having three rules:
- Allow all outbound traffic from the VSI
- Allow inbound DNS traffic (UDP port 53)
- Allow inbound SSH traffic (TCP port 22)

The VSI is configured with Red Hat Enterprise Linux 8.6 for SAP Applications (amd64), has two SSH keys configured to access as root user on SSH, and two storage volumes created:
- One Swap volume of 48Gb
- One data volume of 10Gb

## Input parameters for schematics usage:
The following parameters can be set in the Schematics workspace: VPC, Subnet, Security group, Resource group, Hostname, Profile, Image, SSH Keys and your SAP system configuration variables, as below:

**VSI input parameters**

Parameter | Description
----------|------------
ibmcloud_api_key | IBM Cloud API key (Sensitive* value).
private_ssh_key | id_rsa private key content (Sensitive* value).
SSH_KEYS | List of SSH Keys UUIDs that are allowed to SSH as root to the VSI. Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys). <br /> Sample input (use your own SSH UUIDs from IBM Cloud):<br /> [ "r010-57bfc315-f9e5-46bf-bf61-d87a24a9ce7a" , "r010-3fcd9fe7-d4a7-41ce-8bb3-d96e936b2c7e" ]
BASTION_FLOATING_IP | The FLOATING IP from the Bastion Server.
RESOURCE_GROUP | An EXISTING  Resource Group for VSIs and Volumes resources. <br /> Default value: "Default". The list of Resource Groups is available [here](https://cloud.ibm.com/account/resource-groups).
REGION | The cloud region where to deploy the solution. <br /> The regions and zones for VPC are listed [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br /> Review supported locations in IBM Cloud Schematics [here](https://cloud.ibm.com/docs/schematics?topic=schematics-locations).<br /> Sample value: eu-de.
ZONE | The cloud zone where to deploy the solution. <br /> Sample value: eu-de-2.
VPC | EXISTING VPC name. The list of VPCs is available [here](https://cloud.ibm.com/vpc-ext/network/vpcs)
SUBNET | EXISTING Subnet name. The list of Subnets is available [here](https://cloud.ibm.com/vpc-ext/network/subnets).
SECURITY_GROUP | EXISTING Security group name. The list of Security Groups is available [here](https://cloud.ibm.com/vpc-ext/network/securityGroups).
APP-IMAGE | The OS image used for SAP Application VSI. A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images).<br /> Default value: ibm-redhat-8-6-amd64-sap-applications-2

**Obs***: <br />
- Sensitive - The variable value is not displayed in your Schematics logs and it is hidden in the input field.<br />
- The following parameters should have the same values as the ones set for the BASTION server: REGION, ZONE, VPC, SUBNET, SECURITY_GROUP.
- For any manual change in the terraform code, you have to make sure that you use a certified image based on the SAP NOTE: 2927211.

## Input parameters for CLI usage:

For the script configuration edit your VPC, Subnet, Security group, Resource group, Hostname, Profile, Image, SSH Keys and disk sizes in `input.auto.tfvars` like so:
```shell
REGION          = Cloud Region Default: eu-de
ZONE			= Cloud Zone Default: eu-de-2
VPC			    = VPC name Default: ic4sap
SECURITY_GROUP  = Security group name Default: ic4sap-securitygroup
RESOURCE_GROUP  = Resource group Default: wes-automation
SUBNET			= Subnet name Default: ic4sap-subnet
HOSTNAME		= VSI Hostname Default: test-vsi
PROFILE			= VSI Profile Default: bx2-4x16
IMAGE			= VSI OS Image Default: ibm-redhat-8-6-amd64-sap-applications-2
SSH_KEYS		= SSH Keys ID list to access the VSI
SWAP			= SWAP Size Default: 48
VOL1			= Volume 1 Size Default: 10
```

**Files description and structure**
 - `modules` - directory containing the terraform modules
 - `input.auto.tfvars` - contains the variables that will need to be edited by the user to customize the solution
 - `main.tf` - contains the configuration of the VSI for SAP single tier deployment.
 - `provider.tf` - contains the IBM Cloud Provider data in order to run `terraform init` command.
 - `variables.tf` - contains variables for the VPC and VSI
 - `versions.tf` - contains the minimum required versions for terraform and IBM Cloud provider.

**Obs***: <br />
- Sensitive - The variable value is not displayed in your tf files details after terrafrorm plan&apply commands.<br />
- VOL[number] | The sizes for the disks in GB that are to be attached to the VSI and used by SAP.<br />
- The following variables should be the same like the bastion ones: REGION, ZONE, VPC, SUBNET, SECURITY_GROUP.


## Steps to reproduce for Schematics usage:

1.  Be sure that you have the [required IBM Cloud IAM
    permissions](https://cloud.ibm.com/docs/vpc?topic=vpc-managing-user-permissions-for-vpc-resources) to
    create and work with VPC infrastructure and you are [assigned the
    correct
    permissions](https://cloud.ibm.com/docs/schematics?topic=schematics-access) to
    create the workspace in Schematics and deploy resources.
2.  [Generate an SSH
    key](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys).
    The SSH key is required to access the provisioned VPC virtual server
    instances via the bastion host. After you have created your SSH key,
    make sure to [upload this SSH key to your IBM Cloud
    account](https://cloud.ibm.com/docs/vpc-on-classic-vsi?topic=vpc-on-classic-vsi-managing-ssh-keys#managing-ssh-keys-with-ibm-cloud-console) in
    the VPC region and resource group where you want to deploy the SAP solution
3.  Create the Schematics workspace:
    1.  From the IBM Cloud menu
    select [Schematics](https://cloud.ibm.com/schematics/overview).
       - Click Create a workspace.
       - Enter a name for your workspace.
       - Click Create to create your workspace.
    2.  On the workspace **Settings** page, enter the URL of this solution in the Schematics examples Github repository.
     - Select the latest Terraform version.
     - Click **Save template information**.
     - In the **Input variables** section, review the default input variables and provide alternatives if desired.
    - Click **Save changes**.

4.  From the workspace **Settings** page, click **Generate plan** 
5.  Click **View log** to review the log files of your Terraform
    execution plan.
6.  Apply your Terraform template by clicking **Apply plan**.
7.  Review the log file to ensure that no errors occurred during the
    provisioning, modification, or deletion process.

The output of the Schematics Apply Plan will list the public/private IP addresses
of the VSI host, the hostname and the VPC.


## Steps to reproduce for CLI usage:

For initializing terraform:

```shell
terraform init
```

For planning phase:

```shell
terraform plan -out plan1
# you will be asked for the following sensitive variables: 'ibmcloud_api_key'.
```

For apply phase:

```shell
terraform apply "plan1"
```

For destroy:

```shell
terraform destroy
# you will be asked for the following sensitive variables as a destroy confirmation phase:
'ibmcloud_api_key'.
```
The Terraform version used for deployment should be >= 1.3.6. 
Note: The deployment was tested with Terraform 1.3.6

