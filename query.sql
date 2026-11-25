CREATE DATABASE RetailDB;
USE RetailDB;
SELECT DATABASE();
USE RetailDB;
CREATE TABLE Customers (CustomerID INT,CustomerName VARCHAR(100),SignupDate DATE);
CREATE TABLE Stores (StoreID INT,StoreName VARCHAR(100),RegionRaw VARCHAR(50));
CREATE TABLE Products (ProductID INT,ProductName VARCHAR(100),Category VARCHAR(50));
CREATE TABLE Orders (OrderID INT,OrderDate DATE,CustomerID INT,StoreID INT,OrderStatus VARCHAR(30));
CREATE TABLE OrderItems (OrderItemID INT,OrderID INT,ProductID INT,Quantity INT,UnitPrice DECIMAL(10,2),LoadedAt DATETIME);
CREATE TABLE Returns (ReturnID INT,OrderItemID INT,ReturnDate DATE,ReturnQuantity INT);
USE RetailDB;

SELECT COUNT(*) AS TotalCustomers FROM Customers;
USE RetailDB;
SELECT 'Customers' AS TableName, COUNT(*) AS TotalRows FROM Customers UNION ALL
SELECT 'Stores', COUNT(*) FROM Stores UNION ALL
SELECT 'Products', COUNT(*) FROM Products UNION ALL
SELECT 'Orders', COUNT(*) FROM Orders UNION ALL
SELECT 'OrderItems', COUNT(*) FROM OrderItems UNION ALL
SELECT 'Returns', COUNT(*) FROM Returns;
SELECT * FROM Orders WHERE OrderDate >= '2026-10-01' AND OrderDate < '2026-11-01';

#Data cleaning for Q1
USE RetailDB;
CREATE TABLE Regions (RegionID INT PRIMARY KEY, RegionName VARCHAR(50) UNIQUE);
INSERT INTO Regions (RegionID, RegionName)VALUES (1, 'North'),(2, 'South'),(3, 'West');
ALTER TABLE Stores ADD RegionID INT;
UPDATE Stores SET RegionID =
    CASE
        WHEN UPPER(TRIM(RegionRaw)) IN ('N', 'NORTH') THEN 1
        WHEN UPPER(TRIM(RegionRaw)) IN ('S', 'SOUTH') THEN 2
        WHEN UPPER(TRIM(RegionRaw)) IN ('W', 'WEST') THEN 3
        ELSE NULL
    END;
SELECT S.StoreID,S.StoreName,S.RegionRaw,R.RegionID,R.RegionName FROM Stores S LEFT JOIN Regions R ON S.RegionID = R.RegionID ORDER BY S.StoreID;
SELECT * FROM Stores WHERE RegionID IS NULL;


#Remove Duplicates for Q2
USE RetailDB;
CREATE TABLE OrderItems_Clean LIKE OrderItems;
INSERT INTO OrderItems_Clean(OrderItemID, OrderID, ProductID, Quantity, UnitPrice, LoadedAt)
SELECT OrderItemID,OrderID,ProductID,Quantity,UnitPrice,LoadedAt FROM (
    SELECT *,ROW_NUMBER() OVER (PARTITION BY OrderItemID ORDER BY LoadedAt DESC) AS rn FROM OrderItems) AS Ranked
WHERE rn = 1;
SELECT COUNT(*) AS TotalRows,COUNT(DISTINCT OrderItemID) AS UniqueOrderItems FROM OrderItems_Clean;
SELECT OrderItemID, COUNT(*) AS DuplicateCount FROM OrderItems_Clean GROUP BY OrderItemID HAVING COUNT(*) > 1;
SELECT(SELECT COUNT(*) FROM OrderItems) AS OriginalRows,(SELECT COUNT(*) FROM OrderItems_Clean) AS CleanedRows;

#Joins for Q4
USE RetailDB;
SELECT O.OrderID,O.CustomerID,C.CustomerName FROM Orders O INNER JOIN Customers C ON O.CustomerID = C.CustomerID ORDER BY O.OrderID;

#left join along with isnull for Q5
SELECT O.OrderID,O.CustomerID FROM Orders O LEFT JOIN Customers C ON O.CustomerID = C.CustomerID WHERE C.CustomerID IS NULL ORDER BY O.OrderID;

# Customer with no order for Q6
SELECT C.CustomerID,C.CustomerName FROM Customers C LEFT JOIN Orders O ON C.CustomerID = O.CustomerID WHERE O.OrderID IS NULL ORDER BY C.CustomerID;

#Multiple Returns for Q7
SELECT R.OrderItemID, COUNT(R.ReturnID) AS ReturnTransactionCount, SUM(R.ReturnQuantity) AS TotalReturnedUnits
FROM Returns R INNER JOIN OrderItems_Clean OI ON R.OrderItemID = OI.OrderItemID
GROUP BY R.OrderItemID HAVING COUNT(R.ReturnID) > 1 ORDER BY R.OrderItemID;
