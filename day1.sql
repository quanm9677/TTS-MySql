-- Câu 1: Khách hàng ở Hà Nội
SELECT * FROM Customers WHERE city = 'Hanoi';







-- Câu 2: Đơn hàng > 400000 và sau 31/01/2023
SELECT * FROM Orders
WHERE total_amount > 400000 AND order_date > '2023-01-31';

SELECT 1+1 AS test;

