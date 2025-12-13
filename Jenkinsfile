pipeline {
    agent any

    // Trigger builds on GitHub webhook push events!
    triggers {
        githubPush()
    }

    environment {
        IMAGE_NAME = "my-html-site"
        IMAGE_TAG  = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Show HTML version') {
            steps {
                bat '''
                  echo ===== index.html in workspace =====
                  type index.html
                  echo ==================================
                '''
            }
        }

        stage('Build Docker image') {
            steps {
                bat '''
                  echo Building The Docker image %IMAGE_NAME%:%IMAGE_TAG% ...
                  docker build -t %IMAGE_NAME%:%IMAGE_TAG% .
                '''
            }
        }

        stage('Test Docker image (pre-deploy)') {
            steps {
                bat '''
                  echo Starting test container...
                  docker run -d --rm --name html-test -p 8081:80 %IMAGE_NAME%:%IMAGE_TAG%

                  echo Waiting for container to start...
                  ping -n 6 127.0.0.1 >NUL

                  echo Running HTTP test against http://localhost:8081 ...
                  curl -sSf http://localhost:8081 | find "Hello"
                  if errorlevel 1 (
                    echo TEST FAILED: Expected text not found in response
                    docker stop html-test
                    exit /b 1
                  )

                  echo Tests passed.
                  docker stop html-test
                '''
            }
        }

        stage('Load image into Minikube') {
            steps {
                bat '''
                  echo Loading image into Minikube: %IMAGE_NAME%:%IMAGE_TAG% ...
                  minikube image load %IMAGE_NAME%:%IMAGE_TAG%
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
                  echo Applying manifests...
                  kubectl apply -f k8s/deployment.yaml
                  kubectl apply -f k8s/service.yaml

                  echo Updating deployment image to %IMAGE_NAME%:%IMAGE_TAG% ...
                  kubectl set image deployment/html-site html-site=%IMAGE_NAME%:%IMAGE_TAG%

                  echo Waiting for rollout to complete...
                  kubectl rollout status deployment/html-site --timeout=60s

                  echo Pods after rollout:
                  kubectl get pods
                '''
            }
        }

                stage('Smoke test on Minikube') {
            steps {
                bat '''
                  echo Smoke test from inside Kubernetes pod...

                  for /f "delims=" %%i in ('kubectl get pods -l app=html-site -o jsonpath="{.items[0].metadata.name}"') do (
                    echo Using pod: %%i
                    kubectl exec %%i -- sh -c "wget -qO- http://localhost" | find "Hello"
                    if errorlevel 1 (
                      echo SMOKE TEST FAILED: Expected text not found in live pod
                      exit /b 1
                    )
                  )

                  echo Smoke test passed.
                '''
            }
        }
    }

    post {
        failure {
            bat '''
              echo Build FAILED. Attempting Kubernetes rollback...

              kubectl get deployment html-site >NUL 2>&1
              if errorlevel 1 (
                echo No deployment/html-site found. Skipping rollback.
                exit /b 0
              )

              echo Rolling back deployment/html-site to previous revision...
              kubectl rollout undo deployment/html-site || echo Rollback command failed.

              echo Rollback finished (if a previous revision existed).
            '''
        }
    }
}
