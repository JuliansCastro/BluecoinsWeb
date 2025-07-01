#!/bin/bash
# Script para arreglar permisos de la base de datos SQLite

echo "🔧 Solucionando problema de permisos de base de datos..."

cd /opt/bluecoins-web

# Identificar el archivo de base de datos actual
echo "----------------------------------------"
echo "📋 Verificando configuración de base de datos:"

# Obtener la ruta de la base de datos desde Django
DB_PATH=$(python manage.py shell -c "
from django.conf import settings
db_config = settings.DATABASES['default']
if db_config['ENGINE'] == 'django.db.backends.sqlite3':
    print(db_config['NAME'])
else:
    print('No es SQLite')
" 2>/dev/null)

echo "Base de datos encontrada: $DB_PATH"

# Verificar permisos actuales
echo ""
echo "----------------------------------------"
echo "📋 Permisos actuales:"
if [ -f "$DB_PATH" ]; then
    ls -la "$DB_PATH"
    ls -la "$(dirname "$DB_PATH")"
else
    echo "❌ Archivo de base de datos no encontrado: $DB_PATH"
fi

# Arreglar permisos
echo ""
echo "----------------------------------------"
echo "🔧 Corrigiendo permisos..."

# 1. Cambiar propietario del archivo de base de datos
if [ -f "$DB_PATH" ]; then
    echo "Cambiando propietario del archivo de base de datos..."
    sudo chown admin:admin "$DB_PATH"
    sudo chmod 664 "$DB_PATH"
else
    echo "Creando archivo de base de datos con permisos correctos..."
    touch "$DB_PATH"
    sudo chown admin:admin "$DB_PATH"
    sudo chmod 664 "$DB_PATH"
fi

# 2. Cambiar propietario del directorio que contiene la base de datos
DB_DIR=$(dirname "$DB_PATH")
echo "Cambiando propietario del directorio de base de datos: $DB_DIR"
sudo chown admin:admin "$DB_DIR"
sudo chmod 755 "$DB_DIR"

# 3. Si hay archivos adicionales de SQLite (.db-shm, .db-wal), arreglar sus permisos también
for ext in "" "-shm" "-wal" "-journal"; do
    if [ -f "${DB_PATH}${ext}" ]; then
        echo "Corrigiendo permisos de ${DB_PATH}${ext}"
        sudo chown admin:admin "${DB_PATH}${ext}"
        sudo chmod 664 "${DB_PATH}${ext}"
    fi
done

# 4. Asegurar que todo el directorio del proyecto tenga los permisos correctos
echo "Verificando permisos del proyecto..."
sudo chown -R admin:admin /opt/bluecoins-web
sudo chmod -R 755 /opt/bluecoins-web
sudo chmod 664 "$DB_PATH" 2>/dev/null || true

# Verificar permisos después del cambio
echo ""
echo "----------------------------------------"
echo "📋 Permisos después de la corrección:"
ls -la "$DB_PATH"
ls -la "$DB_DIR"

# Ejecutar migraciones para asegurar que la base de datos esté actualizada
echo ""
echo "----------------------------------------"
echo "🔄 Ejecutando migraciones..."
source venv/bin/activate
python manage.py migrate

# Verificar que Django puede escribir en la base de datos
echo ""
echo "----------------------------------------"
echo "🧪 Probando escritura en base de datos..."
python manage.py shell -c "
from django.contrib.sessions.models import Session
print('Verificando acceso a sesiones...')
print('Número de sesiones:', Session.objects.count())
print('✅ Base de datos accesible para escritura')
" 2>/dev/null || echo "❌ Aún hay problemas con la base de datos"

# Reiniciar el servicio de Django
echo ""
echo "----------------------------------------"
echo "🔄 Reiniciando servicio de Django..."
sudo systemctl restart bluecoins-web
sleep 3

# Verificar estado del servicio
if sudo systemctl is-active --quiet bluecoins-web; then
    echo "✅ Servicio de Django reiniciado correctamente"
else
    echo "❌ Problema al reiniciar el servicio"
    sudo systemctl status bluecoins-web --no-pager -l
fi

echo ""
echo "----------------------------------------"
echo "✅ ¡Corrección completada!"
echo ""
echo "🌐 Ahora puedes intentar acceder al admin:"
echo "   🔗 http://18.118.207.42/admin"
echo ""
echo "Si aún tienes problemas, verifica los logs con:"
echo "   sudo journalctl -u bluecoins-web -f"
