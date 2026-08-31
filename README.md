# Monitoring Stack

Kubernetes monitoring stack for the HireFlow cluster.

## Components

- Prometheus
- Grafana
- Alertmanager
- kube-state-metrics
- node-exporter

## Requirements

- Kubernetes cluster
- kubectl configured
- Helm installed
- Cluster permissions
- Public firewall or NSG access to TCP port 30300

## Files

```text
monitoring-stack/
├── README.md
├── install.sh
├── uninstall.sh
└── values.yaml
```

## Install

```bash
chmod +x install.sh uninstall.sh
./install.sh
```

## Verify

```bash
kubectl get pods -n monitoring -o wide
kubectl get svc -n monitoring
helm list -n monitoring
```

## Grafana

```text
http://YOUR_PUBLIC_IP:30300
```

Username:

```text
admin
```

Password:

```bash
kubectl get secret   -n monitoring   kube-prometheus-stack-grafana   -o jsonpath="{.data.admin-password}" | base64 -d
```

## Uninstall

```bash
./uninstall.sh
```
