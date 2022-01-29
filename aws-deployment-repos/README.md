## Installation Guide for BAP on AWS

### Structure of repositories

The BIAB BAP repository is available [here](https://github.com/beckn/beckn-in-a-box/tree/main/biab-bap).


The main repository contains the following submodules linked to their individual repository.

1. [biab-storefront-ui](https://github.com/beckn/biab-storefront-ui) is the repo for the UI of the project which is the vue storefront implementation and overlay.

2. [biab-bap-client](https://github.com/beckn/biab-bap-client) is the repo where the first layer of API is built, these are client APIs which take care of converting UI requests to protocol level requests and interacts with BPP. It also houses APIs which allow for polling on on_{APIs} ie callback API responses which are stored by the BAP.

3. [biab-bap-protocol](https://github.com/beckn/biab-bap-protocol) is the repo which helps separate the client APIs and the protocol APIs, this repo contains all the APIs which are part of the protocol level APIs of BAP ie mainly the on_{APIs} ie callback APIs. This repository is also the place where the mongo writes and reads happen. The client layer calls the protocol layer to get the saved responses.

4. [beckn-protocol-dtos](https://github.com/beckn/beckn-protocol-dtos) is the repo which contains all the schema objects which are used across the protocol, and the client levels. The jar is versioned and imported as dependency of the client and protocol repos.

5. [biab-mongodb](https://github.com/beckn/biab-mongodb) is the repo which holds the github workflow and Ansible scripts which are used to set the config of the mongo deployment.

6. [biab-infra](https://github.com/beckn/biab-infra) is the repo which holds the github workflow and Ansible scripts which are used to bootstrap all instances in its inventory file to have a bunch of common requirements. Currently, it's being used to add the runner public key to the instance to enable ssh access.

7. [biab-api-gateway](https://github.com/beckn/biab-api-gateway) is the repo which holds github workflow and Ansible scripts which are used to launch the KrakenD service using the official docker image from the developers, and the config file which is in JSON is placed in the right directory to be used by the service.

Instructions on how to set up each of these repositories are provided in the README.md file of the respective repositories.

### Docker structure in each repository
* Dockerfiles are present in the root of each repository which defines how the docker image will be built during the deployment step of the pipeline.

* There is also a .dockerignore file in the root to ensure random files/folders don't get added into the docker image being built as context.

### Ansible structure in each repository

* All the Ansible code resides in the ansible folder in the root of corresponding repositories.
* The inventory, playbooks, roles and vars are in corresponding folders inside the Ansible folder which define the steps to prepare a target ec2 instance(through the mention of IP address) to install all dependencies like docker and AWS cli before it can pull the image and start the service.
* The docker images are pulled from ECR and started as a system level service to ensure that it is easy to stop, restart or check status of.

* If creating your own instance, the values in the var folder need to be replaced with your own values.

### Github Deployment Workflow for all repositories
1. 1. Each repository/project has its own github workflow defined in the standard .github/workflows folder in the repository.

2. The workflow defines the steps which each do the task of building the project and testing it, might have functional, end to end, etc.

3.  After the tests are done depending on the branch and repo the deployment part of the pipeline is run. In this step a docker build environment is set, and the project is copied into it. It is then turned into the final artifact which can be in a docker image and run as a container. For the UI this is production level minified, chunked js and for jvm based projects we have jars which are created and placed in the docker image being built.

4. The docker image is tagged with the project name, and a version which is the build number of the github pipeline(in case of a rollback this is important)

1. The docker image is then pushed to our Amazon ECR, the ECR login is not necessary as the ec2 instance has an attached IAM policy which gives it permissions to ECR.
1. The last part of the pipeline is to trigger the Ansible role which will pull the docker image from ECR, set up any machine level dependencies on the target EC2 instances and then start the service. Currently all the targets are internal IPs. Would be ideal to keep it the same.

Suggested AWS Infrastructure Setup
Deployment Architecture

![](https://github.com/vrushalijatti/beckn-in-a-box/blob/main/Github%20architecture.png)

## AWS Deployment Infra setup
​The deployment infra setup is a prerequisite for all the other setups so that will be our first step​. All the below steps are in the VPC service section under AWS services.

1. First setup VPC in the region that you would like the deployment to be in
2. In the VPC set up subnets such that there are 2 public and 2 private subnets in 2 availability zones (AZ) with each AZ having 1 public and 1 private subnet

3. Set up an internet gateway on the VPC you created

i.  set up subnet association to the 2 public subnets

ii.  set up routes with the destination as the public subnets with target local

iii.  set up another route that has destination 0.0.0.0/0 i.e. anywhere to the target being the internet gateway.

4. Set up a NAT gateway in the VPC you created

i.  set up routes with the destination as the public subnets with target local

ii.  set up another route that has destination 0.0.0.0/0 ie anywhere to the target being the NAT gateway
(If steps 3 and 4 are done properly you should see that without explicit subnet associations shows the private subnet in both the internet gateway and the NAT gateway)

5. Set up Network ACLs for the private and public subnets. Only the ports required can be enabled.

(These are different from security groups (SG) as SGs have stateful management, i.e. if request traffic outbound on a port(eg:443) is open any incoming traffic on the same port is allowed for responses even if the port is not mentioned on inbound allowed ports(eg: if only 22 is allowed on inbound))

(Current rules can be copied. 1024 to the roof of no. of ports, everything is allowed as these are ephemeral ports. These ports are used to establish TTL handshakes and all sorts of other diagnostic calls between outside servers and your machines in the network)

[NACL or Network ACLs documentation to understand it better](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html)

## ECR service

Setup repositories for each of the services and a lifecycle policy to each repository to remove images older than the latest 10.

(These will the repositories to which the runner will push the built docker images)

## S3 service

1. Create a bucket that can be used as a private maven repository
2. This repo will be used to push the protocol DTO jar (and any other private library jar we add in the future)
3. Jars in this repositories are referred to in gradle file as dependencies

(Reference for making the services use s3 bucket as [a maven repo](https://nuvalence.io/blog/using-a-s3-bucket-as-a-maven-repository))​
## IAM service

These are the steps to create the IAM roles and policies under the roles which are required to be attached to the ec2 instances to give password-less access to AWS services.

1. Create a managed policy that allows for ECR read accesses and push an image. Do not give full ECR access as it will also have access to delete.

2. Create a managed policy that allows for S3 read and write access.

3. Create a managed policy which allows only for ECR read access and download images. Both this policy and 1st policy of ECR require getAuthorizationToken permission.

4. Attach 1 and 2 policies as an IAM role saying runner permissions or something of that sort as this will be the role attached to the runner instance.

5. Attach 3rd policy to an IAM role saying serviceECR access or something of that sort as this will allow machines that require the service images to be pulled and downloaded to get the services up and ready. You will not need this on instances that use official images like mongo instances, or the api gateway(KrakenD) instances.​

## EC2 instances
The following instances are the current configuration of how services are distributed, and the number and size of instances. This can be scaled and distributed in different ways. Current configuration:

1. Bastion host(size:t3.small, services:None, subnet:public)

2. Runner (size:t3.medium, services:github runner service ,subnet:private)

3. API-gateway(size:t2.medium, services:[KrakenD(2-instances of service)], subnet:private)​

4. BAP services(size:t3.medium, services: [BAP-client, BAP-protocol], subnet:private)

5. Mongo(size:t3.small, services:Mongo, subnet:private)

6. Storefront-UI(size:t3.medium, services: vue-storefront-UI, subnet:private)

### Special setup in EC2 to be done for some instances

1.The Mongo instance has mongo installed and configs are managed from the [Mongo repository](https://github.com/beckn/biab-mongodb) and its Github actions.

2. The [API-gateway repository ](https://github.com/beckn/biab-api-gateway) requires KrakenD which is installed and configs are managed from the api-gateway repository and its Github actions.

3. Any bootstrapping on all the instances can be done using the infrastructure repository and its Github actions. Currently, used to set up ssh access from runner to an instance​

### Load balancers
1. API load balancer: This is linked to the URL. There are 2 listeners on ports 80 and 443 for http and https. Both of the listeners are set up to forward incoming requests to the BAP target group(this target group is pointing to the ports of the 2 API-gateway services).

2. Storefront UI load balancer: This is linked to the URL. There are 2 listeners on ports 80 and 443 for HTTP and https. The port 80 listener forwards requests to the same host and 443 port as the load balancer with the original path and query. This is to redirect HTTP to https. The 443 port listener is set to forward requests to the UI service port as a target.

3. Internal load balancer between the client and protocol: This has 2 listeners 9001 and 9002 which are set up to forward requests to client service and protocol service respectively. This is used to communicate between the client and protocol services.​

### DNS entries
* The API load balancer and storefront UI have associated CNAME records on the AWS console, this was added on DNS console for the domain.​

### SSL certificates

* Currently, the certificates were manually generated using lets encrypt and certbot on the UI machine. The certs can still be found on it. They have been added to ACM(Amazon certificate manager) manually.

* The load balancers use the ACM certs to add on their 443 listeners to terminate SSL at the load balancer and further traffic is redirected in HTTP within the internal servers.