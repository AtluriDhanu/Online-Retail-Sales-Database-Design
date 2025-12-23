CREATE DATABASE OnlineRetailSales_db;
USE OnlineRetailSales_db;

CREATE TABLE Products (
product_id INT PRIMARY KEY,
product_name VARCHAR(100) NOT NULL,
category VARCHAR(50),
price DECIMAL(10,2) NOT NULL
);

CREATE TABLE Customers (
customer_id INT PRIMARY KEY,
customer_name VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE,
phone VARCHAR(15)
);

CREATE TABLE Orders (
order_id INT PRIMARY KEY,
customer_id INT NOT NULL,
order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Order_Items (
order_item_id INT PRIMARY KEY,
order_id INT NOT NULL,
product_id INT NOT NULL,
quantity INT NOT NULL,
unit_price DECIMAL(10,2) NOT NULL,
FOREIGN KEY (order_id) REFERENCES Orders(order_id),
FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

CREATE TABLE Payments (
payment_id INT PRIMARY KEY,
order_id INT NOT NULL,
payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
amount DECIMAL(10,2) NOT NULL,
payment_method VARCHAR(50),
FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

INSERT INTO Products VALUES
(1, 'Laptop', 'Electronics', 55000),
(2, 'Mobile Phone', 'Electronics', 20000),
(3, 'Headphones', 'Accessories', 1500);

INSERT INTO Customers VALUES
(101, 'Benny', 'benny@gmail.com', '9876543210'),
(102, 'Rock', 'rock@gmail.com', '9876512345');

INSERT INTO Orders VALUES
(5001, 101, NOW()),
(5002, 102, NOW());

INSERT INTO Order_Items VALUES
(1, 5001, 1, 1, 55000),
(2, 5001, 3, 2, 1500),
(3, 5002, 2, 1, 20000);

INSERT INTO Payments VALUES
(9001, 5001, NOW(), 58000, 'UPI'),
(9002, 5002, NOW(), 20000, 'Card');

CREATE TABLE Inventory (
product_id INT PRIMARY KEY,
stock_quantity INT NOT NULL,
last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

INSERT INTO Inventory VALUES
(1, 10, NOW()),
(2, 15, NOW()),
(3, 30, NOW());

DELIMITER $$
CREATE TRIGGER reduce_stock_after_order
AFTER INSERT ON Order_Items
FOR EACH ROW
BEGIN
    UPDATE Inventory
    SET stock_quantity = stock_quantity - NEW.quantity,
        last_updated = CURRENT_TIMESTAMP
    WHERE product_id = NEW.product_id;
END $$
DELIMITER ;

SELECT p.product_name, i.stock_quantity 
FROM Products p
JOIN Inventory i ON p.product_id = i.product_id
WHERE i.stock_quantity < 5;

SELECT 
    o.order_id,
    c.customer_name,
    SUM(oi.quantity * oi.unit_price) AS total_amount,
    o.order_date
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Order_Items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, c.customer_name, o.order_date;

CREATE VIEW daily_sales AS
SELECT 
    DATE(o.order_date) AS sales_date,
    SUM(oi.quantity * oi.unit_price) AS total_sales,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM Orders o
JOIN Order_Items oi ON o.order_id = oi.order_id
GROUP BY DATE(o.order_date)
ORDER BY sales_date;
