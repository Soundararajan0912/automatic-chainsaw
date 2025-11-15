## Kafka (Message Broker)

### Overview
Apache Kafka is a distributed event streaming platform used for building real-time data pipelines and streaming applications.

### Location
```
kafka/
└── docker-compose.yaml
```

### Commands

#### Start Kafka
```powershell
cd kafka
docker compose up -d
```

#### Stop Kafka
```powershell
docker compose down
```

### Verification Commands

#### List Topics
```powershell
docker exec -it <kafka-container-name> kafka-topics --list --bootstrap-server localhost:9092
```

#### Check Kafka Logs
```powershell
docker logs <kafka-container-name>
```

Example Container name : **broker**

#### Create a Kafka Topic
```powershell
docker exec -it broker /opt/kafka/bin/kafka-topics.sh --create --topic test-topic --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1
```

#### List All Kafka Topics
```powershell
docker exec -it broker /opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092
```
####  Describe a Kafka Topic
```powershell
docker exec -it broker /opt/kafka/bin/kafka-topics.sh --describe --topic test-topic --bootstrap-server localhost:9092
```

####  Produce Messages to a Kafka Topic
```powershell
docker exec -it broker /opt/kafka/bin/kafka-console-producer.sh --topic test-topic --bootstrap-server localhost:9092
```

####  Consume Messages from a Kafka Topic
```powershell
docker exec -it broker /opt/kafka/bin/kafka-console-consumer.sh --topic test-topic --bootstrap-server localhost:9092 --from-beginning
```
