/* Vista 1 - Productos
Seguridad. Un comprador solo deberia ver los productos y su historial */
CREATE MATERIALIZED VIEW tienda.comprador_productos AS 
SELECT Id_producto id,
	Categoria_producto cat,
	Marca_producto mar,
	Descripcion_producto des,
	Precio_producto pre
FROM tienda.Producto

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
CREATE INDEX indice_comprador_historial ON tienda.orden_compra (id_orden);
