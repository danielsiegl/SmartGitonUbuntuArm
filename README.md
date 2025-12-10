# SmartGit 25.1 on Ubuntu 25.10 arm64/aarch64 e.g. Raspberry Pi 5 or Parallels on Apple M1/M2/M3/..

This is our guide to installing SmartGit 25.10 on arm64/aarch64 Linux devices. 
We tested this procedure on a Raspberry Pi 5 with Ubuntu 25.10 and with Ubuntu 24.04 inside Parallels on a Apple M2 Pro Mac.
It might work on other Linux/Debian/Ubuntu Versions in a similar fashion - but we only tried it in this combination for now.

## Preparing the Environment

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

## Installing SmartGit

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