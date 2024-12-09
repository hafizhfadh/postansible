#!/bin/bash

# Load environment variables
source .env

# Run the playbook
echo "Starting PostgreSQL HA setup..."
# Run the Ansible playbook
ansible-playbook -i inventory/hosts.yml playbooks/postgresql_cluster.yml --ask-become-pass | tee logs/deployment.log

echo "Deployment and testing completed!"
