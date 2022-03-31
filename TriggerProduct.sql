CREATE OR REPLACE FUNCTION trigger_audit_product() RETURNS trigger as $$
BEGIN
	IF (TG_OP = 'INSERT') THEN
		INSERT INTO tienda.product_audit (product_id, product_name, product_category, product_brand, 
		product_stock, provider_id, event_type, event_datetime)
		VALUES(new.product_id, new.product_name, new.product_category, new.product_brand, new.product_stock, 
			  new.provider_id, 'INSERT', current_date);
		RETURN NEW;
	ELSEIF (TG_OP = 'UPDATE') THEN
		INSERT INTO tienda.product_audit (product_id, product_name, product_category, product_brand, 
		product_stock, provider_id, event_type, event_datetime)
		VALUES(old.product_id, old.product_name, old.product_category, old.product_brand, old.product_stock, 
			  old.provider_id, 'UPDATE', current_date);
		RETURN NEW;
	ELSEIF (TG_OP = 'DELETE') THEN
		INSERT INTO tienda.product_audit (product_id, product_name, product_category, product_brand, 
		product_stock, provider_id, event_type, event_datetime)
		VALUES(old.product_id, old.product_name, old.product_category, old.product_brand, old.product_stock, 
			  old.provider_id, 'DELETE', current_date);
		RETURN OLD;
	END IF;
	RETURN NULL;
END;
$$LANGUAGE PLPGSQL;

CREATE TRIGGER trigger_audit_product AFTER INSERT OR UPDATE OR DELETE ON tienda.product
FOR EACH ROW EXECUTE PROCEDURE trigger_audit_product();

SELECT * from tienda.product;
SELECT * FROM tienda.variant_audit;

/*First INSERT to product*/
INSERT INTO tienda.product(
	"product_id", "product_name", "product_category", "product_brand", "product_stock", "provider_id")
	VALUES (1, 'cepillo', 'aseo personal','oral b', 7, 200);

/*Second INSERT to product*/
INSERT INTO tienda.product(
	"product_id", "product_name", "product_category", "product_brand", "product_stock", "provider_id")
	VALUES (2, 'aceite de girasol', 'despensa','gourmet', 12, 200);

select * from tienda.product_audit;

UPDATE tienda.product
	SET "product_brand"='exito', "product_stock"=3
	WHERE "product_name" = 'aceite de girasol';

select * from tienda.product_audit;

DELETE FROM tienda.product
	WHERE "product_name" = 'aceite de girasol';

select * from tienda.product_audit;
