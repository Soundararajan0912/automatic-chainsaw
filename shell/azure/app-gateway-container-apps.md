# Secure App Gateway + Azure Container Apps Routing Playbook

This guide captures the workflow for keeping Container Apps private inside a virtual network while exposing them through a single Azure Application Gateway (App Gateway) endpoint. It focuses on repeatable deployments, route updates, and operational timing. All CLI samples assume the Azure CLI is running from a Bash shell on Linux.

## 1. Network and security baseline

- **Private Container Apps:** Place the Azure Container Apps Environment (CAE) inside the same virtual network (or a peered one) as App Gateway. Disable public ingress so workloads stay private.
- **Controlled entry point:** Use App Gateway (ideally with WAF in prevention mode) as the only public ingress. Lock the gateway’s public IP to trusted CIDRs via NSGs or Azure Firewall.
- **TLS end-to-end:** Terminate HTTPS at App Gateway and re-encrypt to Container Apps when possible. Manage certificates via Key Vault and App Gateway listeners.

## 2. Service reachability

- Ensure App Gateway’s backend pool can resolve and reach each Container App’s internal endpoint (FQDN or private IP). For CAE, enable internal ingress and capture the internal hostname that Azure generates.
- If mutual TLS or custom headers are required, configure HTTP settings on the gateway with appropriate probes, host headers, and client cert options.

## 3. Declarative configuration workflow

A systematic deployment should treat Container Apps and App Gateway updates as a single change set:

1. **Update IaC definitions (Terraform/Bicep):**
   - Add the new Container App revision or service with its hostname/path expectations.
   - Extend App Gateway configuration with the listener, backend pool, HTTP setting, and request-routing rule pointing to the new app.
2. **CI/CD pipeline:**
   - Lint/test infrastructure code.
   - Deploy Container App changes first; wait for the revision to reach `Running`.
   - Apply the App Gateway changes so routing is published immediately after the app is healthy.
   - Run smoke tests through App Gateway to verify the route.
3. **Version control:** Store both Container App YAML and App Gateway IaC definitions in the same repo to keep them in sync, enable code reviews, and allow rollbacks.

## 4. Security guardrails

- **Network security groups (NSGs):** Limit ingress/egress between subnets to only what App Gateway and Container Apps require.
- **Identity and secrets:** Use managed identities or Key Vault references instead of embedding secrets in code. Keep Terraform service principals scoped to the target subscription/resource group.
- **Policy & monitoring:** Apply Azure Policy to enforce private ingress, ensure WAF stays enabled, and leverage Defender for Cloud alerts. Monitor App Gateway access logs and Container App diagnostics.

## 5. Operational timing expectations

- **Container Apps:** New revisions typically become `Running` within 1–2 minutes, depending on image size and startup logic.
- **App Gateway configuration changes:** Most listener/routing updates complete in **~1–3 minutes**. Large edits (WAF settings, certificate uploads) can take up to 5 minutes.
- **Health probes:** Traffic only flows after the backend probe reports `Healthy`. Always configure probes that match your app’s readiness behavior.
- **Post-change validation:** Run external smoke tests after each deployment to confirm DNS, certificates, and backend responses align with expectations.

## 6. Handling frequent additions

When new Container Apps are introduced regularly:

- Use templates or modules so every service receives a consistent backend pool, probe, and routing rule definition.
- Introduce automation (e.g., GitHub Actions, Azure Pipelines) that triggers whenever a new service definition merges to the main branch.
- Consider blue/green or canary patterns by pointing App Gateway routes to multiple backend pools and shifting weight gradually.

## 7. Without automation (not recommended)

Manual portal edits are possible but risky:

- Slower, prone to typos, and harder to audit.
- Easy to forget to remove old routes or align probe settings.
- Still subject to the same 1–3 minute propagation delay after every save.

Automating via Terraform/Bicep delivers predictable, secure updates and keeps App Gateway and Container Apps aligned as the platform scales.

## 8. Route update runbook

Once a new Container App revision is deployed and its private FQDN is known, use the following Azure CLI steps (Bash shell) to attach it to App Gateway:

```bash
rg="<resourceGroup>"
gw="<gatewayName>"
backendPool="<backendPoolName>"
httpSetting="<httpSettingName>"
probe="<probeName>"
listener="<listenerName>"
rule="<ruleName>"
containerAppFqdn="<new-app.internal.azurecontainerapps.io>"

# 1. Add backend target
az network application-gateway address-pool update \
   --resource-group "$rg" \
   --gateway-name "$gw" \
   --name "$backendPool" \
   --servers "$containerAppFqdn"

# 2. Probe (health check)
az network application-gateway probe update \
   --resource-group "$rg" \
   --gateway-name "$gw" \
   --name "$probe" \
   --protocol Https \
   --path /healthz \
   --host-name-from-http-settings true \
   --interval 30 --timeout 30 --unhealthy-threshold 3

# 3. HTTP settings
az network application-gateway http-settings update \
   --resource-group "$rg" \
   --gateway-name "$gw" \
   --name "$httpSetting" \
   --protocol Https \
   --port 443 \
   --host-name-from-backend-pool true \
   --pick-host-name-from-backend-address true \
   --probe "$probe"

# 4. Listener (if creating a dedicated hostname)
az network application-gateway http-listener update \
   --resource-group "$rg" \
   --gateway-name "$gw" \
   --name "$listener" \
   --frontend-port 443 \
   --frontend-ip appGatewayFrontendIP \
   --ssl-cert <certName> \
   --host-name <publicHostName>

# 5. Route rule (basic listener)
az network application-gateway rule update \
   --resource-group "$rg" \
   --gateway-name "$gw" \
   --name "$rule" \
   --http-listener "$listener" \
   --rule-type Basic \
   --address-pool "$backendPool" \
   --http-settings "$httpSetting"

# Path-based alternative
az network application-gateway url-path-map rule create \
   --resource-group "$rg" \
   --gateway-name "$gw" \
   --path-map-name <urlPathMapName> \
   --name <pathRuleName> \
   --paths /new-service/* \
   --address-pool "$backendPool" \
   --http-settings "$httpSetting"
```

Swap `update` for `create` when introducing new pools/listeners instead of modifying existing ones.

## 9. Verifying the new route & notifying dev teams

1. **Check backend health from Azure’s perspective**
    ```bash
    az network application-gateway backend-health show \
       --resource-group "$rg" \
       --name "$gw" \
       --address-pool "$backendPool" \
       --output json | jq '.'
    ```
    Ensure the new backend target transitions to `Healthy`. This usually takes 1–3 minutes after the route update completes.

2. **Run an end-to-end smoke test through App Gateway**
   ```bash
   curl https://<publicHostName>/new-service/healthz -k
   ```
    or trigger the service’s readiness endpoint/workflow test from your CI pipeline. Capture HTTP status, latency, and key headers.

3. **Monitor for a few minutes**
    - Run the Bash helper to automatically poll backend health, execute a smoke test, and capture key metrics:
       ```bash
       bash ./scripts/verify-app-gateway-route.sh \
          --resource-group "$rg" \
          --gateway-name "$gw" \
          --backend-pool "$backendPool" \
          --test-url "https://<publicHostName>/new-service/healthz"
       ```
    - The script waits (up to 4 minutes) for the backend to become `Healthy`, performs an HTTPS request, and prints the most recent `BackendHealthyHostCount` / `FailedRequests` values so you don’t have to check portals manually.
      - Optional: set up an Application Insights availability test pointed at the new path for continuous monitoring.

4. **Notify the development team**
    Share a short update in your release channel (e.g., Teams/Slack/email) including:
    - Container App name & revision ID.
    - App Gateway public hostname / path bound to it.
    - Timestamp when health checks turned green and smoke tests passed.
    - Any follow-up actions (e.g., DNS cutover, traffic ramp-up schedule).

Providing concrete verification details helps devs know the route is live and ready for functional validation.
