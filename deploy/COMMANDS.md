# Useful commands for BluecoinsWeb deployment on AWS

# =============================================================================
# LOCAL COMMANDS (Before deployment)
# =============================================================================

# 1. Generate new SECRET_KEY
python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'

# 2. Install production dependencies
pip install -r requirements.txt

# 3. Test local configuration
python manage.py check --deploy

# 4. Collect static files locally
python manage.py collectstatic --noinput

# =============================================================================
# AWS CLI COMMANDS (Initial setup)
# =============================================================================

# 1. Configure AWS CLI
aws configure

# 2. Create S3 bucket
aws s3 mb s3://your-bucket-name --region us-east-1

# 3. List buckets
aws s3 ls

# 4. Sync static files with S3
aws s3 sync staticfiles/ s3://your-bucket-name/static/ --delete

# =============================================================================
# EC2 COMMANDS (On the server)
# =============================================================================

# 1. Connect via SSH
ssh -i "your-keypair.pem" ec2-user@your-public-ip

# 2. Update system
sudo yum update -y

# 3. Install system dependencies
sudo yum install python3 python3-pip git nginx -y

# 4. Create application directory
sudo mkdir -p /opt/bluecoins-web
sudo chown ec2-user:ec2-user /opt/bluecoins-web

# 5. Clone repository
git clone https://github.com/your-username/BluecoinsWeb.git /opt/bluecoins-web

# 6. Create virtual environment
cd /opt/bluecoins-web
python3 -m venv venv
source venv/bin/activate

# 7. Install Python dependencies
pip install -r requirements.txt

# 8. Configure environment variables
cp .env.example .env
nano .env

# 9. Run migrations
python manage.py migrate

# 10. Create superuser
python manage.py createsuperuser

# 11. Collect static files
python manage.py collectstatic --noinput

# =============================================================================
# SYSTEMD COMMANDS (Configure services)
# =============================================================================

# 1. Copy service file
sudo cp deploy/bluecoins-web.service /etc/systemd/system/

# 2. Reload systemd
sudo systemctl daemon-reload

# 3. Enable service
sudo systemctl enable bluecoins-web

# 4. Start service
sudo systemctl start bluecoins-web

# 5. Check service status
sudo systemctl status bluecoins-web

# 6. View service logs
sudo journalctl -u bluecoins-web -f

# 7. Restart service
sudo systemctl restart bluecoins-web

# =============================================================================
# NGINX COMMANDS (Web server)
# =============================================================================

# 1. Copy configuration
sudo cp deploy/nginx.conf /etc/nginx/conf.d/bluecoins-web.conf

# 2. Test configuration
sudo nginx -t

# 3. Enable nginx
sudo systemctl enable nginx

# 4. Start nginx
sudo systemctl start nginx

# 5. Restart nginx
sudo systemctl restart nginx

# 6. Check nginx status
sudo systemctl status nginx

# 7. View nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# =============================================================================
# SSL COMMANDS (HTTPS certificates)
# =============================================================================

# 1. Install certbot
sudo yum install certbot python3-certbot-nginx -y

# 2. Obtain SSL certificate
sudo certbot --nginx -d your-domain.com

# 3. Test automatic renewal
sudo certbot renew --dry-run

# 4. View installed certificates
sudo certbot certificates

# =============================================================================
# MAINTENANCE COMMANDS
# =============================================================================

# 1. Update code from Git
cd /opt/bluecoins-web
git pull origin main

# 2. Activate virtual environment
source venv/bin/activate

# 3. Install new dependencies
pip install -r requirements.txt

# 4. Run migrations
python manage.py migrate

# 5. Collect static files
python manage.py collectstatic --noinput

# 6. Restart services
sudo systemctl restart bluecoins-web
sudo systemctl restart nginx

# 7. Check services status
sudo systemctl status bluecoins-web nginx

# =============================================================================
# BACKUP COMMANDS
# =============================================================================

# 1. Database backup
python manage.py dumpdata > backup_$(date +%Y%m%d_%H%M%S).json

# 2. Static files backup (if not using S3)
tar -czf staticfiles_backup_$(date +%Y%m%d_%H%M%S).tar.gz staticfiles/

# 3. Complete application directory backup
sudo tar -czf /home/ec2-user/bluecoins_backup_$(date +%Y%m%d_%H%M%S).tar.gz /opt/bluecoins-web --exclude='venv' --exclude='*.pyc' --exclude='__pycache__'

# 4. Restore database backup
python manage.py loaddata backup_file.json

# =============================================================================
# MONITORING COMMANDS
# =============================================================================

# 1. View resource usage
htop
free -h
df -h

# 2. View Python/Django processes
ps aux | grep python
ps aux | grep gunicorn

# 3. View network connections
netstat -tulpn | grep :8000
netstat -tulpn | grep :80

# 4. View system logs
sudo tail -f /var/log/messages

# 5. View disk usage
du -h /opt/bluecoins-web

# =============================================================================
# TROUBLESHOOTING COMMANDS
# =============================================================================

# 1. Check Django configuration
python manage.py check

# 2. Check production configuration
python manage.py check --deploy

# 3. Check file permissions
ls -la /opt/bluecoins-web/
sudo chown -R ec2-user:ec2-user /opt/bluecoins-web/

# 4. Test gunicorn manually
cd /opt/bluecoins-web
source venv/bin/activate
gunicorn --bind 0.0.0.0:8000 BluecoinsWeb_project.wsgi:application

# 5. Check environment variables
env | grep DJANGO
env | grep AWS

# 6. Test S3 connectivity (if using S3)
python -c "import boto3; print(boto3.client('s3').list_buckets())"
