# Path to the certificate file
$CertPath = "elastic-ca.crt"

# Check if the certificate file exists
if (-Not (Test-Path $CertPath)) {
    Write-Error "Certificate file '$CertPath' not found."
    exit 1
}

# Import the certificate into the Local Machine Trusted Root Certification Authorities store
try {
    Import-Certificate -FilePath $CertPath -CertStoreLocation "Cert:\LocalMachine\Root" | Out-Null
    Write-Output "Certificate '$CertPath' installed as a trusted root CA."
} catch {
    Write-Error "Failed to install certificate: $_"
    exit 1
}