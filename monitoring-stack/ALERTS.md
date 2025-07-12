# Canopy Alert Rules Documentation

This document describes the alert conditions configured for the Canopy monitoring system. Alerts are organized into two main categories: Canopy-specific alerts and Infrastructure alerts.



## Customization


If you like to customize the alerts based on your setup/development needs, just edit the [alert-rules.yaml](./monitoring-stack/monitoring/grafana/provisioning/alerting/alert-rules.yaml)


## Guard Rails Documentation

The following table describes the hard limits, soft limits, and low limits for health-related metrics:

| Metric Name          | Hard Limit  | Soft Limit | Low Limit   | Priority | Notes |
|----------------------|-------------|------------|-------------|----------|-------|
| NodeStatus           | 0           | n/a        | n/a         | High     | -     |
| TotalPeers           | 0 peers     | 1 peer     | 2 peers     | Low      | -     |
| LastHeightTime       | n/a         | 5 min      | 25 secs     | High     | Just over 3 rounds at 20s blocks |
| ValidatorStatus      | n/a         | not 1      | -           | -        | Monitor unexpected Pause or Unstaking |
| BFTRound             | n/a         | 3 rounds   | Round 1     | Medium   | Soft = Just below the 'LastHeight' time |
| BFTElectionTime      | 2 secs      | 1.5 secs   | 1 sec       | Medium   | Hard = config, Soft = 75% of config timing |
| BFTElectionVoteTime  | 2 secs      | 1.5 secs   | 1 sec       | Medium   | Hard = config, Soft = 75% of config timing |
| BFTProposeTime       | 4 secs      | 3 secs     | 2 sec       | High     | Hard = config, Soft = 75% of config timing |
| BFTProposeVoteTime   | 4 secs      | 3 secs     | 2 sec       | High     | Hard = config, Soft = 75% of config timing |
| BFTPrecommitTime     | 2 secs      | 1.5 secs   | 1 sec       | Medium   | Hard = config, Soft = 75% of config timing |
| BFTPrecommitVoteTime | 2 secs      | 1.5 secs   | 1 sec       | Medium   | Hard = config, Soft = 75% of config timing |
| BFTCommitTime        | 2 secs      | 1.5 secs   | 1 sec       | Medium   | Hard = config, Soft = 75% of config timing |
| BFTCommitProcessTime | 2 secs      | 1.5 secs   | 1 sec       | Medium   | Hard = config, Soft = 75% of config timing |
| NonSignerPercent     | 33%         | 10%        | 5%          | High     | Hard = BFT upper bound |
| LargestTxSize        | 4KB         | 3KB        | 2KB         | Medium   | Hard = default mempool config, Soft = 75% of hard |
| BlockSize            | 1MB-1652B   | 750KB      | 500KB       | Medium   | Hard = param - MaxBlockHeader, Soft = 75% of param |
| BlockProcessingTime  | 4 secs      | 3 secs     | 2 secs      | Medium   | Hard = MIN(ProposeTimeoutMS, ProposeVoteTimeoutMS) |
| BlockVDFIterations   | n/a         | 0          | n/a         | Medium   | Soft = unexpected behavior |
| RootChainInfoTime    | 2 secs      | 1 sec      | 700ms       | Medium   | Hard = 10% of block time |
| DBPartitionTime      | 10 min      | 5 min      | 2 min       | Low      | Hard = arbitrary / high likelihood of interruption |
| DBPartitionEntries   | 2,000,000   | 1,500,000  | 1,000,000   | Medium   | Hard = Badger default limit (configurable) |
| DBPartitionSize      | 128MB       | 75MB       | 10 MB       | Medium   | Hard = Badger set limit (configurable) |
| DBCommitTime         | 3 secs      | 2 secs     | 1.5 sec     | Medium   | Hard = soft of BlockProcessingTime |
| DBCommitEntries      | 2,000,000   | 1,500,000  | 1,000,000   | Medium   | Hard = Badger default limit (configurable) |
| DBCommitSize         | 128MB       | 10MB       | 1 MB        | High     | Hard = Badger set limit (configurable) |
| MempoolSize          | 10MB        | 2MB        | 500 KB      | Low      | Hard = default config, Soft = 2 blocks |
| MempoolCount         | 5,000       | 3,500      | 1,000       | Low      | Hard = default config, Soft = 75% of hard |

## Alert Categories

### 1. Node Status and Network
- **NodeStatus**: Monitors overall node health
- **TotalPeers**: Tracks peer connectivity
- **ValidatorStatus**: Monitors validator state changes

### 2. BFT (Byzantine Fault Tolerance) Metrics
- **BFTRound**: Tracks BFT consensus rounds
- **BFTElectionTime**: Monitors election timing
- **BFTElectionVoteTime**: Tracks election vote timing
- **BFTProposeTime**: Monitors proposal timing
- **BFTProposeVoteTime**: Tracks proposal vote timing
- **BFTPrecommitTime**: Monitors precommit timing
- **BFTPrecommitVoteTime**: Tracks precommit vote timing
- **BFTCommitTime**: Monitors commit timing
- **BFTCommitProcessTime**: Tracks commit processing timing
- **NonSignerPercent**: Monitors non-signer percentage

### 3. Block Processing
- **BlockSize**: Monitors block size limits
- **BlockProcessingTime**: Tracks block processing duration
- **BlockVDFIterations**: Monitors VDF iterations
- **LargestTxSize**: Tracks largest transaction size
- **LastHeightTime**: Monitors block production timing

### 4. Database Metrics
- **DBPartitionTime**: Monitors partition operation timing
- **DBPartitionEntries**: Tracks partition entry count
- **DBPartitionSize**: Monitors partition size
- **DBCommitTime**: Tracks commit operation timing
- **DBCommitEntries**: Monitors commit entry count
- **DBCommitSize**: Tracks commit size

### 5. Mempool Metrics
- **MempoolSize**: Monitors mempool size
- **MempoolCount**: Tracks transaction count in mempool

### 6. Root Chain Metrics
- **RootChainInfoTime**: Monitors root chain information retrieval timing

## Alert Severity and Notification

- **High Priority Alerts**: 
  - NodeStatus
  - LastHeightTime
  - BFTProposeTime
  - BFTProposeVoteTime
  - NonSignerPercent
  - DBCommitSize

- **Medium Priority Alerts**: 
  - Most BFT timing metrics
  - Block processing metrics
  - Database metrics
  - Root chain metrics

- **Low Priority Alerts**:
  - TotalPeers
  - Mempool metrics
  - DBPartitionTime

## Alert Evaluation
- **Evaluation Interval**: all alerts 1s \ evaluation group by default 1 minute
- **Notification Channels**:
  - Low Limit Alerts: Discord
  - Soft Limit Alerts: PagerDuty
- **Duration**: Conditions must be met for specified duration before triggering
- **Metrics Source**: Prometheus with appropriate rate calculations 