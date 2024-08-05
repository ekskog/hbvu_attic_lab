# Install Flux on cluster  
  
$ flux install  
  
  
# Create Git Source  
  
Create a file named git-source.yaml with the following content:  
```text  
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: GitRepository
metadata:
  name: hbvu-attic-lab
  namespace: flux-system
spec:
  interval: 1m
  url: https://github.com/thisistayo/hbvu_attic_lab
  ref:
    branch: main
```  
  
$ kubectl apply -f git-source.yaml  
  
# Create Kustomization Resource (for each resource):  
```text  
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: xtr-app
  namespace: flux-system
spec:
  interval: 5m
  path: ./kustomize/apps/xtr
  prune: true
  sourceRef:
    kind: GitRepository
    name: hbvu-attic-lab
```      
  
kubectl apply -f kustomization.yaml  

# Monitor resources  
  
flux get kustomizations --watch  
