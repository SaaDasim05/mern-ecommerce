#!/bin/bash

cd ~/mern-ecommerce

echo "Starting Minikube..."
minikube start --driver=docker --memory=4096 --cpus=2

echo "Waiting for Minikube..."
kubectl wait --for=condition=Ready node/minikube --timeout=120s

echo "Applying Namespace..."
kubectl apply -f k8s/namespace.yml
sleep 2

echo "Deploying Database..."
kubectl apply -f k8s/database/mongo-pv.yml
kubectl apply -f k8s/database/mongo-pvc.yml
kubectl apply -f k8s/database/redis-pv.yml
kubectl apply -f k8s/database/redis-pvc.yml
kubectl apply -f k8s/database/mongo-deployment.yml
kubectl apply -f k8s/database/mongo-service.yml
kubectl apply -f k8s/database/redis-deployment.yml
kubectl apply -f k8s/database/redis-service.yml

echo "Waiting for MongoDB..."
kubectl wait --for=condition=Ready pod -l app=mongodb -n mern-ecommerce --timeout=120s
kubectl wait --for=condition=Ready pod -l app=redis -n mern-ecommerce --timeout=60s

echo "Deploying Backend..."
kubectl apply -f k8s/backend/backend-configmap.yml
kubectl apply -f k8s/backend/backend-secret.yml
kubectl apply -f k8s/backend/backend-deployment.yml
kubectl apply -f k8s/backend/backend-service.yml

echo "Waiting for Backend..."
kubectl wait --for=condition=Ready pod -l app=backend -n mern-ecommerce --timeout=120s

echo "Deploying Frontend..."
kubectl apply -f k8s/frontend/frontend-deployment.yml
kubectl apply -f k8s/frontend/frontend-service.yml

echo "Waiting for all pods..."
kubectl wait --for=condition=Ready pod --all -n mern-ecommerce --timeout=180s

echo ""
echo "=== Deployment Status ==="
kubectl get all -n mern-ecommerce

echo ""
echo "=== App URL ==="
minikube service frontend -n mern-ecommerce --url
