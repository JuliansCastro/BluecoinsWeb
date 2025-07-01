# 🚨 Solución para Error 500 en Django Admin

## Problema Identificado
Después de hacer login en `/admin/`, Django devuelve un error 500 en lugar de mostrar el panel de administración. Esto puede ser causado por varios factores.

## ✅ Solución Automática (Recomendada)

### Ejecutar script de reparación completa
```bash
# Navegar al directorio del proyecto
cd /opt/bluecoins-web

# Hacer ejecutable el script de diagnóstico
chmod +x deploy/diagnose_admin.sh
chmod +x deploy/fix_admin.sh

# Primero diagnosticar el problema
./deploy/diagnose_admin.sh

# Luego aplicar las correcciones
./deploy/fix_admin.sh
```

## ✅ Solución Manual

### Paso 1: Verificar logs
```bash
# Ver logs recientes de Django
sudo journalctl -u bluecoins-web --since "10 minutes ago"

# Ver logs de nginx
sudo tail -20 /var/log/nginx/error.log
```

### Paso 2: Verificar configuración básica
```bash
cd /opt/bluecoins-web
source venv/bin/activate

# Verificar configuración de Django
python manage.py check

# Verificar variables de entorno
grep DJANGO_ .env
```

### Paso 3: Verificar base de datos y migraciones
```bash
# Ejecutar migraciones pendientes
python manage.py migrate

# Verificar estado de migraciones
python manage.py showmigrations

# Verificar que la base de datos admin existe
ls -la databases/bluecoins_admin.db
```

### Paso 4: Recolectar archivos estáticos
```bash
# Recolectar archivos estáticos del admin
python manage.py collectstatic --noinput
```

### Paso 5: Verificar/crear superusuario
```bash
# Verificar si existe un superusuario
python manage.py shell -c "
from django.contrib.auth.models import User
print('Superusuarios:', User.objects.filter(is_superuser=True).count())
"

# Si no existe, crear uno
python manage.py createsuperuser
```

### Paso 6: Reiniciar servicios
```bash
# Reiniciar Django
sudo systemctl restart bluecoins-web

# Reiniciar nginx
sudo systemctl restart nginx

# Verificar estado
sudo systemctl status bluecoins-web
sudo systemctl status nginx
```

## 🔍 Diagnóstico Avanzado

### Verificar configuración específica
```bash
cd /opt/bluecoins-web
source venv/bin/activate

python manage.py shell -c "
from django.conf import settings
print('DEBUG:', settings.DEBUG)
print('ALLOWED_HOSTS:', settings.ALLOWED_HOSTS)
print('SECRET_KEY length:', len(settings.SECRET_KEY))
print('DATABASES:', list(settings.DATABASES.keys()))
"
```

### Probar admin manualmente
```bash
# Obtener respuesta completa del admin
curl -v http://YOUR_IP/admin/

# Verificar códigos de estado
curl -I http://YOUR_IP/admin/
```

### Ver logs en tiempo real
```bash
# Logs de Django en tiempo real
sudo journalctl -u bluecoins-web -f

# En otra terminal, intenta acceder al admin y observa los logs
```

## 🛠️ Soluciones Específicas

### Si el problema es de sesiones:
```bash
# Limpiar sesiones
cd /opt/bluecoins-web
source venv/bin/activate
python manage.py clearsessions
sudo systemctl restart bluecoins-web
```

### Si el problema es de archivos estáticos:
```bash
# Verificar archivos estáticos del admin
ls -la staticfiles/admin/

# Si no existen, recolectar
python manage.py collectstatic --noinput
```

### Si el problema es de permisos:
```bash
# Corregir permisos
sudo chown -R admin:admin /opt/bluecoins-web/
chmod 644 databases/*.db
sudo systemctl restart bluecoins-web
```

## 🎯 Usuario de Prueba

El script automático crea un usuario de prueba:
- **Usuario**: admin
- **Contraseña**: admin123

## 📍 URLs para probar

- Página principal: `http://YOUR_IP/`
- Admin login: `http://YOUR_IP/admin/`
- Admin directamente: `http://YOUR_IP/admin/login/`

## ⚠️ Problemas Comunes

1. **Base de datos admin no existe**: El script creará `databases/bluecoins_admin.db`
2. **Migraciones pendientes**: El script ejecutará todas las migraciones
3. **Archivos estáticos faltantes**: El script recolectará archivos del admin
4. **Permisos incorrectos**: El script corregirá permisos de archivos
5. **ALLOWED_HOSTS mal configurado**: El script actualizará la configuración

## ✅ Resultado Esperado

Después de aplicar las soluciones, deberías poder:
1. Acceder a `http://YOUR_IP/admin/`
2. Ver la página de login del admin de Django
3. Hacer login con tu usuario
4. Acceder al panel de administración sin errores 500
