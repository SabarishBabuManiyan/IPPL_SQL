-- SELECT
--     CAST(ROUND(SUM(CASE WHEN AgeDays <= 0 THEN bal ELSE 0 END),2) AS DECIMAL(18,2)) AS [Current],
--     CAST(ROUND(SUM(CASE WHEN AgeDays BETWEEN 1 AND 30 THEN bal ELSE 0 END),2) AS DECIMAL(18,2)) AS [1_30_Days],
--     CAST(ROUND(SUM(CASE WHEN AgeDays BETWEEN 31 AND 60 THEN bal ELSE 0 END),2) AS DECIMAL(18,2)) AS [31_60_Days],
--     CAST(ROUND(SUM(CASE WHEN AgeDays BETWEEN 61 AND 90 THEN bal ELSE 0 END),2) AS DECIMAL(18,2)) AS [61_90_Days],
--     CAST(ROUND(SUM(CASE WHEN AgeDays BETWEEN 91 AND 120 THEN bal ELSE 0 END),2) AS DECIMAL(18,2)) AS [91_120_Days],
--     CAST(ROUND(SUM(CASE WHEN AgeDays > 120 THEN bal ELSE 0 END),2) AS DECIMAL(18,2)) AS [Above_120_Days]
-- FROM
-- (
--     SELECT
--         cle.[Customer No_],
--         cle.[Due Date],
--         SUM(dcle.[Amount (LCY)]) AS bal,
--         DATEDIFF(DAY, cle.[Due Date], GETDATE()) AS AgeDays
--     FROM [IPPL$Cust_ Ledger Entry] cle
--     INNER JOIN [IPPL$Detailed Cust_ Ledg_ Entry] dcle
--         ON dcle.[Cust_ Ledger Entry No_] = cle.[Entry No_]
--     WHERE cle.[Open] = 1
--     GROUP BY
--         cle.[Customer No_],
--         cle.[Due Date]
-- ) AS x
-- WHERE bal > 0;

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