# Rediscovering the Joy of NGINX

NGINX forms the backbone of the modern web, serving web pages, load balancing, 
and securing access both on the internet and internally. However, most users
aren't aware of the more advanced capabilities of NGINX and NGINX Plus.

This repository contains a number of terraform, ansible, and shell scripts that
will help you setup test infrastructure that can then be used to walk through
some of the more advanced capabilities of NGINX and NGINX Plus.

Although this material is designed to work with the Joy of NGINX presentation,
they can also be used in a standalone manner for testing / learning.

## Caveats
These scripts have been written to work with Microsoft's Azure cloud service. 
This choice was made for ease of deployment; any cloud provider can be used, 
however this will require that the infrastructure code be rewritten for the 
provider chosen.

## Requirements
1. Microsoft Azure Account. Note that although these exmaples use smaller VMs
you will likely incur some cost when doing this work. You have been warned.
2. The latest version of (Ansible)[https://www.ansible.com/] community edition.
3. The latest version of [Terraform](https://www.terraform.io/)].
4. Linux, MacOS, or Windows w/ WSL2 to run the Bash scripts.

## Contents
The examples are broken under two main directories:

### Infrastructure
This directory contains subdirectories for the example infrastucture.

### Ansible
This directory contains subdirectories for the various Ansible examples
that are provided.

## FAQ

#### Terraform has an Ansible provider; why didn't you use that?
By breaking the process into two parts - deployment of the infrastructure via
Terraform and the installation of NGINX via Ansible - the deployment is kept
simpler, and easier for users who are new to these products to understand the 
logic flow.

Additionally, this allows for more flexibility going forward to add additional
content.

#### What are the differences between NGINX and NGINX Plus?
The best place to find this information is on the NGINX Documentation website
which can be found [here](https://docs.nginx.com/). Additional documentation on
directives can be found [here](https://nginx.org/en/docs/)
