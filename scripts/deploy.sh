#!/bin/bash
set -e

# Script para deployar la app a AWS
# Uso: ./scripts/deploy.sh

echo "🚀 Crazy Clothes - Deployment Script"
echo "======================================"

# Variables
APP_NAME="crazy-clothes"
S3_BUCKET="crazy-clothes-deploy"  # Cambia esto
REGION="us-east-1"

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar que estamos en el directorio correcto
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ Error: Ejecuta este script desde el directorio app-cc/${NC}"
    exit 1
fi

# Verificar que AWS CLI está configurado
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI no encontrado. Instálalo primero.${NC}"
    exit 1
fi

echo -e "${BLUE}📦 Paso 1: Build de la aplicación${NC}"
npm run build

echo -e "${BLUE}📤 Paso 2: Subiendo archivos a S3${NC}"
# Crear bucket si no existe
aws s3 mb s3://${S3_BUCKET} --region ${REGION} 2>/dev/null || true

# Subir archivos
tar -czf /tmp/${APP_NAME}.tar.gz \
    --exclude='node_modules' \
    --exclude='.next/cache' \
    --exclude='.git' \
    .

aws s3 cp /tmp/${APP_NAME}.tar.gz s3://${S3_BUCKET}/app.tar.gz

# Subir database dump
aws s3 cp database-dump.sql s3://${S3_BUCKET}/database-dump.sql

echo -e "${BLUE}🔄 Paso 3: Actualizando instancias${NC}"
# Obtener IDs de instancias web
INSTANCE_IDS=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=crazy-clothes-web" \
              "Name=instance-state-name,Values=running" \
    --query "Reservations[*].Instances[*].InstanceId" \
    --output text)

if [ -z "$INSTANCE_IDS" ]; then
    echo -e "${RED}❌ No se encontraron instancias web corriendo${NC}"
    exit 1
fi

# Ejecutar comando de deploy en cada instancia
for INSTANCE_ID in $INSTANCE_IDS; do
    echo -e "${BLUE}  Deployando en instancia: $INSTANCE_ID${NC}"

    aws ssm send-command \
        --instance-ids "$INSTANCE_ID" \
        --document-name "AWS-RunShellScript" \
        --parameters 'commands=[
            "cd /opt/crazy-clothes",
            "aws s3 cp s3://'"${S3_BUCKET}"'/app.tar.gz /tmp/app.tar.gz",
            "tar -xzf /tmp/app.tar.gz -C /opt/crazy-clothes",
            "npm install --production",
            "npm run build",
            "pm2 restart crazy-clothes"
        ]' \
        --output text
done

echo -e "${GREEN}✅ Deploy completado!${NC}"
echo ""
echo "🌐 Tu aplicación estará disponible en el DNS del ALB"
echo "   Obtén la URL con: terraform output alb_url"
