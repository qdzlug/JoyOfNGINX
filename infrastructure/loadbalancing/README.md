# Loadbalancing Example 

## Purpose
This directory contains the terraform and ansible files required to set up a 
sample NGINX loadbalancing configuration. 

When complete, the configuration consists of four small VM's in Azure:
* nginxlb - Loadbalancer system with a public IP address running NGINX Plus
* nginx01 - NGINX Plus upstream
* nginx02 - NGINX Plus upstream
* nginx02 - NGINX Plus upstream

This testing simulates a deployment where the nginxlb accepts all traffic on 
the public internet and forwards it to the upstreams on the private internet.

## Deploying Infrastructure
Deployment requires the installation of terraform, and the various *.tf files
can be found under the [/terraform](./terraform) directory. You will want to 
review and modify the files, especially the [variables.tf](./variables.tf) 
file. This file defines the prefix for the resource group that will be created
as well as the location for the deployment.

Once you have updated the variables file you will need to do the following:
1. Ensure you have installed the 
[Azure CLI tooling](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
1. Logged into Azure via [`az login`](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli).
1. Initialize terraform `terraform init`.
1. Apply the plan `terraform apply` (you will need to approve the deployment).

## Configure Access
The [`create-configs.sh`](./create-configs.sh) has been provided ot pull the 
necessary connection information from the terraform output. This script will:
1. Write out the private ssh key for connection to the instances.
2. Build out an SSH configuration to use the nginxlb as a bastion host to 
connect to the upstreams.
3. Create an ansible inventory file.

This script will provide instructions that will walk you through the process of:
1. Connecting to the infrastructure via ssh.
2. Testing the ansible inventory via `ansible-playbook`. Note that this will 
require that you have ansible installed.

## Next Steps
Follow the instructions in the [`deploy-plus`](../../deploy-nginx) directory.
