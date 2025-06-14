
-- TẠO CƠ SỞ DỮ LIỆU VÀ CHUYỂN VÀO DB
CREATE DATABASE tts_mysql_day1;
USE tts_mysql_day1;

-- TẠO BẢNG CUSTOMERS
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(100),
    email VARCHAR(100)
);

-- TẠO BẢNG ORDERS
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount INT,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- TẠO BẢNG PRODUCTS
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    price INT
);

-- CHÈN DỮ LIỆU VÀO BẢNG CUSTOMERS
INSERT INTO Customers (customer_id, name, city, email) VALUES
(1, 'Nguyen An', 'Hanoi', 'an.nguyen@email.com'),
(2, 'Tran Binh', 'Ho Chi Minh', NULL),
(3, 'Le Cuong', 'Da Nang', 'cuong.le@email.com'),
(4, 'Hoang Duong', 'Hanoi', 'duong.hoang@email.com');

-- CHÈN DỮ LIỆU VÀO BẢNG ORDERS
INSERT INTO Orders (order_id, customer_id, order_date, total_amount) VALUES
(101, 1, '2023-01-15', 500000),
(102, 3, '2023-02-10', 800000),
(103, 2, '2023-03-05', 300000),
(104, 1, '2023-04-01', 450000);

-- CHÈN DỮ LIỆU VÀO BẢNG PRODUCTS
INSERT INTO Products (product_id, name, price) VALUES
(1, 'Laptop Dell', 15000000),
(2, 'Mouse Logitech', 300000),
(3, 'Keyboard Razer', 1200000),
(4, 'Laptop HP', 14000000);

-- TRUY VẤN: DANH SÁCH KHÁCH HÀNG TỪ HÀ NỘI
SELECT * FROM Customers
WHERE city = 'Hanoi';

-- TRUY VẤN: ĐƠN HÀNG > 400000 VÀ SAU 31/01/2023
SELECT * FROM Orders
WHERE total_amount > 400000
  AND order_date > '2023-01-31';

-- TRUY VẤN: KHÁCH HÀNG KHÔNG CÓ EMAIL
SELECT * FROM Customers
WHERE email IS NULL;

-- TRUY VẤN: ĐƠN HÀNG THEO GIÁ TRỊ GIẢM DẦN
SELECT * FROM Orders
ORDER BY total_amount DESC;

-- CHÈN KHÁCH HÀNG MỚI
INSERT INTO Customers (customer_id, name, city, email)
VALUES (6, 'Pham Thanh1', 'Can Tho1', NULL);


-- CẬP NHẬT EMAIL KHÁCH HÀNG ID = 2
UPDATE Customers
SET email = 'binh.tran@email.com'
WHERE customer_id = 2;

-- XOÁ ĐƠN HÀNG MÃ 103
DELETE FROM Orders
WHERE order_id = 103;

-- LẤY 2 KHÁCH HÀNG ĐẦU TIÊN
SELECT * FROM Customers
LIMIT 2;

-- ĐƠN HÀNG GIÁ TRỊ CAO NHẤT & THẤP NHẤT
SELECT MAX(total_amount) AS MaxOrder, MIN(total_amount) AS MinOrder
FROM Orders;

-- TỔNG SỐ ĐƠN, TỔNG TIỀN, GIÁ TRỊ TRUNG BÌNH
SELECT 
  COUNT(*) AS TotalOrders,
  SUM(total_amount) AS TotalRevenue,
  AVG(total_amount) AS AvgOrderValue
FROM Orders;

-- TÌM SẢN PHẨM BẮT ĐẦU BẰNG 'Laptop'
SELECT * FROM Products
WHERE name LIKE 'Laptop%';
