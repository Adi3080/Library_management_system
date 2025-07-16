-- Authors Table
CREATE TABLE Authors (
    author_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Books Table
CREATE TABLE Books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author_id INT REFERENCES Authors(author_id),
    published_year INT
);

-- Members Table
CREATE TABLE Members (
    member_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    join_date DATE DEFAULT CURRENT_DATE
);

-- Loans Table
CREATE TABLE Loans (
    loan_id SERIAL PRIMARY KEY,
    book_id INT REFERENCES Books(book_id),
    member_id INT REFERENCES Members(member_id),
    loan_date DATE DEFAULT CURRENT_DATE,
    due_date DATE,
    return_date DATE
);


-- Insert Authors
INSERT INTO Authors (name) VALUES 
('J.K. Rowling'), ('George Orwell'), ('J.R.R. Tolkien');

-- Insert Books
INSERT INTO Books (title, author_id, published_year) VALUES 
('Harry Potter', 1, 1997),
('1984', 2, 1949),
('The Hobbit', 3, 1937);

-- Insert Members
INSERT INTO Members (name, email) VALUES 
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com');

-- Insert Loans
INSERT INTO Loans (book_id, member_id, loan_date, due_date, return_date) VALUES 
(1, 1, '2025-07-01', '2025-07-10', NULL),
(2, 2, '2025-07-03', '2025-07-13', '2025-07-12');

-- BookAuthors bridge table
CREATE TABLE BookAuthors (
    book_id INT REFERENCES Books(book_id),
    author_id INT REFERENCES Authors(author_id),
    PRIMARY KEY (book_id, author_id)
);


-- Currently Borrowed Books
CREATE VIEW BorrowedBooks AS
SELECT 
    Loans.loan_id, Books.title, Members.name AS borrower, Loans.loan_date, Loans.due_date
FROM Loans
JOIN Books ON Loans.book_id = Books.book_id
JOIN Members ON Loans.member_id = Members.member_id
WHERE Loans.return_date IS NULL;

-- Overdue Books
CREATE VIEW OverdueBooks AS
SELECT * FROM BorrowedBooks
WHERE due_date < CURRENT_DATE;


-- Notification log table
CREATE TABLE Notifications (
    notification_id SERIAL PRIMARY KEY,
    message TEXT,
    notified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Drop the existing function if it exists
DROP FUNCTION IF EXISTS notify_due_date;

-- Corrected Trigger Function
CREATE OR REPLACE FUNCTION notify_due_date()
RETURNS TRIGGER AS $$
DECLARE
    book_title TEXT;
    member_name TEXT;
BEGIN
    -- Get the book title
    SELECT title INTO book_title FROM Books WHERE book_id = NEW.book_id;

    -- Get the member name
    SELECT name INTO member_name FROM Members WHERE member_id = NEW.member_id;

    -- Check if the due date is in the past
    IF NEW.due_date < CURRENT_DATE THEN
        INSERT INTO Notifications (message)
        VALUES (CONCAT('Book "', book_title, '" is overdue for member ', member_name));
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop the trigger if it already exists
DROP TRIGGER IF EXISTS trigger_due_date_notification ON Loans;

-- Create the trigger
CREATE TRIGGER trigger_due_date_notification
AFTER INSERT OR UPDATE ON Loans
FOR EACH ROW
WHEN (NEW.return_date IS NULL AND NEW.due_date < CURRENT_DATE)
EXECUTE FUNCTION notify_due_date();


-- Insert a loan that is already overdue (due_date < today and return_date IS NULL)
INSERT INTO Loans (book_id, member_id, loan_date, due_date, return_date)
VALUES (3, 1, CURRENT_DATE - 10, CURRENT_DATE - 5, NULL);


--  View all borrowed books (not yet returned)
SELECT * FROM BorrowedBooks;

--  View all overdue books
SELECT * FROM OverdueBooks;

--  Count of total books borrowed per member
SELECT 
    M.name AS member_name,
    COUNT(L.loan_id) AS total_loans
FROM Members M
JOIN Loans L ON M.member_id = L.member_id
GROUP BY M.name;

--  All notifications logged (from triggers)
SELECT * FROM Notifications;



