## HA control nodes  
1.1 Set up ENVs  
``` bash
export K3S_DATASTORE_ENDPOINT='mysql://lucarv:lucaPWD4ma4iaDB@tcp(pifour:3306)/' 
export K3S_KUBECONFIG_MODE="644" 
export K3S_TOKEN=SzNTX0FUVElDX0NMVVNURVI= 
```  
  
1.2. Download the executables and set some flags  
``` bash
curl -sfL https://get.k3s.io | sh -s - server -tls-san pifour --tls-san 192.168.1.11 --disable traefik --disable servicelb --node-taint CriticalAddonsOnly=true:NoExecute 
```  
    
1.3. Get the token to use on the agents:  
``` bash
sudo cat /var/lib/rancher/k3s/server/node-token
```  
Copy /etc/rancher/k3s/k3s.yaml onto developer's machine  
``` bash
export KUBECONFIG=~/.kube/config  
```  
  
1.4. Check the daemon is running:  
``` bash
systemctl status k3s-agent --no-pager --full  
kubectl get pods all-nonespaces  
```  
  
### Uninstall 
``` bash
cd /opt/bin && ./k3s-uninstall.sh 
```
  
  
## HA worker nodes  
2.1. Set up ENVs  
``` bash
export K3S_TOKEN=<FROM 1.3 ABOVE>
export K3S_URL=https://<THE IP WHERE THE DATASTORE IS>:6443 
export K3S_KUBECONFIG_MODE="644" 
```  
  
2.2. Download the executables   
``` bash
curl -sfL https://get.k3s.io | sh -s -   
```  
  
### Uninstall 
``` bash
cd /opt/bin && ./k3s-agent-uninstall.sh 
```