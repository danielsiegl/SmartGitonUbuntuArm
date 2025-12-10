# SmartGit 25.1 on Ubuntu ARM64/AArch64

This guide provides instructions for installing SmartGit 25.1 on ARM64/AArch64 Linux devices. 
The installation has been tested and verified on:
- Raspberry Pi 5 with Ubuntu 25.10
- Ubuntu 24.04 running in Parallels on Apple M2 Pro Mac

While the procedure should work on other Linux/Debian/Ubuntu versions, compatibility has only been verified with the configurations listed above.

## Overview
SmartGit can run on ARM64 or AArch64 based Linux systems as it is a Java application. The installation requires providing ARM64-compatible dependencies.

### Prerequisites

#### Git
Ensure Git and Git LFS are installed on your system.

#### Java
OpenJDK 21 is recommended for running SmartGit on AArch64 architecture.

### Installation Steps

1. **Download SmartGit**  
   Download and extract the SmartGit `.tar` archive from [www.smartgit.dev](https://www.smartgit.dev) to your preferred installation directory.

2. **Strip Bundled Components (Optional)**  
   Remove the `/jre` and `/git` directories from your installation directory to use the system-provided versions.

3. **Create Desktop Shortcut**  
   Execute `add-menuitem.sh` from the `bin` directory within your installation path to create a desktop shortcut.

## Scripts
### Preparing the Environment

See [PrepareEnvironment.sh](PrepareEnvironment.sh)

```sh
#!/usr/bin/env bash

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
```

### Installing SmartGit

See [InstallSmartGitarm64.sh](InstallSmartGitarm64.sh)

```sh
#!/usr/bin/env bash

SMARTGIT_URL="https://download.smartgit.dev/smartgit/smartgit-25_1_100-linux-amd64.tar.gz" # we use the amd64 archive and will modify it to work with arm64
INSTALL_DIR="/opt/smartgit"

echo "=== Downloading SmartGit tarball ==="
TMP_TGZ="/tmp/${SMARTGIT_URL##*/}"
wget -O "$TMP_TGZ" "$SMARTGIT_URL"

echo "=== Extracting SmartGit to $INSTALL_DIR ==="
sudo rm -rf "$INSTALL_DIR"
sudo mkdir -p "$INSTALL_DIR"
sudo tar -xzf "$TMP_TGZ" -C "$(dirname "$INSTALL_DIR")"
# Ensure correct permissions
sudo chmod -R u+rwX "$INSTALL_DIR"
sudo ln -s "$INSTALL_DIR" /usr/local/bin/smartgit
echo "=== Removing JDK and Git from $INSTALL_DIR ==="
sudo rm -rf "$INSTALL_DIR/git"
sudo rm -rf "$INSTALL_DIR/jre"

echo "=== Create Shortcut ==="
sudo bash "$INSTALL_DIR/bin/add-menuitem.sh"

echo "=== Finished Installing ==="
```