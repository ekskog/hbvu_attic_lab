#!/bin/bash

# Temporal Deployment Script for k3s
set -e

echo "🚀 Starting Temporal deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl not found. Please install kubectl first.${NC}"
    exit 1
fi

# Function to wait for pods
wait_for_pods() {
    local namespace=$1
    local label=$2
    local timeout=${3:-300}
    
    echo -e "${YELLOW}⏳ Waiting for pods with label ${label} in namespace ${namespace}...${NC}"
    kubectl wait --for=condition=ready --timeout=${timeout}s pod -l ${label} -n ${namespace} 2>/dev/null || true
}

# Step 1: Create namespace
echo -e "${GREEN}📁 Creating namespace...${NC}"
kubectl apply -f 00-namespace.yaml

# Step 2: Create secrets
echo -e "${YELLOW}⚠️  Please ensure you've updated the PostgreSQL credentials in 01-postgres-secret.yaml${NC}"
read -p "Have you updated the credentials? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Please update credentials in 01-postgres-secret.yaml and run again${NC}"
    exit 1
fi

echo -e "${GREEN}🔐 Creating secrets...${NC}"
kubectl apply -f 01-postgres-secret.yaml

# Step 3: Create ConfigMap
echo -e "${GREEN}⚙️  Creating ConfigMap...${NC}"
kubectl apply -f 02-configmap.yaml

# Step 4: Run schema setup
echo -e "${GREEN}🗄️  Running PostgreSQL schema setup...${NC}"
kubectl apply -f 03-schema-setup-job.yaml

echo -e "${YELLOW}⏳ Waiting for schema setup to complete (this may take a few minutes)...${NC}"
kubectl wait --for=condition=complete --timeout=300s job/temporal-schema-setup -n temporal || {
    echo -e "${RED}❌ Schema setup job failed or timed out${NC}"
    echo "Check logs with: kubectl logs job/temporal-schema-setup -n temporal"
    exit 1
}

echo -e "${GREEN}✅ Schema setup completed successfully${NC}"

# Step 5: Deploy Temporal services
echo -e "${GREEN}🔧 Deploying Temporal services...${NC}"
kubectl apply -f 04-frontend.yaml
kubectl apply -f 05-history.yaml
kubectl apply -f 06-matching.yaml
kubectl apply -f 07-worker.yaml

echo -e "${YELLOW}⏳ Waiting for Temporal services to be ready...${NC}"
sleep 10
wait_for_pods "temporal" "component=frontend" 180
wait_for_pods "temporal" "component=history" 180
wait_for_pods "temporal" "component=matching" 180
wait_for_pods "temporal" "component=worker" 180

# Step 6: Deploy Web UI
echo -e "${GREEN}🌐 Deploying Temporal Web UI...${NC}"
kubectl apply -f 08-web-ui.yaml

wait_for_pods "temporal" "component=web" 120

# Summary
echo ""
echo -e "${GREEN}✅ Temporal deployment completed!${NC}"
echo ""
echo "📊 Deployment status:"
kubectl get pods -n temporal

echo ""
echo "🌐 To access the Web UI:"
echo "   kubectl port-forward -n temporal svc/temporal-web 8080:8080"
echo "   Then visit: http://localhost:8080"
echo ""
echo "🔌 To connect workers/clients:"
echo "   From cluster: temporal-frontend.temporal.svc.cluster.local:7233"
echo "   Port-forward: kubectl port-forward -n temporal svc/temporal-frontend 7233:7233"
echo ""
echo "📝 View logs:"
echo "   kubectl logs -n temporal -l app=temporal --tail=50"
echo ""
echo "🔍 Troubleshooting:"
echo "   kubectl describe pods -n temporal"
echo "   kubectl logs -n temporal <pod-name>"
