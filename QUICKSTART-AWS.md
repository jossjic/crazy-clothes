# 🚀 Quick Start - Deploy a AWS (Cuenta de la Empresa)

Guía rápida para deployar desde tu computadora del trabajo.

## ⚡ Pasos rápidos

### 1. Clonar el repo
```bash
git clone https://github.com/jossjic/crazy-clothes.git
cd crazy-clothes/app-cc
```

### 2. Configurar AWS CLI con perfil de la empresa
```bash
aws configure --profile crazy-clothes
# Access Key ID: (pedir al admin)
# Secret Key: (pedir al admin)
# Region: us-east-1
# Output: json

# Verificar que estás en la cuenta correcta
aws sts get-caller-identity --profile crazy-clothes
```

### 3. Generar SSH key
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/crazy-clothes
```

### 4. Crear terraform.tfvars
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Editar `terraform.tfvars`:
```hcl
aws_profile = "crazy-clothes"
your_ip_cidr = "TU.IP.AQUI/32"  # curl ifconfig.me
```

### 5. Deploy
```bash
terraform init
terraform plan    # revisar qué va a crear
terraform apply   # escribe 'yes'
```

### 6. Obtener URL
```bash
terraform output alb_url
# http://crazy-clothes-alb-xxxxx.us-east-1.elb.amazonaws.com
```

## 📖 Documentación completa

Ver `DEPLOYMENT.md` para instrucciones detalladas.

## 💰 Costos

~$80/mes en us-east-1

## 🗑️ Destruir todo

```bash
terraform destroy
```
