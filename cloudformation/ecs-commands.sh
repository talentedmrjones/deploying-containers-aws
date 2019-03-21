
NETWORK_STACK="microservices-network"
REGION="us-east-2"

# create the base VPC and Subnets (public and private)
aws --region $REGION cloudformation create-stack \
--stack-name ${NETWORK_STACK} \
--template-body file://./vpc-subnets.yml \
--parameters ParameterKey=VpcSubnetCidrs,ParameterValue=10.100.0.0/16 \
&& aws --region $REGION cloudformation wait stack-create-complete --stack-name ${NETWORK_STACK}

# create the necessary internet access
aws --region $REGION cloudformation create-stack \
--stack-name ${NETWORK_STACK}-internet \
--template-body file://./igw-ngw-routes.yml \
--parameters ParameterKey=NetworkStack,ParameterValue=${NETWORK_STACK} \
&& aws --region $REGION cloudformation wait stack-create-complete --stack-name ${NETWORK_STACK}-internet

# find latest AMI for ECS
AMI_ID=$(aws --region $REGION ec2 describe-images --owners amazon --filters Name=architecture,Values=x86_64 Name=virtualization-type,Values=hvm Name=root-device-type,Values=ebs Name=name,Values='*amazon-ecs-optimized' --query 'sort_by(Images, &CreationDate)[-1].ImageId' --output text)

# create autoscaling group and ECS cluster
aws --region $REGION cloudformation create-stack \
--stack-name microservices-ecs-cluster \
--template-body file://./autoscaling-ecs-cluster.yml \
--parameters \
ParameterKey=ClusterName,ParameterValue=microservices-ecs \
ParameterKey=NetworkStack,ParameterValue=${NETWORK_STACK} \
ParameterKey=AMI,ParameterValue=${AMI_ID} \
ParameterKey=NumNodes,ParameterValue=3 \
--capabilities "CAPABILITY_NAMED_IAM" \
&& aws --region $REGION cloudformation wait stack-create-complete --stack-name microservices-ecs-cluster


# create application load balancer
aws --region $REGION cloudformation create-stack \
--stack-name microservices-alb-dev-ohio \
--template-body file://./alb.yml \
--parameters \
ParameterKey=NetworkStack,ParameterValue=${NETWORK_STACK} \
ParameterKey=ElbName,ParameterValue=microservices-dev-ohio \
&& aws --region $REGION cloudformation wait stack-create-complete --stack-name microservices-alb-dev-ohio

# if creating ECS service for the first time in the account run the following:
# aws --region $REGION iam create-service-linked-role --aws-service-name ecs.amazonaws.com

# create the ECS service and task for USERS service
aws --region $REGION cloudformation create-stack \
--stack-name microservices-service-users \
--template-body file://./ecs-service-task-users.yml \
--parameters \
ParameterKey=ClusterName,ParameterValue=microservices-ecs \
ParameterKey=AlbStack,ParameterValue=microservices-alb-dev-ohio \
--capabilities "CAPABILITY_NAMED_IAM" \
&& aws --region $REGION cloudformation wait stack-create-complete --stack-name microservices-service-users

# create the CICD pipeline for USERS
aws --region $REGION cloudformation create-stack \
--stack-name microservices-pipeline-users \
--template-body file://./pipeline.yml \
--parameters \
ParameterKey=ArtifactBucket,ParameterValue=cerulean-operations-us-east-2 \
ParameterKey=ClusterName,ParameterValue=microservices-ecs \
ParameterKey=Service,ParameterValue=users \
--capabilities "CAPABILITY_NAMED_IAM" \
&& aws --region $REGION cloudformation wait stack-create-complete --stack-name microservices-pipeline-users

# create the ECS service and task for MESSAGES service
# notice that the messages service requires the additional NetworkStack parameter
# this is because the FARGATE launch type will create ENIs (elastic network interface) inside OUR VPC
aws --region $REGION cloudformation create-stack \
--stack-name microservices-service-messages \
--template-body file://./ecs-service-task-messages.yml \
--parameters \
ParameterKey=NetworkStack,ParameterValue=microservices-network \
ParameterKey=ClusterName,ParameterValue=microservices-ecs \
ParameterKey=AlbStack,ParameterValue=microservices-alb-dev-ohio \
--capabilities "CAPABILITY_NAMED_IAM" \
&& aws --region $REGION cloudformation wait stack-create-complete --stack-name microservices-service-messages

# create the CICD pipeline for MESSAGES
aws --region $REGION cloudformation create-stack \
--stack-name microservices-pipeline-messages \
--template-body file://./pipeline.yml \
--parameters \
ParameterKey=ArtifactBucket,ParameterValue=cerulean-operations-us-east-2 \
ParameterKey=ClusterName,ParameterValue=microservices-ecs \
ParameterKey=Service,ParameterValue=messages \
--capabilities "CAPABILITY_NAMED_IAM" \
&& aws --region $REGION cloudformation wait stack-create-complete --stack-name microservices-pipeline-messages
