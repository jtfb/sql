-- Cross Join
/*1. Suppose every vendor in the `vendor_inventory` table had 5 of each of their products to sell to **every** 
customer on record. How much money would each vendor make per product? 
Show this by vendor_name and product name, rather than using the IDs.

HINT: Be sure you select only relevant columns and rows. 
Remember, CROSS JOIN will explode your table rows, so CROSS JOIN should likely be a subquery. 
Think a bit about the row counts: how many distinct vendors, product names are there (x)?
How many customers are there (y). 
Before your final group by you should have the product of those two queries (x*y).  */

DROP TABLE IF EXISTS new_vendor_inventory;
CREATE TEMP TABLE new_vendor_inventory AS
	SELECT
	market_date
	,vendor_id
	,product_id
	,5 as quantity
	,original_price
	FROM vendor_inventory

SELECT
v.vendor_name
,x.product_name
,x.total
FROM (
	SELECT 
	*
	,nvi.original_price*nvi.quantity AS total
	FROM new_vendor_inventory as nvi
	CROSS JOIN product as p
	ON nvi.product_id = p.product_id
	GROUP BY nvi.product_id,nvi.vendor_id
)x
CROSS JOIN vendor as v
ON x.vendor_id = v.vendor_id


-- INSERT
/*1.  Create a new table "product_units". 
This table will contain only products where the `product_qty_type = 'unit'`. 
It should use all of the columns from the product table, as well as a new column for the `CURRENT_TIMESTAMP`.  
Name the timestamp column `snapshot_timestamp`. */

DROP TABLE IF EXISTS product_units;
CREATE TABLE product_units AS
	SELECT *
	,CURRENT_TIMESTAMP AS 'snapshot_timestamp'
	FROM product
	WHERE product_qty_type = 'unit';

SELECT *
FROM product_units


/*2. Using `INSERT`, add a new row to the product_units table (with an updated timestamp). 
This can be any product you desire (e.g. add another record for Apple Pie). */

INSERT INTO product_units
VALUES(24,'Banada Bread', '10"', 3, 'unit', CURRENT_TIMESTAMP)


-- DELETE
/* 1. Delete the older record for the whatever product you added. 

HINT: If you don't specify a WHERE clause, you are going to have a bad time.*/
DELETE FROM product_units
WHERE product_id = 24


-- UPDATE
/* 1.We want to add the current_quantity to the product_units table. 
First, add a new column, current_quantity to the table using the following syntax.

ALTER TABLE product_units
ADD current_quantity INT;

Then, using UPDATE, change the current_quantity equal to the last quantity value from the vendor_inventory details.

HINT: This one is pretty hard. 
First, determine how to get the "last" quantity per product. 
Second, coalesce null values to 0 (if you don't have null values, figure out how to rearrange your query so you do.) 
Third, SET current_quantity = (...your select statement...), remembering that WHERE can only accommodate one column. 
Finally, make sure you have a WHERE statement to update the right row, 
	you'll need to use product_units.product_id to refer to the correct row within the product_units table. 
When you have all of these components, you can run the update statement. */

WITH current_quantity as
(
	SELECT
	product_id
	,quantity
	FROM (
		SELECT *
		,RANK()OVER (PARTITION BY product_id ORDER BY market_date DESC) as Rank
		FROM vendor_inventory
		GROUP BY product_id, market_date
	) x
	WHERE x.Rank = 1
)

UPDATE product_units
SET current_quantity = COALESCE((
	SELECT quantity
	FROM current_quantity
	WHERE current_quantity.product_id = product_units.product_id
),0);

SELECT * FROM product_units
