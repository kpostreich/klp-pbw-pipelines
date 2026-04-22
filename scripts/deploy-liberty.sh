#!/bin/bash
#
# Liberty Deployment Script
# This script deploys a Liberty server package to the Liberty installation
#

set -e  # Exit on error

# Input parameters
LIBERTY_HOME=$1
SERVER_NAME=$2
SERVER_PACKAGE=$3

# Validate inputs
if [ -z "$LIBERTY_HOME" ] || [ -z "$SERVER_NAME" ] || [ -z "$SERVER_PACKAGE" ]; then
    echo "ERROR: Missing required parameters"
    echo "Usage: $0 <LIBERTY_HOME> <SERVER_NAME> <SERVER_PACKAGE>"
    echo "Example: $0 /opt/liberty/wlp pbwServerX /path/to/server.zip"
    exit 1
fi

echo "========================================="
echo "Liberty Deployment Script"
echo "========================================="
echo "Liberty Home: $LIBERTY_HOME"
echo "Server Name: $SERVER_NAME"
echo "Server Package: $SERVER_PACKAGE"
echo "========================================="

# Check if Liberty is installed
if [ ! -d "$LIBERTY_HOME" ]; then
    echo "ERROR: Liberty home directory not found: $LIBERTY_HOME"
    exit 1
fi

# Check if server package exists
if [ ! -f "$SERVER_PACKAGE" ]; then
    echo "ERROR: Server package not found: $SERVER_PACKAGE"
    exit 1
fi

# Stop the server if it's running
echo ""
echo "Step 1: Stopping Liberty server..."
if [ -d "$LIBERTY_HOME/usr/servers/$SERVER_NAME" ]; then
    $LIBERTY_HOME/bin/server stop $SERVER_NAME || true
    echo "Server stopped (or was not running)"
else
    echo "Server directory does not exist yet"
fi

# Backup existing server
echo ""
echo "Step 2: Backing up existing server..."
if [ -d "$LIBERTY_HOME/usr/servers/$SERVER_NAME" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR="$LIBERTY_HOME/usr/servers/${SERVER_NAME}_backup_$TIMESTAMP"
    
    echo "Creating backup: $BACKUP_DIR"
    mv "$LIBERTY_HOME/usr/servers/$SERVER_NAME" "$BACKUP_DIR"
    echo "Backup created successfully"
    
    # Keep only last 5 backups
    echo "Cleaning up old backups (keeping last 5)..."
    ls -dt $LIBERTY_HOME/usr/servers/${SERVER_NAME}_backup_* 2>/dev/null | tail -n +6 | xargs rm -rf 2>/dev/null || true
else
    echo "No existing server to backup"
fi

# Extract new server package
echo ""
echo "Step 3: Extracting server package..."
cd $LIBERTY_HOME
unzip -q "$SERVER_PACKAGE"
echo "Server package extracted successfully"

# Verify extraction
if [ ! -d "$LIBERTY_HOME/usr/servers/$SERVER_NAME" ]; then
    echo "ERROR: Server directory not found after extraction"
    exit 1
fi

# Set permissions
echo ""
echo "Step 4: Setting permissions..."
chmod -R 755 $LIBERTY_HOME/usr/servers/$SERVER_NAME
echo "Permissions set successfully"

# Start the server
echo ""
echo "Step 5: Starting Liberty server..."
$LIBERTY_HOME/bin/server start $SERVER_NAME

# Wait for server to start
echo ""
echo "Step 6: Waiting for server to start..."
TIMEOUT=120
COUNTER=0
STARTED=false

while [ $COUNTER -lt $TIMEOUT ]; do
    if $LIBERTY_HOME/bin/server status $SERVER_NAME 2>&1 | grep -q "is running"; then
        echo "Server started successfully!"
        STARTED=true
        break
    fi
    
    echo -n "."
    sleep 2
    COUNTER=$((COUNTER + 2))
done

echo ""

if [ "$STARTED" = false ]; then
    echo "ERROR: Server failed to start within $TIMEOUT seconds"
    echo "Check server logs at: $LIBERTY_HOME/usr/servers/$SERVER_NAME/logs/"
    exit 1
fi

# Display server information
echo ""
echo "========================================="
echo "Deployment completed successfully!"
echo "========================================="
echo "Server Name: $SERVER_NAME"
echo "Server Status: Running"
echo "Server Directory: $LIBERTY_HOME/usr/servers/$SERVER_NAME"
echo "Server Logs: $LIBERTY_HOME/usr/servers/$SERVER_NAME/logs/"
echo ""
echo "Application URLs:"
echo "  HTTP:  http://localhost:9080/plantsbywebsphere"
echo "  HTTPS: https://localhost:9443/plantsbywebsphere"
echo "========================================="

exit 0

# Made with Bob
