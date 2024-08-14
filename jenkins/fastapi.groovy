pipeline {
    agent any
    stages {
        stage('Pull repo') {
            steps {
                git branch: 'master', url: 'https://github.com/adithya08/reorg-casestudy.git'
            }
        }
        stage ('Infra setup') {
            steps {
                sh "cd terraform"
                sh "terraform init"
                sh "terraform apply --auto-approve"
            }
        }
        stage('Build Docker image') {
            steps {
                sh "docker build -t <ecr repo url for fastapi>:latest -f server/Dockerfile ."
                sh "docker push <ecr repo url for fastapi>"
            }
        }
        stage('Deploy') {
            steps {
                sh "aws ecs update-service --cluster fastapi_cluster --service fastapi_service --force-deployment"
            }
        }
    }
}