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
gcloud container clusters get-credentials ${var.cluster_name} --region us-central1 --project ${var.project_id}
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
**secrets**
```bash
gcloud iam service-accounts keys create ./credentials.json \
  --iam-account <DNS_SERVICE_ACCOUNT_EMAIL_WITH_PERMISSIONS>
```
```bash
kubectl create secret generic "external-dns-sa" --namespace "default" \
  --from-file ./credentials.json
```
**move the secret to the desired namespace**
```bash
kubectl get secret "external-dns-sa" --namespace=default -o yaml | \
  sed 's/namespace: .*/namespace: external-dns/' | \
    kubectl apply -f -
```
