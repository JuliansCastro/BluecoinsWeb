#!/bin/bash
# Deploy script for EC2 instance with Debian AMI

echo
echo "Starting Django deployment on EC2 (Debian)..."

# Detect if this is Debian/Ubuntu (uses apt) or Amazon Linux (uses yum)
if command -v apt-get >/dev/null 2>&1; then
    echo
    echo "Step 1: Detected Debian/Ubuntu system - using apt package manager"
    echo "Detected Debian/Ubuntu system - using apt package manager"
    PACKAGE_MANAGER="apt"
    UPDATE_CMD="sudo apt-get update && sudo apt-get upgrade -y"
    INSTALL_CMD="sudo apt-get install -y"
    USER_NAME="admin"  # Default for Debian
elif command -v yum >/dev/null 2>&1; then
    echo
    echo "Step 1: Detected Amazon Linux/CentOS system - using yum package manager"
    echo "Detected Amazon Linux/CentOS system - using yum package manager"
    PACKAGE_MANAGER="yum"
    UPDATE_CMD="sudo yum update -y"
    INSTALL_CMD="sudo yum install -y"
    USER_NAME="ec2-user"  # Default for Amazon Linux
else
    echo "Error: No supported package manager found (apt or yum)"
    exit 1
fi

# Update system packages
echo
echo "-----------------------------------------"
echo "Step 2: Updating system packages..."
eval $UPDATE_CMD

# Install Python 3 and pip
echo
echo "-----------------------------------------"
echo "Step 3: Installing Python 3, pip, git, and nginx..."
if [ "$PACKAGE_MANAGER" = "apt" ]; then
    eval "$INSTALL_CMD python3 python3-pip python3-venv git nginx"
else
    eval "$INSTALL_CMD python3 python3-pip python3-venv git nginx"
fi

# Create application directory
echo
echo "-----------------------------------------"
echo "Step 4: Creating application directory..."
if [ ! -d "/opt/bluecoins-web" ]; then
    echo "Creating /opt/bluecoins-web directory..."
    sudo mkdir -p /opt/bluecoins-web
    sudo chown $USER_NAME:$USER_NAME /opt/bluecoins-web
    echo "Directory created and ownership set to $USER_NAME."
    echo "Current directory: $(pwd)"
    echo "Contents of /opt/bluecoins-web:"
    ls -la /opt/bluecoins-web
    echo "You can now navigate to /opt/bluecoins-web to continue the setup."
else
    echo "/opt/bluecoins-web already exists. Removing existing directory."
    sudo rm -rf /opt/bluecoins-web/*
    sudo rm -rf /opt/bluecoins-web/.[^.]* 2>/dev/null || true
    echo "Existing directory cleaned. You can now continue the setup."
    echo "Creating a new /opt/bluecoins-web directory..."
    sudo mkdir -p /opt/bluecoins-web
    sudo chown $USER_NAME:$USER_NAME /opt/bluecoins-web
    echo "Directory created and ownership set to $USER_NAME."
    echo "Current directory: $(pwd)"
    echo "Contents of /opt/bluecoins-web:"
    ls -la /opt/bluecoins-web
    echo "You can now navigate to /opt/bluecoins-web to continue the setup."
    echo "Current directory: $(pwd)"

fi


# Navigate to application directory
echo
echo "-----------------------------------------"
echo "Step 5: Navigating to application directory..."
cd /opt/bluecoins-web
pwd && ls

# Check if repository is already cloned in subdirectory
echo
echo "-----------------------------------------"
echo "Step 6: Checking for existing repository..."
if [ -d "BluecoinsWeb" ] && [ -f "BluecoinsWeb/manage.py" ]; then
    echo "Repository found in subdirectory. Moving files to correct location..."
    # Move all files from subdirectory to current directory
    sudo mv BluecoinsWeb/* . 2>/dev/null || true
    sudo mv BluecoinsWeb/.[^.]* . 2>/dev/null || true
    sudo rmdir BluecoinsWeb
    echo "Files moved successfully."
elif [ ! -f "manage.py" ]; then
    # Clean directory if it contains other files but not our project
    echo "Cleaning directory for fresh clone..."
    sudo rm -rf ./* ./.[^.]* 2>/dev/null || true
    
    # Clone repository
    echo
    echo "-----------------------------------------"
    echo "Step 7: Cloning BluecoinsWeb repository..."
    git clone https://github.com/JuliansCastro/BluecoinsWeb.git .
else
    echo "Repository already exists in correct location."
    pwd && ls
fi

# Verify that files were cloned correctly
echo
echo "-----------------------------------------"
echo "Step 8: Verifying repository files..."
ls -la
if [ ! -f "manage.py" ]; then
    echo "Error: manage.py not found. Repository may not have been cloned correctly."
    echo "Current directory contents:"
    ls -la
    exit 1
fi

# Create virtual environment
echo
echo "-----------------------------------------"
echo "Step 9: Creating virtual environment..."
python3 -m venv venv
# Check if virtual environment was created successfully
if [ ! -d "venv" ]; then
    echo "Error: Virtual environment not created successfully."
    echo "Current directory contents:"
    ls -la
    exit 1
fi
echo "Environment created at $(pwd)/venv"
echo "Activating virtual environment..."
source venv/bin/activate
# Check if virtual environment was activated
if [ -z "$VIRTUAL_ENV" ]; then
    echo "Error: Virtual environment activation failed."
    echo "Current directory contents:"
    ls -la
    exit 1
fi

# Install dependencies
echo
echo "-----------------------------------------"
echo "Step 10: Installing Python dependencies..."
pip install -r requirements.txt

# Create logs directory
echo
echo "-----------------------------------------"
echo "Step 11: Creating logs directory..."
mkdir -p logs
# Fix permissions for logs directory (critical for systemd service)
sudo chown -R $USER_NAME:$USER_NAME logs
chmod 755 logs

# Create .env file (you'll need to edit this with your values)
echo
echo "-----------------------------------------"
echo "Step 12: Creating environment file..."
if [ -f ".env" ]; then
    echo ".env file already exists. Removing and recreating."
    rm .env
    echo "Creating new .env file from example..."
    cp .env.example .env
else
    echo "Creating .env file from example..."
    cp .env.example .env
fi


# Generate secret key
echo
echo "-----------------------------------------"
echo "Step 13: Generating Django secret key..."
SECRET_KEY=$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')
sed -i "s/your-super-secret-key-here/$SECRET_KEY/" .env

# Configure ALLOWED_HOSTS with detected IP
echo
echo "-----------------------------------------"
echo "Step 13.1: Configuring ALLOWED_HOSTS..."
# Get the same IP we'll use for nginx (we'll set this later in the script)
# For now, create a placeholder that we'll update when we detect the IP
echo "Will update ALLOWED_HOSTS later with detected public IP..."

# Update the service file with the correct user
echo
echo "-----------------------------------------"
echo "Step 14: Updating systemd service file for current user..."
sed -i "s/User=ec2-user/User=$USER_NAME/" deploy/bluecoins-web.service
sed -i "s/Group=ec2-user/Group=$USER_NAME/" deploy/bluecoins-web.service

# Update backup directory in update script
echo
echo "-----------------------------------------"
echo "Step 15: Updating backup directory in update script..."
sed -i "s|/home/ec2-user/backups|/home/$USER_NAME/backups|" deploy/update.sh

# Collect static files
echo
echo "-----------------------------------------"
echo "Step 16: Collecting static files..."
python manage.py collectstatic --noinput

# Run migrations
echo
echo "-----------------------------------------"
echo "Step 17: Running database migrations..."
python manage.py migrate

# Create superuser (interactive)
echo
echo "-----------------------------------------"
echo "Step 18: Creating Django superuser..."
python manage.py createsuperuser

# Configure Systemd automatically
echo
echo "-----------------------------------------"
echo "Step 19: Configuring Systemd..."

# Copy systemd service file
echo "Installing systemd service file..."
sudo cp deploy/bluecoins-web.service /etc/systemd/system/

# Reload systemd to recognize new service
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Enable service to start on boot
echo "Enabling bluecoins-web service..."
sudo systemctl enable bluecoins-web

# Fix permissions for logs directory (important!)
echo "Fixing logs directory permissions..."
sudo chown -R $USER_NAME:$USER_NAME /opt/bluecoins-web/logs
chmod 755 /opt/bluecoins-web/logs

# Start the service
echo "Starting bluecoins-web service..."
sudo systemctl start bluecoins-web

# Wait a moment for service to start
sleep 2

# Check service status
echo "Checking service status..."
if sudo systemctl is-active --quiet bluecoins-web; then
    echo "✅ Bluecoins-web service is running successfully!"
    echo "Service details:"
    sudo systemctl status bluecoins-web --no-pager -l
else
    echo "❌ Service failed to start. Checking logs..."
    sudo journalctl -u bluecoins-web --no-pager -l --since "1 minute ago"
    echo ""
    echo "Common fixes:"
    echo "1. Check logs directory permissions: sudo chown -R $USER_NAME:$USER_NAME /opt/bluecoins-web/logs"
    echo "2. Verify virtual environment: ls -la /opt/bluecoins-web/venv/bin/"
    echo "3. Test Django manually: cd /opt/bluecoins-web && source venv/bin/activate && python manage.py check"
fi



# Configure nginx automatically
echo
echo "-----------------------------------------"
echo "Step 20: Configuring Nginx..."

# Get EC2 public IP automatically
# Using metadata service to get public IP
# This works on EC2 instances and is safer than hardcoding IPs
# If running locally, it will default to "localhost"
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "localhost")

# If PUBLIC_IP is empty or failed, try alternative methods
if [ -z "$PUBLIC_IP" ] || [ "$PUBLIC_IP" = "" ]; then
    echo "Primary IP detection failed, trying alternative methods..."
    # Try to get public IP via external service
    PUBLIC_IP=$(curl -s https://ipinfo.io/ip 2>/dev/null || curl -s https://api.ipify.org 2>/dev/null || echo "localhost")
    echo "Alternative IP detection result: $PUBLIC_IP"
fi

# Final fallback to localhost if all methods fail
if [ -z "$PUBLIC_IP" ] || [ "$PUBLIC_IP" = "" ]; then
    PUBLIC_IP="localhost"
    echo "All IP detection methods failed, using localhost"
fi

echo "Final detected public IP: $PUBLIC_IP"

# Update ALLOWED_HOSTS in .env with the detected public IP
echo "Updating ALLOWED_HOSTS with detected IP: $PUBLIC_IP"
if [ "$PUBLIC_IP" = "localhost" ]; then
    # For localhost deployment
    sed -i "s/DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1/DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1/" .env
    echo "ALLOWED_HOSTS configured for localhost"
else
    # For public IP deployment
    sed -i "s/DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1/DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,$PUBLIC_IP/" .env
    echo "ALLOWED_HOSTS configured with public IP: $PUBLIC_IP"
fi

# Copy nginx configuration
sudo cp deploy/nginx.conf /etc/nginx/conf.d/bluecoins-web.conf

# Replace placeholder with actual IP/domain (more specific and safer replacement)
# Handle the case where PUBLIC_IP might be empty or localhost
if [ "$PUBLIC_IP" = "localhost" ]; then
    # For localhost, we'll accept any server name
    sudo sed -i "s/server_name your-domain.com your-ec2-public-ip;/server_name _;/g" /etc/nginx/conf.d/bluecoins-web.conf
    echo "Nginx configured for localhost/any domain (server_name _)"
else
    # Replace with the actual public IP
    sudo sed -i "s/server_name your-domain.com your-ec2-public-ip;/server_name $PUBLIC_IP;/g" /etc/nginx/conf.d/bluecoins-web.conf
    echo "Nginx configured for IP: $PUBLIC_IP"
fi

# Verify the replacement worked correctly and fix common corruption
if grep -q "server_name $PUBLIC_IP;" /etc/nginx/conf.d/bluecoins-web.conf; then
    echo "Nginx configuration updated successfully with IP: $PUBLIC_IP"
elif grep -q "server_name _;" /etc/nginx/conf.d/bluecoins-web.conf; then
    echo "Nginx configuration updated successfully for any domain"
elif grep -q "server_bluecoins_web" /etc/nginx/conf.d/bluecoins-web.conf; then
    echo "Detected sed corruption, fixing automatically..."
    if [ "$PUBLIC_IP" = "localhost" ]; then
        sudo sed -i "s/server_bluecoins_web.*;/server_name _;/g" /etc/nginx/conf.d/bluecoins-web.conf
    else
        sudo sed -i "s/server_bluecoins_web.*;/server_name $PUBLIC_IP;/g" /etc/nginx/conf.d/bluecoins-web.conf
    fi
    echo "Nginx configuration corrected successfully."
else
    echo "Warning: Automatic IP replacement may have failed. Manual check required."
    if [ "$PUBLIC_IP" = "localhost" ]; then
        echo "Expected line: server_name _;"
    else
        echo "Expected line: server_name $PUBLIC_IP;"
    fi
    echo "Current config:"
    sudo grep -n "server_name\|server_" /etc/nginx/conf.d/bluecoins-web.conf
fi

# Test nginx configuration
echo "Testing nginx configuration..."
if sudo nginx -t; then
    echo "Nginx configuration is valid."
    sudo systemctl enable nginx
    sudo systemctl restart nginx
    if sudo systemctl is-active --quiet nginx; then
        echo "Nginx started successfully!"
        
        # Restart Django service to reload ALLOWED_HOSTS configuration
        echo "Restarting Django service to apply ALLOWED_HOSTS changes..."
        sudo systemctl restart bluecoins-web
        sleep 2
        
        # Final verification - test the full stack
        echo
        echo "🧪 Running final verification tests..."
        echo "Testing Django directly (port 8000)..."
        if curl -s http://localhost:8000 >/dev/null; then
            echo "✅ Django is responding correctly"
        else
            echo "❌ Django test failed"
        fi
        
        echo "Testing full stack via nginx (port 80)..."
        if curl -s http://localhost:80 | grep -q "Bluecoins\|nginx"; then
            echo "✅ Nginx proxy is working correctly"
        else
            echo "❌ Nginx proxy test failed"
        fi
        
        echo "Testing public access..."
        if curl -s http://$PUBLIC_IP | grep -q "Bluecoins"; then
            echo "✅ Public access is working correctly"
        else
            echo "⚠️  Public access test inconclusive (may be firewall/security group)"
        fi
    else
        echo "Warning: Nginx failed to start. Check logs with: sudo journalctl -xeu nginx"
    fi
else
    echo "Warning: Nginx configuration test failed. Please check manually."
fi

#
#echo "Step 21: Configure SSL certificate"

echo
echo "-----------------------------------------"
echo "🎉 DEPLOYMENT COMPLETED SUCCESSFULLY! 🎉"
echo "-----------------------------------------"
echo "Current user: $USER_NAME"
echo "Package manager: $PACKAGE_MANAGER"
echo "Public IP: $PUBLIC_IP"
echo ""
echo "✅ Django/Gunicorn: Running on port 8000"
echo "✅ Nginx: Running and configured as reverse proxy"
echo "✅ Database: Migrated and ready"
echo "✅ Static files: Collected and served"
echo ""
echo "🌐 Your Django application is now LIVE and accessible at:"
echo "   🔗 http://$PUBLIC_IP"
echo ""
echo "🔧 Next steps (optional):"
echo "1. Configure SSL certificate: sudo apt-get install certbot python3-certbot-nginx"
echo "2. Set up domain name (if you have one)"
echo "3. Configure automated backups"
echo ""
echo "📊 Useful monitoring commands:"
echo "  sudo systemctl status bluecoins-web  # Check Django service"
echo "  sudo systemctl status nginx         # Check nginx service"
echo "  sudo journalctl -u bluecoins-web -f # View Django logs"
echo "  curl http://localhost:8000          # Test Django directly"
echo "  curl http://$PUBLIC_IP              # Test full stack"
