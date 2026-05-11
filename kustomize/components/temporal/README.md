# Temporal Deployment on k3s with External PostgreSQL

This deployment sets up Temporal in your k3s cluster using your external PostgreSQL 16 instance.

## Prerequisites

1. **PostgreSQL Setup**: Create a user and set a password for Temporal in your PostgreSQL instance:

```bash
# Connect to your PostgreSQL instance
psql -h 192.168.1.8 -U postgres

# Create user
CREATE USER temporal WITH PASSWORD 'your_secure_password';

# Grant necessary privileges
ALTER USER temporal CREATEDB;
```

2. **Update Secrets**: Edit `01-postgres-secret.yaml` with your actual PostgreSQL credentials:
   - `POSTGRES_USER`: Your PostgreSQL username (default: temporal)
   - `POSTGRES_PASSWORD`: Your PostgreSQL password (CHANGE THIS!)

3. **Update ConfigMap** (optional): Edit `02-configmap.yaml` if you need to change any Temporal configuration settings.

## Deployment Order

Apply the manifests in the following order:

```bash
# 1. Create namespace
kubectl apply -f 00-namespace.yaml

# 2. Create PostgreSQL secret (make sure to update credentials first!)
kubectl apply -f 01-postgres-secret.yaml

# 3. Create config map
kubectl apply -f 02-configmap.yaml

# 4. Run schema setup job (this creates databases and tables)
kubectl apply -f 03-schema-setup-job.yaml

# Wait for the schema setup job to complete
kubectl wait --for=condition=complete --timeout=300s job/temporal-schema-setup -n temporal

# 5. Deploy Temporal services
kubectl apply -f 04-frontend.yaml
kubectl apply -f 05-history.yaml
kubectl apply -f 06-matching.yaml
kubectl apply -f 07-worker.yaml

# 6. Deploy Web UI
kubectl apply -f 08-web-ui.yaml
```

## Verification

Check that all pods are running:

```bash
kubectl get pods -n temporal
```

You should see all pods in `Running` state:
- temporal-frontend-xxx
- temporal-history-xxx
- temporal-matching-xxx
- temporal-worker-xxx
- temporal-web-xxx

Check the schema setup job completed successfully:

```bash
kubectl logs job/temporal-schema-setup -n temporal
```

## Accessing Temporal

### Web UI

To access the Temporal Web UI, you can:

1. **Port-forward** (for testing):
```bash
kubectl port-forward -n temporal svc/temporal-web 8080:8080
```
Then visit http://localhost:8080

2. **Create an Ingress** (for permanent access):
See `09-ingress-example.yaml` if you have an ingress controller

### gRPC Frontend

To connect your workers/clients to Temporal:

```bash
# From within the cluster
temporal-frontend.temporal.svc.cluster.local:7233

# From outside using port-forward
kubectl port-forward -n temporal svc/temporal-frontend 7233:7233
# Then connect to localhost:7233
```

## PostgreSQL Databases Created

The schema setup job creates two databases:
- `temporal`: Main database for workflow execution state
- `temporal_visibility`: Database for workflow visibility and search

## Troubleshooting

### Schema setup job fails

Check the logs:
```bash
kubectl logs job/temporal-schema-setup -n temporal -c create-databases
kubectl logs job/temporal-schema-setup -n temporal -c setup-schema
```

Common issues:
- PostgreSQL credentials incorrect
- PostgreSQL not accessible from cluster
- User lacks CREATEDB privilege

### Pods not starting

Check pod logs:
```bash
kubectl logs -n temporal <pod-name>
```

Check events:
```bash
kubectl describe pod -n temporal <pod-name>
```

### Can't connect to frontend

Verify the service is running:
```bash
kubectl get svc -n temporal temporal-frontend
```

Test connectivity from within a pod:
```bash
kubectl run -it --rm debug --image=busybox --restart=Never -n temporal -- sh
# Once inside:
telnet temporal-frontend 7233
```

## Scaling

To scale individual components:

```bash
kubectl scale deployment/temporal-frontend -n temporal --replicas=2
kubectl scale deployment/temporal-history -n temporal --replicas=2
kubectl scale deployment/temporal-matching -n temporal --replicas=2
kubectl scale deployment/temporal-worker -n temporal --replicas=2
```

## Configuration Notes

- **History Shards**: Set to 512 in config. For production, consider increasing based on load
- **Resource Limits**: Adjust CPU/memory limits in deployment YAMLs based on your cluster capacity
- **Replicas**: All services start with 1 replica. Scale based on your needs
- **Metrics**: Prometheus metrics exposed on port 9090 for each service

## Clean Up

To remove the entire Temporal deployment:

```bash
kubectl delete namespace temporal
```

Note: This will NOT delete the PostgreSQL databases. To clean those up:

```sql
DROP DATABASE temporal;
DROP DATABASE temporal_visibility;
```
