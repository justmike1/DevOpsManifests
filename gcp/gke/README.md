# terraform

**init**
* add those two env variables to your shell profile (~/.zprofile or ~/.profile)
```bash
export KUBE_CONFIG_PATH=~/.kube/config
export USE_GKE_GCLOUD_AUTH_PLUGIN=False
source ~/.zprofile | source ~/.profile
```

* connect to the cluster 
```bash
gcloud container clusters get-credentials ${var.cluster_name} --region ${var.region} --project ${var.project_id}
```

* Installations needed
**CLI**
```bash
brew install traefik cilium-cli hubble kubectl terraform helm
```
**CASKS**
```bash
brew install --cask google-cloud-sdk
```

## On first setup
>TODO: write CD script

1. create environment folder with module (see dev environment for example).
2. make sure the name of the backend bucket in `main.tf` & `backend.tf` is the same.
3. comment out code in `backend.tf`, we don't have a state to remote yet.
4. when on the created env folder
```bash
terraform init  # download modules & pull/create remote backend
terraform apply # create cluster/machine
```
5. uncomment `backend.tf`, run `terraform init` again and send state to remote backend.


* on cleanup
```bash
terraform destroy
```

# Helpers

[Machine Types](./environments/README.md)

[Links to docs/sources](./BIBLIOGRAPHY.md)
