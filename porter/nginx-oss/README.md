# Get Porter to install Nginx OSS

Try out an install of Nginx OSS without cloning the repo and installing 
terraform, ansible, etc...

[Porter](https://getporter.org) is a single binary tool for creation and installation of CNAB bundles. 
After [installing Porter](https://getporter.org/install/), you just need to map your Azure credentials to 
a Porter credential set and you're ready to install into your cloud.

The quickest way is to get an [Azure service principal](https://learn.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest#az-ad-sp-create-for-rbac)
 and set the following environment variables.

```
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
AZURE_CLIENT_SECRET
AZURE_CLIENT_ID
```

Then you can use the provided credential set file to map your env to CNAB bundle
credentials.

```
curl https://raw.githubusercontent.com/bdegeeter/JoyOfNGINX/main/porter/nginx-oss/porter-nginx-oss-credentials.yaml -O && porter credentials apply porter-nginx-oss-credentials.yaml
```

Porter has a number of way to map your secrets to the bundle installation. 

You can run `porter credentials list` to confirm creation.

Next, just reference the bundle tag and credential set to install.

```
porter install -c nginx-oss -r ghcr.io/bdegeeter/joyofnginx/nginx-oss:v0.1.2
```

After installation you can access the outputs and try things out.
```
porter installation outputs list nginx-oss
```

Check the service
```
curl $(porter installation outputs list nginx-oss -o json |jq -r '.[] | select(.name=="nginxlb_public_ip_address")| .value ' )
```

Get the ssh key and config to access hosts.
```
porter installation outputs list nginx-oss -o json |jq -r '.[] | select(.name=="openssh_private_key")| .value ' > nginx.pem
chmod 0600 nginx.pem
porter installation outputs list nginx-oss -o json |jq -r '.[] | select(.name=="nginx_ssh_config")| .value ' > nginx.ssh.config

ssh-add nginx.pem
ssh -F nginx.ssh.config <hostname>
```

Get the Ansible inventory file
```
porter installation outputs list nginx-oss -o json |jq -r '.[] | select(.name=="nginx_ansible_hosts")| .value ' > nginx.ansible.hosts
```

When your done uninstall to clean everything up

```
porter installations list
porter uninstall -c nginx-oss nginx-oss
```
