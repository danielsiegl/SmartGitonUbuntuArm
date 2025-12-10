#!/usr/bin/env bash
set -euo pipefail

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
