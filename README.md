# Deployment of a Single Tier System for SAP, in Virtual Private Cloud, using Automation

- [See full IBM Cloud Docs, single-tier virtual private cloud for SAP](https://cloud.ibm.com/docs/sap?topic=sap-create-terraform-single-tier-vpc-sap)

## Description

This automation solution is designed for the deployment of a single tier system for SAP, in VPC, using IBM Cloud Schematics or using CLI.
The SAP solution can be deployed later on top of one of the following operating systems: Red Hat Enterprise Linux 8.6 for SAP Applications, Red Hat Enterprise Linux 8.4 for SAP Applications, Suse Enterprise Linux 15 SP4 for SAP Applications, Suse Enterprise Linux 15 SP3 for SAP Applications, in an existing IBM Cloud Gen2 VPC, using an existing BASTION server (deployment server) host with secure remote SSH access.

This is a Terraform script for deploying a VSI with SAP certified storage and network configuration. The automation has support for the following versions: Terraform >= 1.5.7 and IBM Cloud provider for Terraform >= 1.57.0. Note: The deployment was tested with Terraform 1.5.7

The deployment can be done in two ways:

- From IBM Cloud, using Schematics GUI
- From a BASTION Server (Deployment Server), using CLI

The VSI is configured with **Red Hat Enterprise Linux 8.6 for SAP Applications (amd64)**, **Red Hat Enterprise Linux 8.4 for SAP Applications (amd64)**, **Suse Enterprise Linux 15 SP4 for SAP Applications (amd64)** or **Suse Enterprise Linux 15 SP3 for SAP Applications (amd64)**. SSH keys are configured to allow the access via SSH as root user, and two storage volumes are created:
- One Swap volume (default size 48 GB)
- One data volume (default size 10 GB)

In order to track the events specific to the resources deployed by this solution, the [IBM Cloud Activity Tracker](https://cloud.ibm.com/docs/activity-tracker?topic=activity-tracker-getting-started#gs_ov) to be used should be specified. IBM Cloud Activity Tracker service collects and stores audit records for API calls made to resources that run in the IBM Cloud. It can be used to monitor the activity of your IBM Cloud account, investigate abnormal activity and critical actions, and comply with regulatory audit requirements. In addition, you can be alerted on actions as they happen.

## Contents:

- [1. Prerequisites](#1-prerequisites)
- [2. Input parameters for Schematics usage](#2-input-parameters-for-schematics-usage)
- [3. Input parameters for CLI usage](#3-input-parameters-for-cli-usage)
- [4. Executing the deployment from GUI (Schematics)](#4-executing-the-deployment-from-gui-schematics)
- [5. Executing the deployment from CLI](#5-executing-the-deployment-from-cli)

## 1. Prerequisites:

- A Deployment Server (BASTION Server) in the same VPC should exist. For more information, see https://github.com/IBM-Cloud/sap-bastion-setup.
- Create or retrieve an IBM Cloud API key. The API key is used to authenticate with the IBM Cloud platform and to determine your permissions for IBM Cloud services.
- Create or retrieve your SSH key ID. You need the 40-digit UUID for the SSH key, not the SSH key name.

## 2. Input parameters for Schematics usage:
The following parameters can be set in the Schematics workspace: VPC, Subnet, Security group, Resource group, Hostname, Profile, Image, SSH Keys and your SAP system configuration variables, as below:

**VSI input parameters**

Parameter | Description
----------|------------
IBMCLOUD_API_KEY | IBM Cloud API key (Sensitive* value). The IBM Cloud API Key can be created [here](https://cloud.ibm.com/iam/apikeys)
ID_RSA_FILE_PATH | File path for PRIVATE_SSH_KEY. It will be automatically generated. If it is changed, it must contain the relative path from git repo folders. <br /> Default value: "ansible/id_rsa".
PRIVATE_SSH_KEY | id_rsa private key content (Sensitive* value) in OpenSSH format. This private key it is used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
SSH_KEYS |  List of IBM Cloud SSH Keys UUIDs that are allowed to connect via SSH, as root, to the VSI. The SSH Keys must be created for the same region as the Cloud resources for SAP. Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys). <br /> Sample input:<br /> ["r010-57bfc315-f9e5-46bf-bf61-d87a24a9ce7a", "r010-3fcd9fe7-d4a7-41ce-8bb3-d96e936b2c7e"]
BASTION_FLOATING_IP | The FLOATING IP from the Bastion Server. It can be found at the end of the Bastion Server deployment log, in "Outputs", before "Command finished successfully" message.
RESOURCE_GROUP | The name of an EXISTING Resource Group for VSI and Volumes resources. <br /> Default value: "Default". The list of Resource Groups is available [here](https://cloud.ibm.com/account/resource-groups).
REGION | The cloud region where to deploy the solution. <br /> The regions and zones for VPC are available [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br /> Supported locations in IBM Cloud Schematics [here](https://cloud.ibm.com/docs/schematics?topic=schematics-locations).<br /> Sample value: eu-de.
ZONE | The cloud availability zone where to deploy the solution, in the same VPC. <br /> The regions and zones for VPC are available [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br /> Supported locations in IBM Cloud Schematics [here](https://cloud.ibm.com/docs/schematics?topic=schematics-locations).<br /> Sample value: eu-de-2.
VPC | The name of an EXISTING VPC. Must be in the same region as the solution to be deployed. The list of VPCs is available [here](https://cloud.ibm.com/vpc-ext/network/vpcs)
SUBNET | The name of an EXISTING Subnet, in the same VPC, region and zone as the VSI to be created. The list of Subnets is available [here](https://cloud.ibm.com/vpc-ext/network/subnets).
SECURITY_GROUP | The name of an EXISTING Security group for the same VPC. It can be found at the end of the Bastion Server deployment log, in "Outputs", before "Command finished successfully" message. The list of Security Groups is available [here](https://cloud.ibm.com/vpc-ext/network/securityGroups).
IMAGE | The OS image used for SAP Application VSI (See Obs*). A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images).<br /> Default value: ibm-redhat-8-6-amd64-sap-applications-4
PROFILE | The profile used for the VSI. A list of profiles is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles).<br> For more information about supported OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211)<br/> Default values: DB_PROFILE = "bx2-4x16" , APP_PROFILE = "bx2-4x16".
HOSTNAME | The hostname for VSI. Each hostname should be up to 13 characters as required by SAP.<br> For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361].
SWAP | The size of the SWAP volume, in GB. Default value: 48
VOL1 | The size of Volume 1, in GB. Default value: 10

**Activity Tracker input parameters:**

Parameter | Description
----------|------------
ATR_NAME | The name of the EXISTING Activity Tracker instance, in the same region chosen for SAP system deployment. The list of available Activity Tracker is available [here](https://cloud.ibm.com/observe/activitytracker)

**Obs***: <br />
- Sensitive - The variable value is not displayed in your Schematics logs and it is hidden in the input field.<br />
- The following parameters should have the same values as the ones set for the BASTION server: REGION, ZONE, VPC, SUBNET, SECURITY_GROUP.
- For any manual change in the terraform code, you have to make sure that you use a certified image based on the SAP NOTE: 2927211.

## 3. Input parameters for CLI usage:

### IBM Cloud API Key
For the script configuration add your IBM Cloud API Key in terraform planning phase command 'terraform plan --out plan1'.
You can create an API Key [here](https://cloud.ibm.com/iam/apikeys).

### Input parameter file
The solution is configured by editing your variables in the file `input.auto.tfvars`
Edit your VPC, Subnet, Security group, Hostnames, Profile, Image, SSH Keys and starting with minimal recommended disk sizes like so:

**VSI input parameters**

```shell
##########################################################
# General VPC variables:
######################################################

REGION = "eu-de"
# The cloud region where to deploy the solution. Supported regions: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: REGION = "eu-de"

ZONE = "eu-de-1"
# Availability zone for VSI, in the REGION. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: ZONE = "eu-de-2"

VPC = "ic4sap"
# The name of an EXISTING VPC. Must be in the same region as the solution to be deployed. The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs.
# Example: VPC = "ic4sap"

SECURITY_GROUP = "ic4sap-securitygroup"
# The name of an EXISTING Security group for the same VPC. It can be found at the end of the Bastion Server deployment log, in "Outputs", before "Command finished successfully" message.
# The list of available Security Groups: https://cloud.ibm.com/vpc-ext/network/securityGroups
# Example: SECURITY_GROUP = "ic4sap-securitygroup"

RESOURCE_GROUP = "wes-automation"
# The name of an EXISTING Resource Group, previously created by the user. The list of available Resource Groups: https://cloud.ibm.com/account/resource-groups
# Example: RESOURCE_GROUP = "wes-automation"

SUBNET = "ic4sap-subnet"
# The name of an EXISTING Subnet, in the same VPC and ZONE where the VSI will be created. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets.
# Example: SUBNET = "ic4sap-subnet"

SSH_KEYS = ["r010-8f72b994-c17f-4500-af8f-d05680374t3c", "r011-8f72v884-c17f-4500-af8f-d05900374t3c"]
# List of SSH Keys UUIDs that are allowed to connect via SSH, as root, to the VSI. Can contain one or more IDs. The SSH Keys should be created for the same region as the VSIs. The list of available SSH Keys UUIDs: https://cloud.ibm.com/vpc-ext/compute/sshKeys
# Example: SSH_KEYS = ["r010-8f72b994-c17f-4vf00-af8f-d05680374t3c", "r011-8f72v884-c17f-45bh00-af8f-d05900374t3c"]

ID_RSA_FILE_PATH = "ansible/id_rsa"
# The path to an existing id_rsa private key file, with 0600 permissions. The private key must be in OpenSSH format.
# This private key is used only during the provisioning and it is recommended to be changed after the SAP deployment.
# It must contain the relative or absoute path from your Bastion.
# Examples: "/root/.ssh/id_rsa".

HOSTNAME = "ic4sap"
# The Hostname for the VSI. The hostname should be up to 13 characters, as required by SAP
# Example: HOSTNAME = "ic4sap"

PROFILE = "bx2-4x16"
# The profile for the VSI. The list of available profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles.
# For more information, check SAP Note 2927211: "SAP Applications on IBM Virtual Private Cloud"

IMAGE = "ibm-redhat-8-6-amd64-sap-applications-4"
# OS image for the VSI. Supported OS images: ibm-redhat-8-6-amd64-sap-applications-4, ibm-redhat-8-4-amd64-sap-applications-7, ibm-sles-15-4-amd64-sap-applications-6, ibm-sles-15-3-amd64-sap-applications-9.
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: IMAGE = "ibm-redhat-8-6-amd64-sap-applications-4"

SWAP = "48"
# SWAP volume size, in GB. Default value: 48 GB
# Example: SWAP = "48"

VOL1 = "10"
# Volume 1 size, in GB. Default value: 10 GB
# Example: VOL1 = "10"

##########################################################
# Activity Tracker variables:
##########################################################

ATR_NAME = "Activity-Tracker-SAP-eu-de"
# The name of the EXISTENT Activity Tracker instance, in the same region chosen for SAP system deployment.
# Example: ATR_NAME="Activity-Tracker-SAP-eu-de"

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
- VOL[number] | The sizes of the disks, in GB, that are to be attached to the VSI and used by SAP.<br />
- The following variables should be the same like the bastion ones: REGION, ZONE, VPC, SUBNET, SECURITY_GROUP.


## 4. Executing the deployment from GUI (Schematics):

1.  Make sure that you have the [required IBM Cloud IAM
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
        - Push the `Create workspace` button.
        - Provide the URL of the Github repository of this solution
        - Select the latest Terraform version.
        - Click on `Next` button
        - Provide a name, the resources group and location for your workspace
        - Push `Next` button
        - Review the provided information and then push `Create` button to create your workspace
    2.  On the workspace **Settings** page,
        - In the **Input variables** section, review the default values for the input variables and provide alternatives if desired.
        - Click **Save changes**.

        The automation has support for the following versions: Terraform >= 1.5.7 and IBM Cloud provider for Terraform >= 1.57.0. Note: The deployment was tested with Terraform 1.5.7

4.  From the workspace **Settings** page, click **Generate plan** 
5.  Click **View log** to review the log files of your Terraform
    execution plan.
6.  Apply your Terraform template by clicking **Apply plan**.
7.  Review the log file to ensure that no errors occurred during the
    provisioning, modification, or deletion process.

The output of the Schematics Apply Plan will list the public/private IP addresses
of the VSI host, the hostname and the VPC.


## 5. Executing the deployment from CLI:

For initializing terraform:

```shell
terraform init
```

For planning phase:

```shell
terraform plan -out plan1
# you will be asked for the following sensitive variables: 'IBMCLOUD_API_KEY'.
```

For apply phase:

```shell
terraform apply "plan1"
```

For destroy:

```shell
terraform destroy
# you will be asked for the following sensitive variables as a destroy confirmation phase:
'IBMCLOUD_API_KEY'.
```
