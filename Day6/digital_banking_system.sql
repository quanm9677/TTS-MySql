-- ===========================================
-- 🏦 DIGITAL BANKING SYSTEM - FULL SETUP
-- ===========================================

-- 1.  Create Database
CREATE DATABASE DigitalBanking;
USE DigitalBanking;

-- 2. Create Accounts Table (InnoDB)
CREATE TABLE Accounts (
    account_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100),
    balance DECIMAL(15,2),
    status VARCHAR(20) CHECK (status IN ('Active', 'Frozen', 'Closed'))
) ENGINE = InnoDB;

-- 3. Create Transactions Table (InnoDB)
CREATE TABLE Transactions (
    txn_id INT PRIMARY KEY AUTO_INCREMENT,
    from_account INT,
    to_account INT,
    amount DECIMAL(15,2),
    txn_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) CHECK (status IN ('Success', 'Failed', 'Pending')),
    FOREIGN KEY (from_account) REFERENCES Accounts(account_id),
    FOREIGN KEY (to_account) REFERENCES Accounts(account_id)
) ENGINE = InnoDB;

-- 4. Create TxnAuditLogs Table (MyISAM)
CREATE TABLE TxnAuditLogs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    description TEXT,
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = MyISAM;

-- 5. Create Referrals Table
CREATE TABLE Referrals (
    referrer_id INT,
    referee_id INT
);

-- 6. Sample Data
INSERT INTO Accounts (full_name, balance, status) VALUES
('Nguyen Van A', 1000000, 'Active'),
('Tran Thi B', 800000, 'Active'),
('Le Van C', 500000, 'Active'),
('Pham Thi D', 200000, 'Frozen'),
('Nguyen Van E', 0, 'Closed');

INSERT INTO Referrals (referrer_id, referee_id) VALUES
(1, 2),
(1, 3),
(2, 4),
(3, 5);

-- 7. Stored Procedure TransferMoney
DELIMITER $$

CREATE PROCEDURE TransferMoney(
    IN p_from_account INT,
    IN p_to_account INT,
    IN p_amount DECIMAL(15,2)
)
BEGIN
    DECLARE v_from_balance DECIMAL(15,2);
    DECLARE v_from_status VARCHAR(20);
    DECLARE v_to_status VARCHAR(20);
    DECLARE exit handler for SQLEXCEPTION
    BEGIN
        ROLLBACK;
        INSERT INTO TxnAuditLogs(description) 
        VALUES (CONCAT('FAILED transfer from ', p_from_account, ' to ', p_to_account, ' amount ', p_amount));
    END;

    START TRANSACTION;

    -- Lock rows to prevent deadlock
    SELECT balance, status INTO v_from_balance, v_from_status
    FROM Accounts WHERE account_id = p_from_account FOR UPDATE;

    SELECT status INTO v_to_status
    FROM Accounts WHERE account_id = p_to_account FOR UPDATE;

    IF v_from_status != 'Active' OR v_to_status != 'Active' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'One or both accounts are not active';
    END IF;

    IF v_from_balance < p_amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient funds';
    END IF;

    -- Debit and Credit
    UPDATE Accounts SET balance = balance - p_amount
    WHERE account_id = p_from_account;

    UPDATE Accounts SET balance = balance + p_amount
    WHERE account_id = p_to_account;

    -- Insert Transaction Record
    INSERT INTO Transactions(from_account, to_account, amount, status)
    VALUES (p_from_account, p_to_account, p_amount, 'Success');

    -- Insert Audit Log
    INSERT INTO TxnAuditLogs(description)
    VALUES (CONCAT('Transferred ', p_amount, ' from ', p_from_account, ' to ', p_to_account));

    COMMIT;
END$$

DELIMITER ;

-- 8. MVCC Demonstration Notes (manual steps)
-- -- SESSION 1:
-- SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- START TRANSACTION;
-- SELECT balance FROM Accounts WHERE account_id = 1;

-- -- SESSION 2:
-- CALL TransferMoney(1, 2, 100000);

-- -- SESSION 1:
-- SELECT balance FROM Accounts WHERE account_id = 1;
-- COMMIT;

-- 9. CTE Recursive - Find all referrals under account_id = 1
WITH RECURSIVE Downline(referrer_id, referee_id) AS (
    SELECT referrer_id, referee_id FROM Referrals WHERE referrer_id = 1
    UNION ALL
    SELECT r.referrer_id, r.referee_id
    FROM Referrals r
    JOIN Downline d ON r.referrer_id = d.referee_id
)
SELECT * FROM Downline;

-- 10. CTE Analytical - Classify Transactions by Amount
WITH AvgTxn AS (
    SELECT AVG(amount) AS avg_amount FROM Transactions
),
LabeledTxn AS (
    SELECT txn_id, from_account, to_account, amount, txn_date,
        CASE 
            WHEN amount > (SELECT avg_amount FROM AvgTxn) THEN 'High'
            WHEN amount = (SELECT avg_amount FROM AvgTxn) THEN 'Normal'
            ELSE 'Low'
        END AS amount_level
    FROM Transactions
)
SELECT * FROM LabeledTxn;

