# Hallazgo: Las 41 Piezas NEGOCIO Necesitan SKUs Nuevos

**Fecha:** 2026-07-30  
**Branch:** `investigacion-duplicados`

---

## 🔍 Análisis Realizado

Se intentó hacer matching automático de las 41 piezas NEGOCIO con los 40 SKUs existentes en el catálogo.

**Resultado:** 0 matches

## ✅ Conclusión

Las 41 piezas de los consolidados son **productos completamente nuevos** que no existen en el catálogo actual.

**Evidencia:**
- 40 SKUs existentes en BD
- 41 piezas NEGOCIO sin SKU
- 0 coincidencias por marca + tipo + talla + color

**Ejemplos de piezas nuevas:**
- Onyx 5.0 Seamless T-Shirt (10 variantes de color/talla)
- CBUM Hockey Jersey / Washed Hoodie / Straight Leg Jogger
- Batman series (Cockbear)
- W-series YoungLA (W2230, W472, W149, W233)

## 📋 Acción Requerida

**Crear 41 SKUs nuevos:**

### Proceso:
1. Identificar productos únicos (agrupar por marca + nombre base)
2. Crear filas en tabla `producto` (si no existen)
3. Generar códigos SKU secuenciales (JNG-0041 hasta JNG-0081)
4. INSERT en tabla `sku` con talla + color específicos
5. UPDATE `pieza` para vincular con nuevo `sku_id`

### Estimación:
- ~15-20 productos nuevos
- 41 SKUs (variantes de color/talla)

### Complejidad:
- **Alta** - Requiere análisis de nombres para agrupar correctamente
- Ejemplo: "Onyx 5.0 Seamless T-Shirt" en 10 colores/tallas = 1 producto, 10 SKUs

## 📊 Breakdown por Marca

### Gymshark (26 piezas)
- Onyx 5.0 Seamless T-Shirt: 10 variantes
- Onyx 5.0 Long Sleeve: 2 variantes
- CBUM series: 3 piezas
- Vital/Campus/Flex/Adapt: 11 piezas

### YoungLA (8 piezas)
- W-series (women): 4 piezas
- Foundation/Flagship/Immortal/Supervillain/Warrior: 4 piezas

### Cockbear (7 piezas)
- Batman series: 4 piezas
- Demon Slayer: 2 piezas
- 4255 Batman: 1 pieza

## 🎯 Siguiente Paso

**Opción A:** Crear SKUs manualmente (recomendado para precisión)
- Revisar cada pieza
- Asignar códigos cuidadosamente
- Validar antes de INSERT

**Opción B:** Script semi-automático
- Generar estructura de productos/SKUs
- Revisar antes de ejecutar
- Ejecutar en transacción

**Opción C:** Dejar sin SKU temporalmente
- Las piezas NEGOCIO quedan sin `sku_id`
- No entran a inventario vendible
- Se pueden catalogar después

## 📂 Archivos de Análisis

- `piezas_sin_sku.tsv` - 41 piezas exportadas
- `skus_disponibles.tsv` - 40 SKUs actuales
- `analisis_matching.py` - Script de análisis

---

**Recomendación:** Crear los 41 SKUs es necesario para completar el flujo. Sin SKUs, las piezas NEGOCIO no pueden:
- Entrar al inventario vendible
- Generar movimientos de COMPRA
- Estar disponibles para venta

Sin embargo, el prorrateo y las deudas personales SÍ se pueden completar sin SKUs.
