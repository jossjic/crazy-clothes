#!/usr/bin/env python3
"""
Unificar factores volumétricos a escala (L×W×H)/5000

Convierte todos los factores a kg volumétricos usando mediciones reales
cuando están disponibles, o estimaciones basadas en tipo de prenda.
"""

import json
import sys

# Cargar mediciones reales
with open('/home/jossjic/Descargas/factores_volumetricos_database.json') as f:
    mediciones = json.load(f)

# Crear lookup por descripción/tipo
mediciones_lookup = {}
for rec in mediciones['records']:
    key = (rec.get('brand', '').lower(), rec.get('item', '').lower())
    mediciones_lookup[key] = rec['volumetric_factor_kg']

# Tabla de factores por tipo de prenda (escala volumétrica, no relativa)
# Estos son estimaciones cuando no hay medición directa
FACTORES_POR_TIPO = {
    'Camiseta compresión': 0.50,      # ~25×30×3.5 cm
    'Jogger': 1.40,                    # ~37×32×6 cm (medido AOT)
    'Hoodie': 0.70,                    # ~34×29×3.5 cm (promedio)
    'Hoodie oversized': 1.25,          # más grande
    'Chamarra': 1.20,                  # similar a hoodie grande
    'Sport bra': 0.40,                 # ~20×25×2 cm
    'Short mujer': 0.70,               # ~25×28×2.5 cm
    'Legging': 1.00,                   # ~30×25×4 cm
    'Track Jacket': 0.80,              # más ligero que hoodie
    'Accesorio': 0.02,                 # llavero/carta
    'Electrónico': 0.59,               # Quest 3 medido
}

# Casos especiales con mediciones exactas
CASOS_ESPECIALES = {
    'onyx hoodie': 0.493,              # medido S
    'cbum washed hoodie': 1.254,       # medido M
    'cbum hockey jersey': 0.4615,      # medido M
    'aot joggers': 1.4208,             # medido M (no el relativo 1.8)
    'aot recruitment': 1.4208,         # mismo
    'onyx v5 shortsleeve': 0.5162,     # medido L
    'onyx v5 longsleeve': 0.522,       # medido S
    'onyx 5.0 seamless t-shirt': 0.5162,  # usar medida de V5 shortsleeve
    'onyx 5.0 seamless long sleeve': 0.522,  # usar medida de V5 longsleeve
    'campus hoodie': 0.784,            # medido M
    'meta quest 3': 0.5852,            # medido
}

# Correcciones de tipo (descripción → tipo correcto)
CORRECCIONES_TIPO = {
    'batman zipup': 'Hoodie',
    'batman sweats': 'Jogger',
    'quarter zipup': 'Hoodie',
    'tanjiro zipup': 'Hoodie',
    'rengoku zipup': 'Hoodie',
}

def inferir_factor(item):
    """
    Inferir factor volumétrico correcto para una pieza.

    Prioridad:
    1. Corregir tipo si es necesario
    2. Medición directa por nombre
    3. Medición por marca+item
    4. Caso especial conocido
    5. Tabla por tipo de prenda
    6. Default 1.0 (camiseta estándar)
    """
    descripcion = item.get('descripcion', '').lower()
    tipo = item.get('tipo_prenda_inferido', '')

    # 0. Corregir tipo si está mal inferido
    for desc_key, tipo_correcto in CORRECCIONES_TIPO.items():
        if desc_key in descripcion:
            item['tipo_prenda_inferido'] = tipo_correcto
            tipo = tipo_correcto
            break

    # 1. Casos especiales por nombre
    for nombre, factor in CASOS_ESPECIALES.items():
        if nombre in descripcion:
            return factor, 'medido' if 'aot' in nombre or 'onyx' in nombre or 'cbum' in nombre else 'estimado'

    # 2. Buscar en mediciones por marca+item
    # (simplificado, en producción usaríamos fuzzy matching)

    # 3. Tabla por tipo
    if tipo in FACTORES_POR_TIPO:
        return FACTORES_POR_TIPO[tipo], 'tabla_volumetrica'

    # 4. Default
    return 1.0, 'default'

def unificar_factores(input_file, output_file):
    """Cargar consolidados y actualizar factores a escala uniforme."""

    with open(input_file) as f:
        data = json.load(f)

    stats = {
        'total': len(data['items']),
        'actualizados': 0,
        'sin_cambio': 0,
        'por_tipo': {}
    }

    for item in data['items']:
        factor_original = item['factor_volumetrico']
        factor_nuevo, source = inferir_factor(item)

        if abs(factor_original - factor_nuevo) > 0.001:
            print(f"CAMBIO: {item['descripcion'][:40]:40} | "
                  f"{factor_original:6.4f} → {factor_nuevo:6.4f} | "
                  f"{source}")
            stats['actualizados'] += 1
        else:
            stats['sin_cambio'] += 1

        item['factor_volumetrico'] = round(factor_nuevo, 4)
        item['factor_source'] = source

        # Stats por tipo
        tipo = item.get('tipo_prenda_inferido', 'desconocido')
        stats['por_tipo'][tipo] = stats['por_tipo'].get(tipo, 0) + 1

    # Guardar resultado
    with open(output_file, 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"\n{'='*80}")
    print(f"RESUMEN:")
    print(f"  Total piezas:    {stats['total']}")
    print(f"  Actualizados:    {stats['actualizados']}")
    print(f"  Sin cambio:      {stats['sin_cambio']}")
    print(f"\nPor tipo de prenda:")
    for tipo, count in sorted(stats['por_tipo'].items(), key=lambda x: -x[1]):
        print(f"  {tipo:30} {count:3}")
    print(f"{'='*80}")

if __name__ == '__main__':
    input_file = '/tmp/consolidados_83_CON_FACTORES.json'
    output_file = '/tmp/consolidados_83_FACTORES_UNIFICADOS.json'

    print("Unificando factores volumétricos a escala (L×W×H)/5000...\n")
    unificar_factores(input_file, output_file)
    print(f"\n✅ Guardado en: {output_file}")
