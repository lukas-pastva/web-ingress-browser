#!/bin/sh

TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CA_CERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
API_SERVER=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT

# Build jq filter based on environment variables
JQ_FILTER='[.items[]'

# Add namespace filter if FILTER_NAMESPACES is set (comma-separated list)
if [ -n "$FILTER_NAMESPACES" ]; then
    JQ_FILTER="$JQ_FILTER | select(.metadata.namespace as \$ns | \$namespaces | split(\",\") | index(\$ns))"
fi

# Add name pattern filter if FILTER_PATTERN is set
if [ -n "$FILTER_PATTERN" ]; then
    JQ_FILTER="$JQ_FILTER | select(.metadata.name | test(\$pattern))"
fi

JQ_FILTER="$JQ_FILTER | {name: .metadata.name, namespace: .metadata.namespace, host: .spec.rules[].host, path: (.spec.rules[].http.paths[]?.path // \"/\") | gsub(\"\\\\(\\.\\.\\*\\\\)\"; \"\")}]"

# Execute the query with appropriate arguments
curl -s --cacert $CA_CERT -H "Authorization: Bearer $TOKEN" $API_SERVER/apis/networking.k8s.io/v1/ingresses | \
    jq --arg pattern "${FILTER_PATTERN:-}" --arg namespaces "${FILTER_NAMESPACES:-}" "$JQ_FILTER" > /tmp/ingresses.json