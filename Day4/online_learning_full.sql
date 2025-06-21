-- XÓA DATABASE NẾU ĐÃ TỒN TẠI
DROP DATABASE IF EXISTS OnlineLearning;

-- TẠO DATABASE MỚI
CREATE DATABASE OnlineLearning;

-- SỬ DỤNG DATABASE
USE OnlineLearning;

-- TẠO BẢNG Students
CREATE TABLE Students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    join_date DATE DEFAULT CURRENT_DATE
);

-- TẠO BẢNG Courses
CREATE TABLE Courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    price INT CHECK (price >= 0)
);

-- TẠO BẢNG Enrollments
CREATE TABLE Enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    course_id INT,
    enroll_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

-- THÊM CỘT status VÀO Enrollments
ALTER TABLE Enrollments
ADD status VARCHAR(20) DEFAULT 'active';

-- TẠO VIEW StudentCourseView
CREATE VIEW StudentCourseView AS
SELECT 
    s.student_id,
    s.full_name,
    c.course_id,
    c.title AS course_title,
    e.enroll_date,
    e.status
FROM Enrollments e
JOIN Students s ON e.student_id = s.student_id
JOIN Courses c ON e.course_id = c.course_id;

-- TẠO INDEX TRÊN title CỦA Courses
CREATE INDEX idx_course_title ON Courses(title);

-- CHÈN DỮ LIỆU MẪU VÀO Students
INSERT INTO Students (full_name, email)
VALUES 
('Nguyen Van A', 'a@gmail.com'),
('Tran Thi B', 'b@gmail.com'),
('Le Van C', 'c@gmail.com');

-- CHÈN DỮ LIỆU MẪU VÀO Courses
INSERT INTO Courses (title, description, price)
VALUES
('Python for Beginners', 'Learn Python from scratch', 100),
('Web Development', 'Build modern web apps', 200),
('Data Science 101', 'Intro to data science', 150);

-- CHÈN DỮ LIỆU MẪU VÀO Enrollments
INSERT INTO Enrollments (student_id, course_id)
VALUES
(1, 1),
(2, 2),
(3, 3),
(1, 3);

-- (TÙY CHỌN) XÓA BẢNG Enrollments NẾU CẦN
DROP TABLE IF EXISTS Enrollments;
