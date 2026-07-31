-- Crear SKUs (reutilizando productos existentes)
SET NAMES utf8mb4;
START TRANSACTION;

-- CREAR PRODUCTO: 4255 Batman Midnight Tee
INSERT INTO producto (marca_id, tipo_prenda_id, nombre) VALUES (5, 1, '4255 Batman Midnight Tee');
SET @prod_id_0 = LAST_INSERT_ID();
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0041', @prod_id_0, 'M', 'Joker Purple', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 143;

-- CREAR PRODUCTO: Batman Compression Shirt
INSERT INTO producto (marca_id, tipo_prenda_id, nombre) VALUES (5, 1, 'Batman Compression Shirt');
SET @prod_id_1 = LAST_INSERT_ID();
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0042', @prod_id_1, 'M', 'black', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 128;
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0043', @prod_id_1, 'S', 'black', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 129;

-- CREAR PRODUCTO: Batman Joggers
INSERT INTO producto (marca_id, tipo_prenda_id, nombre) VALUES (5, 5, 'Batman Joggers');
SET @prod_id_2 = LAST_INSERT_ID();
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0044', @prod_id_2, 'M', 'Black Wash', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 146;

-- CREAR PRODUCTO: Batman Tee
INSERT INTO producto (marca_id, tipo_prenda_id, nombre) VALUES (5, 1, 'Batman Tee');
SET @prod_id_3 = LAST_INSERT_ID();
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0045', @prod_id_3, 'M', 'white', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 144;

-- CREAR PRODUCTO: Batman Zip-Up Hoodie
INSERT INTO producto (marca_id, tipo_prenda_id, nombre) VALUES (5, 6, 'Batman Zip-Up Hoodie');
SET @prod_id_4 = LAST_INSERT_ID();
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0046', @prod_id_4, 'M', 'Black Wash', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 145;

-- CREAR PRODUCTO: Demon Slayer Rengoku Tee
INSERT INTO producto (marca_id, tipo_prenda_id, nombre) VALUES (5, 1, 'Demon Slayer Rengoku Tee');
SET @prod_id_5 = LAST_INSERT_ID();
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0047', @prod_id_5, 'M', 'Rengoku Design', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 133;

-- CREAR PRODUCTO: Gymshark Adapt Animal Seamless Sports Bra
INSERT INTO producto (marca_id, tipo_prenda_id, nombre) VALUES (2, 10, 'Gymshark Adapt Animal Seamless Sports Bra');
SET @prod_id_6 = LAST_INSERT_ID();
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0048', @prod_id_6, 'M', 'cherry purple/reset pink', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 178;

-- CREAR PRODUCTO: Gymshark Everyday Seamless Shorts 2.0
INSERT INTO producto (marca_id, tipo_prenda_id, nombre) VALUES (2, 8, 'Gymshark Everyday Seamless Shorts 2.0');
SET @prod_id_7 = LAST_INSERT_ID();
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0049', @prod_id_7, 'M', 'GS black', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 180;

-- Producto YA EXISTE: Gymshark Flex High Waisted Leggings (ID 25)
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0050', 25, 'S', 'black', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 179;

-- Producto YA EXISTE: Gymshark Minimal Sports Bra (ID 24)
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0051', 24, 'S', 'black', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 177;

-- Producto YA EXISTE: Gymshark Vital 1/4 Zip (ID 31)
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0052', 31, 'L', 'black/silhouette grey', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 160;

-- Producto YA EXISTE: Gymshark Vital Seamless 2.0 Leggings (ID 22)
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0053', 22, 'S', 'cobalt purple marl', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 176;

-- Producto YA EXISTE: Gymshark Vital Sports Bra (ID 23)
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0054', 23, 'S', 'cobalt purple marl', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 181;

-- Producto YA EXISTE: Gymshark x CBUM Hockey Jersey (ID 29)
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0055', 29, 'M', 'black', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 152;

-- Producto YA EXISTE: Gymshark x CBUM Straight Leg Jogger (ID 28)
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0056', 28, 'M', 'black', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 153;

-- Producto YA EXISTE: Gymshark x CBUM Washed Hoodie (ID 30)
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0057', 30, 'M', 'stone grey marl', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 151;

-- CREAR PRODUCTO: Onyx 5.0 Seamless Long Sleeve T-Shirt
INSERT INTO producto (marca_id, tipo_prenda_id, nombre) VALUES (2, 1, 'Onyx 5.0 Seamless Long Sleeve T-Shirt');
SET @prod_id_8 = LAST_INSERT_ID();
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0058', @prod_id_8, 'XS', 'OG blue', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 195;
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0059', @prod_id_8, 'S', 'purple', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 194;

-- CREAR PRODUCTO: Onyx 5.0 Seamless T-Shirt
INSERT INTO producto (marca_id, tipo_prenda_id, nombre) VALUES (2, 1, 'Onyx 5.0 Seamless T-Shirt');
SET @prod_id_9 = LAST_INSERT_ID();
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0060', @prod_id_9, 'L', 'Black/Onyx Grey', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 192;
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0061', @prod_id_9, 'M', 'Black/Onyx Grey', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 191;
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0062', @prod_id_9, 'S', 'Black/Onyx Grey', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 190;
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0063', @prod_id_9, 'L', 'Black/Carmine Red', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 189;
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0064', @prod_id_9, 'M', 'Black/Carmine Red', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 188;
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0065', @prod_id_9, 'S', 'Black/Light Grey', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 184;
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0066', @prod_id_9, 'M', 'Black/Light Grey', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 185;
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0067', @prod_id_9, 'L', 'Black/Light Grey', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 186;
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0068', @prod_id_9, 'S', 'Black/Carmine Red', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 187;

-- Producto YA EXISTE: Onyx Hoodie (ID 15)
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0069', 15, 'M', 'purple', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 132;
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0070', 15, 'S', 'light grey', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 131;
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0071', 15, 'M', 'red', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 130;

-- Producto YA EXISTE: Flagship Track Pants (ID 9)
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0072', 9, 'M', 'black', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 120;
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0073', 9, 'M', 'burgundy', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 125;

-- CREAR PRODUCTO: Foundation Cropped Tee
INSERT INTO producto (marca_id, tipo_prenda_id, nombre) VALUES (1, 1, 'Foundation Cropped Tee');
SET @prod_id_10 = LAST_INSERT_ID();
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0074', @prod_id_10, 'M', 'black', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 119;

-- Producto YA EXISTE: Immortal Killer Joggers (ID 11)
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0075', 11, 'M', 'black', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 121;

-- CREAR PRODUCTO: Supervillain Tee
INSERT INTO producto (marca_id, tipo_prenda_id, nombre) VALUES (1, 1, 'Supervillain Tee');
SET @prod_id_11 = LAST_INSERT_ID();
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0076', @prod_id_11, 'M', 'black', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 124;

-- CREAR PRODUCTO: W149 curve hourglass biker shorts 6.5"
INSERT INTO producto (marca_id, tipo_prenda_id, nombre) VALUES (1, 8, 'W149 curve hourglass biker shorts 6.5"');
SET @prod_id_12 = LAST_INSERT_ID();
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0077', @prod_id_12, 'S', 'grey', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 141;

-- CREAR PRODUCTO: W2230 camo cargo joggers
INSERT INTO producto (marca_id, tipo_prenda_id, nombre) VALUES (1, 5, 'W2230 camo cargo joggers');
SET @prod_id_13 = LAST_INSERT_ID();
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0078', @prod_id_13, 'S', 'pink barbed wire camo', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 139;

-- CREAR PRODUCTO: W233 curve seamless leggings
INSERT INTO producto (marca_id, tipo_prenda_id, nombre) VALUES (1, 11, 'W233 curve seamless leggings');
SET @prod_id_14 = LAST_INSERT_ID();
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0079', @prod_id_14, 'M', 'green', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 142;

-- CREAR PRODUCTO: W472 legacy seamless tank
INSERT INTO producto (marca_id, tipo_prenda_id, nombre) VALUES (1, 9, 'W472 legacy seamless tank');
SET @prod_id_15 = LAST_INSERT_ID();
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0080', @prod_id_15, 'XS', 'dusty blue', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 140;

-- CREAR PRODUCTO: Warrior Tee
INSERT INTO producto (marca_id, tipo_prenda_id, nombre) VALUES (1, 1, 'Warrior Tee');
SET @prod_id_16 = LAST_INSERT_ID();
INSERT INTO sku (codigo, producto_id, talla, color, estado) VALUES ('JNG-0081', @prod_id_16, 'M', 'red', 'ACTIVO');
UPDATE pieza SET sku_id = LAST_INSERT_ID() WHERE id = 127;

COMMIT;

-- Productos creados: 17
-- SKUs creados: 41