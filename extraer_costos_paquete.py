#!/usr/bin/env python3
"""
Extraer costos por paquete del documento normalizado.

Estructura esperada:
CONS...
  CASI... (o 1Z... u otra guía)
    • item: ... unit: X.XX usd
    • shipping protection: X.XX usd
    • shipping: X.XX usd
    • discount: X.XX usd
    • taxes: X.XX usd
    • adjustment: X.XX usd (opcional)
    • total: X.XX usd
"""

import re
import json
from decimal import Decimal

def extraer_costos(doc_path):
    """Parsear documento normalizado y extraer costos por paquete."""

    with open(doc_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    cruces = []
    cruce_actual = None
    paquete_actual = None

    for i, line in enumerate(lines):
        line = line.strip()

        # Inicio de cruce
        if line.startswith('CONS'):
            if cruce_actual and paquete_actual:
                # Guardar paquete anterior
                cruce_actual['paquetes'].append(paquete_actual)
                paquete_actual = None

            if cruce_actual:
                # Guardar cruce anterior
                cruces.append(cruce_actual)

            cruce_actual = {
                'folio': line,
                'paquetes': []
            }
            continue

        # Fecha del cruce
        if line.startswith('date:') and cruce_actual:
            fecha = line.split(':', 1)[1].strip()
            cruce_actual['fecha'] = fecha
            continue

        # Inicio de paquete (guía)
        # Debe empezar con patrón de guía común o ser una línea sin bullets
        if (re.match(r'^(CASI|1Z|420|SBAAA)', line) or
            (re.match(r'^[A-Z0-9_]+$', line) and not line.startswith('CONS'))):

            if paquete_actual:
                # Guardar paquete anterior
                cruce_actual['paquetes'].append(paquete_actual)

            paquete_actual = {
                'guide_raw': line,
                'tracking_number': line.replace('CASI', ''),
                'items': [],
                'subtotal_items_usd': Decimal('0'),
                'shipping_protection_usd': None,
                'shipping_usd': None,
                'discount_usd': None,
                'discount_already_applied': False,
                'taxes_usd': None,
                'adjustment_usd': None,
                'total_usd': None
            }
            continue

        # Líneas de items o costos
        if line.startswith('•') and paquete_actual:
            # Item
            if 'item:' in line and 'unit:' in line:
                match = re.search(r'unit:\s*([\d.]+)\s*usd', line, re.IGNORECASE)
                if match:
                    unit_price = Decimal(match.group(1))

                    # Buscar qty
                    qty_match = re.search(r'qty:\s*(\d+)', line)
                    qty = int(qty_match.group(1)) if qty_match else 1

                    paquete_actual['items'].append({
                        'line': line,
                        'unit_price': float(unit_price),
                        'qty': qty,
                        'subtotal': float(unit_price * qty)
                    })
                    paquete_actual['subtotal_items_usd'] += unit_price * qty

            # Shipping protection
            elif 'shipping protection:' in line:
                match = re.search(r'([\d.]+)\s*usd', line, re.IGNORECASE)
                if match:
                    paquete_actual['shipping_protection_usd'] = float(match.group(1))

            # Shipping
            elif line.startswith('• shipping:') or line.startswith('• shipping usd:'):
                match = re.search(r'([\d.]+)\s*usd', line, re.IGNORECASE)
                if match:
                    paquete_actual['shipping_usd'] = float(match.group(1))

            # Discount
            elif 'discount:' in line:
                match = re.search(r'([\d.]+)\s*usd', line, re.IGNORECASE)
                if match:
                    paquete_actual['discount_usd'] = float(match.group(1))

                # Check if already applied
                if 'already applied' in line.lower():
                    paquete_actual['discount_already_applied'] = True

            # Taxes
            elif 'taxes:' in line or 'tax:' in line:
                match = re.search(r'([\d.]+)\s*usd', line, re.IGNORECASE)
                if match:
                    paquete_actual['taxes_usd'] = float(match.group(1))

            # Adjustment
            elif 'adjustment:' in line:
                match = re.search(r'([\d.]+)\s*usd', line, re.IGNORECASE)
                if match:
                    paquete_actual['adjustment_usd'] = float(match.group(1))

            # Total
            elif 'total:' in line and 'reconciliation' not in line:
                match = re.search(r'([\d.]+)\s*usd', line, re.IGNORECASE)
                if match:
                    paquete_actual['total_usd'] = float(match.group(1))

        # Detectar descuento ya aplicado en notas
        if paquete_actual and ('discount is not repeated' in line.lower() or
                               'source displayed discount' in line.lower() or
                               'discount already applied' in line.lower()):
            paquete_actual['discount_already_applied'] = True

            # Extraer el monto del descuento informacional
            match = re.search(r'discount[:\s]+([\d.]+)\s*usd', line, re.IGNORECASE)
            if match and paquete_actual['discount_usd'] in [None, 0, 0.0]:
                paquete_actual['discount_usd'] = float(match.group(1))

    # Guardar último paquete y cruce
    if paquete_actual:
        cruce_actual['paquetes'].append(paquete_actual)
    if cruce_actual:
        cruces.append(cruce_actual)

    # Convertir Decimal a float para JSON
    for cruce in cruces:
        for paquete in cruce['paquetes']:
            paquete['subtotal_items_usd'] = float(paquete['subtotal_items_usd'])

    return cruces

def validar_costos(cruces):
    """Validar que los costos calculados coincidan con el total."""

    print("Validando costos por paquete...\n")

    errores = []

    for cruce in cruces:
        for paquete in cruce['paquetes']:
            subtotal = paquete['subtotal_items_usd']
            protection = paquete['shipping_protection_usd'] or 0
            shipping = paquete['shipping_usd'] or 0
            discount = paquete['discount_usd'] or 0
            taxes = paquete['taxes_usd'] or 0
            adjustment = paquete['adjustment_usd'] or 0
            total = paquete['total_usd']

            # Formula: items + protection + shipping - discount + taxes + adjustment = total
            # Si discount_already_applied, NO restar el descuento (ya está en unit prices)
            if paquete['discount_already_applied']:
                calculado = subtotal + protection + shipping + taxes + adjustment
            else:
                calculado = subtotal + protection + shipping - discount + taxes + adjustment

            diferencia = abs(calculado - total)

            if diferencia > 0.01:  # Tolerancia de 1 centavo
                error = {
                    'cruce': cruce['folio'],
                    'guia': paquete['guide_raw'][:30],
                    'calculado': round(calculado, 2),
                    'total': total,
                    'diferencia': round(diferencia, 2)
                }
                errores.append(error)
                print(f"⚠️  {error['guia']:30} | Calc: ${error['calculado']:8.2f} | "
                      f"Total: ${error['total']:8.2f} | Diff: ${error['diferencia']:6.2f}")
            else:
                print(f"✅ {paquete['guide_raw'][:30]:30} | ${total:8.2f}")

    print(f"\n{'='*80}")
    print(f"Total paquetes: {sum(len(c['paquetes']) for c in cruces)}")
    print(f"Con errores:    {len(errores)}")
    print(f"Validados:      {sum(len(c['paquetes']) for c in cruces) - len(errores)}")
    print(f"{'='*80}\n")

    return errores

def generar_reporte(cruces, output_path):
    """Generar reporte de costos por paquete."""

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write("# Costos por Paquete - Consolidados\n\n")
        f.write(f"**Total cruces:** {len(cruces)}  \n")
        f.write(f"**Total paquetes:** {sum(len(c['paquetes']) for c in cruces)}  \n\n")

        for cruce in cruces:
            f.write(f"## {cruce['folio']}\n")
            f.write(f"**Fecha:** {cruce.get('fecha', 'N/A')}  \n")
            f.write(f"**Paquetes:** {len(cruce['paquetes'])}  \n\n")

            for paquete in cruce['paquetes']:
                f.write(f"### {paquete['guide_raw'][:40]}\n\n")
                f.write("| Concepto | Monto USD |\n")
                f.write("|----------|----------:|\n")
                f.write(f"| Subtotal items | ${paquete['subtotal_items_usd']:.2f} |\n")
                f.write(f"| Shipping protection | ${paquete['shipping_protection_usd'] or 0:.2f} |\n")
                f.write(f"| Shipping | ${paquete['shipping_usd'] or 0:.2f} |\n")
                f.write(f"| Discount | -${paquete['discount_usd'] or 0:.2f} |\n")
                f.write(f"| Taxes | ${paquete['taxes_usd'] or 0:.2f} |\n")

                if paquete['adjustment_usd']:
                    f.write(f"| Adjustment | ${paquete['adjustment_usd']:.2f} |\n")

                f.write(f"| **TOTAL** | **${paquete['total_usd']:.2f}** |\n\n")

if __name__ == '__main__':
    doc_path = '/home/jossjic/Descargas/Consolidados_normalizado_parser_actualizado.txt'
    output_json = '/tmp/costos_por_paquete.json'
    output_md = '/tmp/costos_por_paquete.md'

    print("Extrayendo costos por paquete...\n")
    cruces = extraer_costos(doc_path)

    # Validar
    errores = validar_costos(cruces)

    # Guardar JSON
    with open(output_json, 'w', encoding='utf-8') as f:
        json.dump(cruces, f, indent=2, ensure_ascii=False)

    print(f"✅ JSON guardado en: {output_json}")

    # Generar reporte
    generar_reporte(cruces, output_md)
    print(f"✅ Reporte guardado en: {output_md}")

    if errores:
        print(f"\n⚠️  {len(errores)} paquetes con diferencias en validación")
