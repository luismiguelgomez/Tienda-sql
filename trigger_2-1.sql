CREATE OR REPLACE FUNCTION check_order_duplicates()
	RETURNS TRIGGER
	LANGUAGE PLPGSQL
	AS
		$$
		DECLARE
			cart_in INTEGER = NEW.cart_id;
			orders_rec record;
		BEGIN
			SELECT COUNT(order_id)
			INTO orders_rec FROM tienda.purchase_order WHERE cart_id=cart_in;
			IF orders_rec.count > 0 THEN 
				RAISE EXCEPTION 'ORDER DUPLICATE: Cart cart_id already has an order placed';
				RETURN OLD;
			ELSE 
				RETURN NEW;
			END IF;
		END
		$$

-- USAR EN CASO DE EMERGENCIA: DROP TRIGGER on_order_place ON tienda.purchase_order
