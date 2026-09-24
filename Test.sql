--------------OTD%-------------
-- SELECT [Requested Delivery Date],*

--     --CAST(
--       --  SUM(
--         --    CASE
--           --      WHEN [Shipment Date] <= [Requested Delivery Date]
--             --    THEN 1
--               --  ELSE 0
--            -- END
--         --) * 100.0 / NULLIF(COUNT(*), 0)
--    -- AS DECIMAL(18,2)) AS OTDPerce   nt
-- FROM [IPPL$Sales Shipment Header] where [] between '01-Apr-2026'
-- and '03-Sep-2026'
-- ORDER BY [Posting Date] asc;
-----2-----Top5products---------------------
SELECT TOP 5
    SIL.[No_] AS ItemNo,
    SIL.[Description],
    SIL.[Unit of Measure Code] AS UOM,
    CAST(SUM(SIL.Quantity) AS DECIMAL(18,2)) AS QtySold
FROM [IPPL$Sales Invoice Line] SIL
GROUP BY
    SIL.[No_],
    SIL.[Description],
    SIL.[Unit of Measure Code]
ORDER BY QtySold DESC;
------3-------------------------------------
SELECT TOP 5
    SIH.[Sell-to Customer Name] as Customer_Name,
   CAST(SUM(SIL.Amount) AS DECIMAL(18,2)) AS Sales_Value
FROM [IPPL$Sales Invoice Header] SIH
INNER JOIN [IPPL$Sales Invoice Line] SIL
ON SIH.[No_] = SIL.[Document No_]
GROUP BY SIH.[Sell-to Customer Name]
ORDER BY Sales_Value DESC;
------------------4-------------------------------
SELECT
    CAST(ROUND(SUM(CASE WHEN AgeDays <= 0 THEN ABS(bal) ELSE 0 END),2) AS DECIMAL(18,2)) AS [Current],
    CAST(ROUND(SUM(CASE WHEN AgeDays BETWEEN 1 AND 30 THEN ABS(bal) ELSE 0 END),2) AS DECIMAL(18,2)) AS [1_30_Days],
    CAST(ROUND(SUM(CASE WHEN AgeDays BETWEEN 31 AND 60 THEN ABS(bal) ELSE 0 END),2) AS DECIMAL(18,2)) AS [31_60_Days],
    CAST(ROUND(SUM(CASE WHEN AgeDays BETWEEN 61 AND 90 THEN ABS(bal) ELSE 0 END),2) AS DECIMAL(18,2)) AS [61_90_Days],
    CAST(ROUND(SUM(CASE WHEN AgeDays BETWEEN 91 AND 120 THEN ABS(bal) ELSE 0 END),2) AS DECIMAL(18,2)) AS [91_120_Days],
    CAST(ROUND(SUM(CASE WHEN AgeDays > 120 THEN ABS(bal) ELSE 0 END),2) AS DECIMAL(18,2)) AS [Above_120_Days]
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
    GROUP BY
        vle.[Vendor No_],
        vle.[Due Date]
) AS x
WHERE bal < 0;
-----------------------------------5-----------
SELECT
    CAST(ROUND(SUM(CASE WHEN AgeDays <= 0 THEN bal ELSE 0 END),2) AS DECIMAL(18,2)) AS [Current],
    CAST(ROUND(SUM(CASE WHEN AgeDays BETWEEN 1 AND 30 THEN bal ELSE 0 END),2) AS DECIMAL(18,2)) AS [1_30_Days],
    CAST(ROUND(SUM(CASE WHEN AgeDays BETWEEN 31 AND 60 THEN bal ELSE 0 END),2) AS DECIMAL(18,2)) AS [31_60_Days],
    CAST(ROUND(SUM(CASE WHEN AgeDays BETWEEN 61 AND 90 THEN bal ELSE 0 END),2) AS DECIMAL(18,2)) AS [61_90_Days],
    CAST(ROUND(SUM(CASE WHEN AgeDays BETWEEN 91 AND 120 THEN bal ELSE 0 END),2) AS DECIMAL(18,2)) AS [91_120_Days],
    CAST(ROUND(SUM(CASE WHEN AgeDays > 120 THEN bal ELSE 0 END),2) AS DECIMAL(18,2)) AS [Above_120_Days]
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
    GROUP BY
        cle.[Customer No_],
        cle.[Due Date]
) AS x
WHERE bal > 0;
--------------------------6---------------------------
SELECT
    SIL.[Shortcut Dimension 1 Code],
    SUM(SIL.Amount) AS Sales
FROM [IPPL$Sales Invoice Line] SIL
GROUP BY SIL.[Shortcut Dimension 1 Code]
ORDER BY Sales DESC;
-------------------7----------------------------
SELECT
    FORMAT(SIH.[Posting Date],'yyyy-MM') AS MonthYear,
    SUM(SIL.Amount) AS Sales
FROM [IPPL$Sales Invoice Header] SIH
INNER JOIN [IPPL$Sales Invoice Line] SIL
ON SIH.[No_] = SIL.[Document No_]
GROUP BY FORMAT(SIH.[Posting Date],'yyyy-MM')
ORDER BY MonthYear;
--------------8NetProfit    --------------------
SELECT
    SUM([Amount]) AS NetProfit
FROM [IPPL$G_L Entry] GLE
INNER JOIN [IPPL$G_L Account] GLA
    ON GLE.[G_L Account No_] = GLA.[No_]
WHERE GLE.[Posting Date]
      BETWEEN '2026-04-01' AND '2026-06-30'
  AND GLA.[Income_Balance] = 1;
------------------------------------------------
SELECT
    GLA.[No_],
    GLA.[Name],
    SUM(GLE.[Amount]) AS Amount
FROM [IPPL$G_L Entry] GLE
INNER JOIN [IPPL$G_L Account] GLA
    ON GLE.[G_L Account No_] = GLA.[No_]
WHERE GLE.[Posting Date]
      BETWEEN '2026-04-01' AND '2026-06-30'
  AND GLA.[Income_Balance] = 1
GROUP BY
    GLA.[No_],
    GLA.[Name]
ORDER BY
    GLA.[No_];
    -------------------9------------------------
    SELECT
    CAST(
        SUM(VE.[Sales Amount (Actual)]) -
        SUM(VE.[Cost Amount (Actual)])
    AS DECIMAL(18,2)) AS GrossProfit
FROM [IPPL$Value Entry] VE
WHERE VE.[Posting Date]
BETWEEN '2026-06-01' AND '2026-06-01';
--------------------10---Inventory Value------
SELECT
    CAST(SUM([Cost Amount (Actual)]) AS DECIMAL(18,2))
    AS InventoryValue
FROM [IPPL$Value Entry]
WHERE [Item Ledger Entry Type] IN (0,1,2);
-----------------11-----------------------
   SELECT
    CAST(ROUND(SUM(CASE WHEN bal > 0 THEN bal ELSE 0 END),2)AS Decimal(18,2)) AS Gross_Receivable,
   CAST(ROUND(SUM(CASE WHEN bal < 0 THEN bal ELSE 0 END),2)AS decimal(18,2)) AS Gross_Advances_Credits
FROM (
    SELECT vle.[Vendor No_], SUM(dvle.[Amount (LCY)]) AS bal
    FROM [IPPL$Vendor Ledger Entry] vle
    INNER JOIN [IPPL$Detailed Vendor Ledg_ Entry] dvle
        ON dvle.[Vendor Ledger Entry No_] = vle.[Entry No_]
    WHERE vle.[Open] = 1
    GROUP BY vle.[Vendor No_]
) x;
-----------------------12--Gross Receivable--------
  SELECT
    CAST(ROUND(SUM(CASE WHEN bal > 0 THEN bal ELSE 0 END),2)AS Decimal(18,2)) AS Gross_Receivable,
   CAST(ROUND(SUM(CASE WHEN bal < 0 THEN bal ELSE 0 END),2)AS decimal(18,2)) AS Gross_Advances_Credits
FROM (
    SELECT cle.[Customer No_], SUM(dcle.[Amount (LCY)]) AS bal
    FROM [IPPL$Cust_ Ledger Entry] cle
    INNER JOIN [IPPL$Detailed Cust_ Ledg_ Entry] dcle
        ON dcle.[Cust_ Ledger Entry No_] = cle.[Entry No_]
    WHERE cle.[Open] = 1
    GROUP BY cle.[Customer No_]
) x;
----------------------13-Totalsales------------
SELECT
--COUNT(SIH.[No_]) AS InvoiceCount,
CAST(ROUND(SUM(SIL.[Amount]), 2) AS DECIMAL(18,2)) as Totalsales
FROM [IPPL$Sales Invoice Header] SIH
INNER JOIN [IPPL$Sales Invoice Line] SIL
ON
SIH.[No_] = SIL.[Document No_]
WHERE SIH.[Posting Date] BETWEEN '2026-06-01' and '2026-06-30';

