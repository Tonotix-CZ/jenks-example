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
        stage('Wait for deployment') {
            steps {
                bat '''
                 echo Waiting for html-site deployment to be ready...
                 kubectl rollout status deployment/html-site --timeout=60s
                 echo Current pods:
                 kubectl get pods
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
            stage('Debug K8s connection') {
    steps {
        bat '''
          echo === Minikube status ===
          minikube status

          echo === kubectl current context ===
          kubectl config current-context

          echo === kubectl cluster-info ===
          kubectl cluster-info

          echo === kubectl get nodes ===
          kubectl get nodes
         '''
          }
        }
    }
}
