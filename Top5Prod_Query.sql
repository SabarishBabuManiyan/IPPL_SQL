SELECT TOP 5
    SIL.[No_] AS ItemNo,
    SIL.[Description],
    CAST(SUM(SIL.Quantity) AS decimal(18,2)) QtySold
FROM [IPPL$Sales Invoice Line] SIL
GROUP BY
    SIL.[No_],
    SIL.[Description]
ORDER BY QtySold DESC;

SELECT TOP 5
    [No_] AS ItemNo,
    [Description],
    SUM([Quantity]) AS QtySold
FROM [IPPL$Sales Invoice Line]
WHERE [Type] = 2
GROUP BY
    [No_],
    [Description]
    
ORDER BY
    QtySold DESC;
