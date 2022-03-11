/* Estaba pensando este trigger pa los UPDATEs */
CREATE OR REPLACE FUNCTION audit_action()
	RETURNS TRIGGER
	LANGUAGE PLPGSQL
	AS
		$$
		DECLARE
			old_provider tienda.provider%rowtype; --> Es una variable con la estructura de una tupla
			de tienda.old_provider
		BEGIN
			INSERT (
				product_id,
				product_category,
				product_brand,
				product_stock,
				provider_id,
				provider_name,
				provider_phone,
				provider_email,
				provider_address,
				provider_city,
				event_type			
			)
			VALUES (
				-- El product_audit_id se pone solo
				OLD.product_id,
				OLD.product_category,
				OLD.product_brand,
				/* Esta columna product_stock no va, pues cada VARIANT tiene su propio stock,
				no el producto entonces Brian, cambie eso en primeraTienda.sql y después borre
				esta columna */
				OLD.product_stock, 
				/* Estas columnas del provider se encuentran mediante un SELECT INTO a la
				variable old_provider y a punta de old_provider.provider_id, old_provider.provider_phone, etc. */
				OLD.provider_id,
				OLD.provider_name,
				OLD.provider_phone,
				OLD.provider_email,
				OLD.provider_address,
				OLD.provider_city,
				TG_OP --> Variable tipo de operación
				-- El timestamp se pone solo
			)
			INTO insertion
			RETURN OLD;
			RETURN OLD;
			END IF;
		END
		$$
