SELECT
    CAST(SUM([Cost Amount (Actual)]) AS DECIMAL(18,2))
    AS InventoryValue
FROM [IPPL$Value Entry]
WHERE [Item Ledger Entry Type] IN (0,1,2);