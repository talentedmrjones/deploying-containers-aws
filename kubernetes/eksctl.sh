eksctl create cluster \
--name microservices \
--version 1.13 \
--nodegroup-name workers \
--node-type t3.medium \
--nodes 3 \
--nodes-min 3 \
--nodes-max 3 \
--node-ami auto \
--vpc-public-subnets=subnet-07e086e0f83a8c03b,subnet-0ec3063c069f0864e,subnet-0a8cfb228ff6bb753 \
--vpc-private-subnets=subnet-0632a9a8a2706f958,subnet-066d8c85e986cd3a2,subnet-00bad100432a5d2ab

# REPLACE the above subnets with YOUR subnets

kubectl get svc

kubectl get nodes

kubectl create -f ./kubernetes/deployment.yml

kubectl rollout status deployment/nginxhello

kubectl get pods --show-labels

kubectl get services

kubectl expose deployment nginxhello --type=LoadBalancer --name=helloworld

kubectl get service helloworld