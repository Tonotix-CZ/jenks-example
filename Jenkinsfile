pipeline {
    triggers {
    githubPush()
}
    agent any

    environment {
        IMAGE_NAME = "my-html-site"
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
    }

    triggers {
        // Every minute check for changes in Git
       // pollSCM('* * * * *')
       // Trigger build on GitHub push events - Listen to webhook events
           githubPush()

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
                  docker build -t %IMAGE_NAME%:%IMAGE_TAG% .
                  minikube image load %IMAGE_NAME%:%IMAGE_TAG%
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
        
        stage('Deploy to Kubernetes') {
            steps {
                bat '''
                  kubectl apply -f k8s/deployment.yaml
                  kubectl apply -f k8s/service.yaml
                  echo Updating deployment image...
                  kubectl set image deployment/html-site html-site=%IMAGE_NAME%:%IMAGE_TAG%

                  echo Waiting for rollout to complete...
                  kubectl rollout status deployment/html-site --timeout=60s
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
           
    }
}
