#!/usr/bin/env python3
"""Agrupar piezas en productos base para crear SKUs."""

# Leer piezas
piezas = []
with open('/tmp/piezas_sin_sku.tsv', 'r', encoding='latin-1') as f:
    for line in f.readlines()[1:]:
        parts = line.strip().split('\t')
        if len(parts) >= 6:
            piezas.append({
                'id': parts[0],
                'descripcion': parts[1],
                'color': parts[2],
                'talla': parts[3],
                'marca': parts[4],
                'tipo': parts[5]
            })

# Función para normalizar nombre de producto
def get_producto_base(desc, marca):
    desc_lower = desc.lower()
    
    # Onyx 5.0 Seamless
    if 'onyx 5.0' in desc_lower or 'onyx seamless' in desc_lower:
        if 'long sleeve' in desc_lower:
            return 'Onyx 5.0 Seamless Long Sleeve T-Shirt'
        else:
            return 'Onyx 5.0 Seamless T-Shirt'
    
    # Onyx Hoodie
    if 'onyx hoodie' in desc_lower:
        return 'Onyx Hoodie'
    
    # CBUM
    if 'cbum' in desc_lower:
        if 'hockey' in desc_lower:
            return 'Gymshark x CBUM Hockey Jersey'
        elif 'washed' in desc_lower:
            return 'Gymshark x CBUM Washed Hoodie'
        elif 'straight' in desc_lower or 'jogger' in desc_lower:
            return 'Gymshark x CBUM Straight Leg Jogger'
    
    # Otras Gymshark específicas
    gymshark_products = {
        'vital seamless 2.0 leggings': 'Gymshark Vital Seamless 2.0 Leggings',
        'vital 1/4 zip': 'Gymshark Vital 1/4 Zip',
        'vital sports bra': 'Gymshark Vital Sports Bra',
        'flex high waisted leggings': 'Gymshark Flex High Waisted Leggings',
        'minimal sports bra': 'Gymshark Minimal Sports Bra',
        'adapt animal': 'Gymshark Adapt Animal Seamless Sports Bra',
        'everyday seamless shorts': 'Gymshark Everyday Seamless Shorts 2.0'
    }
    
    for key, name in gymshark_products.items():
        if key in desc_lower:
            return name
    
    # YoungLA W-series
    if marca == 'YoungLA' and desc.startswith('W'):
        code = desc.split()[0]  # W2230, W472, etc
        return desc  # Usar descripción completa
    
    # YoungLA otras
    youngla_products = {
        'foundation cropped tee': 'Foundation Cropped Tee',
        'flagship track pants': 'Flagship Track Pants',
        'immortal killer joggers': 'Immortal Killer Joggers',
        'supervillain': 'Supervillain Tee',
        'warrior': 'Warrior Tee'
    }
    
    for key, name in youngla_products.items():
        if key in desc_lower:
            return name
    
    # Cockbear/Batman
    if 'batman' in desc_lower:
        if 'zipup' in desc_lower or 'zip' in desc_lower:
            return 'Batman Zip-Up Hoodie'
        elif 'sweats' in desc_lower:
            return 'Batman Joggers'
        elif '4255' in desc or 'midnight' in desc_lower:
            return '4255 Batman Midnight Tee'
        elif 'tee' in desc_lower:
            return 'Batman Tee'
        else:
            return 'Batman Compression Shirt'
    
    # Demon Slayer
    if 'demon slayer' in desc_lower or 'rengoku' in desc_lower:
        return 'Demon Slayer Rengoku Tee'
    
    # Default: usar descripción completa
    return desc

# Agrupar piezas por producto base
productos = {}
for pieza in piezas:
    producto_base = get_producto_base(pieza['descripcion'], pieza['marca'])
    
    key = (pieza['marca'], producto_base, pieza['tipo'])
    
    if key not in productos:
        productos[key] = {
            'marca': pieza['marca'],
            'nombre': producto_base,
            'tipo': pieza['tipo'],
            'variantes': []
        }
    
    productos[key]['variantes'].append({
        'pieza_id': pieza['id'],
        'talla': pieza['talla'],
        'color': pieza['color']
    })

# Reporte
print("="*100)
print("PRODUCTOS BASE IDENTIFICADOS")
print("="*100)
print(f"\nTotal: {len(productos)} productos → 41 SKUs\n")

for i, (key, prod) in enumerate(sorted(productos.items()), 1):
    print(f"{i:2}. [{prod['marca']:10}] {prod['nombre']:50} ({len(prod['variantes'])} SKUs)")
    for var in prod['variantes'][:3]:
        print(f"    - Pieza {var['pieza_id']:4}: {var['talla']:3} / {var['color'][:25]}")
    if len(prod['variantes']) > 3:
        print(f"    ... y {len(prod['variantes'])-3} más")

# Guardar para generar SQL
import json
with open('/tmp/productos_agrupados.json', 'w') as f:
    # Convertir keys de tuple a string
    data = []
    for key, prod in productos.items():
        data.append(prod)
    json.dump(data, f, indent=2)

print(f"\n✅ Guardado: /tmp/productos_agrupados.json")
