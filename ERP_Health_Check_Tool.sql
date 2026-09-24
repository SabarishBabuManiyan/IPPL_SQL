SELECT 'Orders with No Lines' AS [Category], COUNT(*) AS [Count]
FROM [IPPL$Sales Header] a
WHERE NOT EXISTS (SELECT 'x' FROM [IPPL$Sales Line] b WHERE a.[No_] = b.[Document No_])

UNION ALL

SELECT 'Open Orders Older than 90 Days', COUNT(*)
FROM [IPPL$Sales Header] SH
WHERE SH.[Document Type] = 1 AND SH.[Status] = 0
AND SH.[Order Date] < DATEADD(DAY,-90,CAST(GETDATE() AS DATE))

UNION ALL

SELECT 'Open Orders with Zero Outstanding Qty', COUNT(*)
FROM (
    SELECT SH.[No_]
    FROM [IPPL$Sales Header] SH
    INNER JOIN [IPPL$Sales Line] SL
        ON SH.[Document Type] = SL.[Document Type] AND SH.[No_] = SL.[Document No_]
    WHERE SH.[Document Type] = 1 AND SH.[Status] = 0
    GROUP BY SH.[No_]
    HAVING SUM(SL.[Outstanding Quantity]) = 0
) x

UNION ALL

SELECT 'Released Orders with No Shipment', COUNT(*)
FROM (
    SELECT SH.[No_]
    FROM [IPPL$Sales Header] SH
    INNER JOIN [IPPL$Sales Line] SL
        ON SH.[Document Type] = SL.[Document Type] AND SH.[No_] = SL.[Document No_]
    WHERE SH.[Document Type] = 1 AND SH.[Status] IN (0,1)
    GROUP BY SH.[No_]
    HAVING SUM(SL.[Quantity Shipped]) = 0
) x

UNION ALL

SELECT 'Orders Without Customer', COUNT(*)
FROM [IPPL$Sales Header]
WHERE [Document Type] = 1
AND (ISNULL([Sell-to Customer No_],'') = '' OR ISNULL([Sell-to Customer Name],'') = '')

UNION ALL

SELECT 'Orders Without Item Lines', COUNT(*)
FROM (
    SELECT SH.[No_]
    FROM [IPPL$Sales Header] SH
    LEFT JOIN [IPPL$Sales Line] SL
        ON SH.[Document Type] = SL.[Document Type] AND SH.[No_] = SL.[Document No_]
    WHERE SH.[Document Type] = 1
    GROUP BY SH.[No_]
    HAVING COUNT(SL.[Line No_]) = 0
) x

UNION ALL

SELECT 'Orders with Invalid Dimensions', COUNT(*)
FROM [IPPL$Sales Header]
WHERE [Document Type] = 1
AND (ISNULL([Shortcut Dimension 1 Code],'') = '' OR ISNULL([Shortcut Dimension 2 Code],'') = '')

UNION ALL

SELECT 'Duplicate Sales Orders (Customer+Date)', COUNT(*)
FROM (
    SELECT [Sell-to Customer No_], [Order Date]
    FROM [IPPL$Sales Header]
    WHERE [Document Type] = 1
    GROUP BY [Sell-to Customer No_], [Order Date]
    HAVING COUNT(*) > 1
) x;

USE [Jayanti_UAT_JUN26];  -- or whatever the exact DB name is
SELECT name FROM sys.database_principals WHERE name = 'sabarish';