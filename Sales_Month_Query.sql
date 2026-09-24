SELECT
--COUNT(SIH.[No_]) AS InvoiceCount,
CAST(ROUND(SUM(SIL.[Amount]), 2) AS DECIMAL(18,2)) as Totalsales
FROM [IPPL$Sales Invoice Header] SIH
INNER JOIN [IPPL$Sales Invoice Line] SIL
ON
SIH.[No_] = SIL.[Document No_]
-- WHERE SIH.[Posting Date] BETWEEN '2026-06-01' and '2026-06-30';
WHERE SIH.[Bill-to Customer No_] = 'C02279';

