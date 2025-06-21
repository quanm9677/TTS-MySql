-- ============================
-- 🏗️ TẠO BẢNG
-- ============================

CREATE TABLE Candidates (
    candidate_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    years_exp INT,
    expected_salary INT
);

CREATE TABLE Jobs (
    job_id INT PRIMARY KEY,
    title VARCHAR(100),
    department VARCHAR(50),
    min_salary INT,
    max_salary INT
);

CREATE TABLE Applications (
    app_id INT PRIMARY KEY,
    candidate_id INT,
    job_id INT,
    apply_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (candidate_id) REFERENCES Candidates(candidate_id),
    FOREIGN KEY (job_id) REFERENCES Jobs(job_id)
);

CREATE TABLE ShortlistedCandidates (
    candidate_id INT,
    job_id INT,
    selection_date DATE
);

-- ============================
-- 📥 DỮ LIỆU MẪU
-- ============================

INSERT INTO Candidates VALUES 
(1, 'Nguyen Van A', 'a@gmail.com', '0911111111', 0, 500),
(2, 'Tran Thi B', 'b@gmail.com', NULL, 2, 800),
(3, 'Le Van C', 'c@gmail.com', '0922222222', 4, 1200),
(4, 'Pham Thi D', 'd@gmail.com', '0933333333', 7, 1500);

INSERT INTO Jobs VALUES 
(101, 'Backend Developer', 'IT', 1000, 2000),
(102, 'HR Specialist', 'HR', 800, 1200),
(103, 'Data Analyst', 'IT', 900, 1600),
(104, 'Accountant', 'Finance', 700, 1000),
(105, 'System Admin', 'IT', 1200, 1800);

INSERT INTO Applications VALUES 
(1001, 1, 101, '2024-01-10', 'Pending'),
(1002, 2, 102, '2024-01-11', 'Accepted'),
(1003, 3, 103, '2024-01-12', 'Rejected'),
(1004, 4, 101, '2024-01-13', 'Accepted'),
(1005, 3, 105, '2024-01-14', 'Accepted');

-- ============================
-- 1️⃣ EXISTS – Ứng viên ứng tuyển vào công việc IT
-- ============================

-- Lấy tất cả ứng viên đã từng nộp hồ sơ vào công việc thuộc phòng IT
-- Dùng EXISTS để kiểm tra sự tồn tại hồ sơ phù hợp trong bảng Applications và Jobs

SELECT *
FROM Candidates c
WHERE EXISTS (
    SELECT 1
    FROM Applications a
    JOIN Jobs j ON a.job_id = j.job_id
    WHERE a.candidate_id = c.candidate_id AND j.department = 'IT'
);

-- ============================
-- 2️⃣ ANY – Công việc có lương tối đa lớn hơn lương mong đợi của ít nhất một ứng viên
-- ============================

SELECT *
FROM Jobs
WHERE max_salary > ANY (
    SELECT expected_salary FROM Candidates
);

-- ============================
-- 3️⃣ ALL – Công việc có lương tối thiểu lớn hơn lương mong đợi của tất cả ứng viên
-- ============================

SELECT *
FROM Jobs
WHERE min_salary > ALL (
    SELECT expected_salary FROM Candidates
);

-- ============================
-- 4️⃣ INSERT SELECT – Chèn vào ShortlistedCandidates từ các ứng viên được chấp nhận
-- ============================

-- Lấy các ứng viên có status = 'Accepted' và chèn vào bảng Shortlisted
-- selection_date sẽ lấy ngày hiện tại bằng CURRENT_DATE()

INSERT INTO ShortlistedCandidates (candidate_id, job_id, selection_date)
SELECT candidate_id, job_id, CURRENT_DATE()
FROM Applications
WHERE status = 'Accepted';

-- ============================
-- 5️⃣ CASE – Hiển thị mức độ kinh nghiệm theo số năm
-- ============================

-- Phân loại kinh nghiệm thành Fresher, Junior, Mid-level, Senior bằng CASE

SELECT 
    full_name,
    years_exp,
    CASE 
        WHEN years_exp < 1 THEN 'Fresher'
        WHEN years_exp BETWEEN 1 AND 3 THEN 'Junior'
        WHEN years_exp BETWEEN 4 AND 6 THEN 'Mid-level'
        ELSE 'Senior'
    END AS experience_level
FROM Candidates;

-- ============================
-- 6️⃣ COALESCE – Thay thế giá trị NULL của số điện thoại
-- ============================

-- Nếu phone bị NULL thì hiển thị 'Chưa cung cấp'

SELECT 
    full_name,
    COALESCE(phone, 'Chưa cung cấp') AS phone
FROM Candidates;

-- ============================
-- 7️⃣ Điều kiện kết hợp – Tìm công việc có max_salary ≠ min_salary và ≥ 1000
-- ============================

SELECT *
FROM Jobs
WHERE max_salary != min_salary AND max_salary >= 1000;

