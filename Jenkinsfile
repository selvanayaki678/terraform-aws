pipeline {
    agent any 
        environment {
            AWS_ACCESS_KEY_ID=credentials('aws_access_key')
            AWS_SECRET_ACCESS_KEY=credentials('aws_access_key_value')
        }
        parameters {
           
    booleanParam(
                                defaultValue: true, 
                                description: '', 
                                name: 'apply'
                            )}
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
                    sh 'cd RDS;terraform init;pwd;terraform plan'
            }
            } 
            stage ('Terraform apply')
            {
                when {
                expression { { params.apply != false } }
                }
                    steps {
                    sh 'cd RDS;terraform apply --auto-approve'
                }
            

            }
    
}
}
