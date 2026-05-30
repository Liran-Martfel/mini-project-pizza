DROP TABLE drinks_order;
DROP TABLE pizza_size;
DROP TABLE pizzas;
DROP TABLE drinks;
DROP TABLE orders;
DROP TABLE clients;
DROP TABLE pizza_toppings;
DROP TABLE toppings;
DROP TABLE menu;

-------------------------------------------------------------
-------------------------------------------------------------

-- menu table serves as the public-facing price list.
-- drinks, pizza_size and toppings maintain their own prices
-- for internal use and historical price tracking.

-------------------------------------------------------------
-------------------------------------------------------------

CREATE TABLE clients
(
	client_id INTEGER PRIMARY KEY AUTOINCREMENT,
	phone TEXT UNIQUE,
	email TEXT,
	first_name TEXT NOT NULL,
	last_name TEXT NOT NULL
);

CREATE TABLE orders
(
	order_id INTEGER PRIMARY KEY AUTOINCREMENT,
	client_id INTEGER NOT NULL,
	when_was_ordered datetime,
	was_delivered datetime,
	take_away boolean DEFAULT 0, --0 is not take away
	online_ordering boolean DEFAULT 0, --0 is ordering in store
	FOREIGN KEY (client_id) REFERENCES clients (client_id) ON DELETE RESTRICT
);

CREATE TABLE drinks
(
	drink_id INTEGER PRIMARY KEY AUTOINCREMENT,
	drink_name TEXT NOT NULL,
	drink_price REAL,
	menu_id INTEGER,
	FOREIGN KEY (menu_id) REFERENCES menu(item_id)
);

CREATE TABLE drinks_order
(
	drink_id INTEGER,
	order_id INTEGER,
	qty INTEGER,
	price_at_time REAL NOT NULL,
	PRIMARY KEY(order_id,drink_id),
	FOREIGN KEY (order_id) REFERENCES orders (order_id) ON DELETE CASCADE,
	FOREIGN KEY (drink_id) REFERENCES drinks (drink_id) ON DELETE CASCADE
);

CREATE TABLE pizzas
(
	pizza_id INTEGER PRIMARY KEY AUTOINCREMENT,
	pizza_size_id INTEGER,
	order_id INTEGER NOT NULL,
	menu_id INTEGER,
	stuffed_crust INTEGER NOT NULL DEFAULT 0, -- 0 is not stuffed
	price_at_time REAL NOT NULL,
	FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE RESTRICT,
	FOREIGN KEY (pizza_size_id) REFERENCES pizza_size(pizza_size_id),
	FOREIGN KEY (menu_id) REFERENCES menu(item_id)
);

CREATE TABLE pizza_size
(
	pizza_size_id INTEGER PRIMARY KEY AUTOINCREMENT,
	size TEXT NOT NULL UNIQUE,
	size_price REAL NOT NULL
);

CREATE TABLE toppings
(
	topping_id INTEGER PRIMARY KEY AUTOINCREMENT,
	topping_name TEXT NOT NULL,
	topping_price REAL
);

CREATE TABLE pizza_toppings
(
	topping_id INTEGER,
	pizza_id INTEGER,
	price_at_time REAL NOT NULL,
	PRIMARY KEY (topping_id,pizza_id),
	FOREIGN KEY (pizza_id) REFERENCES pizzas (pizza_id) ON DELETE CASCADE,
	FOREIGN KEY (topping_id) REFERENCES toppings (topping_id) ON DELETE CASCADE
);

CREATE TABLE menu
(
	item_id INTEGER PRIMARY KEY AUTOINCREMENT,
	item_type TEXT NOT NULL,
	item_name TEXT NOT NULL UNIQUE,
	price REAL NOT NULL
);

INSERT INTO menu (item_type, item_name, price)
VALUES
('pizza', 'small pizza', 40),
('pizza', 'medium pizza', 50),
('pizza', 'large pizza', 65),
('pizza', 'extra large pizza', 80),
('topping', 'onion', 3.5),
('topping', 'olives', 3.5),
('topping', 'tuna', 4.5),
('topping', 'corn', 3.5),
('topping','Extra cheese',5.5),
('drink', 'water', 4),
('drink', 'grape juice', 6),
('drink', 'coca cola', 8);

INSERT INTO clients (phone,email,first_name,last_name)
VALUES 
('054-123-123','123@123gmail.com','avi','del'),
('054-4873-663','liran.martfel@gmail.com','Liran','Martfel'),
('054-2222-222','222@gmail.com','Ido','Brener'),
('050-6456-888','dana@gmail','Dana','Martfel');

INSERT INTO orders (client_id,when_was_ordered,was_delivered,take_away,online_ordering)
VALUES
(1,'2026-04-10 09:10:00','2026-04-10 11:10:00',0,0),
(2,'2026-03-20 18:40:00','2026-03-20 19:40:00',1,1),
(3,'2026-04-12 07:55:00','2026-04-12 08:30:00',1,0),
(4,'2026-04-12 07:55:00','2026-04-12 08:55:00',1,0);

INSERT INTO drinks (drink_name,drink_price,menu_id)
VALUES
('water',4,(SELECT item_id FROM menu WHERE item_name = 'water')),
('grape juice',6,(SELECT item_id FROM menu WHERE item_name = 'grape juice')),
('coca cola',8,(SELECT item_id FROM menu WHERE item_name = 'coca cola'));

INSERT INTO drinks_order (drink_id,order_id,qty,price_at_time)
VALUES
(1,1,1,(SELECT drink_price FROM drinks WHERE drink_id = 1)),
(2,1,1,(SELECT drink_price FROM drinks WHERE drink_id = 2)),
(3,2,1,(SELECT drink_price FROM drinks WHERE drink_id = 3)),
(2,3,2,(SELECT drink_price FROM drinks WHERE drink_id = 2)),
(1,4,2,(SELECT drink_price FROM drinks WHERE drink_id = 1));

INSERT INTO pizza_size (size,size_price)
VALUES
('small pizza',40),
('medium pizza',50),
('large pizza',65),
('extra large pizza',80);

INSERT INTO pizzas (order_id,pizza_size_id,menu_id,stuffed_crust,price_at_time)
VALUES
(1,1,(SELECT item_id FROM menu WHERE item_name = 'small pizza'),0,(SELECT size_price FROM pizza_size WHERE pizza_size_id = 1)),
(2,4,(SELECT item_id FROM menu WHERE item_name = 'extra large pizza'),1,(SELECT size_price FROM pizza_size WHERE pizza_size_id = 4)),
(3,2,(SELECT item_id FROM menu WHERE item_name = 'medium pizza'),0,(SELECT size_price FROM pizza_size WHERE pizza_size_id = 2)),
(4,4,(SELECT item_id FROM menu WHERE item_name = 'extra large pizza'),1,(SELECT size_price FROM pizza_size WHERE pizza_size_id = 4));

INSERT INTO toppings (topping_name,topping_id,topping_price)
VALUES
('onion',1,3.5),
('olives',2,3.5),
('tuna',3,4.5),
('corn',4,3.5),
('Extra cheese',5,5.5);

INSERT INTO pizza_toppings (topping_id,pizza_id,price_at_time)
VALUES
(1,1,(SELECT topping_price FROM toppings WHERE topping_id = 1)),
(2,1,(SELECT topping_price FROM toppings WHERE topping_id = 2)),
(5,2,(SELECT topping_price FROM toppings WHERE topping_id = 5)),
(3,3,(SELECT topping_price FROM toppings WHERE topping_id = 3)),
(3,2,(SELECT topping_price FROM toppings WHERE topping_id = 3)),
(5,4,(SELECT topping_price FROM toppings WHERE topping_id = 5)),
(3,4,(SELECT topping_price FROM toppings WHERE topping_id = 3)),
(4,4,(SELECT topping_price FROM toppings WHERE topping_id = 4));

--Get all clients with their full name and phone number:
SELECT
	first_name,
	last_name,
	phone AS customer_phone
FROM clients;

--Get all orders that were take-away and who took it,what he ordered
SELECT 
	o.order_id AS order_number,
	c.first_name,
	c.last_name,
	pz.size,
	coalesce(t.topping_name,'didnt order') AS topping_name,
	CASE
		WHEN take_away = 1 THEN 'to go'
			ELSE 'eating here'
	END AS order_type,
	CASE
		WHEN online_ordering = 1 THEN 'online'
			ELSE 'in store'
	END AS ordered_at
FROM orders o
LEFT JOIN clients c ON o.client_id = c.client_id
LEFT JOIN pizzas p ON o.order_id = p.order_id
LEFT JOIN pizza_size pz ON p.pizza_size_id = pz.pizza_size_id
LEFT JOIN pizza_toppings pt ON p.pizza_id = pt.pizza_id
LEFT JOIN toppings t ON pt.topping_id = t.topping_id
WHERE take_away = 1;

--show all items on the menu
SELECT *
FROM menu;

--showing total order+price for one person
SELECT 
	drink_name AS item,
	qty,
	d_o.price_at_time AS price
FROM drinks_order d_o 
	LEFT join orders o ON d_o.order_id = o.order_id 
	LEFT JOIN drinks d ON d.drink_id = d_o.drink_id
	LEFT join clients c ON c.client_id = o.client_id
	where first_name ='Liran' and last_name = 'Martfel'
UNION ALL

SELECT	
	topping_name AS item,
	COALESCE(NULL, 0) AS qty,
	pt.price_at_time AS price
FROM drinks_order d_o 
	LEFT join orders o ON d_o.order_id = o.order_id 
	LEFT JOIN pizzas p ON p.order_id = o.order_id 
	LEFT join pizza_toppings pt ON pt.pizza_id = p.pizza_id
	LEFT join toppings t ON t.topping_id = pt.topping_id
	LEFT join clients c ON c.client_id = o.client_id
	where first_name ='Liran' and last_name = 'Martfel'
UNION ALL	

SELECT
	size AS item,
	COALESCE(NULL, 0) AS qty,
	p.price_at_time AS price
FROM pizzas p 
	LEFT JOIN orders o ON p.order_id = o.order_id
	LEFT JOIN pizza_size pz ON pz.pizza_size_id = p.pizza_size_id
	LEFT join clients c ON c.client_id = o.client_id
	where first_name ='Liran' and last_name = 'Martfel'
UNION ALL

SELECT 'TOTAL' AS item, 0 AS qty, SUM(price) AS price
FROM
(
    SELECT d_o.price_at_time AS price
    FROM drinks_order d_o 
        LEFT JOIN orders o ON d_o.order_id = o.order_id 
        LEFT JOIN clients c ON c.client_id = o.client_id
        WHERE first_name ='Liran' AND last_name = 'Martfel'
    UNION ALL
    SELECT pt.price_at_time AS price
    FROM drinks_order d_o 
        LEFT JOIN orders o ON d_o.order_id = o.order_id 
        LEFT JOIN pizzas p ON p.order_id = o.order_id 
        LEFT JOIN pizza_toppings pt ON pt.pizza_id = p.pizza_id
        LEFT JOIN clients c ON c.client_id = o.client_id
        WHERE first_name ='Liran' AND last_name = 'Martfel'
    UNION ALL
    SELECT p.price_at_time AS price
    FROM pizzas p 
        LEFT JOIN orders o ON p.order_id = o.order_id
        LEFT JOIN clients c ON c.client_id = o.client_id
        WHERE first_name ='Liran' AND last_name = 'Martfel'
);

-- shows each order, when it was placed and when it was delivered and to who.
SELECT 
	first_name,
	last_name,
	when_was_ordered AS ordered,
	was_delivered AS delivered
FROM orders o
inner join clients c ON o.client_id = c.client_id;
