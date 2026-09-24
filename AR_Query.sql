-- SELECT
--     cle.[Customer No_],
--     SUM(dcle.[Amount (LCY)]) AS Outstanding_AR
-- FROM
--     [IPPL$Cust_ Ledger Entry] cle
--     INNER JOIN [IPPL$Detailed Cust_ Ledg_ Entry] dcle
--         ON dcle.[Cust_ Ledger Entry No_] = cle.[Entry No_]
-- WHERE
--     cle.[Open] = 1
-- GROUP BY
--     cle.[Customer No_]
-- HAVING
--     SUM(dcle.[Amount (LCY)]) <> 0
-- ORDER BY
--     Outstanding_AR DESC;
-- ----------------------------------------------Testing------------
--     SELECT
--     cle.[Customer No_],
--     SUM(dcle.[Amount (LCY)]) AS Outstanding_AR
-- FROM
--     [IPPL$Cust_ Ledger Entry] cle
--     INNER JOIN [IPPL$Detailed Cust_ Ledg_ Entry] dcle
--         ON dcle.[Cust_ Ledger Entry No_] = cle.[Entry No_]
-- WHERE
--     cle.[Open] = 1
--     AND cle.[Customer No_] = 'C02279'
-- GROUP BY
--     cle.[Customer No_];
--  -----------------------------------------------Testing-----------
--     SELECT
--     cle.[Entry No_],
--     cle.[Document Type],
--     cle.[Document No_],
--     cle.[Posting Date],
--     cle.[Due Date],
--     cle.[Open],
--     cle.[Reversed],
--     SUM(dcle.[Amount (LCY)]) AS Entry_Remaining
-- FROM
--     [IPPL$Cust_ Ledger Entry] cle
--     INNER JOIN [IPPL$Detailed Cust_ Ledg_ Entry] dcle
--         ON dcle.[Cust_ Ledger Entry No_] = cle.[Entry No_]
-- WHERE
--     cle.[Customer No_] = 'C02279'
--     AND cle.[Open] = 1
-- GROUP BY
--     cle.[Entry No_], cle.[Document Type], cle.[Document No_],
--     cle.[Posting Date], cle.[Due Date], cle.[Open], cle.[Reversed]
-- ORDER BY
--     cle.[Posting Date];
--     -----------------------------------------
--     ---------AR_Receivable-------------------
--     -----------------------------------------
--     SELECT
--     CAST(ROUND(SUM(CASE WHEN bal > 0 THEN bal ELSE 0 END),2)AS Decimal(18,2)) AS Gross_Receivable,
--    CAST(ROUND(SUM(CASE WHEN bal < 0 THEN bal ELSE 0 END),2)AS decimal(18,2)) AS Gross_Advances_Credits
-- FROM (
--     SELECT cle.[Customer No_], SUM(dcle.[Amount (LCY)]) AS bal
--     FROM [IPPL$Cust_ Ledger Entry] cle
--     INNER JOIN [IPPL$Detailed Cust_ Ledg_ Entry] dcle
--         ON dcle.[Cust_ Ledger Entry No_] = cle.[Entry No_]
--     WHERE cle.[Open] = 1
--     GROUP BY cle.[Customer No_]
-- ) x;

SELECT
    x.[Customer No_],
    CAST(ROUND(CASE WHEN x.bal > 0 THEN x.bal ELSE 0 END, 2) AS DECIMAL(18,2)) AS Gross_Receivable,
    CAST(ROUND
    (CASE WHEN x.bal < 0 THEN x.bal ELSE 0 END, 2) AS DECIMAL(18,2)) AS Gross_Advances_Credits
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
----------------------DAX_---equal
SELECT
    SUM(dcle.[Amount (LCY)]) AS AR_Balance_Open
FROM [IPPL$Cust_ Ledger Entry] cle
INNER JOIN [IPPL$Detailed Cust_ Ledg_ Entry] dcle
    ON dcle.[Cust_ Ledger Entry No_] = cle.[Entry No_]
WHERE cle.[Open] = 1;


