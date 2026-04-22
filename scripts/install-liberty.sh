#!/bin/bash
#
# Liberty 26.0.0.1 Installation Script
# This script downloads and installs Open Liberty 26.0.0.1
#

set -e  # Exit on error

# Configuration
LIBERTY_VERSION="26.0.0.1"
LIBERTY_DOWNLOAD_URL="https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/runtime/release/${LIBERTY_VERSION}/openliberty-${LIBERTY_VERSION}.zip"
INSTALL_DIR="/opt/liberty"
LIBERTY_HOME="${INSTALL_DIR}/wlp"

echo "========================================="
echo "Liberty ${LIBERTY_VERSION} Installation"
echo "========================================="
echo "Installation directory: ${INSTALL_DIR}"
echo "Liberty home: ${LIBERTY_HOME}"
echo "========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "ERROR: This script must be run as root (use sudo)"
    exit 1
fi

# Check if Liberty is already installed
if [ -d "${LIBERTY_HOME}" ]; then
    echo "WARNING: Liberty appears to be already installed at ${LIBERTY_HOME}"
    read -p "Do you want to reinstall? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled"
        exit 0
    fi
    echo "Backing up existing installation..."
    BACKUP_DIR="${INSTALL_DIR}/wlp_backup_$(date +%Y%m%d_%H%M%S)"
    mv "${LIBERTY_HOME}" "${BACKUP_DIR}"
    echo "Backup created at: ${BACKUP_DIR}"
fi

# Create installation directory
echo "Step 1: Creating installation directory..."
mkdir -p ${INSTALL_DIR}
cd ${INSTALL_DIR}
echo "Installation directory created"
echo ""

# Download Liberty
echo "Step 2: Downloading Liberty ${LIBERTY_VERSION}..."
echo "URL: ${LIBERTY_DOWNLOAD_URL}"
wget -q --show-progress ${LIBERTY_DOWNLOAD_URL} -O openliberty-${LIBERTY_VERSION}.zip

if [ ! -f "openliberty-${LIBERTY_VERSION}.zip" ]; then
    echo "ERROR: Failed to download Liberty"
    exit 1
fi

echo "Download completed"
echo ""

# Extract Liberty
echo "Step 3: Extracting Liberty..."
unzip -q openliberty-${LIBERTY_VERSION}.zip
echo "Liberty extracted successfully"
echo ""

# Verify extraction
if [ ! -d "${LIBERTY_HOME}" ]; then
    echo "ERROR: Liberty home directory not found after extraction"
    exit 1
fi

# Set permissions
echo "Step 4: Setting permissions..."
chown -R $(logname):$(logname) ${INSTALL_DIR}
chmod -R 755 ${LIBERTY_HOME}
echo "Permissions set"
echo ""

# Clean up download
echo "Step 5: Cleaning up..."
rm openliberty-${LIBERTY_VERSION}.zip
echo "Cleanup completed"
echo ""

# Verify installation
echo "Step 6: Verifying installation..."
${LIBERTY_HOME}/bin/server version
echo ""

# Create servers directory
echo "Step 7: Creating servers directory..."
mkdir -p ${LIBERTY_HOME}/usr/servers
chown -R $(logname):$(logname) ${LIBERTY_HOME}/usr/servers
echo "Servers directory created"
echo ""

# Display installation summary
echo "========================================="
echo "Liberty Installation Complete!"
echo "========================================="
echo ""
echo "Liberty Version: ${LIBERTY_VERSION}"
echo "Liberty Home: ${LIBERTY_HOME}"
echo "Server Binary: ${LIBERTY_HOME}/bin/server"
echo "Servers Directory: ${LIBERTY_HOME}/usr/servers"
echo ""
echo "Common Commands:"
echo "  Create server:  ${LIBERTY_HOME}/bin/server create myServer"
echo "  Start server:   ${LIBERTY_HOME}/bin/server start myServer"
echo "  Stop server:    ${LIBERTY_HOME}/bin/server stop myServer"
echo "  Server status:  ${LIBERTY_HOME}/bin/server status myServer"
echo "  Server version: ${LIBERTY_HOME}/bin/server version"
echo ""
echo "Environment Variable (add to ~/.bashrc):"
echo "  export LIBERTY_HOME=${LIBERTY_HOME}"
echo "  export PATH=\$PATH:\$LIBERTY_HOME/bin"
echo ""
echo "Documentation:"
echo "  https://openliberty.io/docs/"
echo "========================================="

exit 0

# Made with Bob
