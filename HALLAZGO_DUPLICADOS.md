# Hallazgo: Duplicados en la Importación de Consolidados

**Fecha:** 2026-07-30  
**Branch:** `investigacion-duplicados`  
**Estado:** Rollback al commit `383d6e5`

---

## 📊 Problema Detectado

### Números esperados vs reales

| Momento | NEGOCIO | PERSONAL | TOTAL |
|---------|---------|----------|-------|
| BD antes | 26 | 23 | 49 |
| Consolidados nuevos | **41** | **42** | **83** |
| **Esperado (suma)** | **67** | **65** | **132** |
| **BD real post-import** | **83** | **69** | **152** |
| **Diferencia** | **+16** | **+4** | **+20** |

### 🔴 Hay 20 piezas duplicadas

## 🔍 Causa del Problema

El SQL usaba `NOT EXISTS` comparando descripción exacta:

```sql
WHERE NOT EXISTS (
  SELECT 1 FROM pieza pi
  WHERE pi.descripcion = 'Onyx 5.0 Seamless T-Shirt'
    AND pi.destino = 'NEGOCIO'
    AND pi.color = 'Light Grey'
    AND pi.talla = 'M'
)
```

**Pero la BD tenía:**
- Descripciones genéricas: `"onyx hoodie"`
- Consolidados tienen descripciones específicas: `"Onyx 5.0 Seamless T-Shirt"`

**Resultado:** No detectó duplicados porque los strings no coinciden.

## 📋 Ejemplos de Duplicados

### Paquete `1Z08X89A0320535275` (19 piezas, debería tener ~10)

**Duplicados detectados:**
- "Onyx 5.0 Seamless T-Shirt" (genérico, dato viejo)
- "Onyx 5.0 Seamless T-Shirt Large Light Grey" (específico, consolidado nuevo)
- "Onyx 5.0 Seamless T-Shirt Medium Light Grey" (específico, consolidado nuevo)
- ...etc

### Paquete `420785219434640109629005071033` (13 piezas, debería tener 6)

**Duplicados:**
- "flagship track pants" (genérico)
- "flagship track pants black medium 50usd" (específico)
- "flagship track pants burgundy medium 50usd" (específico)

## ✅ Datos Correctos de los Consolidados

### Documento fuente: `Consolidados_normalizado_parser_actualizado.txt`

**Total piezas: 83**
- **41 NEGOCIO**
- **42 PERSONAL**

**12 cruces:**
1. CONS9928546710 - 11 piezas (8 NEG + 3 PERS)
2. CONS9943741515 - 8 piezas (4 NEG + 4 PERS)
3. CONS9943741691 - 1 pieza (0 NEG + 1 PERS)
4. CONS9943741870 - 11 piezas (8 NEG + 3 PERS)
5. CONS9943742286 - 7 piezas (3 NEG + 4 PERS)
6. CONS9962926323 - 12 piezas (1 NEG + 11 PERS)
7-12. Paquetes fuera de sistema - 33 piezas (17 NEG + 16 PERS)

**25 paquetes/guías únicas**

## 🔧 Soluciones Propuestas

### Opción 1: Limpiar y reimportar (Recomendada)

```sql
-- Restaurar BD a estado pre-consolidados
DELETE FROM pieza WHERE paquete_id IN (
  SELECT id FROM paquete WHERE cruce_id IN (
    SELECT id FROM cruce WHERE folio LIKE 'CONS%' AND fecha >= '2026-03-01'
  )
);

DELETE FROM paquete WHERE cruce_id IN (
  SELECT id FROM cruce WHERE folio LIKE 'CONS%' AND fecha >= '2026-03-01'
);

DELETE FROM cruce WHERE folio LIKE 'CONS%' AND fecha >= '2026-03-01';

-- Luego ejecutar importacion_consolidados_safe.sql
```

**Pros:**
- Estado limpio
- 41 NEGOCIO + 42 PERSONAL exactos
- Sin duplicados

**Contras:**
- Pierde los 49 datos previos si son valiosos

### Opción 2: Deduplicar inteligente

Crear query que identifique duplicados por:
- Mismo paquete
- Descripción similar (fuzzy match)
- Mismo color/talla
- Mismo destino

**Pros:**
- Mantiene datos previos que no sean duplicados
- Más conservador

**Contras:**
- Más complejo
- Puede no detectar todos los casos

### Opción 3: Usar matching más inteligente en el SQL

Modificar `NOT EXISTS` para usar:
```sql
WHERE NOT EXISTS (
  SELECT 1 FROM pieza pi
  JOIN paquete pa ON pi.paquete_id = pa.id
  WHERE pa.guia = ?
    AND (pi.descripcion LIKE CONCAT('%', ?, '%') OR ? LIKE CONCAT('%', pi.descripcion, '%'))
    AND (pi.color = ? OR pi.color IS NULL)
    AND (pi.talla = ? OR pi.talla IS NULL)
    AND pi.destino = ?
)
```

**Pros:**
- Detecta duplicados con descripciones variadas

**Contras:**
- Más lento
- Puede generar falsos positivos

## 📝 Estado Actual del Branch

**Branch:** `investigacion-duplicados`  
**Commit:** `383d6e5` (antes de importación)

**Archivos disponibles:**
- ✅ `consolidados_83_FACTORES_UNIFICADOS.json` - Datos limpios (83 piezas)
- ✅ `costos_por_paquete.json` - Costos desglosados (25 paquetes)
- ✅ `reporte_factores.md` - Documentación de factores
- ✅ `costos_por_paquete.md` - Documentación de costos
- ❌ `importacion_consolidados_safe.sql` - No ejecutado aún

**Base de datos:**
- Estado: Pre-consolidados (49 piezas)
- Dump: `dump_post_consolidados_20260730_224600.sql`

## 🎯 Recomendación

**Limpiar completamente y reimportar desde cero:**

1. Restaurar BD al dump `dump_pre_consolidados_20260730_224357.sql`
2. Ejecutar `paso1_alter_schema_v2_fixed.sql` (schema)
3. Ejecutar `importacion_consolidados_safe.sql` (datos limpios)
4. Verificar: 41 NEGOCIO + 42 PERSONAL = 83 piezas

**Justificación:**
- Los datos previos (49 piezas) parecen ser un subset incompleto de los consolidados
- Los consolidados (83 piezas) son la fuente de verdad completa y validada
- Mejor partir de un estado limpio que intentar deduplicar

## 📂 Archivos de Referencia

```
app-cc/
├── consolidados_83_FACTORES_UNIFICADOS.json   (83 piezas: 41 NEG + 42 PERS)
├── costos_por_paquete.json                    (25 paquetes con costos)
├── reporte_factores.md                        (factores volumétricos)
├── dump_pre_consolidados_20260730_224357.sql  (backup pre-modificaciones)
├── dump_post_consolidados_20260730_224600.sql (backup post-schema)
└── paso1_alter_schema_v2_fixed.sql            (modificaciones de schema)
```

## ✅ Siguiente Paso

Decidir estrategia y ejecutar:
- Limpiar y reimportar desde cero, O
- Deduplicar y corregir, O
- Mantener como está y documentar las 83 NEGOCIO como dato oficial

---

**Autor:** Claude Sonnet 4.5  
**Sessión:** 2026-07-30 (Consolidados)
