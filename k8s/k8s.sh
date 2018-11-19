export KOPS_STATE_STORE="s3://YOUR_BUCKET_GOES_HERE"

kops create cluster \
--name k8s.cerulean.systems \
--zones us-east-2a,us-east-2b,us-east-2c \
--master-zones us-east-2a,us-east-2b,us-east-2c \
--dns-zone cerulean.systems \
--node-size t2.medium \
--node-count 3 \
--master-size t2.medium \
--master-count 3 \


kops update cluster k8s.cerulean.systems --yes

kops validate cluster

kubectl get nodes

kubectl create -f ./k8s/deployment.yml

kubectl rollout status deployment/nginx-deployment

kubectl get pods --show-labels

kubectl get services

kubectl expose deployment nginx-deployment --type=LoadBalancer --name=helloworld

kubectl get services

kubectl describe-services helloworld

kops delete cluster k8s.cerulean.systems --yes
