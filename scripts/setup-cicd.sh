#!/bin/bash
#
# Master CI/CD Setup Script
# This script orchestrates the complete CI/CD pipeline setup
#

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "========================================="
echo "CI/CD Pipeline Setup - Master Script"
echo "========================================="
echo "Project Root: $PROJECT_ROOT"
echo "Scripts Directory: $SCRIPT_DIR"
echo "========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "ERROR: This script must be run with sudo"
    echo "Usage: sudo ./scripts/setup-cicd.sh"
    exit 1
fi

# Function to print section headers
print_section() {
    echo ""
    echo "========================================="
    echo "$1"
    echo "========================================="
    echo ""
}

# Function to check if a command succeeded
check_status() {
    if [ $? -eq 0 ]; then
        echo "✓ $1 completed successfully"
    else
        echo "✗ $1 failed"
        exit 1
    fi
}

# Step 1: Install Liberty
print_section "Step 1: Installing Liberty 26.0.0.1"
if [ -d "/opt/liberty/wlp" ]; then
    echo "Liberty is already installed at /opt/liberty/wlp"
    read -p "Do you want to reinstall? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        $SCRIPT_DIR/install-liberty.sh
        check_status "Liberty installation"
    else
        echo "Skipping Liberty installation"
    fi
else
    $SCRIPT_DIR/install-liberty.sh
    check_status "Liberty installation"
fi

# Step 2: Install Jenkins
print_section "Step 2: Installing Jenkins"
if systemctl is-active --quiet jenkins; then
    echo "Jenkins is already installed and running"
    read -p "Do you want to reinstall? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        systemctl stop jenkins
        $SCRIPT_DIR/install-jenkins-rhel.sh
        check_status "Jenkins installation"
    else
        echo "Skipping Jenkins installation"
    fi
else
    $SCRIPT_DIR/install-jenkins-rhel.sh
    check_status "Jenkins installation"
fi

# Step 3: Wait for Jenkins to be fully ready
print_section "Step 3: Waiting for Jenkins to be ready"
echo "Waiting for Jenkins to fully start (this may take up to 2 minutes)..."
COUNTER=0
MAX_WAIT=120

while [ $COUNTER -lt $MAX_WAIT ]; do
    if curl -s http://localhost:8080 > /dev/null 2>&1; then
        echo "✓ Jenkins is ready!"
        break
    fi
    echo -n "."
    sleep 5
    COUNTER=$((COUNTER + 5))
done

if [ $COUNTER -ge $MAX_WAIT ]; then
    echo ""
    echo "⚠ Jenkins is taking longer than expected to start"
    echo "You can check the status with: sudo systemctl status jenkins"
fi

# Step 4: Display setup summary
print_section "Setup Complete!"

echo "Installation Summary:"
echo "--------------------"
echo ""

# Check Liberty
if [ -d "/opt/liberty/wlp" ]; then
    echo "✓ Liberty 26.0.0.1"
    echo "  Location: /opt/liberty/wlp"
    echo "  Version: $(/opt/liberty/wlp/bin/server version | head -1)"
else
    echo "✗ Liberty not found"
fi
echo ""

# Check Jenkins
if systemctl is-active --quiet jenkins; then
    echo "✓ Jenkins"
    echo "  Status: Running"
    echo "  URL: http://localhost:8080"
    if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
        echo "  Initial Password: $(cat /var/lib/jenkins/secrets/initialAdminPassword)"
    fi
else
    echo "✗ Jenkins not running"
fi
echo ""

echo "========================================="
echo "Next Steps:"
echo "========================================="
echo ""
echo "1. Access Jenkins:"
echo "   Open: http://localhost:8080"
echo "   Use the initial password shown above"
echo ""
echo "2. Configure Jenkins:"
echo "   - Install suggested plugins"
echo "   - Create admin user"
echo "   - Configure JDK and Maven paths"
echo ""
echo "3. Create Pipeline Job:"
echo "   - New Item → Pipeline"
echo "   - Name: PlantsByWebSphere-Pipeline"
echo "   - Pipeline from SCM → Git"
echo "   - Repository: https://github.com/IBMTechSales/liberty_admin_pot_src.git"
echo "   - Script Path: Jenkinsfile"
echo ""
echo "4. Run the Pipeline:"
echo "   - Click 'Build Now'"
echo "   - Monitor the build progress"
echo ""
echo "For detailed instructions, see:"
echo "  - QUICK-START.md"
echo "  - CI-CD-SETUP.md"
echo ""
echo "========================================="

exit 0

# Made with Bob
