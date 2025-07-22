#!/bin/bash

set -euo pipefail

POOL_FILE="pool.yaml"

if [ -f "$POOL_FILE" ]; then
  echo "Deleting existing pool.yaml at $POOL_FILE"
  rm -f "$POOL_FILE"
else
  echo "No pool.yaml file found at $POOL_FILE"
fi
