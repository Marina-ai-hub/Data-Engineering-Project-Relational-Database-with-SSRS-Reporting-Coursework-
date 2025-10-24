CREATE DATABASE WebShopDB
ON(
NAME = 'WebShop',
FILENAME = 'C:\DataBases\WebShopDB.mdf',
SIZE = 100MB,
MAXSIZE = 100MB, 
FILEGROWTH = 10MB
)
LOG ON (
NAME = 'LogWebShopDB.ldf',
FILENAME = 'C:\DataBases\WebShopDB.ldf',
SIZE = 5MB,
MAXSIZE = 50MB,
FILEGROWTH = 5MB
)
COLLATE Cyrillic_General_CI_AS

-- Створити у базі даних таблиці. Встановити зв’язки між таблицями. Передбачити умови цілісності посилання та створити обмеження користувача.
DROP TABLE IF EXISTS Invoice;
DROP TABLE IF EXISTS Warehouse;
DROP TABLE IF EXISTS PaymentSys;
DROP TABLE IF EXISTS Delivery;
DROP TABLE IF EXISTS OrdersCl;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Suppliers;
DROP TABLE IF EXISTS Clients;
DROP TABLE IF EXISTS Users;


-- Список зовнішніх ключів, які посилаються на ваші таблиці
SELECT 
    f.name AS ForeignKey,
    OBJECT_NAME(f.parent_object_id) AS TableName,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS ColumnName,
    OBJECT_NAME (f.referenced_object_id) AS ReferencedTableName
FROM 
    sys.foreign_keys AS f
INNER JOIN 
    sys.foreign_key_columns AS fc 
    ON f.object_id = fc.constraint_object_id
WHERE 
    OBJECT_NAME (f.referenced_object_id) IN ('Warehouse', 'Products', 'Suppliers', 'Users');




CREATE TABLE Users (
ID_User INTEGER IDENTITY(1,1) NOT NULL PRIMARY KEY,
IPAdresse VARCHAR(50) UNIQUE CHECK (IPAdresse LIKE '%.%.%.%'),
ChangeDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Clients (
ID_Client INTEGER IDENTITY(1,1) NOT NULL PRIMARY KEY,
ID_User INTEGER NOT NULL FOREIGN KEY REFERENCES Users(ID_User),
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL,
AddressCl VARCHAR(50) NOT NULL,
Phone VARCHAR(50) CHECK (Phone LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
Email VARCHAR(50) CHECK (Email LIKE '%_@_%.__%'),
Invoice VARCHAR(50) UNIQUE NULL,
UNIQUE (ID_Client, Phone, Email)
);

CREATE TABLE Suppliers (
ID_Supplier INTEGER IDENTITY(1,1) NOT NULL PRIMARY KEY,
ID_User INTEGER NOT NULL FOREIGN KEY REFERENCES Users(ID_User),
CompanyName VARCHAR(50) NOT NULL,
AddressSp VARCHAR(50) NULL,
Phone VARCHAR(50) UNIQUE CHECK (Phone LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
);

CREATE TABLE Products (
ID_Product INTEGER IDENTITY(1,1) NOT NULL PRIMARY KEY,
ID_User INTEGER NOT NULL FOREIGN KEY REFERENCES Users(ID_User),
ID_Supplier INTEGER NOT NULL FOREIGN KEY REFERENCES Suppliers(ID_Supplier),
Name VARCHAR(50) NOT NULL,
Brand VARCHAR(50) NOT NULL,
Price FLOAT NOT NULL CHECK (Price >= 0),
Quantity INTEGER NOT NULL CHECK (Quantity >= 0)
);

CREATE TABLE OrdersCl (
ID_Order INTEGER IDENTITY(1,1) NOT NULL PRIMARY KEY,
ID_Product INTEGER NOT NULL FOREIGN KEY REFERENCES Products(ID_Product),
ID_Client INTEGER NOT NULL FOREIGN KEY REFERENCES Clients(ID_Client),
ID_User INTEGER NOT NULL FOREIGN KEY REFERENCES Users(ID_User),
OrderStatus VARCHAR(50) CHECK (OrderStatus IN ('Completed', 'Pending','Cancelled')),
Price FLOAT NOT NULL CHECK (Price >= 0),
OrderDate DATETIME NULL   
);


CREATE TABLE Delivery (
ID_Delivery INTEGER IDENTITY(1,1) NOT NULL PRIMARY KEY,
ID_Order INTEGER NOT NULL UNIQUE FOREIGN KEY REFERENCES OrdersCl(ID_Order),
ID_User INTEGER NOT NULL FOREIGN KEY REFERENCES Users(ID_User),
AddressDl VARCHAR(50) NOT NULL,
DeliveryDate DATETIME NULL,  
DeliveryStatus VARCHAR(50) CHECK (DeliveryStatus IN ('Shipped', 'Delivered', 'Cancelled'))
);

CREATE TABLE PaymentSys (
ID_PaymentSys INTEGER IDENTITY(1,1) NOT NULL PRIMARY KEY,
ID_Order INTEGER NOT NULL UNIQUE FOREIGN KEY REFERENCES OrdersCl(ID_Order),
ID_Client INTEGER NOT NULL FOREIGN KEY REFERENCES Clients(ID_Client),
ID_User INTEGER NOT NULL FOREIGN KEY REFERENCES Users(ID_User),
PaymentStatus VARCHAR(50) CHECK (PaymentStatus IN ('Success','Failed')),
Price FLOAT NOT NULL CHECK (Price >= 0),
PaymentDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP 
);

CREATE TABLE Warehouse (
ID_Warehouse INTEGER IDENTITY(1,1) NOT NULL PRIMARY KEY,
ID_Supplier INTEGER NOT NULL FOREIGN KEY REFERENCES Suppliers(ID_Supplier),
ID_Product INTEGER NOT NULL FOREIGN KEY REFERENCES Products(ID_Product),
ID_User INTEGER NOT NULL FOREIGN KEY REFERENCES Users(ID_User),
Quantity INTEGER NOT NULL CHECK (Quantity >= 0),
Price FLOAT NOT NULL CHECK (Price >= 0)
);

CREATE TABLE Invoice (
ID_Invoice INTEGER IDENTITY(1,1) NOT NULL PRIMARY KEY,
ID_PaymentSys INTEGER NOT NULL FOREIGN KEY REFERENCES PaymentSys(ID_PaymentSys),
ID_User INTEGER FOREIGN KEY REFERENCES Users(ID_User),
Price FLOAT NOT NULL CHECK (Price >= 0)
);
/*
--///////////////////////////////////////////////////////////////////
-- Заполнение таблицы Users
INSERT INTO Users (IPAdresse, ChangeDate)
VALUES
('192.168.1.1', '2024-03-01 10:00:00'),
('192.168.1.2', '2024-03-02 11:30:00'),
('192.168.1.3', '2024-03-03 14:45:00'),
('192.168.1.4', '2024-03-04 09:20:00'),
('192.168.1.5', '2024-03-05 16:00:00'),
('192.168.1.6', '2024-03-06 08:50:00');
GO

-- Заповнення таблиці Clients
INSERT INTO Clients (ID_User, FirstName, LastName, AddressCl, Phone, Email, Invoice)
VALUES
(1, 'Ivan', 'Petrov', 'Kyiv, Shevchenka 10', '093-123-4567', 'ivan.petrov@mail.com', 'INV001'),
(2, 'Maria', 'Shevchenko', 'Lviv, Franka 5', '093-987-6543', 'maria.shevchenko@mail.com', 'INV002'),
(3, 'Olga', 'Vasyleva', 'Zaporizhzhia, Soborna 15', '093-876-5432', 'olga.vasyleva@mail.com', 'INV003'),
(4, 'Elena', 'Shevchenko', 'Dnipro, Centralna 10', '093-765-4321', 'elena.koval@mail.com', 'INV004'),
(5, 'Serhiy', 'Maksymov', 'Kharkiv, Pushkina 20', '093-234-5678', 'serhiy.maksymov@mail.com', 'INV005'),
(6, 'Olga', 'Vasyleva', 'Zaporizhzhia, Soborna 15', '093-876-5432', 'olga.vasyleva@mail.com', 'INV006');
GO


-- Заповнення таблиці Suppliers
INSERT INTO Suppliers (ID_User, CompanyName, AddressSp, Phone)
VALUES
(1, 'TechWorld', 'Kyiv, Peremohy 15', '093-111-1111'),
(2, 'ClothesShop', 'Lviv, Svobody 20', '093-222-2222'),
(3, 'FoodMarket', 'Odesa, Prymorska 8', '093-333-3333'),
(4, 'GadgetPro', 'Dnipro, Heroiv 12', '093-444-4444'),
(5, 'ElectroMart', 'Kharkiv, Chervonozavodskyi 7', '093-555-5555'),
(6, 'FreshFruits', 'Zaporizhzhia, Lenina 8', '093-666-6666');
GO

-- Заповнення таблиці Products
INSERT INTO Products (ID_User, ID_Supplier, Name, Brand, Price, Quantity)
VALUES
(1, 1, 'Laptop', 'Apple', 1299.99, 5),
(2, 2, 'T-shirt', 'Nike', 29.99, 50),
(3, 3, 'Chocolate', 'Roshen', 2.50, 100),
(1, 1, 'Smartphone', 'Samsung', 899.99, 10),
(1, 2, 'Jeans', 'Levi’s', 79.99, 30),
(2, 3, 'Smart Watch', 'Garmin', 199.99, 20);
GO

-- Заповнення таблиці OrdersCl
INSERT INTO OrdersCl (ID_Product, ID_Client, ID_User, OrderStatus, Price, OrderDate)
VALUES
(1, 1, 1, 'Completed', 1299.99, '2024-03-05 12:00:00'),
(2, 2, 2, 'Pending', 29.99, '2024-03-06 15:30:00'),
(3, 3, 3, 'Cancelled', 2.50, NULL),
(4, 1, 1, 'Completed', 599.99, '2024-03-08 10:45:00'),
(5, 2, 2, 'Pending', 79.99, '2024-03-09 09:15:00'),
(6, 4, 4, 'Pending', 599.99, '2024-03-10 11:00:00');
GO

-- Заповнення таблиці Delivery
INSERT INTO Delivery (ID_Order, ID_User, AddressDl, DeliveryDate, DeliveryStatus)
VALUES 
(1, 1, 'Kyiv, Shevchenka 10', '2024-03-06 10:00:00', 'Delivered'),
(2, 2, 'Lviv, Franka 5', NULL, 'Shipped'),
(3, 3, 'Odesa, Deribasivska 3', NULL, 'Cancelled'),
(4, 1, 'Kyiv, Shevchenka 10', '2024-03-09 14:00:00', 'Delivered'),
(5, 2, 'Lviv, Franka 5', NULL, 'Shipped'),
(6, 4, 'Dnipro, Centralna 2', '2024-03-15 12:00:00', 'Delivered');
GO

-- Заповнення таблиці PaymentSys
INSERT INTO PaymentSys (ID_Order, ID_Client, ID_User, PaymentStatus, Price, PaymentDate)
VALUES
(1, 1, 1, 'Success', 1299.99, '2021-03-05 12:10:00'),
(2, 2, 2, 'Success', 29.99, '2021-03-08 13:50:00'),
(3, 3, 3, 'Failed', 2.50, '2024-03-08 10:50:00'),  
(4, 1, 1, 'Success', 899.99, '2024-04-08 22:50:00'),
(5, 2, 2, 'Failed', 79.99, '2025-03-06 17:50:00'),
(6, 4, 4, 'Success', 599.99, '2025-03-10 11:10:00');
GO

-- Заповнення таблиці Warehouse
INSERT INTO Warehouse (ID_Supplier, ID_Product, ID_User, Quantity, Price)
VALUES
(1, 1, 1, 10, 1200.00),
(2, 2, 2, 100, 25.00),
(3, 3, 3, 200, 2.00),
(1, 4, 1, 15, 850.00),
(2, 5, 2, 50, 70.00),
(3, 6, 3, 5, 580.00);
GO


-- Заповнення таблиці Invoice
INSERT INTO Invoice (ID_PaymentSys, ID_User, Price)
VALUES
(1, 1, 1299.99),
(2, 1, 899.99),
(3, 4, 599.99),
(4, 2, 29.99),
(2, 2, 79.99);
*/


-- Вставка даних у таблицю Users
INSERT INTO Users (IPAdresse, ChangeDate)
VALUES
('192.168.0.1', '2024-03-01 16:00:00'),
('192.168.0.2', '2024-03-02 16:00:00'),
('192.168.0.3', '2024-03-03 16:00:00');

-- Вставка даних у таблицю Clients
INSERT INTO Clients (ID_User, FirstName, LastName, AddressCl, Phone, Email, Invoice)
VALUES
(1, 'Ivan', 'Petrov', 'Kyiv, St. Shevchenka, 10', '050-123-4567', 'ivan@example.com', 'INV001'),
(2, 'Olga', 'Ivanova', 'Kyiv, St. Lesya, 5', '050-234-5678', 'olga@example.com', 'INV002'),
(3, 'Andriy', 'Kovalenko', 'Lviv, St. Franka, 15', '050-345-6789', 'andriy@example.com', 'INV003'),
(1, 'Svitlana', 'Tarasenko', 'Kharkiv, St. Shevchenka, 20', '050-456-7890', 'svitlana@example.com', 'INV004'),
(2, 'Viktor', 'Melnyk', 'Odesa, St. Pushkina, 30', '050-567-8901', 'dmytro@example.com', 'INV005'),
(3, 'Natalia', 'Kuzmenko', 'Dnipro, St. Kotsiubynskoho, 8', '050-678-9012', 'natalia@example.com', 'INV006'),
(1, 'Viktor', 'Moroz', 'Kyiv, St. Bessarabka, 10', '050-789-0123', 'viktor@example.com', 'INV007'),
(2, 'Tatiana', 'Nikolenko', 'Lviv, St. Soborna, 12', '050-890-1234', 'tatiana@example.com', 'INV008'),
(3, 'Marina', 'Vasylenko', 'Kharkiv, St. Kurchatova, 40', '050-901-2345', 'pavlo@example.com', 'INV009'),
(1, 'Marina', 'Vasylenko', 'Odesa, St. Derybasivska, 5', '050-012-3456', 'marina@example.com', 'INV010');

-- Вставка даних у таблицю Suppliers
INSERT INTO Suppliers (ID_User, CompanyName, AddressSp, Phone)
VALUES
(1, 'Tech Supplies', 'Kyiv, St. Bessarabka, 12', '050-111-2222'),
(2, 'Home Goods', 'Kyiv, St. Yevhena, 20', '050-222-3333'),
(3, 'Auto Parts', 'Lviv, St. Franka, 10', '050-333-4444'),
(1, 'Electronics Co.', 'Odesa, St. Soborna, 25', '050-444-5555'),
(2, 'Furniture Ltd.', 'Kharkiv, St. Kurchatova, 5', '050-555-6666'),
(3, 'Sports Gear', 'Kyiv, St. Shevchenka, 30', '050-666-7777'),
(1, 'Books & Stationery', 'Odesa, St. Shevchenka, 40', '050-777-8888'),
(2, 'Health & Beauty', 'Dnipro, St. Pivdenna, 15', '050-888-9999'),
(3, 'Supplies', 'Lviv, St. Soborna, 8', '050-999-0000'),
(1, 'Food & Drinks', 'Kharkiv, St. Soborna, 5', '050-000-1111');


-- Вставка даних у таблицю Products
-- Вставка даних у таблицю Products
INSERT INTO Products (ID_User, ID_Supplier, Name, Brand, Price, Quantity)
VALUES
(1, 1, 'Laptop', 'HP', 1000.0, 50),
(2, 2, 'Laptop', 'Apple', 1200.0, 30),
(3, 3, 'Laptop', 'Lenovo', 900.0, 40),
(1, 1, 'Monitor', 'HP', 300.0, 25),
(2, 1, 'Printer', 'HP', 200.0, 20),
(3, 4, 'Sofa', 'IKEA', 500.0, 10),
(1, 5, 'Sofa', 'IKEA', 490.0, 12),
(2, 6, 'Bicycle', 'SportX', 250.0, 15),
(3, 6, 'Helmet', 'SafeRide', 80.0, 50),
(1, 6, 'Sneakers', 'Nike', 100.0, 35),
(2, 7, 'Notebook', 'Moleskine', 25.0, 60),
(3, 7, 'Pen', 'Pilot', 5.0, 100),
(1, 8, 'Shampoo', 'Loreal', 10.0, 200),
(2, 8, 'Conditioner', 'Loreal', 12.0, 150),
(3, 10, 'Dog Food', 'Pedigree', 20.0, 300),
(1, 10, 'Cat Food', 'Pedigree', 22.0, 250),
(2, 9, 'Dog Food', 'HomeCo', 21.0, 100),
(3, 2, 'Washing Machine', 'HomeCo', 450.0, 8);

-- Вставка даних у таблицю OrdersCl
INSERT INTO OrdersCl (ID_Product, ID_Client, ID_User, OrderStatus, Price, OrderDate)
VALUES
(1, 1, 1, 'Completed', 1000.0, '2025-03-01'),
(2, 2, 2, 'Pending', 500.0, '2025-03-02'),
(3, 3, 3, 'Cancelled', 100.0, '2025-03-03'),
(4, 4, 1, 'Completed', 300.0, '2025-03-04'),
(5, 5, 2, 'Pending', 250.0, '2025-03-05'),
(6, 6, 3, 'Completed', 25.0, '2025-03-06'),
(7, 7, 1, 'Completed', 15.0, '2025-03-07'),
(8, 8, 2, 'Cancelled', 10.0, '2025-03-08'),
(9, 9, 3, 'Completed', 20.0, '2025-03-09'),
(10, 10, 1, 'Pending', 1.5, '2025-03-10');


-- Вставка даних у таблицю Delivery
INSERT INTO Delivery (ID_Order, ID_User, AddressDl, DeliveryDate, DeliveryStatus)
VALUES
(1, 1, 'Kyiv, St. Shevchenka, 10', '2025-03-02', 'Shipped'),
(2, 2, 'Kyiv, St. Lesya, 5', '2025-03-03', 'Shipped'),
(3, 3, 'Lviv, St. Franka, 15', '2025-03-04', 'Cancelled'),
(4, 1, 'Kharkiv, St. Shevchenka, 20', '2025-03-05', 'Delivered'),
(5, 2, 'Odesa, St. Pushkina, 30', '2025-03-06', 'Shipped'),
(6, 3, 'Dnipro, St. Kotsiubynskoho, 8', '2025-03-07', 'Shipped'),
(7, 1, 'Kyiv, St. Bessarabka, 10', '2025-03-08', 'Delivered'),
(8, 2, 'Lviv, St. Soborna, 12', '2025-03-09', 'Cancelled'),
(9, 3, 'Kharkiv, St. Kurchatova, 40', '2025-03-10', 'Shipped'),
(10, 1, 'Odesa, St. Derybasivska, 5', '2025-03-11', 'Shipped');


-- Вставка даних у таблицю PaymentSys
INSERT INTO PaymentSys (ID_Order, ID_Client, ID_User, PaymentStatus, Price, PaymentDate)
VALUES
(1, 1, 1, 'Success', 1000.0, '2025-03-02'),
(2, 2, 2, 'Failed', 500.0, '2025-03-03'),
(3, 3, 3, 'Success', 100.0, '2025-03-04'),
(4, 4, 1, 'Success', 300.0, '2025-03-05'),
(5, 5, 2, 'Failed', 250.0, '2025-03-06'),
(6, 6, 3, 'Success', 25.0, '2025-03-07'),
(7, 7, 1, 'Success', 15.0, '2025-03-08'),
(8, 8, 2, 'Failed', 10.0, '2025-03-09'),
(9, 9, 3, 'Success', 20.0, '2025-03-10'),
(10, 10, 1, 'Success', 1.5, '2025-03-11');


-- Вставка даних у таблицю Warehouse
INSERT INTO Warehouse (ID_Supplier, ID_Product, ID_User, Quantity, Price)
VALUES
(1, 1, 1, 50, 1000.0),
(2, 2, 2, 30, 500.0),
(3, 3, 3, 100, 100.0),
(4, 4, 1, 70, 300.0),
(5, 5, 2, 40, 250.0),
(6, 6, 3, 200, 25.0),
(7, 7, 1, 500, 15.0),
(8, 8, 2, 150, 10.0),
(9, 9, 3, 250, 20.0),
(10, 10, 1, 1000, 1.5);


-- Вставка даних у таблицю Invoice
INSERT INTO Invoice(ID_PaymentSys, ID_User, Price)
VALUES
(1, 1, 1000.0),
(2, 2, 500.0),
(3, 3, 100.0),
(4, 1, 300.0),
(5, 2, 250.0),
(6, 3, 25.0),
(7, 1, 15.0),
(8, 2, 10.0),
(9, 3, 20.0),
(10, 1, 1.5);



SELECT * FROM Users;
SELECT * FROM Products;
SELECT * FROM OrdersCl;
SELECT * FROM Clients;
SELECT * FROM Suppliers;
SELECT * FROM Delivery;
SELECT * FROM PaymentSys;
SELECT * FROM Warehouse;
SELECT * FROM Invoice;
