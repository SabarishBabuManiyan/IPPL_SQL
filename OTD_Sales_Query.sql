SELECT
    CAST(
        SUM(
            CASE
                WHEN [Shipment Date] <= [Requested Delivery Date]
                THEN 1
                ELSE 0
            END
        ) * 100.0 / NULLIF(COUNT(*), 0)
    AS DECIMAL(18,2)) AS OTDPercent
FROM [IPPL$Sales Shipment Header];