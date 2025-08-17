-- =========================================================
-- 📚 Library Management System (SQL Project)
-- Author: Your Name
-- Description: A sample SQL project for managing books,
--              members, and borrow/return transactions.
-- =========================================================

-- Drop tables if they exist (for re-run safety)
DROP TABLE IF EXISTS BorrowRecords;
DROP TABLE IF EXISTS Books;
DROP TABLE IF EXISTS Members;

-- ========================
-- 1. Create Tables
-- ========================

CREATE TABLE Members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    join_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100),
    category VARCHAR(50),
    available BOOLEAN DEFAULT TRUE
);

CREATE TABLE BorrowRecords (
    record_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    book_id INT,
    borrow_date DATE DEFAULT CURRENT_DATE,
    return_date DATE,
    FOREIGN KEY (member_id) REFERENCES Members(member_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
);

-- ========================
-- 2. Insert Sample Data
-- ========================

-- Members
INSERT INTO Members (name, email) VALUES
('Alice Johnson', 'alice@example.com'),
('Bob Smith', 'bob@example.com'),
('Charlie Brown', 'charlie@example.com');

-- Books
INSERT INTO Books (title, author, category) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', 'Fiction'),
('To Kill a Mockingbird', 'Harper Lee', 'Fiction'),
('A Brief History of Time', 'Stephen Hawking', 'Science'),
('The Art of Computer Programming', 'Donald Knuth', 'Computer Science');

-- Borrow Records
INSERT INTO BorrowRecords (member_id, book_id, borrow_date) VALUES
(1, 1, '2025-08-01'),
(2, 3, '2025-08-02');

-- ========================
-- 3. Useful Queries
-- ========================

-- List all books
SELECT * FROM Books;

-- Find all available books
SELECT title, author FROM Books WHERE available = TRUE;

-- Show all members who borrowed books
SELECT m.name, b.title, r.borrow_date
FROM BorrowRecords r
JOIN Members m ON r.member_id = m.member_id
JOIN Books b ON r.book_id = b.book_id;

-- Count how many books each member borrowed
SELECT m.name, COUNT(r.record_id) AS books_borrowed
FROM Members m
LEFT JOIN BorrowRecords r ON m.member_id = r.member_id
GROUP BY m.name;

-- ========================
-- 4. Advanced Features
-- ========================

-- Create a view for borrowed book details
CREATE VIEW BorrowedBooks AS
SELECT r.record_id, m.name AS member_name, b.title AS book_title, r.borrow_date, r.return_date
FROM BorrowRecords r
JOIN Members m ON r.member_id = m.member_id
JOIN Books b ON r.book_id = b.book_id;

-- Create a trigger to mark book unavailable after borrow
DELIMITER //
CREATE TRIGGER after_borrow
AFTER INSERT ON BorrowRecords
FOR EACH ROW
BEGIN
    UPDATE Books SET available = FALSE WHERE book_id = NEW.book_id;
END;
//
DELIMITER ;

-- Create a procedure to return a book
DELIMITER //
CREATE PROCEDURE return_book(IN p_record_id INT)
BEGIN
    UPDATE BorrowRecords SET return_date = CURRENT_DATE WHERE record_id = p_record_id;
    UPDATE Books 
    SET available = TRUE 
    WHERE book_id = (SELECT book_id FROM BorrowRecords WHERE record_id = p_record_id);
END;
//
DELIMITER ;

-- ========================
-- 5. Test Stored Procedure
-- ========================

-- Call procedure to return book with record_id = 1
CALL return_book(1);

-- Check borrow records after return
SELECT * FROM BorrowRecords;

-- Check book availability after return
SELECT * FROM Books;
