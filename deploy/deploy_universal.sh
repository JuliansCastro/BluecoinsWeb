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
sudo mkdir -p /opt/bluecoins-web
sudo chown $USER_NAME:$USER_NAME /opt/bluecoins-web

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

# Create .env file (you'll need to edit this with your values)
echo
echo "-----------------------------------------"
echo "Step 12: Creating environment file..."
cp .env.example .env

# Generate secret key
echo
echo "-----------------------------------------"
echo "Step 13: Generating Django secret key..."
SECRET_KEY=$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')
sed -i "s/your-super-secret-key-here/$SECRET_KEY/" .env

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

echo
echo "-----------------------------------------"
echo "Deployment setup complete!"
echo "Current user: $USER_NAME"
echo "Package manager: $PACKAGE_MANAGER"
echo ""
echo "Next steps:"
echo "1. Configure nginx"
echo "2. Set up systemd service for gunicorn"
echo "3. Configure SSL certificate"
