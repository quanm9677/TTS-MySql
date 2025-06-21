
CREATE DATABASE HotelBooking;
USE HotelBooking;

-- 2. TẠO BẢNG

-- Bảng Rooms
CREATE TABLE Rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(10) UNIQUE,
    type VARCHAR(20),
    status VARCHAR(20) CHECK (status IN ('Available', 'Occupied', 'Maintenance')),
    price INT CHECK (price >= 0)
);

-- Bảng Guests
CREATE TABLE Guests (
    guest_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100),
    phone VARCHAR(20)
);

-- Bảng Bookings
CREATE TABLE Bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    guest_id INT,
    room_id INT,
    check_in DATE,
    check_out DATE,
    status VARCHAR(20) CHECK (status IN ('Pending', 'Confirmed', 'Cancelled')),
    FOREIGN KEY (guest_id) REFERENCES Guests(guest_id),
    FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
);

-- Bảng Invoices (Bonus)
CREATE TABLE Invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT,
    total_amount INT,
    generated_date DATE,
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);

-- 3. DỮ LIỆU MẪU

INSERT INTO Rooms (room_number, type, status, price) VALUES
('101', 'Standard', 'Available', 500000),
('102', 'VIP', 'Available', 1000000),
('103', 'Suite', 'Maintenance', 2000000);

INSERT INTO Guests (full_name, phone) VALUES
('Nguyen Van A', '0901234567'),
('Tran Thi B', '0909876543');

INSERT INTO Bookings (guest_id, room_id, check_in, check_out, status) VALUES
(1, 1, '2025-06-25', '2025-06-27', 'Confirmed');

-- 4. STORED PROCEDURE: MakeBooking

DELIMITER $$

CREATE PROCEDURE MakeBooking(
    IN p_guest_id INT,
    IN p_room_id INT,
    IN p_check_in DATE,
    IN p_check_out DATE
)
BEGIN
    DECLARE room_status VARCHAR(20);
    DECLARE conflict_count INT;

    -- Kiểm tra tình trạng phòng
    SELECT status INTO room_status
    FROM Rooms
    WHERE room_id = p_room_id;

    IF room_status <> 'Available' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Phòng hiện không sẵn sàng.';
    END IF;

    -- Kiểm tra trùng lịch
    SELECT COUNT(*) INTO conflict_count
    FROM Bookings
    WHERE room_id = p_room_id
      AND status = 'Confirmed'
      AND (
           p_check_in < check_out AND p_check_out > check_in
      );

    IF conflict_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Phòng đã có người đặt trong khoảng thời gian này.';
    END IF;

    -- Thêm booking & cập nhật trạng thái phòng
    INSERT INTO Bookings(guest_id, room_id, check_in, check_out, status)
    VALUES (p_guest_id, p_room_id, p_check_in, p_check_out, 'Confirmed');

    UPDATE Rooms
    SET status = 'Occupied'
    WHERE room_id = p_room_id;
END$$

DELIMITER ;

-- 5. TRIGGER: after_booking_cancel

DELIMITER $$

CREATE TRIGGER after_booking_cancel
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
    IF NEW.status = 'Cancelled' THEN
        DECLARE future_booking_count INT;

        SELECT COUNT(*) INTO future_booking_count
        FROM Bookings
        WHERE room_id = NEW.room_id
          AND status = 'Confirmed'
          AND check_in > CURDATE();

        IF future_booking_count = 0 THEN
            UPDATE Rooms
            SET status = 'Available'
            WHERE room_id = NEW.room_id;
        END IF;
    END IF;
END$$

DELIMITER ;

-- 6. BONUS PROCEDURE: GenerateInvoice

DELIMITER $$

CREATE PROCEDURE GenerateInvoice(
    IN p_booking_id INT
)
BEGIN
    DECLARE stay_nights INT;
    DECLARE price_per_night INT;
    DECLARE total_price INT;
    DECLARE check_in_date DATE;
    DECLARE check_out_date DATE;
    DECLARE room_id_val INT;

    -- Lấy thông tin đặt phòng
    SELECT check_in, check_out, room_id INTO check_in_date, check_out_date, room_id_val
    FROM Bookings
    WHERE booking_id = p_booking_id;

    -- Tính số đêm
    SET stay_nights = DATEDIFF(check_out_date, check_in_date);

    -- Giá phòng
    SELECT price INTO price_per_night
    FROM Rooms
    WHERE room_id = room_id_val;

    -- Tổng tiền
    SET total_price = stay_nights * price_per_night;

    -- Tạo hóa đơn
    INSERT INTO Invoices(booking_id, total_amount, generated_date)
    VALUES (p_booking_id, total_price, CURDATE());
END$$

DELIMITER ;

-- 7. TEST PROCEDURES & TRIGGERS (GỢI Ý SỬ DỤNG)

-- Gọi thủ tục đặt phòng
-- CALL MakeBooking(2, 2, '2025-07-01', '2025-07-03');

-- Hủy đặt phòng để test trigger
-- UPDATE Bookings SET status = 'Cancelled' WHERE booking_id = 1;

-- Tạo hóa đơn cho booking_id = 2
-- CALL GenerateInvoice(2);

-- Xem hóa đơn
-- SELECT * FROM Invoices;

