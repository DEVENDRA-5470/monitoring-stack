#!/usr/bin/env bash

set -Eeuo pipefail

NAMESPACE="monitoring"
RELEASE_NAME="kube-prometheus-stack"
CHART_NAME="prometheus-community/kube-prometheus-stack"
TIMEOUT="5m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALUES_FILE="${SCRIPT_DIR}/values.yaml"

header() {
  echo
  echo "============================================================"
  echo "🚀 $1"
  echo "============================================================"
}

ok() {
  echo "✅ SUCCESS: $1"
}

fail() {
  echo "❌ ERROR: $1"
  exit 1
}

info() {
  echo "ℹ️  $1"
}

header "Checking Required Tools 🛠️"

command -v kubectl >/dev/null 2>&1 || fail "kubectl is not installed."

ok "kubectl is installed"

if command -v helm >/dev/null 2>&1; then

  ok "Helm is already installed"

else

  info "Helm is not installed"
  info "Installing Helm..."

  command -v curl >/dev/null 2>&1 || fail "curl is required to install Helm automatically."

  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

  command -v helm >/dev/null 2>&1 || fail "Helm installation failed."

  ok "Helm installed successfully"

fi

header "Helm Version 🔍"

helm version

[[ -f "$VALUES_FILE" ]] || fail "values.yaml not found."

header "Checking Kubernetes Cluster Connection ☸️"

kubectl cluster-info >/dev/null 2>&1 || fail "Cannot connect to Kubernetes cluster."

ok "Kubernetes cluster connection successful"

header "Cluster Nodes 🖥️"

kubectl get nodes -o wide

header "Creating Monitoring Namespace 📦"

kubectl create namespace "$NAMESPACE" \
  --dry-run=client \
  -o yaml | kubectl apply -f -

ok "Namespace '${NAMESPACE}' is ready"

header "Adding Prometheus Helm Repository 📚"

helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts \
  --force-update

helm repo update

ok "Helm repository updated"

header "Installing Monitoring Stack 📊"

info "Installing Prometheus, Grafana and Alertmanager..."

helm upgrade \
  --install \
  "$RELEASE_NAME" \
  "$CHART_NAME" \
  --namespace "$NAMESPACE" \
  --values "$VALUES_FILE" \
  --wait \
  --timeout "$TIMEOUT"

ok "Monitoring stack installed successfully"

header "Monitoring Pod Status 🟢"

kubectl get pods -n "$NAMESPACE" -o wide

header "Monitoring Services 🌐"

kubectl get svc -n "$NAMESPACE"

NODE_PORT=$(
  kubectl get svc "${RELEASE_NAME}-grafana" \
    -n "$NAMESPACE" \
    -o jsonpath='{.spec.ports[0].nodePort}'
)

PUBLIC_IP=""

if command -v curl >/dev/null 2>&1; then

  info "Detecting public IP..."

  PUBLIC_IP=$(
    curl -fsS \
      --max-time 5 \
      https://api.ipify.org \
      2>/dev/null || true
  )

fi

header "Grafana Access 📈"

if [[ -n "$PUBLIC_IP" ]]; then

  echo "🌍 Grafana URL:"
  echo
  echo "http://${PUBLIC_IP}:${NODE_PORT}"

else

  echo "⚠️ Public IP could not be detected."
  echo
  echo "Use:"
  echo "http://YOUR_PUBLIC_IP:${NODE_PORT}"

fi

echo
echo "👤 Username:"
echo "admin"

echo
echo "🔐 Password command:"
echo

echo "kubectl get secret -n ${NAMESPACE} ${RELEASE_NAME}-grafana -o jsonpath=\"{.data.admin-password}\" | base64 -d ; echo"

echo

ok "Monitoring installation completed successfully 🎉"