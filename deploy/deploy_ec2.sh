#!/bin/bash
# Deploy script for EC2 instance

echo "Starting Django deployment on EC2..."

# Update system packages
sudo yum update -y

# Install Python 3 and pip
sudo yum install python3 python3-pip git -y

# Install and configure nginx
sudo yum install nginx -y

# Create application directory
sudo mkdir -p /opt/bluecoins-web
sudo chown ec2-user:ec2-user /opt/bluecoins-web

# Navigate to application directory
cd /opt/bluecoins-web

# Clone repository (replace with your repository URL)
# git clone https://github.com/yourusername/BluecoinsWeb.git .

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Create logs directory
mkdir -p logs

# Create .env file (you'll need to edit this with your values)
cp .env.example .env

# Generate secret key
SECRET_KEY=$(python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())')
sed -i "s/your-super-secret-key-here/$SECRET_KEY/" .env

# Collect static files
python manage.py collectstatic --noinput

# Run migrations
python manage.py migrate

# Create superuser (interactive)
echo "Creating Django superuser..."
python manage.py createsuperuser

echo "Deployment setup complete!"
echo "Next steps:"
echo "1. Configure nginx"
echo "2. Set up systemd service for gunicorn"
echo "3. Configure SSL certificate"
