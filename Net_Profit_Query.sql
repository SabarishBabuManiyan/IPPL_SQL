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