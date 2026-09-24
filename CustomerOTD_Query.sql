WITH CustomerInvoices AS
(
    SELECT
        cle.[Entry No_]           AS InvEntryNo,
        cle.[Customer No_]        AS CustomerNo,
        c.Name                    AS CustomerName,
        cle.[Document No_]        AS InvoiceNo,
        cle.[Posting Date]        AS InvoiceDate,
        cle.[Due Date]            AS DueDate,
        cle.[Closed by Entry No_] AS ClosedByEntryNo,
        cle.[Closed by Amount]    AS ClosedByAmount,
        cle.[Document Type]
    FROM [IPPL$Cust_ Ledger Entry] cle
    INNER JOIN [IPPL$Customer] c
        ON c.[No_] = cle.[Customer No_]
    WHERE cle.[Document Type] = 2
)
,
AppliedEntries AS
(
    SELECT
        ci.InvEntryNo,
        p.[Entry No_]       AS PaymentEntryNo,
        p.[Document No_]    AS ReceiptNo,
        p.[Posting Date]    AS ReceiptDate,
        p.[Closed by Amount (LCY)] AS ReceiptAmountLCY
    FROM CustomerInvoices ci
    LEFT JOIN [IPPL$Cust_ Ledger Entry] p
        ON p.[Entry No_] = ci.ClosedByEntryNo
)
SELECT
    ci.CustomerNo,
    ci.CustomerName,
    ci.InvoiceNo,
    ci.InvoiceDate,
    ci.DueDate,

    ap.ReceiptNo,
    ap.ReceiptDate,

    DATEDIFF(
        DAY,
        ap.ReceiptDate,
        ci.DueDate
    ) AS NoofdaysCal,

    CASE
        WHEN ap.ReceiptDate IS NULL
             AND ci.DueDate > GETDATE()
        THEN 'Not Due and Not Received'

        WHEN ap.ReceiptDate IS NULL
             AND ci.DueDate <= GETDATE()
        THEN 'Overdue and Not Received'

        WHEN DATEDIFF(
                DAY,
                ap.ReceiptDate,
                ci.DueDate
             ) <= -16
        THEN 'Received after 16+ days'

        WHEN DATEDIFF(
                DAY,
                ap.ReceiptDate,
                ci.DueDate
             ) BETWEEN -15 AND -11
        THEN 'Received with Delay 11-15 Days'

        WHEN DATEDIFF(
                DAY,
                ap.ReceiptDate,
                ci.DueDate
             ) BETWEEN -10 AND -6
        THEN 'Received with Delay 6-10 Days'

        WHEN DATEDIFF(
                DAY,
                ap.ReceiptDate,
                ci.DueDate
             ) BETWEEN -5 AND -1
        THEN 'Received with Delay 1-5 Days'

        WHEN DATEDIFF(
                DAY,
                ap.ReceiptDate,
                ci.DueDate
             ) >= 0
        THEN 'Received On Time'

        ELSE 'Unknown'
    END AS DueType
FROM CustomerInvoices ci
LEFT JOIN AppliedEntries ap
    ON ap.InvEntryNo = ci.InvEntryNo;