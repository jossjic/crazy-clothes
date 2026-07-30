# Crazy Clothes - Sistema de Inventario y Ventas

Sistema web completo para gestión de inventario, ventas, comisiones y capital de Crazy Clothes.

## 🚀 Características

### Módulos Implementados (v1.0)

1. **Inventario Completo**
   - Vista unificada de stock con costos, precios y márgenes
   - Tracking por ubicación (Puebla, Mérida, Veracruz)
   - Navegación a detalle de cada pieza

2. **Ventas y Comisiones**
   - Registro de ventas multi-línea
   - Cálculo automático de comisiones: Negociador (8%), Entrega (5%)
   - Dashboard por socio y canal de venta

3. **Capital y Participación**
   - Aportaciones, retiros, reinversiones por socio
   - Cálculo de valor de participación
   - ROI mensual dinámico
   - Comparación con instrumentos de inversión
   - Análisis de estructura de comisiones

4. **Compras (Cruces)**
   - Flujo: Cruce → Paquetes → Piezas
   - Separación automática: Inventario negocio vs Personal
   - Prorrateo volumétrico de costos de envío

5. **Pedidos a Proveedores**
   - Tracking de órdenes: PENDIENTE → EN_TRANSITO → RECIBIDO
   - Creación automática de movimientos de inventario
   - Alertas de pedidos atrasados

6. **Deudas entre Socios**
   - Registro de préstamos internos
   - Balance por socio: por cobrar / por pagar
   - Control de vencimientos

7. **Cierres Mensuales**
   - Snapshot histórico de métricas financieras
   - Gráfico de evolución de ingresos
   - Preservación de estado del capital y comisiones

8. **Reportes**
   - Ventas por período
   - Top productos vendidos
   - Análisis por canal de venta

9. **Configuración del Sistema**
   - Parámetros editables sin tocar código
   - Tipo de cambio, porcentajes de comisión, alertas

10. **Listas Maestras (CRUD)**
    - Marcas, Tipos de prenda, Ubicaciones, Canales de venta

## 🛠️ Stack Técnico

- **Frontend**: Next.js 15 + React 19
  - Server Components
  - Server Actions
  - App Router
- **Backend**: Node.js
- **Base de datos**: MySQL 8.4
- **Estilos**: Tailwind CSS
- **Iconos**: Lucide React

## 📦 Instalación y Configuración

### Requisitos previos

- **Node.js** 18+ ([descargar aquí](https://nodejs.org/))
- **Docker** (para MySQL) ([descargar aquí](https://www.docker.com/get-started))
- **Git** ([descargar aquí](https://git-scm.com/downloads))

### Instalación paso a paso

#### 1️⃣ Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/crazy-clothes.git
cd crazy-clothes/app-cc
```

#### 2️⃣ Instalar dependencias de Node.js

```bash
npm install
```

Esto instalará todas las dependencias necesarias (Next.js, React, MySQL client, etc.).

#### 3️⃣ Levantar la base de datos MySQL con Docker

**Opción A: Primera vez (crear contenedor nuevo)**

```bash
docker run --name cc_mysql \
  -e MYSQL_ROOT_PASSWORD=test \
  -e MYSQL_DATABASE=cc \
  -p 33306:3306 \
  -d mysql:8.4
```

**Opción B: Si ya existe el contenedor (reiniciarlo)**

```bash
docker start cc_mysql
```

**Verificar que MySQL está corriendo:**

```bash
docker ps | grep cc_mysql
```

Deberías ver algo como:
```
CONTAINER ID   IMAGE       STATUS          PORTS
abc123def456   mysql:8.4   Up 5 seconds    0.0.0.0:33306->3306/tcp
```

#### 4️⃣ Importar la base de datos

```bash
docker exec -i cc_mysql mysql -uroot -ptest cc < database-dump.sql
```

Esto cargará:
- 17 tablas con datos iniciales
- 5 views calculadas
- 33 SKUs con costos
- Datos de ejemplo de ventas y compras

**Verificar que se importó correctamente:**

```bash
docker exec -it cc_mysql mysql -uroot -ptest cc -e "SHOW TABLES;"
```

Deberías ver todas las tablas del sistema.

#### 5️⃣ Configurar variables de entorno

Crear el archivo `.env.local` en la raíz del proyecto:

```bash
cat > .env.local << 'EOF'
DB_HOST=127.0.0.1
DB_PORT=33306
DB_USER=root
DB_PASSWORD=test
DB_NAME=cc
EOF
```

#### 6️⃣ Ejecutar el proyecto en modo desarrollo

```bash
npm run dev
```

Deberías ver:

```
  ▲ Next.js 15.0.0
  - Local:        http://localhost:3000
  - Ready in 2.1s
```

#### 7️⃣ Abrir en el navegador

Visita: **http://localhost:3000**

Deberías ver el dashboard principal con el sidebar de navegación.

---

## 🔧 Comandos útiles

### Desarrollo

```bash
npm run dev          # Iniciar servidor de desarrollo
npm run build        # Compilar para producción
npm run start        # Ejecutar versión de producción
```

### Base de datos

```bash
# Ver logs de MySQL
docker logs cc_mysql

# Conectarse a MySQL
docker exec -it cc_mysql mysql -uroot -ptest cc

# Detener MySQL
docker stop cc_mysql

# Reiniciar MySQL
docker restart cc_mysql

# Hacer backup de la BD
docker exec cc_mysql mysqldump -uroot -ptest cc > backup.sql

# Restaurar backup
docker exec -i cc_mysql mysql -uroot -ptest cc < backup.sql
```

### Git

```bash
# Ver cambios
git status

# Crear un branch para tu feature
git checkout -b feature/nombre-del-feature

# Hacer commit
git add .
git commit -m "feat: descripción del cambio"

# Subir cambios
git push origin feature/nombre-del-feature
```

---

## 🐛 Solución de problemas comunes

### Error: "Cannot connect to MySQL"

**Solución:**
1. Verificar que Docker está corriendo: `docker ps`
2. Reiniciar el contenedor: `docker restart cc_mysql`
3. Verificar el puerto: `docker port cc_mysql`

### Error: "Port 33306 already in use"

**Solución:**
```bash
# Encontrar qué proceso usa el puerto
lsof -i :33306

# Detener el contenedor antiguo
docker stop cc_mysql
docker rm cc_mysql

# Crear uno nuevo
docker run --name cc_mysql -e MYSQL_ROOT_PASSWORD=test -e MYSQL_DATABASE=cc -p 33306:3306 -d mysql:8.4
```

### Error: "Module not found" o errores de npm

**Solución:**
```bash
# Limpiar node_modules y reinstalar
rm -rf node_modules package-lock.json
npm install
```

### El frontend no se actualiza

**Solución:**
```bash
# Limpiar caché de Next.js
rm -rf .next
npm run dev
```

---

## 🚀 Guía para contribuir

### Para Agusto y Luis (o cualquier colaborador)

1. **Clonar el repo y hacer setup** (pasos 1-7 arriba)

2. **Crear un branch para tu trabajo:**
   ```bash
   git checkout -b feature/mi-mejora
   ```

3. **Hacer tus cambios** en el código

4. **Probar localmente:**
   ```bash
   npm run dev
   # Abrir http://localhost:3000 y verificar que funciona
   ```

5. **Hacer commit:**
   ```bash
   git add .
   git commit -m "feat: descripción clara del cambio"
   ```

6. **Subir tu branch:**
   ```bash
   git push origin feature/mi-mejora
   ```

7. **Crear un Pull Request** en GitHub

### Estructura del código

```
app-cc/
├── app/                    # Páginas Next.js (App Router)
│   ├── inventario/        # Módulo de inventario
│   ├── ventas/            # Módulo de ventas
│   ├── capital/           # Módulo de capital
│   ├── config/            # Configuración
│   └── ...
├── lib/
│   ├── db.js              # Conexión a MySQL
│   └── actions.js         # Server Actions (backend)
├── components/            # Componentes reutilizables
├── database-dump.sql      # Dump inicial de la BD
└── README.md              # Esta guía
```

### Dónde hacer cambios comunes

- **Agregar una página nueva:** Crear carpeta en `app/`
- **Modificar el backend:** Editar `lib/actions.js`
- **Cambiar estilos:** Usar Tailwind classes o editar `app/globals.css`
- **Agregar un ícono:** Importar de `lucide-react`
- **Modificar la BD:** Crear migration SQL y actualizar `database-dump.sql`

### Buenas prácticas

- ✅ Hacer commits pequeños y frecuentes
- ✅ Escribir mensajes de commit descriptivos
- ✅ Probar localmente antes de hacer push
- ✅ Comentar código complejo
- ✅ Hacer backup de la BD antes de cambios grandes
- ❌ No hacer commit de `node_modules/` o `.env.local`
- ❌ No modificar directamente en `main`, usar branches

## 📊 Estructura de Base de Datos

### Tablas principales:
- `sku` - Catálogo de productos
- `movimiento` - Stock derivado (COMPRA, VENTA, PERSONAL)
- `cruce`, `paquete`, `pieza` - Jerarquía de compras
- `venta`, `venta_linea` - Ventas multi-línea
- `comision` - Registro de comisiones
- `capital_movimiento` - Flujo de capital por socio
- `socio` - Socios del negocio
- `prestamo` - Deudas internas
- `pedido_orden`, `pedido_orden_linea` - Órdenes a proveedores
- `cierre_mensual` - Snapshots históricos
- `configuracion` - Parámetros del sistema

### Views calculadas:
- `v_sku_stock` - Stock actual por SKU
- `v_pieza_costo` - Costos con prorrateo volumétrico
- `v_capital_socio` - Capital y participación por socio
- `v_deuda_balance` - Balance de préstamos
- `v_pedido_orden_resumen` - Resumen de pedidos

### Lógica de costos:
- **Prorrateo volumétrico**: El costo del cruce se distribuye según `factor_volumetrico` (marca × tipo_prenda)
- **Fallback**: SKUs sin paquete usan `sku_costo` directamente
- **Margen**: `precio_lista - costo_total`

## 🎯 Modelo de Negocio

### Flujo de compra:
1. Cruce (envío desde USA) con costo total
2. Paquetes individuales dentro del cruce
3. Piezas por marca/tipo con factor volumétrico
4. Prorrateo: `costo_pieza = (costo_cruce × factor_volumetrico) / sum(factores)`

### Comisiones:
- **Negociador**: 8% del precio de venta
- **Entrega**: 5% del precio de venta
- **Total**: 13% por venta

### Capital:
- Cada socio tiene % de participación
- Capital = Aportaciones - Retiros + Reinversiones + (Utilidad × % Ownership)
- Valor de Participación = Valor Teórico × % Ownership

### ROI:
- ROI total = (Valor Participación + Comisiones - Inversión) / Inversión
- ROI mensual = ROI total / meses_transcurridos (dinámico)

## 📝 Versión

**v1.0.0** - Primera versión completa
- Fecha: 29 julio 2026
- 10/10 fases implementadas
- Paridad 100% con Excel v2.5

## 👥 Autores

- Jose (JJ) - Desarrollo completo
- Claude Code - Asistencia en implementación

## 📄 Licencia

Uso interno - Crazy Clothes
