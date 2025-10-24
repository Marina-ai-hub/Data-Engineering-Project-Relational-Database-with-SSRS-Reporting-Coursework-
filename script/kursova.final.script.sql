--================================================================
                        -- TRIGGER --
--================================================================
--- 1)	Приклад 1. Оновлення дати у таблиці Users при будь-яких змін у системі ----
CREATE TRIGGER trg_changes_monitoring_products 
ON Products
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Users
    SET ChangeDate = GETDATE()
    FROM Users u
    INNER JOIN inserted i ON u.ID_User = i.ID_User;
END;
GO

CREATE TRIGGER trg_changes_monitoring_orders
ON OrdersCl
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Users
    SET ChangeDate = GETDATE()
    FROM Users u
    INNER JOIN inserted i ON u.ID_User = i.ID_User;
END;
GO

CREATE TRIGGER trg_changes_monitoring_clients 
ON Clients
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Users
    SET ChangeDate = GETDATE()
    FROM Users u
    INNER JOIN inserted i ON u.ID_User = i.ID_User;
END;
GO

CREATE TRIGGER trg_changes_monitoring_suppliers
ON Suppliers
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Users
    SET ChangeDate = GETDATE()
    FROM Users u
    INNER JOIN inserted i ON u.ID_User = i.ID_User;
END;
GO

CREATE TRIGGER trg_changes_monitoring_delivery 
ON Delivery
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Users
    SET ChangeDate = GETDATE()
    FROM Users u
    INNER JOIN inserted i ON u.ID_User = i.ID_User;
END;
GO

CREATE TRIGGER trg_changes_monitoring_paymentSys
ON PaymentSys
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Users
    SET ChangeDate = GETDATE()
    FROM Users u
    INNER JOIN inserted i ON u.ID_User = i.ID_User;
END;
GO

CREATE TRIGGER trg_changes_monitoring_warehouse 
ON Warehouse
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Users
    SET ChangeDate = GETDATE()
    FROM Users u
    INNER JOIN inserted i ON u.ID_User = i.ID_User;
END;
GO

CREATE TRIGGER trg_changes_monitoring_invoice 
ON Invoice
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Users
    SET ChangeDate = GETDATE()
    FROM Users u
    INNER JOIN inserted i ON u.ID_User = i.ID_User;
END;
GO
--------------------- Перевірка роботи тригеру --------------------------
SELECT * FROM Products WHERE ID_Product = 1;
SELECT * FROM Users WHERE ID_User = 1;

UPDATE Products
SET Price = 1500
WHERE ID_Product = 1;

SELECT * FROM Products WHERE ID_Product = 1;
SELECT * FROM Users WHERE ID_User = 1;
------------------------------------------------------------------------

***--- 2)	Приклад 2. Оновлення статусу замовлення після здійснення платежу ----
CREATE TRIGGER trg_order_status_after_payment
ON PaymentSys
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE OrdersCl
    SET OrderStatus = 'Pending'
    FROM OrdersCl o
    INNER JOIN inserted i ON o.ID_Order = i.ID_Order
    WHERE i.PaymentStatus = 'Success';

	UPDATE OrdersCl
    SET OrderStatus = 'Cancelled'
    FROM OrdersCl o
    INNER JOIN inserted i ON o.ID_Order = i.ID_Order
    WHERE i.PaymentStatus = 'Failed';
END;
GO

--------------------- Перевірка роботи тригеру --------------------------
SELECT *  FROM OrdersCl WHERE ID_Client IN (1, 2);
SELECT *  FROM PaymentSys WHERE ID_PaymentSys IN (1, 2)

UPDATE PaymentSys
SET PaymentStatus = 'Failed'
WHERE ID_PaymentSys = 2;

UPDATE PaymentSys
SET PaymentStatus = 'Success'
WHERE ID_PaymentSys = 1;

SELECT *  FROM OrdersCl WHERE ID_Client IN (1, 2);
SELECT *  FROM PaymentSys WHERE ID_PaymentSys IN (1, 2)
------------------------------------------------------------------------------

***--- 3)	Приклад 3. Оновлення статусу доставки після здійснення замовлення ---
CREATE TRIGGER trg_delivery_order_status
ON Delivery
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Delivery
    SET DeliveryStatus = 'Shipped'  
    FROM Delivery d
    JOIN OrdersCl o ON d.ID_Order = o.ID_Order
    WHERE o.OrderStatus = 'Pending';

    UPDATE OrdersCl
    SET OrderStatus = 'Completed'
    FROM OrdersCl o
    JOIN inserted i ON o.ID_Order = i.ID_Order
    WHERE i.DeliveryStatus = 'Delivered';

    UPDATE OrdersCl
    SET OrderStatus = 'Cancelled'
    FROM OrdersCl o
    JOIN inserted i ON o.ID_Order = i.ID_Order 
    WHERE i.DeliveryStatus = 'Cancelled';
END;
GO

--------------------- Перевірка роботи тригеру --------------------------
SELECT o.ID_Client, d.ID_Delivery, o.OrderStatus, d.DeliveryStatus
FROM OrdersCl o
JOIN Delivery d
ON d.ID_Order = o.ID_Order
WHERE ID_Delivery IN (3, 5, 6) AND ID_Client IN (3, 5, 6) 

UPDATE OrdersCl
SET OrderStatus = 'Pending'
WHERE ID_Client = 3

UPDATE Delivery
SET DeliveryStatus = 'Delivered'
WHERE ID_Delivery = 5;

UPDATE Delivery
SET DeliveryStatus = 'Cancelled'
WHERE ID_Delivery = 6;

SELECT o.ID_Client, d.ID_Delivery, o.OrderStatus, d.DeliveryStatus
FROM OrdersCl o
JOIN Delivery d
ON d.ID_Order = o.ID_Order
WHERE ID_Delivery IN (3, 5, 6) AND ID_Client IN (3, 5, 6) 
----------------------------------------------------------------------

**--- 4)	Приклад 4. Оновлення кількості товарів на складі після видалення клієнтом замовлення або зміни кількості товарів ---
CREATE TRIGGER trg_update_warehouse_after_products_modification
ON Products
AFTER DELETE, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE w
        SET w.Quantity = w.Quantity + d.Quantity
        FROM Warehouse w
        JOIN DELETED d ON w.ID_Product = d.ID_Product;

    UPDATE w
        SET w.Quantity = w.Quantity - i.Quantity
        FROM Warehouse w
        JOIN DELETED d ON w.ID_Product = d.ID_Product
        JOIN INSERTED i ON d.ID_Product = i.ID_Product;
END;

--------------------- Перевірка роботи тригеру --------------------------
SELECT w.ID_Warehouse, p.ID_Product, p.Quantity AS ProductsQuantity, w.Quantity AS WarehouseQuantity
FROM Warehouse w
JOIN Suppliers s ON s.ID_Supplier=w.ID_Supplier
JOIN Products p ON p.ID_Supplier = s.ID_Supplier
WHERE p.ID_Product  =1 AND w.ID_Warehouse =1 

UPDATE Products 
SET Quantity = 39
WHERE ID_Product = 1

SELECT w.ID_Warehouse, p.ID_Product, p.Quantity AS ProductsQuantity, w.Quantity AS WarehouseQuantity
FROM Warehouse w
JOIN Suppliers s ON s.ID_Supplier= w.ID_Supplier
JOIN Products p ON p.ID_Supplier = s.ID_Supplier
WHERE p.ID_Product  =1 AND w.ID_Warehouse = 1 
------------------------------------------------------------------------------------

--================================================================
                        -- CURSOR --
--================================================================
---- 1) Приклад 1. Перевірка наявності товару перед обробкою замовлення ---- 
DECLARE @OrderID INT, @ProductID INT, @RequiredQuantity INT, @StockQuantity INT;

DECLARE order_cursor CURSOR FOR
SELECT o.ID_Order, o.ID_Product, p.Quantity 
FROM OrdersCl o
JOIN Products p ON o.ID_Product = p.ID_Product
WHERE o.OrderStatus = 'Pending';
OPEN order_cursor;
FETCH NEXT FROM order_cursor INTO @OrderID, @ProductID, @RequiredQuantity;
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Перевірка кількості товару на складі
    SELECT @StockQuantity = Quantity 
    FROM Warehouse 
    WHERE ID_Product = @ProductID;
    IF @StockQuantity >= @RequiredQuantity
    BEGIN
        -- Оновлення статусу замовлення
        UPDATE OrdersCl 
        SET OrderStatus = 'Completed' 
        WHERE ID_Order = @OrderID;
        -- Зменшення кількості товару на складі
        UPDATE Warehouse 
        SET Quantity = Quantity - @RequiredQuantity
        WHERE ID_Product = @ProductID;
    END
    FETCH NEXT FROM order_cursor INTO @OrderID, @ProductID, @RequiredQuantity;
END;
CLOSE order_cursor;
DEALLOCATE order_cursor;

---------------------------------------------------------------------------------

---- 2) Приклад 2. Загальний процес доставки замовлення ----
DECLARE @OrdersID INT,  @DeliveryID INT, @ClientID INT, @AddressDelivery VARCHAR(100), @AddressClient VARCHAR(100);

DECLARE delivery_cursor CURSOR FOR
SELECT o.ID_Order, d.ID_Delivery, c.ID_Client, d.AddressDl, c.AddressCl
FROM OrdersCl o
JOIN Delivery d ON o.ID_Order = d.ID_Order
JOIN PaymentSys p ON o.ID_Order = p.ID_Order
JOIN Clients c ON o.ID_Client = c.ID_Client
WHERE p.PaymentStatus = 'Success';
OPEN delivery_cursor;

FETCH NEXT FROM delivery_cursor INTO @OrdersID, @DeliveryID, @ClientID, @AddressDelivery, @AddressClient

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Після успішної оплати оновлення статусу замовлення
	UPDATE OrdersCl
    SET OrderStatus = 'Pending' 
    WHERE ID_Order = @OrdersID;

    -- Перевірка наявності адреси покупця та відповідності до адреси доставки
     IF @AddressDelivery IS NULL AND  @AddressClient IS NOT NULL  
	 BEGIN
		   UPDATE Delivery
	       SET AddressDl = @AddressClient   
	       WHERE ID_Delivery = @DeliveryID;

		   SET @AddressDelivery = @AddressClient;
	END

	-- Оновлення статусу доставки та встановлення приблизної дати отримання 
	 IF @AddressDelivery IS NOT NULL 
	   BEGIN 
	    UPDATE Delivery
	     SET DeliveryStatus = 'Shipped', 
		     DeliveryDate = DATEADD(DAY, 5, GETDATE())    
	     WHERE ID_Delivery = @DeliveryID;
	   END

    FETCH NEXT FROM delivery_cursor INTO @OrdersID, @DeliveryID, @ClientID, @AddressDelivery, @AddressClient;
END;

CLOSE delivery_cursor;
DEALLOCATE delivery_cursor;
---------------------------------------------------------------------------------

---- 3)	Приклад 3. Видача рахунку покупцю після успішної оплати ---
DECLARE @PaymentID INT, @OrderID INT, @ID_User INT, @Price FLOAT

DECLARE invoice_cursor CURSOR FOR
SELECT ID_PaymentSys, ID_Order, ID_User, Price
FROM PaymentSys
WHERE PaymentStatus = 'Success' 
  AND ID_PaymentSys NOT IN (SELECT ID_PaymentSys 
                            FROM Invoice)
OPEN invoice_cursor;
FETCH NEXT FROM invoice_cursor INTO @PaymentID, @OrderID, @ID_User, @Price;

WHILE @@FETCH_STATUS = 0
BEGIN
   -- Створення  рахунку
   
   INSERT INTO Invoice(ID_PaymentSys, ID_User, Price) 
   VALUES (@PaymentID, @ID_User, @Price);
END;

CLOSE invoice_cursor;
DEALLOCATE invoice_cursor;
GO
---------------------------------------------------------------


--================================================================
                        -- FUNCTION --
--================================================================
---- 1) Приклад 1. Підрахунок загальної кількості товарів на складі для певних постачальників -----
CREATE or ALTER FUNCTION fn_TotalWarehouse(@SupplierCompanyName NVARCHAR(255))
RETURNS INT
AS
BEGIN
    DECLARE @TotalStock INT;

    SELECT @TotalStock = SUM(Quantity) 
	FROM Warehouse w
	JOIN Suppliers s ON w.ID_Supplier = s.ID_Supplier
	WHERE s.CompanyName = @SupplierCompanyName;

    RETURN @TotalStock;
END;
--------------------- Перевірка роботи --------------------------
SELECT dbo.fn_TotalWarehouse('Tech Supplies') AS TotalStockForCompany
---------------------------------------------------------------------------

---- 2) Приклад 2. Інформація про замовлення клієнта для заданої компанії або назви бренду ----
Alter FUNCTION fn_TotalOrdersPriceByCompanyORBrand(@BrandOrCompanyName VARCHAR(255))
RETURNS TABLE
AS
RETURN (
    SELECT 
        c.ID_Client, c.FirstName, c.LastName, SUM(o.Price) AS TotalOrder
    FROM Clients c
    JOIN OrdersCl o ON c.ID_Client = o.ID_Client  
    JOIN Products p ON p.ID_Product = o.ID_Product  
    JOIN Suppliers s ON s.ID_Supplier = p.ID_Supplier
    WHERE s.CompanyName = @BrandOrCompanyName OR p.Brand = @BrandOrCompanyName
    GROUP BY c.ID_Client, c.FirstName, c.LastName
);

--------------------- Перевірка роботи --------------------------
SELECT * FROM dbo.fn_TotalOrdersPriceByCompanyORBrand('Nike')
UNION 
SELECT * FROM dbo.fn_TotalOrdersPriceByCompanyORBrand('Tech Supplies')
---------------------------------------------------------------------------------


--================================================================
                        -- PROCEDURE --
--================================================================

CREATE OR ALTER PROCEDURE myProductPriceMaxMin
 @Name VARCHAR(75) = null, 
 @Price FLOAT = null
AS 
BEGIN
   SELECT MaxProduct.Name AS MaxProductName, 
          MaxProduct.Brand AS MaxProductBrand,
          MaxProduct.Price AS MaxProductPrice,
		  MaxProduct.Quantity AS MaxProductQuantity,
		  MinProduct.Name AS MinProductName, 
		  MaxProduct.Brand AS MinProductBrand,
          MinProduct.Price AS MinProductPrice,
		  MinProduct.Quantity AS MinProductQuantity
    FROM (SELECT TOP 1 Name, Brand, Price, Quantity 
	      FROM Products 
	      WHERE Name LIKE @Name AND Price <= @Price
          ORDER BY Price DESC) AS MaxProduct

	CROSS JOIN( SELECT TOP 1 Name, Brand, Price, Quantity
	FROM Products 
	WHERE Name LIKE @Name AND Price <= @Price
    ORDER BY Price ASC) AS MinProduct
END;
GO
-- Виконання процедури
DECLARE  @retminbrand VARCHAR(75), @retmin FLOAT, @retmax FLOAT,  @retmaxbrand VARCHAR(75), @retrows INT;

EXEC myProductPriceMaxMin  
    @Name = 'Sofa', 
    @Price = 500

-- Вивід результату
SELECT * FROM Products

 
--- 2) Приклад 2. Інформація про товар  за заданою брендом та типом. Виведення різних постачальників такого товару---
CREATE OR ALTER PROCEDURE FindProductForNameBrand
  @Name VARCHAR(75) = null, @Brand VARCHAR(75) = null
 AS
 BEGIN 
    SELECT w.ID_Product, p.Name, p.Brand, s.CompanyName, p.Price, 
            p.Quantity AS ShopQuantity,  w.Quantity AS StockQuantity,  SUM(w.Quantity) AS Total_Quantity
    FROM Warehouse w
    JOIN OrdersCl o ON w.ID_Product = o.ID_Product
    LEFT JOIN Products p ON w.ID_Product = p.ID_Product 
    JOIN Suppliers s ON s.ID_Supplier = p.ID_Supplier
	WHERE ((@Name IS NULL OR LOWER(p.Name) LIKE LOWER('%' + @Name + '%'))
            AND 
            (@Brand IS NULL OR LOWER(p.Brand) LIKE LOWER('%' + @Brand + '%')))
    GROUP BY w.ID_Product, p.Name, p.Brand, s.CompanyName, p.Price, 
            p.Quantity, w.Quantity
	ORDER BY Total_Quantity  DESC 
  END;
GO

--------------------- Перевірка роботи --------------------------
EXEC FindProductForNameBrand  @Name = 'Laptop', @Brand = 'HP'
------------------------------------------------------------------
------------------------------------------------------------------

--- 3) Приклад 3. Інформація про замовлення за заданим статусом оплати  ---
CREATE OR ALTER PROCEDURE FindPayments
  @PaymentStatus VARCHAR(75)
 AS
 BEGIN 
    SELECT ps.ID_PaymentSys, o.ID_Order, 
	       c.ID_Client, c.FirstName,  c.LastName, c.Email, c.Phone, 
		   c.Invoice, ps.Price, ps.PaymentDate
    FROM PaymentSys ps
	JOIN OrdersCl o ON o.ID_Order = ps.ID_Order
	JOIN Clients c ON c.ID_Client = o.ID_Client
	JOIN Invoice i ON i.ID_PaymentSys = ps.ID_PaymentSys
	JOIN Products p ON p.ID_Product = o.ID_Product
	--WHERE PaymentStatus LIKE @PaymentStatus 
	ORDER BY ps.Price DESC 
  END;
GO
------- Перевірка роботи --------
EXEC FindPayments  @PaymentStatus = 'Failed'
UNION 
EXEC FindPayments  @PaymentStatus = 'Success'
-------------------------


--- 4) Приклад 4. Повна інформація про замовлення за заданими статусами  ---
CREATE OR ALTER PROCEDURE AllStatusOrder
    @PaymentStatus VARCHAR(75) = null,
	@OrderStatus VARCHAR(75) = null,
	@DeliveryStatus VARCHAR(75) = null
  AS
    BEGIN 
	   SELECT c.LastName, c.FirstName, c.Email, c.Phone, c.AddressCl,
          p.Name AS ProductName, p.Brand AS ProductBrand, p.Quantity,
		   c.Invoice, i.Price AS InvoiceSum, convert(varchar, o.OrderDate, 4) AS OrderDate, convert(varchar, ps.PaymentDate, 4) AS PaymentDate, 
		   o.OrderStatus, ps.PaymentStatus,d.DeliveryStatus
   FROM PaymentSys ps
	LEFT JOIN OrdersCl o ON o.ID_Order = ps.ID_Order
	LEFT JOIN Clients c ON c.ID_Client = o.ID_Client
	LEFT JOIN Invoice i ON i.ID_PaymentSys = ps.ID_PaymentSys
	LEFT JOIN Products p ON p.ID_Product = o.ID_Product
	LEFT JOIN Delivery d ON o.ID_Order = d.ID_Order
	WHERE ((PaymentStatus LIKE @PaymentStatus) OR (@PaymentStatus IS NULL)
	     AND (OrderStatus LIKE @OrderStatus) OR (@OrderStatus IS NULL)
		 AND (DeliveryStatus LIKE @DeliveryStatus) OR (@DeliveryStatus IS NULL));
  END;
GO

--- 5) Приклад 5. Процедура для зміни статусу доставки
CREATE OR ALTER PROCEDURE ChangeStatusDelivery
    @OrderID INT, @NewDeliveryStatus VARCHAR(75)
  AS BEGIN
     UPDATE Delivery
	 SET DeliveryStatus = @NewDeliveryStatus
	 WHERE ID_Order = @OrderID;
   END;
 GO
 ------- Перевірка роботи --------
 EXEC ChangeStatusDelivery  @OrderID = 5, @NewDeliveryStatus = 'Delivered'
 SELECT * FROM Delivery
 -------------------------

 SELECT *
FROM sys.procedures

 -- 5) Процедура для додавання нового рядка в таблиці складу Warehouse
CREATE OR ALTER PROCEDURE InsertIntoWarehouse
    @NewIDSupplier INT, @NewIDProduct INT, @NewIDUser INT, @NewIDQuantity INT, @NewPrice FLOAT
  AS BEGIN
     INSERT INTO Warehouse (ID_Supplier, ID_Product, ID_User, Quantity, Price)
	 VALUES (@NewIDSupplier, @NewIDProduct, @NewIDUser, @NewIDQuantity, @NewPrice);
   END;
 GO

------- Перевірка роботи --------
SELECT * FROM Warehouse

EXEC InsertIntoWarehouse 10, 7, 9, 57, 1000.0
SELECT * FROM Warehouse
  -------------------------



CREATE PROCEDURE RegisterAsCustomer
CREATE PROCEDURE RegisterAsSupplier
CREATE PROCEDURE UpdateIfoAsCustomer
CREATE PROCEDURE UpdateIfoAsSupplier
CREATE PROCEDURE MakeOrder
CREATE PROCEDURE UpdateStockQuantity
CREATE PROCEDURE UpdateStockPrice
CREATE PROCEDURE UpdateOrderQuantity
CREATE PROCEDURE UpdateDeliveryAdress
CREATE PROCEDURE UpdateInvoice





  --================================================================
                        -- VIEW --
--================================================================

-- 1) Інформація про продажі товарів
CREATE VIEW ViewProductSalesSummary AS
SELECT 
    P.Name AS ProductName,
    P.Brand,
    SUM(p.Quantity) AS TotalQuantitySold,
    SUM(p.Price * p.Quantity) AS TotalRevenue
FROM Products p
JOIN OrdersCl o ON p.ID_Product = o.ID_Product
GROUP BY P.Name, P.Brand;


-- 2) Чек замовлення клієнтів 
CREATE OR ALTER VIEW ViewInvoicet AS
SELECT 
    I.ID_Invoice,
    C.LastName + ' ' + C.FirstName AS ClientName,
    PS.Price AS PaymentAmount,
    PS.PaymentStatus,
    PS.PaymentDate
FROM Invoice I
JOIN PaymentSys PS ON I.ID_PaymentSys = PS.ID_PaymentSys
JOIN Clients C ON PS.ID_Client = C.ID_Client;


-- 3) Історія замовлення клієнтів 
CREATE OR ALTER  VIEW ViewClientOrders AS
SELECT 
    o.ID_Order, C.LastName + ' ' + C.FirstName AS ClientName,
    P.Name AS ProductName, P.Brand AS ProductBrand,
    FORMAT(O.OrderDate, 'dd/MM/yyyy') as OrderDate, 
    O.OrderStatus,
	D.DeliveryStatus,
    O.Price
FROM OrdersCl O
JOIN Clients C ON O.ID_Client = C.ID_Client
JOIN Products P ON O.ID_Product = P.ID_Product
LEFT JOIN Delivery D ON D.ID_Order = O.ID_Order;

SELECT * FROM ViewClientOrders
-- 4) Виведення інформації про товар на складі--

CREATE VIEW ViewStockProducts
AS SELECT w.ID_Product, p.Name, p.Brand, s.CompanyName, 
          SUM(w.Quantity) AS TotalQuantity, SUM(w.Price) AS TotalPrice
FROM Warehouse w
JOIN OrdersCl o ON w.ID_Product = o.ID_Product
LEFT JOIN Products p ON w.ID_Product = p.ID_Product 
JOIN Suppliers s ON s.ID_Supplier = p.ID_Supplier
GROUP BY w.ID_Product, p.Name, p.Brand , s.CompanyName;
GO

-- 5) Статуси замовлень клієнтів
CREATE VIEW ViewClientOrdersHistory AS
SELECT o.ID_Order, C.LastName + ' ' + C.FirstName AS ClientName, p.Name AS Product,
         o.OrderStatus, ps.PaymentStatus, d.DeliveryStatus, o.Price
FROM OrdersCl o
JOIN Clients c ON o.ID_Client = c.ID_Client
JOIN Products p ON o.ID_Product = p.ID_Product
LEFT JOIN Delivery d ON o.ID_Order = d.ID_Order
LEFT JOIN PaymentSys ps ON o.ID_Order = ps.ID_Order
LEFT JOIN Invoice i ON i.ID_PaymentSys = ps.ID_PaymentSys

ORDER BY LastName, Price DESC;

-- 6) Виведення інформації про успішні оплати для подальшої доставки товару до клієнтів --
CREATE VIEW ViewSuccessPayments AS
SELECT o.ID_Order,pr.Name AS ProductName, c.FirstName, c.LastName, c.Phone, c.AddressCl
FROM Clients c
JOIN PaymentSys p
  ON p.ID_Client = c.ID_Client
JOIN OrdersCl o
  ON o.ID_Client = c.ID_Client
JOIN Products pr
  ON pr.ID_Product = o.ID_Product
WHERE p.PaymentStatus = 'Success'
GO

-- 7) Виведення рахунків замовлень клієнтів --
CREATE VIEW ViewClientsInvoices AS
SELECT c.LastName + ' ' + c.FirstName AS ClientName, c.Invoice,  SUM(DISTINCT i.Price) AS TotalSum, p.PaymentDate
FROM Invoice i
JOIN PaymentSys p
 ON i.ID_PaymentSys = p.ID_PaymentSys
JOIN Clients c
  ON c.ID_Client = p.ID_Client
JOIN OrdersCl o ON c.ID_Client = p.ID_Client
WHERE p.PaymentStatus = 'Success'
GROUP BY  c.Invoice, p.PaymentDate, c.LastName, c.FirstName;


-- 8) Інформація про клієнта для відділу логістики доставки --
ALTER VIEW ViewLogisticInfo AS (
   SELECT d.ID_Order, c.FirstName, c.LastName, c.Phone, d.AddressDl, convert(varchar, d.DeliveryDate, 4) AS DeliveryDate, d.DeliveryStatus
   FROM Delivery d 
   JOIN OrdersCl o ON o.ID_Order = d.ID_Order
   JOIN Clients c ON o.ID_Client = c.ID_Client
)

SELECT * FROM ViewLogisticInfo


-- 9) Інформація про компанії, ціль - визначити найприбутковіших постачальників магазину
ALTER VIEW ViewCompanyProductSales AS
SELECT 
    s.CompanyName, 
    p.Name AS ProductName, 
    p.Brand, 
	ps.PaymentDate,
	SUM(p.Quantity) AS TotalSales,
	COUNT(DISTINCT c.ID_Client) AS TotalClients,
	SUM(i.Price) AS TotalRevenue
FROM OrdersCl o
LEFT JOIN Clients c ON c.ID_Client = o.ID_Client
LEFT JOIN Products p ON o.ID_Product = p.ID_Product
LEFT JOIN PaymentSys ps ON o.ID_Order = ps.ID_Order
LEFT JOIN Invoice i ON ps.ID_PaymentSys = i.ID_PaymentSys
LEFT JOIN Suppliers s ON s.ID_Supplier = p.ID_Supplier
WHERE ps.PaymentStatus = 'Success'
GROUP BY 
    s.CompanyName, 
    p.Name, 
    p.Brand, 
	ps.PaymentDate
GO

SELECT * FROM ViewCompanyProductSales
ORDER BY TotalRevenue;

SELECT * FROM ViewProductSalesSummary
SELECT * FROM ViewInvoicet
SELECT * FROM ViewClientOrders
SELECT * FROM ViewStockProducts
SELECT * FROM ViewClientOrders
SELECT * FROM ViewClientOrdersHistory
SELECT * FROM ViewSuccessPayments
SELECT * FROM ViewClientsInvoices
SELECT * FROM ViewLogisticInfo


--=================================================================================
--  Database-level roles для надання доступу реальним користувачам (для внутрішнії кориистувачів БД) 
--=================================================================================

-- Системнй адміністратор (вносить всі зміни)
-- Access all files and data within the corporate network
CREATE LOGIN sys_admin_user WITH PASSWORD = 'SysPa$$w0rd';
USE WebShopDB;
CREATE USER sys_admin_user FOR LOGIN sys_admin_user;
ALTER ROLE db_owner ADD MEMBER sys_admin_user;

-- Аналітик 
-- доступ для читання таблиць, уявлень і функцій
CREATE LOGIN analyst_user WITH PASSWORD = 'AnalystPa$$w0rd';
CREATE USER analyst_user FOR LOGIN analyst_user;
ALTER ROLE db_datareader ADD MEMBER analyst_user;

-- Менеджер  (або керівник інтернет-магазину)
-- 	Виконання DDL-інструкцій (створення, зміна, видалення об'єктів бази даних)
CREATE LOGIN e_manager_user WITH PASSWORD = 'ManagerPa$$w0rd';
CREATE USER e_manager_user FOR LOGIN e_manager_user;
ALTER ROLE db_ddladmin ADD MEMBER e_manager_user;

-- бухгалтер – доступ лише до фінансових таблиць та товарів
CREATE LOGIN sales_user WITH PASSWORD = 'SalesPa$$w0rd';
CREATE USER sales_user FOR LOGIN sales_user;
GRANT SELECT ON PaymentSys TO sales_user;
GRANT SELECT ON Clients TO sales_user;
GRANT SELECT ON OrdersCl TO sales_user;
GRANT SELECT ON Invoice TO sales_user;
GRANT SELECT ON Products TO sales_user;
GRANT SELECT ON Warehouse TO sales_user;
GO

-- Відділ логістики  – доступ до інформації про замовлення, клієнтів і доставку
CREATE LOGIN logistic_user WITH PASSWORD = 'LogisticPa$$w0rd';
CREATE USER logistic_user FOR LOGIN logistic_user;
GRANT SELECT ON Delivery TO logistic_user;
GRANT SELECT ON OrdersCl TO logistic_user;
GRANT SELECT ON Clients TO logistic_user;
GO


--=================================================================================
--  Application Role для зовнішніх користувачів (клієнти, постачальники, доставка)  
-- не мають прямого SQL-доступу
-- працюють через зовнішні додатки (які можливо будуть у майбутньому),
-- повинні мати мінімальні права, строго обмежені.
--=================================================================================

-- Клієнти магазину
-- переглядати та оновлювати замовлення, переглядати інформацію про товари
-- переглядати свою особисту інформацію про себе, доставку, інвойси, 
CREATE APPLICATION ROLE client_app_role WITH PASSWORD = 'ClientPa$$w0rd';

-- Постачальник магазину 
-- переглядати рахунки; змінювати інформацію про склад, продукти, особисті дані 
CREATE APPLICATION ROLE supplier_app_role WITH PASSWORD = 'SupplierPa$$w0rd';


-- кур'єр
-- переглядати та оновлювати (для статусу) інформацію про доставку
CREATE APPLICATION ROLE delivery_app_user WITH PASSWORD = 'DeliveryPa$$w0rd';



--========================================================================
                   -- Надання дозволу --
--========================================================================
------ 1. репорт 1
GRANT SELECT, UPDATE, INSERT ON ViewClientOrders TO e_manager_user, sys_admin_user
GRANT SELECT ON ViewClientOrders TO analyst_user

------ 2. репорт 2
GRANT EXECUTE ON FindProductForNameBrand TO e_manager_user, sys_admin_user
GRANT EXECUTE ON FindProductForNameBrand TO analyst_user


------ 3. репорт 3
GRANT SELECT, UPDATE ON ViewClientsInvoices TO e_manager_user, sales_user
GRANT SELECT, UPDATE ON ViewClientsInvoices TO e_manager_user, sales_user
GRANT SELECT ON ViewSuccessPayments TO analyst_user
GRANT SELECT, UPDATE ON ViewSuccessPayments TO e_manager_user, sales_user
GRANT SELECT, UPDATE, INSERT ON ViewSuccessPayments TO sys_admin_user

------ 4. репорт 4
GRANT SELECT, UPDATE ON ViewLogisticInfo TO e_manager_user,logistic_user
GRANT SELECT, UPDATE, INSERT ON ViewLogisticInfo TO sys_admin_user

------ 5. репорт 5
GRANT SELECT ON ViewCompanyMonthSales TO analyst_user, e_manager_user
GRANT SELECT, UPDATE, INSERT ON ViewCompanyMonthSales TO sys_admin_user

------ 6. репорт 6
GRANT EXECUTE ON ChangeStatusDelivery TO delivery_app_user ;

------ 7. репорт 7
GRANT SELECT ON ViewCompanyProductSales TO analyst_user, e_manager_user, sales_user


--====================================================================                     
         -- client_app_role  -- 
--====================================================================
-- Клієнти магазину
-- переглядати та оновлювати замовлення, переглядати інформацію про товари
-- переглядати свою особисту інформацію про себе, доставку, інвойси, 
---------------------------------------------------------------------------
CREATE APPLICATION ROLE client_app_role WITH PASSWORD = 'ClientPa$$w0rd';

GRANT EXECUTE ON pr_RegisterAsCustomer TO client_app_role;
GRANT EXECUTE ON pr_AddInvoice TO client_app_role;
GRANT EXECUTE ON pr_UpdateIfoAsCustomer TO client_app_role;
GRANT EXECUTE ON FindProductForNameBrand TO client_app_role;
GRANT EXECUTE ON pr_MakeOrder TO client_app_role;
GRANT EXECUTE ON pr_UpdateOrderQuantity TO client_app_role;
GRANT EXECUTE ON pr_ViewPersonalOrders TO client_app_role;
GRANT SELECT ON vw_Catalog TO client_app_role;


 --- 1. Процедура для реєстрації користувача
CREATE OR ALTER PROCEDURE pr_RegisterAsCustomer
   @IPAdresse VARCHAR(50),
   @FirstName VARCHAR(50), 
   @LastName VARCHAR(50),
   @AddressCl VARCHAR(50), 
   @Phone VARCHAR(50), 
   @Email VARCHAR(50),
   @Invoice VARCHAR(50) = NULL
AS
BEGIN 
    SET NOCOUNT ON;

    DECLARE @NewUserID INT;

	SELECT @NewUserID = ID_User 
	FROM Users
	WHERE IPAdresse = @IPAdresse;

	IF @NewUserID IS NULL
	 BEGIN INSERT INTO Users(IPAdresse)
	      VALUES(@IPAdresse);
          SET @NewUserID = SCOPE_IDENTITY();
     END

    -- Додаємо клієнта з прив’язкою до ID_User
    INSERT INTO Clients (ID_User, FirstName, LastName, AddressCl, Phone, Email, Invoice)
    VALUES (@NewUserID, @FirstName, @LastName, @AddressCl, @Phone, @Email, @Invoice);
END;
GO

DECLARE @cookie VARBINARY(8000);
  -- Вмикаємо application role
EXEC sp_setapprole 
    @rolename = 'client_app_role',
    @password = 'ClientPa$$w0rd',
    @fCreateCookie = 1,
    @cookie = @cookie OUTPUT;

EXEC pr_RegisterAsCustomer
    @IPAdresse = '192.168.0.6',
    @FirstName = 'Vadym',
    @LastName = 'Ivanov',
    @AddressCl = 'Lviv, St. Rynok, 12',
    @Phone = '093-123-4567',
    @Email = 'oleg@gmail.com',
    @Invoice = 'INV016';
    -- Вимикаємо application role
EXEC sp_unsetapprole @cookie;

SELECT * FROM Clients


DELETE FROM Clients
WHERE ID_User = 4

 --- 2. Процедура для того щоб додавати рахок користувачу
CREATE OR ALTER PROCEDURE pr_AddInvoice
   @Invoice VARCHAR(50),
   @ID_Client INTEGER
AS BEGIN 
   UPDATE Clients 
   SET Invoice = @Invoice
   WHERE ID_Client = @ID_Client;
END;
GO

DECLARE @cookie VARBINARY(8000);
  -- Вмикаємо application role
EXEC sp_setapprole 
    @rolename = 'client_app_role',
    @password = 'ClientPa$$w0rd',
    @fCreateCookie = 1,
    @cookie = @cookie OUTPUT;

EXEC pr_AddInvoice
    @ID_Client = 3,
    @Invoice = 'INV12';
    -- Вимикаємо application role
EXEC sp_unsetapprole @cookie;



 --- 3. Процедура для оновлення особистої інформації клієнта
 CREATE OR ALTER PROCEDURE pr_UpdateIfoAsCustomer
   @ID_Client INTEGER,
   @AddressCl VARCHAR(50)= NULL, 
   @Phone VARCHAR(50)= NULL, 
   @Email VARCHAR(50)= NULL
   --, @FirstName VARCHAR(50), 
  -- @LastName VARCHAR(50)
AS BEGIN 
   IF @Phone IS NOT NULL
      UPDATE Clients 
      SET Phone = @Phone WHERE ID_Client = @ID_Client

	IF @AddressCl IS NOT NULL 
	   UPDATE Clients 
	   SET AddressCl = @AddressCl WHERE ID_Client = @ID_Client

    IF @Email IS NOT NULL
	   UPDATE Clients
	   SET Email = @Email WHERE ID_Client = @ID_Client
END;
GO

DECLARE @cookie VARBINARY(8000);
  -- Вмикаємо application role
EXEC sp_setapprole 
    @rolename = 'client_app_role',
    @password = 'ClientPa$$w0rd',
    @fCreateCookie = 1,
    @cookie = @cookie OUTPUT;

EXEC pr_UpdateIfoAsCustomer
    @ID_Client = 3,
    @AddressCl = 'Lviv, St. Rynok, 12',
    @Phone = '093-123-4567',
    @Email = 'oleg@gmail.com';
    -- Вимикаємо application role
EXEC sp_unsetapprole @cookie;


--- 4. Процедура пошуку товару за заданими користувачем параметрами бренду або типу товару
CREATE OR ALTER PROCEDURE FindProductForNameBrand
  @Name VARCHAR(75) = null, @Brand VARCHAR(75) = null
 AS
 BEGIN 
    SELECT w.ID_Product, p.Name, p.Brand, s.CompanyName, p.Price, 
            p.Quantity AS ShopQuantity,  w.Quantity AS StockQuantity,  SUM(w.Quantity) AS Total_Quantity
    FROM Warehouse w
    JOIN OrdersCl o ON w.ID_Product = o.ID_Product
    LEFT JOIN Products p ON w.ID_Product = p.ID_Product 
    JOIN Suppliers s ON s.ID_Supplier = p.ID_Supplier
	WHERE ((@Name IS NULL OR LOWER(p.Name) LIKE LOWER('%' + @Name + '%'))
            AND 
            (@Brand IS NULL OR LOWER(p.Brand) LIKE LOWER('%' + @Brand + '%')))
    GROUP BY w.ID_Product, p.Name, p.Brand, s.CompanyName, p.Price, 
            p.Quantity, w.Quantity
	ORDER BY Total_Quantity  DESC 
  END;
GO

EXEC FindProductForNameBrand  @Name = 'Laptop', @Brand = 'HP'


EXEC FindProductForNameBrand 

--- 5. Процедура здійснення замовлення
CREATE OR ALTER PROCEDURE pr_MakeOrder
   @IPAdresse VARCHAR(50),
   @Name VARCHAR(50) = null,
   @Brand VARCHAR(50) = null,
   @ID_Product INTEGER = null,
   @ID_Client INTEGER,
   @Quantity INTEGER
AS BEGIN
    SET NOCOUNT ON;
	DECLARE @NewUserID INT;

	SELECT @NewUserID = ID_User 
	FROM Users
	WHERE IPAdresse = @IPAdresse;

	IF @NewUserID IS NULL
	 BEGIN INSERT INTO Users(IPAdresse)
	      VALUES(@IPAdresse);
          SET @NewUserID = SCOPE_IDENTITY();
     END

	IF @ID_Product IS NULL
	 BEGIN SELECT @ID_Product = ID_Product 
	 FROM Products
	 WHERE Name = @Name AND Brand = @Brand;
	END

   INSERT INTO OrdersCl (ID_Product, ID_Client, ID_User, OrderStatus, Price, OrderDate)
     SELECT @ID_Product, @ID_Client, @NewUserID, 'Pending', Price * @Quantity, GETDATE()
     FROM Products 
     WHERE ID_Product = @ID_Product;
END;
GO


DECLARE @cookie VARBINARY(8000);
EXEC sp_setapprole 
    @rolename = 'client_app_role',
    @password = 'ClientPa$$w0rd',
    @fCreateCookie = 1,
    @cookie = @cookie OUTPUT;

EXEC pr_MakeOrder
    @IPAdresse = '192.168.0.1',
	@ID_Client = 3,
	@Name = 'Laptop', 
	@Brand = 'HP',
    @Quantity = 2;
    -- Вимикаємо application role
EXEC sp_unsetapprole @cookie;

SELECT * FROM OrdersCl

--- 6. Процедура зміни кількості товару у замовленні --> оновлення суми замовлення
CREATE OR ALTER PROCEDURE pr_UpdateOrderQuantity
   @ID_Order INTEGER,
   @ID_Product INTEGER,
   @Quantity INTEGER
AS BEGIN 
   SET NOCOUNT ON;
  UPDATE p
        SET p.Quantity = @Quantity
		FROM Products p
        JOIN OrdersCl o ON o.ID_Product = p.ID_Product
	    WHERE o.ID_Order = @ID_Order AND o.ID_Product = @ID_Product

  UPDATE o
        SET o.Price = @Quantity * p.Price
		FROM OrdersCl o 
		JOIN Products p ON o.ID_Product = p.ID_Product
	    WHERE o.ID_Order = @ID_Order AND o.ID_Product = @ID_Product
END;
GO
 
DECLARE @cookie VARBINARY(8000);
EXEC sp_setapprole 
    @rolename = 'client_app_role',
    @password = 'ClientPa$$w0rd',
    @fCreateCookie = 1,
    @cookie = @cookie OUTPUT;

EXEC pr_UpdateOrderQuantity
	@ID_Order = 12,
	@ID_Product = 9,
    @Quantity = 1;
    -- Вимикаємо application role
EXEC sp_unsetapprole @cookie;

SELECT p.Quantity, o.Price, o.ID_Order, o.ID_Product AS OdPrOrd, p.ID_Product AS OdPrPr
FROM Products p
JOIN OrdersCl o ON o.ID_Product = p.ID_Product


--- 7. Процедура перегляду замовлення 
CREATE OR ALTER PROCEDURE pr_ViewPersonalOrders
   @ID_Order INTEGER
AS BEGIN 
   SELECT * FROM ViewClientOrders vw
   WHERE vw.ID_Order = @ID_Order
END;
GO
 
DECLARE @cookie VARBINARY(8000);
EXEC sp_setapprole 
    @rolename = 'client_app_role',
    @password = 'ClientPa$$w0rd',
    @fCreateCookie = 1,
    @cookie = @cookie OUTPUT;

EXEC pr_ViewPersonalOrders
	@ID_Order = 3;
    -- Вимикаємо application role
EXEC sp_unsetapprole @cookie;

--- 8. Перегляд всіх товарів
CREATE VIEW vw_Catalog 
AS SELECT Name, Brand, Price, Quantity
FROM Products;


--====================================================================
                    -- supplier_app_role -- 
--====================================================================
-- Постачальник магазину 
-- переглядати рахунки; змінювати інформацію про склад, продукти, особисті дані 
CREATE APPLICATION ROLE supplier_app_role WITH PASSWORD = 'SupplierPa$$w0rd';

GRANT EXECUTE ON pr_RegisterAsSupplier TO supplier_app_role;
GRANT EXECUTE ON pr_UpdateIfoAsSupplier TO supplier_app_role;
GRANT EXECUTE ON pr_UpdateStock TO supplier_app_role;
GRANT EXECUTE ON pr_ProductStock TO supplier_app_role;


 --- 1. Процедура для реєстрації постачальника
 CREATE OR ALTER PROCEDURE pr_RegisterAsSupplier
     @IPAdresse VARCHAR(75),
     @CompanyName VARCHAR(75), 
     @AddressSp VARCHAR(75), 
     @Phone VARCHAR(75)
 AS BEGIN
    SET NOCOUNT ON;

    DECLARE @NewUserID INT;

	SELECT @NewUserID = ID_User 
	FROM Users
	WHERE IPAdresse = @IPAdresse;

	IF @NewUserID IS NULL
	 BEGIN INSERT INTO Users(IPAdresse)
	      VALUES(@IPAdresse);
          SET @NewUserID = SCOPE_IDENTITY();
     END

    INSERT INTO Suppliers (ID_User, CompanyName, AddressSp, Phone)
    VALUES (@NewUserID, @CompanyName, @AddressSp,@Phone)
END;
GO

DECLARE @cookie varbinary(8000);
EXEC sp_setapprole 
    @rolename = 'supplier_app_role',
    @password = 'SupplierPa$$w0rd',
    @fCreateCookie = 1,
    @cookie = @cookie OUTPUT;

EXEC pr_RegisterAsSupplier
     @IPAdresse = '192.168.0.6',
     @CompanyName = 'Auto Parts', 
     @AddressSp = 'Odessa, St. Romashka, 1',  
     @Phone = '067-224-1363'
EXEC sp_unsetapprole @cookie;


 ====--- 2. Процедура для перегляду складу 
CREATE OR ALTER PROCEDURE pr_ProductStock 
   @ID_Supplier INTEGER
 AS BEGIN 
   SELECT p.Name, p.Brand, w.Quantity, w.Price
   FROM Warehouse w
   LEFT JOIN Suppliers s ON s.ID_Supplier = w.ID_Supplier
   LEFT JOIN Products p ON p.ID_Supplier = w.ID_Supplier
   WHERE @ID_Supplier = w.ID_Supplier
END;
GO

DECLARE @cookie varbinary(8000);
EXEC sp_setapprole 
    @rolename = 'supplier_app_role',
    @password = 'SupplierPa$$w0rd',
    @fCreateCookie = 1,
    @cookie = @cookie OUTPUT;

EXEC pr_ProductStock
     @ID_Supplier = 1
EXEC sp_unsetapprole @cookie;


 --- 3. Процедура для оновлення контактних даних про постачальника
CREATE OR ALTER PROCEDURE pr_UpdateIfoAsSupplier 
    @ID_Supplier INTEGER,
	@CompanyName VARCHAR(75) = null,
	@AddressSp VARCHAR(200) = null,
	@Phone VARCHAR(200) = null
 AS BEGIN 
     IF @CompanyName IS NOT NULL
	 UPDATE Suppliers 
	 SET CompanyName = @CompanyName
	 WHERE ID_Supplier = @ID_Supplier
	 
	 IF @AddressSp IS NOT NULL
	 UPDATE Suppliers 
	 SET AddressSp = @AddressSp
	 WHERE ID_Supplier = @ID_Supplier

	 IF @Phone IS NOT NULL
	 UPDATE Suppliers 
	 SET Phone = @Phone
	 WHERE ID_Supplier = @ID_Supplier
END;
GO

DECLARE @cookie varbinary(8000);
EXEC sp_setapprole 
    @rolename = 'supplier_app_role',
    @password = 'SupplierPa$$w0rd',
    @fCreateCookie = 1,
    @cookie = @cookie OUTPUT;

EXEC pr_UpdateIfoAsSupplier
    @ID_Supplier = 8,
	@CompanyName = 'Food & Drinks',
	@AddressSp = 'Dnipro, St. Pivdenna, 15',
	@Phone = '050-845-7161'
EXEC sp_unsetapprole @cookie;



 --- 3. Процедура для оновлення товарів та складі 
CREATE OR ALTER PROCEDURE pr_UpdateStock
    @ID_Supplier INTEGER,
	@ID_Product INTEGER,
	@ID_Warehouse INTEGER,
	@Quantity INTEGER = null,
	@Price FLOAT = null
 AS BEGIN 
     IF @Quantity IS NOT NULL
	 UPDATE Warehouse 
	 SET Quantity = @Quantity
	 WHERE @ID_Warehouse = ID_Warehouse AND ID_Product = @ID_Product AND ID_Supplier = @ID_Supplier
	 
	 IF @Price IS NOT NULL
	 UPDATE Warehouse 
	 SET Price = @Price
	 WHERE @ID_Warehouse = ID_Warehouse AND ID_Product = @ID_Product AND ID_Supplier = @ID_Supplier
END;
GO

DECLARE @cookie varbinary(8000);
EXEC sp_setapprole 
    @rolename = 'supplier_app_role',
    @password = 'SupplierPa$$w0rd',
    @fCreateCookie = 1,
    @cookie = @cookie OUTPUT;

EXEC pr_UpdateStock
     @ID_Supplier = 7,
	 @ID_Product = 7,
	 @ID_Warehouse = 7,
	 @Quantity = 50,
	 @Price  = 16
EXEC sp_unsetapprole @cookie;

SELECT * FROM Warehouse

SELECT * FROM Delivery

--====================================================================
                    -- delivery_app_user -- 
--====================================================================
-- кур'єр
-- переглядати та оновлювати (для статусу) інформацію про доставку
CREATE APPLICATION ROLE delivery_app_user WITH PASSWORD = 'DeliveryPa$$w0rd';

GRANT EXECUTE ON pr_UpdateDeliveryAdress TO delivery_app_user;
GRANT EXECUTE ON vw_ClientDeliveryData TO delivery_app_user;

--- 1. Поданя перегляд 
CREATE PROCEDURE vw_ClientDeliveryData
    @ID_Order INTEGER
AS BEGIN
    SELECT * FROM ViewLogisticInfo
    WHERE ID_Order = @ID_Order;
END;
==== --- 2. Процедура оновлювати (для статусу) інформацію про доставку
CREATE PROCEDURE pr_UpdateDeliveryAdress
    @ID_Delivery INTEGER,
    @NewStatus VARCHAR(50)
AS BEGIN
    UPDATE Delivery
    SET DeliveryStatus = @NewStatus, DeliveryDate = GETDATE()
    WHERE ID_Delivery = @ID_Delivery;
END;

DECLARE @cookie varbinary(8000);
EXEC sp_setapprole 
    @rolename = 'delivery_app_user',
    @password = 'DeliveryPa$$w0rd',
    @fCreateCookie = 1,
    @cookie = @cookie OUTPUT;

EXEC vw_ClientDeliveryData
     @ID_Order = 4

EXEC pr_UpdateDeliveryAdress
     @ID_Delivery = 4,
	 @NewStatus = 'Delivered'

EXEC vw_ClientDeliveryData
     @ID_Order = 4
EXEC sp_unsetapprole @cookie;