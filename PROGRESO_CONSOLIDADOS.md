# Progreso: Importación y Procesamiento de Consolidados

**Branch:** `investigacion-duplicados`  
**Fecha:** 2026-07-30  
**Estado:** En progreso

---

## ✅ COMPLETADO

### 1. Schema de BD Modificado
- ✅ Columnas agregadas a `pieza`: `color`, `talla`, `pedido_proveedor_id`
- ✅ Columnas agregadas a `paquete`: `guide_raw`, `tracking_number`, dimensiones, pesos
- ✅ Columnas agregadas a `pedido_proveedor`: `shipping_protection_usd`, `adjustment_usd`
- ✅ Columnas agregadas a `cruce`: `exchange_rate_usd_mxn`
- ✅ Índices creados: `ix_pieza_matching`, `ix_paquete_tracking`, etc.

### 2. Factores Volumétricos Unificados
- ✅ 83 piezas con factores en escala (L×W×H)/5000
- ✅ 18 piezas con mediciones reales
- ✅ 62 piezas con factores de tabla por tipo
- ✅ Tipos corregidos (Batman zipup → Hoodie, Batman sweats → Jogger)

### 3. Costos por Paquete Extraídos
- ✅ 25 paquetes con costos desglosados
- ✅ 24/25 validados correctamente
- ✅ Detección de descuentos ya aplicados
- ✅ Validación de fórmula: items + protection + shipping - discount + taxes + adj = total

### 4. Importación Limpia Ejecutada
- ✅ **83 piezas: 41 NEGOCIO + 42 PERSONAL**
- ✅ 12 cruces
- ✅ 25 paquetes
- ✅ Sin duplicados
- ✅ Dump completo: `dump_limpio_83piezas_20260730_230708.sql`

### 5. Prorrateo Volumétrico Calculado
- ✅ Fórmula aplicada: Costo pieza = (Costo cruce) × (Factor pieza) / (Suma factores cruce)
- ✅ 12 cruces procesados
- ✅ 83 piezas prorrateadas
- ✅ Total: $15,642.38 USD
- ✅ Resultados: `prorrateo_completo.json`

---

## ⏳ EN PROGRESO

### 6. Matching de SKUs (41 piezas NEGOCIO)

**Estado:** Iniciado

**Piezas a procesar:**
- 7 Cockbear (Batman, Demon Slayer)
- 34 Gymshark (Onyx, CBUM, Vital, etc.)

**Estrategia:**
- Matching automático por: marca + tipo + talla + color + nombre
- Score mínimo: 15 puntos
- Match manual para casos ambiguos

**Archivo:** `/tmp/piezas_sin_sku.tsv` (41 piezas exportadas)

---

## 📋 PENDIENTE

### 7. Actualizar Tabla `cruce` con Costos MXN

Calcular y guardar:
- `cruce.costo_mxn` = Total USD × tipo de cambio
- `cruce.exchange_rate_usd_mxn` = Tipo de cambio del día

**Cruces con costos pendientes:**
- CONS_FUERA_380416815890 (2 piezas)
- CONS_FUERA_380419641012 (2 piezas)
- CONS_FUERA_382233588111 (2 piezas)

### 8. Generar Movimientos de Inventario

Una vez vinculadas las piezas NEGOCIO con SKUs:
- INSERT INTO `movimiento` (tipo='COMPRA')
- Uno por cada pieza NEGOCIO
- Actualizar stock disponible

### 9. Registrar Deudas de Piezas PERSONAL

Para las 42 piezas PERSONAL:
- INSERT INTO `deuda` (tipo='CRUCE_PERSONAL')
- Vincular con `pieza_id`
- Calcular monto con prorrateo

---

## 📊 Números Clave

| Concepto | Cantidad |
|----------|----------|
| Cruces | 12 |
| Paquetes | 25 |
| Piezas totales | 83 |
| - NEGOCIO | 41 |
| - PERSONAL | 42 |
| Total USD | $15,642.38 |
| Factores medidos | 18 |
| Factores de tabla | 62 |

---

## 📂 Archivos Importantes

```
investigacion-duplicados/
├── consolidados_83_FACTORES_UNIFICADOS.json   (83 piezas con factores)
├── costos_por_paquete.json                    (25 paquetes con costos)
├── prorrateo_completo.json                    (prorrateo calculado)
├── importacion_limpia_final.sql               (SQL ejecutado)
├── dump_limpio_83piezas_*.sql                 (backup BD)
├── HALLAZGO_DUPLICADOS.md                     (análisis de problema)
└── PROGRESO_CONSOLIDADOS.md                   (este archivo)
```

---

## 🔧 Próximos Pasos

1. Completar matching de SKUs (41 piezas)
2. Actualizar costos en cruces con tipo de cambio
3. Generar movimientos de inventario
4. Registrar deudas personales
5. Validar stock resultante

---

**Última actualización:** 2026-07-30 23:15
