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
PUBLICIP=$($TERRAFORM $TERRAFORMARGS | $JQ '.nginx_public_ip_address.value')
NGINX=$($TERRAFORM $TERRAFORMARGS | $JQ '.nginx_address.value')

# Get our SSH key; we would not do this in production...
$TERRAFORM show -json | $JQ -r \
'.values.root_module.resources[].values | select(.private_key_pem)
|.private_key_pem' > $SSHKEY
chmod 600 $SSHKEY
echo "Private key written to $BASEDIR/$SSHKEY "

# Write out an ssh config file

echo "Host nginx"                          >  $SSHCONFIG
echo "        User azureuser"                >> $SSHCONFIG
echo "        HostName $PUBLICIP"            >> $SSHCONFIG
echo "        StrictHostKeyChecking no"      >> $SSHCONFIG
echo " "                                     >> $SSHCONFIG

echo "SSH configuration written"
echo " "

# Build Ansible Configuration

echo "[all:vars]" > $ANSIBLEHOSTS
echo "ansible_user=azureuser" >> $ANSIBLEHOSTS
echo "ansible_become=yes" >> $ANSIBLEHOSTS
echo "ansible_become_method=sudo" >> $ANSIBLEHOSTS
echo "ansible_python_interpreter=/usr/bin/python3" >> $ANSIBLEHOSTS
echo "ansible_ssh_common_args='-F $SSHCONFIG'" >> $ANSIBLEHOSTS
echo " " >> $ANSIBLEHOSTS
echo "[nginx_main]" >> $ANSIBLEHOSTS
echo "nginx" >> $ANSIBLEHOSTS
echo " " >> $ANSIBLEHOSTS


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
echo "      nginx : NGINX server"
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
