# 🚀 Auto-Deployment con GitHub Actions

**¡Tu app se despliega automáticamente cada vez que hagas push a main!**

## ⚡ Configuración Rápida (5 minutos)

### 1. Configurar GitHub Secrets

Ve a tu repo → **Settings** → **Secrets and variables** → **Actions**

Agrega estos 3 secrets:

| Secret | Valor |
|--------|-------|
| `AWS_HOST` | Tu IP pública de EC2 |
| `AWS_USERNAME` | `admin` o `ec2-user` |
| `AWS_SSH_KEY` | Contenido de tu archivo `.pem` |

### 2. Subir el workflow

```bash
git add .github/workflows/deploy.yml
git commit -m "Add auto-deployment"
git push origin main
```

### 3. ¡Listo! 🎉

Ya está configurado. La próxima vez que hagas push, se desplegará automáticamente.

## 🔄 Cómo funciona

1. Haces `git push origin main`
2. GitHub Actions ejecuta automáticamente
3. Se conecta a tu servidor AWS via SSH
4. Ejecuta el script `deploy/update.sh`
5. Tu app se actualiza en 1-2 minutos

## 📊 Monitorear deployments

- **GitHub**: Ve a la pestaña "Actions" en tu repo
- **Servidor**: `sudo journalctl -u bluecoins-web -f`
- **Test**: `curl http://tu-ip-publica`

## 🆘 Si algo falla

1. Revisa los logs en GitHub Actions
2. Verifica que los secrets estén bien configurados
3. Prueba manualmente: `./deploy/update.sh`

**¡Ya puedes enfocarte solo en programar!** 🎯
