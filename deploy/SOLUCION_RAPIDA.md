# 🚨 Solución Rápida para Error 500 en Django Admin

## Problema Identificado
El error 500 después del login en Django admin es causado por un problema de permisos en la base de datos SQLite. El error específico es:

**`sqlite3.OperationalError: attempt to write a readonly database`**

Django necesita escribir en la base de datos para crear sesiones cuando un usuario hace login, pero el archivo de base de datos no tiene permisos de escritura.

## ✅ Solución Inmediata (Ejecutar en tu servidor)

### Opción 1: Script Automático (Recomendado)
```bash
# Navegar al directorio del proyecto
cd /opt/bluecoins-web

# Hacer ejecutable el script de reparación
chmod +x deploy/fix_database_permissions.sh

# Ejecutar la reparación de permisos
./deploy/fix_database_permissions.sh
```

### Opción 2: Reparación Manual
```bash
# Navegar al directorio del proyecto
cd /opt/bluecoins-web

# 1. Identificar la ruta de la base de datos
DB_PATH=$(python manage.py shell -c "from django.conf import settings; print(settings.DATABASES['default']['NAME'])")
echo "Base de datos: $DB_PATH"

# 2. Corregir permisos del archivo de base de datos
sudo chown admin:admin "$DB_PATH"
sudo chmod 664 "$DB_PATH"

# 3. Corregir permisos del directorio
sudo chown admin:admin "$(dirname "$DB_PATH")"
sudo chmod 755 "$(dirname "$DB_PATH")"

# 4. Corregir permisos de todo el proyecto
sudo chown -R admin:admin /opt/bluecoins-web

# 5. Ejecutar migraciones por si acaso
source venv/bin/activate
python manage.py migrate

# 6. Reiniciar Django
sudo systemctl restart bluecoins-web
```

## 🧪 Verificar que todo funcione

### Comprobar Django (puerto 8000)
```bash
curl http://localhost:8000
```
**Resultado esperado:** HTML de tu página de inicio

### Comprobar nginx + Django (puerto 80)
```bash
curl http://$PUBLIC_IP
```
**Resultado esperado:** El mismo HTML que el paso anterior

## 📍 Obtener tu IP pública
```bash
curl -s https://ipinfo.io/ip
```

## 🌐 Acceder a tu aplicación
Una vez reparado, tu aplicación estará disponible en:
- **http://TU_IP_PUBLICA** (reemplaza con la IP que obtuviste)

## 🔧 Si aún tienes problemas

### Ver logs de nginx
```bash
sudo journalctl -xeu nginx
```

### Ver logs de tu aplicación Django
```bash
sudo journalctl -u bluecoins-web -f
```

### Comprobar estado de los servicios
```bash
sudo systemctl status nginx
sudo systemctl status bluecoins-web
```

## ✅ Resultado Final Esperado
Después de aplicar la solución, deberías poder acceder a tu aplicación Django a través de nginx en el puerto 80 usando tu IP pública de EC2.
