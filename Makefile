# ==============================
#   K8s Cost Optimizer Makefile
# ==============================

# Variables
PROM_NS=monitoring
ARGO_NS=argocd

# ==============================
#   High-Level Commands
# ==============================
.PHONY: all start stop delete clean deploy forward prometheus argocd

all: start prometheus argocd forward
	@echo "✅ Full cluster environment is up and running!"

# ==============================
#   Cluster Commands
# ==============================
start:
	@echo "🚀 Starting Minikube..."
	minikube start --driver=docker --cpus=4
	@echo "✅ Minikube started."

stop:
	@echo "⏹️ Stopping Minikube..."
	minikube stop
	@echo "✅ Minikube stopped."

delete:
	@echo "🔥 Deleting Minikube cluster..."
	minikube delete
	@echo "✅ Cluster deleted."

# ==============================
#   Helm Deployments
# ==============================
prometheus:
	@echo "📦 Installing Prometheus & Grafana..."
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
	helm repo update
	kubectl create namespace $(PROM_NS) || true
	helm install prometheus prometheus-community/kube-prometheus-stack -n $(PROM_NS) --wait
	@echo "✅ Prometheus & Grafana installed."

argocd:
	@echo "📦 Installing ArgoCD..."
	kubectl create namespace $(ARGO_NS) || true
	kubectl apply -n $(ARGO_NS) -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	@echo "⏳ Waiting for ArgoCD Server to be ready..."
	kubectl rollout status deployment/argocd-server -n $(ARGO_NS)
	@echo "✅ ArgoCD installed."

# ==============================
#   Port Forwarding
# ==============================
forward:
	@echo "🚀 Port-forwarding dashboards..."
	-kubectl port-forward svc/prometheus-operated -n $(PROM_NS) 9090:9090 &
	-kubectl port-forward svc/prometheus-grafana -n $(PROM_NS) 3000:80 &
	-kubectl port-forward svc/argocd-server -n $(ARGO_NS) 8080:443 &
	@echo "➡️  Prometheus available at: http://localhost:9090"
	@echo "➡️  Grafana available at:    http://localhost:3000"
	@echo "➡️  ArgoCD available at:     https://localhost:8080"
	@echo "✅ Port forwarding set. Keeping session alive..."
	@wait

# ==============================
#   Clean Everything (Careful)
# ==============================
clean: delete
	@echo "🧹 Cleaned cluster and reset everything."
