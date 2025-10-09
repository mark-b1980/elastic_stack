#!/bin/bash
CERT_FILE="elastic-ca.crt"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root." >&2
    exit 1
fi

# Change directory to script location
script_dir=$(dirname "$0")
cd "$script_dir"

# Copy certificate to trusted store
cp "$CERT_FILE" /usr/local/share/ca-certificates/
    chmod 644 /usr/local/share/ca-certificates/$CERT_FILE

# Update CA certificates
update-ca-certificates

echo "Certificate installed as trusted system-wide."
