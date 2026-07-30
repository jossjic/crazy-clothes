# Inventario Reconciliado - Julio 30, 2026

## Estado Actual

✅ **La base de datos está completamente corregida y reconciliada con el documento consolidado de Drive.**

## Cambios Realizados

### 1. Guías Perdidas Registradas (7 total)

Guías que llegaron físicamente pero nunca fueron asignadas a un cruce por el proveedor Telomando:

- **FedEx 380419641012** - Personal (Godzilla hoodie + pants) $170 USD
- **FedEx 380416815890** - Personal JJ (Cockbear items) $136 USD
- **UPS 1Z08X89AYW00349426** - Gymshark 6 items $153.20 USD
- **FedEx 382233588111** - Personal Luis + JJ (Civil Racing jackets) $255 USD
- **UPS 1Z08X89A0320535275** - ONYX 9 shortsleeves $364.50 USD
- **UPS 1Z08YY74YW30322345** - ONYX 2 longsleeves PERSONAL $100.80 USD
- **UPS 1Z08X89AYW01891981** - Gymshark + kettlebell (completado con piezas faltantes)

### 2. ONYX Completo (14 piezas totales)

#### Hoodies (3 piezas)
- Red M - Vendida (JNG-0021)
- Purple M - Vendida (JNG-0020)
- Grey S - Disponible (JNG-0022)

#### Shortsleeves (9 piezas)
**NEGOCIO (8):**
- 4 vendidas: Medium Red, Small OG Blue, Small Red, Small Light Grey
- 4 disponibles: Large Red (JNG-0011), Medium Light Grey (JNG-0013), Large Light Grey (JNG-0014), Large OG Blue (JNG-0016)

**PERSONAL (1):**
- OG Blue Medium - JJ

#### Longsleeves (2 piezas)
- Purple S - PERSONAL
- OG Blue XS - PERSONAL

### 3. Correcciones de Asignación Personal

Piezas que estaban marcadas como NEGOCIO pero eran personales:

- **OMEGA BREATH PANTS** → PERSONAL Luis
- **FIH L** → PERSONAL Luis
- **FIH M** → PERSONAL JJ
- **Foundation cropped tees (2)** → PERSONAL Luis y Agusto
- **Campus 7" Shorts Light Grey XS** → PERSONAL Luis
- **Campus Mesh Shorts Black/Red S** → PERSONAL Luis
- **Gymshark Charge T-Shirt XS** → PERSONAL Luis
- **Carlos Belcast Track Jacket Grey XS** → PERSONAL Luis
- **Gymshark Power T-Shirt Black/Red M** → PERSONAL JJ
- **Gymshark Charge T-Shirt M** → PERSONAL Agusto

### 4. Pérdidas Operativas Documentadas

Piezas regaladas en collabs con influencers (cuentan como gasto sin inventario):

- **W2230 Camo Cargo Joggers Pink S** - Collab con influencer
- **W233 Curve Seamless Leggings Green M** - Collab con morra

### 5. Movimientos de Entrada Creados

Se crearon movimientos de COMPRA para corregir stock negativo:

- 4 ONYX shortsleeves que se habían vendido sin registrar entrada
- 1 ONYX hoodie Grey S que faltaba
- 4 ONYX shortsleeves adicionales en inventario

## Resultado Final

### Stock
- **39 SKUs totales**
- **0 SKUs con stock negativo** ✅
- **17 SKUs con stock disponible**
- **22 SKUs sin stock** (vendidos o aún no catalogados)

### Piezas NEGOCIO sin SKU (5 totales)
**Para catalogar (3):**
1. Carlos Belcast Track Jacket Grey XS - CONS9962926323
2. Gymshark Power T-Shirt Black/Conditioning Red M - CONS9962926323
3. Gymshark Charge T-Shirt Black/Wash M - CONS9962926323

**Pérdidas operativas (2):**
4. W2230 Camo Cargo Joggers Pink S - Collab
5. W233 Curve Seamless Leggings Green M - Collab

### Cruces Registrados
- CONS9928546710 (Marzo 25, 2026)
- CONS9943741515 (Abril 08, 2026)
- CONS9943741691 (Abril 16, 2026)
- CONS9943741870 (Abril 27, 2026)
- CONS9943742286 (Mayo 21, 2026)
- CONS9962926323 (Julio 08, 2026)

### Guías NO Registradas (problemas del proveedor)
Estas guías tienen problemas documentados del proveedor pero las piezas físicas ya están registradas o aún no han llegado:

- `4207852170149334620826000001283829` - Personal Luis, aún no llega
- `399720300746` - FedEx issue, producto ya registrado en otra guía
- `399969598390` - FedEx patrón de falla, producto ya registrado
- `380449171210` - FedEx issue, se cuenta con otro envío

## Base de Datos

**Dump actualizado:** `database-dump.sql` (commit b3d3706)

### Para Aplicar en AWS

#### Opción 1: Subir a S3 (para próximos deployments)
```bash
aws s3 cp database-dump.sql s3://crazy-clothes-bucket/database-dump.sql
```

#### Opción 2: Aplicar directamente en instancia DB
```bash
# Conectar vía SSM
aws ssm start-session --target <db-instance-id>

# Dentro de la instancia
mysql -uroot -p cc < /path/to/database-dump.sql
```

## Notas Importantes

1. **Stock limpio**: No hay negativos, todo reconciliado con documento consolidado de Drive
2. **ONYX completo**: Los 3 pedidos ONYX (hoodies, shortsleeves, longsleeves) están completamente registrados
3. **Piezas personales**: Todas correctamente asignadas a Luis, JJ, o Agusto
4. **Pérdidas operativas**: Documentadas como gastos en collabs, afectan márgenes correctamente
5. **Pendiente catalogar**: Solo 3 piezas reales que necesitan crear producto/SKU cuando sea necesario

---

**Última actualización:** 2026-07-30  
**Responsable:** Claude Code + Jose  
**Estado:** ✅ COMPLETO Y RECONCILIADO
