#!/bin/bash
set -e
echo "Simulating node failure and testing failover..."
ssh username@172.28.0.10 "sudo systemctl stop patroni"
echo "Primary node stopped. Waiting for failover..."
sleep 20

NEW_PRIMARY=$(curl -s http://172.28.0.11:8008/cluster | jq -r '.members[] | select(.role=="leader") | .name')
echo "New primary node is: $NEW_PRIMARY"

ssh username@172.28.0.10 "sudo systemctl start patroni"
echo "Primary node restarted."
