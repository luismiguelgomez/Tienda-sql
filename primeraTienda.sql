CREATE SCHEMA tienda;

--ENUMS------------------------------------
CREATE TYPE tienda.enum_tipo_docu AS ENUM ('CC','CE', 'NIT');
CREATE TYPE tienda.enum_tipo_evento AS ENUM ('CREATE', 'UPDATE', 'DELETE');
CREATE TYPE tienda.enum_score_desc AS ENUM ('LOW', 'LOW-MID', 'MID', 'MID-HIGH', 'HIGH');
CREATE TYPE tienda.enum_tipo_pago AS ENUM ('Debito', 'Credito', 'PSE');

/* TODO: Double-check if References/Relations are correctly handled */
/* TODO: Create insertions (Maybe not from scratch) */

--CREATION---------------------------------
CREATE TABLE tienda.CUSTOMER (
	Customer_id INT NOT NULL PRIMARY KEY,
	Customer_doctype tienda.enum_tipo_docu NOT NULL,
	Customer_name VARCHAR(100) NOT NULL,
	Customer_phone VARCHAR(20) UNIQUE NOT NULL,
	Customer_email VARCHAR(100) UNIQUE NOT NULL,
	Customer_address VARCHAR(100) NOT NULL,
	Customer_city VARCHAR(100) NOT NULL,
	Customer_pw VARCHAR(100) NOT NULL
);

CREATE TABLE tienda.SHOPPING_CART (
	Cart_id INT NOT NULL PRIMARY KEY,
	Creation_date TIMESTAMP NOT NULL,
	Customer_id INT NOT NULL,
	CONSTRAINT "Customer_id" FOREIGN KEY ("Customer_id")
		REFERENCES tienda.CUSTOMER("Customer_id")
);

CREATE TABLE tienda.ORDEN_COMPRA (
	Order_id INT NOT NULL PRIMARY KEY,
	Delivery_address VARCHAR(250) NOT NULL,
	isPremiun BOOLEAN NOT NULL,
	Valor_compra INT NOT NULL,
	Customer_id INT NOT NULL,
	CONSTRAINT "Customer_id" FOREIGN KEY ("Customer_id")
		REFERENCES tienda.CUSTOMER("Customer_id")
);

CREATE TABLE tienda.ADMINISTATOR (
	Admin_id VARCHAR(100) NOT NULL PRIMARY KEY,
	Admin_phone VARCHAR(20) NOT NULL,
	Admin_email VARCHAR(100) NOT NULL,
	Admin_pw VARCHAR(100) NOT NULL
);

CREATE TABLE tienda.PRODUCT_SALE (
	Order_id INT NOT NULL,
	Product_id INT NOT NULL,
	--1 preparacion 2 enviado 3 recibido 4 cancelado
	Product_state INT NOT NULL,
	Variant_id INT NOT NULL,
	CONSTRAINT "Order_id" FOREIGN KEY ("Order_id")
		REFERENCES tienda.ORDEN_COMPRA("Order_id"),
	CONSTRAINT "Product_id" FOREIGN KEY ("Product_id")
		REFERENCES tienda.PRODUCTO("Product_id")
);

CREATE TABLE tienda.Payment_method (
	Payment_method_id INT NOT NULL PRIMARY KEY,
	Method_name tienda.enum_tipo_pago NOT NULL ,
	--Card_num porque 'Number' es una palabra reservada
	--Nulleable porque no se tiene q especificar el valor si es PSE
	Card_num BIGINT,
	Monthly_fees SMALLINT NOT NULL
);

CREATE TABLE tienda.PROVIDER (
	/* Id porque todos los usuarios pueden crear Ids
	que pueden ser de varios tipos */
	Provider_id INT NOT NULL PRIMARY KEY,
	Provider_doctype tienda.enum_tipo_docu NOT NULL,
	Provider_name VARCHAR(100) NOT NULL,
	Provider_phone VARCHAR(20) UNIQUE NOT NULL,
	Provider_email VARCHAR(100) UNIQUE NOT NULL,
	Provider_address VARCHAR(100) NOT NULL,
	Provider_city VARCHAR(100) NOT NULL,
	Provider_pw VARCHAR(100) NOT NULL,
	--Debería poderse ver la reputación semanal del Proveedor
	Provider_rep_id INT NOT NULL,
	CONSTRAINT "Provider_rep_id" FOREIGN KEY ("Weekly_rep_id")
		REFERENCES tienda.WEEKLY_REPUTATION("Weekly_rep_id")
);

CREATE TABLE tienda.PRODUCT (
	Product_id INT NOT NULL PRIMARY KEY,
	Product_name VARCHAR(100) NOT NULL,
	Product_category VARCHAR(100) NOT NULL,
	Product_brand VARCHAR(100) NOT NULL,
	Product_stock INT NOT NULL,
	Provider_id INT NOT NULL,
);

CREATE TABLE tienda.VARIANT (
	Variant_id INT NOT NULL PRIMARY KEY,
	Variant_name VARCHAR(100) UNIQUE NOT NULL,
	Variant_description VARCHAR(500) UNIQUE NOT NULL,
	Variant_price INT NOT NULL,
	Variant_stock INT NOT NULL,
	Product_id INT NOT NULL
);

CREATE TABLE tienda.REVIEW (
	Review_id INT NOT NULL PRIMARY KEY,
	Review_obtained INT NOT NULL,
	Review_text VARCHAR(300),
	Review_date TIMESTAMP NOT NULL,
	Provider_id INT NOT NULL
);

CREATE TABLE tienda.VARIANT_AUDIT (
	Variant_audit_id INT NOT NULL PRIMARY KEY,
	Product_id INT NOT NULL,
	Product_name VARCHAR(100) NOT NULL,
	Product_category VARCHAR(100) NOT NULL,
	Product_brand VARCHAR(100) NOT NULL,
	Product_stock INT NOT NULL,
	Provider_id NOT NULL,
	Provider_name VARCHAR(100) NOT NULL,
	Provider_phone VARCHAR(20) NOT NULL,
	Provider_email VARCHAR(100) NOT NULL,
	Provider_address VARCHAR(100) NOT NULL,
	Provider_city VARCHAR(100) NOT NULL,
	Variant_id INT NOT NULL,
	Variant_name VARCHAR(100) NOT NULL,
	Variant_description VARCHAR(500) NOT NULL,
	Variant_price INT NOT NULL,
	Variant_stock INT NOT NULL,
	Event_type tienda.enum_tipo_evento NOT NULL,
	Event_datetime TIMESTAMP NOT NULL,
	CONSTRAINT "Variant_id" FOREIGN KEY ("Variant_id")
		REFERENCES tienda.VARIANT("Variant_id")
);

CREATE TABLE tienda.WEEKLY_REPUTATION (
	Weekly_rep_id INT NOT NULL,
	--Debería estar especificado de quién es la reputación
	Provider_id INT NOT NULL,
	Weekly_score INT NOT NULL,
	Score_desc tienda.enum_score_desc NOT NULL,
	Week_init_date TIMESTAMP NOT NULL,
	CONSTRAINT "Provider_id" FOREIGN KEY ("Provider_id")
		REFERENCES tienda.PROVIDER("Provider_id")
);

CREATE TABLE tienda.PRODUCT_AUDIT (
	Product_audit_id INT NOT NULL PRIMARY KEY,
	--Pongo el ID sin FK porque causaría errores
	Product_id INT NOT NULL,
	Product_category VARCHAR(100) NOT NULL,
	Product_brand VARCHAR(100) NOT NULL
	Product_stock INT NOT NULL,
	Provider_id INT NOT NULL,
	Provider_name VARCHAR(100) NOT NULL,
	Provider_phone VARCHAR(20) NOT NULL,
	Provider_email VARCHAR(100) NOT NULL,
	Provider_address VARCHAR(100) NOT NULL,
	Provider_city VARCHAR(100) NOT NULL,
	Event_type tienda.enum_score_desc NOT NULL,
	Event_datetime TIMESTAMP NOT NULL,
);


-- INSERTIONS---------------------------------
/* ADMIN -> ID(3), PHONE, EMAIL, PW */
INSERT INTO tienda.ADMINISTRATOR VALUES (100,'CC', 'BRIAN',588485, 'brian@gmail', 'Carrera 71', 'Chia', 'ADMIN');
/* PROVIDER -> ID, DOCTYPE, NAME, PHONE, EMAIL, ADDRESS, CITY, PW */
INSERT INTO tienda.PROVIDER VALUES (200, 'CC', 'Ada', 588485, 'lovelace@protonmail', 'Autonorte', 'Bogotá', '#X@Un1c0d3@X#');
/* CUSTOMER -> ID, DOCTYPE, NAME, PHONE, EMAIL, ADDRESS, CITY, PW */
INSERT INTO tienda.CUSTOMER VALUES (300, 'CC', 'Emilia', 588485, 'emily@outlook', 'El Dorado', 'Bogotá', 'Empanadas123');
/* PRODUCT -> ID(2), NAME, CATEGORY, BRAND, STOCK, PROV_ID */
INSERT INTO tienda.PRODUCT VALUES (10, 'mouse genius', 'periféricos', 'genius', 'mouse chimba genius', 1000, 200); /* tiene variants */
INSERT INTO tienda.PRODUCT VALUES (20, 'teclado logitech', 'periféricos', 'logitech', 'teclado chimba genius', 700, 200); /* tiene variants */
/* VARIANT -> ID, NAME, DESC, PRICE, STOCK, PROD_ID */
INSERT INTO tienda.VARIANT VALUES (101, 'negro', 'mouse genius negro', 1000, 20, 10);
INSERT INTO tienda.VARIANT VALUES (102, 'rosa', 'mouse genius rosa', 1000, 20, 10);
INSERT INTO tienda.VARIANT VALUES (201, 'negro', 'teclado logitech negro', 1000, 20, 20);
INSERT INTO tienda.VARIANT VALUES (202, 'rosa', 'teclado logitech rosa', 1000, 20, 20);

/* Emilia le compra 10 y 20 a Ada */
/* ORD_ID(4), DEL_ADDRESS, ISPREMIUN, PLATA, CUST_ID */
INSERT INTO tienda.orden_compra VALUES (1000,'El Dorado', FALSE, 300, 100);
	/* ORD_ID, PROD_ID, PROD_STATE, VARIANT_ID */
	INSERT INTO tienda.productos_compra VALUES (1000, 10, 1, 102);
	INSERT INTO tienda.productos_compra VALUES (1000, 20, 2, 202);

----------------------------------------------

/* Vista 1 - Productos
Seguridad. Un comprador solo deberia ver los productos y su historial */
CREATE MATERIALIZED VIEW tienda.comprador_productos AS 
SELECT Id_producto id,
	Categoria_producto cat,
	Marca_producto mar,
	Descripcion_producto des,
	Precio_producto pre
FROM tienda.Producto;

SELECT * FROM tienda.comprador_productos;

/* Vista 2 - Historial
Seguridad. Un comprador solo debería ver los productos y su historial
-> Realice la eliminacion, por ejemplo */
DROP MATERIALIZED VIEW  IF EXISTS tienda.comprador_historial;
CREATE MATERIALIZED VIEW  tienda.comprador_historial AS
SELECT
	id_orden id,
	Direccion_envio dir,
	Tipo_envio tipo,
	Valor_compra val,
	numero_identificacion num
FROM  tienda.orden_compra;

SELECT * FROM  tienda.comprador_historial;

/* Vista 3 - Productos Orden
Seguridad. Un comprador solo debería ver los productos y su historial */
CREATE MATERIALIZED VIEW  tienda.comprador_historial_producto AS
SELECT
	ord_c.id_orden,
	prod_compra.estado_producto,
	prod.categoria_producto,
	prod.marca_producto,
	prod.descripcion_producto,
	prod.Precio_producto
FROM tienda.orden_compra ord_c
JOIN tienda.productos_compra prod_compra ON prod_compra.id_orden = ord_c.id_orden
JOIN tienda.producto prod ON prod.id_producto = prod_compra.id_producto;

SELECT * FROM tienda.comprador_historial_producto;

/* Vista 4 - Proveedor
Un comprador solo deberia ver los productos y ser capaz de modificarlos, 
por ende debe ver el stock */
CREATE MATERIALIZED VIEW tienda.proveedor_producto AS
SELECT
	Id_producto,
	Categoria_producto cate,
	Marca_producto marc,
	Descripcion_producto,
	Precio_producto prec,
	stock
FROM tienda.producto;

/* Índices de las PK */
/* Índice #1.1 - Número de identificación del usuario */
CREATE INDEX id_usuarios ON tienda.usuario(numero_identificacion);

/* Índice #1.2 - Número de identificación del producto */
CREATE INDEX id_productos ON tienda.producto(id_producto);

/* Índice #1.3 - Número de identificación de la órden */
CREATE INDEX id_ordenes ON tienda.orden_compra(id_orden);

/* Índices adicionales */
/* Índice #2.1 - Filtro por categoria
Para realizar la validacion (Si el producto pertenece o no a una categoria) para 
filtrar productos por categoria solo es necesario saber la categoria. */
CREATE INDEX productos_categoria ON tienda.producto(categoria_producto);

/* Índice #2.2 - Filtro por marca
Para realizar la validacion (Si el producto pertenece o no a una categoria) para filtrar productos por categoria solo es necesario saber la categoria. */
CREATE INDEX productos_marca ON tienda.producto (marca_producto);

/* Índice #2.3 - Ordenes
Para facilitar la visualización de órdenes en el historial */
CREATE INDEX indice_comprador_historial_producto ON tienda.orden_compra (id_orden);
