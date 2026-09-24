SELECT
    vle.[Vendor No_],
    vle.[Entry No_],
    vle.[Document No_],
    vle.[Due Date],
    SUM(dvle.[Amount (LCY)]) AS Balance,
    DATEDIFF(DAY, vle.[Due Date], GETDATE()) AS AgeDays,
    CASE
        WHEN DATEDIFF(DAY, vle.[Due Date], GETDATE()) <= 0 THEN 'Current'
        WHEN DATEDIFF(DAY, vle.[Due Date], GETDATE()) BETWEEN 1 AND 30 THEN '1-30'
        WHEN DATEDIFF(DAY, vle.[Due Date], GETDATE()) BETWEEN 31 AND 60 THEN '31-60'
        WHEN DATEDIFF(DAY, vle.[Due Date], GETDATE()) BETWEEN 61 AND 90 THEN '61-90'
        WHEN DATEDIFF(DAY, vle.[Due Date], GETDATE()) BETWEEN 91 AND 120 THEN '91-120'
        ELSE '>120'
    END AS AgeBucket
FROM [IPPL$Vendor Ledger Entry] vle
INNER JOIN [IPPL$Detailed Vendor Ledg_ Entry] dvle
    ON dvle.[Vendor Ledger Entry No_] = vle.[Entry No_]
WHERE vle.[Open] = 1
  AND vle.[Vendor No_] = 'VITIMB'
GROUP BY
    vle.[Vendor No_],
    vle.[Entry No_],
    vle.[Document No_],
    vle.[Due Date]
ORDER BY
    AgeDays DESC;