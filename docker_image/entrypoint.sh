#!/bin/sh
#
CONFIG_PATH="$(realpath "$(dirname "$0")/../monitoring-stack/loadbalancer/traefik.yml")"
ENV_FILE="$(realpath "$(dirname "$0")/../monitoring-stack/.env")"

# Load .env file
if [ -f $ENV_FILE ]; then
  echo "loading env file"
  echo $ENV_FILE
  . $ENV_FILE
else
  echo "env file not found"
fi

if grep -q "\${ACME_EMAIL}" "$CONFIG_PATH"; then
  echo "Replacing \${ACME_EMAIL} with $ACME_EMAIL in $CONFIG_PATH"
  sed -i "s|\${ACME_EMAIL}|$ACME_EMAIL|g" "$CONFIG_PATH"
else
  echo "ACME_EMAIL already set."
fi

# if BIN_PATH its defined we make a link to it from its volume to our system
if [[ -z "${BIN_PATH}" ]]; then
  echo "using existing BIN_PATH $BIN_PATH"
# if BIN_PATH it's no provided we sue '/bin/cli'
else
  echo "BIN_PATH not provided using /bin/cli as default"
  export BIN_PATH="/bin/cli"
fi

# Persisting current version
# Check if it exist
if [ -f "/root/.canopy/cli" ]; then
  echo "Found existing persistent cli version"
else
  echo "Persisting build version for current cli"
  mv $BIN_PATH /root/.canopy/cli
fi
ln -s /root/.canopy/cli $BIN_PATH

# Update config.json with DOMAIN if provided
if [ ! -z "${DOMAIN}" ]; then
  echo "Updating config.json with DOMAIN: ${DOMAIN}"
  
  # Function to update config file
  update_config() {
    local config_file="$1"
    local node_name="$2"
    local port_suffix="$3"
    
    if [ -f "$config_file" ]; then
      echo "Updating $config_file for $node_name"
      
      # Update RPC URL
      sed -i "s|http://localhost:50002|https://rpc.${HOSTNAME}.${DOMAIN}|g" "$config_file"
      
      # Update Admin RPC URL
      sed -i "s|http://localhost:50003|https://adminrpc.${HOSTNAME}.${DOMAIN}|g" "$config_file"
      
      # Update external address
      sed -i "s|tcp://node1.localhost|tcp://${HOSTNAME}.${DOMAIN}|g" "$config_file"
      
      echo "Updated $config_file successfully"
    else
      echo "Warning: Config file $config_file not found"
    fi
  }
  
  # Update node1 config
  update_config "/root/.canopy/config.json" "node1" "500"
  
  # Update node2 config if it exists
  if [ -f "/root/.canopy/config2.json" ]; then
    update_config "/root/.canopy/config2.json" "node2" "400"
  fi
  
  echo "Config files updated with DOMAIN: ${DOMAIN}"
else
  echo "DOMAIN not set, using default config values"
fi

exec /app/canopy "$@"
