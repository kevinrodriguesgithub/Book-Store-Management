-- CREATE DATABASE BMS;

-- USE BMS;

CREATE TABLE Category (
	category_id INT PRIMARY KEY IDENTITY(1,1),
	category_name VARCHAR(255) NOT NULL,
	description VARCHAR(255) NOT NULL
)

CREATE TABLE Author(
	author_id INT PRIMARY KEY IDENTITY(1,1),
	author_first_name VARCHAR(50) NOT NULL,
	author_last_name VARCHAR(50) NOT NULL,
	initials CHAR(10) NOT NULL
)

CREATE TABLE Publisher (
    publisher_id INT PRIMARY KEY IDENTITY(1,1),
    publisher_name VARCHAR(255),
    publisher_city VARCHAR(255)
);

CREATE TABLE Employee (
    employee_id INT PRIMARY KEY IDENTITY(1,1),
    emp_first_name VARCHAR(255),
    emp_last_name VARCHAR(255),
    date_of_birth DATE,
    start_date DATE,
    salary DECIMAL(10, 2),
    schedule_time VARCHAR(255),
);

CREATE TABLE Inventory (
	inventory_id INT PRIMARY KEY IDENTITY(1,1),
	employee_id INT NOT NULL,
	CONSTRAINT Inventory_FK FOREIGN KEY(employee_id) REFERENCES Employee(employee_id)
)


CREATE TABLE Promotion (
    promotion_id INT PRIMARY KEY IDENTITY(1,1),
    code VARCHAR(255),
    description varchar(255),
    discount_percent DECIMAL(5, 2),
    start_date DATE default (getdate()),
    end_date DATE default (getdate())
);

CREATE TABLE [Location] (
    zip_code INT NOT NULL,
    city VARCHAR(20),
    state CHAR(2),
    CONSTRAINT Location_PK PRIMARY KEY (zip_code),
    CONSTRAINT Zipcode_CK CHECK (zip_code BETWEEN 00500 AND 99999)
)

CREATE TABLE Customer (
    customer_id INT NOT NULL IDENTITY(1,1),
    first_name NVARCHAR(25),
    last_name NVARCHAR(25),
    customer_type VARCHAR(50),
    phone_number CHAR(15),
    zip_code INT NOT NULL,
    CONSTRAINT Customer_PK PRIMARY KEY (customer_id),
    CONSTRAINT Customer_FK FOREIGN KEY (zip_code) REFERENCES [Location](zip_code),
    CONSTRAINT PhoneNumber_CK CHECK (phone_number LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
    CONSTRAINT Uc_PhoneNumber UNIQUE(phone_number)
)

CREATE TABLE Book (
    isbn VARCHAR(20) PRIMARY KEY, 
    title NVARCHAR(255), 
    publication_year INT, 
    publisher_id INT NOT NULL,
    category_id INT NOT NULL, 
    FOREIGN KEY (publisher_id) REFERENCES Publisher(publisher_id),
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

CREATE TABLE Item (
  item_id INT NOT NULL PRIMARY KEY Identity(1,1),
  [description] VARCHAR(255) NOT NULL,
  price DECIMAL(6,2) NOT NULL CONSTRAINT
  item_price_nonnegative_CK CHECK (price >= 0),
  item_type VARCHAR(20) NOT NULL CONSTRAINT 
  item_type_chk CHECK (item_type IN ('Book', 'Merchandise')) 
);

CREATE TABLE Merchandise (
  m_item_id INT NOT NULL PRIMARY KEY,
  inventory_id INT NOT NULL,
  category_id INT NOT NULL,
  CONSTRAINT merchandise_fk1 FOREIGN KEY (m_item_id) REFERENCES Item(item_id),
  CONSTRAINT merchandise_fk2 FOREIGN KEY (inventory_id) REFERENCES Inventory(inventory_id),
  CONSTRAINT merchandise_fk3 FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

CREATE TABLE Review (
	review_id INT PRIMARY KEY IDENTITY(1,1),
	content VARCHAR(255),
	reviewer VARCHAR(50) NOT NULL,
	creation_date DATETIME NOT NULL,
	rating DECIMAL(3,2) NOT NULL,
	item_id INT NOT NULL,
	CONSTRAINT Review_FK FOREIGN KEY(item_id) REFERENCES Item(item_id)
)

CREATE TABLE [Order] (
    order_id INT NOT NULL IDENTITY(1,1),
    order_amount DECIMAL(6,2),
    item_count INT NOT NULL DEFAULT 0,
    order_date DATE DEFAULT(getdate()),
    customer_id INT NOT NULL,
    promotion_id INT,
    CONSTRAINT Order_PK PRIMARY KEY (order_id),
    CONSTRAINT Order_FK1 FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    CONSTRAINT Order_FK2 FOREIGN KEY (promotion_id) REFERENCES Promotion(promotion_id),
    CONSTRAINT Order_amount_nonnegative_CK CHECK (order_amount >= 0)
)

CREATE TABLE OrderItem (
    order_item_id INT NOT NULL IDENTITY(1,1),
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    CONSTRAINT OrderItem_PK PRIMARY KEY (order_item_id),
    CONSTRAINT OrderItem_FK1 FOREIGN KEY (order_id) REFERENCES [Order](order_id),
    CONSTRAINT OrderItem_FK2 FOREIGN KEY (item_id) REFERENCES Item(item_id)
)

CREATE TABLE BookCopy (
    b_item_id INT PRIMARY KEY ,
    isbn VARCHAR(20), 
    inventory_id INT,
    can_rent BIT,
    FOREIGN KEY (isbn) REFERENCES Book(isbn),
    FOREIGN KEY (b_item_id) REFERENCES Item(item_id),
    FOREIGN KEY (inventory_id) REFERENCES Inventory(inventory_id)
);

CREATE TABLE BookRent (
    book_rent_id INT PRIMARY KEY IDENTITY(1,1),
    rent_date DATE default(getdate()),
    due_date DATE,
    return_date DATE,
    customer_id INT NOT NULL,
    b_item_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (b_item_id) REFERENCES BookCopy(b_item_id),
    CONSTRAINT CHK_ReturnDateGreaterThanRentDate CHECK (return_date > rent_date)
);

CREATE TABLE Penalty (
    penalty_id INT PRIMARY KEY IDENTITY(1,1),
    penalty_amount MONEY,
    book_rent_id INT UNIQUE,
    FOREIGN KEY (book_rent_id) REFERENCES BookRent(book_rent_id)
);

CREATE TABLE Wrote (
  author_id INT NOT NULL,
  isbn varchar(20) NOT NULL,
  [role] VARCHAR(20) NOT NULL,
  CONSTRAINT wrote_pk PRIMARY KEY (author_id,isbn),
  CONSTRAINT wrote_fk1 FOREIGN KEY (author_id) REFERENCES Author(author_id),
  CONSTRAINT wrote_fk2 FOREIGN KEY (isbn) REFERENCES Book(isbn),
);

--------------------------------------------------------------------------------
-- INDEXES

CREATE NONCLUSTERED INDEX idx_author_name
ON Author (author_first_name, author_last_name);

CREATE NONCLUSTERED INDEX idx_book_title
ON Book (title);

CREATE NONCLUSTERED INDEX idx_review_date
ON Review (creation_date);

-- ---------------------------------------------------------------------------------
-- TRIGGERS

-- TRIGGER New Order
GO
CREATE TRIGGER trg_NewOrderItem
ON OrderItem
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT oi.item_id
        FROM OrderItem oi
        INNER JOIN inserted i ON oi.item_id = i.item_id
    )
    BEGIN
        RAISERROR ('Sorry! This item is not available for ordering', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN

    DECLARE @OrderID INT;
    DECLARE @Amount DECIMAL(6, 2);

    -- Check if the order ID exists in the inserted data
    SELECT @OrderID = order_id FROM inserted;

    -- Calculate total amount and item count for the current order
    SELECT @Amount = it.price
    FROM inserted i
    INNER JOIN Item it ON i.item_id = it.item_id;

    -- Update the order amount and item count
    UPDATE [Order]
    SET order_amount = order_amount + @Amount,
        item_count = item_count + 1
    WHERE order_id = @OrderID;

    -- Apply promotion if applicable
    DECLARE @DiscountPercent DECIMAL(5, 2);
    SELECT @DiscountPercent = COALESCE(p.discount_percent, 0)
    FROM [Order] o
    LEFT JOIN Promotion p ON o.promotion_id = p.promotion_id
    WHERE o.order_id = @OrderID;

    UPDATE [Order]
    SET order_amount = order_amount * (1 - @DiscountPercent / 100)
    WHERE order_id = @OrderID;

        -- Perform the insert operation
        INSERT INTO OrderItem (order_id, item_id)
        SELECT order_id, item_id
        FROM inserted;
    END
END
GO

-- Select * from OrderItem;
-- SELECT * from [Order];
-- SELECT * from Item where item_id = 49;

-- INSERT INTO OrderItem VALUES (2,1);
-- INSERT into OrderItem VALUES (20, 41);


-- TRIGGER Calculate Penalty
GO
CREATE TRIGGER trg_CalculatePenalty
ON BookRent
AFTER UPDATE
AS
BEGIN
    -- Check if the return date column was updated
    IF UPDATE(return_date)
    BEGIN
        DECLARE @RentID INT;
        DECLARE @DueDate DATE;
        DECLARE @ReturnDate DATE;
        DECLARE @Penalty DECIMAL(6, 2);

        -- Get the updated return date and rental ID
        SELECT @RentID = i.book_rent_id, @ReturnDate = i.return_date
        FROM inserted i;

        -- Get the due date for the rental
        SELECT @DueDate = due_date
        FROM BookRent
        WHERE book_rent_id = @RentID;

        -- Calculate the number of days overdue
        DECLARE @DaysOverdue INT;
        SET @DaysOverdue = DATEDIFF(DAY, @DueDate, @ReturnDate);

        -- Calculate penalty amount
        IF @DaysOverdue > 0
        BEGIN
            SET @Penalty = CAST(@DaysOverdue AS DECIMAL(6, 2)); -- $1 per day penalty

            INSERT INTO Penalty (penalty_amount, book_rent_id) VALUES
            (@Penalty, @RentID);
        END
    END
END;
GO

-- Select * from BookRent;
-- SELECT * from Penalty;

-- UPDATE BookRent set return_date = '2024-05-20' where book_rent_id = 5;

-- --------------------------------------------------------------------------------------------------
-- TABLE LEVEL CONSTRAINTS


-- Table level constraint for inserting invalid values in Book or Merchandise Relation
GO
CREATE FUNCTION dbo.fnCheckItemType
(
    @ItemId INT,
    @ExpectedType VARCHAR(20)
)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT;

    SELECT @Result = CASE 
                        WHEN EXISTS (
                            SELECT 1 
                            FROM Item 
                            WHERE item_id = @ItemId AND item_type = @ExpectedType
                        ) 
                        THEN 1 
                        ELSE 0 
                     END;

    RETURN @Result;
END;
GO

alter table BookCopy
drop constraint if exists CK_BookCopy_ItemType;

ALTER TABLE BookCopy
ADD CONSTRAINT CK_BookCopy_ItemType CHECK (dbo.fnCheckItemType(b_item_id, 'Book') = 1);

alter table Merchandise
drop constraint if exists CK_Merchandise_ItemType;

ALTER TABLE Merchandise
ADD CONSTRAINT CK_Merchandise_ItemType CHECK (dbo.fnCheckItemType(m_item_id, 'Merchandise') = 1);

-- SELECT * FROM Item;

-- INSERT INTO Merchandise (m_item_id, inventory_id, category_id) VALUES
-- (1, 1, 3);

-- INSERT INTO BookCopy (b_item_id, isbn, inventory_id, can_rent) VALUES
-- (3, '1234567890123', 1, 0)

-- Verify that the employee's start date is not earlier than his or her date of birth
GO
CREATE FUNCTION CheckEmployeeStartDate(@EmployeeID INT)
RETURNS BIT
BEGIN
    DECLARE @IsValid BIT;
    IF EXISTS(SELECT 1 FROM Employee WHERE employee_id = @EmployeeID AND start_date >= date_of_birth)
        SET @IsValid = 1;
    ELSE
        SET @IsValid = 0;
    RETURN @IsValid;
END;

GO
alter table Employee
drop constraint if exists CHK_Employee_StartDate;

ALTER TABLE Employee
ADD CONSTRAINT CHK_Employee_StartDate CHECK (dbo.CheckEmployeeStartDate(employee_id) = 1);

-- INSERT INTO Employee ( emp_first_name, emp_last_name, date_of_birth, start_date, salary, schedule_time) VALUES
-- ('Jay', 'Smith', '1980-01-01', '1978-05-10', 50000.00, '9 am - 5 pm')

-- Ensure that the promotional code is valid for your order
GO
CREATE FUNCTION CheckPromotionValidity(@PromotionID INT, @OrderDate DATE)
RETURNS BIT
BEGIN
    DECLARE @IsValid BIT = 0; 
    IF EXISTS(
        SELECT 1 
        FROM Promotion p
        WHERE p.promotion_id = @PromotionID 
        AND @OrderDate BETWEEN p.start_date AND p.end_date
    )
        SET @IsValid = 1;
    RETURN @IsValid;
END;

GO
alter table [Order]
drop constraint if exists CHK_Order_PromotionValidity;

ALTER TABLE [Order]
ADD CONSTRAINT CHK_Order_PromotionValidity 
CHECK (promotion_id IS NULL OR dbo.CheckPromotionValidity(promotion_id, order_date) = 1);

-- INSERT INTO [Order] (order_amount, item_count, order_date, customer_id, promotion_id) VALUES
-- (25.98, 2, '2023-04-01', 1, 1)

-- ------------------------------------------------------------------------------
-- VIEWS

-- Book Details View
GO
CREATE VIEW BookDetailsView AS
SELECT 
    b.isbn, 
    b.title, 
    CONCAT(a.author_first_name, ' ', a.author_last_name) AS author_name,
    cat.category_name,
    pub.publisher_name,
    b.publication_year,
    COUNT(bc.b_item_id) AS number_of_copies
FROM 
    Book b
    JOIN Publisher pub ON b.publisher_id = pub.publisher_id
    JOIN Category cat ON b.category_id = cat.category_id
    JOIN Wrote w ON b.isbn = w.isbn
    JOIN Author a ON w.author_id = a.author_id
    LEFT JOIN BookCopy bc ON b.isbn = bc.isbn
GROUP BY 
    b.isbn, b.title, a.author_first_name, a.author_last_name, cat.category_name, pub.publisher_name, b.publication_year;
GO

-- Customer Details View
CREATE VIEW CustomerOrdersView AS
SELECT o.order_id, CONCAT(c.first_name,' ', c.last_name) as customer_name,
       o.order_amount, o.item_count, o.order_date, 
       c.customer_type
FROM [Order] o
JOIN Customer c ON o.customer_id = c.customer_id
GO

-- Merchandise Details View
CREATE VIEW MerchandiseDetailsView AS
SELECT m.m_item_id as item_id, i.description AS merchandise_description, 
       i.price AS merchandise_price, c.category_name
FROM Merchandise m
JOIN Item i ON m.m_item_id = i.item_id
JOIN Category c ON m.category_id = c.category_id
GO


CREATE VIEW PopularBooksRentedView AS
SELECT
    b.isbn,
    b.title,
    COUNT(br.book_rent_id) AS RentalCount
FROM
    BookRent br
JOIN
    BookCopy bc ON br.b_item_id = bc.b_item_id
JOIN
    Book b ON bc.isbn = b.isbn
GROUP BY
    b.isbn, b.title
GO

-- SELECT * FROM PopularBooksRentedView ORDER BY RentalCount DESC
-- SELECT * from BookDetailsView
-- SELECT * from CustomerOrdersView
-- SELECT * FROM MerchandiseDetailsView

--------------------------------------------------------------------------------------------------
-- PROCEDURES

-- Search Book And Merchandise
-- drop PROCEDURE SearchBooksAndMerchandise;
GO
CREATE OR ALTER PROCEDURE BooksAndMerchandiseAvailability
    @searchKeyword NVARCHAR(255),
    @resultCount INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Placeholder for '%' + search keyword + '%'
    DECLARE @formattedKeyword NVARCHAR(260) = '%' + @searchKeyword + '%';

    -- Table to hold the search results
    DECLARE @SearchResults TABLE (
        ItemID INT,
        TitleOrDescription NVARCHAR(255),
        ItemType NVARCHAR(50),
        Price DECIMAL(10,2)
    );

    -- Searching in Books and Items for matching titles and descriptions using LIKE
    INSERT INTO @SearchResults (ItemID, TitleOrDescription, ItemType, Price)
    SELECT CAST(b.isbn AS INT) AS ItemID, 
           b.title AS TitleOrDescription, 
           'Book' AS ItemType, 
           i.price
    FROM Book b
    JOIN Item i ON i.description = b.isbn -- Assuming ISBN matches description
    WHERE b.title LIKE @formattedKeyword
    UNION
    SELECT i.item_id AS ItemID, 
           i.description AS TitleOrDescription, 
           i.item_type AS ItemType, 
           i.price
    FROM Item i
    WHERE i.description LIKE @formattedKeyword;

    -- Check if the keyword exists in OrderItem
    IF EXISTS (SELECT 1 FROM OrderItem WHERE item_id IN (SELECT ItemID FROM @SearchResults))
    BEGIN
        -- Keyword exists in OrderItem, so item is not available
       PRINT 'item is not available';
    END
    ELSE
    BEGIN
        -- Output the count of results found
        SELECT @resultCount = COUNT(*) FROM @SearchResults;

        -- If resultCount is 0 or null, show a message as "Not available"
        IF @resultCount IS NULL OR @resultCount = 0
        BEGIN
            PRINT 'Not available';
        END
        ELSE
        BEGIN
            -- Selecting the results to return
            SELECT * FROM @SearchResults;
        END
    END
END;


-- DECLARE @MatchCount INT;
-- EXEC BooksAndMerchandiseAvailability
--     @searchKeyword = N'Pride and Prejudice',  -- Example search keyword
--     @resultCount = @MatchCount OUTPUT;
-- SELECT 'Total Matches: ' + CAST(@MatchCount AS VARCHAR(10));

-- select * from item where item_id = 11;
-- select * from item;
-- select * from OrderItem;
-- select * from bookcopy where can_rent = 1;

-- Procedure Add Merchandise
GO
CREATE OR ALTER PROCEDURE AddMerchandise
    @description VARCHAR(255),
    @price DECIMAL(6,2),
    @category_name NVARCHAR(255),
    @inventory_id INT,
    @item_id INT OUTPUT,
    @m_item_id INT OUTPUT
AS
BEGIN
    DECLARE @category_id INT;

    -- Check if the category name exists, and set @category_id
    SELECT @category_id = category_id FROM Category WHERE category_name = @category_name;

    -- If not exists, insert the new category and set @category_id
    IF @category_id IS NULL
    BEGIN
        INSERT INTO Category (category_name, description) VALUES (@category_name, 'Description for ' + @category_name);
        SET @category_id = SCOPE_IDENTITY();
    END

    -- Insert into Item table
    INSERT INTO Item ([description], price, item_type)
    VALUES (@description, @price, 'Merchandise');

    -- Get the last inserted item_id
    SET @item_id = SCOPE_IDENTITY();
    SET @m_item_id = @item_id; -- In this scenario, m_item_id is the same as item_id

    -- Insert into Merchandise table
    INSERT INTO Merchandise (m_item_id, inventory_id, category_id)
    VALUES (@m_item_id, @inventory_id, @category_id);
END;
GO

-- select * from category;
-- select * from merchandise;
-- select * from Item;
-- select * from Inventory;

-- DECLARE @MerchItemID INT, @MerchandiseID INT;
-- EXEC AddMerchandise
--     @description = 'Sci-Fi Themed T-Shirt - Large',
--     @price = 15.99,
--     @category_name = N'Sci-Fi Merchandise Clothes',
--     @inventory_id = 3, 
--     @item_id = @MerchItemID OUTPUT,
--     @m_item_id = @MerchandiseID OUTPUT;

-- SELECT @MerchItemID as 'Merchandise Item ID', @MerchandiseID as 'Merchandise ID';


-- Procedure RentBook
GO
CREATE OR ALTER PROCEDURE RentBook
    @customer_id INT,
    @b_item_id INT,
    @rent_id INT OUTPUT, -- To return the ID of the new rent record
    @status_message NVARCHAR(255) OUTPUT -- To return the status message
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @canRent BIT;
    DECLARE @isAvailable BIT;

    ;WITH LatestRent AS (
        SELECT TOP 1 return_date
        FROM BookRent
        WHERE b_item_id = @b_item_id
        ORDER BY rent_date DESC
    )
    SELECT @isAvailable = CASE 
                            WHEN return_date IS NULL THEN 0 
                            ELSE 1 
                          END
    FROM LatestRent;

    IF @isAvailable IS NULL
    BEGIN
        SELECT @canRent = can_rent FROM BookCopy WHERE b_item_id = @b_item_id;
        IF @canRent = 1
        BEGIN
            SET @isAvailable = 1;
        END
        ELSE
        BEGIN
            SET @status_message = 'Book cannot be rented';
            RETURN;
        END
    END

    IF @isAvailable = 1
    BEGIN
        INSERT INTO BookRent (customer_id, b_item_id, rent_date, due_date, return_date)
        VALUES (@customer_id, @b_item_id, GETDATE(), DATEADD(WEEK, 2, GETDATE()), NULL);

        SET @rent_id = SCOPE_IDENTITY(); 
        SET @status_message = 'Book rented successfully';
    END
    ELSE
    BEGIN
        SET @status_message = 'Book currently not available';
    END
END;
GO

-- DECLARE @RentID INT, @StatusMessage NVARCHAR(255);

-- EXEC RentBook
--     @customer_id = 1,
--     @b_item_id = 1, 
--     @rent_id = @RentID OUTPUT,
--     @status_message = @StatusMessage OUTPUT;

-- SELECT @RentID AS 'Rent Record ID', @StatusMessage AS 'Status Message';

-- select * from BookRent;
-- select * from BookCopy;
-- SELECT * from Penalty;

-- UPDATE BookRent SET return_date = '2024-04-25' where book_rent_id = 5;

-- PROCEDURE Get Order Details By Date
GO
CREATE OR ALTER PROCEDURE GetOrderDetailsByDate
    @OrderID INT,
    @OrderDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Step 1: Select item details for the specified order and date
    SELECT 
        i.item_id AS 'Item ID',
        i.description AS 'Description',
        i.price AS 'Price'
    FROM 
        [Order] o
        INNER JOIN OrderItem oi ON o.order_id = oi.order_id
        INNER JOIN Item i ON oi.item_id = i.item_id
    WHERE 
        o.order_id = @OrderID AND o.order_date = @OrderDate;

    -- Step 2: Select order summary (total items and total amount spent)
    SELECT 
        o.item_count AS 'Total Items',
        SUM(i.price) AS 'Total Amount Spent'
    FROM 
        [Order] o
        INNER JOIN OrderItem oi ON o.order_id = oi.order_id
        INNER JOIN Item i ON oi.item_id = i.item_id
    WHERE 
        o.order_id = @OrderID AND o.order_date = @OrderDate
    GROUP BY 
        o.item_count;
END;
GO

-- select * from [order];
-- EXEC GetOrderDetailsByDate @OrderID = 2, @OrderDate = '2022-08-15';

-- PROCEDURE Search Books By Author

-- drop procedure SearchBooksByAuthor
GO
CREATE OR ALTER PROCEDURE SearchBooksByAuthor
    @AuthorName NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    -- Fetching books by the author that can be rented
    SELECT 
        bc.b_item_id AS 'ItemID',
        b.title AS 'Title',
        a.author_first_name + ' ' + a.author_last_name AS 'Author',
        'Rentable' AS 'Availability'
    FROM 
        Book b
        JOIN Wrote w ON b.isbn = w.isbn
        JOIN Author a ON w.author_id = a.author_id
        JOIN BookCopy bc ON b.isbn = bc.isbn
    WHERE 
        (a.author_first_name LIKE '%' + @AuthorName + '%' OR a.author_last_name LIKE '%' + @AuthorName + '%')
        AND bc.can_rent = 1;

    -- Fetching books by the author that can be ordered
    SELECT 
        bc.b_item_id AS 'ItemID',
        b.title AS 'Title',
        a.author_first_name + ' ' + a.author_last_name AS 'Author',
        CASE 
            WHEN EXISTS (
                SELECT 1 
                FROM OrderItem oi
                JOIN Item i ON oi.item_id = i.item_id
                WHERE i.description = b.title
            ) THEN 'Sold'
            ELSE 'Orderable'
        END AS 'Availability'
    FROM 
        Book b
        JOIN Wrote w ON b.isbn = w.isbn
        JOIN Author a ON w.author_id = a.author_id
        JOIN BookCopy bc ON b.isbn = bc.isbn
    WHERE 
        (a.author_first_name LIKE '%' + @AuthorName + '%' OR a.author_last_name LIKE '%' + @AuthorName + '%')
        AND bc.can_rent = 0;
END;

-- select * from Author;
-- select * from item;
-- select * from OrderItem;
-- select * from BookCopy;
-- EXEC SearchBooksByAuthor @AuthorName = N'Harper'; 

-- ------------------------------------------------------------------------------------------------------------------------------------
-- USER DEFINED FUNCTIONS

--Total Books borrowed ever by a specific customer (regardless of returned or not)
GO
CREATE FUNCTION TotalBooksEverBorrowed (@CustomerId INT)
RETURNS INT
AS
BEGIN
    DECLARE @TotalBooks INT;

    SELECT @TotalBooks = COUNT(*)
    FROM BookRent
    WHERE customer_id = @CustomerId;

    RETURN @TotalBooks;
END;
GO
--Pass customer_id to the function parameter
-- SELECT dbo.TotalBooksEverBorrowed(2) AS TotalBooksBorrowed;

--Find the age of oldest book in our category
GO
CREATE FUNCTION dbo.OldestBookDetailsInCategory (@CategoryID INT)
RETURNS TABLE
AS
RETURN (
    SELECT TOP 1
        title,
        publication_year,
        YEAR(GETDATE()) - publication_year AS Age
    FROM 
        Book
    WHERE 
        category_id = @CategoryID
    ORDER BY 
        publication_year ASC
);
GO

-- SELECT * FROM dbo.OldestBookDetailsInCategory(1);

-- Calculate the age of an employee
GO
CREATE FUNCTION CalculateAge(@date_of_birth DATE)
RETURNS INT
AS
BEGIN
	RETURN 
    (DATEDIFF(YEAR, @date_of_birth, GETDATE()) -
	CASE 
        WHEN MONTH(@date_of_birth) > MONTH(GETDATE()) OR 
             (MONTH(@date_of_birth) = MONTH(GETDATE()) AND DAY(@date_of_birth) > DAY(GETDATE())) 
        THEN 1 
        ELSE 0 
    END)
END

GO
-- Select employee_id, date_of_birth, dbo.CalculateAge(date_of_birth) as EmpAge from Employee

-- --------------------------------------------------------------------------------------------------------
