# 🚀 Auto-Deployment with GitHub Actions

**The app deploys automatically every time someone pushes to main!**

## ⚡ Quick Setup (5 minutes)

### 1. Configure GitHub Secrets

Go to the repository → **Settings** → **Secrets and variables** → **Actions**

Add these 3 secrets:

| Secret Name | Value | Example |
|-------------|-------|---------|
| `AWS_HOST` | EC2 public IP address | `54.123.45.67` |
| `AWS_USERNAME` | SSH username | `admin` (Debian) or `ec2-user` (Amazon Linux) |
| `AWS_SSH_KEY` | Private SSH key content | Entire content of the `.pem` file |

**How to get these values:**
- **AWS_HOST**: Find it in the AWS EC2 console under "Public IPv4 address"
- **AWS_USERNAME**: Depends on the AMI type (see table above)
- **AWS_SSH_KEY**: Copy the entire content of the `.pem` file used to connect to the instance

### 2. Upload the workflow

The workflow file is already created at `.github/workflows/deploy.yml`. Just commit and push it:

```bash
git add .github/workflows/deploy.yml
git commit -m "Add GitHub Actions auto-deployment"
git push origin main
```

### 3. Done! 🎉

The system is now configured. Every time someone pushes to main, the application will deploy automatically.

## 🔄 How it works

1. Developer pushes `git push origin main`
2. GitHub Actions executes automatically
3. It connects to the AWS server via SSH
4. It executes the `deploy/update.sh` script
5. The application updates in 1-2 minutes

## 📊 Monitor deployments

- **GitHub**: Go to the "Actions" tab in the repository
- **Server**: `sudo journalctl -u bluecoins-web -f`
- **Test**: `curl http://public-ip-address`

## 🆘 If something fails

1. Check the logs in GitHub Actions (most detailed information)
2. Verify that the secrets are properly configured
3. Test manual deployment: `cd /opt/bluecoins-web && ./deploy/update.sh`
4. Check server status: `sudo systemctl status bluecoins-web nginx`

## 📋 Essential Files

Only these files are needed for GitHub Actions deployment:

```
.github/workflows/deploy.yml    # GitHub Actions workflow
deploy/update.sh               # Update script executed by GitHub Actions
deploy/deploy_universal.sh     # Initial server setup (run once)
DEPLOYMENT.md                  # This documentation
```

**Now developers can focus only on programming!** 🎯
