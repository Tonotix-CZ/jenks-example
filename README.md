    HTML-to-Kubernetes CI/CD Pipeline
Automated Docker Build • Automated Tests • Kubernetes Deployment • Smoke Tests • Auto-Rollback • GitHub Webhooks
This project demonstrates a full end-to-end CI/CD pipeline that deploys a simple HTML site to a live Kubernetes cluster using Jenkins, Docker, and Minikube.

    Overview:
Every push to the main branch triggers:
Jenkins automatic build via GitHub Webhook
Docker image build
Automated pre-deployment tests
Push image into Minikube
Kubernetes Deployment rolling update
In-cluster smoke test
Automatic rollback if anything fails
Optional: Local shortcut to open the deployed site
This makes it the perfect DevOps demonstration project for interviews and GitHub portfolio.

    Features:
- Fully automated CI/CD pipeline
Triggered via GitHub webhook → Jenkins pipeline → Minikube deployment.

- Docker-based HTML web app
A simple HTML page running on Nginx inside a Docker container.

- Automated integration tests
Before deployment, Jenkins runs:
A temporary container
HTTP request test
Verifies expected text "Hello" inside the page

- Kubernetes deployment
A rolling update pushes the new version of the site into Minikube.

- Smoke test inside Kubernetes
We curl the app from inside the pod, avoiding NodePort issues on Windows.

- Automatic rollback
If the deployment or smoke test fails:
kubectl rollout undo deployment/html-site

- Local viewing script (optional)
A open-html-site.ps1 script opens your live Minikube service in a browser.

    Architecture Diagram
          +-------------+
          |   GitHub    |
          |  (Pushes)   |
          +------+------+
                 |
                 v  Webhook
           +-----+-----+
           |  Jenkins  |
           | Pipeline  |
           +-----+-----+
                 |
       +---------+---------+
       |  Build Docker     |
       |  Run tests        |
       +---------+---------+
                 |
                 v
          +------+------+
          |  Minikube   |
          | Kubernetes  |
          +------+------+
                 |
      +----------+-----------+
      | Rolling Deployment   |
      | Pod Smoke Testing    |
      +----------+-----------+
                 |
                 v
        +--------+--------+
        |   Live Website   |
        +------------------+

📁 Repository Structure
jenks-example/
│
├── index.html               # Web app
├── Dockerfile               # Image build
├── Jenkinsfile              # Full CI/CD pipeline
│
└── k8s/
    ├── deployment.yaml      # Kubernetes deployment
    └── service.yaml         # Kubernetes service

    Jenkins Pipeline Highlights:
Triggered by GitHub push
triggers {
    githubPush()
}

Automated test before deployment
docker run -d --rm --name html-test -p 8081:80 %IMAGE_NAME%:%IMAGE_TAG%
curl -sSf http://localhost:8081 | find "Hello"

Deployment update
kubectl set image deployment/html-site html-site=%IMAGE_NAME%:%IMAGE_TAG%
kubectl rollout status deployment/html-site

In-cluster smoke test
kubectl exec <pod> -- sh -c "wget -qO- http://localhost" | find "Hello"

Auto-rollback
kubectl rollout undo deployment/html-site

    Viewing the Website:
Option A — Recommended
minikube service html-site-service
This opens the browser automatically.
Option B — Port forward
kubectl port-forward deployment/html-site 8080:80
Then open:
http://localhost:8080
