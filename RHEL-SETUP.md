# RHEL 9 CI/CD Pipeline Setup Guide

Quick setup guide specifically for RHEL 9 systems.

## 🚀 One-Command Setup

Run this single command to install everything:

```bash
sudo ./scripts/setup-cicd.sh
```

This will:
1. Install Liberty 26.0.0.1 at `/opt/liberty/wlp`
2. Install Jenkins at `/var/lib/jenkins`
3. Configure and start both services
4. Display the Jenkins initial password

**Time Required:** 10-15 minutes

---

## 📋 Manual Step-by-Step Setup

If you prefer to install components separately:

### Step 1: Install Liberty (5 minutes)

```bash
sudo ./scripts/install-liberty.sh
```

**Verify:**
```bash
/opt/liberty/wlp/bin/server version
```

### Step 2: Install Jenkins (5 minutes)

```bash
sudo ./scripts/install-jenkins-rhel.sh
```

**Verify:**
```bash
sudo systemctl status jenkins
curl http://localhost:8080
```

### Step 3: Get Jenkins Initial Password

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

---

## ⚙️ Configure Jenkins (5 minutes)

1. **Access Jenkins:**
   ```
   http://localhost:8080
   ```

2. **Initial Setup:**
   - Enter the initial admin password
   - Click "Install suggested plugins"
   - Wait for plugins to install
   - Create admin user:
     - Username: `admin`
     - Password: [your choice]
     - Full name: `Jenkins Admin`
     - Email: `admin@example.com`

3. **Configure Tools:**
   - Go to: **Manage Jenkins** → **Global Tool Configuration**
   
   **JDK:**
   - Name: `JDK-17`
   - Uncheck "Install automatically"
   - JAVA_HOME: `/usr/lib/jvm/java-17-openjdk`
   
   **Maven:**
   - Name: `Maven-3.9`
   - Uncheck "Install automatically"  
   - MAVEN_HOME: `/usr/share/maven`
   
   - Click **Save**

---

## 🔧 Create Pipeline Job (3 minutes)

1. **Create New Job:**
   - Click **New Item**
   - Name: `PlantsByWebSphere-Pipeline`
   - Type: **Pipeline**
   - Click **OK**

2. **Configure Pipeline:**
   - Description: `CI/CD Pipeline for PlantsByWebSphere`
   - Pipeline Definition: `Pipeline script from SCM`
   - SCM: `Git`
   - Repository URL: `https://github.com/IBMTechSales/liberty_admin_pot_src.git`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
   - Click **Save**

---

## ▶️ Run Your First Build

1. Go to the pipeline job
2. Click **Build Now**
3. Watch the build progress
4. Wait 5-10 minutes for first build

**Expected Stages:**
1. ✓ Cleanup Workspace
2. ✓ Checkout Source
3. ✓ Build Application
4. ✓ Run Unit Tests
5. ✓ Package Application
6. ✓ Create Liberty Server Package
7. ✓ Deploy to Liberty
8. ✓ Verify Deployment

---

## ✅ Verify Deployment

```bash
# Check Liberty server status
/opt/liberty/wlp/bin/server status pbwServerX

# Check if application is accessible
curl http://localhost:9080/plantsbywebsphere

# View server logs
tail -f /opt/liberty/wlp/usr/servers/pbwServerX/logs/messages.log
```

**Application URLs:**
- HTTP: http://localhost:9080/plantsbywebsphere
- HTTPS: https://localhost:9443/plantsbywebsphere

---

## 🔥 Firewall Configuration

If you need to access Jenkins or the application from other machines:

```bash
# Open Jenkins port
sudo firewall-cmd --permanent --add-port=8080/tcp

# Open Liberty HTTP port
sudo firewall-cmd --permanent --add-port=9080/tcp

# Open Liberty HTTPS port
sudo firewall-cmd --permanent --add-port=9443/tcp

# Reload firewall
sudo firewall-cmd --reload

# Verify
sudo firewall-cmd --list-ports
```

---

## 🆘 Troubleshooting

### Jenkins Won't Start

```bash
# Check status
sudo systemctl status jenkins

# Check logs
sudo journalctl -u jenkins -n 50

# Restart
sudo systemctl restart jenkins
```

### Liberty Won't Start

```bash
# Check if Liberty is installed
ls -la /opt/liberty/wlp

# Try starting manually
/opt/liberty/wlp/bin/server start pbwServerX

# Check logs
tail -f /opt/liberty/wlp/usr/servers/pbwServerX/logs/messages.log
```

### Build Fails

```bash
# Check Java version
java -version

# Check Maven version
mvn -version

# Verify Jenkins has access to Liberty
sudo ls -la /opt/liberty/wlp/usr/servers

# Fix permissions if needed
sudo chown -R jenkins:jenkins /opt/liberty/wlp/usr/servers
```

### Port Already in Use

```bash
# Check what's using port 9080
sudo netstat -tulpn | grep 9080

# Or with ss
sudo ss -tulpn | grep 9080

# Stop the conflicting process
sudo kill -9 [PID]
```

---

## 🔧 Useful Commands

### Jenkins Commands
```bash
sudo systemctl start jenkins      # Start Jenkins
sudo systemctl stop jenkins       # Stop Jenkins
sudo systemctl restart jenkins    # Restart Jenkins
sudo systemctl status jenkins     # Check status
sudo journalctl -u jenkins -f     # View logs
```

### Liberty Commands
```bash
/opt/liberty/wlp/bin/server start pbwServerX    # Start server
/opt/liberty/wlp/bin/server stop pbwServerX     # Stop server
/opt/liberty/wlp/bin/server status pbwServerX   # Check status
/opt/liberty/wlp/bin/server version             # Check version
```

### Log Locations
```bash
# Jenkins logs
/var/log/jenkins/jenkins.log
sudo journalctl -u jenkins

# Liberty logs
/opt/liberty/wlp/usr/servers/pbwServerX/logs/messages.log
/opt/liberty/wlp/usr/servers/pbwServerX/logs/console.log
```

---

## 📊 System Requirements

**Minimum:**
- RHEL 9 or compatible
- 4GB RAM
- 20GB disk space
- 2 CPU cores

**Recommended:**
- 8GB RAM
- 50GB disk space
- 4 CPU cores

---

## 🎯 Success Checklist

- [ ] Liberty 26.0.0.1 installed at `/opt/liberty/wlp`
- [ ] Jenkins installed and accessible at `http://localhost:8080`
- [ ] Pipeline job created and configured
- [ ] First build completed successfully
- [ ] Application deployed to Liberty
- [ ] Application accessible at `http://localhost:9080/plantsbywebsphere`

---

## 📚 Additional Resources

- [Full Setup Guide](CI-CD-SETUP.md)
- [Quick Start Guide](QUICK-START.md)
- [Open Liberty Documentation](https://openliberty.io/docs/)
- [Jenkins Documentation](https://www.jenkins.io/doc/)

---

**System:** RHEL 9  
**Liberty Version:** 26.0.0.1  
**Jenkins:** LTS  
**Last Updated:** 2026-04-22