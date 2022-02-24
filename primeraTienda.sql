CREATE SCHEMA tienda; 
CREATE TABLE tienda.ADMINISTADOR (
	nombre VARCHAR(100) NOT NULL PRIMARY KEY,
	telefono VARCHAR(20) NOT NULL,
	email VARCHAR(100) NOT NULL,
	contrasenia VARCHAR(100) NOT NULL
);

CREATE TYPE tienda.enum_tipo_identificacion AS ENUM ('CC','CE', 'NIT');

CREATE TABLE tienda.USUARIO (
	numero_identificacion INT NOT NULL PRIMARY KEY,
	enum_tipo_identificacion tienda.enum_tipo_identificacion,
	proveedor boolean NOT NULL,
	nombre VARCHAR(100) NOT NULL,
	telefono VARCHAR(20) NOT NULL,
	email VARCHAR(100) NOT NULL,
	direccion VARCHAR(100) NOT NULL,
	ciudad VARCHAR(100) NOT NULL,
	contrasenia VARCHAR(100) NOT NULL
);

CREATE TABLE tienda.PRODUCTO (
	id_producto INT NOT NULL PRIMARY KEY,
	titulo_producto VARCHAR(100) UNIQUE NOT NULL,
	categoria_producto VARCHAR(100) NOT NULL,
	marca_producto VARCHAR(100) NOT NULL,
	descripcion_producto VARCHAR(500) NOT NULL,
	precio_producto int NOT NULL,
	stock int not null
);

CREATE TABLE tienda.ORDEN_COMPRA (
	id_orden INT NOT NULL PRIMARY KEY,
	direccion_envio VARCHAR(250) NOT NULL,
	tipo_envio boolean NOT NULL,
	valor_compra int NOT NULL,
	numero_identificacion int NOT NULL,
	CONSTRAINT "id_orden" FOREIGN KEY ("numero_identificacion")
		REFERENCES tienda.usuario("numero_identificacion")
);

CREATE TABLE tienda.PRODUCTOS_COMPRA (
	id_orden INT NOT NULL,
	id_producto INT NOT NULL,
	-- 1 preparacion 2 enviado 3 recibido 4 cancelado
	estado_producto INT NOT NULL,
	CONSTRAINT "id_orden" FOREIGN KEY ("id_orden")
		REFERENCES tienda.ORDEN_COMPRA("id_orden"),
	CONSTRAINT "id_producto" FOREIGN KEY ("id_producto")
		REFERENCES tienda.producto("id_producto")
);

-- usuarios
INSERT into tienda.usuario VALUES (500,'CC',false,'BRIAN',588485, 'brian@gmail','carrera 71', 'CHIA', 'ADMIN');
INSERT into tienda.usuario VALUES (600,'CC',false,'Jósteinn',588485, 'bifrost@gmail','carrera 9', 'USAQUÉN', 'mjolnir333');
INSERT into tienda.usuario VALUES (700,'CC',false,'Vasant',588485, 'vava@gmail','carrera 43', 'SUBA', 'pepita47');
INSERT into tienda.usuario VALUES (800,'CC',false,'Ada',588485, 'lovelace@protonmail','autonorte', 'ENGATIVA', '#X@Un1c0d3@X#');
INSERT into tienda.usuario VALUES (900,'CC',false,'Emilia',588485, 'emily@outlook','el dorado', 'FONTIBÓN', 'emi');
-- productos
INSERT INTO tienda.producto VALUES (10, 'mouse negro genius', 'periféricos', 'genius', 'mouse chimba negro genius usado', 1000, 300);
INSERT INTO tienda.producto VALUES (20, 'mouse rosa genius', 'periféricos', 'genius', 'mouse chimba rosa genius usado', 3000, 300);
INSERT INTO tienda.producto VALUES (30, 'mouse azul genius', 'periféricos', 'genius', 'mouse chimba azul genius usado', 500, 300);
INSERT INTO tienda.producto VALUES (40, 'teclado negro genius', 'periféricos', 'genius', 'teclado chimba negro genius usado', 700, 300);
INSERT INTO tienda.producto VALUES (50, 'teclado negro logitech', 'periféricos', 'logitech', 'teclado chimba negro logitech nuevo', 1200, 300);
INSERT INTO tienda.producto VALUES (60, 'cable negro logitech', 'periféricos', 'logitech', 'cable chimba logitech nuevo', 7000, 300);
INSERT INTO tienda.producto VALUES (70, 'java 8 in action', 'libros', 'oreilly', 'libro streams y lambdas java 8', 85,  50);
INSERT INTO tienda.producto VALUES (80, 'learning python', 'libros', 'oreilly', 'libro programación básica en python', 900, 50);
INSERT INTO tienda.producto VALUES (90, 'cobol estructurado', 'libros', 'mc grawhill', 'libro sistemas administrativos y sintaxis cobol', 970, 70);

-- compras + productos compra
INSERT into tienda.orden_compra VALUES (20,'call 48 sur', FALSE, 300, 500); -- brian compra 10
	INSERT into tienda.productos_compra VALUES (20, 10, 1);
INSERT into tienda.orden_compra VALUES (21,'carrera 9', FALSE, 600, 600); -- josteinn compra 30 y 50
	INSERT into tienda.productos_compra VALUES (21, 30, 3);
	INSERT into tienda.productos_compra VALUES (21, 50, 3);
INSERT into tienda.orden_compra VALUES (22,'call 48 sur', FALSE, 300, 700); -- vasant compra 60
	INSERT into tienda.productos_compra VALUES (22, 60, 4);
INSERT into tienda.orden_compra VALUES (23,'call 48 sur', FALSE, 470, 800); -- ada compra 40, 70, 80 y 90
	INSERT into tienda.productos_compra VALUES (23, 40, 2);
	INSERT into tienda.productos_compra VALUES (23, 70, 3);
	INSERT into tienda.productos_compra VALUES (23, 80, 3);
	INSERT into tienda.productos_compra VALUES (23, 90, 3);


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
