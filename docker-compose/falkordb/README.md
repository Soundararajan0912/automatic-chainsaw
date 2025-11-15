## FalkorDB (Graph Database)

### Overview
FalkorDB is a graph database for storing and querying connected data using graph structures.

### Location
```
falkordb/
└── docker-compose.yaml
```

### Commands

#### Start FalkorDb
```powershell
cd falkordb
docker compose  up -d
```

#### Stop FalkorDb
```powershell
docker compose down
```

## Common Docker Commands
### View All Running Containers
```powershell
docker ps
```

### View All Containers (including stopped)
```powershell
docker ps -a
```

### View Container Logs
```powershell
docker logs <container-name>
docker logs -f <container-name>  # Follow logs in real-time
```

### View Container Resource Usage
```powershell
docker stats
```

### Remove All Stopped Containers
```powershell
docker container prune
```

### Remove Unused Images
```powershell
docker image prune -a
```

### Remove Unused Volumes
```powershell
docker volume prune
```
### FalkorDB UI and Integration
After completing the above setup, open your browser and navigate to:

`http://<server-ip>:3001`
This will open the Falkor database UI.

To integrate FalkorDB with Redis, provide the Redis connection details (host, port, authentication) within the FalkorDB UI or its configuration settings. This allows FalkorDB to use Redis as its backend data store.
