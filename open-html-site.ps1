# open-html-site.ps1
Write-Host "Starting Minikube service for html-site-service..."

# This will print the URL and try to open a browser
$serviceOutput = minikube service html-site-service --url 2>&1

Write-Host $serviceOutput

# Try to extract a URL and open it
$url = ($serviceOutput | Select-String -Pattern "http://.*").Matches.Value | Select-Object -First 1

if ($url) {
    Write-Host "Opening browser at $url"
    Start-Process $url
} else {
    Write-Host "Could not detect URL from minikube output."
}
