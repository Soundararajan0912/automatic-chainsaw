## Portainer (Container Management)

### Overview
Portainer provides a web-based UI for managing Docker containers, images, networks, and volumes.

### Location
```
portainer/
└── docker-compose.yaml
```

### Commands

#### Start Portainer
```powershell
cd portainer
docker-compose up -d
```

#### Stop Portainer
```powershell
docker-compose down
```

### Verification Commands

#### Access Portainer UI
Open browser: `http://localhost:9000`

For production environment(secure) : `https://localhost:9443`

**Expected Output**: Portainer signup page

#### Check Portainer Container
```powershell
docker ps | findstr portainer
or
docker ps | grep portainer
```
### Important note:
Portainer is not yet compatible with `Docker 28/29` because of breaking changes introduced in these versions.
Due to this , you may face : `Failed loading environment The environment named local is unreachable. `

**Refernce links**:

https://docs.portainer.io/start/requirements-and-prerequisites

https://github.com/orgs/portainer/discussions/12926
