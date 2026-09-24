SELECT
    FORMAT(SIH.[Posting Date],'yyyy-MM') AS MonthYear,
    SUM(SIL.Amount) AS Sales
FROM [IPPL$Sales Invoice Header] SIH
INNER JOIN [IPPL$Sales Invoice Line] SIL
ON SIH.[No_] = SIL.[Document No_]
GROUP BY FORMAT(SIH.[Posting Date],'yyyy-MM')
ORDER BY MonthYear;