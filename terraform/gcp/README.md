# Private GKE Cluster on Custom VPC

This Terraform configuration builds a fully private GKE cluster inside a dedicated VPC, attaches Cloud NAT for outbound-only egress, and provisions two autoscaled node pools (CPU and GPU). Horizontal Pod Autoscaling/metrics-server is enabled via the cluster add-on.

## Layout

- `versions.tf` – Terraform + provider constraints.
- `providers.tf` – Google provider configuration.
- `services.tf` – Enables required Google APIs.
- `main.tf` – Network, router/NAT, Artifact Registry, GKE control plane, node pools.
- `variables.tf` – All tunable inputs (region, ranges, node pool shapes, cluster version, etc.).
- `outputs.tf` – Helpful references after apply.
- `terraform.tfvars.example` – Sample values to copy into your own `terraform.tfvars`.

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and adjust at minimum `project_id`, `gke_version`, ranges, and node pool details if needed.
2. Authenticate: `gcloud auth application-default login` (or use a service account with the necessary IAM roles).
3. Initialize and review the plan:
   ```powershell
   terraform init
   terraform plan
   ```
4. Apply: `terraform apply`.

The cluster endpoint is private (`enable_private_endpoint = true`), so it is reachable only from hosts with routes to the VPC (for example, a bastion VM inside the subnet or Cloud Shell that has been connected to that VPC via a private Cloud Shell environment).

## Connecting to the cluster

1. From a VM/bastion inside the VPC subnet (or through Cloud Shell with a Cloud Router-connected private workspace), ensure the Google Cloud SDK is authenticated with the same project.
2. Fetch cluster credentials:
   ```bash
   gcloud container clusters get-credentials <cluster_name> --region <region> --project <project_id>
   ```
   This command uses the private control plane endpoint, so it works only from inside the VPC.
3. Use `kubectl` as usual (`kubectl get nodes`, deploy workloads, etc.).

Because NAT is configured, nodes reach Google APIs/Artifact Registry without exposing public IP addresses, keeping the control plane and nodes entirely private.

## Network ranges

- **Primary subnet (`subnet_cidr`)** – Defaults to `10.0.0.0/24`, limiting the node CIDR to 256 IPs as requested while keeping the VPC custom-mode so you can add more subnets later if needed.
- **Secondary Pod range (`pods_secondary_range_cidr`)** – Defaults to `10.2.0.0/16`. This secondary IP range belongs to the same subnet but is used exclusively for Pod IPs via GKE’s VPC-native mode.
- **Secondary Service range (`services_secondary_range_cidr`)** – Defaults to `10.3.0.0/20` for cluster Service IPs.
- **Master IPv4 CIDR (`master_ipv4_cidr_block`)** – Defaults to `172.16.0.16/28`, reserving 16 internal IPs for the private control-plane endpoint. This block must not overlap with the primary or secondary ranges, ensuring the masters stay reachable only from within the VPC.

## Artifact Registry

Terraform also provisions a regional Artifact Registry repository (Docker format) defined by:

- `artifact_registry_location` – defaults to `us-central1`.
- `artifact_registry_repository` – defaults to `tenant-images`.

Use the `artifact_registry_repository` output to retrieve the repo name/region when configuring Cloud Build or other CI jobs to push tenant images.

## Node pool scheduling

- CPU nodes inherit the labels defined in `cpu_node_pool.node_labels` (defaults to `{ pool = "cpu" }`).
- GPU nodes inherit both labels and taints from `gpu_node_pool` (defaults: label `{ pool = "gpu" }`, taint `workload=gpu:NoSchedule`).

When deploying workloads that require GPUs, set a matching `nodeSelector`/`nodeAffinity` (`pool: gpu`) **and** add a toleration for the taint so pods schedule only on the GPU pool. Non-GPU workloads can target the CPU pool without tolerations.

## Generated kubeconfig

The configuration now renders a kubeconfig locally via the `local_file` resource. By default it lands at `<repo>/kubeconfig-<cluster>.yaml` (see the `kubeconfig_file_path` output), and you can override the destination with `kubeconfig_path` in `terraform.tfvars`. The kubeconfig embeds:

- the private control-plane endpoint,
- the CA bundle from `master_auth`, and
- the OAuth token from your current `gcloud` credentials.

Tokens issued this way expire quickly (about one hour). Re-run `terraform apply` or regenerate credentials when needed, or simply use `gcloud container clusters get-credentials` if you prefer the standard workflow.
