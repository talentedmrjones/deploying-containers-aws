eksctl create cluster \
--name microservices-k8s \
--version 1.13 \
--nodegroup-name microservices-k8s-workers \
--node-type t3.medium \
--nodes 3 \
--nodes-min 3 \
--nodes-max 3 \
--node-ami auto \
--vpc-private-subnets=<YOUR, private, subnets> \
--vpc-public-subnets=<YOUR, public, subnets>

