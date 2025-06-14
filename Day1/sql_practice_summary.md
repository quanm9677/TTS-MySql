
# 🧩 Bài Thực Hành SQL – Tổng Hợp Lệnh và Giải Thích

## 📂 Cấu trúc dữ liệu

### Bảng: Customers
| customer_id | name         | city         | email                 |
|-------------|--------------|--------------|------------------------|
| 1           | Nguyen An    | Hanoi        | an.nguyen@email.com   |
| 2           | Tran Binh    | Ho Chi Minh  | NULL                  |
| 3           | Le Cuong     | Da Nang      | cuong.le@email.com    |
| 4           | Hoang Duong  | Hanoi        | duong.hoang@email.com |

### Bảng: Orders
| order_id | customer_id | order_date | total_amount |
|----------|-------------|------------|--------------|
| 101      | 1           | 2023-01-15 | 500000       |
| 102      | 3           | 2023-02-10 | 800000       |
| 103      | 2           | 2023-03-05 | 300000       |
| 104      | 1           | 2023-04-01 | 450000       |

### Bảng: Products
| product_id | name            | price      |
|------------|-----------------|------------|
| 1          | Laptop Dell     | 15000000   |
| 2          | Mouse Logitech  | 300000     |
| 3          | Keyboard Razer  | 1200000    |
| 4          | Laptop HP       | 14000000   |

---

## 🎯 Các Truy Vấn SQL và Giải Thích

### 1. Khách hàng ở Hà Nội
```sql
SELECT * FROM Customers
WHERE city = 'Hanoi';
```
> Chọn tất cả khách hàng có city là 'Hanoi'.

---

### 2. Đơn hàng > 400.000 và sau 31/01/2023
```sql
SELECT * FROM Orders
WHERE total_amount > 400000
  AND order_date > '2023-01-31';
```
> Lọc đơn hàng theo điều kiện về số tiền và thời gian.

---

### 3. Khách hàng không có email
```sql
SELECT * FROM Customers
WHERE email IS NULL;
```
> Lọc những dòng có giá trị email là NULL.

---

### 4. Đơn hàng sắp xếp giảm dần theo tổng tiền
```sql
SELECT * FROM Orders
ORDER BY total_amount DESC;
```
> Sắp xếp đơn hàng từ cao đến thấp.

---

### 5. Thêm khách hàng mới
```sql
INSERT INTO Customers (customer_id, name, city, email)
VALUES (5, 'Pham Thanh', 'Can Tho', NULL);
```
> Thêm khách hàng không có email.

---

### 6. Cập nhật email khách hàng mã 2
```sql
UPDATE Customers
SET email = 'binh.tran@email.com'
WHERE customer_id = 2;
```
> Cập nhật dữ liệu cụ thể cho khách hàng.

---

### 7. Xoá đơn hàng mã 103
```sql
DELETE FROM Orders
WHERE order_id = 103;
```
> Xoá dòng cụ thể trong bảng Orders.

---

### 8. Lấy 2 khách hàng đầu tiên
```sql
SELECT * FROM Customers
LIMIT 2;
```
> Giới hạn số dòng trả về.

---

### 9. Đơn hàng lớn nhất và nhỏ nhất
```sql
SELECT MAX(total_amount) AS MaxOrder, MIN(total_amount) AS MinOrder
FROM Orders;
```
> Dùng hàm tổng hợp để tìm giá trị cực trị.

---

### 10. Tổng số đơn hàng, tổng tiền, trung bình đơn hàng
```sql
SELECT 
  COUNT(*) AS TotalOrders,
  SUM(total_amount) AS TotalRevenue,
  AVG(total_amount) AS AvgOrderValue
FROM Orders;
```
> Thống kê số lượng, tổng tiền và giá trị trung bình.

---

### 11. Sản phẩm bắt đầu bằng “Laptop”
```sql
SELECT * FROM Products
WHERE name LIKE 'Laptop%';
```
> Dùng LIKE với ký tự % để tìm tên sản phẩm theo mẫu.

---

## 📘 Giải thích về RDBMS

**RDBMS (Relational Database Management System)** là hệ quản trị cơ sở dữ liệu quan hệ, nơi dữ liệu được lưu trữ trong các bảng có liên quan với nhau qua:

- **Primary Key (Khóa chính)**: Định danh duy nhất từng dòng.
- **Foreign Key (Khóa ngoại)**: Tạo quan hệ giữa các bảng.

**Lợi ích**:
- Dữ liệu nhất quán
- Truy vấn hiệu quả
- Giảm trùng lặp
- Dễ bảo trì và mở rộng

