# CI/CD Pipeline Setup Guide - MVP

This guide provides step-by-step instructions to set up a minimal viable CI/CD pipeline for the PlantsByWebSphere application using Jenkins on a Linux VM.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Architecture Overview](#architecture-overview)
3. [Installation Steps](#installation-steps)
4. [Jenkins Configuration](#jenkins-configuration)
5. [Running the Pipeline](#running-the-pipeline)
6. [Troubleshooting](#troubleshooting)
7. [Maintenance](#maintenance)

---

## 🔧 Prerequisites

### System Requirements

- **Operating System**: Ubuntu 20.04+ or RHEL 8+
- **RAM**: Minimum 4GB (8GB recommended)
- **Disk Space**: Minimum 20GB free
- **CPU**: 2+ cores
- **Network**: Internet access for downloading dependencies

### Required Software

The following will be installed by the setup scripts:
- Java 11 (OpenJDK)
- Maven 3.6+
- Jenkins LTS
- Git

### Liberty Installation

Liberty 26.0.0.1 should be installed at: `/opt/liberty/wlp`

If not installed, download and extract:
```bash
# Download Liberty
wget https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/runtime/release/26.0.0.1/openliberty-26.0.0.1.zip

# Extract to /opt
sudo mkdir -p /opt/liberty
sudo unzip openliberty-26.0.0.1.zip -d /opt/liberty

# Verify installation
/opt/liberty/wlp/bin/server version
```

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     CI/CD Pipeline Flow                      │
└─────────────────────────────────────────────────────────────┘

    ┌──────────────┐
    │   GitHub     │
    │  Repository  │
    └──────┬───────┘
           │
           │ Manual Trigger
           ▼
    ┌──────────────┐
    │   Jenkins    │
    │   Pipeline   │
    └──────┬───────┘
           │
           ├─► Stage 1: Checkout Source
           ├─► Stage 2: Build (Maven)
           ├─► Stage 3: Unit Tests
           ├─► Stage 4: Package (WAR/EAR)
           ├─► Stage 5: Create Liberty Package
           ├─► Stage 6: Deploy to Liberty
           └─► Stage 7: Verify Deployment
           
    ┌──────────────┐
    │   Liberty    │
    │   Server     │
    │  26.0.0.1    │
    └──────────────┘
```

---

## 📦 Installation Steps

### Step 1: Clone the Repository

```bash
cd ~
git clone https://github.com/IBMTechSales/liberty_admin_pot_src.git
cd liberty_admin_pot_src
```

### Step 2: Make Scripts Executable

```bash
chmod +x scripts/*.sh
```

### Step 3: Install Jenkins

Run the Jenkins installation script:

```bash
sudo ./scripts/install-jenkins.sh
```

This script will:
- Install Java 11
- Install Maven
- Install Jenkins LTS
- Start Jenkins service
- Display the initial admin password

**Expected Output:**
```
========================================
Jenkins Installation Complete!
========================================

Jenkins is now running on: http://localhost:8080

Initial Admin Password:
----------------------------------------
[YOUR-INITIAL-PASSWORD-HERE]
----------------------------------------
```

**Important:** Save the initial admin password displayed at the end!

### Step 4: Access Jenkins

1. Open your browser and navigate to: `http://localhost:8080`
2. Enter the initial admin password
3. Click "Install suggested plugins"
4. Wait for plugins to install (5-10 minutes)
5. Create your first admin user:
   - Username: `admin`
   - Password: `[choose a secure password]`
   - Full name: `Jenkins Admin`
   - Email: `admin@example.com`
6. Keep the default Jenkins URL: `http://localhost:8080/`
7. Click "Start using Jenkins"

---

## ⚙️ Jenkins Configuration

### Step 1: Configure Java and Maven

1. Go to **Manage Jenkins** → **Global Tool Configuration**

2. **JDK Configuration:**
   - Click "Add JDK"
   - Name: `JDK-11`
   - Uncheck "Install automatically"
   - JAVA_HOME: `/usr/lib/jvm/java-11-openjdk-amd64`

3. **Maven Configuration:**
   - Click "Add Maven"
   - Name: `Maven-3.9`
   - Uncheck "Install automatically"
   - MAVEN_HOME: `/usr/share/maven`

4. Click **Save**

### Step 2: Install Required Plugins

1. Go to **Manage Jenkins** → **Manage Plugins**
2. Click on **Available** tab
3. Search and install the following plugins:
   - Pipeline
   - Git
   - Pipeline: Stage View
   - Blue Ocean (optional, for better UI)
4. Click **Install without restart**
5. Check "Restart Jenkins when installation is complete"

### Step 3: Create Pipeline Job

1. From Jenkins dashboard, click **New Item**
2. Enter name: `PlantsByWebSphere-Pipeline`
3. Select **Pipeline**
4. Click **OK**

5. In the configuration page:
   - **Description:** `CI/CD Pipeline for PlantsByWebSphere Application`
   
   - **Pipeline Section:**
     - Definition: `Pipeline script from SCM`
     - SCM: `Git`
     - Repository URL: `https://github.com/IBMTechSales/liberty_admin_pot_src.git`
     - Branch: `*/main`
     - Script Path: `Jenkinsfile`

6. Click **Save**

---

## 🚀 Running the Pipeline

### Manual Execution

1. Go to Jenkins dashboard
2. Click on `PlantsByWebSphere-Pipeline`
3. Click **Build Now**
4. Watch the pipeline execution in real-time

### Pipeline Stages

The pipeline will execute the following stages:

1. **Cleanup Workspace** - Cleans previous build artifacts
2. **Checkout Source** - Clones the GitHub repository
3. **Build Application** - Compiles Java code with Maven
4. **Run Unit Tests** - Executes JUnit tests
5. **Package Application** - Creates WAR and EAR files
6. **Create Liberty Server Package** - Builds Liberty server package
7. **Deploy to Liberty** - Deploys to Liberty server
8. **Verify Deployment** - Validates the deployment

### Expected Build Time

- First build: 5-10 minutes (downloads dependencies)
- Subsequent builds: 2-5 minutes

### Viewing Build Results

1. Click on the build number (e.g., `#1`)
2. Click **Console Output** to see detailed logs
3. Click **Pipeline Steps** to see stage-by-stage execution

---

## 🔍 Troubleshooting

### Issue 1: Jenkins Won't Start

**Symptoms:** Jenkins service fails to start

**Solution:**
```bash
# Check Jenkins status
sudo systemctl status jenkins

# Check Jenkins logs
sudo journalctl -u jenkins -n 50

# Restart Jenkins
sudo systemctl restart jenkins
```

### Issue 2: Build Fails at Maven Stage

**Symptoms:** Maven build fails with "command not found"

**Solution:**
```bash
# Verify Maven installation
mvn -version

# If not installed, install Maven
sudo apt-get install -y maven

# Update Jenkins configuration with correct Maven path
```

### Issue 3: Liberty Deployment Fails

**Symptoms:** Deployment script fails

**Solution:**
```bash
# Check if Liberty is installed
ls -la /opt/liberty/wlp

# Check Liberty permissions
sudo chown -R jenkins:jenkins /opt/liberty/wlp/usr/servers

# Verify Liberty can start manually
/opt/liberty/wlp/bin/server start pbwServerX
```

### Issue 4: Application Not Accessible

**Symptoms:** Deployment succeeds but application is not accessible

**Solution:**
```bash
# Check if server is running
/opt/liberty/wlp/bin/server status pbwServerX

# Check server logs
tail -f /opt/liberty/wlp/usr/servers/pbwServerX/logs/messages.log

# Check if port is listening
netstat -tuln | grep 9080

# Test application
curl http://localhost:9080/plantsbywebsphere
```

### Issue 5: Permission Denied Errors

**Symptoms:** Scripts fail with permission denied

**Solution:**
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Give Jenkins user access to Liberty
sudo usermod -aG jenkins jenkins
sudo chown -R jenkins:jenkins /opt/liberty/wlp/usr/servers
```

### Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| `JAVA_HOME not set` | Java not configured | Set JAVA_HOME in Jenkins |
| `mvn: command not found` | Maven not in PATH | Install Maven or update PATH |
| `Server already running` | Previous server not stopped | Stop server manually |
| `Port 9080 already in use` | Port conflict | Stop conflicting process |
| `Permission denied` | Insufficient permissions | Fix file permissions |

---

## 🔧 Maintenance

### Daily Tasks

- Monitor build status
- Check application health
- Review error logs

### Weekly Tasks

- Clean up old builds
- Review disk space usage
- Update dependencies (if needed)

### Monthly Tasks

- Update Jenkins plugins
- Review and optimize pipeline
- Backup Jenkins configuration

### Backup Jenkins Configuration

```bash
# Backup Jenkins home directory
sudo tar -czf jenkins-backup-$(date +%Y%m%d).tar.gz /var/lib/jenkins

# Backup to remote location
scp jenkins-backup-*.tar.gz user@backup-server:/backups/
```

### Clean Up Old Builds

1. Go to **Manage Jenkins** → **Manage Old Data**
2. Or configure in job:
   - Job Configuration → **Discard old builds**
   - Days to keep builds: `30`
   - Max # of builds to keep: `10`

### Update Jenkins

```bash
# Update Jenkins
sudo apt-get update
sudo apt-get upgrade jenkins

# Restart Jenkins
sudo systemctl restart jenkins
```

---

## 📊 Monitoring

### Application URLs

After successful deployment:
- **HTTP:** http://localhost:9080/plantsbywebsphere
- **HTTPS:** https://localhost:9443/plantsbywebsphere

### Log Locations

**Jenkins Logs:**
```bash
# System logs
sudo journalctl -u jenkins -f

# Jenkins home
/var/lib/jenkins/
```

**Liberty Logs:**
```bash
# Messages log
/opt/liberty/wlp/usr/servers/pbwServerX/logs/messages.log

# Console log
/opt/liberty/wlp/usr/servers/pbwServerX/logs/console.log

# Trace log
/opt/liberty/wlp/usr/servers/pbwServerX/logs/trace.log
```

### Health Checks

```bash
# Check Jenkins
curl http://localhost:8080

# Check Liberty
curl http://localhost:9080/plantsbywebsphere

# Check server status
/opt/liberty/wlp/bin/server status pbwServerX
```

---

## 📝 Additional Resources

### Jenkins Documentation
- [Jenkins User Documentation](https://www.jenkins.io/doc/)
- [Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)

### Liberty Documentation
- [Open Liberty Documentation](https://openliberty.io/docs/)
- [Liberty Maven Plugin](https://github.com/OpenLiberty/ci.maven)

### Maven Documentation
- [Maven Documentation](https://maven.apache.org/guides/)

---

## 🆘 Support

If you encounter issues not covered in this guide:

1. Check Jenkins console output for detailed error messages
2. Review Liberty server logs
3. Verify all prerequisites are met
4. Check file permissions
5. Ensure all required ports are available

---

## ✅ Success Criteria

Your CI/CD pipeline is successfully set up when:

- ✅ Jenkins is accessible at http://localhost:8080
- ✅ Pipeline job is created and configured
- ✅ Build executes without errors
- ✅ All pipeline stages complete successfully
- ✅ Application is deployed to Liberty
- ✅ Application is accessible at http://localhost:9080/plantsbywebsphere

---

**Last Updated:** 2026-04-22  
**Version:** 1.0 (MVP)