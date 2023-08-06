INSTALL 
curl -s https://fluxcd.io/install.sh | sudo bash (or brew) 
 
$ k create ns flux-system  
$ export GITHUB_TOKEN=<YOUR GITHUB TOKEN>
$ export GITHUB_USER=<YOUR GITHUB USERNAME> 
$ export GITHUB_REPO=flux 
 
 
flux bootstrap github --owner=${GITHUB_USER} --repository=${GITHUB_REPO} --branch=main --personal=true --path=clusters/attic 
 
$ flux bootstrap github --owner=qsp66 --repository=attic-flux  --private=false --personal=true --path=./clusters/attic   
 
REPO GETS CREATED BY BOOTSTRAPPING BUT IT IS PRIVATE, MIGHT NEED TO CHANGE TO PUBLIC 
 
git clone https://github.com/qusp66/flux 
cd flux 
git config credential.username $GITHUB_USER 
 
flux create source git <SOURCE NAME>--url=https://github.com/qusp66/hbvu_attic_lab --branch=main --interval=30s --export > ./<SOURCE NAME>-source.yaml 
 
-- EXAMPLE -- 
$ flux create source git mosquitto --url=https://github.com/qusp66/hbvu_attic_lab --branch=main --interval=30s --export > ./mosquitto-source.yaml 
 

 
( flux delete source git <SOURCE NAME>) 
 
flux create kustomization minio --target-namespace=<NAMESPACE WHERE THE YAMLs SHOULD BE KAFed> --source=<SOURCE NAME> --path="<THE RELATIVE PATH IN THE GIT REPO DEFINED AS SOURCE>" --prune=true --interval=5m --export > ./<KUST-NAME>-kustomization.yaml 
 
-- EXAMPLE -- 
$ flux create kustomization influxdb --target-namespace=iot --source=influxdb --path="./kustomize/components/influxdb" --prune=true --interval=5m --export > ./influxdb-kustomization.yaml 
 
 
(  flux delete kustomization <KUST NAME> ))  
 
git add -A && git commit -m "Add SPCEU Kustomization" 
git push 
 
flux get kustomizations --watch 
 
flux logs --level=error 
 
flux uninstall --namespace=flux-system 
 