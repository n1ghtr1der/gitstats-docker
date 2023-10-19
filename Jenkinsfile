def buildImage() {
    sh '''docker build  --build-arg REPO=${REPOSITORY_URL} --build-arg REPO_NAME=${REPOSITORY_NAME} \
     --build-arg SSH_PRV_KEY="$(cat ${SSH_CREDENTIALS})" . -t gitstats-image:${REPOSITORY_NAME}
    '''
}

pipeline {
    agent any

    environment {
        REPOSITORY_URL = 'git@ssh.dev.azure.com:v3/lds-ifce/PU%20-%20Plataforma%20EAD%20Adaptativa/front-end'
        REPOSITORY_NAME = 'front-end'
        SSH_CREDENTIALS = credentials('devops-key')
        DOCKERFILE = credentials('gitstats-dockerfile')
        BUCKET_NAME = 'gitstats-homero'
        //TEST = "${sh(script: 'cat /home/jenkins_home/.ssh/id_rsa')}"
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
                        sh 'docker run --name homero-stats -d gitstats-image:${REPOSITORY_NAME} tail -f /dev/null'
                        sh 'docker cp homero-stats:/stats .'
                    }
                }
                stage('S3 cleanup and upload stats') {
                    steps {
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-ecr']]) {
                            sh 'aws s3 rm s3://${BUCKET_NAME}/${REPOSITORY_NAME}/* --recursive'
                            sh 'aws s3 cp ./stats s3://${BUCKET_NAME}/${REPOSITORY_NAME} --recursive'
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
                docker rm $(docker ps -aq) -f
                docker rmi $(docker images -aq) -f
                docker images
            '''
            dir("${WORKSPACE}@tmp") { deleteDir() }
            deleteDir()
        }
    }
}