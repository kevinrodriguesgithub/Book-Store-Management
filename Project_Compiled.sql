CREATE DATABASE BMS;

USE BMS;


DROP TABLE IF EXISTS Wrote;
DROP TABLE IF EXISTS Penalty;
DROP TABLE IF EXISTS BookRent;
DROP TABLE IF EXISTS BookCopy;
DROP TABLE IF EXISTS OrderItem;
DROP TABLE IF EXISTS [Order];
DROP TABLE IF EXISTS Review;
DROP TABLE IF EXISTS Merchandise;
DROP TABLE IF EXISTS Item;
DROP TABLE IF EXISTS Book;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS [Location];
DROP TABLE IF EXISTS Promotion;
DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Publisher;
DROP TABLE IF EXISTS Author;
DROP TABLE IF EXISTS Category;



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


-- --------------------------------------------------------------------------------------------


-- Insert records for Category
INSERT INTO Category ( category_name, description) VALUES
('Fiction', 'Fictional Books'),
('Non-Fiction', 'Non-Fictional Books'),
('Clothing', 'Apparel'),
('Home & Office', 'Items for Home and Office'),
('Accessories', 'Miscellaneous Items'),
('Mystery', 'Mystery Books'),
('Thriller', 'Thriller Books'),
('Educational', 'Educational Books'),
('Thriller', 'Thriller Books'),
('Romance', 'Romance Books'),
('Art and Craft', 'Art and Craft supplies');

-- Insert records for Author
INSERT INTO Author ( author_first_name, author_last_name, initials) VALUES
('Harper', 'Lee', 'H.L.'),
('George', 'Orwell', 'G.O.'),
('Jane', 'Austen', 'J.A.'),
('J.D.', 'Salinger', 'J.D.S.'),
('F. Scott', 'Fitzgerald', 'F.S.F.'),
('Aldous', 'Huxley', 'A.H.'),
('J.R.R.', 'Tolkien', 'J.R.R.T.'),
('Ray', 'Bradbury', 'R.B.'),
('A. J.', 'Johnson', 'A. J.'),
('Michael', 'Smith', 'M.SM'),
('David', 'Lee', 'D.LE'),
('Brian', 'Thompson', 'B. T.'),
('John', 'Richards', 'J. R.'),
('Mark', 'Stevens', 'M. S.'),
('Daniel', 'White', 'D. W.'),
('James', 'Carter', 'J. C.'),
('Patrick', 'Evans', 'P. E.'),
('Robert', 'Green', 'R. G.'),
('Emily', 'Collins', 'E. C.'),
('Sarah', 'Parker', 'S. P.'),
('Jessica', 'Grant', 'J. G.'),
('Rachel', 'Adams', 'R. A.'),
('Laura', 'Miller', 'L. M.'),
('Jennifer', 'Roberts', 'J. R.'),
('Laura', 'Harris', 'L. H.'),
('Elizabeth', 'King', 'E. K.'),
('Anna', 'Johnson', 'A. J.'),
('Robert', 'Johnson', 'R. J.'),
('Emily', 'Smith', 'E. S.'),
('Michael', 'Williams', 'M. W.'),
('Jessica', 'Brown', 'J. B.'),
('David', 'Taylor', 'D. T.'),
('Sarah', 'Johnson', 'S. J.'),
('Emily', 'Roberts', 'E. R.'),
('Michael', 'Thompson', 'M. T.'),
('Jessica', 'Addams', 'J. A.'),
('David', 'Parker', 'D. P.');

-- Insert records for Publisher
INSERT INTO Publisher ( publisher_name, publisher_city) VALUES
('Penguin Random House', 'New York'),
('HarperCollins Publishers', 'London'),
('Simon & Schuster', 'New York'),
('Hachette Livre', 'Paris'),
('Macmillan Publishers', 'London');

-- Insert records for Employee
INSERT INTO Employee ( emp_first_name, emp_last_name, date_of_birth, start_date, salary, schedule_time) VALUES
('John', 'Smith', '1980-01-01', '2005-05-10', 50000.00, '9 am - 5 pm'),
('Jane', 'Doe', '1985-02-02', '2008-08-15', 55000.00, '1 pm - 6 pm'),
('Alice', 'Johnson', '1990-03-03', '2010-10-20', 60000.00, '8 am - 4 pm'),
('Bob', 'Williams', '1995-04-04', '2012-12-25', 65000.00, '10 am - 3 pm'),
('Emma', 'Brown', '2000-05-05', '2015-03-30', 70000.00, '9 am - 6 pm'),
('Michael', 'Jones', '1982-06-06', '2007-07-05', 75000.00, '12 pm - 5 pm'),
('Sarah', 'Davis', '1984-07-07', '2009-09-12', 80000.00, '8:30 am - 4:30 pm'),
('David', 'Wilson', '1988-08-08', '2011-11-18', 85000.00, '2 pm - 7 pm'),
('Emily', 'Taylor', '1992-09-09', '2013-04-22', 90000.00, '9 am - 5 pm'),
('James', 'Martinez', '1997-10-10', '2016-06-08', 95000.00, '11 am - 4 pm');

-- Insert records for Inventory
INSERT INTO Inventory (employee_id) VALUES
(1),
(2),
(3),
(4),
(5),
(6),
(7),
(8),
(9),
(10);

-- Insert records for Promotion
INSERT INTO Promotion ( code, description, discount_percent, start_date, end_date) VALUES
('PROMO1', '10% off on all books', 10.00, '2024-04-01', '2024-05-01'),
('PROMO2', '15% off on first purchase', 15.00, '2024-04-02', '2024-05-02'),
('PROMO3', 'Free shipping on orders over $50', 0.00, '2024-04-03', '2024-05-03'),
('PROMO4', '$5 discount on merchandise', 5.00, '2024-04-04', '2024-05-04'),
('PROMO5', '20% off on all items', 20.00, '2024-04-05', '2024-05-05'),
('PROMO6', 'Buy one get one free on books', 100.00, '2024-04-06', '2024-05-06'),
('PROMO7', '20% off on jackets', 20.00, '2024-04-07', '2024-05-07'),
('PROMO8', '$10 off on orders over $50', 10.00, '2024-04-08', '2024-05-08'),
('PROMO9', 'Free merchandise with book purchase', 0.00, '2024-04-09', '2024-05-09'),
('PROMO10', '25% off on all orders', 25.00, '2024-04-10', '2024-05-10');

INSERT INTO [Location] (zip_code, city, state) VALUES
(10001, 'New York', 'NY'),
(20002, 'Washington', 'DC'),
(30303, 'Atlanta', 'GA'),
(60606, 'Chicago', 'IL'),
(90001, 'Los Angeles', 'CA'),
(75201, 'Dallas', 'TX'),
(98101, 'Seattle', 'WA'),
(33101, 'Miami', 'FL'),
(19101, 'Philadelphia', 'PA'),
(48201, 'Detroit', 'MI');

-- Insert records for Customer
INSERT INTO Customer (first_name, last_name, customer_type, phone_number, zip_code) VALUES
('John', 'Doe', 'Regular', '123-456-7890', 10001),
('Jane', 'Smith', 'Premium', '234-567-8901', 20002),
('Alice', 'Johnson', 'Regular', '345-678-9012', 30303),
('Bob', 'Williams', 'Regular', '456-789-0123', 60606),
('Emma', 'Brown', 'Premium', '567-890-1234', 90001),
('Michael', 'Jones', 'Regular', '678-901-2345', 75201),
('Sarah', 'Davis', 'Regular', '789-012-3456', 98101),
('David', 'Wilson', 'Regular', '890-123-4567', 33101),
('Emily', 'Taylor', 'Premium', '901-234-5678', 19101),
('James', 'Martinez', 'Regular', '012-345-6789', 48201),
('Nilraj', 'Mayekar', 'Premium', '857-456-7220', 10001),
('Anirudh', 'Maheshwari', 'Premium', '857-456-1110', 10001),
('Kevin', 'Rodrigues', 'Regular', '857-456-3567', 10001),
('Vishnuvardhan', 'Chennavaram', 'Regular', '857-476-2476', 75201),
('Fei', 'Cao', 'Premium', '857-345-2223', 75201);

-- Insert records for Book
INSERT INTO Book (isbn, title, publication_year, publisher_id, category_id) VALUES
('1234567890123', 'To Kill a Mockingbird', 1960, 1, 1),
('2345678901234', '1984', 1949, 2, 1),
('3456789012345', 'Pride and Prejudice', 1813, 3, 1),
('4567890123456', 'The Catcher in the Rye', 1951, 4, 1),
('5678901234567', 'The Great Gatsby', 1925, 5, 1),
('6789012345678', 'Animal Farm', 1945, 1, 1),
('7890123456789', 'Brave New World', 1932, 2, 1),
('8901234567890', 'The Lord of the Rings', 1954, 3, 1),
('9012345678901', 'Fahrenheit 451', 1953, 4, 1),
('0123456789012', 'The Hobbit', 1937, 5, 1),
('9781234567890', 'The Cryptic Cipher', 2016, 1, 6),
('9781234567913', 'Code Red: The Hunt for the Hacker', 2019, 2, 6),
('9781234567937', 'The Puzzle Master', 2017, 3, 6),
('9781234567951', 'Unraveling the Enigma', 2015, 4, 6),
('9781234567975', 'The Labyrinth of Lies', 2018, 5, 6),
('9781234567999', 'The Case of the Vanishing Witness', 2016, 1, 6),
('9781234568019', 'The Puzzle Box Murders', 2014, 2, 6),
('9781234568033', 'Cipher of Conspiracy', 2013, 3, 6),
('9781234568057', 'Chasing Shadows', 2019, 4, 6),
('9781234568071', 'Clandestine Operations', 2017, 5, 6),
 
('9781234567906', 'Murder at Midnight Manor', 2019, 1, 7),
('9781234567920', 'The Deadly Game', 2016, 2, 7),
('9781234567944', 'In the Shadow of Suspicion', 2018, 3, 7),
('9781234567968', 'The Secret Code Conspiracy', 2014, 4, 7),
('9781234567982', 'Decoding Danger', 2015, 5, 7),
('9781234568002', 'Dark Waters', 2017, 1, 7),
('9781234568026', 'The Da Vinci Disappearance', 2016, 2, 7),
('9781234568040', 'The Secret Society', 2018, 3, 7),
('9781234568064', 'The Mystery of the Missing Manuscript', 2019, 4, 7),
 
('9781234568101', 'A Love Beyond Time', 2012, 5, 10),
('9781234568118', 'Heartstrings and Harmony', 2014, 1, 10),
('9781234568125', 'Destined Hearts', 2016, 2, 10),
('9781234568132', 'Love in Bloom', 2018, 3, 10),
('9781234568149', 'Forever Yours', 2015, 4, 10),
 
('9781234567200', 'The Fundamentals of Physics', 2010, 5, 8),
('9781234567217', 'Mathematics Made Easy', 2015, 1, 8),
('9781234567224', 'The History of World Wars', 2005, 2, 8),
('9781234567231', 'Introduction to Computer Science', 2018, 3, 8),
('9781234567248', 'Understanding Economics: A Beginner''s Guide', 2013, 4, 8);

-- Insert records for Item
INSERT INTO Item ([description], price, item_type) VALUES
('To Kill a Mockingbird', 25.99, 'Book'),
('1984', 19.99, 'Book'),
('T-shirt - Small', 15.99, 'Merchandise'),
('Mug - White', 8.99, 'Merchandise'),
('Keychain - Silver', 5.99, 'Merchandise'),
('Jacket - Black', 49.99, 'Merchandise'),
('Brave New World', 29.99, 'Book'),
('T-shirt - Large', 16.99, 'Merchandise'),
('Fahrenheit 451', 22.99, 'Book'),
('Keychain - Black', 6.49, 'Merchandise'),
('Pride and Prejudice', 24.99, 'Book'),
('The Catcher in the Rye', 15.49, 'Book'),
('The Great Gatsby', 19.49, 'Book'),
('Animal Farm', 14.99, 'Book'),
('The Lord of the Rings', 10.49, 'Book'),
('The Hobbit', 11.99, 'Book'),
('Fahrenheit 451', 22.99, 'Book'),
('To Kill a Mockingbird', 25.99, 'Book'),
('To Kill a Mockingbird', 25.99, 'Book'),
('To Kill a Mockingbird', 25.99, 'Book'),
('1984', 19.99, 'Book'),
('1984', 19.99, 'Book'),
('Brave New World', 29.99, 'Book'),
('The Great Gatsby', 19.49, 'Book'),
('The Great Gatsby', 19.49, 'Book'),
('The Lord of the Rings', 10.49, 'Book'),
('The Lord of the Rings', 10.49, 'Book'),
('The Hobbit', 11.49, 'Book'),
('The Hobbit', 11.49, 'Book'),
('T-shirt - Large', 15.99, 'Merchandise'),
('T-shirt - Small', 15.99, 'Merchandise'),
('T-shirt - Medium', 15.99, 'Merchandise'),
('T-shirt - XL', 15.99, 'Merchandise'),
('Shirt - Large', 16.50, 'Merchandise'),
('Shirt - Medium',  16.50, 'Merchandise'),
('Shirt - XL',  16.50, 'Merchandise'),
('Hoodie Shirt - XL', 30.49, 'Merchandise'),
('Hoodie Shirt - Medium', 30.49, 'Merchandise'),
('Hoodie Shirt - Large', 30.49, 'Merchandise'),
('Keychain - Orange', 6.49, 'Merchandise'),
('Keychain - Blue', 6.49, 'Merchandise'),
('Mug - White', 8.99, 'Merchandise'),
('Mug - Black', 8.99, 'Merchandise'),
('Mug - Purple', 8.99, 'Merchandise'),
('Pen - Silver', 10.99, 'Merchandise'),
('Pen - Silver', 10.99, 'Merchandise'),
('Pen - Gold', 10.99, 'Merchandise'),
('Blue Jeans - Large', 15.49, 'Merchandise'),
('A4 paper - 50 stack', 4.49, 'Merchandise'),
('A3 paper - 50 stack', 4.49, 'Merchandise'),
('A2 paper - 50 stack', 4.49, 'Merchandise'),
 
('To Kill a Mockingbird', 25.99, 'Book'),
('The Cryptic Cipher', 35.99, 'Book'),
('Code Red: The Hunt for the Hacker', 30.99,'Book'),
('The Puzzle Master', 15.99,'Book'),
('Unraveling the Enigma', 36.99, 'Book'),
('The Labyrinth of Lies', 25.49, 'Book'),
('The Case of the Vanishing Witness', 25.99,'Book'),
('The Puzzle Box Murders', 20.99,'Book'),
('Cipher of Conspiracy', 38.99, 'Book'),
('Chasing Shadows', 21.99, 'Book'),
('Clandestine Operations', 24.99, 'Book'),
 
('Murder at Midnight Manor', 25.99, 'Book'),
('The Deadly Game', 55.99, 'Book'),
('In the Shadow of Suspicion', 60.99, 'Book'),
('The Secret Code Conspiracy', 35.99, 'Book'),
('Decoding Danger', 44.99, 'Book'),
('Dark Waters', 44.99, 'Book'),
('The Da Vinci Disappearance', 39.96, 'Book'),
('The Secret Society', 27.99,'Book'),
('The Mystery of the Missing Manuscript', 40.99, 'Book'),
 
('A Love Beyond Time', 67.99, 'Book'),
('Heartstrings and Harmony', 19.99, 'Book'),
('Destined Hearts', 29.99, 'Book'),
('Love in Bloom', 46.99, 'Book'),
('Forever Yours', 47.99, 'Book'),
 
('The Fundamentals of Physics', 75.99, 'Book'),
('Mathematics Made Easy', 251.99, 'Book'),
('The History of World Wars', 254.99, 'Book'),
('Introduction to Computer Science', 222.99,'Book'),
('Understanding Economics: A Beginner''s Guide', 300.99, 'Book');

-- Insert records for Merchandise
INSERT INTO Merchandise (m_item_id, inventory_id, category_id) VALUES
(3, 1, 3),
(4, 2, 4),
(5, 3, 5),
(6, 4, 3),
(8, 5, 3),
(10, 6, 4),
(30, 4, 3),
(31, 4, 3),
(32, 4, 3),
(33, 5, 3),
(34, 5, 3),
(35, 6, 3),
(36, 6, 3),
(37, 7, 3),
(38, 7, 3),
(39, 7, 3),
(40, 8, 5),
(41, 8, 5),
(42, 8, 4),
(43, 8, 4),
(44, 9, 4),
(45, 9, 4),
(46, 9, 4),
(47, 9, 4),
(48, 10, 3),
(49, 10, 11),
(50, 10, 11),
(51, 6, 11);

-- Insert records for Review
INSERT INTO Review (content, reviewer, creation_date, rating, item_id) VALUES
('Great book, loved it!', 'John Doe', '2024-04-01', 4.5, 1),
('Excellent service, fast delivery!', 'Jane Smith', '2024-04-02', 5.0, 2),
('The merchandise quality is amazing.', 'Alice Johnson', '2024-04-03', 4.0, 3),
('Book was damaged upon arrival.', 'Bob Williams', '2024-04-04', 3.0, 4),
('Highly recommended, will buy again.', 'Emma Brown', '2024-04-05', 4.5, 5),
('Quick response from customer service.', 'Michael Jones', '2024-04-06', 4.0, 6),
('Product exactly as described.', 'Sarah Davis', '2024-04-07', 5.0, 7),
('Could be better, not satisfied.', 'David Wilson', '2024-04-08', 2.5, 8),
('Impressive quality, worth the price.', 'Emily Taylor', '2024-04-09', 4.5, 9),
('Fast shipping, good packaging.', 'James Martinez', '2024-04-10', 4.0, 10);

-- Insert records for Order
INSERT INTO [Order] (order_amount, item_count, order_date, customer_id, promotion_id) VALUES
(39.04, 2, '2024-04-01', 1, 1),
(24.98, 2, '2022-08-15', 2, NULL),
(5.99, 1, '2021-05-22', 3, NULL),
(55.98, 2, '2024-04-20', 4, 5),
(16.99, 1, '2020-12-12', 5, NULL),
(22.99, 1, '2021-03-14', 6, NULL),
(6.49, 1, '2023-04-05', 7, NULL),
(55.47, 3, '2023-02-11', 11, NULL),
(21.48, 2, '2023-03-10', 11, NULL),
(74.47, 4, '2023-03-20', 12, NULL),
(22.48, 2, '2023-04-01', 12, NULL),
(46.99, 2, '2023-01-10', 13, NULL),
(4.49, 1, '2023-01-10', 14, NULL),
(30.48, 2, '2023-03-21', 15, NULL),
(33.47, 2, '2023-03-23', 11, NULL),
(10.49, 1, '2023-04-06', 12, NULL),
(36.99, 1, '2022-03-06', 13, NULL),
(280.48, 2, '2022-03-10', 12, NULL),
(222.99, 1, '2022-03-13', 12, NULL),
(300.99, 1, '2023-04-10', 11, NULL);

-- Insert records for OrderItem
INSERT INTO OrderItem (order_id, item_id) VALUES
(1, 1);
INSERT INTO OrderItem (order_id, item_id) VALUES
(1, 2);
INSERT INTO OrderItem (order_id, item_id) VALUES
(2, 3);
INSERT INTO OrderItem (order_id, item_id) VALUES
(2, 4);
INSERT INTO OrderItem (order_id, item_id) VALUES
(3, 5);
INSERT INTO OrderItem (order_id, item_id) VALUES
(4, 6);
INSERT INTO OrderItem (order_id, item_id) VALUES
(4, 7);
INSERT INTO OrderItem (order_id, item_id) VALUES
(5, 8);
INSERT INTO OrderItem (order_id, item_id) VALUES
(6, 9);
INSERT INTO OrderItem (order_id, item_id) VALUES
(7, 10);

INSERT INTO OrderItem (order_id, item_id) VALUES
(8, 30);
INSERT INTO OrderItem (order_id, item_id) VALUES
(8, 37);
INSERT INTO OrderItem (order_id, item_id) VALUES
(8, 44);
INSERT INTO OrderItem (order_id, item_id) VALUES
(9, 15);
INSERT INTO OrderItem (order_id, item_id) VALUES
(9, 45);
INSERT INTO OrderItem (order_id, item_id) VALUES
(10, 31);
INSERT INTO OrderItem (order_id, item_id) VALUES
(10, 32);
INSERT INTO OrderItem (order_id, item_id) VALUES
(10, 36);
INSERT INTO OrderItem (order_id, item_id) VALUES
(10, 18);
INSERT INTO OrderItem (order_id, item_id) VALUES
(11, 33);
INSERT INTO OrderItem (order_id, item_id) VALUES
(11, 40);
INSERT INTO OrderItem (order_id, item_id) VALUES
(12, 34);
INSERT INTO OrderItem (order_id, item_id) VALUES
(12, 38);
INSERT INTO OrderItem (order_id, item_id) VALUES
(13, 50);
INSERT INTO OrderItem (order_id, item_id) VALUES
(14, 19);
INSERT INTO OrderItem (order_id, item_id) VALUES
(14, 51);
INSERT INTO OrderItem (order_id, item_id) VALUES
(15, 21);
INSERT INTO OrderItem (order_id, item_id) VALUES
(15, 49);
INSERT INTO OrderItem (order_id, item_id) VALUES
(16, 26);
INSERT INTO OrderItem (order_id, item_id) VALUES
(15, 42);
 INSERT INTO OrderItem (order_id, item_id) VALUES
(17, 56);
INSERT INTO OrderItem (order_id, item_id) VALUES
(18, 57);
INSERT INTO OrderItem (order_id, item_id) VALUES
(18, 79);
INSERT INTO OrderItem (order_id, item_id) VALUES
(19, 80);
INSERT INTO OrderItem (order_id, item_id) VALUES
(20, 81);

-- Insert records for BookCopy
INSERT INTO BookCopy (b_item_id, isbn, inventory_id, can_rent) VALUES
(1, '1234567890123', 1, 0),
(2, '2345678901234', 2, 0),
(7, '7890123456789', 7, 0),
(9, '9012345678901', 9, 0),
(11, '3456789012345', 3, 1),
(12, '4567890123456', 5, 1),
(13, '5678901234567', 8, 1),
(14, '6789012345678', 10, 1),
(15, '8901234567890', 9, 0),
(16, '0123456789012', 7, 1),
(17, '9012345678901', 2, 1),
(18, '1234567890123', 1, 0),
(19, '1234567890123', 1, 0),
(20, '1234567890123', 1, 1),
(21, '2345678901234', 2, 0),
(22, '2345678901234', 2, 1),
(23, '7890123456789', 2, 1),
(24, '5678901234567', 2, 0),
(25, '5678901234567', 3, 0),
(26, '8901234567890', 3, 0),
(27, '8901234567890', 3, 1),
(28, '0123456789012', 3, 0),
(29, '0123456789012', 3, 1),
 
(52,'1234567890123', 1, 0),
(53,'9781234567890', 1, 0),
(54,'9781234567913', 2, 0),
(55,'9781234567937', 3, 0),
(56,'9781234567951', 4, 0),
(57,'9781234567975', 5, 0),
(58,'9781234567999', 6, 1),
(59,'9781234568019', 8, 1 ),
(60,'9781234568033', 9, 1),
(61,'9781234568057',10, 1),
(62,'9781234568071', 1, 1),
 
(63,'9781234567906', 2, 1),
(64,'9781234567920', 3, 1),
(65,'9781234567944', 4, 1),
(66,'9781234567968', 5, 1),
(67,'9781234567982', 6, 1),
(68,'9781234568002', 7, 1),
(69,'9781234568026', 8, 1),
(70,'9781234568040', 9, 1),
(71,'9781234568064', 10, 1),
 
(72,'9781234568101', 1, 1),
(73,'9781234568118',2, 1),
(74,'9781234568125', 3, 1),
(75,'9781234568132',4, 1),
(76,'9781234568149', 5, 1),
 
(77,'9781234567200', 6, 1),
(78,'9781234567217',7, 1),
(79,'9781234567224', 8, 0),
(80,'9781234567231',9, 0),
(81,'9781234567248',10, 0);


-- Insert records for BookRent
INSERT INTO BookRent (rent_date, due_date, return_date, customer_id, b_item_id) VALUES
('2024-04-01', '2024-04-15', '2024-04-15', 1, 11),
('2024-04-02', '2024-04-16', '2024-04-16', 2, 12),
('2024-04-03', '2024-04-17', '2024-04-21', 3, 13),
('2024-04-04', '2024-04-18', '2024-04-22', 4, 14),
('2024-05-01', '2024-05-15', NULL, 5, 16),
('2024-06-07', '2024-06-21', '2024-06-20', 6, 17),
('2024-07-03', '2024-07-17', NULL, 7, 58),
('2024-08-14', '2024-08-28', NULL, 8, 59),
('2024-09-05', '2024-09-19', NULL, 9, 60),
('2024-10-10', '2024-10-24', '2024-10-23', 10, 61),
('2024-11-15', '2024-11-29', NULL, 11, 62),
('2023-12-20', '2024-01-03', NULL, 12, 67),
('2024-01-25', '2024-02-08', NULL, 13, 68),
('2024-02-11', '2024-02-25', NULL, 14, 69),
('2024-03-13', '2024-03-27', NULL, 15, 70),
('2024-04-17', '2024-05-01', NULL, 1, 71),
('2024-05-20', '2024-06-03', '2024-06-02', 2, 72),
('2024-06-22', '2024-07-06', NULL, 3, 73),
('2024-07-09', '2024-07-23', NULL, 4, 74),
('2024-08-15', '2024-08-29', NULL, 5, 75),
('2024-09-18', '2024-10-02', NULL, 6, 76),
('2024-10-20', '2024-11-03', NULL, 7, 77),
('2024-11-25', '2024-12-09', '2024-12-08', 8, 78),
('2023-12-30', '2024-01-13', NULL, 9, 79),
('2024-01-01', '2024-01-15', '2024-01-12', 10, 11),
('2024-02-05', '2024-02-19', '2024-02-18', 11, 12),
('2024-02-20', '2024-03-06', '2024-03-04', 5, 11),
('2024-03-10', '2024-03-24', '2024-03-22', 2, 14),
('2024-04-01', '2024-04-15', '2024-04-14', 6, 17),
('2024-04-20', '2024-05-04', '2024-05-03', 9, 61),
('2024-05-06', '2024-05-20', '2024-05-18', 1, 72);

-- Insert records for Penalty
INSERT INTO Penalty (penalty_amount, book_rent_id) VALUES
(4.00, 3),
(4.00, 4);

-- Insert records for Wrote
INSERT INTO Wrote (author_id, isbn, [role]) VALUES
(1, '1234567890123', 'Author'),
(2, '2345678901234', 'Co-Author'),
(3, '3456789012345', 'Author'),
(4, '4567890123456', 'Co-Author'),
(5, '5678901234567', 'Author'),
(2, '6789012345678', 'Co-Author'),
(6, '7890123456789', 'Author'),
(7, '8901234567890', 'Co-Author'),
(8, '9012345678901', 'Author'),
(7, '0123456789012', 'Author'),
(9,'9781234567890', 'Author'),
(10,'9781234567913', 'Author'),
(11,'9781234567937', 'Author'),
(12,'9781234567951', 'Author'),
(13,'9781234567975', 'Author'),
(14,'9781234567999', 'Author'),
(15,'9781234568019', 'Author' ),
(16,'9781234568033', 'Author'),
(17,'9781234568057', 'Author'),
(18,'9781234568071', 'Author'),
 
(19,'9781234567906', 'Author'),
(20,'9781234567920', 'Author'),
(21,'9781234567944', 'Author'),
(22,'9781234567968', 'Author'),
(23,'9781234567982', 'Author'),
(24,'9781234568002', 'Author'),
(25,'9781234568026', 'Author'),
(26,'9781234568040', 'Author'),
(27,'9781234568064', 'Author'),
 
(33,'9781234568101', 'Author'),
(34,'9781234568118','Author' ),
(35,'9781234568125', 'Author'),
(36,'9781234568132','Author' ),
(37,'9781234568149', 'Author'),
 
(28,'9781234567200', 'Author'),
(29,'9781234567217','Author' ),
(30,'9781234567224', 'Author'),
(31,'9781234567231','Author'),
(32,'9781234567248','Author');

SELECT * from Category;
SELECT * from Author;
SELECT * from Publisher;
SELECT * from Employee;
SELECT * from Inventory;
SELECT * from Promotion;
SELECT * from [Location];
SELECT * from Customer;
SELECT * from Book;
SELECT * from Item;
SELECT * from Merchandise;
SELECT * from Review;
SELECT * from [Order];
SELECT * from OrderItem;
SELECT * from BookCopy;
SELECT * from BookRent;
SELECT * from Penalty;
SELECT * from Wrote;

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

Select * from OrderItem;
SELECT * from [Order];
SELECT * from Item where item_id = 49;

INSERT INTO OrderItem VALUES (2,1);
INSERT into OrderItem VALUES (20, 41);


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

Select * from BookRent;
SELECT * from Penalty;

UPDATE BookRent set return_date = '2024-05-20' where book_rent_id = 5;
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

SELECT * FROM Item;

INSERT INTO Merchandise (m_item_id, inventory_id, category_id) VALUES
(1, 1, 3);

INSERT INTO BookCopy (b_item_id, isbn, inventory_id, can_rent) VALUES
(3, '1234567890123', 1, 0)

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

INSERT INTO Employee ( emp_first_name, emp_last_name, date_of_birth, start_date, salary, schedule_time) VALUES
('Jay', 'Smith', '1980-01-01', '1978-05-10', 50000.00, '9 am - 5 pm')

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

INSERT INTO [Order] (order_amount, item_count, order_date, customer_id, promotion_id) VALUES
(25.98, 2, '2023-04-01', 1, 1)

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

SELECT * FROM PopularBooksRentedView ORDER BY RentalCount DESC
SELECT * from BookDetailsView
SELECT * from CustomerOrdersView
SELECT * FROM MerchandiseDetailsView

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


DECLARE @MatchCount INT;
EXEC BooksAndMerchandiseAvailability
    @searchKeyword = N'Pride and Prejudice',  -- Example search keyword
    @resultCount = @MatchCount OUTPUT;
SELECT 'Total Matches: ' + CAST(@MatchCount AS VARCHAR(10));

select * from item where item_id = 11;
select * from item;
select * from OrderItem;
select * from bookcopy where can_rent = 1;

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

select * from category;
select * from merchandise;
select * from Item;
select * from Inventory;

DECLARE @MerchItemID INT, @MerchandiseID INT;
EXEC AddMerchandise
    @description = 'Sci-Fi Themed T-Shirt - Large',
    @price = 15.99,
    @category_name = N'Sci-Fi Merchandise Clothes',
    @inventory_id = 3, 
    @item_id = @MerchItemID OUTPUT,
    @m_item_id = @MerchandiseID OUTPUT;

SELECT @MerchItemID as 'Merchandise Item ID', @MerchandiseID as 'Merchandise ID';


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

DECLARE @RentID INT, @StatusMessage NVARCHAR(255);

EXEC RentBook
    @customer_id = 1,
    @b_item_id = 1, 
    @rent_id = @RentID OUTPUT,
    @status_message = @StatusMessage OUTPUT;

SELECT @RentID AS 'Rent Record ID', @StatusMessage AS 'Status Message';

select * from BookRent;
select * from BookCopy;
SELECT * from Penalty;

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

select * from [order];
EXEC GetOrderDetailsByDate @OrderID = 2, @OrderDate = '2022-08-15';

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

select * from Author;
select * from item;
select * from OrderItem;
select * from BookCopy;
EXEC SearchBooksByAuthor @AuthorName = N'Harper'; 

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
SELECT dbo.TotalBooksEverBorrowed(2) AS TotalBooksBorrowed;

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

SELECT * FROM dbo.OldestBookDetailsInCategory(1);

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
Select employee_id, date_of_birth, dbo.CalculateAge(date_of_birth) as EmpAge from Employee

-- --------------------------------------------------------------------------------------------------------
-- Column data encryption

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'BMS@6210';
GO

-- Verify that the master key exists
SELECT name KeyName,
symmetric_key_id KeyID,
key_length KeyLength,
algorithm_desc KeyAlgorithm
FROM sys.symmetric_keys;

-- Create a Certificate
CREATE CERTIFICATE SalaryCert
WITH SUBJECT = 'Employee Salary Encryption';
GO

-- drop certificate SalaryCert;

-- Create a Symmetric Key
CREATE SYMMETRIC KEY SalaryKey
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE SalaryCert;
GO

-- drop symmetric key SalaryKey

ALTER TABLE Employee
ALTER COLUMN salary VARBINARY(400);
GO

-- open the symmetric key with which to encrypt the data
OPEN SYMMETRIC KEY SalaryKey
DECRYPTION BY CERTIFICATE SalaryCert;


UPDATE Employee
SET salary = EncryptByKey(Key_GUID('SalaryKey'), CONVERT(VARBINARY,salary));

CLOSE SYMMETRIC KEY SalaryKey;
GO

OPEN SYMMETRIC KEY SalaryKey
DECRYPTION BY CERTIFICATE SalaryCert;

SELECT emp_first_name, emp_last_name, 
       CONVERT(DECIMAL,DecryptByKey(salary)) AS DecryptedSalary
FROM Employee;

CLOSE SYMMETRIC KEY SalaryKey;
GO
-- ---------------------------------------------------------------------------------------------

-- Get Items in an inventory
SELECT 
    i.inventory_id,
    COALESCE(COUNT(DISTINCT m.m_item_id), 0) AS total_merchandise,
    COALESCE(COUNT(DISTINCT b.b_item_id), 0) AS total_book_copy,
    COALESCE(COUNT(DISTINCT m.m_item_id) + COUNT(DISTINCT b.b_item_id), 0) AS total_items
FROM 
    Inventory i
LEFT JOIN 
    Merchandise m ON i.inventory_id = m.inventory_id
LEFT JOIN 
    BookCopy b ON i.inventory_id = b.inventory_id
GROUP BY 
    i.inventory_id;

