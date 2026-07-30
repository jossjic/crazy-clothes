# 🚀 Activar GitHub Actions Pipeline

## Paso 1: Commit todos los cambios

```bash
cd ~/Work/crazy-clothes/app-cc

# Agregar todos los archivos modificados
git add .

# Crear commit con mensaje descriptivo
git commit -m "fix(infra): Apply all 11 AWS deployment fixes

- Add S3 backend for terraform state
- Add IAM roles for SSM Session Manager access
- Rewrite user_data_db.sh for MySQL 8.0 Community
- Rewrite user_data_web.sh with dnf retry logic + prebuilt .next
- Regenerate database-dump.sql without warning
- Add GitHub Actions CI/CD workflow with OIDC
- Update Next.js from 15.1.6 to 16.2.12 (CVE fix)
- Add /pedidos/[id] detail page
- Improve FormPieza with smart SKU selector
- Add migration 001 for pedido tracking

All fixes verified from real AWS deployment (account 660759882203).
Next terraform apply will work cleanly from scratch."
```

## Paso 2: Push a GitHub

```bash
git push origin main
```

**¡Esto activará automáticamente el workflow!**

---

## 🔍 Ver el pipeline corriendo

### Opción A: GitHub Web UI (recomendado)

1. Ve a: https://github.com/jossjic/crazy-clothes
2. Click en la pestaña **"Actions"**
3. Deberías ver el workflow "Deploy to AWS" corriendo

### Opción B: GitHub CLI (si está instalado)

```bash
gh run list --repo jossjic/crazy-clothes
gh run watch  # Ver en tiempo real
```

---

## ⚠️ IMPORTANTE: Requisitos previos

**ANTES de que el pipeline funcione completamente**, necesitas:

### 1. Subir artifacts iniciales a S3

El pipeline necesita estos archivos en S3 para el primer deploy:

```bash
# Database dump (ya está regenerado correctamente)
aws s3 cp ~/Work/crazy-clothes/app-cc/database-dump.sql \
  s3://crazy-clothes-deploy-660759882203/database-dump.sql

# Build inicial de .next (hasta que el pipeline corra por primera vez)
cd ~/Work/crazy-clothes/app-cc
npm install
npm run build
tar -czf next-build.tar.gz .next
aws s3 cp next-build.tar.gz \
  s3://crazy-clothes-deploy-660759882203/next-build.tar.gz
```

### 2. Verificar IAM Role OIDC existe

El workflow usa este role:
```
arn:aws:iam::660759882203:role/crazy-clothes-github-actions-deploy
```

Según el reporte, **YA EXISTE** en tu cuenta AWS. Verifica que tenga permisos para:
- `s3:PutObject` / `s3:GetObject` en el bucket de deploy
- `ssm:SendCommand` + `ssm:GetCommandInvocation`
- `autoscaling:DescribeAutoScalingGroups`

---

## 🎯 Qué hace el pipeline cuando se activa

1. **Checkout** - Descarga el código del repo
2. **Setup Node.js** - Instala Node 20
3. **Install dependencies** - `npm ci` en `app-cc/`
4. **Build** - `npm run build` (genera `.next/`)
5. **Create artifact** - `tar -czf next-build.tar.gz .next`
6. **Configure AWS** - Autenticación vía OIDC (sin access keys)
7. **Upload to S3** - Sube el artifact al bucket
8. **Deploy via SSM** - Envía comando a todas las instancias del ASG para:
   - Descargar el nuevo artifact
   - Extraer en `/opt/crazy-clothes/.next`
   - Reiniciar PM2

---

## 🐛 Si el pipeline falla

### Error: "role-to-assume not found"
→ Verifica que el IAM Role OIDC existe en tu cuenta AWS

### Error: "Access Denied" en S3
→ Verifica que el role tiene permisos S3

### Error: "No instances found in ASG"
→ El ASG debe estar corriendo (al menos 1 instancia healthy)

### Error durante build
→ Verifica que todas las páginas tengan `export const dynamic = 'force-dynamic'`

---

## 🔄 Después del primer deploy exitoso

Cada vez que hagas push a `main` (y los cambios estén en `app-cc/**`), el pipeline:
1. ✅ Se activa automáticamente
2. ✅ Hace build
3. ✅ Sube a S3
4. ✅ Despliega a todas las instancias

**No necesitas hacer nada manual.** El pipeline se encarga de todo.

---

## 📊 Pipeline status

El pipeline se activa por:
- ✅ Push a `main` (si cambia algo en `app-cc/**`)
- ✅ Push a `main` (si cambia `.github/workflows/deploy.yml`)
- ✅ Manualmente desde GitHub UI (Actions → Deploy to AWS → Run workflow)

---

## ✅ Checklist

Antes de hacer push:

- [ ] Verificar que el IAM Role OIDC existe en AWS
- [ ] Subir `database-dump.sql` a S3 (una vez)
- [ ] Subir `next-build.tar.gz` inicial a S3 (una vez)
- [ ] Verificar que el ASG está corriendo
- [ ] Hacer commit de todos los cambios
- [ ] Push a `main`
- [ ] Ver el pipeline en GitHub Actions

---

**Después de push, ve a:** https://github.com/jossjic/crazy-clothes/actions
