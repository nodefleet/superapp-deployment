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
exec /app/canopy "$@"
