SELECT TOP 5
    SIH.[Sell-to Customer Name] as Customer_Name,
   CAST(SUM(SIL.Amount) AS DECIMAL(18,2)) AS Sales_Value
FROM [IPPL$Sales Invoice Header] SIH
INNER JOIN [IPPL$Sales Invoice Line] SIL
ON SIH.[No_] = SIL.[Document No_]
GROUP BY SIH.[Sell-to Customer Name]
ORDER BY Sales_Value DESC;