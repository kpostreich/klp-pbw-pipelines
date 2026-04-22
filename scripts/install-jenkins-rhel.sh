#!/bin/bash
#
# Jenkins Installation Script for RHEL 9
# This script installs Jenkins and required dependencies on RHEL/CentOS
#

set -e  # Exit on error

echo "========================================="
echo "Jenkins Installation Script for RHEL 9"
echo "========================================="
echo "This script will install:"
echo "  - Java 11 (if not present)"
echo "  - Jenkins LTS"
echo "  - Required dependencies"
echo "========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "ERROR: This script must be run as root (use sudo)"
    exit 1
fi

# Check RHEL version
echo "Step 1: Checking system version..."
if [ -f /etc/redhat-release ]; then
    cat /etc/redhat-release
else
    echo "WARNING: This script is designed for RHEL/CentOS"
fi
echo ""

# Update system packages
echo "Step 2: Updating system packages (skipping problematic packages)..."
dnf update -y --skip-broken || echo "Warning: Some packages could not be updated, continuing..."
echo "System packages updated"
echo ""

# Install Java 11 if not present
echo "Step 3: Checking Java installation..."
if ! command -v java &> /dev/null; then
    echo "Installing Java 11..."
    dnf install -y java-11-openjdk java-11-openjdk-devel
else
    echo "Java is already installed:"
    java -version
fi
echo ""

# Install required tools
echo "Step 4: Installing required tools..."
dnf install -y wget curl git fontconfig
echo "Required tools installed"
echo ""

# Add Jenkins repository
echo "Step 5: Adding Jenkins repository..."
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
echo "Jenkins repository added"
echo ""

# Install Jenkins
echo "Step 6: Installing Jenkins..."
dnf install -y jenkins
echo "Jenkins installed successfully"
echo ""

# Configure firewall (if firewalld is running)
echo "Step 7: Configuring firewall..."
if systemctl is-active --quiet firewalld; then
    echo "Firewalld is active, opening port 8080..."
    firewall-cmd --permanent --add-port=8080/tcp
    firewall-cmd --reload
    echo "Firewall configured"
else
    echo "Firewalld is not active, skipping firewall configuration"
fi
echo ""

# Start and enable Jenkins
echo "Step 8: Starting Jenkins service..."
systemctl daemon-reload
systemctl start jenkins
systemctl enable jenkins
echo "Jenkins service started and enabled"
echo ""

# Wait for Jenkins to start
echo "Step 9: Waiting for Jenkins to start..."
sleep 30

# Check Jenkins status
echo "Step 10: Checking Jenkins status..."
systemctl status jenkins --no-pager | head -10
echo ""

# Get initial admin password
echo "========================================="
echo "Jenkins Installation Complete!"
echo "========================================="
echo ""
echo "Jenkins is now running on: http://localhost:8080"
echo ""

if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    echo "Initial Admin Password:"
    echo "----------------------------------------"
    cat /var/lib/jenkins/secrets/initialAdminPassword
    echo ""
    echo "----------------------------------------"
else
    echo "WARNING: Initial admin password file not found"
    echo "It may take a few more seconds for Jenkins to fully start"
    echo "Check: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
fi

echo ""
echo "Next Steps:"
echo "1. Open http://localhost:8080 in your browser"
echo "2. Enter the initial admin password shown above"
echo "3. Install suggested plugins"
echo "4. Create your first admin user"
echo "5. Configure Jenkins"
echo ""
echo "Jenkins Service Commands:"
echo "  Start:   sudo systemctl start jenkins"
echo "  Stop:    sudo systemctl stop jenkins"
echo "  Restart: sudo systemctl restart jenkins"
echo "  Status:  sudo systemctl status jenkins"
echo ""
echo "Jenkins Logs:"
echo "  sudo journalctl -u jenkins -f"
echo ""
echo "Jenkins Home Directory:"
echo "  /var/lib/jenkins"
echo "========================================="

exit 0

# Made with Bob
