pipeline {
    agent any 
        environment {
            AWS_ACCESS_KEY_ID=credentials('aws_access_key')
            AWS_SECRET_ACCESS_KEY=credentials('aws_access_key_value')
        }
        stages {
            // stage('Checkout') {
            //     steps {
            //     checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/selvanayaki678/terraform-aws.git']]])            
            //       }
            // }
            stage ('checking current dir'){
                steps {
                    sh 'pwd;ls;printenv'
                }
            }
        }
    
}
