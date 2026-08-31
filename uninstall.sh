#!/usr/bin/env bash

set -Eeuo pipefail

NAMESPACE="monitoring"
RELEASE_NAME="kube-prometheus-stack"

echo
echo "============================================================"
echo "🗑️  Monitoring Stack Uninstaller"
echo "============================================================"

echo
echo "⚠️  WARNING: This will uninstall the monitoring stack."

echo
read -r -p "⌨️  Type DELETE to continue: " CONFIRM

if [[ "$CONFIRM" != "DELETE" ]]; then
  echo
  echo "❌ Uninstall cancelled."
  exit 0
fi

echo
echo "🔍 Checking Helm release..."

if helm status "$RELEASE_NAME" -n "$NAMESPACE" >/dev/null 2>&1; then

  echo "🗑️  Removing monitoring stack..."

  helm uninstall \
    "$RELEASE_NAME" \
    --namespace "$NAMESPACE" \
    --wait

  echo
  echo "✅ Monitoring stack removed successfully."

else
  echo
  echo "ℹ️  Helm release '${RELEASE_NAME}' was not found."
fi

echo
echo "============================================================"
echo "🏁 Uninstall Process Completed"
echo "============================================================"

echo
echo "📦 Namespace '${NAMESPACE}' was intentionally kept."

echo
echo "🧹 To delete the namespace manually, run:"
echo

echo "kubectl delete namespace ${NAMESPACE}"