#!/bin/bash
# Script para solucionar problemas del admin de Django

echo "🔧 Solucionando problemas del admin de Django..."

cd /opt/bluecoins-web
source venv/bin/activate

# Obtener IP pública
PUBLIC_IP=$(curl -s https://ipinfo.io/ip 2>/dev/null || curl -s https://api.ipify.org 2>/dev/null)
echo "IP pública detectada: $PUBLIC_IP"

echo ""
echo "----------------------------------------"
echo "📋 Paso 1: Verificando y actualizando configuración..."

# Asegurar que DEBUG esté en False para producción
if grep -q "DJANGO_DEBUG=true" .env; then
    echo "⚠️  DEBUG está en true, cambiando a false para producción..."
    sed -i 's/DJANGO_DEBUG=true/DJANGO_DEBUG=false/' .env
fi

# Verificar ALLOWED_HOSTS
echo "Verificando ALLOWED_HOSTS..."
if ! grep -q "$PUBLIC_IP" .env; then
    echo "Actualizando ALLOWED_HOSTS..."
    sed -i "s/DJANGO_ALLOWED_HOSTS=.*/DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,$PUBLIC_IP/" .env
fi

echo ""
echo "----------------------------------------"
echo "📋 Paso 2: Verificando base de datos y migraciones..."

# Verificar que la base de datos de admin existe
if [ ! -f "databases/bluecoins_admin.db" ]; then
    echo "⚠️  Base de datos de admin no existe, creándola..."
    python manage.py migrate
else
    echo "✅ Base de datos de admin existe"
fi

echo "Verificando migraciones..."
python manage.py showmigrations

echo "Ejecutando migraciones faltantes..."
python manage.py migrate

echo ""
echo "----------------------------------------"
echo "📋 Paso 3: Recolectando archivos estáticos..."
python manage.py collectstatic --noinput

echo ""
echo "----------------------------------------"
echo "📋 Paso 4: Verificando configuración de Django..."
echo "Ejecutando verificaciones de Django..."
python manage.py check

echo ""
echo "Verificando configuración específica..."
python manage.py shell -c "
from django.conf import settings
import os
print('=== CONFIGURACIÓN DJANGO ===')
print(f'DEBUG: {settings.DEBUG}')
print(f'ALLOWED_HOSTS: {settings.ALLOWED_HOSTS}')
print(f'SECRET_KEY length: {len(settings.SECRET_KEY)}')
print(f'DATABASES: {list(settings.DATABASES.keys())}')
print(f'STATIC_URL: {settings.STATIC_URL}')
print(f'STATIC_ROOT: {settings.STATIC_ROOT}')

# Verificar archivos de base de datos
print('\\n=== ARCHIVOS DE BASE DE DATOS ===')
default_db = settings.DATABASES['default']['NAME']
print(f'Default DB: {default_db}')
print(f'Default DB exists: {os.path.exists(default_db)}')
if os.path.exists(default_db):
    print(f'Default DB size: {os.path.getsize(default_db)} bytes')

bluecoins_db = settings.DATABASES['bluecoins']['NAME']
print(f'Bluecoins DB: {bluecoins_db}')
print(f'Bluecoins DB exists: {os.path.exists(bluecoins_db)}')
if os.path.exists(bluecoins_db):
    print(f'Bluecoins DB size: {os.path.getsize(bluecoins_db)} bytes')
"

echo ""
echo "----------------------------------------"
echo "📋 Paso 5: Verificando superusuario..."

# Verificar si existe al menos un superusuario
USER_COUNT=$(python manage.py shell -c "
from django.contrib.auth.models import User
print(User.objects.filter(is_superuser=True).count())
" 2>/dev/null)

if [ "$USER_COUNT" = "0" ]; then
    echo "⚠️  No hay superusuarios. Creando usuario de prueba..."
    echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'admin123') if not User.objects.filter(username='admin').exists() else print('User admin already exists')" | python manage.py shell
    echo "✅ Usuario de prueba creado: admin/admin123"
else
    echo "✅ Existen $USER_COUNT superusuario(s)"
fi

echo ""
echo "----------------------------------------"
echo "📋 Paso 6: Verificando permisos..."
sudo chown -R admin:admin /opt/bluecoins-web/
chmod 755 /opt/bluecoins-web/logs
chmod 644 databases/*.db 2>/dev/null || true

echo ""
echo "----------------------------------------"
echo "📋 Paso 7: Reiniciando servicios..."
sudo systemctl restart bluecoins-web
sleep 3
sudo systemctl restart nginx

echo ""
echo "----------------------------------------"
echo "📋 Paso 8: Verificando estado de servicios..."
if sudo systemctl is-active --quiet bluecoins-web; then
    echo "✅ Django service está funcionando"
else
    echo "❌ Django service falló. Logs:"
    sudo journalctl -u bluecoins-web --no-pager -l --since "1 minute ago"
fi

if sudo systemctl is-active --quiet nginx; then
    echo "✅ Nginx está funcionando"
else
    echo "❌ Nginx falló. Logs:"
    sudo journalctl -xeu nginx
fi

echo ""
echo "----------------------------------------"
echo "📋 Paso 9: Probando acceso..."
echo "Probando página principal..."
if curl -s "http://$PUBLIC_IP" | grep -q "Bluecoins\|Welcome"; then
    echo "✅ Página principal funciona"
else
    echo "❌ Página principal no responde correctamente"
fi

echo ""
echo "Probando admin login..."
ADMIN_RESPONSE=$(curl -s "http://$PUBLIC_IP/admin/")
if echo "$ADMIN_RESPONSE" | grep -q "Django administration"; then
    echo "✅ Admin login page funciona"
elif echo "$ADMIN_RESPONSE" | grep -q "500"; then
    echo "❌ Admin devuelve error 500"
elif echo "$ADMIN_RESPONSE" | grep -q "400"; then
    echo "❌ Admin devuelve error 400"
else
    echo "⚠️  Admin respuesta inesperada"
fi

echo ""
echo "----------------------------------------"
echo "🎯 Información de login:"
echo "URL: http://$PUBLIC_IP/admin/"
echo "Usuario de prueba: admin"
echo "Contraseña de prueba: admin123"
echo ""
echo "🔍 Comandos para debugging adicional:"
echo "Ver logs en tiempo real: sudo journalctl -u bluecoins-web -f"
echo "Ver logs recientes: sudo journalctl -u bluecoins-web --since '5 minutes ago'"
echo "Verificar configuración: cd /opt/bluecoins-web && source venv/bin/activate && python manage.py shell"
echo "Probar admin manualmente: curl -v http://$PUBLIC_IP/admin/"

echo ""
echo "🌐 Intenta acceder nuevamente a: http://$PUBLIC_IP/admin/"
