#!/bin/bash
#
# Simple script to build out connection information to be used as part of this
# demo setup. Is not production ready, should not be used in production, etc.
#

BASEDIR=$(pwd)
TERRAFORM=$(which terraform)
TERRAFORMARGS="output --json"
JQ=$(which jq)
SSHKEY="$BASEDIR/nginx.pem"
SSHCONFIG="$BASEDIR/nginx.ssh.config"
ANSIBLEHOSTS="$BASEDIR/nginx.ansible.hosts"

## Parse out the IP addresses we need
PUBLICIP=$($TERRAFORM $TERRAFORMARGS | $JQ '.nginxlb_public_ip_address.value')
NGINX01=$($TERRAFORM $TERRAFORMARGS | $JQ '.nginx01_address.value')
NGINX02=$($TERRAFORM $TERRAFORMARGS | $JQ '.nginx02_address.value')
NGINX03=$($TERRAFORM $TERRAFORMARGS | $JQ '.nginx03_address.value')
NGINXLB=$($TERRAFORM $TERRAFORMARGS | $JQ '.nginxlb_address.value')

# Get our SSH key; we would not do this in production...
$TERRAFORM show -json | $JQ -r \
'.values.root_module.resources[].values | select(.private_key_pem)
|.private_key_pem' > $SSHKEY
chmod 600 $SSHKEY
echo "Private key written to $BASEDIR/$SSHKEY "

# Write out an ssh config file

echo "Host nginxlb"                          >  $SSHCONFIG
echo "        User azureuser"                >> $SSHCONFIG
echo "        HostName $PUBLICIP"            >> $SSHCONFIG
echo "        StrictHostKeyChecking no"      >> $SSHCONFIG
echo " "                                     >> $SSHCONFIG

echo "Host nginx01"                          >> $SSHCONFIG
echo "        User azureuser"                >> $SSHCONFIG
echo "        HostName NGINX01 "             >> $SSHCONFIG
echo "        StrictHostKeyChecking no"      >> $SSHCONFIG
echo "        ProxyJump azureuser@$PUBLICIP" >> $SSHCONFIG
echo " "                                     >> $SSHCONFIG

echo "Host nginx02"                          >> $SSHCONFIG
echo "        User azureuser"                >> $SSHCONFIG
echo "        HostName NGINX02 "             >> $SSHCONFIG
echo "        StrictHostKeyChecking no"      >> $SSHCONFIG
echo "        ProxyJump azureuser@$PUBLICIP" >> $SSHCONFIG
echo " "                                     >> $SSHCONFIG

echo "Host nginx03"                          >> $SSHCONFIG
echo "        User azureuser"                >> $SSHCONFIG
echo "        HostName $NGINX03 "            >> $SSHCONFIG
echo "        StrictHostKeyChecking no"      >> $SSHCONFIG
echo "        ProxyJump azureuser@$PUBLICIP" >> $SSHCONFIG
echo " "                                     >> $SSHCONFIG

echo "SSH configuration written"
echo " "

# Build Ansible Configuration

echo "[all:vars]"                                  > $ANSIBLEHOSTS
echo "ansible_user=azureuser"                     >> $ANSIBLEHOSTS
echo "ansible_become=yes"                         >> $ANSIBLEHOSTS
echo "ansible_become_method=sudo"                 >> $ANSIBLEHOSTS
echo "ansible_python_interpreter=/usr/bin/python3">> $ANSIBLEHOSTS
echo "ansible_ssh_common_args='-F $SSHCONFIG'"    >> $ANSIBLEHOSTS
echo " "                                          >> $ANSIBLEHOSTS
echo "[nginx_lb]"                                 >> $ANSIBLEHOSTS
echo "nginxlb"                                    >> $ANSIBLEHOSTS
echo " "                                          >> $ANSIBLEHOSTS
echo "[nginx_upstream]"                           >> $ANSIBLEHOSTS
echo "nginx01"                                    >> $ANSIBLEHOSTS
echo "nginx02"                                    >> $ANSIBLEHOSTS
echo "nginx03"                                    >> $ANSIBLEHOSTS
echo " "                                          >> $ANSIBLEHOSTS


echo "To use..."
echo " "
echo "====> Using SSH with this deployment"
echo "Add $SSHKEY to your ssh agent:"
echo "     ssh-add $SSHKEY"
echo " "
echo "Invoke ssh with the configuration file $SSHCONFIG"
echo "     ssh -F $SSHCONFIG hostname"
echo " "
echo "Hostnames are:"
echo "      nginxlb : NGINX Loadbalancer"
echo "      nginx01 : NGINX Upstream 1"
echo "      nginx02 : NGINX Upstream 2"
echo "      nginx03 : NGINX Upstream 3"
echo " "

echo "====> Using SSH with this deployment"
echo "Ensure you added the SSHKEY to your agent"
echo "     ssh-add $SSHKEY"
echo ""
echo "Test the inventory:"
echo "     ansible-playbook -i $ANSIBLEHOSTS ansible-ping.yaml"
echo " "
echo "As long as there are no errors you are configured correctly"
echo " "
