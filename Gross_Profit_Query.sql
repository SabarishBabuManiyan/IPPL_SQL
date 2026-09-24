SELECT
    CAST(
        SUM(VE.[Sales Amount (Actual)]) -
        SUM(VE.[Cost Amount (Actual)])
    AS DECIMAL(18,2)) AS GrossProfit
FROM [IPPL$Value Entry] VE
WHERE VE.[Posting Date]
BETWEEN '2026-06-01' AND '2026-06-01';