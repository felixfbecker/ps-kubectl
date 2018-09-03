Import-Module "$PSScriptRoot/../Tests/Invoke-Executable.psm1"

# Download kubectl, which is a requirement for using minikube.
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v1.9.0/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Download minikube.
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.25.2/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/
sudo minikube start --vm-driver=none --kubernetes-version=v1.9.0

# Fix the kubectl context, as it's often stale.
minikube update-context

# Wait for Kubernetes to be up and ready.
while ($true) {
    Write-Information "Waiting for node to be ready"
    $nodes = (Invoke-Executable { kubectl get nodes -o json } | ConvertFrom-Json).Items
    $nodes
    if (($nodes.Status.Conditions | Where-Object { $_.Type -eq 'Ready' -and $_.Status -eq 'True' })) {
        break
    }
    Start-Sleep 1
}

Write-Information "Node ready"

kubectl cluster-info

# # Verify kube-addon-manager.
# # kube-addon-manager is responsible for managing other kubernetes components, such as kube-dns, dashboard, storage-provisioner..
# JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'; until kubectl -n kube-system get pods -lcomponent=kube-addon-manager -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; do sleep 1;echo "waiting for kube-addon-manager to be available"; kubectl get pods --all-namespaces; done
# # Wait for kube-dns to be ready.
# JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'; until kubectl -n kube-system get pods -lk8s-app=kube-dns -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; do sleep 1;echo "waiting for kube-dns to be available"; kubectl get pods --all-namespaces; done
# # Create example Redis deployment on Kubernetes.
# kubectl run travis-example --image=redis --labels="app=travis-example"
# # Make sure created pod is scheduled and running.
# JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'; until kubectl -n default get pods -lapp=travis-example -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; do sleep 1;echo "waiting for travis-example deployment to be available"; kubectl get pods -n default; done
