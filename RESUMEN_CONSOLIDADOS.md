# Importación Consolidados - Resumen Final

**Fecha:** 2026-07-31  
**Branch:** `investigacion-duplicados`  
**Estado:** ✅ COMPLETADO

---

## 📊 Datos Importados

### Piezas
- **83 piezas totales**
  - 41 NEGOCIO (28 con costo)
  - 42 PERSONAL (36 con costo)
- **64 piezas con costo** ($62,131.91 MXN)
- **19 piezas sin costo** (cruces sin datos)

### SKUs
- **41 SKUs nuevos** creados (JNG-0041 a JNG-0081)
- **28 SKUs con costo** actualizado en `sku_costo`

### Cruces
- **12 cruces** importados
- **6 cruces principales** con costo de importación: $8,200 MXN
  - CONS9928546710: $1,100 MXN (4.21 kg)
  - CONS9943741515: $1,400 MXN (7.26 kg)
  - CONS9943741691: $1,200 MXN (5.44 kg)
  - CONS9943741870: $1,400 MXN (7.13 kg)
  - CONS9943742286: $1,100 MXN (4.37 kg)
  - CONS9962926323: $2,000 MXN (13.02 kg)

---

## 💰 Costos

### Resumen Global
| Concepto | USD | MXN (TC 18) |
|----------|-----|-------------|
| Mercancía (paquetes) | $3,771.53 | $67,887.58 |
| Importación (cruces) | - | $8,200.00 |
| **TOTAL** | **~$4,227** | **$76,087.58** |

### Por Destino
- **NEGOCIO:** $23,597.15 MXN (28 piezas con costo)
- **PERSONAL:** $38,534.76 MXN (36 piezas con costo)

---

## 📦 Movimientos de Inventario

**28 movimientos** tipo `COMPRA` creados:
- Fecha: según fecha del cruce
- Cantidad: 1 por pieza
- Vinculados a pieza_id

**Stock actualizado** para 28 SKUs (JNG-0041+)

---

## 💳 Deudas PERSONAL

**36 deudas** creadas (tipo `MERCANCIA_PERSONAL`):

| Socio | Piezas | Deuda Total |
|-------|--------|-------------|
| JJ | 14 | $21,672.16 |
| Luise | 8 | $10,657.04 |
| Agusto | 2 | $2,153.82 |
| **TOTAL** | **36** | **$34,482.02** |

---

## 🗃️ Base de Datos

### Commits
1. `335d2d8` - Importación inicial (83 piezas + SKUs + costos cruces)
2. `34b04a1` - Movimientos + deudas

### Dumps
- `dump_limpio_83piezas_20260730_230708.sql` - Post-import limpio
- `dump_costos_actualizados_20260730_235622.sql` - Con costos de cruces
- `dump_consolidados_completo_20260730_235920.sql` - Con costos de piezas
- `dump_final_consolidados_20260731_000528.sql` - **FINAL** (movimientos + deudas)

### Archivos SQL Aplicados
1. `paso1_alter_schema_v2_fixed.sql` - Schema (costo_unitario_mxn)
2. `importacion_limpia_final.sql` - 83 piezas (cruces + paquetes + piezas)
3. `crear_skus_safe.sql` - 41 SKUs (JNG-0041 a JNG-0081)
4. `actualizar_costos_cruces_real.sql` - Costos de importación ($8,200 MXN)
5. `actualizar_costos_final.sql` - Costos por pieza (64 piezas)
6. `sku_costo_y_movimientos.sql` - 28 SKUs + 28 movimientos
7. `deudas_personal.sql` - 36 deudas

---

## ⚠️ Pendientes

### 19 Piezas sin Costo
Están en BD pero sin costo porque:
- Pertenecen a cruces sin datos de costo en JSON original
- Son piezas viejas (antes de consolidados)

**Cruces afectados:**
- CONS9928546710: 3 piezas
- CONS9943741515: 2 piezas
- CONS9943742286: 1 pieza
- CONS_FUERA_382233588111: 1 pieza
- SBAAAAQLJHVRGP222_FEDEX382233588111: 12 piezas

**Solución sugerida:** Obtener costos de esos paquetes o dejarlos en NULL.

### 13 Piezas NEGOCIO sin SKU
- No están en el rango JNG-0041+
- No tienen movimiento de inventario
- Son de cruces sin costo o sin SKU asignado

---

## ✅ Verificación

```sql
-- Piezas con costo
SELECT destino, COUNT(*), FORMAT(SUM(costo_unitario_mxn), 2) 
FROM pieza WHERE costo_unitario_mxn IS NOT NULL GROUP BY destino;
-- NEGOCIO: 28 → $23,597.15
-- PERSONAL: 36 → $38,534.76

-- Movimientos
SELECT COUNT(*) FROM movimiento WHERE fecha >= '2026-03-01' AND tipo = 'COMPRA';
-- 59 (28 nuevos + 31 previos)

-- Deudas
SELECT s.nombre, COUNT(*), FORMAT(SUM(d.monto_mxn), 2)
FROM deuda d JOIN socio s ON d.deudor_id = s.id
WHERE d.fecha >= '2026-03-01' AND tipo = 'MERCANCIA_PERSONAL'
GROUP BY s.nombre;
-- JJ: 14 → $21,672.16
-- Luise: 8 → $10,657.04
-- Agusto: 2 → $2,153.82

-- SKU costos
SELECT COUNT(*) FROM sku_costo WHERE sku_id IN (
  SELECT id FROM sku WHERE codigo >= 'JNG-0041'
);
-- 28
```

---

## 📚 Documentación

- `HALLAZGO_DUPLICADOS.md` - Análisis de duplicados detectados
- `PROGRESO_CONSOLIDADOS.md` - Log de progreso (obsoleto)
- `consolidados_83_FACTORES_UNIFICADOS.json` - Datos fuente (83 piezas)
- `costos_por_paquete.json` - Costos de mercancía por paquete
- `costos_83_piezas.json` - Cálculo de costo por pieza (mercancía + importación)

---

**✅ Importación completada exitosamente**
