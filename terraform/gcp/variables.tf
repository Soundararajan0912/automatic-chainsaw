variable "project_id" {
  description = "GCP project where all resources will be created."
  type        = string
}

variable "region" {
  description = "Default region for regional resources."
  type        = string
  default     = "us-central1"
}

variable "vpc_name" {
  description = "Name for the dedicated VPC network."
  type        = string
  default     = "gke-private-vpc"
}

variable "subnet_name" {
  description = "Name for the primary subnet that hosts the cluster nodes."
  type        = string
  default     = "gke-nodes-subnet"
}

variable "subnet_cidr" {
  description = "Primary IPv4 range for the node subnet (must fit within 256 IPs /24)."
  type        = string
  default     = "10.0.0.0/24"
}

variable "pods_secondary_range_name" {
  description = "Name for the secondary range dedicated to Pods."
  type        = string
  default     = "gke-pods"
}

variable "pods_secondary_range_cidr" {
  description = "CIDR block for the Pod secondary range."
  type        = string
  default     = "10.2.0.0/16"
}

variable "services_secondary_range_name" {
  description = "Name for the secondary range dedicated to cluster Services."
  type        = string
  default     = "gke-services"
}

variable "services_secondary_range_cidr" {
  description = "CIDR block for the Services secondary range."
  type        = string
  default     = "10.3.0.0/20"
}

variable "cluster_name" {
  description = "GKE cluster name."
  type        = string
  default     = "private-gke-cluster"
}

variable "gke_version" {
  description = "GKE master/node version to pin."
  type        = string
  default     = "1.29.4-gke.1043000"
}

variable "release_channel" {
  description = "GKE release channel to use."
  type        = string
  default     = "REGULAR"
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for the private control plane endpoints."
  type        = string
  default     = "172.16.0.16/28"
}

variable "artifact_registry_location" {
  description = "Region where the Artifact Registry repository will be created."
  type        = string
  default     = "us-central1"
}

variable "artifact_registry_repository" {
  description = "Repository ID for Artifact Registry (Docker format)."
  type        = string
  default     = "tenant-images"
}

variable "nat_log_filter" {
  description = "Filter for Cloud NAT logging (ALL, ERRORS_ONLY, TRANSLATIONS_ONLY)."
  type        = string
  default     = "ERRORS_ONLY"
}

variable "cpu_node_pool" {
  description = "Shape and autoscaling settings for the CPU oriented node pool."
  type = object({
    name         = string
    machine_type = string
    disk_size_gb = number
    disk_type    = string
    min_count    = number
    max_count    = number
    tags         = optional(list(string), [])
    node_labels  = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  })
  default = {
    name         = "cpu-e2-pool"
    machine_type = "e2-standard-4"
    disk_size_gb = 100
    disk_type    = "pd-ssd"
    min_count    = 1
    max_count    = 2
    tags         = []
    node_labels  = { pool = "cpu" }
    taints       = []
  }
}

variable "gpu_node_pool" {
  description = "Shape and autoscaling settings for the GPU oriented node pool."
  type = object({
    name               = string
    machine_type       = string
    disk_size_gb       = number
    disk_type          = string
    min_count          = number
    max_count          = number
    accelerator_type   = string
    accelerator_count  = number
    tags               = optional(list(string), [])
    node_labels        = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  })
  default = {
    name              = "gpu-pool"
    machine_type      = "n1-standard-8"
    disk_size_gb      = 50
    disk_type         = "pd-ssd"
    min_count         = 1
    max_count         = 2
    accelerator_type  = "nvidia-tesla-t4"
    accelerator_count = 1
    tags              = []
    node_labels       = { pool = "gpu" }
    taints = [{
      key    = "workload"
      value  = "gpu"
      effect = "NO_SCHEDULE"
    }]
  }
}

variable "kubeconfig_path" {
  description = "Optional override for where the generated kubeconfig should be written. Defaults to <module>/kubeconfig-<cluster>.yaml when empty."
  type        = string
  default     = ""
}

variable "cloud_build_worker_pool" {
  description = "Optional overrides for the private Cloud Build worker pool that performs builds and kubectl deployments."
  type = object({
    name           = optional(string)
    location       = optional(string)
    machine_type   = optional(string)
    disk_size_gb   = optional(number)
    no_external_ip = optional(bool)
  })
  default = {}
}
