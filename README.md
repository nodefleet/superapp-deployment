# Overview


This repo is home to various deployments flavor for canopy focusing mainly on providing a proper local development enviroment and a secure but flexible staging/production environments as well


### Validator configuration


For configuring your own validator on canopy mainnet chainID 1 and 2 you need to create your keystore.json and validator_key.json.

This command will ask for your password and username and will create the previous files and store it on `canopy_data/node1/`  which is the datadir that we use for our deployment tooling


```bash
chmod +x setup.sh
./setup.sh
```

### Simple stack


This first [single-stack](./simgle-stack/docker-compose.yaml) contains just the vanilla configurations necessary to build canopy node1 and node2 as simple as :

```bash
cd  ./simple-stack
cp .env.template .env
sudo make up
```


### Monitoring stack


It contains a stack with prometheus, loki, grafana, cadvisor, node-exporter, and traefik as loadbalancer useful for a production grade deployments and flexible for local development as well


For more information please refer to [README.md](./monitoring-stack/README.md)



### docker_image 

It contains the Dockerfile and entrypoint.sh used by all the stacks in order to have a centralized way of building the canopy image


### Canopy config files


Contains the datadir and config files for the nodes used in this stack, respectively [node1](../canopy_data/node1/config.json) and [node2](../canopy_data/node1/config.json)
