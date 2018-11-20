
NETWORK_STACK="microservices-network"

# create the base VPC and Subnets (public and private)
aws cloudformation create-stack \
--stack-name ${NETWORK_STACK} \
--template-body file://./vpc-subnets.yml \
--parameters ParameterKey=VpcCidrPrefix,ParameterValue=10.0 \
&& aws cloudformation wait stack-create-complete --stack-name ${NETWORK_STACK}

# create the necessary internet access
aws cloudformation create-stack \
--stack-name ${NETWORK_STACK}-internet \
--template-body file://./igw-ngw-routes.yml \
--parameters ParameterKey=NetworkStack,ParameterValue=${NETWORK_STACK} \
&& aws cloudformation wait stack-create-complete --stack-name ${NETWORK_STACK}-internet

# find latest AMI for ECS
AMI_ID=$(aws ec2 describe-images --owners amazon --filters Name=architecture,Values=x86_64 Name=virtualization-type,Values=hvm Name=root-device-type,Values=ebs Name=name,Values='*amazon-ecs-optimized' --query 'sort_by(Images, &CreationDate)[-1].ImageId' --output text)

# create autoscaling group and ECS cluster
aws cloudformation create-stack \
--stack-name microservices-ecs-cluster \
--template-body file://./autoscaling-ecs-cluster.yml \
--parameters \
ParameterKey=ClusterName,ParameterValue=microservices-ecs \
ParameterKey=NetworkStack,ParameterValue=${NETWORK_STACK} \
ParameterKey=AMI,ParameterValue=${AMI_ID} \
ParameterKey=NumNodes,ParameterValue=3 \
--capabilities "CAPABILITY_NAMED_IAM" \
&& aws cloudformation wait stack-create-complete --stack-name microservices-ecs-cluster


# create application load balancer
aws cloudformation create-stack \
--stack-name microservices-alb-dev-ohio \
--template-body file://./alb.yml \
--parameters \
ParameterKey=NetworkStack,ParameterValue=${NETWORK_STACK} \
ParameterKey=ElbName,ParameterValue=microservices-dev-ohio \
&& aws cloudformation wait stack-create-complete --stack-name microservices-alb-dev-ohio


# create the ECS service and task
aws cloudformation create-stack \
--stack-name microservices-service-users \
--template-body file://./ecs-service-task-users.yml \
--parameters \
ParameterKey=ClusterName,ParameterValue=microservices-ecs \
ParameterKey=AlbStack,ParameterValue=microservices-elb-dev-ohio \
--capabilities "CAPABILITY_NAMED_IAM" \
&& aws cloudformation wait stack-create-complete --stack-name microservices-service-users

# create the CICD pipeline
aws cloudformation create-stack \
--stack-name microservices-pipeline-users \
--template-body file://./pipeline.yml \
--parameters \
ParameterKey=ClusterName,ParameterValue=microservices-ecs \
ParameterKey=Service,ParameterValue=users \
--capabilities "CAPABILITY_NAMED_IAM" \
&& aws cloudformation wait stack-create-complete --stack-name microservices-pipeline-users
