-- Importación LIMPIA consolidados
-- 12 cruces, 25 paquetes, 83 piezas
SET NAMES utf8mb4;
START TRANSACTION;

-- Limpiar cruces existentes (cascade a paquetes/piezas)
DELETE FROM cruce WHERE folio IN ('CONS9928546710','CONS9943741515','CONS9943741691','CONS9943741870','CONS9943742286','CONS9962926323');

INSERT INTO cruce (folio, fecha, costo_mxn, notas) VALUES ('CONS9928546710', '2026-03-25', NULL, 'Consolidados 2026-07-30');
INSERT INTO cruce (folio, fecha, costo_mxn, notas) VALUES ('CONS9943741515', '2026-04-08', NULL, 'Consolidados 2026-07-30');
INSERT INTO cruce (folio, fecha, costo_mxn, notas) VALUES ('CONS9943741691', '2026-04-16', NULL, 'Consolidados 2026-07-30');
INSERT INTO cruce (folio, fecha, costo_mxn, notas) VALUES ('CONS9943741870', '2026-04-27', NULL, 'Consolidados 2026-07-30');
INSERT INTO cruce (folio, fecha, costo_mxn, notas) VALUES ('CONS9943742286', '2026-05-21', NULL, 'Consolidados 2026-07-30');
INSERT INTO cruce (folio, fecha, costo_mxn, notas) VALUES ('CONS9962926323', '2026-07-08', NULL, 'Consolidados 2026-07-30');
INSERT INTO cruce (folio, fecha, costo_mxn, notas) VALUES ('CONS_FUERA_1Z08X89AYW00349426', '2026-01-01', NULL, 'Consolidados 2026-07-30');
INSERT INTO cruce (folio, fecha, costo_mxn, notas) VALUES ('CONS_FUERA_380416815890', '2026-01-01', NULL, 'Consolidados 2026-07-30');
INSERT INTO cruce (folio, fecha, costo_mxn, notas) VALUES ('CONS_FUERA_380419641012', '2026-01-01', NULL, 'Consolidados 2026-07-30');
INSERT INTO cruce (folio, fecha, costo_mxn, notas) VALUES ('CONS_FUERA_382233588111', '2026-01-01', NULL, 'Consolidados 2026-07-30');
INSERT INTO cruce (folio, fecha, costo_mxn, notas) VALUES ('CONS_SIN_ASIGNAR_202607', '2026-01-01', NULL, 'Consolidados 2026-07-30');
INSERT INTO cruce (folio, fecha, costo_mxn, notas) VALUES ('SBAAAAQLJHVRGP222_FEDEX382233588111', '2026-01-01', NULL, 'Consolidados 2026-07-30');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('1Z08X89A0320535275', '1Z08X89A0320535275', '1Z08X89A0320535275', 1, (SELECT id FROM cruce WHERE folio = 'SBAAAAQLJHVRGP222_FEDEX382233588111'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('1Z08X89AYW00349426', '1Z08X89AYW00349426', '1Z08X89AYW00349426', 1, (SELECT id FROM cruce WHERE folio = 'CONS_FUERA_1Z08X89AYW00349426'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('1Z08X89AYW01891981', '1Z08X89AYW01891981', '1Z08X89AYW01891981', 1, (SELECT id FROM cruce WHERE folio = 'SBAAAAQLJHVRGP222_FEDEX382233588111'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('1Z08YY74YW30322345', '1Z08YY74YW30322345', '1Z08YY74YW30322345', 1, (SELECT id FROM cruce WHERE folio = 'SBAAAAQLJHVRGP222_FEDEX382233588111'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('380416815890', '380416815890', '380416815890', NULL, (SELECT id FROM cruce WHERE folio = 'CONS_FUERA_380416815890'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('380419641012', '380419641012', '380419641012', NULL, (SELECT id FROM cruce WHERE folio = 'CONS_FUERA_380419641012'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('382233588111', '382233588111', '382233588111', NULL, (SELECT id FROM cruce WHERE folio = 'CONS_FUERA_382233588111'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('4207852170149334620826000001283829', '4207852170149334620826000001283829', '4207852170149334620826000001283829', 2, (SELECT id FROM cruce WHERE folio = 'CONS_SIN_ASIGNAR_202607'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('1Z08X89A0300826855', 'CASI1Z08X89A0300826855', '1Z08X89A0300826855', 1, (SELECT id FROM cruce WHERE folio = 'CONS9943742286'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('1Z08X89A0301650873', 'CASI1Z08X89A0301650873', '1Z08X89A0301650873', 1, (SELECT id FROM cruce WHERE folio = 'CONS9962926323'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('1Z08X89A0320538281', 'CASI1Z08X89A0320538281', '1Z08X89A0320538281', 1, (SELECT id FROM cruce WHERE folio = 'CONS9943741515'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('1Z1F92320318576758', 'CASI1Z1F92320318576758', '1Z1F92320318576758', 1, (SELECT id FROM cruce WHERE folio = 'CONS9962926323'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('1ZC1R7210300545183', 'CASI1ZC1R7210300545183', '1ZC1R7210300545183', 1, (SELECT id FROM cruce WHERE folio = 'CONS9943741870'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('4207852170149400108106244117836182', 'CASI4207852170149400108106244117836182', '4207852170149400108106244117836182', 2, (SELECT id FROM cruce WHERE folio = 'CONS9943742286'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('4207852170149434908106245318083125', 'CASI4207852170149434908106245318083125', '4207852170149434908106245318083125', 2, (SELECT id FROM cruce WHERE folio = 'CONS9962926323'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('420785219200190244541414837086', 'CASI420785219200190244541414837086', '420785219200190244541414837086', 2, (SELECT id FROM cruce WHERE folio = 'CONS9943741691'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('420785219200190244541419304040', 'CASI420785219200190244541419304040', '420785219200190244541419304040', 2, (SELECT id FROM cruce WHERE folio = 'CONS9962926323'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('420785219205590267338805428145', 'CASI420785219205590267338805428145', '420785219205590267338805428145', 2, (SELECT id FROM cruce WHERE folio = 'CONS9943742286'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('420785219205590267338808841279', 'CASI420785219205590267338808841279', '420785219205590267338808841279', 2, (SELECT id FROM cruce WHERE folio = 'CONS9962926323'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('420785219400140109629002153594', 'CASI420785219400140109629002153594', '420785219400140109629002153594', 2, (SELECT id FROM cruce WHERE folio = 'CONS9943741515'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('420785219434640109629005034571', 'CASI420785219434640109629005034571', '420785219434640109629005034571', 2, (SELECT id FROM cruce WHERE folio = 'CONS9928546710'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('420785219434640109629005071033', 'CASI420785219434640109629005071033', '420785219434640109629005071033', 2, (SELECT id FROM cruce WHERE folio = 'CONS9928546710'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('420785219434640109629005267580', 'CASI420785219434640109629005267580', '420785219434640109629005267580', 2, (SELECT id FROM cruce WHERE folio = 'CONS9943741515'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('420785219434640109629005663979', 'CASI420785219434640109629005663979', '420785219434640109629005663979', 2, (SELECT id FROM cruce WHERE folio = 'CONS9943741870'), 'RECIBIDO');
INSERT INTO paquete (guia, guide_raw, tracking_number, paqueteria_id, cruce_id, estado)
VALUES ('420785219434640109629006011632', 'CASI420785219434640109629006011632', '420785219434640109629006011632', 2, (SELECT id FROM cruce WHERE folio = 'CONS9943741870'), 'RECIBIDO');
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219434640109629005071033' LIMIT 1), 'foundation cropped tee', 'black', 'M', 1, 4, 1, 0.5000, 'NEGOCIO', NULL, 36.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219434640109629005071033' LIMIT 1), 'flagship track pants', 'black', 'M', 1, 4, 5, 1.4000, 'NEGOCIO', NULL, 50.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219434640109629005071033' LIMIT 1), 'immortal killer joggers', 'black', 'M', 1, 4, 5, 1.4000, 'NEGOCIO', NULL, 50.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219434640109629005071033' LIMIT 1), 'foundation cropped tee', 'black', 'S', 1, 4, 1, 0.5000, 'PERSONAL', 6, 36.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219434640109629005071033' LIMIT 1), 'foundation cropped tee', 'black', 'S', 1, 4, 1, 0.5000, 'PERSONAL', 5, 36.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219434640109629005071033' LIMIT 1), 'supervillain', 'black', 'M', 1, 4, 1, 0.5000, 'NEGOCIO', NULL, 38.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219434640109629005071033' LIMIT 1), 'flagship track pants', 'burgundy', 'M', 1, 4, 5, 1.4000, 'NEGOCIO', NULL, 50.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219434640109629005034571' LIMIT 1), 'warrior', 'red', 'L', 1, 4, 1, 0.5000, 'PERSONAL', 4, 42.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219434640109629005034571' LIMIT 1), 'warrior', 'red', 'M', 1, 4, 1, 0.5000, 'NEGOCIO', NULL, 42.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219434640109629005034571' LIMIT 1), 'batman', 'black', 'M', 1, 5, 1, 0.5000, 'NEGOCIO', NULL, 48.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219434640109629005034571' LIMIT 1), 'batman', 'black', 'S', 1, 5, 1, 0.5000, 'NEGOCIO', NULL, 48.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89A0320538281' LIMIT 1), 'onyx hoodie', 'red', 'M', 1, 2, 6, 0.4930, 'NEGOCIO', NULL, 57.60);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89A0320538281' LIMIT 1), 'onyx hoodie', 'light grey', 'S', 1, 2, 6, 0.4930, 'NEGOCIO', NULL, 57.60);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89A0320538281' LIMIT 1), 'onyx hoodie', 'purple', 'M', 1, 2, 6, 0.4930, 'NEGOCIO', NULL, 57.60);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219400140109629002153594' LIMIT 1), 'demon slayer rengoku tee', 'Rengoku Design', 'M', 1, 5, 1, 0.5000, 'NEGOCIO', NULL, 42.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219400140109629002153594' LIMIT 1), 'quarter zipup', NULL, 'NA', 1, 4, 6, 0.7000, 'PERSONAL', 4, 55.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219434640109629005267580' LIMIT 1), 'demon slayer sweats', NULL, 'L', 1, 5, 5, 1.4000, 'PERSONAL', 4, 62.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219434640109629005267580' LIMIT 1), 'tanjiro zipup', NULL, 'NA', 1, 4, 6, 0.7000, 'PERSONAL', 4, 65.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219434640109629005267580' LIMIT 1), 'rengoku zipup', NULL, 'NA', 1, 4, 6, 0.7000, 'PERSONAL', 4, 65.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219200190244541414837086' LIMIT 1), 'Mothra City Chaos "Side By Side" Everyday Basic Tee', 'black', 'S', 1, 5, 1, 0.5000, 'PERSONAL', 6, 48.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219434640109629006011632' LIMIT 1), 'W2230 camo cargo joggers', 'pink barbed wire camo', 'S', 1, 4, 5, 1.4000, 'NEGOCIO', NULL, 52.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219434640109629006011632' LIMIT 1), 'W472 legacy seamless tank', 'dusty blue', 'XS', 1, 4, 9, 1.0000, 'NEGOCIO', NULL, 18.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219434640109629006011632' LIMIT 1), 'W149 curve hourglass biker shorts 6.5"', 'grey', 'S', 1, 4, 8, 0.7000, 'NEGOCIO', NULL, 26.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219434640109629006011632' LIMIT 1), 'W233 curve seamless leggings', 'green', 'M', 1, 4, 11, 1.0000, 'NEGOCIO', NULL, 55.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219434640109629006011632' LIMIT 1), '4255 Batman Midnight Tee', 'Joker Purple', 'M', 1, 5, 1, 0.5000, 'NEGOCIO', NULL, 22.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219434640109629005663979' LIMIT 1), 'batman tee', 'white', 'M', 1, 5, 1, 0.5000, 'NEGOCIO', NULL, 48.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219434640109629005663979' LIMIT 1), 'batman zipup', 'Black Wash', 'M', 1, 5, 6, 0.7000, 'NEGOCIO', NULL, 76.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219434640109629005663979' LIMIT 1), 'batman sweats', 'Black Wash', 'M', 1, 5, 5, 1.4000, 'NEGOCIO', NULL, 76.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1ZC1R7210300545183' LIMIT 1), 'AOT tee', 'white', 'L', 1, 4, 1, 0.5000, 'PERSONAL', 4, 42.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1ZC1R7210300545183' LIMIT 1), 'AOT joggers', 'red', 'L', 1, 4, 5, 1.4208, 'PERSONAL', 4, 68.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1ZC1R7210300545183' LIMIT 1), 'batman sweats', 'Black Wash', 'M', 1, 5, 5, 1.4000, 'PERSONAL', 4, 76.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '4207852170149400108106244117836182' LIMIT 1), 'N''s Zekrom 31 Promo - Pokémon Center Stamp', NULL, 'NA', 1, 4, 12, 0.0200, 'PERSONAL', 4, 120.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89A0300826855' LIMIT 1), 'Gymshark x CBUM Washed Hoodie - Bros', 'stone grey marl', 'M', 1, 2, 6, 1.2540, 'NEGOCIO', NULL, 70.20);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89A0300826855' LIMIT 1), 'Gymshark x CBUM Hockey Jersey', 'black', 'M', 1, 2, 1, 0.4615, 'NEGOCIO', NULL, 50.40);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89A0300826855' LIMIT 1), 'Gymshark x CBUM Straight Leg Jogger', 'black', 'M', 1, 2, 5, 1.4000, 'NEGOCIO', NULL, 63.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219205590267338805428145' LIMIT 1), 'Omega Breath Pants', NULL, 'XS', 1, 16, 5, 1.4000, 'PERSONAL', 6, 90.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219205590267338805428145' LIMIT 1), 'Breath Divinity Compression Shirt FIH', 'Black', 'L', 1, 16, 1, 0.5000, 'PERSONAL', 4, 68.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219205590267338805428145' LIMIT 1), 'Breath Divinity Compression Shirt FIH', 'Black', 'M', 1, 16, 1, 0.5000, 'PERSONAL', 6, 68.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '4207852170149434908106245318083125' LIMIT 1), 'Meta Oculus Quest 3 128GB with controllers', NULL, 'NA', 1, 4, 12, 1.0000, 'PERSONAL', 4, 305.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89A0301650873' LIMIT 1), 'Gymshark Campus 7" Shorts', 'light grey', 'XS', 1, 2, 8, 0.7000, 'PERSONAL', 6, 12.60);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89A0301650873' LIMIT 1), 'Gymshark x Carlos Belcast Track Jacket', 'grey', 'XS', 1, 2, 7, 1.2000, 'PERSONAL', 6, 45.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89A0301650873' LIMIT 1), 'Gymshark Vital 1/4 Zip', 'black/silhouette grey', 'L', 1, 2, 4, 1.0000, 'NEGOCIO', NULL, 39.60);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89A0301650873' LIMIT 1), 'Gymshark Campus Mesh Shorts', 'black/conditioning red', 'S', 1, 2, 8, 0.7000, 'PERSONAL', 6, 20.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219200190244541419304040' LIMIT 1), 'Ghidorah City Chaos "Side By Side" Everyday Distressed Tee', 'black', 'S', 1, 5, 1, 0.5000, 'PERSONAL', 6, 60.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z1F92320318576758' LIMIT 1), 'Gymshark Power Straight Leg Pants', 'GS black/GS asphalt grey', 'L', 1, 2, 5, 1.4000, 'PERSONAL', 4, 37.44);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z1F92320318576758' LIMIT 1), 'Gymshark Crest Oversized Joggers', 'GS black', 'L', 1, 2, 5, 1.4000, 'PERSONAL', 4, 28.80);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z1F92320318576758' LIMIT 1), 'Gymshark Power Oversized Hoodie', 'black/conditioning red', 'M', 1, 2, 6, 0.7000, 'PERSONAL', 4, 39.06);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z1F92320318576758' LIMIT 1), 'Gymshark x Carlos Belcast Track Pant', 'GS black', 'M', 1, 2, 5, 1.4000, 'PERSONAL', 5, 57.60);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z1F92320318576758' LIMIT 1), 'Gymshark Pumper Pants', 'black/grey', 'M', 1, 2, 5, 1.4000, 'PERSONAL', 5, 35.28);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '420785219205590267338808841279' LIMIT 1), 'Executioner Banana Shape Uncuffed Sweatpants', 'darkness', 'XS', 1, 4, 5, 1.4000, 'PERSONAL', 6, 90.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '4207852170149334620826000001283829' LIMIT 1), '5197 Demon Slayer Kimetsu no Yaiba Quarter Zip', 'warding masks', 'S', 1, 5, 6, 0.7000, 'PERSONAL', 6, 24.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '4207852170149334620826000001283829' LIMIT 1), '2064 Sideline Joggers', 'black', 'M', 1, 4, 5, 1.4000, 'PERSONAL', 5, 50.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '4207852170149334620826000001283829' LIMIT 1), '2069 Elevated Essentials Baggy Joggers', 'black wash', 'S', 1, 4, 5, 1.4000, 'PERSONAL', 6, 58.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '380419641012' LIMIT 1), 'Godzilla Hell Forever Hoodie', 'black', 'S', 1, 5, 6, 0.7000, 'PERSONAL', 5, 85.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '380419641012' LIMIT 1), 'Godzilla Hell Lounger Sweat Pants', 'black', 'S', 1, 5, 5, 1.4000, 'PERSONAL', 6, 85.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '380416815890' LIMIT 1), 'Monsters In Time Lex Double Layer Hoodie', 'black/black', 'M', 1, 5, 6, 0.7000, 'PERSONAL', 4, 68.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '380416815890' LIMIT 1), 'Monsters In Time Eternal Wide Leg Pants', 'black', 'L', 1, 5, 5, 1.4000, 'PERSONAL', 4, 68.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89AYW00349426' LIMIT 1), 'Gymshark Vital Seamless 2.0 Leggings', 'cobalt purple marl', 'S', 1, 2, 11, 1.0000, 'NEGOCIO', NULL, 32.40);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89AYW00349426' LIMIT 1), 'Gymshark Minimal Sports Bra', 'black', 'S', 1, 2, 10, 0.4000, 'NEGOCIO', NULL, 21.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89AYW00349426' LIMIT 1), 'Gymshark Adapt Animal Seamless Sports Bra', 'cherry purple/reset pink', 'M', 1, 2, 10, 0.4000, 'NEGOCIO', NULL, 32.20);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89AYW00349426' LIMIT 1), 'Gymshark Flex High Waisted Leggings', 'black', 'S', 1, 2, 11, 1.0000, 'NEGOCIO', NULL, 30.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89AYW00349426' LIMIT 1), 'Gymshark Everyday Seamless Shorts 2.0', 'GS black', 'M', 1, 2, 8, 0.7000, 'NEGOCIO', NULL, 22.40);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89AYW00349426' LIMIT 1), 'Gymshark Vital Sports Bra', 'cobalt purple marl', 'S', 1, 2, 10, 0.4000, 'NEGOCIO', NULL, 15.20);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '382233588111' LIMIT 1), 'Civil Racing Biker Jacket', 'red', 'M', 1, 6, 7, 1.2000, 'PERSONAL', 4, 127.50);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '382233588111' LIMIT 1), 'Civil Racing Biker Jacket', 'red', 'S', 1, 6, 7, 1.2000, 'PERSONAL', 6, 127.50);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89A0320535275' LIMIT 1), 'Onyx 5.0 Seamless T-Shirt', 'Black/Light Grey', 'S', 1, 2, 1, 0.5162, 'NEGOCIO', NULL, 45.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89A0320535275' LIMIT 1), 'Onyx 5.0 Seamless T-Shirt', 'Black/Light Grey', 'M', 1, 2, 1, 0.5162, 'NEGOCIO', NULL, 45.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89A0320535275' LIMIT 1), 'Onyx 5.0 Seamless T-Shirt', 'Black/Light Grey', 'L', 1, 2, 1, 0.5162, 'NEGOCIO', NULL, 45.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89A0320535275' LIMIT 1), 'Onyx 5.0 Seamless T-Shirt', 'Black/Carmine Red', 'S', 1, 2, 1, 0.5162, 'NEGOCIO', NULL, 45.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89A0320535275' LIMIT 1), 'Onyx 5.0 Seamless T-Shirt', 'Black/Carmine Red', 'M', 1, 2, 1, 0.5162, 'NEGOCIO', NULL, 45.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89A0320535275' LIMIT 1), 'Onyx 5.0 Seamless T-Shirt', 'Black/Carmine Red', 'L', 1, 2, 1, 0.5162, 'NEGOCIO', NULL, 45.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89A0320535275' LIMIT 1), 'Onyx 5.0 Seamless T-Shirt', 'Black/Onyx Grey', 'S', 1, 2, 1, 0.5162, 'NEGOCIO', NULL, 45.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89A0320535275' LIMIT 1), 'Onyx 5.0 Seamless T-Shirt', 'Black/Onyx Grey', 'M', 1, 2, 1, 0.5162, 'NEGOCIO', NULL, 45.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89A0320535275' LIMIT 1), 'Onyx 5.0 Seamless T-Shirt', 'Black/Onyx Grey', 'L', 1, 2, 1, 0.5162, 'NEGOCIO', NULL, 45.00);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89A0320535275' LIMIT 1), 'Onyx 5.0 Seamless T-Shirt', 'OG blue', 'M', 1, 2, 1, 0.5162, 'PERSONAL', 4, 40.50);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08YY74YW30322345' LIMIT 1), 'Onyx 5.0 Seamless Long Sleeve T-Shirt', 'purple', 'S', 1, 2, 1, 0.5220, 'NEGOCIO', NULL, 50.40);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08YY74YW30322345' LIMIT 1), 'Onyx 5.0 Seamless Long Sleeve T-Shirt', 'OG blue', 'XS', 1, 2, 1, 0.5220, 'NEGOCIO', NULL, 50.40);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89AYW01891981' LIMIT 1), 'Gymshark Power T-Shirt', 'black/conditioning red', 'M', 1, 2, 1, 0.5000, 'PERSONAL', 4, 21.60);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89AYW01891981' LIMIT 1), 'Gymshark Kettlebell Charm', 'conditioning red', 'one size', 1, 2, 12, 0.0200, 'PERSONAL', 4, 8.40);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89AYW01891981' LIMIT 1), 'Gymshark Kettlebell Charm', 'conditioning red', 'one size', 1, 2, 12, 0.0200, 'PERSONAL', 6, 8.40);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89AYW01891981' LIMIT 1), 'Gymshark Kettlebell Charm', 'conditioning red', 'one size', 1, 2, 12, 0.0200, 'PERSONAL', 5, 8.40);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89AYW01891981' LIMIT 1), 'Gymshark Charge T-Shirt', 'black/wash', 'XS', 1, 2, 1, 0.5000, 'PERSONAL', 6, 21.60);
INSERT INTO pieza (paquete_id, descripcion, color, talla, cantidad, marca_id, tipo_prenda_id, factor_manual, destino, socio_id, costo_usd)
VALUES ((SELECT id FROM paquete WHERE guia = '1Z08X89AYW01891981' LIMIT 1), 'Gymshark Charge T-Shirt', 'black/wash', 'M', 1, 2, 1, 0.5000, 'PERSONAL', 5, 21.60);

COMMIT;
-- Total: 12 cruces, 25 paquetes, 83 piezas (41 NEG + 42 PERS)