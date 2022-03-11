CREATE TRIGGER on_order_place
	BEFORE INSERT
	ON tienda.purchase_order
	FOR EACH ROW EXECUTE PROCEDURE check_order_duplicates();
