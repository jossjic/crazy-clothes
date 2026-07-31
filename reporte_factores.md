# Reporte de Unificación de Factores Volumétricos

**Fecha:** 2026-07-30  
**Escala:** Kilogramos volumétricos `(L×W×H)/5000`

## Resumen

- **Total piezas:** 83
- **Actualizadas:** 69
- **Sin cambio:** 14

## Cambios Principales

### Factores medidos (prioridad máxima)

| Descripción | Original | Unificado | Fuente |
|-------------|----------|-----------|--------|
| Onyx Hoodie (S/M) | 2.5000 | 0.4930 | Medido |
| CBUM Washed Hoodie | 2.5000 | 1.2540 | Medido |
| CBUM Hockey Jersey | 0.4620 | 0.4615 | Medido |
| AOT Joggers | 1.8000 | 1.4208 | Medido |
| Onyx V5 Short Sleeve | 1.0000 | 0.5162 | Medido (L) |
| Onyx V5 Long Sleeve | 1.0000 | 0.5220 | Medido (S) |

### Tipos corregidos

| Descripción | Tipo original | Tipo correcto | Factor |
|-------------|---------------|---------------|--------|
| Batman Zip-Up | Camiseta compresión | Hoodie | 0.7000 |
| Batman Sweats (×2) | Camiseta compresión | Jogger | 1.4000 |
| Quarter/Tanjiro/Rengoku Zipup | Hoodie | Hoodie | 0.7000 |

### Tabla de factores por tipo

| Tipo de prenda | Factor (kg vol) | Piezas |
|----------------|-----------------|--------|
| Camiseta compresión | 0.5000 | 31 |
| Jogger | 1.4000 | 19 |
| Hoodie | 0.7000 | 12 |
| Short mujer | 0.7000 | 4 |
| Accesorio | 0.0200 | 4 |
| Legging | 1.0000 | 3 |
| Chamarra | 1.2000 | 3 |
| Sport bra | 0.4000 | 3 |
| Tank top mujer | 1.0000 | 1 |
| Electronico | 1.0000 | 1 |

## Problemas Detectados

### Quest 3
- **Original:** 0.5852 (medido)
- **Actualizado:** 1.0000 (default)
- **Causa:** No coincide con casos especiales
- **Acción:** Requiere revisión manual

### Legacy Seamless Tank
- **Original:** 0.6000
- **Actualizado:** 1.0000 (default)
- **Causa:** Tipo "Tank top mujer" no en tabla
- **Acción:** Agregar factor específico para tank tops

## Validación

```bash
# Verificar factores únicos
jq -r '.items[] | .factor_volumetrico' consolidados_83_FACTORES_UNIFICADOS.json | sort -u

# Contar por factor_source
jq -r '.items[] | .factor_source' consolidados_83_FACTORES_UNIFICADOS.json | sort | uniq -c
```

## Siguiente Paso

Importar estos factores unificados a la tabla `factor_volumetrico` en la BD.
