SELECT
    SIL.[Shortcut Dimension 1 Code],
    SUM(SIL.Amount) AS Sales
FROM [IPPL$Sales Invoice Line] SIL
GROUP BY SIL.[Shortcut Dimension 1 Code]
ORDER BY Sales DESC;