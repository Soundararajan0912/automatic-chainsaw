# Exposing a Private Grafana Service Through Azure Application Gateway

This guide documents how to publish an internal service (Ex: Grafana) instance (listening on port `3000`) through an Azure Application Gateway listener, backend setting, and routing rule.

## 1. Prerequisites

1. **Grafana service is healthy inside the private network.**
   - SSH into the server and verify the process is listening on port `3000`.
   - Run the quick checks below and confirm you receive HTTP 200/302 responses (or Grafana HTML):
     ```bash
     curl http://localhost:3000
     curl http://<internal-ip>:3000
     ```
   - If either command fails, fix the service or firewall before exposing it.
2. **Application Gateway Standard_v2 or WAF_v2** already deployed with:
   - At least one **public frontend IP configuration**.
   - A **backend pool** containing the private server (or a NIC/IP configuration you can add to one now).
3. **Appropriate NSG/Firewall rules** allowing the App Gateway subnet to reach the server on TCP/3000.

> ⚠️ **Port uniqueness:** Azure Application Gateway cannot host two listeners on the same frontend IP/port combination. Ensure port `3000` is not already used by another listener.

## 2. Create (or confirm) a backend pool entry

If the private Grafana VM is not already part of a backend pool:

1. In the Application Gateway blade, select **Backend pools** & **Add**.
2. Provide a descriptive name, e.g., `grafana-backendpool`.
3. Add targets (IP address, NIC, or VM scale set) that point to the Grafana host.
4. Save the backend pool.

## 3. Add a listener on port 3000

1. Navigate to **Listeners** &  **Add listener**.
2. Configure the listener:
   - **Name:** `grafana-http-3000` (or any meaningful name).
   - **Frontend IP:** Select the public frontend IP that should expose Grafana.
   - **Protocol:** `HTTP` (Grafana defaults to HTTP on port 3000; switch to HTTPS if you terminate TLS at the gateway).
   - **Port:** `3000`.
   - **Listener type:** `Basic`.
3. Click **Add**. If you receive an error about port reuse, pick a different port or remove the conflicting listener.

## 4. Create backend settings for Grafana

1. In the Application Gateway blade, go to **Backend settings** &  **Add**.
2. Provide details:
   - **Name:** `grafana-http-settings`.
   - **Backend protocol:** `HTTP`.
   - Leave the remaining options (backend port, timeout, cookie-based affinity, paths) at their defaults unless Grafana requires custom behavior.
3. Save the backend settings.

## 5. Create a routing rule linking listener and backend

1. Open **Rules** & **Add routing rule**.
2. **Basics tab:**
   - **Rule name:** `route-grafana-3000`.
   - **Priority:** Choose an unused integer (e.g., `200`). Lower numbers have higher priority.
   - **Listener:** Select `grafana-http-3000`.
3. **Backend targets tab:**
   - **Target type:** `Backend pool`.
   - **Backend target:** Pick the pool that points to the Grafana server (e.g., `grafana-backendpool`).
   - **HTTP settings:** Choose `grafana-http-settings`.
4. Click **Add** to create the rule.

## 6. Validate the exposure

1. Wait for the Application Gateway configuration to finish updating (typically 300 seconds).
2. From an external client, browse to `http://<app-gw-public-ip>:3000` (or the DNS name mapped to it).
3. Confirm you receive the Grafana login screen.
4. Monitor **Backend health** in the Application Gateway blade to ensure probes show `Healthy` for the backend instance.

## 7. Troubleshooting tips

| Symptom | Possible cause | Fix |
| --- | --- | --- |
| Backend health shows `Unknown`/`Unhealthy` | Grafana not listening on port 3000 or blocked by NSG | Re-run `curl` tests locally; adjust NSG/firewall to allow TCP/3000 from App Gateway subnet |
| `Port already in use` error when creating listener | Another listener uses the same frontend IP+port | Delete/modify the existing listener or choose a new port |
| 502 Bad Gateway | Backend HTTP settings mismatch (protocol/port) | Ensure settings use HTTP/3000 unless SSL offload is required |
| External clients timeout | DNS/Public IP misconfiguration | Confirm listener references the correct frontend IP and DNS is updated |

Following these steps exposes the private Grafana service securely through Azure Application Gateway while keeping the workload inside the VNet.
