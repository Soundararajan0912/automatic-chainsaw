# Managed Streaming Services Guide

A comprehensive guide to managed streaming services across AWS, Google Cloud, and Azure for real-time data processing, ingestion, and delivery.
## 📋 Table of Contents
- [Overview](#overview)
- [Key Concepts](#key-concepts)
- [AWS Services](#aws-services)
  - [Kinesis Data Streams](#aws-kinesis-data-streams)
  - [Kinesis Data Firehose](#aws-kinesis-data-firehose)
  - [AppSync Subscriptions](#aws-appsync-subscriptions)
- [Google Cloud Services](#google-cloud-services)
  - [Cloud Pub/Sub](#google-cloud-pubsub)
  - [Managed Kafka](#google-cloud-managed-kafka)
- [Azure Services](#azure-services)
  - [Event Hubs](#microsoft-azure-event-hubs)
- [Comparison & Decision Guide](#comparison--decision-guide)
- [Integration Patterns](#integration-patterns)
- [Cost Optimization](#cost-optimization)
- [When NOT to Use](#when-not-to-use)


## Overview

Managed streaming services handle real-time data ingestion, storage, and delivery without requiring you to manage servers or infrastructure. They auto-scale, handle durability/replication, and integrate with downstream analytics/processing services.

### Key Difference from Lambda Streaming

| Aspect | Lambda Option (Pull Model) | Managed Services (Push Model) |
|--------|---------------------------|-------------------------------|
| **Data Flow** | You define streaming endpoint (Flask app), clients pull from you | Clients push data TO the service, then you consume/process it |
| **Use Case** | Client-side streaming responses | Ingesting high-volume data and processing it in real-time |
| **Best For** | Serving data streams to clients | Collecting and processing events at scale |

---

## AWS Services

### AWS Kinesis Data Streams

**Purpose:** Capture, process, and analyze high-volume streaming data in real-time

#### Architecture

```
Data Producers (IoT, apps, logs) → Kinesis Stream → Multiple Consumers
                                    ↓
                              SHARDS (parallel units)
                                    ↓
                    Lambda/EC2/Fargate → S3/DynamoDB
```

- Each stream divided into **SHARDS** (parallel processing units)
- **1 shard** = 1 MB/sec input, 2 MB/sec output
- Data stored for **24 hours** (configurable up to **365 days**)

#### How It Works

1. Application sends records to Kinesis stream
2. Data distributed across shards based on partition key
3. Multiple Lambda functions/consumers read from stream simultaneously
4. Each consumer processes their shard independently
5. Process at high scale: 1 MB/sec per shard × N shards

#### Key Features

- ✅ Real-time processing (sub-second latency)
- ✅ Multiple concurrent consumers (read same stream)
- ✅ Data retention 1-365 days (replay capability)
- ✅ Exactly-once processing semantics
- ✅ Manual provisioning (you choose # of shards)
- ✅ Scales to terabytes per hour

#### Best For

- Real-time analytics pipelines
- Processing millions of events per second
- Application event streams
- Fraud detection (needs data history)

#### Pricing

| Component | Cost |
|-----------|------|
| Per shard-hour | $0.28 |
| Per 1M PUT records | $0.014 |
| Standard throughput | 4 MB/sec total |
| Enhanced fan-out | $0.43 per shard-hour |

#### Example Use Case

```
Application logs → Kinesis Stream → Lambda (process/filter) → S3/DynamoDB
```

### AWS Kinesis Data Firehose

**Purpose:** Automatically load streaming data into data warehouses, data lakes, and analytics services

#### Architecture

```
Data Source (Kinesis, Direct PUT, S3, EventBridge, IoT) 
    ↓
Firehose (buffers + transforms)
    ↓
Destination (S3, Redshift, Splunk, Datadog, etc.)
```

#### How It Works

1. Data sent to Firehose stream
2. Firehose buffers data for X seconds OR Y MB (whichever comes first)
3. **Optional:** Lambda transformation applied to each batch
4. Data delivered to destination (S3, Redshift, etc.)
5. Failed deliveries backed up to S3 automatically

#### Key Features

- ✅ Fully managed (no shard management)
- ✅ Auto-scales automatically
- ✅ Built-in transformation (Lambda functions)
- ✅ Converts data format (Parquet, ORC, JSON)
- ✅ Automatic data backup on failure
- ✅ Low-latency loading (60-90 seconds typical)
- ✅ Extended data retention (backups)

#### Best For

- Loading data into data warehouses/lakes
- Simple transformation + loading
- Log aggregation to S3
- Time-series data to analytics platforms
- ELT (Extract-Load-Transform) workflows

#### Pricing

- **$0.029 per GB** of data ingested
- Free data transformation with Lambda
- No shard/provisioning costs
- Only pay for data you ingest

#### Example Use Case

```
Application events → Firehose → S3 (data lake) → Athena SQL queries
```

### AWS AppSync Subscriptions

**Purpose:** Enable real-time data updates to connected clients via WebSocket

#### Architecture

```
Client (browser/mobile) ← WebSocket → AppSync ← Data Source (DynamoDB/Lambda)
```

#### How It Works

1. Client connects to AppSync GraphQL API
2. Client sends subscription (GraphQL query)
3. AppSync establishes WebSocket connection
4. Server performs mutation (create/update/delete)
5. AppSync automatically sends update to all subscribers
6. Clients receive real-time data

#### Key Features

- ✅ Real-time push notifications to clients
- ✅ WebSocket connections managed automatically
- ✅ GraphQL native (type-safe)
- ✅ Multiple authorization modes (API Key, Cognito, IAM)
- ✅ Built-in conflict resolution
- ✅ Integrates with Lambda, DynamoDB, RDS

#### Best For

- Chat applications (real-time messages)
- Collaborative tools (live updates)
- Dashboards (real-time metrics)
- Social apps (notifications)
- Live notifications

#### Pricing

| Component | Cost |
|-----------|------|
| GraphQL requests | $1.25 per million |
| Real-time notifications | $1.25 per million |
| Connection-hours | $0.25 per 100,000 |
| Data transfer | Standard AWS rates |

#### Example Use Case

```
User creates post → DynamoDB → AppSync mutation → All subscribers notified in real-time
```


## Google Cloud Services

### Google Cloud Pub/Sub

**Purpose:** Asynchronous messaging for event-driven systems

#### Architecture

```
Publishers → Topics → Subscriptions → Subscribers (Pull/Push)
```

- Messages stored briefly (**1 week retention** by default)
- At-least-once delivery guarantee

#### How It Works

1. Application publishes message to topic
2. Message available to all subscribers
3. Subscribers can pull (on-demand) or receive push delivery
4. Subscriber acknowledges message
5. Message removed from queue

#### Key Features

- ✅ Fully managed, serverless
- ✅ Auto-scales automatically
- ✅ Multiple subscription types (pull/push)
- ✅ Global topic distribution
- ✅ High throughput (millions of messages/sec)
- ✅ Exactly-once processing
- ✅ Filter subscriptions

#### Best For

- Event-driven architectures
- Asynchronous task queues
- Decoupling microservices
- Multi-cloud deployments
- Streaming to multiple destinations

#### Pricing (GCP)

- **$50 per TB** ingested
- **$10 per TB** of data operations
- First 1 GB/month free

#### Example Use Case

```
Order placed → Pub/Sub topic → Multiple subscribers (billing, shipping, notifications)
```


### Google Cloud Managed Kafka

**Purpose:** Apache Kafka as a managed service

#### Features

- Kafka API compatibility
- Self-managed or Confluent Cloud
- Supports connectors
- Unlimited retention (with cluster)
- Lower operational overhead than self-hosted

#### Best For

- Existing Kafka workloads
- Need for Kafka ecosystem/connectors
- Complex event routing


## Azure Services

### Microsoft Azure Event Hubs

**Purpose:** Managed event streaming service (Azure equivalent of Kinesis)

#### Architecture

```
Event Producers → Event Hub (with partitions) → Event Consumers
```

- Supports up to **20 MB messages**
- **1-7 day retention** with option for long-term storage

#### How It Works

1. Applications send events to Event Hub
2. Events partitioned for parallel processing
3. Multiple consumers process partitions concurrently
4. Integrates with Stream Analytics, Functions, Logic Apps

#### Key Features

- ✅ Supports millions of events/sec
- ✅ 20 MB message size (larger than Kinesis)
- ✅ Apache Kafka protocol support
- ✅ Geo-disaster recovery
- ✅ Serverless and dedicated tiers

#### Best For

- Azure-based architectures
- Large message streaming
- Multi-region deployments
- Kafka compatibility needed

#### Pricing (Azure)

- Throughput units: **$0.012 per hour**
- Standard tier: Up to 1,000 events/sec per unit
- Premium: Higher throughput


## Comparison & Decision Guide

### Feature Comparison

| Feature | Kinesis Streams | Firehose | AppSync | Pub/Sub | Event Hubs |
|---------|-----------------|----------|---------|---------|------------|
| **Purpose** | Real-time analytics | Data loading | Real-time responses | Async messaging | Real-time ingestion |
| **Delivery Model** | Pull/Enhanced fan-out | Push to destination | Push via WebSocket | Push/Pull | Pull/Push |
| **Latency** | <100ms | 60-90 seconds | Real-time | ~100ms | Real-time |
| **Throughput** | Terabytes/hour | Terabytes/hour | Millions of messages | Millions/sec | Millions/sec |
| **Data Retention** | 1-365 days | Optional (S3 backup) | Real-time only | 7 days default | 1-7 days |
| **Multi-consumer** | ✅ Yes | ❌ No | ✅ Yes | ✅ Yes | ✅ Yes |
| **Scaling** | Manual (shards) | Automatic | Automatic | Automatic | Automatic |
| **Message Size** | 1 MB | Variable | Variable | 100 MB | 20 MB |
| **Pricing Model** | Per shard + record | Per GB | Per request + connections | Per GB | Per throughput unit |
| **Cost (high volume)** | Higher if not optimized | Lower | Depends on subscribers | Medium | Lower |

### Quick Decision Matrix

#### Choose **Kinesis Streams** if:
- ✅ Need real-time processing of streaming data
- ✅ Have multiple consumers reading same stream
- ✅ Need to replay/re-process historical data
- ✅ Building real-time analytics pipeline
- ✅ Handling IoT/sensor/event data at scale
- ✅ Need exactly-once processing

#### Choose **Firehose** if:
- ✅ Only need to load data to destination (S3, warehouse)
- ✅ Want transformation + loading in one service
- ✅ Don't need complex processing logic
- ✅ Want pay-per-GB pricing (simpler)
- ✅ Loading to Redshift/S3/Splunk/etc

#### Choose **AppSync Subscriptions** if:
- ✅ Building real-time client applications
- ✅ Need live notifications/updates
- ✅ Have browser/mobile clients
- ✅ Using GraphQL API
- ✅ Need WebSocket management

#### Choose **Pub/Sub** if:
- ✅ Building event-driven microservices
- ✅ Want to decouple publishers and subscribers
- ✅ Multi-cloud requirements
- ✅ Simple async messaging needed

#### Choose **Event Hubs** if:
- ✅ Azure-first or multi-cloud strategy
- ✅ Need Kafka compatibility
- ✅ Large message support important
- ✅ Enterprise streaming requirements



## Integration Patterns

### Pattern 1: Data Collection → Processing → Analytics

```
Kinesis Streams → Lambda → S3/DynamoDB/Analytics
```

**Use Case:** Real-time data pipeline with processing



### Pattern 2: Simple Log Aggregation

```
Application → Firehose → S3 (data lake) → Athena (SQL queries)
```

**Use Case:** Centralized logging and analysis



### Pattern 3: Real-Time Notifications

```
Database mutation → AppSync → Connected clients (instant notification)
```

**Use Case:** Live updates to web/mobile apps



### Pattern 4: Event-Driven Microservices

```
Service A publishes event → Pub/Sub → Service B subscribes and acts
```

**Use Case:** Decoupled microservices architecture



### Pattern 5: Hybrid Data Pipeline

```
IoT devices → Kinesis → Lambda (enrich) → Firehose → Snowflake/Redshift
```

**Use Case:** Complex data pipeline with multiple stages

## Cost Optimization

### Kinesis Streams

- ✅ Use **on-demand pricing** for variable workloads (vs provisioned shards)
- ✅ Enhanced fan-out: only if **>2 concurrent consumers**
- ✅ Batch writes (`put_records`) instead of `put_record`

### Firehose

- ✅ Adjust **buffer size/interval** (larger buffer = better compression = lower cost)
- ✅ Use **format conversion** (compress to Parquet)
- ✅ **Partition data** by date/time (easier to query)

### AppSync

- ✅ Use **connection pooling** on client side
- ✅ **Filter subscriptions** (don't send unnecessary data)
- ✅ Use **request rate limiting**

### Pub/Sub

- ✅ **Batch publish** messages (fewer API calls)
- ✅ Use **pull subscriptions** (vs push) for better control
- ✅ **Clean up unused subscriptions**



## When NOT to Use

### ❌ Don't use Managed Streaming Services if:

- Client-side streaming (use Lambda with Flask SSE instead)
- Simple file transfer (use S3/blob storage)
- Client expecting HTTP chunked response
- Building request-response API (use REST/GraphQL)
- Low-volume occasional events (use SQS/simple queues)
- Batch processing with no real-time requirements


## 📚 Additional Resources

### AWS Documentation
- [Kinesis Data Streams](https://docs.aws.amazon.com/kinesis/latest/dev/introduction.html)
- [Kinesis Data Firehose](https://docs.aws.amazon.com/firehose/latest/dev/what-is-this-service.html)
- [AWS AppSync](https://docs.aws.amazon.com/appsync/latest/devguide/what-is-appsync.html)

### Google Cloud Documentation
- [Cloud Pub/Sub](https://cloud.google.com/pubsub/docs)
- [Managed Kafka](https://cloud.google.com/managed-service-for-apache-kafka)

### Azure Documentation
- [Event Hubs](https://docs.microsoft.com/en-us/azure/event-hubs/)



## 📄 License

This documentation is provided as-is for educational and reference purposes.


**Last Updated:** November 2025
