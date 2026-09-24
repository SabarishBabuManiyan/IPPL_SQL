----------AP_Ageing-----------------
SELECT
    x.[Vendor No_],
    CAST(ROUND(SUM(CASE WHEN AgeDays <= 0 THEN ABS(bal) ELSE 0 END), 2) AS DECIMAL(18,2)) AS [Current],
    CAST(ROUND(SUM(CASE WHEN AgeDays BETWEEN 1 AND 30 THEN ABS(bal) ELSE 0 END), 2) AS DECIMAL(18,2)) AS [1_30_Days],
    CAST(ROUND(SUM(CASE WHEN AgeDays BETWEEN 31 AND 60 THEN ABS(bal) ELSE 0 END), 2) AS DECIMAL(18,2)) AS [31_60_Days],
    CAST(ROUND(SUM(CASE WHEN AgeDays BETWEEN 61 AND 90 THEN ABS(bal) ELSE 0 END), 2) AS DECIMAL(18,2)) AS [61_90_Days],
    CAST(ROUND(SUM(CASE WHEN AgeDays BETWEEN 91 AND 120 THEN ABS(bal) ELSE 0 END), 2) AS DECIMAL(18,2)) AS [91_120_Days],
    CAST(ROUND(SUM(CASE WHEN AgeDays > 120 THEN ABS(bal) ELSE 0 END), 2) AS DECIMAL(18,2)) AS [Above_120_Days]
FROM
(
    SELECT
        vle.[Vendor No_],
        vle.[Due Date],
        SUM(dvle.[Amount (LCY)]) AS bal,
        DATEDIFF(DAY, vle.[Due Date], GETDATE()) AS AgeDays
    FROM [IPPL$Vendor Ledger Entry] vle
    INNER JOIN [IPPL$Detailed Vendor Ledg_ Entry] dvle
        ON dvle.[Vendor Ledger Entry No_] = vle.[Entry No_]
    WHERE vle.[Open] = 1
      AND vle.[Vendor No_] = 'V00002'
    GROUP BY vle.[Vendor No_], vle.[Due Date]
) x
WHERE bal < 0
GROUP BY x.[Vendor No_];
---------------AP Query--------------------
SELECT
    x.[Vendor No_],
    CAST(ROUND(CASE WHEN x.bal > 0 THEN x.bal ELSE 0 END, 2) AS DECIMAL(18,2)) AS Gross_Receivable,
    CAST(ROUND(CASE WHEN x.bal < 0 THEN x.bal ELSE 0 END, 2) AS DECIMAL(18,2)) AS Gross_Advances_Credits
FROM (
    SELECT
        vle.[Vendor No_],
        SUM(dvle.[Amount (LCY)]) AS bal
    FROM [IPPL$Vendor Ledger Entry] vle
    INNER JOIN [IPPL$Detailed Vendor Ledg_ Entry] dvle
        ON dvle.[Vendor Ledger Entry No_] = vle.[Entry No_]
    WHERE vle.[Open] = 1
      AND vle.[Vendor No_] = 'V00002'  -- Replace with Vendor No.
    GROUP BY vle.[Vendor No_]
) x;
--------------------AR Ageing-------------------
SELECT
    x.[Customer No_],
    CAST(ROUND(SUM(CASE WHEN AgeDays <= 0 THEN ABS(bal) ELSE 0 END), 2) AS DECIMAL(18,2)) AS [Current],
    CAST(ROUND(SUM(CASE WHEN AgeDays BETWEEN 1 AND 30 THEN ABS(bal) ELSE 0 END), 2) AS DECIMAL(18,2)) AS [1_30_Days],
    CAST(ROUND(SUM(CASE WHEN AgeDays BETWEEN 31 AND 60 THEN ABS(bal) ELSE 0 END), 2) AS DECIMAL(18,2)) AS [31_60_Days],
    CAST(ROUND(SUM(CASE WHEN AgeDays BETWEEN 61 AND 90 THEN ABS(bal) ELSE 0 END), 2) AS DECIMAL(18,2)) AS [61_90_Days],
    CAST(ROUND(SUM(CASE WHEN AgeDays BETWEEN 91 AND 120 THEN ABS(bal) ELSE 0 END), 2) AS DECIMAL(18,2)) AS [91_120_Days],
    CAST(ROUND(SUM(CASE WHEN AgeDays > 120 THEN ABS(bal) ELSE 0 END), 2) AS DECIMAL(18,2)) AS [Above_120_Days]
FROM
(
    SELECT
        cle.[Customer No_],
        cle.[Due Date],
        SUM(dcle.[Amount (LCY)]) AS bal,
        DATEDIFF(DAY, cle.[Due Date], GETDATE()) AS AgeDays
    FROM [IPPL$Cust_ Ledger Entry] cle
    INNER JOIN [IPPL$Detailed Cust_ Ledg_ Entry] dcle
        ON dcle.[Cust_ Ledger Entry No_] = cle.[Entry No_]
    WHERE cle.[Open] = 1
      AND cle.[Customer No_] = 'C02279'   -- Replace with Customer No.
    GROUP BY
        cle.[Customer No_],
        cle.[Due Date]
) x
WHERE bal > 0
GROUP BY x.[Customer No_];
--------------------AR Query---------------------
SELECT
    x.[Customer No_],
    CAST(ROUND(CASE WHEN x.bal > 0 THEN x.bal ELSE 0 END, 2) AS DECIMAL(18,2)) AS Gross_Receivable,
    CAST(ROUND(CASE WHEN x.bal < 0 THEN x.bal ELSE 0 END, 2) AS DECIMAL(18,2)) AS Gross_Advances_Credits
FROM (
    SELECT
        cle.[Customer No_],
        SUM(dcle.[Amount (LCY)]) AS bal
    FROM [IPPL$Cust_ Ledger Entry] cle
    INNER JOIN [IPPL$Detailed Cust_ Ledg_ Entry] dcle
        ON dcle.[Cust_ Ledger Entry No_] = cle.[Entry No_]
    WHERE cle.[Open] = 1
      AND cle.[Customer No_] = 'C02284'  -- Replace with Customer No.
    GROUP BY cle.[Customer No_]
) x;
-----------------Gross profit----------------------
SELECT
    CAST(
        SUM(VE.[Sales Amount (Actual)]) -
        SUM(VE.[Cost Amount (Actual)])
    AS DECIMAL(18,2)) AS GrossProfit
FROM [IPPL$Value Entry] VE
WHERE VE.[Posting Date]
BETWEEN '2026-06-01' AND '2026-06-01';
----------------Inventory value------------------
SELECT
    CAST(SUM([Cost Amount (Actual)]) AS DECIMAL(18,2))
    AS InventoryValue
FROM [IPPL$Value Entry]
WHERE [Item Ledger Entry Type] IN (0,1,2);
----------------Net Profit-----------------------
SELECT
    SUM([Amount]) AS NetProfit
FROM [IPPL$G_L Entry] GLE
INNER JOIN [IPPL$G_L Account] GLA
    ON GLE.[G_L Account No_] = GLA.[No_]
WHERE GLE.[Posting Date]
      BETWEEN '2026-04-01' AND '2026-06-30'
  AND GLA.[Income_Balance] = 1;
  -------------OTD Sales------------------------
  SELECT
    CAST(
        SUM(
            CASE
                WHEN [Shipment Date] <= [Requested Delivery Date]
                THEN 1
                ELSE 0
            END
        ) * 100.0 / NULLIF(COUNT(*), 0)
    AS DECIMAL(18,2)) AS OTDPercent
FROM [IPPL$Sales Shipment Header];
----------------------Sales by Dimension-----------
SELECT
    SIL.[Shortcut Dimension 1 Code],
    SUM(SIL.Amount) AS Sales
FROM [IPPL$Sales Invoice Line] SIL

GROUP BY SIL.[Shortcut Dimension 1 Code]
ORDER BY Sales DESC;
---------------Sales Gp Trend----------------------
SELECT
    FORMAT(SIH.[Posting Date],'yyyy-MM') AS MonthYear,
    SUM(SIL.Amount) AS Sales
FROM [IPPL$Sales Invoice Header] SIH
INNER JOIN [IPPL$Sales Invoice Line] SIL
ON SIH.[No_] = SIL.[Document No_]
GROUP BY FORMAT(SIH.[Posting Date],'yyyy-MM')
ORDER BY MonthYear;
-----------------Sales per month------------------
SELECT
--COUNT(SIH.[No_]) AS InvoiceCount,
CAST(ROUND(SUM(SIL.[Amount]), 2) AS DECIMAL(18,2)) as Totalsales
FROM [IPPL$Sales Invoice Header] SIH
INNER JOIN [IPPL$Sales Invoice Line] SIL
ON
SIH.[No_] = SIL.[Document No_]
-- WHERE SIH.[Posting Date] BETWEEN '2026-06-01' and '2026-06-30';
WHERE SIH.[Bill-to Customer No_] = 'C02279';

-------------Top 5 cust--------------------
SELECT TOP 5
    SIH.[Sell-to Customer Name] as Customer_Name,
   CAST(SUM(SIL.Amount) AS DECIMAL(18,2)) AS Sales_Value
FROM [IPPL$Sales Invoice Header] SIH
INNER JOIN [IPPL$Sales Invoice Line] SIL
ON SIH.[No_] = SIL.[Document No_]
GROUP BY SIH.[Sell-to Customer Name]
ORDER BY Sales_Value DESC;
-------------Top 5 Products--------------
SELECT TOP 5
    SIL.[No_] AS ItemNo,
    SIL.[Description],
    CAST(SUM(SIL.Quantity) AS decimal(18,2)) QtySold
FROM [IPPL$Sales Invoice Line] SIL
GROUP BY
    SIL.[No_],
    SIL.[Description]
ORDER BY QtySold DESC;

SELECT SUM([Amount])

FROM [IPPL$Sales Invoice Line];
