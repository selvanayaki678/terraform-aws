pipeline {
    agent any 
        environment {
            AWS_ACCESS_KEY_ID=credentials('aws_access_key')
            AWS_SECRET_ACCESS_KEY=credentials('aws_access_key_value')
        }
        parameters {
            booleanParam(name: 'terraform-apply', defaultValue: false)
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
                    sh 'cd RDS;terraform init;pwd;terraform plan'
            }
            } 
            stage ('Terraform ${action}')
            {
                when {
                expression { return params.terrafom-apply }
                }
                    steps {
                    sh 'cd RDS;terraform ${action} --auto-approve'
                }
            

            }
    
}
}
