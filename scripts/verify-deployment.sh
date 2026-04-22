#!/bin/bash
#
# Liberty Deployment Verification Script
# This script verifies that the Liberty server is running and the application is accessible
#

set -e  # Exit on error

# Input parameters
LIBERTY_HOME=$1
SERVER_NAME=$2

# Configuration
HTTP_PORT=9080
HTTPS_PORT=9443
APP_CONTEXT="plantsbywebsphere"
MAX_RETRIES=30
RETRY_DELAY=5

# Validate inputs
if [ -z "$LIBERTY_HOME" ] || [ -z "$SERVER_NAME" ]; then
    echo "ERROR: Missing required parameters"
    echo "Usage: $0 <LIBERTY_HOME> <SERVER_NAME>"
    exit 1
fi

echo "========================================="
echo "Liberty Deployment Verification"
echo "========================================="
echo "Liberty Home: $LIBERTY_HOME"
echo "Server Name: $SERVER_NAME"
echo "========================================="

# Test 1: Check if server is running
echo ""
echo "Test 1: Checking server status..."
if $LIBERTY_HOME/bin/server status $SERVER_NAME 2>&1 | grep -q "is running"; then
    echo "✓ Server is running"
else
    echo "✗ Server is not running"
    echo "Server status:"
    $LIBERTY_HOME/bin/server status $SERVER_NAME
    exit 1
fi

# Test 2: Check server logs for errors
echo ""
echo "Test 2: Checking server logs for errors..."
LOG_FILE="$LIBERTY_HOME/usr/servers/$SERVER_NAME/logs/messages.log"

if [ -f "$LOG_FILE" ]; then
    ERROR_COUNT=$(grep -c "ERROR" "$LOG_FILE" 2>/dev/null || echo "0")
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo "⚠ Found $ERROR_COUNT error(s) in server logs"
        echo "Last 10 errors:"
        grep "ERROR" "$LOG_FILE" | tail -10
    else
        echo "✓ No errors found in server logs"
    fi
else
    echo "⚠ Log file not found: $LOG_FILE"
fi

# Test 3: Check if HTTP port is listening
echo ""
echo "Test 3: Checking if HTTP port $HTTP_PORT is listening..."
if netstat -tuln 2>/dev/null | grep -q ":$HTTP_PORT " || ss -tuln 2>/dev/null | grep -q ":$HTTP_PORT "; then
    echo "✓ HTTP port $HTTP_PORT is listening"
else
    echo "✗ HTTP port $HTTP_PORT is not listening"
    exit 1
fi

# Test 4: Check if HTTPS port is listening
echo ""
echo "Test 4: Checking if HTTPS port $HTTPS_PORT is listening..."
if netstat -tuln 2>/dev/null | grep -q ":$HTTPS_PORT " || ss -tuln 2>/dev/null | grep -q ":$HTTPS_PORT "; then
    echo "✓ HTTPS port $HTTPS_PORT is listening"
else
    echo "⚠ HTTPS port $HTTPS_PORT is not listening (may not be configured)"
fi

# Test 5: Check application accessibility
echo ""
echo "Test 5: Checking application accessibility..."
APP_URL="http://localhost:$HTTP_PORT/$APP_CONTEXT"

RETRY_COUNT=0
APP_ACCESSIBLE=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL" 2>/dev/null || echo "000")
    
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
        echo "✓ Application is accessible (HTTP $HTTP_CODE)"
        APP_ACCESSIBLE=true
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo "  Attempt $RETRY_COUNT/$MAX_RETRIES: HTTP $HTTP_CODE - Retrying in $RETRY_DELAY seconds..."
            sleep $RETRY_DELAY
        fi
    fi
done

if [ "$APP_ACCESSIBLE" = false ]; then
    echo "✗ Application is not accessible after $MAX_RETRIES attempts"
    echo "  URL: $APP_URL"
    echo "  Last HTTP Code: $HTTP_CODE"
    exit 1
fi

# Test 6: Check application response content
echo ""
echo "Test 6: Checking application response content..."
RESPONSE=$(curl -s "$APP_URL" 2>/dev/null || echo "")

if echo "$RESPONSE" | grep -qi "plants"; then
    echo "✓ Application response contains expected content"
else
    echo "⚠ Application response may not contain expected content"
    echo "  First 200 characters of response:"
    echo "$RESPONSE" | head -c 200
fi

# Display summary
echo ""
echo "========================================="
echo "Verification Summary"
echo "========================================="
echo "Server Status: Running ✓"
echo "HTTP Port: Listening ✓"
echo "Application: Accessible ✓"
echo ""
echo "Application URLs:"
echo "  HTTP:  http://localhost:$HTTP_PORT/$APP_CONTEXT"
echo "  HTTPS: https://localhost:$HTTPS_PORT/$APP_CONTEXT"
echo ""
echo "Server Logs:"
echo "  Messages: $LIBERTY_HOME/usr/servers/$SERVER_NAME/logs/messages.log"
echo "  Console:  $LIBERTY_HOME/usr/servers/$SERVER_NAME/logs/console.log"
echo "========================================="
echo "✓ All verification tests passed!"
echo "========================================="

exit 0

# Made with Bob
