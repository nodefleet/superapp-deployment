# Canopy monitoring stack overview


This  docker-compose.yaml contains the following software stack for production grade and monitoring purposes; prometheus, grafana for monitoring and cadvisor and node-exporter for container and server metrics respectively and traefik for loadbalancing purposes

We added a [.env](./.env) which is the file we use to parametrice all configurations in order to setup your personal canopy monitoring stack. It is intented to run by default for local testing but can be easily modified via .env variable to be configured for more robust staging/production purposes



## Setup

### System Requirements


#### Monitoring Stack
- **Minimum**: 12GB RAM | 12vCPU | 250GB storage
- **Recommended**: 32GB RAM | 16vCPU | 500GB storage

**Component-specific requirements:**


#### Canopy Nodes
- **Minimum**: 4GB RAM | 2vCPU | 100GB storage
- **Recommended**: 8GB RAM | 4vCPU | 100GB storage


- **Prometheus**: 1GB RAM | 1vCPU | 20GB storage (for metrics storage)
- **Grafana**: 512MB RAM | 1vCPU | 5GB storage (for dashboards and UI)
- **Loki**: 1GB RAM | 1vCPU | 20GB storage (for log storage)
- **Cadvisor**: 256MB RAM | 1vCPU | 2GB storage (for container metrics)
- **Traefik**: 256MB RAM | 1vCPU | 1GB storage (for load balancing)
- **Node Exporter**: 128MB RAM | 1vCPU | 1GB storage (for host metrics)
- **Blackbox Exporter**: 128MB RAM | 1vCPU | 1GB storage (for endpoint monitoring)

### .env 

Copy the env variable as example in order to activate it's usage 

```bash

cp .env.template .env

```

### Grafana loki plugin

Install the loki plugin so all of our logs can be ingested by loki 


``` bash

sudo docker plugin install  grafana/loki-docker-driver --alias loki

```


### grafana notification channels

In order to correctly receive the infrastructure and canopy alerts on this setup stack you should configure the discord and the pagerduty notification channel configs:

[Discord channel webhook](./monitoring/grafana/provisioning/alerting/discord-alert.yaml#L28)

[Pagerduty APIKEY](./monitoring/grafana/provisioning/alerting/pagerduty-alert.yaml#L9)


## Running


```bash

sudo make up

```

If you like to start from the most recent snapshot for canopy mainnet full nodechainID 1 and chainID 2, you should consider using

```bash

sudo make start_with_snapshot

```

### .env.template values


#### DOMAIN=localhost


This stack runs the following local and production services where localhost is replaced by $DOMAIN for production purposes:

- http://wallet.node1.localhost/
	user: canopy, pass:canopy (production usage)
- http://explorer.node1.localhost/
- http://rpc.node1.localhost/
- http://adminrpc.node1.localhost/

- http://wallet.node2.localhost/
(password protected by canopy:canopy)
- http://explorer.node2.localhost/
- http://rpc.node1.localhost/
- http://adminrpc.node1.localhost/


Additionally for the monitoring stack it runs:

- http://monitoring.localhost/
	user: admin, pass: canopy

### Clearing data


This command clears all canopy nodes data for a hard reset of the environment

```bash
sudo make reset
```


## Monitoring stack configuration

Below you will find the configuration file references and instructions in order to understand and customize the current setup

You can also find additional documentation below regarding the current setup:

[Metric documentation](./METRICS.md)

[Alert documentation](./ALERTS.md)


### Grafana

Grafana comes with defaults dashboard described below along with their configuration files and some other env variables described on (.env)[.env]

#### - [Blackbox dashboard](http://localhost:3000/d/xtkCtBkis/blackbox-exporter?var-interval=10s&orgId=1&from=now-15m&to=now&timezone=browser&var-target=$__all&var-source=$__all&var-destination=$__all&refresh=1m)

Dashboard with blackbox metrics which continously tests the wallet, RPC, and explorer endpoints on the canopy nodes 

#### - [Cadvisor exporter](http://localhost:3000/d/pMEd7m0Mz/cadvisor-exporter?orgId=1&from=now-6h&to=now&timezone=browser&var-host=$__all&var-container=$__all&var-DS_PROMETHEUS=PBFA97CFB590B2093)

Dashboard with resources metrics for docker containers

#### - [Node exporter](http://localhost:3000/d/rYdddlPWk/node-exporter-full?orgId=1&from=now-24h&to=now&timezone=browser&var-datasource=default&var-job=node-exporter&var-node=node-exporter:9100&var-diskdevices=%5Ba-z%5D%2B%7Cnvme%5B0-9%5D%2Bn%5B0-9%5D%2B%7Cmmcblk%5B0-9%5D%2B&refresh=1m)

Dashboard with resource metrics for the host instance 


#### - [Traefik dashboard](http://localhost:3000/d/O23g2BeWk/traefik-dashboard?orgId=1&from=now-5m&to=now&timezone=browser&var-service=&var-entrypoint=$__all&refresh=5m)

Dashboard with loadbalancer metrics

#### - [Canopy dashboard](http://localhost:3000/d/fejf7y7gcnwg0e/canopy-dashboard?orgId=1&from=now-1h&to=now&timezone=browser&var-instance=node1:9090&var-instance=node2:9090) 

Dashboard with canopy metrics for blocks, transactions, validators among other metrics


#### - [Instance monitoring alerts](http://localhost:3000/d/KljDeaZ4z/blockchain-node-instance-dashboard?orgId=1&from=now-15m&to=now&timezone=browser&var-DS_PROMETHEUS=default&var-job=node-exporter)

Dashboard with host container metrics 

[dashboard folder](./monitoring/grafana/dashboards)
[dashboard config](./monitoring/grafana/provisioning/dashboards/dashboard.yaml)
[datasources config](./monitoring/grafana/provisioning/datasources/automatic.yaml)


#### Prometheus

Configuration it's mainly described on the prometheus.yml configuration file

[prometheus.yml](./monitoring/prometheus/prometheus.yml)


#### Cadvisor

Used for server metrics, we use the vanilla config which is described in docker-compose.yaml

#### Node-exporter

Used for exporting node metrics, we use the vanilla config which is described in docker-compose.yaml

#### Blackbox

We use blackbox for testing and monitoring wallet/explorer endpoints. We'll be adding more tests for rpc and adminrcp soon

[blackbox.yml](./monitoring/blackbox/blackbox.yml)


#### Loadbalancer 

We use traefik as loadbalancer for exposing wallet/explorer/rpc/adminrpc respectively on two setups local and production with 2 nodes which can be accessed on the URLS described in the start of the document

Also, for changing the DOMAIN, just modify the DOMAIN variable on [.env](.env) and it will update the way it's being accessed, as default it's pointing to localhost

Traefik will automatically create certs for all the URLS described on the # Runing section in this document  

[traefik config](./loadbalancer/traefik.yml) 
[production service](./loadbalancer/services/prod.yaml)
[local service](./loadbalancer/services/local.yaml)
[Middlewares](./loadbalancer/services/middleware.yaml)


##### Loadbalancer configuration for canopy

In order to properly expose canopy nodes through our loadbalancer for production purposes you need to configure the following config variables on [node1 config.json](../canopy_data/node1/config.json) and [node2 config.jso](../canopy_data/node2/config.json) respectively and replace it with the domain you'll use for production purposes:


Node1 config.json

```json
  "rpcURL": "https://rpc.node1.<YOUR_DOMAIN>:50002",
  "adminRPCUrl": "https://adminrpc.node1.<YOUR_DOMAIN>:50003",
  "externalAddress": "tcp://node1.<YOUR_DOMAIN>",
```

Node2 config.json

```json
  "rpcURL": "https://rpc.node2.<YOUR_DOMAIN>:40002",
  "adminRPCUrl": "https://admin.node2.<YOUR_DIMAIN>:40003",
  "externalAddress": "tcp://node2.<YOUR_DIMAIN>",
```


#####  SSL resolver

We use acme as SSL certificate resolver with httpChallenge by default which can be used for production, our documentation also contains `cloudflare` and `namecheap` integration for dnsChallenge recommended for production grade usage

For more information please check  [traefik config](./loadbalancer/traefik.yml) on the section https-resolver, below you'll find details about the https-resolvers described in this file: 

*https-resolver*

It's the one used by default for production grade SSL, validation it's based on httpChallenge validation 


*cloudflare*

It's the recommended one (or any compatible https DNS resolver for your provider) since DNS resolver it's way more effective than httpChallenge

*namecheap*

Added for educational purposes

For more information about https-resolvers please refer to [traefik https-resolvers](https://doc.traefik.io/traefik/reference/install-configuration/tls/certificate-resolvers/overview/)


##### Basic AUTH

By default wallet endpoints are accessed using username: canopy, passwd: canopy
 
But for customizing the loadbalancer basic auth access for production purposes on wallet production endpoints, create a custom password using the following command:

``` bash
htpasswd -nb  canopy canopy
```

Which will print a username and a hashed password that you need to replace it on [middleware.yaml](./loadbalancer/services/middleware.yaml)

After you save this file, traefik will automatically reload and allow the new password to be used right away on your production environment


#### Loki

We use loki for logs which takes all the stdout from the containers and sends it to the loki container. more info on (docker-compose.yaml)[./docker-compose.yaml]

[Loki config](./monitoring/loki/config.yaml)


For ex.: to access loki logs on node1 after you executed the docker-compose up command you should see it [here](http://localhost:3000/explore?schemaVersion=1&panes=%7B%225v4%22:%7B%22datasource%22:%22beh1gkva12hvkd%22,%22queries%22:%5B%7B%22refId%22:%22A%22,%22expr%22:%22%7Bcompose_service%3D%5C%22node2%5C%22%7D%20%7C%3D%20%60%60%22,%22queryType%22:%22range%22,%22datasource%22:%7B%22type%22:%22loki%22,%22uid%22:%22beh1gkva12hvkd%22%7D,%22editorMode%22:%22builder%22,%22direction%22:%22backward%22%7D%5D,%22range%22:%7B%22from%22:%22now-1h%22,%22to%22:%22now%22%7D%7D%7D&orgId=1)
