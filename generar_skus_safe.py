#!/usr/bin/env python3
"""Generar SQL seguro que reutiliza productos existentes."""
import json
import subprocess

def query_mysql(sql):
    cmd = ['docker', 'exec', 'cc_mysql_test', 'mysql', '-u', 'root', '-ptest', 'cc', '-e', sql, '--batch', '--skip-column-names']
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    return result.stdout.strip()

# Obtener productos existentes
productos_existentes_raw = query_mysql("SELECT id, marca_id, nombre FROM producto")
productos_existentes = {}
for line in productos_existentes_raw.split('\n'):
    if line:
        parts = line.split('\t')
        if len(parts) >= 3:
            key = (parts[1], parts[2].lower())  # (marca_id, nombre_lower)
            productos_existentes[key] = parts[0]  # id

print(f"Productos existentes: {len(productos_existentes)}")

# Cargar productos agrupados
with open('/tmp/productos_agrupados.json') as f:
    productos = json.load(f)

MARCAS = {'YoungLA': 1, 'Gymshark': 2, 'Otro': 4, 'Cockbear': 5}
TIPOS = {'Camiseta compresión': 1, 'Jogger': 5, 'Hoodie': 6, 'Short mujer': 8, 'Tank top mujer': 9, 'Sport bra': 10, 'Legging': 11}

ultimo_sku = 40

sql = []
sql.append("-- Crear SKUs (reutilizando productos existentes)")
sql.append("SET NAMES utf8mb4;")
sql.append("START TRANSACTION;\n")

productos_creados = 0
skus_creados = 0

for prod in productos:
    marca = prod['marca']
    if marca == 'Otro' and any(n in prod['nombre'] for n in ['Foundation', 'Flagship', 'Immortal', 'Supervillain', 'Warrior', 'W']):
        marca = 'YoungLA'
    
    marca_id = MARCAS.get(marca, 4)
    tipo_id = TIPOS.get(prod['tipo'], 1)
    nombre = prod['nombre']
    
    # Buscar si producto existe
    key_exact = (str(marca_id), nombre.lower())
    key_cbum = (str(marca_id), nombre.replace('Gymshark x ', '').lower())
    key_vital = (str(marca_id), nombre.replace('Gymshark ', '').lower())
    
    producto_id = None
    if key_exact in productos_existentes:
        producto_id = productos_existentes[key_exact]
        sql.append(f"-- Producto YA EXISTE: {nombre} (ID {producto_id})")
    elif key_cbum in productos_existentes:
        producto_id = productos_existentes[key_cbum]
        sql.append(f"-- Producto YA EXISTE: {nombre} (ID {producto_id})")
    elif key_vital in productos_existentes:
        producto_id = productos_existentes[key_vital]
        sql.append(f"-- Producto YA EXISTE: {nombre} (ID {producto_id})")
    else:
        # Crear producto nuevo
        nombre_esc = nombre.replace("'", "''")
        sql.append(f"-- CREAR PRODUCTO: {nombre}")
        sql.append(f"INSERT INTO producto (marca_id, tipo_prenda_id, nombre) VALUES ({marca_id}, {tipo_id}, '{nombre_esc}');")
        sql.append(f"SET @prod_id_{productos_creados} = LAST_INSERT_ID();")
        producto_id = f"@prod_id_{productos_creados}"
        productos_creados += 1
    
    # Crear SKUs
    for var in prod['variantes']:
        ultimo_sku += 1
        codigo = f"JNG-{ultimo_sku:04d}"
        talla = var['talla'].replace("'", "''")
        color = var['color'].replace("'", "''")
        
        sql.append(f"INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('{codigo}', {producto_id}, '{talla}', '{color}', 'ACTIVO');")
        sql.append(f"UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = {var['pieza_id']};")
        skus_creados += 1
    
    sql.append("")

sql.append("COMMIT;")
sql.append(f"\n-- Productos creados: {productos_creados}")
sql.append(f"-- SKUs creados: {skus_creados}")

with open('/tmp/crear_skus_safe.sql', 'w', encoding='utf-8') as f:
    f.write('\n'.join(sql))

print(f"✅ SQL seguro: /tmp/crear_skus_safe.sql")
print(f"   Productos nuevos: {productos_creados}")
print(f"   Productos reutilizados: {len(productos) - productos_creados}")
print(f"   SKUs totales: {skus_creados}")
