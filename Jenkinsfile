pipeline {
    agent any

    environment {
        IMAGE_NAME = "my-html-site"
    }

    triggers {
        // Every minute check for changes in Git
        pollSCM('* * * * *')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker image') {
            steps {
                bat '''
                  docker build -t %IMAGE_NAME%:latest .
                '''
            }
        }

        stage('Load image into Minikube') {
            steps {
                bat '''
                  minikube image load %IMAGE_NAME%:latest
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                bat '''
                  kubectl apply -f k8s/deployment.yaml
                  kubectl apply -f k8s/service.yaml
                '''
            }
        }

        stage('Smoke info (print URL)') {
            steps {
                bat '''
                  echo Getting service URL...
                  minikube service html-site-service --url
                '''
            }
        }
    }
}
