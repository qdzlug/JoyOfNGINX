#!/usr/bin/env bash
set -euo pipefail

install() {
  echo Run Ansible Playbook
  eval `ssh-agent -s`
  cd terraform
  ./create-configs.sh
  ssh-add ./nginx.pem
  sleep 20
  echo
  echo Ping ansible hosts
  ansible-playbook -i ./nginx.ansible.hosts ./ansible-ping.yaml
  sleep 10
  echo
  echo Deploy Nginx OSS
  ansible-playbook -i ./nginx.ansible.hosts ../ansible-playbooks/NGINXOSS/deploy-oss.yaml
}

upgrade() {
  echo World 2.0
}

uninstall() {
  echo
}

# Call the requested function and pass the arguments as-is
"$@"
