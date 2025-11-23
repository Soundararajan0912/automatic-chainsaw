# Unified Docker Compose Stack

A comprehensive Docker Compose setup for a complete data infrastructure stack including databases, message queues, monitoring, and metadata management.

## 📋 Table of Contents

- [Components](#components)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Docker Compose Commands](#docker-compose-commands)
- [Component Testing](#component-testing)
- [Default Credentials](#default-credentials)
- [Data Persistence Notes](#data-persistence-notes)
- [Environment Variables](#environment-variables)

## 🚀 Components

This stack includes the following services:

| Service | Description | Default Port | UI/API |
|---------|-------------|--------------|---------|
| **PostgreSQL** | Relational database with logical replication | 5432 | - |
| **MongoDB** | NoSQL document database | 27017 | - |
| **Redis** | In-memory cache and message broker | 6379 | - |
| **Kafka** | Distributed event streaming platform | 9092, 29092 | - |
| **Debezium** | CDC (Change Data Capture) connector | 8083 | REST API |
| **Cerbos** | Authorization policy engine | 3592 | - |
| **FalkorDB** | Graph database | 6380 | UI: 3001 |
| **Portainer** | Container management UI | 9443, 8000 | HTTPS UI |
| **Prometheus** | Metrics collection and monitoring | 9090 | UI |
| **Grafana** | Data visualization and dashboards | 3000 | UI |
| **Node Exporter** | Host metrics exporter | 9100 | Metrics |
| **cAdvisor** | Container metrics | 8081 | UI |
| **Elasticsearch** | Search and analytics engine | 9200, 9300 | REST API |
| **OpenMetadata Server** | Metadata management platform | 8585, 8586 | UI |
| **Ingestion (Airflow)** | Workflow orchestration for metadata ingestion | 8080 | UI |

## 📦 Prerequisites

- Docker Engine 20.10 or later
- Docker Compose V2 or later
- Minimum 8GB RAM (16GB recommended)
- 20GB free disk space

## 🎯 Quick Start

### Start All Services

```powershell
docker compose up -d
```

**Expected Output:**
```
[+] Running 18/18
 ✔ Network app_network                     Created
 ✔ Volume "postgres_data"                  Created
 ✔ Volume "mongodb_data"                   Created
 ✔ Volume "redis_data"                     Created
 ✔ Container postgres                      Started
 ✔ Container mongodb                       Started
 ✔ Container redis                         Started
 ✔ Container kafka                         Started
 ✔ Container openmetadata_elasticsearch    Started
 ✔ Container cerbos                        Started
 ✔ Container falkordb                      Started
 ✔ Container portainer                     Started
 ✔ Container nodeexporter                  Started
 ✔ Container cadvisor                      Started
 ✔ Container debezium                      Started
 ✔ Container prometheus                    Started
 ✔ Container execute_migrate_all           Started
 ✔ Container grafana                       Started
 ✔ Container openmetadata_server           Started
 ✔ Container openmetadata_ingestion        Started
```

### Stop All Services

```powershell
docker compose down
```

**Expected Output:**
```
[+] Running 18/18
 ✔ Container openmetadata_ingestion        Removed
 ✔ Container grafana                       Removed
 ✔ Container openmetadata_server           Removed
 ✔ Container prometheus                    Removed
 ✔ Container debezium                      Removed
 ✔ Container execute_migrate_all           Removed
 ✔ Container cadvisor                      Removed
 ✔ Container nodeexporter                  Removed
 ✔ Container portainer                     Removed
 ✔ Container falkordb                      Removed
 ✔ Container cerbos                        Removed
 ✔ Container openmetadata_elasticsearch    Removed
 ✔ Container kafka                         Removed
 ✔ Container redis                         Removed
 ✔ Container mongodb                       Removed
 ✔ Container postgres                      Removed
 ✔ Network app_network                     Removed
```

### Stop All Services and Remove Volumes

```powershell
docker compose down -v
```

> ⚠️ **Warning:** This will delete all persistent data!

## 📖 Docker Compose Commands

### Starting Services

#### Start All Services

```powershell
docker compose up -d
```

#### Start Specific Services

```powershell
# Start only databases
docker compose up -d postgres mongodb redis

# Start databases and message queue
docker compose up -d postgres mongodb redis kafka

# Start monitoring stack
docker compose up -d prometheus grafana node-exporter cadvisor

# Start OpenMetadata stack
docker compose up -d postgres elasticsearch execute-migrate-all openmetadata-server ingestion
```

**Expected Output:**
```
[+] Running 3/3
 ✔ Container postgres   Started
 ✔ Container mongodb    Started
 ✔ Container redis      Started
```

#### Start with Build (if custom images)

```powershell
docker compose up -d --build
```

### Stopping Services

#### Stop All Services

```powershell
docker compose stop
```

#### Stop Specific Services

```powershell
# Stop only Kafka
docker compose stop kafka

# Stop monitoring stack
docker compose stop prometheus grafana node-exporter cadvisor
```

**Expected Output:**
```
[+] Stopping 1/1
 ✔ Container kafka   Stopped
```

### Restarting Services

#### Restart All Services

```powershell
docker compose restart
```

#### Restart Specific Services

```powershell
# Restart Kafka
docker compose restart kafka

# Restart OpenMetadata Server
docker compose restart openmetadata-server
```

### Viewing Logs

#### View All Logs

```powershell
docker compose logs -f
```

#### View Specific Service Logs

```powershell
# View Kafka logs
docker compose logs -f kafka

# View last 100 lines of PostgreSQL logs
docker compose logs --tail=100 postgres

# View OpenMetadata Server logs
docker compose logs -f openmetadata-server
```

### Using Profiles (Advanced)

Docker Compose profiles allow you to group services and start only specific groups. While this `docker-compose.yml` doesn't have profiles defined yet, here's how you can use them:

#### Example: Adding Profiles to docker-compose.yml

Add profile tags to services in your `docker-compose.yml`:

```yaml
services:
  postgres:
    profiles: ["database", "core"]
    # ... rest of config

  prometheus:
    profiles: ["monitoring"]
    # ... rest of config

  openmetadata-server:
    profiles: ["metadata"]
    # ... rest of config
```

#### Start Services by Profile

```powershell
# Start only database services
docker compose --profile database up -d

# Start monitoring services
docker compose --profile monitoring up -d

# Start multiple profiles
docker compose --profile database --profile monitoring up -d
```

**Expected Output:**
```
[+] Running 3/3
 ✔ Container postgres   Started
 ✔ Container mongodb    Started
 ✔ Container redis      Started
```

### Service Status

#### Check Running Services

```powershell
docker compose ps
```

**Expected Output:**
```
NAME                         IMAGE                                              STATUS
cadvisor                     gcr.io/cadvisor/cadvisor:latest                   Up 2 minutes (healthy)
cerbos                       ghcr.io/cerbos/cerbos:0.34.0                      Up 2 minutes
debezium                     quay.io/debezium/connect:3.3                      Up 2 minutes (healthy)
execute_migrate_all          docker.getcollate.io/openmetadata/server:1.10.7   Exited (0)
falkordb                     falkordb/falkordb:latest                          Up 2 minutes (healthy)
grafana                      grafana/grafana:latest                            Up 2 minutes (healthy)
kafka                        apache/kafka:latest                               Up 2 minutes (healthy)
mongodb                      mongo:latest                                      Up 2 minutes (healthy)
nodeexporter                 prom/node-exporter:latest                         Up 2 minutes (healthy)
openmetadata_elasticsearch   docker.elastic.co/elasticsearch/elasticsearch...  Up 2 minutes (healthy)
openmetadata_ingestion       docker.getcollate.io/openmetadata/ingestion:1...  Up 2 minutes
openmetadata_server          docker.getcollate.io/openmetadata/server:1.10.7   Up 2 minutes
portainer                    portainer/portainer-ce:latest                     Up 2 minutes
postgres                     postgres:17.6                                     Up 2 minutes (healthy)
prometheus                   prom/prometheus:latest                            Up 2 minutes (healthy)
redis                        redis:latest                                      Up 2 minutes (healthy)
```

#### Check All Services (including stopped)

```powershell
docker compose ps -a
```

### Service Health

#### View Service Health Status

```powershell
docker compose ps --format json | ConvertFrom-Json | Select-Object Name, Health, Status
```

## 🧪 Component Testing

### PostgreSQL Testing

```powershell
# Test connection using psql
docker exec -it postgres psql -U postgres -c "SELECT version();"

# List all databases
docker exec -it postgres psql -U postgres -c "\l"

# Test specific database connection
docker exec -it postgres psql -U openmetadata_user -d openmetadata_db -c "SELECT current_database();"

# Check replication slots
docker exec -it postgres psql -U postgres -c "SELECT * FROM pg_replication_slots;"
```

**Expected Output:**
```
                                                      version
--------------------------------------------------------------------------------------------------------------------
 PostgreSQL 17.6 (Debian 17.6-1.pgdg120+1) on x86_64-pc-linux-gnu, compiled by gcc (Debian 12.2.0-14) 12.2.0, 64-bit
(1 row)
```

### MongoDB Testing

```powershell
# Test connection
docker exec -it mongodb mongosh -u admin -p password --authenticationDatabase admin --eval "db.adminCommand('ping')"

# Show databases
docker exec -it mongodb mongosh -u admin -p password --authenticationDatabase admin --eval "show dbs"

# Test insert and query
docker exec -it mongodb mongosh -u admin -p password --authenticationDatabase admin test --eval "db.test.insertOne({test: 'data'}); db.test.find()"
```

**Expected Output:**
```
{ ok: 1 }
```

### Redis Testing

```powershell
# Test connection with password
docker exec -it redis redis-cli -a tLrrGkm6HoC7qUppXTeQkiBf PING

# Set and get a test key
docker exec -it redis redis-cli -a tLrrGkm6HoC7qUppXTeQkiBf SET testkey "Hello Redis"
docker exec -it redis redis-cli -a tLrrGkm6HoC7qUppXTeQkiBf GET testkey

# Check Redis info
docker exec -it redis redis-cli -a tLrrGkm6HoC7qUppXTeQkiBf INFO server
```

**Expected Output:**
```
PONG
OK
"Hello Redis"
```

### Kafka Testing

```powershell
# List topics
docker exec -it kafka /opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --list

# Create a test topic
docker exec -it kafka /opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic test-topic --partitions 1 --replication-factor 1

# Describe topic
docker exec -it kafka /opt/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic test-topic

# Produce test message
docker exec -it kafka bash -c "echo 'test message' | /opt/kafka/bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic test-topic"

# Consume messages
docker exec -it kafka /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test-topic --from-beginning --max-messages 1
```

**Expected Output:**
```
Created topic test-topic.
Topic: test-topic	TopicId: xyz123	PartitionCount: 1	ReplicationFactor: 1
test message
```

### Debezium Testing

```powershell
# Check Debezium Connect status
curl http://localhost:8083/

# List installed connectors
curl http://localhost:8083/connectors

# Check connector plugins
curl http://localhost:8083/connector-plugins | ConvertFrom-Json | Format-Table
```

**Expected Output:**
```json
{
  "version": "3.3.0",
  "commit": "1234567890abcdef",
  "kafka_cluster_id": "MkU3OEVBNTcwNTJENDM2Qk"
}
```

### Cerbos Testing

```powershell
# Check Cerbos health
curl http://localhost:3592/_cerbos/health

# Test policy check (example)
curl -X POST http://localhost:3592/api/check/resources `
  -H "Content-Type: application/json" `
  -d '{"principal":{"id":"user1","roles":["user"]},"resource":{"kind":"document","id":"1"},"actions":["view"]}'
```

**Expected Output:**
```json
{"status":"SERVING"}
```

### FalkorDB Testing

```powershell
# Test connection
docker exec -it falkordb redis-cli PING

# Create a graph
docker exec -it falkordb redis-cli GRAPH.QUERY test "CREATE (n:Person {name: 'Alice', age: 30})"

# Query the graph
docker exec -it falkordb redis-cli GRAPH.QUERY test "MATCH (n:Person) RETURN n.name, n.age"
```

**Expected Output:**
```
PONG
1) 1) "Labels added: 1"
   2) "Nodes created: 1"
   3) "Properties set: 2"
```

### Portainer Testing

```powershell
# Access Portainer Web UI
Start-Process "https://localhost:9443"
```

> Navigate to `https://localhost:9443` in your browser (accept self-signed certificate warning)

### Prometheus Testing

```powershell
# Check Prometheus health
curl http://localhost:9090/-/healthy

# Check Prometheus targets
curl http://localhost:9090/api/v1/targets | ConvertFrom-Json

# Access Prometheus Web UI
Start-Process "http://localhost:9090"
```

**Expected Output:**
```
Prometheus is Healthy.
```

### Grafana Testing

```powershell
# Check Grafana health
curl http://localhost:3000/api/health

# Access Grafana Web UI
Start-Process "http://localhost:3000"
```

**Expected Output:**
```json
{
  "commit": "abc123",
  "database": "ok",
  "version": "latest"
}
```

### Elasticsearch Testing

```powershell
# Check cluster health
curl http://localhost:9200/_cluster/health?pretty

# List indices
curl http://localhost:9200/_cat/indices?v

# Get cluster info
curl http://localhost:9200/
```

**Expected Output:**
```json
{
  "cluster_name": "docker-cluster",
  "status": "yellow",
  "timed_out": false,
  "number_of_nodes": 1
}
```

### OpenMetadata Server Testing

```powershell
# Check server health
curl http://localhost:8586/healthcheck

# Check API version
curl http://localhost:8585/api/v1/system/version

# Access OpenMetadata Web UI
Start-Process "http://localhost:8585"
```

**Expected Output:**
```json
{
  "status": "healthy"
}
```

### Airflow (Ingestion) Testing

```powershell
# Check Airflow health
curl http://localhost:8080/health

# Access Airflow Web UI
Start-Process "http://localhost:8080"
```

**Expected Output:**
```json
{
  "metadatabase": {
    "status": "healthy"
  },
  "scheduler": {
    "status": "healthy"
  }
}
```

## 🔐 Default Credentials

### Airflow (Ingestion Service)

**Login credentials for Airflow and OpenMetadata UI are defined in the `init-db.sql` file.**

Check the `init-db.sql` file for:
- Database usernames and passwords
- Initial user accounts
- Access credentials

**Default Airflow Credentials** (for UI access):
- **Username:** `admin`
- **Password:** `admin`

### OpenMetadata

**Default OpenMetadata Credentials:** (for UI access)
- **Username:** `admin@open-metadata.org`
- **Password:** `admin`

### Grafana

**Default Grafana Credentials:** (for UI access)
- **Username:** `admin` ( can be changed via  `GRAFANA_ADMIN_USER`  environment variable )
- **Password:** `admin` (can be changed via `GRAFANA_ADMIN_PASSWORD` environment variable)
- **URL:** http://localhost:3000

### PostgreSQL

**Default PostgreSQL Credentials:**
- **Username:** `postgres`
- **Password:** `S3cret` (can be changed via `POSTGRES_PASSWORD` environment variable)
- **Port:** 5432

**OpenMetadata Database User:**
- **Username:** `OPENMETADATA_DB_USER` (check `init-db.sql`)
- **Password:** `OPENMETADATA_DB_PASSWORD` (check `init-db.sql`)
- **Database:** `openmetadata_db`

**Airflow Database User:**
- **Username:** `AIRFLOW_DB_USER` (check `init-db.sql`)
- **Password:** `AIRFLOW_DB_PASSWORD` (check `init-db.sql`)
- **Database:** `airflow_db`

### MongoDB

**Default MongoDB Credentials:**
- **Username:** `admin`
- **Password:** `password` (can be changed via `MONGO_INITDB_ROOT_PASSWORD` environment variable)
- **Port:** 27017

### Redis

**Default Redis Password:**
- **Password:** `tLrrGkm6HoC7qUppXTeQkiBf` (can be changed via `REDIS_PASSWORD` environment variable)
- **Port:** 6379

### Portainer

**Initial Setup:** Create admin account on first access at https://localhost:9443

## 💾 Data Persistence Notes

### Kafka Data Persistence

**⚠️ Important:** By default, Kafka volumes are commented out in the `docker-compose.yml`. If data persistence is needed, follow these steps:

#### Issue with Default Volume Creation

When volumes are created automatically by Docker Compose, the root user becomes the owner, and changing UID permissions is challenging. Container startup can be delayed due to permission changes for all files.

#### Solution: Manual Volume Creation (One-time Activity)

**Step 1:** Create the Kafka volume manually

```powershell
docker volume create kafka_data
```

**Step 2:** Change ownership to Kafka user (UID 1000)

On **Linux/Mac**:
```bash
sudo chown -R 1000:1000 /var/lib/docker/volumes/kafka_data/_data
```

On **Windows** (using WSL2):
```powershell
wsl -e sudo chown -R 1000:1000 /var/lib/docker/volumes/kafka_data/_data
```

**Step 3:** Update `docker-compose.yml`

Uncomment and modify the Kafka service volume configuration:

```yaml
  kafka:
    image: apache/kafka:latest
    # ... other configurations ...
    volumes:
      - kafka_data:/tmp/kraft-combined-logs
    # ... rest of configuration ...

# At the bottom of the file, update volumes section:
volumes:
  # ... other volumes ...
  kafka_data:
    external: true  # This tells Docker to use the pre-created volume
```

**Step 4:** Restart Kafka service

```powershell
# Stop Kafka if running
docker compose stop kafka

# Start Kafka with new volume configuration
docker compose up -d kafka
```

**Expected Output:**
```
[+] Running 1/1
 ✔ Container kafka   Started
```

**Step 5:** Verify volume is mounted

```powershell
docker exec -it kafka ls -la /tmp/kraft-combined-logs
```

### Other Volume Configurations

All other services use named volumes that are automatically created and managed:

- `postgres_data` - PostgreSQL data
- `mongodb_data` - MongoDB data
- `redis_data` - Redis data
- `falkordb_data` - FalkorDB data
- `portainer_data` - Portainer configuration
- `prometheus_data` - Prometheus time-series data
- `grafana_data` - Grafana dashboards and settings
- `es-data` - Elasticsearch indices
- `ingestion-volume-dag-airflow` - Airflow DAG configurations
- `ingestion-volume-dags` - Airflow DAG definitions
- `ingestion-volume-tmp` - Airflow temporary files

### Backup Volumes

```powershell
# List all volumes
docker volume ls

# Backup a specific volume (example: postgres_data)
docker run --rm -v postgres_data:/data -v ${PWD}:/backup ubuntu tar czf /backup/postgres_backup.tar.gz /data

# Restore a volume
docker run --rm -v postgres_data:/data -v ${PWD}:/backup ubuntu tar xzf /backup/postgres_backup.tar.gz -C /
```

## 🌍 Environment Variables

You can customize the stack by creating a `.env` file in the same directory as `docker-compose.yml`:

```env
# =============================================================================
# UNIFIED ENVIRONMENT CONFIGURATION
# =============================================================================
# This file contains all environment variables for the unified Docker Compose setup
# Copy this file to .env and modify the values as needed
# =============================================================================

# -----------------------------------------------------------------------------
# PostgreSQL Configuration
# -----------------------------------------------------------------------------
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=S3cret
POSTGRES_DB=postgres

# -----------------------------------------------------------------------------
# MongoDB Configuration
# -----------------------------------------------------------------------------
MONGO_PORT=27017
MONGO_INITDB_ROOT_USERNAME=admin
MONGO_INITDB_ROOT_PASSWORD=password
MONGO_INITDB_DATABASE=test

# -----------------------------------------------------------------------------
# Redis Configuration
# -----------------------------------------------------------------------------
REDIS_PORT=6379
REDIS_PASSWORD=tLrrGkm6HoC7qUppXTeQkiBf

# -----------------------------------------------------------------------------
# Kafka Configuration
# -----------------------------------------------------------------------------
KAFKA_EXTERNAL_PORT=9092
KAFKA_INTERNAL_PORT=29092

# -----------------------------------------------------------------------------
# Debezium Configuration
# -----------------------------------------------------------------------------
DEBEZIUM_PORT=8083

# -----------------------------------------------------------------------------
# Cerbos Configuration
# -----------------------------------------------------------------------------
CERBOS_PORT=3592

# -----------------------------------------------------------------------------
# FalkorDB Configuration
# -----------------------------------------------------------------------------
FALKORDB_PORT=6380
FALKORDB_UI_PORT=3001

# -----------------------------------------------------------------------------
# Portainer Configuration
# -----------------------------------------------------------------------------
PORTAINER_HTTPS_PORT=9443
PORTAINER_EDGE_PORT=8000

# -----------------------------------------------------------------------------
# Monitoring Stack Configuration
# -----------------------------------------------------------------------------
# Prometheus
PROMETHEUS_PORT=9090

# Grafana
GRAFANA_PORT=3000
GRAFANA_ADMIN_USER=grafana_admin
GRAFANA_ADMIN_PASSWORD='m^Z2L3ZU875q'

# Node Exporter
NODE_EXPORTER_PORT=9100

# cAdvisor
CADVISOR_PORT=8081

# Openmetadata DB Connection onfiguration
AIRFLOW_DB_USER=airflow_admin
AIRFLOW_DB_PASSWORD='AIRF10w$Adm1n@2410'
OPENMETADATA_DB_USER=openmetadata_admin
OPENMETADATA_DB_PASSWORD='OPD$0un5ar@2410'
```

## 🔧 Troubleshooting

### Check Service Health

```powershell
docker compose ps
```

### View Service Logs

```powershell
# All services
docker compose logs -f

# Specific service
docker compose logs -f <service-name>
```

### Restart a Specific Service

```powershell
docker compose restart <service-name>
```

### Recreate a Service

```powershell
docker compose up -d --force-recreate <service-name>
```

### Remove All Containers and Volumes

```powershell
docker compose down -v
```

### Check Network Connectivity

```powershell
# Check if containers can communicate
docker exec -it kafka ping -c 3 postgres
```

## 📚 Additional Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [MongoDB Documentation](https://docs.mongodb.com/)
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [OpenMetadata Documentation](https://docs.open-metadata.org/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [OpenMetadata Admin credentials documentation](https://github.com/open-metadata/OpenMetadata/issues/15518)


**Note:** Always ensure you understand the security implications of the default passwords and change them in production environments and don't mix the UI credentials with its DB credentials.
For Openmetadata , if default db credentials should be changed, it should be updated in .env and in sql file 
