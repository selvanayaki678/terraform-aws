pipeline {
    agent any 
        environment {
            AWS_ACCESS_KEY_ID=credentials('aws_access_key')
            AWS_SECRET_ACCESS_KEY=credentials('aws_access_key_value')
        }
        parameters {      
    booleanParam( defaultValue: true, description: '',name: 'apply' )
    booleanParam( defaultValue: true, description: '',name: 'vapply' )        
        }
        stages {
            stage('Checkout') {
                steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/selvanayaki678/terraform-aws.git']]])            
                  }
            }
            stage ('checking current dir'){
                steps {
                    sh 'pwd;ls;printenv'
                }
            }
            stage ('terraform init')
            {
                steps {
                    sh 'cd RDS;terraform init;pwd;terraform plan -var-file=rds-mysql.tfvars'
            }
            } 
            stage ('Terraform apply')
            {
                when {
                expression {  return params.apply == true  }
                }
                    steps {
                    sh 'cd RDS;terraform apply -var-file=rds-mysql.tfvars --auto-approve'
                }
            

            }
            stage ('VPC terraform init & Plan')
            {
                steps {
                    sh 'cd EKS/VPC;terraform init;pwd;terraform plan -var-file=vpc-eks-cluster.tfvars'
            }
            } 
            stage ('VPC Terraform apply')
            {
                when {
                expression {  return params.vapply == true  }
                }
                    steps {
                    sh 'cd EKS/VPC;terraform apply -var-file=vpc-eks-cluster.tfvars --auto-approve'
                }
            

            }

    
}
}
