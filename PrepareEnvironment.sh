#!/usr/bin/env bash
set -euo pipefail

echo "=== Updating package lists and installing prerequisites ==="
sudo apt-get update -y
sudo apt-get install -y software-properties-common wget tar

echo "=== Adding Git Core PPA for latest Git ==="
if ! grep -R "ppa.launchpadcontent.net/git-core/ppa" /etc/apt 2>/dev/null; then
    sudo add-apt-repository -y ppa:git-core/ppa
fi

echo "=== Updating package lists ==="
sudo apt-get update -y

echo "=== Installing latest Git, Git LFS, and OpenJDK 21 ==="
sudo apt-get install -y git git-lfs openjdk-21-jdk

echo "=== Installing Git LFS ==="
git lfs install
