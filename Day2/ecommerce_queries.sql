
-- 1. Doanh thu theo danh mục
SELECT p.category, SUM(oi.quantity * p.price) AS revenue
FROM Orders o
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
WHERE o.status = 'completed'
GROUP BY p.category;

-- 2. Danh sách người dùng + tên người giới thiệu
SELECT u.user_id, u.full_name, r.full_name AS referrer_name
FROM Users u
LEFT JOIN Users r ON u.referrer_id = r.user_id;

-- 3. Sản phẩm đã từng được mua nhưng hiện tại không active
SELECT DISTINCT p.product_id, p.product_name
FROM OrderItems oi
JOIN Products p ON oi.product_id = p.product_id
WHERE p.is_active = 0;

-- 4. Người dùng chưa từng đặt đơn hàng nào
SELECT u.user_id, u.full_name
FROM Users u
LEFT JOIN Orders o ON u.user_id = o.user_id
WHERE o.order_id IS NULL;

-- 5. Đơn hàng đầu tiên của mỗi người dùng
SELECT o.user_id, MIN(o.order_date) AS first_order_date
FROM Orders o
GROUP BY o.user_id;

-- 6. Tổng chi tiêu của từng người dùng (chỉ tính đơn completed)
SELECT u.user_id, u.full_name, SUM(oi.quantity * p.price) AS total_spent
FROM Users u
JOIN Orders o ON u.user_id = o.user_id
JOIN OrderItems oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id
WHERE o.status = 'completed'
GROUP BY u.user_id, u.full_name;

-- 7. Người dùng có tổng chi tiêu > 25 triệu
SELECT user_id, full_name, total_spent
FROM (
  SELECT u.user_id, u.full_name, SUM(oi.quantity * p.price) AS total_spent
  FROM Users u
  JOIN Orders o ON u.user_id = o.user_id
  JOIN OrderItems oi ON o.order_id = oi.order_id
  JOIN Products p ON oi.product_id = p.product_id
  WHERE o.status = 'completed'
  GROUP BY u.user_id, u.full_name
) AS spending
WHERE total_spent > 25000000;

-- 8. Tổng đơn hàng và doanh thu theo thành phố
SELECT u.city,
       COUNT(DISTINCT o.order_id) AS total_orders,
       SUM(CASE WHEN o.status = 'completed' THEN oi.quantity * p.price ELSE 0 END) AS total_revenue
FROM Users u
LEFT JOIN Orders o ON u.user_id = o.user_id
LEFT JOIN OrderItems oi ON o.order_id = oi.order_id
LEFT JOIN Products p ON oi.product_id = p.product_id
GROUP BY u.city;

-- 9. Người dùng có ít nhất 2 đơn completed
SELECT o.user_id, u.full_name, COUNT(*) AS completed_orders
FROM Orders o
JOIN Users u ON o.user_id = u.user_id
WHERE o.status = 'completed'
GROUP BY o.user_id
HAVING COUNT(*) >= 2;

-- 10. Đơn hàng có sản phẩm từ nhiều danh mục
SELECT oi.order_id
FROM OrderItems oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY oi.order_id
HAVING COUNT(DISTINCT p.category) > 1;

-- 11. UNION người đã đặt hàng và người được giới thiệu
SELECT DISTINCT u.user_id, u.full_name, 'placed_order' AS source
FROM Users u
JOIN Orders o ON u.user_id = o.user_id

UNION

SELECT u.user_id, u.full_name, 'referred' AS source
FROM Users u
WHERE u.referrer_id IS NOT NULL;
