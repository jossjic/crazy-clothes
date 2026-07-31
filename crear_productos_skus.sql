-- =====================================================================
-- CREAR PRODUCTOS Y SKUs PARA CONSOLIDADOS
-- 28 productos → 41 SKUs
-- =====================================================================

SET NAMES utf8mb4;
START TRANSACTION;

-- =====================================================================
-- MARCA: Cockbear (6 productos)
-- =====================================================================

-- Producto: 4255 Batman Midnight Tee
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (5, 1, '4255 Batman Midnight Tee');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0041: M / Joker Purple
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0041', @producto_id, 'M', 'Joker Purple', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 143;


-- Producto: Batman Compression Shirt
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (5, 1, 'Batman Compression Shirt');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0042: M / black
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0042', @producto_id, 'M', 'black', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 128;

-- SKU JNG-0043: S / black
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0043', @producto_id, 'S', 'black', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 129;


-- Producto: Batman Joggers
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (5, 5, 'Batman Joggers');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0044: M / Black Wash
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0044', @producto_id, 'M', 'Black Wash', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 146;


-- Producto: Batman Tee
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (5, 1, 'Batman Tee');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0045: M / white
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0045', @producto_id, 'M', 'white', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 144;


-- Producto: Batman Zip-Up Hoodie
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (5, 6, 'Batman Zip-Up Hoodie');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0046: M / Black Wash
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0046', @producto_id, 'M', 'Black Wash', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 145;


-- Producto: Demon Slayer Rengoku Tee
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (5, 1, 'Demon Slayer Rengoku Tee');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0047: M / Rengoku Design
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0047', @producto_id, 'M', 'Rengoku Design', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 133;


-- =====================================================================
-- MARCA: Gymshark (13 productos)
-- =====================================================================

-- Producto: Gymshark Adapt Animal Seamless Sports Bra
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (2, 10, 'Gymshark Adapt Animal Seamless Sports Bra');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0048: M / cherry purple/reset pink
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0048', @producto_id, 'M', 'cherry purple/reset pink', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 178;


-- Producto: Gymshark Everyday Seamless Shorts 2.0
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (2, 8, 'Gymshark Everyday Seamless Shorts 2.0');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0049: M / GS black
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0049', @producto_id, 'M', 'GS black', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 180;


-- Producto: Gymshark Flex High Waisted Leggings
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (2, 11, 'Gymshark Flex High Waisted Leggings');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0050: S / black
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0050', @producto_id, 'S', 'black', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 179;


-- Producto: Gymshark Minimal Sports Bra
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (2, 10, 'Gymshark Minimal Sports Bra');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0051: S / black
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0051', @producto_id, 'S', 'black', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 177;


-- Producto: Gymshark Vital 1/4 Zip
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (2, 1, 'Gymshark Vital 1/4 Zip');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0052: L / black/silhouette grey
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0052', @producto_id, 'L', 'black/silhouette grey', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 160;


-- Producto: Gymshark Vital Seamless 2.0 Leggings
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (2, 11, 'Gymshark Vital Seamless 2.0 Leggings');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0053: S / cobalt purple marl
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0053', @producto_id, 'S', 'cobalt purple marl', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 176;


-- Producto: Gymshark Vital Sports Bra
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (2, 10, 'Gymshark Vital Sports Bra');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0054: S / cobalt purple marl
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0054', @producto_id, 'S', 'cobalt purple marl', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 181;


-- Producto: Gymshark x CBUM Hockey Jersey
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (2, 1, 'Gymshark x CBUM Hockey Jersey');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0055: M / black
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0055', @producto_id, 'M', 'black', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 152;


-- Producto: Gymshark x CBUM Straight Leg Jogger
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (2, 5, 'Gymshark x CBUM Straight Leg Jogger');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0056: M / black
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0056', @producto_id, 'M', 'black', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 153;


-- Producto: Gymshark x CBUM Washed Hoodie
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (2, 6, 'Gymshark x CBUM Washed Hoodie');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0057: M / stone grey marl
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0057', @producto_id, 'M', 'stone grey marl', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 151;


-- Producto: Onyx 5.0 Seamless Long Sleeve T-Shirt
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (2, 1, 'Onyx 5.0 Seamless Long Sleeve T-Shirt');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0058: XS / OG blue
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0058', @producto_id, 'XS', 'OG blue', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 195;

-- SKU JNG-0059: S / purple
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0059', @producto_id, 'S', 'purple', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 194;


-- Producto: Onyx 5.0 Seamless T-Shirt
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (2, 1, 'Onyx 5.0 Seamless T-Shirt');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0060: L / Black/Onyx Grey
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0060', @producto_id, 'L', 'Black/Onyx Grey', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 192;

-- SKU JNG-0061: M / Black/Onyx Grey
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0061', @producto_id, 'M', 'Black/Onyx Grey', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 191;

-- SKU JNG-0062: S / Black/Onyx Grey
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0062', @producto_id, 'S', 'Black/Onyx Grey', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 190;

-- SKU JNG-0063: L / Black/Carmine Red
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0063', @producto_id, 'L', 'Black/Carmine Red', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 189;

-- SKU JNG-0064: M / Black/Carmine Red
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0064', @producto_id, 'M', 'Black/Carmine Red', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 188;

-- SKU JNG-0065: S / Black/Light Grey
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0065', @producto_id, 'S', 'Black/Light Grey', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 184;

-- SKU JNG-0066: M / Black/Light Grey
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0066', @producto_id, 'M', 'Black/Light Grey', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 185;

-- SKU JNG-0067: L / Black/Light Grey
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0067', @producto_id, 'L', 'Black/Light Grey', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 186;

-- SKU JNG-0068: S / Black/Carmine Red
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0068', @producto_id, 'S', 'Black/Carmine Red', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 187;


-- Producto: Onyx Hoodie
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (2, 6, 'Onyx Hoodie');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0069: M / purple
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0069', @producto_id, 'M', 'purple', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 132;

-- SKU JNG-0070: S / light grey
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0070', @producto_id, 'S', 'light grey', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 131;

-- SKU JNG-0071: M / red
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0071', @producto_id, 'M', 'red', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 130;


-- =====================================================================
-- MARCA: YoungLA (9 productos)
-- =====================================================================

-- Producto: Flagship Track Pants
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (1, 5, 'Flagship Track Pants');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0072: M / black
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0072', @producto_id, 'M', 'black', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 120;

-- SKU JNG-0073: M / burgundy
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0073', @producto_id, 'M', 'burgundy', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 125;


-- Producto: Foundation Cropped Tee
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (1, 1, 'Foundation Cropped Tee');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0074: M / black
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0074', @producto_id, 'M', 'black', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 119;


-- Producto: Immortal Killer Joggers
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (1, 5, 'Immortal Killer Joggers');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0075: M / black
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0075', @producto_id, 'M', 'black', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 121;


-- Producto: Supervillain Tee
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (1, 1, 'Supervillain Tee');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0076: M / black
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0076', @producto_id, 'M', 'black', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 124;


-- Producto: W149 curve hourglass biker shorts 6.5"
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (1, 8, 'W149 curve hourglass biker shorts 6.5"');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0077: S / grey
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0077', @producto_id, 'S', 'grey', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 141;


-- Producto: W2230 camo cargo joggers
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (1, 5, 'W2230 camo cargo joggers');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0078: S / pink barbed wire camo
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0078', @producto_id, 'S', 'pink barbed wire camo', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 139;


-- Producto: W233 curve seamless leggings
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (1, 11, 'W233 curve seamless leggings');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0079: M / green
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0079', @producto_id, 'M', 'green', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 142;


-- Producto: W472 legacy seamless tank
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (1, 9, 'W472 legacy seamless tank');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0080: XS / dusty blue
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0080', @producto_id, 'XS', 'dusty blue', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 140;


-- Producto: Warrior Tee
INSERT INTO producto (marca_id, tipo_prenda_id, nombre)
VALUES (1, 1, 'Warrior Tee');
SET @producto_id = LAST_INSERT_ID();

-- SKU JNG-0081: M / red
INSERT INTO sku (codigo, producto_id, talla, color, estado)
VALUES ('JNG-0081', @producto_id, 'M', 'red', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 127;


COMMIT;

-- =====================================================================
-- RESUMEN
-- =====================================================================
-- Productos creados: 28
-- SKUs creados: 41 (JNG-0041 a JNG-0081)
-- Piezas vinculadas: 41
-- =====================================================================