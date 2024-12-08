#!/bin/bash

# Load environment variables
source .env

# Run the playbook
echo "Starting PostgreSQL HA setup..."
ansible-playbook \
  -i ansible/inventory/production.yml \
  --vault-password-file $ANSIBLE_VAULT_PASS \
  ansible/playbooks/setup_postgresql.yml | tee logs/deployment.log

# Run tests
echo "Running tests..."
bash scripts/test_patroni.sh
bash scripts/test_pgpool.sh
bash scripts/test_failover.sh

echo "Deployment and testing completed!"
