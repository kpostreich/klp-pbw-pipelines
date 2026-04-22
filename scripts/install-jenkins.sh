#!/bin/bash
#
# Jenkins Installation Script for Ubuntu/Debian Linux
# This script installs Jenkins and required dependencies
#

set -e  # Exit on error

echo "========================================="
echo "Jenkins Installation Script"
echo "========================================="
echo "This script will install:"
echo "  - Java 11 (OpenJDK)"
echo "  - Maven"
echo "  - Jenkins LTS"
echo "========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "ERROR: This script must be run as root (use sudo)"
    exit 1
fi

# Update system packages
echo "Step 1: Updating system packages..."
apt-get update -y

# Install Java 11
echo ""
echo "Step 2: Installing Java 11..."
apt-get install -y openjdk-11-jdk

# Verify Java installation
java -version
echo "Java installed successfully"

# Install Maven
echo ""
echo "Step 3: Installing Maven..."
apt-get install -y maven

# Verify Maven installation
mvn -version
echo "Maven installed successfully"

# Install required tools
echo ""
echo "Step 4: Installing required tools..."
apt-get install -y curl wget gnupg2 software-properties-common apt-transport-https ca-certificates

# Add Jenkins repository
echo ""
echo "Step 5: Adding Jenkins repository..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package list
apt-get update -y

# Install Jenkins
echo ""
echo "Step 6: Installing Jenkins..."
apt-get install -y jenkins

# Start Jenkins service
echo ""
echo "Step 7: Starting Jenkins service..."
systemctl start jenkins
systemctl enable jenkins

# Wait for Jenkins to start
echo ""
echo "Step 8: Waiting for Jenkins to start..."
sleep 30

# Get initial admin password
echo ""
echo "========================================="
echo "Jenkins Installation Complete!"
echo "========================================="
echo ""
echo "Jenkins is now running on: http://localhost:8080"
echo ""
echo "Initial Admin Password:"
echo "----------------------------------------"
cat /var/lib/jenkins/secrets/initialAdminPassword
echo ""
echo "----------------------------------------"
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
echo "========================================="

exit 0

# Made with Bob
