#!/bin/bash
echo "setting up the validator key"
docker build -t canopy --build-arg 'BRANCH=beta-0.1.3' --build-arg BUILD_PATH=cmd/cli  ./docker_image/ && \
docker run --user root -it -p 50000:50000 -p 50001:50001 -p 50002:50002 -p 50003:50003 -p 9001:9001 --name canopy-config  --volume ${PWD}/canopy_data/node1/:/root/.canopy/ canopy && \
docker stop canopy-config && docker rm canopy-config && \
cp canopy_data/node1/validator_key.json canopy_data/node2/ && \
cp canopy_data/node1/keystore.json canopy_data/node2/

# ask user for setup type
echo "Please select setup type:"
echo "1) simple (only contains the node containers)"
echo "2) full (contains the node containers and the monitoring stack)"
read -p "Enter your choice (1 or 2): " SETUP_CHOICE

# validate and set SETUP_TYPE
while [[ "$SETUP_CHOICE" != "1" && "$SETUP_CHOICE" != "2" ]]; do
    echo "Invalid choice. Please enter 1 for simple or 2 for full."
    read -p "Enter your choice (1 or 2): " SETUP_CHOICE
done

if [[ "$SETUP_CHOICE" == "1" ]]; then
    SETUP_TYPE="simple"
else
    SETUP_TYPE="full"
fi

# set destination paths based on setup type
if [[ "$SETUP_TYPE" == "simple" ]]; then
    STACK_PATH="$(realpath "$(dirname "$0")/simple-stack/")"
else
    STACK_PATH="$(realpath "$(dirname "$0")/monitoring-stack/")"
fi

# only ask for domain and email if setup type is "full"
if [[ "$SETUP_TYPE" == "full" ]]; then
    # ask user for domain input
    read -p "Please enter the domain: " DOMAIN

    # validate that domain is not empty
    while [[ -z "$DOMAIN" ]]; do
        echo "Domain cannot be empty."
        read -p "Please enter the domain: " DOMAIN
    done

    # ask user for acme email input
    read -p "Please enter email to validate the domain against: " ACME_EMAIL

    # validate that email is not empty
    while [[ -z "$ACME_EMAIL" ]]; do
        echo "email cannot be empty."
        read -p "Please enter the email: " ACME_EMAIL
    done

    # define the path to the template and new .env file
    ENV_TEMPLATE_FILE="$STACK_PATH/.env.template"
    ENV_FILE="$STACK_PATH/.env"

    # check if .env.template file exists
    if [[ ! -f "$ENV_TEMPLATE_FILE" ]]; then
      echo ".env.template file not found, please create it with the default values from the repository."
        exit 1
    fi

    # perform sed substitution and create new .env file
    sed -e "s/DOMAIN=.*/DOMAIN=$DOMAIN/" -e "s/ACME_EMAIL=.*/ACME_EMAIL=$ACME_EMAIL/" "$ENV_TEMPLATE_FILE" > "$ENV_FILE"

    echo "Created .env file with domain: $DOMAIN and email: $ACME_EMAIL"
fi

echo "setup complete ✅"
