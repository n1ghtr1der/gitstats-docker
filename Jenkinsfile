def buildImage() {
    sh '''docker build  --build-arg REPO=${REPOSITORY_URL} --build-arg REPO_NAME=${REPOSITORY_NAME} \
     --build-arg SSH_PRV_KEY="${SSH_CREDENTIALS}" . -t gitstats-image:front
    '''
}

pipeline {
    agent any

    environment {
        REPOSITORY_URL = 'git@ssh.dev.azure.com:v3/lds-ifce/PU%20-%20Plataforma%20EAD%20Adaptativa/front-end'
        REPOSITORY_NAME = 'front-end'
        SSH_CREDENTIALS = credentials('devops-key')
        DOCKERFILE = credentials('gitstats-dockerfile') 
    }

    stages {
        stage('Creating Dockerfile') {
            steps {
                sh 'cat ${DOCKERFILE} > ./Dockerfile'
            }
        }
        stage('Homero Front') {
            stages {
                stage('Running Docker') {
                    steps {
                        echo 'Generating statistics'
                        buildImage()
                    }
                }
                stage('Copying stats from container') {
                    steps {
                        sh 'docker run --name front-stats -d gitstats-image tail -f /dev/null'
                        sh 'docker cp gitstats:/stats .'
                    }
                }
                stage('S3 Upload') {
                    steps {
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-ecr']]) {
                            sh 'aws s3 cp ./stats s3://gitstats-homero/${REPOSITORY_NAME}'
                        }
                    }
                }
            }
        }
    }
    post {
        cleanup {
            sh '''
                docker container prune -f
                docker rmi $(docker images -aq) -f
                docker images
            '''
            dir("${WORKSPACE}@tmp") { deleteDir() }
            deleteDir()
        }
    }
}