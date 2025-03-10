# k8-cost-optimizer
make start           # Starts Minikube
make prometheus      # Installs Prometheus & Grafana
make argocd          # Installs ArgoCD
make forward         # Port-forwards dashboards
make all             # Runs EVERYTHING (start + deploy + forward)
make stop            # Stops Minikube
make delete          # Deletes the entire Minikube cluster
make clean           # Deletes and cleans everything
