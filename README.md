MONITORING STACK

Kubernetes monitoring stack for the HireFlow cluster.


COMPONENTS

- Prometheus
- Grafana
- Alertmanager
- kube-state-metrics
- node-exporter


REQUIREMENTS

- Kubernetes cluster
- kubectl configured
- Helm installed
- Cluster permissions
- Public firewall or NSG access to TCP port 30300


FILES

monitoring-stack/
├── README.txt
├── install.sh
├── uninstall.sh
└── values.yaml


HELM INSTALLATION

Check whether Helm is already installed:

helm version


If Helm is not installed, install Helm:

curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash


Verify Helm installation:

helm version


Expected output will look similar to:

version.BuildInfo{Version:"v3.x.x", ...}


KUBERNETES CLUSTER VERIFICATION

Verify that kubectl can communicate with the Kubernetes cluster:

kubectl get nodes


All required nodes should show:

STATUS
Ready


Verify the current Kubernetes context:

kubectl config current-context


INSTALLATION

Make the scripts executable:

chmod +x install.sh uninstall.sh


Run the installation:

./install.sh


VERIFY INSTALLATION

Check monitoring pods:

kubectl get pods -n monitoring -o wide


Check monitoring services:

kubectl get svc -n monitoring


Check the Helm release:

helm list -n monitoring


Check all monitoring pods:

kubectl get pods -n monitoring


Expected components include:

Prometheus
Grafana
Alertmanager
kube-state-metrics
node-exporter


GRAFANA ACCESS

Grafana is exposed using NodePort 30300.

Open:

http://YOUR_PUBLIC_IP:30300


USERNAME

admin


GET GRAFANA PASSWORD

kubectl get secret \
  -n monitoring \
  kube-prometheus-stack-grafana \
  -o jsonpath="{.data.admin-password}" | base64 -d


UNINSTALL

./uninstall.sh