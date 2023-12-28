## Changes on the Front End  

### NGINX PROXY  
    
As I intended to deploy a HA configuration to my cluster, I need to change the configuration of my proxy to stream the k8s control plane traffic. The new nginx.conf is like below:  
  
```
load_module  /usr/lib/nginx/modules/ngx_stream_module.so;
events {}
stream {
  log_format basic '$remote_addr [$time_local]'
                   '$protocol $status $bytes_sent $bytes_received '
                   '$session_time';

  upstream k3s_servers {
    server k3sm-flb:6443;
    server k3sm-hpp:6443;
  }

  server {
    access_log /var/log/nginx/nginx-kube.log basic;
    listen 6443;
    proxy_pass k3s_servers;
  }
}

http {
  log_format compression '$remote_addr - $remote_user [$time_local] '
                         '"$request" $status $body_bytes_sent '
                         '"$http_referer" "$http_user_agent" "$gzip_ratio"';
  include /etc/nginx/conf.d/*.conf;
}  
```

### MARIA DB  
  
I created a DB to store the HA stuff needed by k3s...  

``` bash
sudo mysql -u lucarv -p
    MariaDB [(none)]> create database k3s_ha_db;

(edit to allow remote connections)  
$ sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf 
$ sudo service mysql restart    
``` 

## Set up k3s


### HA control nodes  
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
  
1.5. If anything went wrong it would be good to uninstall 
``` bash
cd /opt/bin && ./k3s-uninstall.sh 
```
  
  
### HA worker nodes  
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
  
2.3. If anything went wrong it would be good to uninstall 
``` bash
cd /opt/bin && ./k3s-agent-uninstall.sh 
```