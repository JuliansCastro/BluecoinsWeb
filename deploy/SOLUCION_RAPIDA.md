# 🚨 Solución Rápida para Problema de Nginx

## Problema Identificado
El script de deployment funcionó correctamente, pero nginx falló debido a un problema en la configuración del `server_name` cuando no se pudo detectar la IP pública automáticamente.

## ✅ Solución Inmediata (Ejecutar en tu servidor)

### Opción 1: Script Automático (Recomendado)
```bash
# Navegar al directorio del proyecto
cd /opt/bluecoins-web

# Hacer ejecutable el script de reparación
chmod +x deploy/fix_nginx.sh

# Ejecutar la reparación
./deploy/fix_nginx.sh
```

### Opción 2: Reparación Manual
```bash
# Obtener la IP pública real
PUBLIC_IP=$(curl -s https://ipinfo.io/ip)
echo "Tu IP pública es: $PUBLIC_IP"

# Reparar la configuración de nginx
sudo sed -i "s/server_name.*/server_name $PUBLIC_IP;/" /etc/nginx/conf.d/bluecoins-web.conf

# Verificar que la configuración sea válida
sudo nginx -t

# Si es válida, reiniciar nginx
sudo systemctl restart nginx

# Verificar que nginx esté corriendo
sudo systemctl status nginx
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
