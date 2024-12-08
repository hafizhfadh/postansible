#!/bin/bash
set -e
echo "Testing Patroni cluster health..."
for node in 172.28.0.10 172.28.0.11 172.28.0.12; do
  echo "Checking node $node..."
  curl -s "http://$node:8008/cluster" | jq .
done
