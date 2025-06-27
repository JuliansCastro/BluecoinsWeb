#!/bin/bash
# Automated update script for production

set -e  # Exit on any error

echo "🚀 Starting BluecoinsWeb update..."

# Variables
APP_DIR="/opt/bluecoins-web"
BACKUP_DIR="/home/admin/backups"  # Changed to 'admin' for Debian AMI
DATE=$(date +%Y%m%d_%H%M%S)

# Create backups directory if it doesn't exist
mkdir -p $BACKUP_DIR

echo "📦 Creating backup before updating..."

# Database backup
cd $APP_DIR
source venv/bin/activate
python manage.py dumpdata > "$BACKUP_DIR/db_backup_$DATE.json"
echo "✅ Database backup created: db_backup_$DATE.json"

# Configuration files backup
cp .env "$BACKUP_DIR/env_backup_$DATE"
echo "✅ .env backup created"

echo "⬇️  Downloading latest version of code..."

# Update code from Git
git stash  # Save local changes if any
git pull origin main
echo "✅ Code updated from Git"

echo "📋 Installing dependencies..."

# Install/update dependencies
pip install -r requirements.txt
echo "✅ Dependencies installed"

echo "🗄️  Running migrations..."

# Run migrations
python manage.py migrate
echo "✅ Migrations executed"

echo "📁 Collecting static files..."

# Collect static files
python manage.py collectstatic --noinput
echo "✅ Static files collected"

echo "🔄 Restarting services..."

# Restart services
sudo systemctl restart bluecoins-web
sudo systemctl restart nginx
echo "✅ Services restarted"

echo "🔍 Checking services status..."

# Verify that services are running
sleep 5

if sudo systemctl is-active --quiet bluecoins-web; then
    echo "✅ bluecoins-web is running"
else
    echo "❌ ERROR: bluecoins-web is not running"
    echo "📋 Service logs:"
    sudo journalctl -u bluecoins-web --no-pager -n 20
    exit 1
fi

if sudo systemctl is-active --quiet nginx; then
    echo "✅ nginx is running"
else
    echo "❌ ERROR: nginx is not running"
    echo "📋 Nginx logs:"
    sudo tail -n 20 /var/log/nginx/error.log
    exit 1
fi

echo "🌐 Testing HTTP connectivity..."

# Test that the site responds
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "✅ Website responds correctly (HTTP $HTTP_STATUS)"
else
    echo "⚠️  Warning: Website responds with HTTP $HTTP_STATUS"
fi

echo ""
echo "🎉 Update completed successfully!"
echo ""
echo "📊 Deployment information:"
echo "   📅 Date: $(date)"
echo "   📁 Directory: $APP_DIR"
echo "   💾 DB Backup: $BACKUP_DIR/db_backup_$DATE.json"
echo "   ⚙️  ENV Backup: $BACKUP_DIR/env_backup_$DATE"
echo ""
echo "🔗 Useful commands:"
echo "   View logs: sudo journalctl -u bluecoins-web -f"
echo "   Status:    sudo systemctl status bluecoins-web nginx"
echo "   Rollback:  git reset --hard HEAD~1 && $0"
echo ""

# Clean old backups (keep only the last 10)
echo "🧹 Cleaning old backups..."
cd $BACKUP_DIR
ls -t db_backup_*.json | tail -n +11 | xargs -r rm
ls -t env_backup_* | tail -n +11 | xargs -r rm
echo "✅ Old backups removed"

echo "✨ All done! Your application is updated and running."
