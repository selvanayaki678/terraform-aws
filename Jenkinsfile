pipeline {
    agent any {
        environment {
            name="selva"
        }
        stages {
            stage('priint env')
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
}