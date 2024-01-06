# EKS and RDS Creation in AWS using Terraform

### Overview:

This repo is having Terraform script that automates the creation of an Amazon Elastic Kubernetes Service (EKS) cluster and RDS instance on AWS. The script covers the following key components:

![Project1-Employee_portal-Page-1](https://github.com/selvanayaki678/employee-portal-crud/assets/67256407/f0ec20b9-e7a3-425b-9dca-a3b14f0c9166)

1. **AWS Configuration in Terraform:**
   - Ensure you have an AWS account and have created an IAM user with administrator permissions.
   - Generate the Access Key ID and Secret Access Key for this IAM user.

2. **Jenkins Integration with AWS:**
   - Add the IAM user's Access Key ID and Secret Access Key as Jenkins credentials.
   - In the Jenkinsfile, set these credentials as environment variables.

   Example Jenkinsfile snippet:
   ```groovy
   pipeline {
    agent any 
        environment {
            AWS_ACCESS_KEY_ID=credentials('aws_access_key')
            AWS_SECRET_ACCESS_KEY=credentials('aws_access_key_value')
        }
   }
   ```

3. **Terraform State Management:**
   - The Terraform state file is stored in an S3 bucket for better collaboration and consistency across your team.
   - Ensure that you have configured the AWS provider with the necessary credentials.

   Example Terraform Configuration:
   ```hcl
	  terraform {
	  backend "s3" {
	    bucket = "terraform-statefile-s3-aws"
	    key    = "state/eks-cluster.tfstate"
	    region = "us-east-2"
	  }
	}
   ```

4. **EKS cluster creation**
  	- **EKS Cluster:**
  	   - VPC and 2 public subnets are created for the EKS cluster.
  	   - IAM roles are created and attached to the the `AmazonEKSClusterPolicy`.
  	   - The EKS cluster is created utilizing the specified IAM roles and VPC.
  	- **Node Group:**
  	   - IAM roles with `AmazonEKSWorkerNodePolicy` and `AmazonEKS_CNI_Policy` are created.
  	   - EKS node group is configured to utilize the created IAM roles.
        ![image](https://github.com/selvanayaki678/employee-portal-crud/assets/67256407/02cd1254-6856-40ce-90bf-969b108d3bf1)


5. **RDS Instance creation**
	- Creating an AWS RDS instance with Terraform involves setting up a VPC, two public subnets in different zones, and a database subnet group.
	- The RDS instance, specifically for MySQL, is configured using Terraform, defining details like instance ID, username, and password. 
	- Additionally, a security group is established to permit all required incoming connections, ensuring accessibility to the RDS instance. 
	![image](https://github.com/selvanayaki678/employee-portal-crud/assets/67256407/3358534f-793b-4d50-9abd-4a07c4ca2b6b)




### Usage:

1. **Setup Terraform:**
   - Install Terraform locally 
2. **Terraform steps :**
   - Added all terraform commands in jenkins file
     ![image](https://github.com/selvanayaki678/employee-portal-crud/assets/67256407/b9c1232f-b597-4c4e-8c2d-2c7b63d8100d)

    - Terraform init -- This initiates the download of required providers.
    - Terraform plan -- This command reveals the anticipated resources that will be created.
    - terraform apply -- This command parameterized within the pipeline, can be chosen to be executed or skipped, It results in the creation of resources in AWS.
![image](https://github.com/selvanayaki678/employee-portal-crud/assets/67256407/71c15485-e85e-4ddc-a80d-fb966665d9a1)

    - Terraform destroy -- This command, which can be customized in the pipeline, lets you decide whether to run it or not. If executed, it starts cleaning up resources.

