#!/usr/bin/env bash
set -euo pipefail

SMARTGIT_URL="https://download.smartgit.dev/smartgit/smartgit-25_1_100-linux-amd64.tar.gz"
INSTALL_DIR="$HOME/smartgit"

# Check if we're in WSL
if grep -qiE '(microsoft|wsl)' /proc/version 2>/dev/null; then
  echo "Detected WSL environment - installing to user directory"
  SUDO=""
  IS_WSL=true
else
  # Use sudo if needed on native Linux
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    SUDO="sudo"
  else
    SUDO=""
  fi
  IS_WSL=false
fi

if [[ "$IS_WSL" == false ]]; then
  echo "=== Updating package lists and installing prerequisites ==="
  $SUDO apt-get update -y
  $SUDO apt-get install -y software-properties-common wget tar

  echo "=== Adding Git Core PPA for latest Git ==="
  if ! grep -R "ppa.launchpadcontent.net/git-core/ppa" /etc/apt 2>/dev/null; then
    $SUDO add-apt-repository -y ppa:git-core/ppa
  fi

  echo "=== Updating package lists ==="
  $SUDO apt-get update -y

  echo "=== Installing latest Git, Git LFS, and OpenJDK 17 ==="
  $SUDO apt-get install -y git git-lfs openjdk-17-jdk
  
  echo "=== Installing Git LFS ==="
  git lfs install
else
  echo "=== WSL Environment - Installing packages via apt ==="
  echo "Checking for required commands..."
  
  MISSING_PACKAGES=()
  
  if ! command -v wget &> /dev/null; then
    echo "✗ wget not found"
    MISSING_PACKAGES+=(wget)
  else
    echo "✓ wget found"
  fi
  
  if ! command -v tar &> /dev/null; then
    echo "✗ tar not found"
    MISSING_PACKAGES+=(tar)
  else
    echo "✓ tar found"
  fi
  
  if ! command -v git &> /dev/null; then
    echo "✗ git not found"
    MISSING_PACKAGES+=(git)
  else
    echo "✓ git found"
  fi
  
  # Check for git-lfs separately since it's an extension
  if ! git lfs version &> /dev/null; then
    echo "✗ git-lfs not found"
    MISSING_PACKAGES+=(git-lfs)
  else
    echo "✓ git-lfs found"
  fi
  
  if ! command -v java &> /dev/null; then
    echo "✗ java not found"
    MISSING_PACKAGES+=(openjdk-17-jdk)
  else
    echo "✓ java found"
  fi
  
  if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
    echo ""
    echo "Installing missing packages: ${MISSING_PACKAGES[*]}"
    echo "This requires sudo access..."
    /usr/bin/sudo /usr/bin/apt-get update -y
    /usr/bin/sudo /usr/bin/apt-get install -y "${MISSING_PACKAGES[@]}"
    
    # Install git-lfs if it was just installed
    if [[ " ${MISSING_PACKAGES[*]} " =~ " git-lfs " ]]; then
      echo "=== Installing Git LFS ==="
      git lfs install
    fi
  else
    echo "All required packages are already installed"
  fi
fi

echo "=== Downloading SmartGit tarball ==="
TMP_TGZ="/tmp/${SMARTGIT_URL##*/}"
wget -O "$TMP_TGZ" "$SMARTGIT_URL"

echo "=== Extracting SmartGit to $INSTALL_DIR ==="
rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
tar -xzf "$TMP_TGZ" -C "$(dirname "$INSTALL_DIR")"
# Ensure correct permissions
chmod -R u+rwX "$INSTALL_DIR"

echo "=== Detecting JAVA_HOME for OpenJDK 17 ==="
if ! command -v java &> /dev/null; then
  echo "WARNING: Java not found. SmartGit requires Java to run."
  if [[ "$IS_WSL" == true ]]; then
    echo "In WSL, you can install Java with:"
    echo "  sudo apt-get update && sudo apt-get install -y openjdk-17-jdk"
    echo "Or download from: https://adoptium.net/"
  fi
  echo "Skipping Java configuration..."
  JAVA_HOME=""
else
  JAVA_BIN_PATH="$(readlink -f "$(command -v java)")"
  JAVA_HOME="$(dirname "$(dirname "$JAVA_BIN_PATH")")"
  echo "Detected JAVA_HOME = $JAVA_HOME"
  
  echo "=== Configuring SmartGit to use OpenJDK 17 ==="
  CONFIG_DIR="$HOME/.config/smartgit"
  VMOPTIONS_FILE="$CONFIG_DIR/smartgit.vmoptions"
  mkdir -p "$CONFIG_DIR"

  # Remove any existing jre= entry
  if [[ -f "$VMOPTIONS_FILE" ]]; then
    sed -i '/^jre=/d' "$VMOPTIONS_FILE"
  fi

  # Add new Java path
  echo "jre=$JAVA_HOME" >> "$VMOPTIONS_FILE"

  echo "Created $VMOPTIONS_FILE:"
  cat "$VMOPTIONS_FILE"
fi

echo "=== Creating smartgit launcher ==="
if [[ "$IS_WSL" == true ]]; then
  # In WSL, create launcher in user's local bin
  mkdir -p "$HOME/.local/bin"
  LAUNCHER="$HOME/.local/bin/smartgit"
  
  cat > "$LAUNCHER" <<EOF
#!/bin/bash
exec $INSTALL_DIR/bin/smartgit "\$@"
EOF
  
  chmod +x "$LAUNCHER"
  
  # Add to PATH if not already there
  if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    echo "Added $HOME/.local/bin to PATH in .bashrc"
  fi
else
  # Native Linux - use /usr/local/bin
  LAUNCHER="/usr/local/bin/smartgit"
  
  $SUDO bash -c "cat > $LAUNCHER" <<EOF
#!/bin/bash
exec $INSTALL_DIR/bin/smartgit "\$@"
EOF
  
  $SUDO chmod +x "$LAUNCHER"
fi

echo
echo "=== Installation complete! ==="
echo "SmartGit installed to: $INSTALL_DIR"
if [[ "$IS_WSL" == true ]]; then
  echo "Launcher created at: $LAUNCHER"
  if [[ -z "$JAVA_HOME" ]]; then
    echo ""
    echo "⚠️  IMPORTANT: Java is not installed!"
    echo "Install Java before running SmartGit:"
    echo "  sudo apt-get update && sudo apt-get install -y openjdk-17-jdk"
  else
    echo "Restart your shell or run: source ~/.bashrc"
    echo "Then start SmartGit by running: smartgit"
  fi
else
  echo "Start SmartGit by running: smartgit"
fi
