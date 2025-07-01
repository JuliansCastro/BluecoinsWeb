#!/bin/bash
# Script para diagnosticar el problema del admin de Django

echo "🔍 Diagnosticando problema del admin de Django..."

# Verificar logs de Django
echo "----------------------------------------"
echo "📋 Logs recientes de Django:"
sudo journalctl -u bluecoins-web --no-pager -l --since "10 minutes ago"

echo ""
echo "----------------------------------------"
echo "📋 Logs de nginx:"
sudo tail -20 /var/log/nginx/error.log

echo ""
echo "----------------------------------------"
echo "📋 Verificando configuración de Django:"
cd /opt/bluecoins-web
source venv/bin/activate

# Verificar configuración
echo "Verificando configuración..."
python manage.py check

echo ""
echo "----------------------------------------"
echo "📋 Variables de entorno actuales:"
echo "DEBUG: $(grep DJANGO_DEBUG .env)"
echo "ALLOWED_HOSTS: $(grep DJANGO_ALLOWED_HOSTS .env)"
echo "SECRET_KEY configurado: $(grep -q DJANGO_SECRET_KEY .env && echo 'Sí' || echo 'No')"

echo ""
echo "----------------------------------------"
echo "📋 Verificando rutas de Django:"
python manage.py shell -c "
from django.conf import settings
print('STATIC_URL:', settings.STATIC_URL)
print('STATIC_ROOT:', settings.STATIC_ROOT)
print('SECRET_KEY length:', len(settings.SECRET_KEY))
print('DEBUG:', settings.DEBUG)
print('ALLOWED_HOSTS:', settings.ALLOWED_HOSTS)
"

echo ""
echo "----------------------------------------"
echo "📋 Verificando archivos estáticos:"
ls -la staticfiles/ | head -10

echo ""
echo "----------------------------------------"
echo "📋 Verificando permisos:"
ls -la logs/
whoami
