## Monitoring Stack (Prometheus , Grafana, Node exporter , Cadvisor)

### Overview
Complete monitoring solution with Prometheus for metrics collection and Grafana for visualization.

### Location
```
monitoring/
├── docker-compose.yml
├── prometheus.yml
└── grafana/
    └── provisioning/
```

### Configuration Details
- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization dashboards (Empty folders )
- **Datasources and dashboards**: Should be configured manually after the setup is done

### Commands

#### Start Monitoring Stack
```powershell
cd monitoring
docker-compose up -d
```

#### Stop Monitoring Stack
```powershell
docker-compose down
```

### Verification Commands

#### Access Prometheus UI
Open browser: `http://localhost:9090`

**Expected Output**: Prometheus dashboard

#### Access Grafana UI
Open browser: `http://localhost:3000`

**Default Credentials**: admin/admin (change on first login)

#### Check Prometheus Targets
```powershell
curl http://localhost:9090/api/v1/targets
```

#### Test Prometheus Query
```powershell
curl http://localhost:9090/api/v1/query?query=up
```

### Grafana Dashboards to be imported after Prometheus datasource is configured in UI
**Node monitoring**: dashbord id `1860`

**Cadvisor** : dashbord id `19792`
