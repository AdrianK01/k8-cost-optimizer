# ==============================
#   K8s Cost Optimizer Makefile
# ==============================

# Variables
PROM_NS=monitoring
ARGO_NS=argocd
APP=application
# ==============================
#   High-Level Commands
# ==============================
.PHONY: all start stop delete clean deploy forward prometheus argocd nginx kill-forwards

all: start prometheus argocd nginx forward
	@echo "Full cluster environment is up and running!"

# ==============================
#   Cluster Commands
# ==============================
start:
	@echo "Starting Minikube..."
	minikube start --cpus=4
	@echo "Minikube started."

stop:
	@echo "Stopping Minikube..."
	minikube stop
	@echo "Minikube stopped."

delete:
	@echo "Deleting Minikube cluster..."
	minikube delete
	@echo "Cluster deleted."

# ==============================
#   Helm Deployments
# ==============================
prometheus:
	@echo "Installing Prometheus & Grafana..."
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
	helm repo update
	kubectl create namespace $(PROM_NS) || true
	helm install prometheus prometheus-community/kube-prometheus-stack -n $(PROM_NS) --wait
	@echo "Prometheus & Grafana installed."

argocd:
	@echo "Installing ArgoCD..."
	kubectl create namespace $(ARGO_NS) || true
	kubectl apply -n $(ARGO_NS) -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	@echo "Waiting for ArgoCD Server to be ready..."
	kubectl rollout status deployment/argocd-server -n $(ARGO_NS)
	@echo "ArgoCD installed."

nginx:
	@echo "Deploying Nginx..."
	kubectl create namespace $(APP) || true
	kubectl create deployment nginx --image=nginx --namespace=$(APP) || true
	kubectl expose deployment nginx --port=80 --target-port=80 --type=NodePort --namespace=$(NGINX_NS) || true
	@echo "Deployed Nginx."
# ==============================
#   Port Forwarding
# ==============================
forward:
	@echo "Port-forwarding dashboards..."
	-kubectl port-forward svc/prometheus-operated -n $(PROM_NS) 9090:9090 &
	-kubectl port-forward svc/prometheus-grafana -n $(PROM_NS) 3000:80 &
	-kubectl port-forward svc/argocd-server -n $(ARGO_NS) 8080:443 &
	-kubectl port-forward deployment/nginx -n $(APP) 9080:80 &
	@echo "Prometheus available at: http://localhost:9090"
	@echo "Grafana available at:    http://localhost:3000"
	@echo "ArgoCD available at:     https://localhost:8080"
	@echo "Nginx available at:     http://localhost:9080"
	@echo "Port forwarding set. Keeping session alive..."
	@wait

kill-forwards:
	@echo "Killing forwarding processes"
	@pkill -f "kubectl port-forward" || true
	@echo "Killed port forwarding"