#!/bin/bash
# Quick fix script for nginx configuration issues and Django ALLOWED_HOSTS

echo "🔧 Fixing nginx configuration and Django ALLOWED_HOSTS..."

# Get current public IP
PUBLIC_IP=$(curl -s https://ipinfo.io/ip 2>/dev/null || curl -s https://api.ipify.org 2>/dev/null || echo "localhost")
echo "Detected public IP: $PUBLIC_IP"

# Backup current config
sudo cp /etc/nginx/conf.d/bluecoins-web.conf /etc/nginx/conf.d/bluecoins-web.conf.backup

# Fix the server_name directive
if [ "$PUBLIC_IP" = "localhost" ] || [ -z "$PUBLIC_IP" ]; then
    echo "Using wildcard server_name for local/unknown IP"
    sudo sed -i 's/server_name.*/server_name _;/' /etc/nginx/conf.d/bluecoins-web.conf
else
    echo "Setting server_name to: $PUBLIC_IP"
    sudo sed -i "s/server_name.*/server_name $PUBLIC_IP;/" /etc/nginx/conf.d/bluecoins-web.conf
fi

# Fix Django ALLOWED_HOSTS
echo "Updating Django ALLOWED_HOSTS..."
cd /opt/bluecoins-web

if [ "$PUBLIC_IP" = "localhost" ] || [ -z "$PUBLIC_IP" ]; then
    # For localhost deployment
    sed -i "s/DJANGO_ALLOWED_HOSTS=.*/DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1/" .env
    echo "ALLOWED_HOSTS configured for localhost"
else
    # For public IP deployment
    sed -i "s/DJANGO_ALLOWED_HOSTS=.*/DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,$PUBLIC_IP/" .env
    echo "ALLOWED_HOSTS configured with public IP: $PUBLIC_IP"
fi

# Test nginx configuration
echo "Testing nginx configuration..."
if sudo nginx -t; then
    echo "✅ Nginx configuration is valid!"
    echo "Restarting nginx..."
    sudo systemctl restart nginx
    
    # Restart Django to reload settings
    echo "Restarting Django service to apply ALLOWED_HOSTS changes..."
    sudo systemctl restart bluecoins-web
    sleep 3
    
    if sudo systemctl is-active --quiet nginx && sudo systemctl is-active --quiet bluecoins-web; then
        echo "✅ Both nginx and Django restarted successfully!"
        echo ""
        echo "🌐 Your application should now be accessible at:"
        if [ "$PUBLIC_IP" != "localhost" ] && [ -n "$PUBLIC_IP" ]; then
            echo "   🔗 http://$PUBLIC_IP"
            
            # Test the application
            echo ""
            echo "🧪 Testing application..."
            if curl -s "http://$PUBLIC_IP" | grep -q "Bluecoins\|Welcome"; then
                echo "✅ Application is responding correctly!"
            else
                echo "⚠️  Application test inconclusive. Try accessing manually."
            fi
        else
            echo "   🔗 http://localhost (or your actual server IP)"
        fi
    else
        echo "❌ Service restart failed. Check logs:"
        echo "Nginx: sudo journalctl -xeu nginx"
        echo "Django: sudo journalctl -xeu bluecoins-web"
    fi
else
    echo "❌ Nginx configuration is still invalid. Manual intervention required."
    echo "Current config:"
    sudo cat /etc/nginx/conf.d/bluecoins-web.conf | grep server_name
fi
