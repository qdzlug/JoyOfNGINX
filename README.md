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

#### NGNIX Plus
Ansible scripts to manage NGINX Plus, the paid version of NGINX by F5.

#### NGNIX OSS
Ansible scripts to manage NGINX OSS, the OSS version managed by F5.

#### Tailscale
[Tailscale](https://github.com/tailscale/tailscale) is a software product that
leverages [wireguard](https://www.wireguard.com/) to provide secure VPN 
networking. 

Within these examples, Wireguard can be used to securely connect to the nodes
used for the examples. This can also serve as a proof of concept for securing
traffic between, say, a front end loadbalancer and the upstreams it is balancing
across.

This directory contains an ansible deployment file that can be used to install
Tailscale on your nodes. This requires that you:
1. Have a Tailscale account.
2. You have created a non-expiring API token to join your tailscale network.

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
