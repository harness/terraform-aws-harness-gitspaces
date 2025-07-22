#!/bin/bash

set -euo pipefail

INSTANCE_NAME=$1
NEW_INSTANCE_FILE=$2
POOL_FILE="pool.yaml"

# Convert YAML to JSON (if exists), else initialize
if [[ -f "$POOL_FILE" ]]; then
  EXISTING_JSON=$(yq -o=json '.' "$POOL_FILE")
else
  EXISTING_JSON='{"version":"1", "timestamp":"", "instances":[]}'
fi

# Read new instance JSON
NEW_INSTANCE=$(yq -o=json '.' "$NEW_INSTANCE_FILE")

# Filter out existing instance with same name
FILTERED_JSON=$(echo "$EXISTING_JSON" | jq --arg name "$INSTANCE_NAME" '
  .instances |= map(select(.name != $name))
')

# Add the new instance
UPDATED_JSON=$(echo "$FILTERED_JSON" | jq --argjson new_instance "$NEW_INSTANCE" '
  .instances += [$new_instance]
  | .timestamp = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))
')

# Write back to YAML
echo "$UPDATED_JSON" | yq -P > "$POOL_FILE"
