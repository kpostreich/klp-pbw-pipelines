# Quick Start Guide - CI/CD Pipeline MVP

Get your CI/CD pipeline up and running in 15 minutes!

## 🚀 Quick Setup (3 Steps)

### Step 1: Install Jenkins (5 minutes)

```bash
# Clone the repository
git clone https://github.com/IBMTechSales/liberty_admin_pot_src.git
cd liberty_admin_pot_src

# Make scripts executable
chmod +x scripts/*.sh

# Install Jenkins (requires sudo)
sudo ./scripts/install-jenkins.sh
```

**Save the initial admin password displayed at the end!**

### Step 2: Configure Jenkins (5 minutes)

1. Open browser: `http://localhost:8080`
2. Enter the initial admin password
3. Click "Install suggested plugins" and wait
4. Create admin user (username: `admin`)
5. Click "Start using Jenkins"

### Step 3: Create Pipeline Job (5 minutes)

1. Click **New Item**
2. Name: `PlantsByWebSphere-Pipeline`
3. Type: **Pipeline**
4. Click **OK**
5. Configure:
   - Definition: `Pipeline script from SCM`
   - SCM: `Git`
   - Repository URL: `https://github.com/IBMTechSales/liberty_admin_pot_src.git`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
6. Click **Save**

## ▶️ Run Your First Build

1. Click **Build Now**
2. Watch the pipeline execute
3. Wait 5-10 minutes for first build
4. Access application: `http://localhost:9080/plantsbywebsphere`

## ✅ Verify Success

```bash
# Check Jenkins
curl http://localhost:8080

# Check Liberty server
/opt/liberty/wlp/bin/server status pbwServerX

# Check application
curl http://localhost:9080/plantsbywebsphere
```

## 🆘 Quick Troubleshooting

**Jenkins won't start?**
```bash
sudo systemctl status jenkins
sudo systemctl restart jenkins
```

**Build fails?**
```bash
# Check console output in Jenkins UI
# Or check logs:
sudo journalctl -u jenkins -n 50
```

**Application not accessible?**
```bash
# Check Liberty logs
tail -f /opt/liberty/wlp/usr/servers/pbwServerX/logs/messages.log
```

## 📚 Next Steps

- Read the full [CI-CD-SETUP.md](CI-CD-SETUP.md) guide
- Configure automated triggers (optional)
- Set up monitoring (optional)
- Add more environments (staging, production)

## 🎯 What You Get

✅ Automated build process  
✅ Automated testing  
✅ Automated deployment to Liberty 26.0.0.1  
✅ Deployment verification  
✅ Build artifacts archiving  
✅ Easy rollback capability  

---

**Need help?** Check [CI-CD-SETUP.md](CI-CD-SETUP.md) for detailed instructions and troubleshooting.