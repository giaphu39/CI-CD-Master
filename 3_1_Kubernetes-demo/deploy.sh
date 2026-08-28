set -e # Dừng script ngay lập tức nếu bất kỳ lệnh nào bị lỗi (run this script with bash)

USERNAME="amalkin39"
PROJECT_NAME="3_1_kubernetes-demo-api"
IMAGE="${USERNAME}/${PROJECT_NAME}:latest"
SERVICE_NAME="devops-kubernetes-api-service"

echo "Building Docker image..."
docker build -t "${IMAGE}" .

echo "Pushing Docker image to Docker Hub..."
docker push "${IMAGE}"

echo "Applying Kubernetes manifests..."
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/services.yaml

echo "Getting pods..."
kubectl get pods 

echo "Getting services..."
kubectl get services

echo "Fetching the main service..."
kubectl get services ${SERVICE_NAME}

# minikube service ${SERVICE_NAME}
