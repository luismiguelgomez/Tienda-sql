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
	id_orden INT NOT NULL PRIMARY KEY,
	id_producto INT NOT NULL,
	estado_producto INT NOT NULL,
	CONSTRAINT "id_orden" FOREIGN KEY ("id_orden")
		REFERENCES tienda.ORDEN_COMPRA("id_orden"),
	CONSTRAINT "id_producto" FOREIGN KEY ("id_producto")
		REFERENCES tienda.producto("id_producto")
);

INSERT into tienda.usuario VALUES (500,'CC',false,'BRIAN',588485, 'brian@gmail','carrera 71', 'CHIA', 'ADMIN');
INSERT into tienda.orden_compra VALUES (12,'call 48 sur', FALSE, 700, 500);


-- vistas (min. 2)
-- indices (min. 3, adicional a los PK)

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- vista #1 - Productos
-- justificacion: un comprador solo deberia ver los productos y su historial

CREATE MATERIALIZED VIEW tienda.comprador_productos as 
SELECT Id_producto id,
	Categoria_producto cat,
	Marca_producto mar,
	Descripcion_producto desc,
	Precio_producto pre
FROM tienda.Producto

select * from tienda.comprador_productos;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- vista #2 - Historial
-- justificacion: un comprador solo deberia ver los productos y su historial
/*Realice la eliminacion por ejemplo*/
drop MATERIALIZED VIEW  IF EXISTS tienda.comprador_historial;
CREATE MATERIALIZED VIEW  tienda.comprador_historial AS
SELECT
	id_orden id,
	Direccion_envio dir,
	Tipo_envio tipo,
	Valor_compra val,
	numero_identificacion num
FROM  tienda.orden_compra;

SELECT * FROM  tienda.comprador_historial;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- vista #3 - Productos Orden
-- justificacion: un comprador solo deberia ver los productos y su historial
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
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- vista #4 - Proveedor
-- justificacion: un comprador solo deberia ver los productos y ser capaz de modificarlos, por ende debe ver el stock.
CREATE MATERIALIZED VIEW tienda.proveedor_producto AS
SELECT
	Id_producto,
	Categoria_producto cate,
	Marca_producto marc,
	Descripcion_producto,
	Precio_producto prec,
	stock
FROM tienda.producto;
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- indice #1 - Filtro por categoria
-- justificacion: Para realizar la validacion (Si el producto pertenece o no a una categoria) para filtrar productos por categoria solo es necesario saber la categoria.
CREATE INDEX productos_categoria ON tienda.producto(categoria_producto);
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- indice #2 - Filtro por 
-- justificacion: Para realizar la validacion (Si el producto pertenece o no a una categoria) para filtrar productos por categoria solo es necesario saber la categoria.
CREATE INDEX productos_marca ON tienda.producto (marca_producto);
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- indice #3 - Ordenes
-- justificacion: TODO: Cambiar esto !!
CREATE INDEX indice_comprador_historial ON tienda.orden_compra (id_orden);
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
