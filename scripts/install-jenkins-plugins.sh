#!/bin/bash
#
# Install Compatible Jenkins Plugins for Jenkins 2.452.4
# This script installs only essential plugins compatible with Jenkins 2.452.4 LTS
#

set -e

echo "========================================="
echo "Jenkins Plugin Installation"
echo "========================================="
echo "Installing plugins compatible with Jenkins 2.452.4 LTS"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "ERROR: This script must be run with sudo"
    exit 1
fi

# Jenkins details
JENKINS_HOME="/var/lib/jenkins"
JENKINS_URL="http://localhost:8080"
JENKINS_CLI="$JENKINS_HOME/jenkins-cli.jar"
PLUGIN_DIR="$JENKINS_HOME/plugins"

# Wait for Jenkins to be ready
echo "Step 1: Waiting for Jenkins to be ready..."
COUNTER=0
MAX_WAIT=60
while [ $COUNTER -lt $MAX_WAIT ]; do
    if curl -s $JENKINS_URL > /dev/null 2>&1; then
        echo "✓ Jenkins is ready"
        break
    fi
    echo -n "."
    sleep 2
    COUNTER=$((COUNTER + 2))
done

if [ $COUNTER -ge $MAX_WAIT ]; then
    echo "✗ Jenkins is not responding"
    exit 1
fi
echo ""

# Download Jenkins CLI
echo "Step 2: Downloading Jenkins CLI..."
if [ ! -f "$JENKINS_CLI" ]; then
    wget -q -O "$JENKINS_CLI" "$JENKINS_URL/jnlpJars/jenkins-cli.jar"
    echo "✓ Jenkins CLI downloaded"
else
    echo "✓ Jenkins CLI already exists"
fi
echo ""

# Essential plugins for our pipeline (compatible versions)
echo "Step 3: Installing essential plugins..."
echo "Note: Installing specific versions compatible with Jenkins 2.452.4"
echo ""

# Core plugins needed for Git pipeline
PLUGINS=(
    "git:5.2.2"
    "git-client:5.0.0"
    "workflow-aggregator:596.v8c21c963d92d"
    "pipeline-stage-view:2.34"
    "credentials:1371.vfee6b_095f0a_3"
    "credentials-binding:681.vf91669a_32e45"
)

cd "$JENKINS_HOME"

for plugin in "${PLUGINS[@]}"; do
    plugin_name=$(echo $plugin | cut -d: -f1)
    plugin_version=$(echo $plugin | cut -d: -f2)
    
    echo "Installing $plugin_name:$plugin_version..."
    
    # Download plugin directly
    wget -q -O "$PLUGIN_DIR/${plugin_name}.jpi" \
        "https://updates.jenkins.io/download/plugins/${plugin_name}/${plugin_version}/${plugin_name}.hpi" || \
        echo "  Warning: Could not download $plugin_name:$plugin_version"
done

echo ""
echo "Step 4: Setting permissions..."
chown -R jenkins:jenkins "$PLUGIN_DIR"
echo "✓ Permissions set"
echo ""

echo "========================================="
echo "Plugin Installation Complete"
echo "========================================="
echo ""
echo "Jenkins needs to be restarted to load the plugins."
echo "Run: sudo systemctl restart jenkins"
echo ""
echo "After restart, you can:"
echo "1. Access Jenkins at: http://localhost:8080"
echo "2. Complete the initial setup wizard"
echo "3. Skip additional plugin installation"
echo "4. Create your pipeline job"
echo ""

# Made with Bob
