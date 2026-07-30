# 🚀 Guía de Deployment a AWS

Esta guía explica cómo deployar Crazy Clothes en AWS usando una arquitectura de 3 capas segura.

## 🏗️ Arquitectura

```
Internet
   ↓
[Application Load Balancer]  ← Subnet Pública (10.0.1.0/24, 10.0.2.0/24)
   ↓
[Web Servers (Auto Scaling)]  ← Subnet Privada App (10.0.11.0/24, 10.0.12.0/24)
   ↓
[MySQL Database]              ← Subnet Privada DB (10.0.21.0/24, 10.0.22.0/24)
```

### Componentes:

1. **VPC** con 6 subnets (2 públicas, 2 privadas app, 2 privadas DB) en 2 AZs
2. **Application Load Balancer** (ALB) en subnets públicas
3. **Auto Scaling Group** con 2-4 instancias web en subnets privadas
4. **MySQL EC2** en subnet privada de DB
5. **NAT Gateway** para que instancias privadas accedan a internet
6. **Bastion Host** para acceso SSH a instancias privadas

### Seguridad:

- ✅ Web servers **sin IP pública**, solo accesibles desde ALB
- ✅ Database **sin IP pública**, solo accesible desde web servers
- ✅ Security Groups con principio de mínimo privilegio
- ✅ Bastion host con acceso SSH restringido a tu IP

### Costos estimados (us-east-1):

| Recurso | Tipo | Costo mensual |
|---------|------|---------------|
| ALB | - | ~$16 |
| NAT Gateway | - | ~$32 |
| DB EC2 | t3.small | ~$15 |
| Web EC2 x2 | t3.micro | ~$16 |
| **Total** | | **~$80/mes** |

---

## 📋 Prerrequisitos

1. **Cuenta de AWS** con credenciales configuradas
2. **AWS CLI** instalado y configurado
3. **Terraform** instalado ([download](https://www.terraform.io/downloads))
4. **SSH key pair** generado

---

## 🚀 Pasos de Deployment

### 1. Configurar AWS CLI

```bash
# Instalar AWS CLI (si no lo tienes)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configurar credenciales
aws configure
# AWS Access Key ID: (tu key)
# AWS Secret Access Key: (tu secret)
# Default region: us-east-1
# Default output format: json
```

### 2. Generar SSH Key

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/crazy-clothes
# Presiona Enter para aceptar defaults
```

### 3. Configurar Variables de Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edita `terraform.tfvars` y ajusta:

```hcl
# Obtén tu IP actual
your_ip_cidr = "TU.IP.PUBLICA.AQUI/32"

# Ajusta la región si quieres usar otra
aws_region = "us-east-1"

# Ajusta los tipos de instancia según presupuesto
db_instance_type = "t3.small"   # o t3.micro para ahorrar
web_instance_type = "t3.micro"
```

**Obtener tu IP pública:**
```bash
curl ifconfig.me
# Agrega /32 al final, ejemplo: 203.0.113.45/32
```

**Obtener AMI más reciente de Amazon Linux 2023:**
```bash
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=al2023-ami-2023.*-x86_64" \
  --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
  --output text
```

### 4. Inicializar y Aplicar Terraform

```bash
cd terraform

# Inicializar Terraform
terraform init

# Ver el plan de ejecución
terraform plan

# Aplicar (crear la infraestructura)
terraform apply
# Escribe 'yes' para confirmar
```

Esto tardará ~5-10 minutos. Al finalizar verás los outputs:

```
Outputs:

alb_url = "http://crazy-clothes-alb-123456789.us-east-1.elb.amazonaws.com"
bastion_public_ip = "54.123.45.67"
db_private_ip = "10.0.21.10"
```

### 5. Subir Database Dump a S3

```bash
# Crear bucket S3 para deployment
aws s3 mb s3://crazy-clothes-deploy --region us-east-1

# Subir database dump
aws s3 cp database-dump.sql s3://crazy-clothes-deploy/

# Subir código (tar.gz)
tar -czf /tmp/app.tar.gz \
    --exclude='node_modules' \
    --exclude='.next' \
    --exclude='.git' \
    .

aws s3 cp /tmp/app.tar.gz s3://crazy-clothes-deploy/
```

### 6. Conectarse al DB e Importar Datos

```bash
# Conectarse al bastion
ssh -i ~/.ssh/crazy-clothes ec2-user@<BASTION_IP>

# Desde el bastion, conectarse al DB
ssh ec2-user@<DB_PRIVATE_IP>

# En el DB server, descargar e importar dump
aws s3 cp s3://crazy-clothes-deploy/database-dump.sql /tmp/
mysql -u root -pCrazyClothes2026SecurePass cc < /tmp/database-dump.sql

# Verificar
mysql -u root -pCrazyClothes2026SecurePass cc -e "SHOW TABLES;"
```

### 7. Deployar Código a Web Servers

```bash
# Opción A: Usar el script de deploy
./scripts/deploy.sh

# Opción B: Manual via SSM (Session Manager)
# Obtener IDs de instancias web
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=crazy-clothes-web" \
            "Name=instance-state-name,Values=running" \
  --query "Reservations[*].Instances[*].InstanceId"

# Conectarse via SSM
aws ssm start-session --target <INSTANCE_ID>

# En la instancia web:
cd /opt/crazy-clothes
aws s3 cp s3://crazy-clothes-deploy/app.tar.gz /tmp/
tar -xzf /tmp/app.tar.gz -C /opt/crazy-clothes
npm install --production
npm run build
pm2 restart crazy-clothes
```

### 8. Verificar que Todo Funciona

```bash
# Obtener URL del ALB
terraform output alb_url

# Hacer request
curl $(terraform output -raw alb_url)
```

Abre el URL en tu navegador. Deberías ver la app funcionando!

---

## 🔄 Updates y Re-deployments

### Actualizar código de la app:

```bash
# Hacer cambios en el código
git add .
git commit -m "feat: nueva funcionalidad"
git push

# Re-deployar
./scripts/deploy.sh
```

### Actualizar infraestructura:

```bash
cd terraform

# Editar archivos .tf según necesites
vim main.tf

# Aplicar cambios
terraform plan
terraform apply
```

### Agregar más web servers:

```bash
# Editar terraform/terraform.tfvars
desired_web_instances = 4  # antes era 2

# Aplicar
terraform apply
```

---

## 🔒 Acceso a Instancias Privadas

### Via Bastion Host:

```bash
# 1. SSH al bastion
ssh -i ~/.ssh/crazy-clothes ec2-user@<BASTION_IP>

# 2. Desde bastion, SSH a instancia privada
ssh ec2-user@<PRIVATE_IP>
```

### Via AWS Session Manager (más seguro):

```bash
# Instalar plugin de Session Manager
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
sudo rpm -i session-manager-plugin.rpm

# Conectarse a instancia
aws ssm start-session --target <INSTANCE_ID>
```

---

## 📊 Monitoreo

### Ver logs de web servers:

```bash
# Via SSM
aws ssm start-session --target <INSTANCE_ID>

# Ver logs de PM2
pm2 logs crazy-clothes

# Ver logs de user-data
tail -f /var/log/user-data.log
```

### Ver logs del ALB:

```bash
# Habilitar access logs del ALB (opcional, cuesta extra)
aws elbv2 modify-load-balancer-attributes \
    --load-balancer-arn <ALB_ARN> \
    --attributes Key=access_logs.s3.enabled,Value=true \
                 Key=access_logs.s3.bucket,Value=crazy-clothes-logs
```

### CloudWatch:

- Ve a CloudWatch console
- Busca métricas de:
  - EC2: CPUUtilization, NetworkIn/Out
  - ELB: TargetResponseTime, RequestCount
  - Auto Scaling: GroupDesiredCapacity

---

## 🗑️ Destruir Todo (Cleanup)

**⚠️ CUIDADO: Esto borrará toda la infraestructura!**

```bash
cd terraform
terraform destroy
# Escribe 'yes' para confirmar

# Borrar bucket S3
aws s3 rb s3://crazy-clothes-deploy --force
```

---

## 🐛 Troubleshooting

### Web servers no arrancan:

1. Verificar user-data logs:
   ```bash
   aws ssm start-session --target <INSTANCE_ID>
   tail -f /var/log/user-data.log
   ```

2. Verificar security groups:
   ```bash
   terraform state show aws_security_group.web
   ```

### No puedo conectarme al DB desde web:

1. Verificar security group del DB permite tráfico desde web SG
2. Verificar que MySQL está corriendo en DB:
   ```bash
   systemctl status mysqld
   ```

### ALB health checks fallan:

1. Verificar que app está corriendo en puerto 3000:
   ```bash
   curl localhost:3000
   pm2 status
   ```

2. Verificar target group health:
   ```bash
   aws elbv2 describe-target-health \
       --target-group-arn <TARGET_GROUP_ARN>
   ```

---

## 📚 Recursos Adicionales

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [Auto Scaling User Guide](https://docs.aws.amazon.com/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html)
- [ALB User Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
