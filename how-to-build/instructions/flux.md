INSTALL
curl -s https://fluxcd.io/install.sh | sudo bash (or brew)

$ k create ns flux-system 
$ export GITHUB_TOKEN=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 
$ export GITHUB_USER=thisistayo
$ export GITHUB_REPO=attic-flux


flux bootstrap github --owner=${GITHUB_USER} --repository=${GITHUB_REPO} --branch=main --personal=true --path=clusters/attic

$ flux bootstrap github --owner=${GITHUB_USER} --repository=attic-flux  --private=false --personal=true --path=./clusters/attic  

REPO GETS CREATED BY BOOTSTRAPPING BUT IT IS PRIVATE, MIGHT NEED TO CHANGE TO PUBLIC

git clone https://github.com/qusp66/flux
cd flux
git config credential.username $GITHUB_USER

SOURCES: 

>> flux create source git <SOURCE NAME> --url=https://github.com/qusp66/hbvu_attic_lab --branch=main --interval=30s --export > ./<SOURCE NAME>-source.yaml
-- EXAMPLE --
$ flux create source git hbvue --url=https://github.com/thisistayo/hbvu_attic_lab --branch=main --interval=30s --export > ./hbvue-source.yaml
$ flux create source git subsonic --url=https://github.com/thisistayo/hbvu_attic_lab --branch=main --interval=30s --export > ./subsonic-source.yaml
$ flux get sources all --all-namespaces

( flux delete source git <SOURCE NAME>)
KUSTOMIZATIONS: 

>> flux create kustomization --target-namespace=<NAMESPACE WHERE THE YAMLs SHOULD BE KAFed> --source=<SOURCE NAME> --path="<THE RELATIVE PATH IN THE GIT REPO DEFINED AS SOURCE>" --prune=true --interval=5m --export > ./<KUST-NAME>-kustomization.yaml

-- EXAMPLE --
$ flux create kustomization hbvue --target-namespace=webapps --source=hbvue --path="./" --prune=true --interval=5m --export > ./hbvue-kustomization.yaml
$ flux create kustomization subsonic --target-namespace=subsonic --source=subsonic --path="./" --prune=true --interval=5m --export > ./subsonic-kustomization.yaml

(  flux delete kustomization <KUST NAME> )) 

git add -A && git commit -m "Add SPCEU Kustomization"
git push

flux get kustomizations --watch

flux logs --level=error

flux uninstall --namespace=flux-system
