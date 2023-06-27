## HA control nodes  
Set up ENVs  
``` bash
export K3S_DATASTORE_ENDPOINT='mysql://lucarv:lucaPWD4ma4iaDB@tcp(pifour:3306)/' 
export K3S_KUBECONFIG_MODE="644" 
export K3S_TOKEN=SzNTX0FUVElDX0NMVVNURVI= 
```
Download the executables and set some flags  
``` bash
curl -sfL https://get.k3s.io | sh -s - server -tls-san pifour --tls-san 192.168.1.11 --disable traefik --disable servicelb --node-taint CriticalAddonsOnly=true:NoExecute 
```
  
Get the token to use on the agents:  
``` bash
sudo cat /var/lib/rancher/k3s/server/node-token 
```  
  
Check the daemon is running:  
``` bash
systemctl status k3s-agent --no-pager --full  
kubectl get pods all-nonespaces  
```
 
### Uninstall 
``` bash
cd /opt/bin && ./k3s-uninstall.sh 
```
  
  
## HA worker nodes  
Set up ENVs  
``` bash
export K3S_TOKEN=K10cd5fc2e15fe1cc72d1655af2b35fcdeebc34f174a4cc5d196440d399958b7c8d::server:SzNTX0FUVElDX0NMVVNURVI= 
export K3S_URL=https://192.168.1.11:6443 
export K3S_KUBECONFIG_MODE="644" 
``` 
  
Download the executables   
``` bash
curl -sfL https://get.k3s.io | sh -s -   
``` 
  
### Uninstall 
``` bash
cd /opt/bin && ./k3s-agent-uninstall.sh 
```




Copy /etc/rancher/k3s/k3s.yaml onto developer's machine  
export KUBECONFIG=~/.kube/config  
