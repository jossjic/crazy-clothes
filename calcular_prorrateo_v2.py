#!/usr/bin/env python3
import json
from decimal import Decimal

# Cargar piezas
with open('/tmp/consolidados_83_FACTORES_UNIFICADOS.json') as f:
    piezas = json.load(f)['items']

# Cargar costos por paquete
with open('/tmp/costos_por_paquete.json') as f:
    cruces_data = json.load(f)

# Crear lookup de costos por guía
costos_por_guia = {}
for cruce in cruces_data:
    for paquete in cruce['paquetes']:
        guia = paquete['guide_raw']
        costos_por_guia[guia] = {
            'total_usd': paquete.get('total_usd', 0),
            'cruce_original': cruce['folio']
        }

# Agrupar piezas por cruce (usando el folio del consolidado)
cruces = {}
for pieza in piezas:
    cruce_folio = pieza['cruce']
    guia = pieza['guide_raw']
    
    if cruce_folio not in cruces:
        # Buscar costo del paquete
        costo_info = costos_por_guia.get(guia, {})
        cruces[cruce_folio] = {
            'fecha': '2026-01-01',  # Default
            'total_usd': 0.0,
            'paquetes': set(),
            'piezas': []
        }
    
    # Acumular costo si es del mismo cruce
    if guia in costos_por_guia:
        cruces[cruce_folio]['total_usd'] += costos_por_guia[guia]['total_usd']
        cruces[cruce_folio]['paquetes'].add(guia)
    
    cruces[cruce_folio]['piezas'].append({
        'descripcion': pieza['descripcion'],
        'destino': 'PERSONAL' if pieza['personal'] else 'NEGOCIO',
        'factor': pieza.get('factor_volumetrico', 1.0),
        'precio_usd': pieza.get('precio_unitario', 0),
        'guia': guia
    })

# Calcular prorrateo
for folio, cruce in cruces.items():
    cruce['paquetes'] = len(cruce['paquetes'])
    suma_factores = sum(p['factor'] for p in cruce['piezas'])
    cruce['suma_factores'] = suma_factores
    
    if suma_factores > 0 and cruce['total_usd'] > 0:
        for pieza in cruce['piezas']:
            pieza['peso_relativo'] = pieza['factor'] / suma_factores
            pieza['costo_prorrateado_usd'] = cruce['total_usd'] * pieza['peso_relativo']

# Reporte
print("=" * 100)
print("PRORRATEO VOLUMÉTRICO - COMPLETO (83 PIEZAS)")
print("=" * 100)

total_piezas = 0
for folio in sorted(cruces.keys()):
    cruce = cruces[folio]
    total_piezas += len(cruce['piezas'])
    
    print(f"\n{folio}")
    print(f"  Total USD: ${cruce['total_usd']:,.2f}")
    print(f"  Paquetes: {cruce['paquetes']}")
    print(f"  Piezas: {len(cruce['piezas'])} (suma factores: {cruce['suma_factores']:.4f})")
    
    if cruce['total_usd'] > 0 and len(cruce['piezas']) <= 15:
        print(f"\n  {'Descripción':40} {'Dest':8} {'Factor':>8} {'%':>6} {'Prorrateado':>12}")
        print(f"  {'-'*40} {'-'*8} {'-'*8} {'-'*6} {'-'*12}")
        
        for pieza in cruce['piezas']:
            desc = pieza['descripcion'][:38]
            dest = pieza['destino'][:6]
            factor = pieza['factor']
            pct = pieza.get('peso_relativo', 0) * 100
            costo = pieza.get('costo_prorrateado_usd', 0)
            print(f"  {desc:40} {dest:8} {factor:8.4f} {pct:5.1f}% ${costo:11.2f}")
    elif cruce['total_usd'] > 0:
        print(f"  (listado omitido - {len(cruce['piezas'])} piezas)")

print("\n" + "=" * 100)
print("RESUMEN")
print("=" * 100)
print(f"Total cruces: {len(cruces)}")
print(f"Total piezas: {total_piezas}")
print(f"Total USD: ${sum(c['total_usd'] for c in cruces.values()):,.2f}")

# Guardar
with open('/tmp/prorrateo_completo.json', 'w') as f:
    json.dump(cruces, f, indent=2, default=str)

print(f"\n✅ Guardado: /tmp/prorrateo_completo.json")
