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

## 📦 Instalación

### 1. Clonar el repositorio

```bash
git clone <repo-url>
cd app-cc
```

### 2. Instalar dependencias

```bash
npm install
```

### 3. Base de datos MySQL

Levantar MySQL (Docker):

```bash
docker run --name cc_mysql \
  -e MYSQL_ROOT_PASSWORD=test \
  -e MYSQL_DATABASE=cc \
  -p 33306:3306 \
  -d mysql:8.4
```

Importar el dump:

```bash
docker exec -i cc_mysql mysql -uroot -ptest cc < database-dump.sql
```

### 4. Configurar variables de entorno

Crear `.env.local`:

```env
DB_HOST=127.0.0.1
DB_PORT=33306
DB_USER=root
DB_PASSWORD=test
DB_NAME=cc
```

### 5. Ejecutar en desarrollo

```bash
npm run dev
```

Abrir: http://localhost:3000

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
