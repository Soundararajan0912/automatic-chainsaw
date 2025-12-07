#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: verify-app-gateway-route.sh \
  --resource-group <name> \
  --gateway-name <name> \
  --backend-pool <name> \
  --test-url <https://host/path> \
  [--expected-status 200] \
  [--max-wait 240] \
  [--poll-interval 15]
EOF
}

# Defaults
EXPECTED_STATUS=200
MAX_WAIT=240
POLL_INTERVAL=15

while [[ $# -gt 0 ]]; do
  case "$1" in
    --resource-group)
      RESOURCE_GROUP="$2"; shift 2 ;;
    --gateway-name)
      GATEWAY_NAME="$2"; shift 2 ;;
    --backend-pool)
      BACKEND_POOL="$2"; shift 2 ;;
    --test-url)
      TEST_URL="$2"; shift 2 ;;
    --expected-status)
      EXPECTED_STATUS="$2"; shift 2 ;;
    --max-wait)
      MAX_WAIT="$2"; shift 2 ;;
    --poll-interval)
      POLL_INTERVAL="$2"; shift 2 ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1 ;;
  esac
done

if [[ -z "${RESOURCE_GROUP:-}" || -z "${GATEWAY_NAME:-}" || -z "${BACKEND_POOL:-}" || -z "${TEST_URL:-}" ]]; then
  echo "Missing required arguments." >&2
  usage
  exit 1
fi

echo "[+] Verifying Azure CLI context..."
az account show >/dev/null

echo "[+] Polling backend pool '$BACKEND_POOL' health..."
end_time=$(( $(date +%s) + MAX_WAIT ))
backend_ok=false

while [[ $(date +%s) -lt $end_time ]]; do
  states=$(az network application-gateway backend-health show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$GATEWAY_NAME" \
    --query "backendAddressPools[?backendPool.name=='$BACKEND_POOL'].backendHttpSettingsCollection[].servers[].health" \
    -o tsv)

  if [[ -z "$states" ]]; then
    echo "    Waiting for backend instances to register..."
  else
    unhealthy=$(echo "$states" | grep -v "Healthy" || true)
    if [[ -z "$unhealthy" ]]; then
      backend_ok=true
      break
    else
      echo "    Current states: $states"
    fi
  fi
  sleep "$POLL_INTERVAL"
done

if [[ "$backend_ok" != true ]]; then
  echo "Backend pool '$BACKEND_POOL' did not become Healthy within $MAX_WAIT seconds." >&2
  exit 2
fi

echo "[+] Backend healthy. Running smoke test against $TEST_URL ..."
status=$(curl -sk -o /dev/null -w "%{http_code}" "$TEST_URL") || true

if [[ "$status" != "$EXPECTED_STATUS" ]]; then
  echo "Smoke test returned HTTP $status (expected $EXPECTED_STATUS)." >&2
  exit 3
fi

echo "[+] Smoke test succeeded with HTTP $status."

start_iso=$(date -u -d "-5 minutes" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -v-5M +"%Y-%m-%dT%H:%M:%SZ")
end_iso=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "[+] Sampling Azure Monitor metrics (BackendHealthyHostCount, FailedRequests)..."
az monitor metrics list \
  --resource $(az network application-gateway show --resource-group "$RESOURCE_GROUP" --name "$GATEWAY_NAME" --query id -o tsv) \
  --metrics BackendHealthyHostCount FailedRequests \
  --aggregation Average \
  --interval PT1M \
  --timespan "$start_iso/$end_iso" \
  --query "value[].{metric:name.value,latest:timeseries[0].data[-1].average}" -o tsv || true

echo "[+] Route verification complete. You can safely notify the dev team."
