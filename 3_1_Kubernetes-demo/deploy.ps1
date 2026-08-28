$ErrorActionPreference = "Stop"

$USERNAME = "amalkin39"
$PROJECT_NAME = "3_1_kubernetes-demo-api"
$IMAGE = "${USERNAME}/${PROJECT_NAME}:latest"
$SERVICE_NAME = "devops-kubernetes-api-service"

Write-Host "Building Docker image..." -ForegroundColor Green
docker build -t $IMAGE . | Out-Host

Write-Host "Pushing Docker image to Docker Hub..." -ForegroundColor Green
docker push $IMAGE | Out-Host

Write-Host "Applying Kubernetes manifests..." -ForegroundColor Green
kubectl apply -f k8s/deployment.yaml | Out-Host
kubectl apply -f k8s/services.yaml | Out-Host

Write-Host "Getting pods..." -ForegroundColor Green
kubectl get pods | Out-Host

Write-Host "Getting services..." -ForegroundColor Green
kubectl get services | Out-Host

Write-Host "Fetching the main service..." -ForegroundColor Green
kubectl get services $SERVICE_NAME | Out-Host
