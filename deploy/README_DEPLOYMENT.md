# 🚀 AWS Deployment Guide - BluecoinsWeb

This guide will take you step by step to deploy your Django application on AWS using free tier services.

## 📋 Prerequisites

- AWS account (free tier)
- AWS CLI installed and configured
- Git installed
- Basic knowledge of Linux/SSH

**Important:** This guide is optimized for **Debian 12 AMI** with user `admin`. See the AMI configuration section below for other options.

## 🔧 AMI Selection and Configuration

**Choose your AMI type based on your preference:**

| AMI Type | Default User | SSH Connection | Package Manager | Status |
|----------|-------------|----------------|-----------------|---------|
| **Debian 12** ⭐ | `admin` | `ssh -i key.pem admin@ip` | `apt` | **Recommended** |
| Amazon Linux 2 | `ec2-user` | `ssh -i key.pem ec2-user@ip` | `yum` | Well supported |
| Ubuntu 22.04 LTS | `ubuntu` | `ssh -i key.pem ubuntu@ip` | `apt` | Popular choice |
| CentOS | `centos` | `ssh -i key.pem centos@ip` | `yum` | Enterprise |

**Note:** If you choose a different AMI, either:
- Manual update: Modify user references in configuration files
- Automatic: Use `deploy/deploy_universal.sh` which auto-detects your system

## 🏗️ Deployment Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Users         │────│   CloudFront    │────│      S3         │
│                 │    │   (Optional)    │    │ (Static         │
│                 │    │                 │    │  Files)         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              │
                    ┌─────────────────┐
                    │   EC2 Instance  │
                    │   (t2.micro)    │
                    │                 │
                    │ ┌─────────────┐ │
                    │ │   Nginx     │ │
                    │ └─────────────┘ │
                    │ ┌─────────────┐ │
                    │ │  Gunicorn   │ │
                    │ └─────────────┘ │
                    │ ┌─────────────┐ │
                    │ │   Django    │ │
                    │ └─────────────┘ │
                    │ ┌─────────────┐ │
                    │ │   SQLite    │ │
                    │ └─────────────┘ │
                    └─────────────────┘
```

## 📝 Steps for Automatic Deployment

### Step 1: Configure AWS S3 (Optional but Recommended)

1. **Create S3 bucket:**
   ```bash
   chmod +x deploy/setup_aws.sh
   ./deploy/setup_aws.sh
   ```

2. **Save credentials:** Save the Access Key ID and Secret Access Key that are displayed.

### Step 2: Launch EC2 Instance

1. **Go to AWS EC2 console**
2. **Launch new instance:**
   - **AMI Options:**
     - **Debian 12** (recommended for this guide) - Default user: `admin`
     - Amazon Linux 2 - Default user: `ec2-user`  
     - Ubuntu 22.04 LTS - Default user: `ubuntu`
   - Type: t2.micro (free tier)
   - Configure Security Group:
     - SSH (22) from your IP
     - HTTP (80) from anywhere
     - HTTPS (443) from anywhere (optional)
     - Custom TCP (8000) from anywhere (optional, for development)

3. **Create/select and download Key Pair** for SSH access and download the `.pem` file.

### Step 3: Connect to EC2 Instance

```bash
# Connect via SSH (replace with your .pem file and public IP)
ssh -i "your-keypair.pem" admin@your-ec2-public-ip
```

### Step 4: Configure the Server

1. **Update and upgrade the system:**
   ```bash
   sudo apt-get update && sudo apt-get upgrade -y
   ```

2. **Upload `deploy_universal.sh` script:**

- **Upload file `deploy_universal.sh` in `home/admin` directory of your EC2 instance using SCP:**

   ```bash
   # Upload the deploy script to your EC2 instance
   scp -i "your-keypair.pem" your-local-path/BluecoinsWeb/deploy/deploy_universal.sh admin@your-ec2-public-ip:/home/admin/
   ```

<!--
https://stackoverflow.com/questions/16744863/connect-to-amazon-ec2-file-directory-using-filezilla-and-sftp
-->

-  Using _[FileZilla](https://filezilla-project.org/download.php):_

   Setup using a video tutorial for this. Just check:

   [Connect to Amazon EC2 file directory using FileZilla and SFTP, Video Tutorial](http://y2u.be/e9BDvg42-JI)

   Summary of above video tutorial:

   1. Edit (Preferences) > Settings > Connection > SFTP, Click "Add key file”
   2. Browse to the location of your .pem file and select it. 
   3. A message box will appear asking your permission to convert the file into ppk format. Click Yes, then give the file a name and store it somewhere.
   4. If the new file is shown in the list of Keyfiles, then continue to the next step. If not, then click "Add keyfile..." and select the converted file.
   5. File > Site Manager Add a new site with the following parameters:

      - **Host**: Your public DNS name of your EC2 instance, or the public IP address of the server.

      - **Protocol**: SFTP

      - **Logon Type**: Normal

      - **User**: From the docs: "For Amazon Linux, the default user name is `ec2-user`. For RHEL5, the user name is often `root` but might be `ec2-user`. For Ubuntu, the user name is `ubuntu`. For SUSE Linux, the user name is `root`. For Debian, the user name is `admin`. Otherwise, check with your AMI provider."

         Press Connect Button - If saving of passwords has been disabled, you will be prompted that the logon type will be changed to 'Ask for password'. Say 'OK' and when connecting, at the password prompt push 'OK' without entering a password to proceed past the dialog.

   **Note**: FileZilla automatically figures out which key to use. You do not need to specify the key after importing it as described above.



3. **Execute the deployment script:**

   ```bash
   chmod +x /home/admin/deploy_universal.sh
   sudo /home/admin/deploy_universal.sh
   ```
4. **Test url on your browser:**
   - Open your browser and go to `http://your-ec2-public-ip` or `http://your-domain.com` if you configured a domain.

   If you see the Bluecoins Web application, congratulations! 🎉
---

## **Steps for manual server setup (Optional):**

Only if you didn't use the `deploy_universal.sh` script, follow these steps:
   ```bash
    # Install vital dependencies
    sudo apt-get install python3 git -y

   # Create application directory
   sudo mkdir -p /opt/bluecoins-web
   sudo chown admin:admin /opt/bluecoins-web
   ls -lah /opt/bluecoins-web
    ```

3. **Upload your code to the server:**
   ```bash
   # Via SCP from your local machine
   scp -i "your-keypair.pem" -r . admin@your-public-ip:/opt/bluecoins-web
   ```

2. **Run deployment script:**
   ```bash
   cd /opt/bluecoins-web
   chmod +x deploy/deploy_universal.sh
   sudo ./deploy/deploy_universal.sh
   ```

### Step 5: Configure Environment Variables

1. **Edit .env file:**
   ```bash
   cd /opt/bluecoins-web
   nano .env
   ```

   ```bash
   # In another terminal, generate a secret key
   python -c "import secrets; print(secrets.token_urlsafe(50))"
   ```

2. **Configure the following variables:**
   ```bash
   DJANGO_SECRET_KEY=your-generated-secret-key
   DJANGO_DEBUG=false
   DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,your-ec2-public-ip,your-domain.com
   
   # Only if using S3, uncomment and configure these:
   # USE_S3=true
   # AWS_ACCESS_KEY_ID=your-access-key
   # AWS_SECRET_ACCESS_KEY=your-secret-key
   # AWS_STORAGE_BUCKET_NAME=your-bucket-name
   # AWS_S3_REGION_NAME=us-east-1
   ```

### Step 6: Configure Systemd and Nginx

1. **Configure systemd service:**
   ```bash
   sudo cp deploy/bluecoins-web.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable bluecoins-web
   
   # Fix permissions for logs directory (important!)
   sudo chown -R admin:admin /opt/bluecoins-web/logs
   chmod 755 /opt/bluecoins-web/logs
   
   sudo systemctl start bluecoins-web
   sudo systemctl status bluecoins-web
   ```

   **Note**: If the service fails with "Unable to configure handler 'file'" error, it's due to logs directory permissions. The fix above resolves this issue.

2. **Configure Nginx:**
   ```bash
   # Copy nginx configuration
   sudo cp deploy/nginx.conf /etc/nginx/conf.d/bluecoins-web.conf
   
   # Edit configuration with your domain/IP (IMPORTANT!)
   sudo nano /etc/nginx/conf.d/bluecoins-web.conf
   # Replace 'your-domain.com your-ec2-public-ip' with your actual EC2 public IP
   # Example: server_name 54.123.45.67;
   
   # Test nginx configuration before restarting
   sudo nginx -t
   
   # If test passes, enable and restart nginx
   sudo systemctl enable nginx
   sudo systemctl restart nginx
   sudo systemctl status nginx
   ```

   **Important**: You must edit the nginx configuration file and replace the placeholder values with your actual EC2 public IP address before restarting nginx.

### Step 7: Configure Database

1. **Run migrations:**
   ```bash
   cd /opt/bluecoins-web
   source venv/bin/activate
   python manage.py migrate
   ```

2. **Create superuser:**
   ```bash
   python manage.py createsuperuser
   ```

3. **Collect static files:**
   ```bash
   python manage.py collectstatic --noinput
   ```

### Step 8: Configure SSL (Optional but Recommended)

1. **Install Certbot:**
   ```bash
   # For Debian/Ubuntu
   sudo apt-get install certbot python3-certbot-nginx -y
   
   # For Amazon Linux (if using yum)
   # sudo yum install certbot python3-certbot-nginx -y
   ```

2. **Obtain SSL certificate:**
   ```bash
   sudo certbot --nginx -d your-domain.com
   ```

## 🚀 Quick Start Summary for Debian

If you're using **Debian 12 AMI**, here's the condensed workflow:

1. **Launch EC2 instance** with Debian 12 AMI
2. **Connect:** `ssh -i "your-keypair.pem" admin@your-ec2-public-ip`
3. **Clone repo:** `git clone https://github.com/JuliansCastro/BluecoinsWeb.git /opt/bluecoins-web`
4. **Auto-deploy:** `cd /opt/bluecoins-web && chmod +x deploy/deploy_universal.sh && sudo ./deploy/deploy_universal.sh`
5. **Configure .env** with your settings
6. **Setup services:** Follow steps 6-7 from the detailed guide above
7. **Done!** Your Django app is live 🎉

## 🔧 Useful Maintenance Commands

```bash
# View application logs
sudo journalctl -u bluecoins-web -f

# Restart services
sudo systemctl restart bluecoins-web
sudo systemctl restart nginx

# Check service status
sudo systemctl status bluecoins-web
sudo systemctl status nginx

# Update code
cd /opt/bluecoins-web
git pull origin main
source venv/bin/activate
pip install -r requirements.txt
python manage.py collectstatic --noinput
python manage.py migrate
sudo systemctl restart bluecoins-web
```

## 💰 Estimated Costs (Free Tier)

- **EC2 t2.micro**: Free for 12 months (750 hours/month)
- **S3**: 5GB free for 12 months
- **Data Transfer**: 15GB free per month
- **CloudFront**: 50GB free for 12 months (optional)

## ⚠️ Security Considerations

1. **Configure restrictive Security Groups**
2. **Use HTTPS** with SSL certificates
3. **Configure regular database backups**
4. **Keep the system updated**
5. **Configure monitoring** with CloudWatch

## 🔄 Backups and Recovery

```bash
# Database backup
python manage.py dumpdata > backup_$(date +%Y%m%d_%H%M%S).json

# Static files backup (if not using S3)
tar -czf staticfiles_backup_$(date +%Y%m%d_%H%M%S).tar.gz staticfiles/

# Restore backup
python manage.py loaddata backup_file.json
```

## 📞 Troubleshooting

### Common Issues

1. **502 Bad Gateway Error:**
   - Verify that gunicorn is running
   - Check logs with `sudo journalctl -u bluecoins-web -f`

2. **Static files not loading:**
   - Run `python manage.py collectstatic --noinput`
   - Check nginx configuration

3. **Nginx fails to start/restart:**
   - Test configuration: `sudo nginx -t`
   - Check logs: `sudo journalctl -xeu nginx.service`
   - Common issues:
     - Missing or incorrect server_name in `/etc/nginx/conf.d/bluecoins-web.conf`
     - Replace `your-domain.com your-ec2-public-ip` with actual values
     - **Corrupted syntax** (e.g., `server_bluecoins_web` instead of `server_name`):
       ```bash
       # Fix corrupted nginx configuration
       PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
       sudo sed -i "s/server_bluecoins_web $PUBLIC_IP;/server_name $PUBLIC_IP;/" /etc/nginx/conf.d/bluecoins-web.conf
       ```
     - Port 80 already in use: `sudo netstat -tlnp | grep :80`
   - Fix configuration and test: `sudo nginx -t && sudo systemctl restart nginx`

4. **400 Bad Request Error:**
   - This means Django is rejecting requests from your public IP
   - **Cause**: Your server's public IP is not in Django's `ALLOWED_HOSTS`
   - **Quick fix**:
     ```bash
     # Get your public IP
     PUBLIC_IP=$(curl -s https://ipinfo.io/ip)
     # Update ALLOWED_HOSTS
     cd /opt/bluecoins-web
     sed -i "s/DJANGO_ALLOWED_HOSTS=.*/DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,$PUBLIC_IP/" .env
     # Restart Django
     sudo systemctl restart bluecoins-web
     ```
   - **Automated fix**: Use the repair script: `cd /opt/bluecoins-web && ./deploy/fix_nginx.sh`

5. **Database connection error:**
   - Check SQLite file permissions
   - Review configuration in settings.py

5. **Gunicorn service fails with "Unable to configure handler 'file'" error:**
   - This is a permissions issue with the logs directory
   - Fix with: `sudo chown -R admin:admin /opt/bluecoins-web/logs`
   - Then restart service: `sudo systemctl restart bluecoins-web`
   - Check status: `sudo systemctl status bluecoins-web`

6. **S3 issues:**
   - Verify AWS credentials
   - Review bucket policies

7. **Spanish locale not available (Warning message):**
   - The application will work fine with default locale, but if you want Spanish month names, install Spanish locale:
   
   ```bash
   # Install Spanish locale on Debian/Ubuntu
   sudo apt-get install locales
   sudo locale-gen es_ES.UTF-8
   sudo update-locale
   
   # Or alternatively, install language pack
   sudo apt-get install language-pack-es
   
   # Restart the application after locale installation
   sudo systemctl restart bluecoins-web
   ```


