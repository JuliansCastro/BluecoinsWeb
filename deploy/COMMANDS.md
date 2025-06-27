# Summary:

<!--see video for context: https://www.youtube.com/watch?v=hbavPcLnq28
-->

📋 **Full Configuration Summary**
Your Django application has been prepared for deployment on AWS with the following changes and files:

🔧 **Modified Files:**
1. ⚙️ `settings.py`:
    - AWS S3 configuration
    - WhiteNoise for static files
    - Production security settings
    - Logging configured

2. 📦 `requirements.txt`:
    - Added production dependencies (gunicorn, whitenoise, boto3, django-storages)

3. 📄 `.env.example`:
    - Environment variables for AWS and production

4. 📄 `.gitignore`:
    - Deployment and security files

📁 **Deployment Files Created:**
1. 📄 `README_DEPLOYMENT.md`: Complete step-by-step guide
2. 📄 `deploy_ec2.sh`: EC2 installation script
3. 📄 `setup_aws.sh`: AWS S3 setup script
4. 📄 `bluecoins-web.service`: systemd service file
5. 📄 `nginx.conf`: Nginx configuration
6. 📄 `update.sh`: Automated update script
7. 📄 `COMMANDS.md`: Useful reference commands

🚀 **Next Steps to Deploy:**
1. **Create an AWS account** and configure AWS CLI
2. **Launch a t2.micro EC2 instance** (free tier)
3. **Set up S3** for static files (optional)
4. **Follow the guide in** `README_DEPLOYMENT.md`

💰 **Estimated Costs (Free Tier):**
- **EC2 t2.micro**: Free for 12 months
- **S3**: 5GB free for 12 months
- **Data transfer**: 15GB free per month

🔒 **Included Security Features:**
- Environment variables for credentials
- HTTPS ready (with SSL certificates)
- Security headers configured
- WhiteNoise for secure static files
- Production logging

⚡ **Additional Features:**
- Automatic update script
- Automated database backups
- Monitoring with systemd
- Optimized Nginx configuration


# Useful commands for BluecoinsWeb deployment on AWS

---
# LOCAL COMMANDS (Before deployment)


# 1. Generate new SECRET_KEY
python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'

# 2. Install production dependencies
pip install -r requirements.txt

# 3. Test local configuration
python manage.py check --deploy

# 4. Collect static files locally
python manage.py collectstatic --noinput

<br><br><br>

---
# AWS CLI COMMANDS (Initial setup)
---

# 1. Configure AWS CLI
aws configure

# 2. Create S3 bucket
aws s3 mb s3://your-bucket-name --region us-east-1

# 3. List buckets
aws s3 ls

# 4. Sync static files with S3
aws s3 sync staticfiles/ s3://your-bucket-name/static/ --delete

---
# EC2 COMMANDS (On the server, with Debian/Ubuntu linux distribution)
---

# 1. Connect via SSH
```bash
ssh -i "your-keypair.pem" admin@your-public-ip
```

# 2. Update system
```bash
sudo apt-get update && sudo apt-get upgrade -y
```

# 3. Install system dependencies
```bash
sudo apt-get install python3 python3-pip python3-venv git nginx -y
```

# 4. Create application directory
```bash
sudo mkdir -p /opt/bluecoins-web
sudo chown ec2-user:ec2-user /opt/bluecoins-web
```

# 5. Clone repository
```bash
git clone https://github.com/your-username/BluecoinsWeb.git /opt/bluecoins-web
```

# 6. Create virtual environment
```bash
cd /opt/bluecoins-web
python3 -m venv venv
source venv/bin/activate
```

# 7. Install Python dependencies
```bash
pip install -r requirements.txt
```

# 8. Configure environment variables
```bash
cp .env.example .env
nano .env
```

# 9. Run migrations
```bash
python manage.py migrate
```

# 10. Create superuser
```bash
python manage.py createsuperuser
```

# 11. Collect static files
```bash
python manage.py collectstatic --noinput
```

---
# SYSTEMD COMMANDS (Configure services)


# 1. Copy service file

```bash
sudo cp deploy/bluecoins-web.service /etc/systemd/system/
```

# 2. Reload systemd
```bash
sudo systemctl daemon-reload
```

# 3. Enable service
```bash
sudo systemctl enable bluecoins-web
```

# 4. Start service
```bash
sudo systemctl start bluecoins-web
```

# 5. Check service status
```bash
sudo systemctl status bluecoins-web
```

# 6. View service logs
```bash
sudo journalctl -u bluecoins-web -f
```

# 7. Restart service
```bash
sudo systemctl restart bluecoins-web
```

---
# NGINX COMMANDS (Web server)

# 1. Copy configuration
```bash
sudo cp deploy/nginx.conf /etc/nginx/conf.d/bluecoins-web.conf
```

# 2. Test configuration
```bash
sudo nginx -t
```

# 3. Enable nginx
```bash
sudo systemctl enable nginx
```

# 4. Start nginx
```bash
sudo systemctl start nginx
```

# 5. Restart nginx
```bash
sudo systemctl restart nginx
```

# 6. Check nginx status
```bash
sudo systemctl status nginx
```

# 7. View nginx logs
```bash
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

---
# SSL COMMANDS (HTTPS certificates)


# 1. Install certbot
```bash
sudo yum install certbot python3-certbot-nginx -y
```

# 2. Obtain SSL certificate
```bash
sudo certbot --nginx -d your-domain.com
```

# 3. Test automatic renewal
```bash
sudo certbot renew --dry-run
```

# 4. View installed certificates
```bash
sudo certbot certificates
```

---
# MAINTENANCE COMMANDS


# 1. Update code from Git
```bash
cd /opt/bluecoins-web
git pull origin main
```

# 2. Activate virtual environment
```bash
source venv/bin/activate
```

# 3. Install new dependencies
```bash
pip install -r requirements.txt
```

# 4. Run migrations
```bash
python manage.py migrate
```

# 5. Collect static files
```bash
python manage.py collectstatic --noinput
```

# 6. Restart services
```bash
sudo systemctl restart bluecoins-web
sudo systemctl restart nginx
```

# 7. Check services status
```bash
sudo systemctl status bluecoins-web nginx
```

---
# BACKUP COMMANDS


# 1. Database backup
```bash
python manage.py dumpdata > backup_$(date +%Y%m%d_%H%M%S).json
```

# 2. Static files backup (if not using S3)
```bash
tar -czf staticfiles_backup_$(date +%Y%m%d_%H%M%S).tar.gz staticfiles/
```

# 3. Complete application directory backup
```bash
sudo tar -czf /home/ec2-user/bluecoins_backup_$(date +%Y%m%d_%H%M%S).tar.gz /opt/bluecoins-web --exclude='venv' --exclude='*.pyc' --exclude='__pycache__'
```

# 4. Restore database backup
```bash
python manage.py loaddata backup_file.json
```

---
# MONITORING COMMANDS


# 1. View resource usage
```bash
htop
free -h
df -h
```

# 2. View Python/Django processes
```bash
ps aux | grep python
ps aux | grep gunicorn
```

# 3. View network connections
```bash
netstat -tulpn | grep :8000
netstat -tulpn | grep :80
```

# 4. View system logs
```bash
sudo tail -f /var/log/messages
```
# 5. View disk usage
```bash
du -h /opt/bluecoins-web
```

---
# TROUBLESHOOTING COMMANDS


# 1. Check Django configuration
```bash
python manage.py check
```

# 2. Check production configuration
```bash
python manage.py check --deploy
```

# 3. Check file permissions
```bash
ls -la /opt/bluecoins-web/
sudo chown -R ec2-user:ec2-user /opt/bluecoins-web/
```
# 4. Test gunicorn manually
```bash
cd /opt/bluecoins-web
source venv/bin/activate
gunicorn --bind 0.0.0.0:8000 BluecoinsWeb_project.wsgi:application
```

# 5. Check environment variables
```bash
env | grep DJANGO
env | grep AWS
```

# 6. Test S3 connectivity (if using S3)
```bash
python -c "import boto3; print(boto3.client('s3').list_buckets())"
```