-- --    SELECT
-- --     CAST(ROUND(SUM(CASE WHEN bal > 0 THEN bal ELSE 0 END),2)AS Decimal(18,2)) AS Gross_Receivable,
-- --    CAST(ROUND(SUM(CASE WHEN bal < 0 THEN bal ELSE 0 END),2)AS decimal(18,2)) AS Gross_Advances_Credits
-- -- FROM (
-- --     SELECT vle.[Vendor No_], SUM(dvle.[Amount (LCY)]) AS bal
-- --     FROM [IPPL$Vendor Ledger Entry] vle
-- --     INNER JOIN [IPPL$Detailed Vendor Ledg_ Entry] dvle
-- --         ON dvle.[Vendor Ledger Entry No_] = vle.[Entry No_]
-- --     WHERE vle.[Open] = 1
-- --     GROUP BY vle.[Vendor No_]
-- -- ) x;
-- SELECT
--     CAST(
--         ROUND(
--             SUM(CASE WHEN bal < 0 THEN ABS(bal) ELSE 0 END),2
--         ) AS DECIMAL(18,2)
--     ) AS AccountsPayable
-- FROM (
--     SELECT vle.[Vendor No_],
--            SUM(dvle.[Amount (LCY)]) AS bal
--     FROM [IPPL$Vendor Ledger Entry] vle
--     INNER JOIN [IPPL$Detailed Vendor Ledg_ Entry] dvle
--         ON dvle.[Vendor Ledger Entry No_] = vle.[Entry No_]
--     WHERE vle.[Open] = 1
--     GROUP BY vle.[Vendor No_]
-- ) x;
-------------------Last query---------------
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
---------------Dax_Match
SELECT
    SUM(dvle.[Amount (LCY)]) AS AP_Balance_Open
FROM [IPPL$Vendor Ledger Entry] vle
INNER JOIN [IPPL$Detailed Vendor Ledg_ Entry] dvle
    ON dvle.[Vendor Ledger Entry No_] = vle.[Entry No_]
WHERE vle.[Open] = 1;