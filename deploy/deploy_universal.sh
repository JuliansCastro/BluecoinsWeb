#!/bin/bash
# Deploy script for EC2 instance with Debian AMI

echo "Starting Django deployment on EC2 (Debian)..."

# Detect if this is Debian/Ubuntu (uses apt) or Amazon Linux (uses yum)
if command -v apt-get >/dev/null 2>&1; then
    echo "Detected Debian/Ubuntu system - using apt package manager"
    PACKAGE_MANAGER="apt"
    UPDATE_CMD="sudo apt-get update && sudo apt-get upgrade -y"
    INSTALL_CMD="sudo apt-get install -y"
    USER_NAME="admin"  # Default for Debian
elif command -v yum >/dev/null 2>&1; then
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
echo "Updating system packages..."
eval $UPDATE_CMD

# Install Python 3 and pip
echo "Installing Python 3, pip, git, and nginx..."
if [ "$PACKAGE_MANAGER" = "apt" ]; then
    eval "$INSTALL_CMD python3 python3-pip python3-venv git nginx"
else
    eval "$INSTALL_CMD python3 python3-pip python3-venv git nginx"
fi

# Create application directory
echo "Creating application directory..."
sudo mkdir -p /opt/bluecoins-web
sudo chown $USER_NAME:$USER_NAME /opt/bluecoins-web

# Navigate to application directory
echo "Navigating to application directory..."
cd /opt/bluecoins-web

# Clone repository (replace with your repository URL)
git clone https://github.com/JuliansCastro/BluecoinsWeb.git

# Create virtual environment
echo "Creating virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install dependencies
echo "Installing Python dependencies..."
pip install -r requirements.txt

# Create logs directory
mkdir -p logs

# Create .env file (you'll need to edit this with your values)
echo "Creating environment file..."
cp .env.example .env

# Generate secret key
echo "Generating Django secret key..."
SECRET_KEY=$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')
sed -i "s/your-super-secret-key-here/$SECRET_KEY/" .env

# Update the service file with the correct user
echo "Updating systemd service file for current user..."
sed -i "s/User=ec2-user/User=$USER_NAME/" deploy/bluecoins-web.service
sed -i "s/Group=ec2-user/Group=$USER_NAME/" deploy/bluecoins-web.service

# Update backup directory in update script
sed -i "s|/home/ec2-user/backups|/home/$USER_NAME/backups|" deploy/update.sh

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Run migrations
echo "Running database migrations..."
python manage.py migrate

# Create superuser (interactive)
echo "Creating Django superuser..."
python manage.py createsuperuser

echo "Deployment setup complete!"
echo "Current user: $USER_NAME"
echo "Package manager: $PACKAGE_MANAGER"
echo ""
echo "Next steps:"
echo "1. Configure nginx"
echo "2. Set up systemd service for gunicorn"
echo "3. Configure SSL certificate"
