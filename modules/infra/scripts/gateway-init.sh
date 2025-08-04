#!/bin/bash
echo 'export GATEWAY_SECRET=${gateway_secret}' >> /etc/profile

if ! command -v docker &> /dev/null; then
  echo "Docker not found. Installing..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh ./get-docker.sh
else
  echo "Docker is already installed. Skipping installation."
fi

mkdir -p /etc/gateway/dynres /etc/gateway/config

cat << EOF > /etc/gateway/config/app.env
HARNESS_JWT_IDENTITY=CDEGateway
HARNESS_JWT_VALIDINMIN=1440
CDE_CLIENT_CONFIG_PATH=/etc/gateway/config/cdeclients.yaml
ENVOY_DYNAMIC_RESOURCE_DIRECTORY=/etc/gateway/dynres
GATEWAY_URL=${gateway_url}
GATEWAY_SECRET=${gateway_secret}
HARNESS_JWT_SECRET=${gateway_secret}
CDE_GATEWAY_REPORT_STATS=true
CDE_GATEWAY_ENABLE_SSH_PIPER=true
CDE_GATEWAY_ACCOUNT_IDENTIFIER=${account_identifier}
CDE_GATEWAY_INFRA_PROVIDER_CONFIG_IDENTIFIER=${infra_provider}
CDE_GATEWAY_VERSION=${gateway_version}
CDE_GATEWAY_REGION=${region_name}
CDE_GATEWAY_GROUP_NAME=${group_name}
CDE_GATEWAY_INFRA_PROVIDER_TYPE=hybrid_vm_aws
CDE_GATEWAY_REDIS_ENDPOINT=${redis_endpoint}
CDE_GATEWAY_EVENTS_MODE=${events_mode}
CDE_GATEWAY_ENABLE_HIGH_AVAILABILITY=${enable_ha}
EOF

cat << YAML > /etc/gateway/config/cdeclients.yaml
- base_url: ${cde_manager_url}
  secure: false
YAML

sudo docker run -d \
  -e ENVOY_DYNAMIC_RESOURCE_DIRECTORY=/etc/gateway/dynres \
  -e CDE_CLIENT_CONFIG_PATH=/etc/gateway/config/cdeclients.yaml \
  -e CDE_GATEWAY_ENV_FILE=/etc/gateway/config/app.env \
  -e GATEWAY_AGENT_REQUIRE_MTLS=false \
  -e ENVOY_DEBUG_LEVEL=debug \
  -v /etc/gateway:/etc/gateway \
  --network host \
  harness/cde-gateway:${gateway_version}
