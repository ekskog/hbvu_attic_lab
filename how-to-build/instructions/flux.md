# INSTALLATION AND CONFIGURATION  
  
Install the flux cli on the dev machine:    
``` bash
$ curl -s https://fluxcd.io/install.sh | sudo bash
```  
  
Head to github and create a repo to store the flux artifacts. Get a personal token too.  
``` bash    
$ k create ns flux-system  
$ export GITHUB_TOKEN=<YOUR GITHUB TOKEN>  
$ export GITHUB_USER=<YOUR GITHUB USERNAME>  
$ export GITHUB_REPO=<YOUR REPO>   
```  
  
Bootstrap flux:  
  
``` bash    
$ flux bootstrap github --owner=${GITHUB_USER} --repository=${GITHUB_REPO} --branch=main --personal=true --path=clusters/attic 
...  
...  
✔ all components are healthy  
```   

Clone the repo to your dev machine:  
   ``` bash   
git clone https://github.com/${GITHUB_USER}/${GITHUB_REPO}
cd <GITHUB_REPO>
git config credential.username $GITHUB_USER 
```  

flux create source git <SOURCE NAME>--url=https://github.com/qusp66/hbvu_attic_lab --branch=main --interval=30s --export > ./<SOURCE NAME>-source.yaml 
 
-- EXAMPLE -- 
$ flux create source git minio --url=https://github.com/thisistayo/hbvu_attic_lab --branch=main --interval=30s --export > ./minio-source.yaml 
 
( flux delete source git <SOURCE NAME>) 
 
flux create kustomization minio --target-namespace=<NAMESPACE WHERE THE YAMLs SHOULD BE KAFed> --source=<SOURCE NAME> --path="<THE RELATIVE PATH IN THE GIT REPO DEFINED AS SOURCE>" --prune=true --interval=5m --export > ./<KUST-NAME>-kustomization.yaml 
 
-- EXAMPLE -- 
$ flux create kustomization minio --target-namespace=minio --source=minio --path="./kustomize/components/minio" --prune=true --interval=5m --export > ./minio-kustomization.yaml 
 
 
(  flux delete kustomization <KUST NAME> ))  
 
git add -A && git commit -m "Add MINIO Kustomization" 
git push 
 
flux get kustomizations --watch 
 
flux logs --level=error 
 
flux uninstall --namespace=flux-system 
 