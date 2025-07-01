#!/bin/bash
# Quick fix script for nginx configuration issues

echo "🔧 Fixing nginx configuration..."

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

# Test nginx configuration
echo "Testing nginx configuration..."
if sudo nginx -t; then
    echo "✅ Nginx configuration is valid!"
    echo "Restarting nginx..."
    sudo systemctl restart nginx
    
    if sudo systemctl is-active --quiet nginx; then
        echo "✅ Nginx restarted successfully!"
        echo ""
        echo "🌐 Your application should now be accessible at:"
        if [ "$PUBLIC_IP" != "localhost" ] && [ -n "$PUBLIC_IP" ]; then
            echo "   🔗 http://$PUBLIC_IP"
        else
            echo "   🔗 http://localhost (or your actual server IP)"
        fi
    else
        echo "❌ Nginx failed to start. Check logs: sudo journalctl -xeu nginx"
    fi
else
    echo "❌ Nginx configuration is still invalid. Manual intervention required."
    echo "Current config:"
    sudo cat /etc/nginx/conf.d/bluecoins-web.conf | grep server_name
fi
