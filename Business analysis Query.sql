#Q8 -Completed order count for sales region
USE RetailDB;
SELECT R.RegionName,
    COUNT(DISTINCT O.OrderID) AS CompletedOrderCount,
    SUM(OI.Quantity * OI.UnitPrice) AS GrossSales
FROM Orders O INNER JOIN Stores S
    ON O.StoreID = S.StoreID
INNER JOIN Regions R
    ON S.RegionID = R.RegionID
INNER JOIN OrderItems_Clean OI
    ON O.OrderID = OI.OrderID
WHERE O.OrderDate >= '2026-10-01'
  AND O.OrderDate < '2026-11-01'
  AND O.OrderStatus = 'Completed'
GROUP BY R.RegionName ORDER BY R.RegionName;

#Q8 Return Value by Region
SELECT R.RegionName,
    SUM(RT.ReturnQuantity * OI.UnitPrice) AS ReturnValue
FROM Returns RT INNER JOIN OrderItems_Clean OI
    ON RT.OrderItemID = OI.OrderItemID
INNER JOIN Orders O
    ON OI.OrderID = O.OrderID
INNER JOIN Stores S
    ON O.StoreID = S.StoreID
INNER JOIN Regions R
    ON S.RegionID = R.RegionID
WHERE RT.ReturnDate >= '2026-10-01'
  AND RT.ReturnDate < '2026-11-01'
  AND O.OrderStatus = 'Completed'
GROUP BY R.RegionName ORDER BY R.RegionName;

#Q10 for compare store with each region
SELECT R.RegionName,S.StoreID,S.StoreName,
    COALESCE(SUM(OI.Quantity * OI.UnitPrice), 0) AS GrossSales
FROM Stores S JOIN Regions R ON S.RegionID = R.RegionID
LEFT JOIN Orders O ON S.StoreID = O.StoreID
    AND O.OrderDate >= '2026-10-01'
    AND O.OrderDate < '2026-11-01'
    AND O.OrderStatus = 'Completed'
LEFT JOIN OrderItems_Clean OI ON O.OrderID = OI.OrderID
GROUP BY R.RegionName,S.StoreID,S.StoreName
ORDER BY R.RegionName, S.StoreID;

#Q10 Value by store
SELECT R.RegionName,S.StoreID,S.StoreName,
    COALESCE(SUM(RT.ReturnQuantity * OI.UnitPrice), 0) AS ReturnValue
FROM Stores S JOIN Regions R ON S.RegionID = R.RegionID
LEFT JOIN Orders O ON S.StoreID = O.StoreID AND O.OrderStatus = 'Completed'
LEFT JOIN OrderItems_Clean OI ON O.OrderID = OI.OrderID
LEFT JOIN Returns RT ON OI.OrderItemID = RT.OrderItemID
    AND RT.ReturnDate >= '2026-10-01'
    AND RT.ReturnDate < '2026-11-01'
GROUP BY R.RegionName,S.StoreID, S.StoreName
ORDER BY R.RegionName,S.StoreID;

#Q11 Return Value by Product Category
#Highest return value region: North
SELECT P.Category,SUM(RT.ReturnQuantity * OI.UnitPrice) AS ReturnValue
FROM Returns RT JOIN OrderItems_Clean OI ON RT.OrderItemID = OI.OrderItemID
JOIN Orders O ON OI.OrderID = O.OrderID
JOIN Stores S ON O.StoreID = S.StoreID
JOIN Regions R ON S.RegionID = R.RegionID
JOIN Products P ON OI.ProductID = P.ProductID
WHERE R.RegionName = 'North'
  AND RT.ReturnDate >= '2026-10-01'
  AND RT.ReturnDate < '2026-11-01'
  AND O.OrderStatus = 'Completed'
GROUP BY P.Category ORDER BY ReturnValue DESC, P.Category ASC;



#Calculate Category Share
SELECT P.Category,SUM(RT.ReturnQuantity * OI.UnitPrice) AS ReturnValue, ROUND( SUM(RT.ReturnQuantity * OI.UnitPrice) * 100.0 /
        SUM(SUM(RT.ReturnQuantity * OI.UnitPrice)) OVER (), 2
    ) AS ReturnSharePercentage
FROM Returns RT JOIN OrderItems_Clean OI ON RT.OrderItemID = OI.OrderItemID
JOIN Orders O ON OI.OrderID = O.OrderID
JOIN Stores S ON O.StoreID = S.StoreID
JOIN Regions R ON S.RegionID = R.RegionID
JOIN Products P ON OI.ProductID = P.ProductID
WHERE R.RegionName = 'North'
  AND RT.ReturnDate >= '2026-10-01'
  AND RT.ReturnDate < '2026-11-01'
  AND O.OrderStatus = 'Completed'
GROUP BY P.Category ORDER BY ReturnValue DESC, P.Category ASC;
