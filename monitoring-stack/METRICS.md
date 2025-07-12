# Canopy Prometheus Integration

This document provides information about integrating Canopy metrics on prometheus

## Prometheus Configuration

### Basic Scrape Configuration
```yaml
scrape_configs:
  - job_name: 'canopy'
    static_configs:
      - targets: ['localhost:9090']  # Default Canopy metrics endpoint
    scrape_interval: 15s
    scrape_timeout: 10s
```

You can find a working example [here](./prometheus/prometheus.yml)


### Recommended Recording Rules
```yaml
groups:
  - name: canopy
    rules:
      # Node Health
      - record: canopy:node_up
        expr: canopy_node_status == 1
      
      # Peer Health
      - record: canopy:peers_total
        expr: sum(canopy_peer_total{status="connected"})
      
      # Validator Status Summary
      - record: canopy:validators_by_status
        expr: sum by (status) (canopy_validator_status)
      
      # Transaction Rates
      - record: canopy:transaction_rate
        expr: rate(canopy_transaction_received[5m]) + rate(canopy_transaction_sent[5m])
```

## Metric Types and Usage

### Gauges
Gauges represent current values that can go up or down:
- Node status
- Peer counts
- Block height
- Memory usage
- Validator status

### Counters
Counters represent monotonically increasing values:
- Transaction counts
- Block processing counts

### Histograms
Histograms track the distribution of values:
- Block processing time

## Recommended Alerts

```yaml
groups:
  - name: canopy
    rules:
      # Node Health
      - alert: CanopyNodeDown
        expr: canopy_node_status == 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Canopy node is down"
          description: "Node has been down for more than 5 minutes"

      # Sync Status
      - alert: CanopyNodeNotSynced
        expr: canopy_node_syncing_status == 1
        for: 15m
        labels:
          severity: warning
        annotations:
          summary: "Canopy node is not synced"
          description: "Node has been out of sync for more than 15 minutes"

      # Peer Health
      - alert: CanopyLowPeerCount
        expr: sum(canopy_peer_total{status="connected"}) < 3
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Low peer count"
          description: "Node has fewer than 3 connected peers"

      # Performance
      - alert: CanopyHighBlockProcessingTime
        expr: rate(canopy_block_processing_seconds_sum[5m]) / rate(canopy_block_processing_seconds_count[5m]) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High block processing time"
          description: "Average block processing time is above 1 second"
```

## Grafana Dashboard Recommendations

You can find the example of the default grafana dashboard implementation [here](./grafana/dashboards/canopy_dashboard.json)

### Key Panels to Include
1. Node Status
   - Node up/down status
   - Sync status
   - Uptime

2. Peer Network
   - Total peers
   - Inbound/outbound peers
   - Peer connection status

3. Validator Status
   - Validator count by status
   - Validator types
   - Staking status

4. Transaction Metrics
   - Transaction rate
   - Transaction volume
   - Transaction types

5. Performance
   - Block processing time
   - Memory usage
   - CPU usage

### Example Queries
```promql
# Node Health
canopy_node_status

# Peer Network Health
sum(canopy_peer_total{status="connected"})

# Validator Status Distribution
sum by (status) (canopy_validator_status)

# Transaction Rate
rate(canopy_transaction_received[5m]) + rate(canopy_transaction_sent[5m])

# Block Processing Performance
rate(canopy_block_processing_seconds_sum[5m]) / rate(canopy_block_processing_seconds_count[5m])
```
 