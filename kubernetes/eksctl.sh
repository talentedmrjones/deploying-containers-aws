eksctl create cluster \
--name microservices \
--version 1.13 \
--nodegroup-name workers \
--node-type t3.medium \
--nodes 3 \
--nodes-min 3 \
--nodes-max 3 \
--node-ami auto \
--vpc-public-subnets=subnet-059e2687d914d6c0c,subnet-064c99608a6f339c6,subnet-01903b5cb71c08418 \
--vpc-private-subnets=subnet-02a4bfac3b04a977d,subnet-0161e512b30974a02,subnet-03e1b184cf43afecd



# REPLACE the above subnets with YOUR subnets

kubectl get svc

kubectl get nodes

kubectl create -f ./kubernetes/deployment.yml

kubectl rollout status deployment/nginxhello

kubectl get pods --show-labels

kubectl describe deployments

kubectl get services
# there is not service at this point
kubectl expose deployment nginxhello --type=LoadBalancer --name=helloworld

kubectl get services
# now we have a service
kubectl get service helloworld