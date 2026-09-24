
--Customer Details
SELECT
    [No_]                          AS CustomerNo,
    [Name],
    [Address],
    [City],
    [State Code],
    [GST Registration No_],
    [P_A_N_ No_],
    [Customer Posting Group]  
FROM
    [IPPL$Customer]
WHERE
   ISNULL([GST Registration No_],'') = ''
   
ORDER BY
    [Name];


--Customers without GST Count
 SELECT
    COUNT(*) AS CustomersWithoutGST
FROM
    [IPPL$Customer]
WHERE
    ISNULL([GST Registration No_], '') = ''
    AND [Blocked] = 0;


--GST Duplicate Records
 SELECT
    [GST Registration No_], 
    COUNT(*) AS DuplicateCount
    
    FROM
    [IPPL$Customer]
WHERE
[GST Registration No_] IS NOT NULL AND [GST Registration No_] <> ''
GROUP BY [GST Registration No_]
HAVING Count(*) > 1
ORDER BY DuplicateCount DESC


--GST Duplicate Records Count
SELECT SUM(DuplicateCount) AS TotalDuplicateRecords
FROM (
    SELECT
        [GST Registration No_],
        COUNT(*) AS DuplicateCount
    FROM [IPPL$Customer]
    WHERE [GST Registration No_] IS NOT NULL AND [GST Registration No_] <> ''
    GROUP BY [GST Registration No_]
    HAVING COUNT(*) > 1
) dup;


--Blocked customer count
SELECT COUNT(*) AS BlockedCustomerCount
FROM [IPPL$Customer]
WHERE [Blocked] <> 0
  AND [Address] IS NOT NULL;
   
--Vendor Blocked count
SELECT COUNT(*) AS BlockedvendorCount
FROM [IPPL$Vendor]
WHERE [Blocked] = 0
  AND ( [City] IS NULL OR  LTRIM(RTRIM([City])) = '');
