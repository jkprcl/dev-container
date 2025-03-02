Write-Host "Starting build"
$DevUser = 'jack'
$ImageName = 'dev-container'
& podman build --build-arg DEV_USER="$($DevUser)" -f .\dockerfile -t "$($ImageName)" .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed, podman returned exit code [$($LASTEXITCODE)]"
    exit 1
}
Write-Host 'Build successful!'
exit 0
