pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = '616850318755'
        AWS_DEFAULT_REGION = 'us-west-2'
        ECR_REPO_NAME = 'your-ecr-repo'
        IMAGE_TAG = "${env.BUILD_ID}"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git 'https://github.com/your-username/aws-data-pipeline.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}")
                }
            }
        }
        stage('Login to AWS ECR') {
            steps {
                script {
                    sh '$(aws ecr get-login --no-include-email --region ${AWS_DEFAULT_REGION})'
                }
            }
        }
        stage('Push Docker Image to ECR') {
            steps {
                script {
                    dockerImage.push()
                }
            }
        }
        stage('Deploy with Terraform') {
            steps {
                script {
                    sh '''
                    cd terraform
                    terraform init
                    terraform apply -auto-approve
                    '''
                }
            }
        }
    }
}
