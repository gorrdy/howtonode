#!/bin/bash

# Ensure the script is run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root using: sudo ./install-bitcoin-core.sh <version>"
  exit 1
fi

# Check if version argument is provided
if [ -z "$1" ]; then
  echo "Usage: sudo ./install-bitcoin-core.sh <version>"
  exit 1
fi

VERSION="$1"

echo "Updating package lists..."
sleep 1
apt update

echo "Downloading Bitcoin Core version $VERSION tarball..."
sleep 1
wget "https://bitcoincore.org/bin/bitcoin-core-${VERSION}/bitcoin-${VERSION}-x86_64-linux-gnu.tar.gz"

echo "Downloading SHA256SUMS and signature file..."
sleep 1
wget "https://bitcoincore.org/bin/bitcoin-core-${VERSION}/SHA256SUMS"
wget "https://bitcoincore.org/bin/bitcoin-core-${VERSION}/SHA256SUMS.asc"

echo "Verifying SHA256 checksums..."
sleep 1
sha256sum --ignore-missing --check SHA256SUMS

echo "Importing Bitcoin Core GPG signing keys..."
sleep 1
curl -s "https://api.github.com/repositories/355107265/contents/builder-keys" | grep download_url | grep -oE "https://[a-zA-Z0-9./-]+" | while read url; do curl -s "$url" | gpg --import; done

echo "Verifying signature of SHA256SUMS.asc..."
sleep 1
gpg --verify SHA256SUMS.asc 

echo "Extracting Bitcoin Core binaries..."
sleep 1
tar -xvf "bitcoin-${VERSION}-x86_64-linux-gnu.tar.gz"

echo "Installing Bitcoin Core binaries to /usr/local/bin..."
sleep 1
install -m 0755 -o root -g root -t /usr/local/bin "bitcoin-${VERSION}/bin/"*

echo "Removing tarball and SHA256 files..."
sleep 1
rm -f "bitcoin-${VERSION}-x86_64-linux-gnu.tar.gz" SHA256SUMS SHA256SUMS.asc

echo "Checking installed bitcoin-cli version..."
sleep 1
bitcoin-cli --version
