import json
from datetime import datetime

MARCAS = {'youngla': 1, 'gymshark': 2, 'otro': 4, 'cockbear': 5, 'civil regime': 6, 'onyx': 7, 'breath divinity': 16}
TIPOS = {'camiseta compresión': 1, 'camiseta deportiva': 1, 'camisa manga larga': 4, 'jogger': 5, 'hoodie': 6, 'chamarra': 7, 'short mujer': 8, 'tank top mujer': 9, 'sport bra': 10, 'legging': 11, 'accesorio': 12, 'electronico': 12, 'pants': 13, 'track jacket': 14}
SOCIOS = {'jj': 4, 'agusto': 5, 'luise': 6, 'luis': 6}

def inferir_marca(desc):
    d = desc.lower()
    if 'gymshark' in d or 'onyx' in d or 'cbum' in d: return 2
    if 'youngla' in d: return 1
    if 'civil' in d: return 6
    if 'breath' in d: return 16
    if any(x in d for x in ['batman', 'demon', 'mothra', 'ghidorah', 'godzilla', 'monsters']): return 5
    return 4

def detectar_paqueteria(guia):
    clean = guia.replace('CASI', '')
    if clean.startswith('1Z'): return 1
    if clean.startswith('420') or clean.startswith('9'): return 2
    if 'FEDEX' in guia.upper(): return 3
    return None

def esc(s):
    if s is None: return 'NULL'
    return "'" + str(s).replace("'", "''") + "'"

with open('/tmp/consolidados_83_FACTORES_UNIFICADOS.json') as f:
    piezas_data = json.load(f)['items']

with open('/tmp/costos_por_paquete.json') as f:
    cruces_data = json.load(f)

cruces, paquetes, piezas = {}, {}, []
cruce_lookup = {c['folio']: c for c in cruces_data}

for item in piezas_data:
    cruce_folio, guia_raw = item['cruce'], item['guide_raw']
    if cruce_folio not in cruces:
        cruce_info = cruce_lookup.get(cruce_folio, {})
        fecha = cruce_info.get('fecha', '2026-01-01')
        if fecha == 'NO_DISPONIBLE': fecha = '2026-01-01'
        cruces[cruce_folio] = {'fecha': fecha}
    if guia_raw not in paquetes:
        paquetes[guia_raw] = {'cruce': cruce_folio, 'tracking': item.get('tracking_number', guia_raw.replace('CASI', ''))}
    piezas.append(item)

sql = []
sql.append("-- Importación LIMPIA consolidados")
sql.append(f"-- {len(cruces)} cruces, {len(paquetes)} paquetes, {len(piezas)} piezas")
sql.append("SET NAMES utf8mb4;")
sql.append("START TRANSACTION;\n")

# DELETE de cruces existentes (cascade)
cruces_delete = ['CONS9928546710', 'CONS9943741515', 'CONS9943741691', 'CONS9943741870', 'CONS9943742286', 'CONS9962926323']
sql.append("-- Limpiar cruces existentes (cascade a paquetes/piezas)")
sql.append(f"DELETE FROM cruce WHERE folio IN ({','.join([esc(f) for f in cruces_delete])});\n")

# CRUCES
for folio in sorted(cruces.keys()):
    info = cruces[folio]
    sql.append(f"INSERT INTO cruce (folio, fecha, costo_mxn, notas) VALUES ({esc(folio)}, '{info['fecha']}', NULL, 'Consolidados 2026-07-30');")

# PAQUETES
for guia in sorted(paquetes.keys()):
    info = paquetes[guia]
    paq_id = detectar_paqueteria(guia)
    tracking = info['tracking']
    sql.append(f"INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)")
    sql.append(f"VALUES ({esc(tracking)}, {esc(guia)}, {esc(tracking)}, {paq_id or 'NULL'}, (SELECT id FROM cruce WHERE folio = {esc(info['cruce'])}), 'RECIBIDO');")

# PIEZAS
for idx, item in enumerate(piezas, 1):
    marca_id = inferir_marca(item['descripcion'])
    tipo_id = TIPOS.get(item.get('tipo_prenda_inferido', '').lower(), 12)
    destino = 'PERSONAL' if item['personal'] else 'NEGOCIO'
    socio_id = SOCIOS.get(item.get('owner', '').lower()) if destino == 'PERSONAL' else None
    factor = item.get('factor_volumetrico', 1.0)
    precio = item.get('precio_unitario', 0)
    color = item.get('color', '')
    talla = item.get('size', '')
    qty = item.get('qty', 1)
    tracking = item.get('tracking_number', item['guide_raw'].replace('CASI', ''))
    
    color_val = esc(color) if color else 'NULL'
    talla_val = esc(talla) if talla else 'NULL'
    socio_val = socio_id if socio_id else 'NULL'
    
    sql.append(f"INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)")
    sql.append(f"VALUES ((SELECT id FROM paquete WHERE guia = {esc(tracking)} LIMIT 1), {esc(item['descripcion'])}, {color_val}, {talla_val}, {qty}, {marca_id}, {tipo_id}, {factor:.4f}, '{destino}', {socio_val}, {precio:.2f});")

sql.append("\nCOMMIT;")
sql.append(f"-- Total: {len(cruces)} cruces, {len(paquetes)} paquetes, {len(piezas)} piezas (41 NEG + 42 PERS)")

with open('/tmp/importacion_limpia_final.sql', 'w', encoding='utf-8') as f:
    f.write('\n'.join(sql))

print(f"✅ SQL limpio: /tmp/importacion_limpia_final.sql")
print(f"   {len(cruces)} cruces, {len(paquetes)} paquetes, {len(piezas)} piezas")
