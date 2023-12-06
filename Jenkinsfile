pipeline {
    agent any 
        environment {
            name = "selva"
        }
        stages {
            stage('print env')
            {
                environment {
                    msg="hello world"
                }
                steps {
                    sh 'cd /home/user/terraform-aws; terraform --version; terraform init'
                }
            }
        }
    
}
