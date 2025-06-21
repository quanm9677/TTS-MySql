-- =============================================
-- 📂 Hệ thống Thương Mại Điện Tử - Tối Ưu Truy Vấn
-- =============================================

-- 1. Tạo Database và chọn DB
DROP DATABASE IF EXISTS ECommerceDB;
CREATE DATABASE ECommerceDB;
USE ECommerceDB;

-- 2. Tạo Bảng

CREATE TABLE Categories (
    category_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    category_id INT,
    price DECIMAL(12,0),
    stock_quantity INT,
    created_at DATETIME,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    order_date DATETIME,
    status VARCHAR(20)
);

CREATE TABLE OrderItems (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(12,0),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- 3. Thêm Dữ Liệu

INSERT INTO Categories (category_id, name) VALUES
(1, 'Electronics'),
(2, 'Books'),
(3, 'Clothing'),
(4, 'Home & Kitchen');

INSERT INTO Products (name, category_id, price, stock_quantity, created_at) VALUES
('Smartphone X', 1, 12000000, 50, '2025-05-10'),
('Bluetooth Headphones', 1, 1500000, 120, '2025-05-15'),
('LED TV 55"', 1, 15000000, 20, '2025-06-01'),
('Laptop Pro', 1, 25000000, 10, '2025-06-15'),
('Cookbook 101', 2, 250000, 200, '2025-03-20'),
('Fiction Novel', 2, 180000, 150, '2025-03-25'),
('Men T-Shirt', 3, 200000, 100, '2025-04-10'),
('Women Dress', 3, 350000, 80, '2025-04-12'),
('Blender 5-in-1', 4, 900000, 60, '2025-04-18'),
('Rice Cooker', 4, 1200000, 40, '2025-05-01');

INSERT INTO Orders (order_id, user_id, order_date, status) VALUES
(1001, 101, '2025-06-01', 'Shipped'),
(1002, 102, '2025-06-02', 'Pending'),
(1003, 103, '2025-06-03', 'Shipped'),
(1004, 104, '2025-06-10', 'Cancelled'),
(1005, 105, '2025-06-15', 'Shipped'),
(1006, 106, '2025-06-17', 'Shipped'),
(1007, 107, '2025-06-18', 'Pending');

INSERT INTO OrderItems (order_id, product_id, quantity, unit_price) VALUES
(1001, 1, 1, 12000000),
(1001, 2, 2, 1500000),
(1002, 5, 1, 250000),
(1003, 4, 1, 25000000),
(1003, 6, 3, 180000),
(1005, 3, 1, 15000000),
(1005, 7, 2, 200000),
(1006, 1, 2, 12000000),
(1006, 8, 1, 350000),
(1006, 9, 1, 900000),
(1004, 10, 1, 1200000);

-- 4. Tạo Index Tối Ưu Truy Vấn

CREATE INDEX idx_orders_status_orderdate ON Orders (status, order_date DESC);
CREATE INDEX idx_orders_orderdate ON Orders (order_date);
CREATE INDEX idx_orderitems_orderid_productid ON OrderItems (order_id, product_id);
CREATE INDEX idx_orderitems_productid ON OrderItems (product_id);
CREATE INDEX idx_products_category_created ON Products (category_id, created_at DESC);
CREATE INDEX idx_products_cover_cat3 ON Products (category_id, price ASC, product_id, name);

-- 5. Truy Vấn Tối Ưu Mẫu

-- 5.1 Truy vấn đơn hàng đã giao
EXPLAIN SELECT Orders.order_id, Orders.order_date, OrderItems.product_id, OrderItems.quantity, OrderItems.unit_price
FROM Orders
JOIN OrderItems ON Orders.order_id = OrderItems.order_id
WHERE Orders.status = 'Shipped'
ORDER BY Orders.order_date DESC;

-- 5.2 JOIN Products & Categories (so sánh subquery)
EXPLAIN SELECT p.product_id, p.name, c.name AS category_name
FROM Products p
JOIN Categories c ON p.category_id = c.category_id;

-- 5.3 Sản phẩm mới nhất danh mục Electronics, còn hàng
SELECT product_id, name, price, stock_quantity, created_at
FROM Products
WHERE category_id = (
    SELECT category_id FROM Categories WHERE name = 'Electronics'
)
AND stock_quantity > 0
ORDER BY created_at DESC
LIMIT 10;

-- 5.4 Covering Index – danh mục 3
EXPLAIN SELECT product_id, name, price
FROM Products
WHERE category_id = 3
ORDER BY price ASC
LIMIT 20;

-- 5.5 Doanh thu theo tháng
SELECT DATE_FORMAT(order_date, '%Y-%m') AS ym, SUM(oi.quantity * oi.unit_price) AS monthly_revenue
FROM Orders o
JOIN OrderItems oi ON o.order_id = oi.order_id
WHERE o.order_date >= '2025-01-01' AND o.order_date < '2026-01-01'
GROUP BY ym
ORDER BY ym;

-- 5.6 Truy vấn nhiều bước – sản phẩm đắt
WITH expensive_orders AS (
    SELECT DISTINCT o.order_id
    FROM Orders o
    JOIN OrderItems oi ON o.order_id = oi.order_id
    WHERE oi.unit_price > 1000000
)
SELECT SUM(oi.quantity) AS total_qty, COUNT(*) AS line_items
FROM expensive_orders eo
JOIN OrderItems oi ON eo.order_id = oi.order_id;

-- 5.7 Top 5 sản phẩm bán chạy nhất 30 ngày
SELECT oi.product_id, p.name, SUM(oi.quantity) AS sold_qty
FROM OrderItems oi
JOIN Orders o ON o.order_id = oi.order_id
JOIN Products p ON p.product_id = oi.product_id
WHERE o.order_date >= CURDATE() - INTERVAL 30 DAY
  AND o.status = 'Shipped'
GROUP BY oi.product_id, p.name
ORDER BY sold_qty DESC
LIMIT 5;
