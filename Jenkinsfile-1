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
                    sh 'printenv'
                }
            }
        }
    
}
