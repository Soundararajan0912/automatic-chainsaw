# Google Cloud Service Inventory

| Service | Usage in this solution |
|---------|------------------------|
| Google Kubernetes Engine (GKE) | Hosts the private tenant clusters (and optional management cluster) with CPU/GPU node pools and namespace isolation for each tenant workload. |
| Cloud Run | Optional control-plane runtime for the UI/API service, paired with a Serverless VPC Connector to reach the private cluster without managing servers. |
| Virtual Private Cloud (VPC) & Subnets | Dedicated network that houses the private GKE control plane, node pools, Cloud Build worker pool, and internal load balancers. |
| Cloud NAT | Provides controlled egress to the internet for private nodes/workers so they can pull container images and reach Google APIs without public IPs. |
| Cloud Build + Private Worker Pool | Executes build, test, and kubectl deployment stages from inside the same VPC, ensuring private connectivity to the tenant cluster. |
| Artifact Registry | Stores all workload and control-plane container images that are built by Cloud Build or GitHub Actions before deployment. |
| Application Gateway | Fronts the control-plane UI/API and optional shared services, handling HTTPS routing and integration with managed SSL certificates. |
| Managed SSL Certificates | Issues and renews TLS certificates for Application Gateway and HTTPS Load Balancers so traffic stays encrypted without manual rotation. |
| Cloud Monitoring & Logging (Cloud Operations) | Centralizes metrics, traces, and logs from GKE, Cloud Run, Cloud Build, and the worker pools; powers dashboards, SLOs, and alerts. |
| Secret Manager | Stores generated kubeconfigs, GitHub Action OIDC bindings, and other deployment secrets that the control plane and Cloud Build fetch at runtime. |
| Identity and Access Management (IAM) & IAM Credentials API | Enables short-lived impersonation tokens for the Infrastructure SA, Deployment SA, and Cloud Build service account, eliminating stored keys. |
| Cloud SQL (PostgreSQL) | Acts as the authoritative datastore for tenant environment requests, tracking ownership, build history, kubeconfig paths, and ILB endpoints. |
| Internal Load Balancing (GCLB) | Exposes tenant workloads on private IPs within the VPC so only authorized networks can consume each service. |
