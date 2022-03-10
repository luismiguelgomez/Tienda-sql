CREATE SCHEMA tienda;

--ENUMS------------------------------------
CREATE TYPE tienda.enum_tipo_docu AS ENUM ('CC','CE', 'NIT');
CREATE TYPE tienda.enum_tipo_evento AS ENUM ('CREATE', 'UPDATE', 'DELETE');
CREATE TYPE tienda.enum_score_desc AS ENUM ('LOW', 'LOW-MID', 'MID', 'MID-HIGH', 'HIGH');
CREATE TYPE tienda.enum_tipo_pago AS ENUM ('Debito', 'Credito', 'PSE');

/* Borré las views y los índices pq para este taller son un cero a la izquierda,
 pero si nos llegan a hacer falta las recuperamos de commits anteriores */

--TABLES---------------------------------
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
	CONSTRAINT "Customer_id" FOREIGN KEY ("customer_id")
		REFERENCES tienda.CUSTOMER("customer_id")
);

CREATE TABLE tienda.ORDEN_COMPRA (
	Order_id INT NOT NULL PRIMARY KEY,
	Delivery_address VARCHAR(250) NOT NULL,
	isPremiun BOOLEAN NOT NULL,
	Valor_compra INT NOT NULL,
	Customer_id INT NOT NULL,
	CONSTRAINT "Customer_id" FOREIGN KEY ("customer_id")
		REFERENCES tienda.CUSTOMER("customer_id")
);

CREATE TABLE tienda.ADMINISTATOR (
	Admin_id INT NOT NULL PRIMARY KEY,
	Admin_phone VARCHAR(20) NOT NULL,
	Admin_email VARCHAR(100) NOT NULL,
	Admin_pw VARCHAR(100) NOT NULL
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
	Provider_pw VARCHAR(100) NOT NULL
);

CREATE TABLE tienda.WEEKLY_REPUTATION (
	--Debería estar especificado de quién es la reputación
	Provider_id INT NOT NULL,
	Weekly_score INT NOT NULL,
	Score_desc tienda.enum_score_desc NOT NULL,
	Week_init_date TIMESTAMP NOT NULL
);
		
ALTER TABLE tienda.WEEKLY_REPUTATION ADD CONSTRAINT "Provider_id" FOREIGN KEY ("provider_id")
		REFERENCES tienda.PROVIDER("provider_id");

CREATE TABLE tienda.PRODUCT (
	Product_id INT NOT NULL PRIMARY KEY,
	Product_name VARCHAR(100) NOT NULL,
	Product_category VARCHAR(100) NOT NULL,
	Product_brand VARCHAR(100) NOT NULL,
	Product_stock INT NOT NULL,
	Provider_id INT NOT NULL,
	CONSTRAINT "Provider_id" FOREIGN KEY ("provider_id")
		REFERENCES tienda.PROVIDER("provider_id")
);

CREATE TABLE tienda.PRODUCT_SALE (
	Order_id INT NOT NULL,
	Product_id INT NOT NULL,
	--1 preparacion 2 enviado 3 recibido 4 cancelado
	Product_state INT NOT NULL,
	Variant_id INT NOT NULL,
	CONSTRAINT "Order_id" FOREIGN KEY ("order_id")
		REFERENCES tienda.ORDEN_COMPRA("order_id"),
	CONSTRAINT "Product_id" FOREIGN KEY ("product_id")
		REFERENCES tienda.PRODUCT("product_id")
);

CREATE TABLE tienda.Payment_method (
	Payment_method_id INT NOT NULL PRIMARY KEY,
	Method_name tienda.enum_tipo_pago NOT NULL ,
	--Card_num porque 'Number' es una palabra reservada
	--Nulleable porque no se tiene q especificar el valor si es PSE
	Card_num BIGINT,
	Monthly_fees SMALLINT NOT NULL
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
	Provider_id INT NOT NULL,
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
	CONSTRAINT "Variant_id" FOREIGN KEY ("variant_id")
		REFERENCES tienda.VARIANT("variant_id")
);

CREATE TABLE tienda.PRODUCT_AUDIT (
	Product_audit_id INT NOT NULL PRIMARY KEY,
	--Pongo el ID sin FK porque causaría errores
	Product_id INT NOT NULL,
	Product_category VARCHAR(100) NOT NULL,
	Product_brand VARCHAR(100) NOT NULL,
	Product_stock INT NOT NULL,
	Provider_id INT NOT NULL,
	Provider_name VARCHAR(100) NOT NULL,
	Provider_phone VARCHAR(20) NOT NULL,
	Provider_email VARCHAR(100) NOT NULL,
	Provider_address VARCHAR(100) NOT NULL,
	Provider_city VARCHAR(100) NOT NULL,
	Event_type tienda.enum_score_desc NOT NULL,
	Event_datetime TIMESTAMP NOT NULL
);

-- INSERTIONS---------------------------------
/* ADMIN -> ID(3), PHONE, EMAIL, PW */
INSERT INTO tienda.ADMINISTATOR VALUES ('100','588485','brian@gmail','passw0rBRIAN');
/* PROVIDER -> ID, DOCTYPE, NAME, PHONE, EMAIL, ADDRESS, CITY, PW */
INSERT INTO tienda.PROVIDER VALUES (200, 'CC', 'Ada', '588485', 'lovelace@protonmail', 'Autonorte', 'Bogotá', '#X@Un1c0d3@X#');
/* CUSTOMER -> ID, DOCTYPE, NAME, PHONE, EMAIL, ADDRESS, CITY, PW */
INSERT INTO tienda.CUSTOMER VALUES (300, 'CC', 'Emilia', '588485', 'emily@outlook', 'El Dorado', 'Bogotá', 'Empanadas123');
/* PRODUCT -> ID(2), NAME, CATEGORY, BRAND, STOCK, PROV_ID */
INSERT INTO tienda.PRODUCT VALUES (10, 'mouse genius', 'periféricos', 'genius', 1000, 200); /* tiene variants */
INSERT INTO tienda.PRODUCT VALUES (20, 'teclado logitech', 'periféricos', 'logitech', 700, 200); /* tiene variants */
/* VARIANT -> ID, NAME, DESC, PRICE, STOCK, PROD_ID */
INSERT INTO tienda.VARIANT VALUES (101, 'negro', 'mouse genius negro', 1000, 20, 10);
INSERT INTO tienda.VARIANT VALUES (102, 'rosa', 'mouse genius rosa', 1000, 20, 10);
INSERT INTO tienda.VARIANT VALUES (201, 'negro nebulosa', 'teclado logitech negro', 1000, 20, 20);
INSERT INTO tienda.VARIANT VALUES (202, 'rojo', 'teclado logitech rosa', 1000, 20, 20);

/* Emilia le compra 10 y 20 a Ada */
/* ORD_ID(4), DEL_ADDRESS, ISPREMIUN, PLATA, CUST_ID */
INSERT INTO tienda.orden_compra VALUES (1000,'El Dorado', FALSE, 80000, 300);
	/* ORD_ID, PROD_ID, PROD_STATE, VARIANT_ID */
	INSERT INTO tienda.productos_compra VALUES (1000, 10, 1, 102);
	INSERT INTO tienda.productos_compra VALUES (1000, 20, 2, 202);
