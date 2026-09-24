--PMS v3



DECLARE @FromDate date = '2026-07-01';

DECLARE @ToDate   date = '2026-07-31';
 
IF OBJECT_ID('tempdb..#InvoicesInScope') IS NOT NULL DROP TABLE #InvoicesInScope;

IF OBJECT_ID('tempdb..#InvoiceBase')     IS NOT NULL DROP TABLE #InvoiceBase;
 
--materialized once instead of recomputed 5x -PMS
 
SELECT v.[Entry No_] AS InvEntryNo, v.*

INTO #InvoicesInScope

FROM [IPPL$Vendor Ledger Entry] v

WHERE v.[Vendor Posting Group] NOT IN ('BRANCH','DOM IC')

  AND v.[Document Type] = 2

  AND v.[Posting Date] >= @FromDate AND v.[Posting Date] <= DATEADD(DAY,1,@ToDate);
 
CREATE UNIQUE CLUSTERED INDEX IX_temp_IIS_EntryNo ON #InvoicesInScope (InvEntryNo);

CREATE NONCLUSTERED INDEX IX_temp_IIS_DocNo        ON #InvoicesInScope ([Document No_]);
 
 
;WITH

VLE_Amounts AS (

    SELECT

        d.[Vendor Ledger Entry No_] AS EntryNo,

        SUM(CASE WHEN d.[Entry Type] = 1 THEN d.Amount         ELSE 0 END) AS OriginalAmount,

        SUM(CASE WHEN d.[Entry Type] = 1 THEN d.[Amount (LCY)] ELSE 0 END) AS OriginalAmountLCY,

        SUM(d.Amount)         AS RemainingAmount,

        SUM(d.[Amount (LCY)]) AS RemainingAmountLCY

    FROM [IPPL$Detailed Vendor Ledg_ Entry] d

    JOIN #InvoicesInScope i ON i.InvEntryNo = d.[Vendor Ledger Entry No_]

    GROUP BY d.[Vendor Ledger Entry No_]

),

PurchInvLineFirst AS (

    SELECT pil.[Document No_] AS InvoiceNo, pil.[Receipt No_] AS ReceiptNo,

           ROW_NUMBER() OVER (PARTITION BY pil.[Document No_] ORDER BY pil.[Line No_]) AS rn

    FROM [IPPL$Purch_ Inv_ Line] pil

    JOIN #InvoicesInScope i ON i.[Document No_] = pil.[Document No_]

    WHERE pil.[Type] = 2

),

POResolution AS (

    SELECT pih.[No_] AS InvoiceNo,

           CASE WHEN pih.[Order No_] <> '' THEN pih.[Order No_] ELSE prh.[Order No_] END AS ResolvedOrderNo

    FROM [IPPL$Purch_ Inv_ Header] pih

    JOIN #InvoicesInScope i ON i.[Document No_] = pih.[No_]

    LEFT JOIN PurchInvLineFirst pl ON pl.InvoiceNo = pih.[No_] AND pl.rn = 1

    LEFT JOIN [IPPL$Purch_ Rcpt_ Header] prh ON prh.[No_] = pl.ReceiptNo

),

ApprovalResolution AS (

    SELECT po.InvoiceNo, ae.[Approver ID] AS ApproverID,

           ROW_NUMBER() OVER (PARTITION BY po.InvoiceNo ORDER BY ae.[Entry No_]) AS rn

    FROM POResolution po

    JOIN [IPPL$Approval Entry] ae

         ON ae.[Document No_] = po.ResolvedOrderNo

        AND ae.[Table ID] = 38 AND ae.[Document Type] = 1 AND ae.Status = 2

    WHERE po.ResolvedOrderNo IS NOT NULL AND po.ResolvedOrderNo <> ''

),

GLCreated AS (

    SELECT g.[Document No_], g.[JT Creation Date],

           ROW_NUMBER() OVER (PARTITION BY g.[Document No_] ORDER BY g.[Entry No_]) AS rn

    FROM [IPPL$G_L Entry] g

    JOIN #InvoicesInScope i ON i.[Document No_] = g.[Document No_]

    WHERE g.[Document Type] = 2

)

SELECT

    v.InvEntryNo, v.[Vendor No_] AS VendorNo, v.[Document No_] AS DocumentNo,

    v.[Posting Date] AS InvPostingDate, v.[Due Date] AS DueDate,

    CASE WHEN v.[Currency Code] <> '' THEN v.[Currency Code] ELSE gls.[LCY Code] END AS CurrencyCode,

    v.[External Document No_] AS ExternalDocumentNo,

    v.[Global Dimension 1 Code] AS Inv_GlobalDim1,

    v.[Global Dimension 2 Code] AS Inv_GlobalDim2,

    v.[Closed by Entry No_]    AS Inv_ClosedByEntryNo,

    v.[Closed by Amount]       AS Inv_ClosedByAmount,

    v.[Closed by Amount (LCY)] AS Inv_ClosedByAmountLCY,

    ven.Name AS VendorName, ven.[Vendor Posting Group] AS VendorPostingGroup,

    ven.[Gen_ Bus_ Posting Group] AS GenBusPostingGroup, ven.MSME AS MSME,

    pih.[Order Date] AS PIH_OrderDate, pih.[Payment Terms Code] AS PaymentTermsCode,

    pih.[Location Code] AS LocationCode, pih.[Purchase Type] AS PIH_PurchaseTypeRaw,

    pih.[Vendor Invoice Date] AS VendorInvoiceDate,

    gl.[JT Creation Date] AS CreatedInERPDate,

    por.ResolvedOrderNo AS PurchaseOrderNo, ar.ApproverID AS ApprovedBy,

    ISNULL(am.OriginalAmount,0) AS OriginalAmount,

    ISNULL(am.OriginalAmountLCY,0) AS OriginalAmountLCY,

    ISNULL(am.RemainingAmount,0) AS RemainingAmount,

    ISNULL(am.RemainingAmountLCY,0) AS RemainingAmountLCY,

    v.[Reason for Late Accouting] AS Inv_ReasonForLateAccountingRaw

INTO #InvoiceBase

FROM #InvoicesInScope v

CROSS JOIN (SELECT TOP 1 [LCY Code] FROM [IPPL$General Ledger Setup]) gls

LEFT JOIN VLE_Amounts am ON am.EntryNo = v.InvEntryNo

LEFT JOIN [IPPL$Vendor] ven ON ven.[No_] = v.[Vendor No_]

LEFT JOIN [IPPL$Purch_ Inv_ Header] pih ON pih.[No_] = v.[Document No_]

LEFT JOIN (SELECT * FROM GLCreated WHERE rn = 1) gl ON gl.[Document No_] = v.[Document No_]

LEFT JOIN POResolution por ON por.InvoiceNo = v.[Document No_]

LEFT JOIN (SELECT * FROM ApprovalResolution WHERE rn = 1) ar ON ar.InvoiceNo = v.[Document No_];
 
CREATE UNIQUE CLUSTERED INDEX IX_temp_IB_EntryNo        ON #InvoiceBase (InvEntryNo);

CREATE NONCLUSTERED INDEX     IX_temp_IB_ClosedByEntryNo ON #InvoiceBase (Inv_ClosedByEntryNo);
 
;WITH

AppRowsRaw AS (

    SELECT

        ib.InvEntryNo,

        a.[Entry No_]                AS AppliedEntryNo,

        a.[Closed by Amount]         AS AppAmount,

        a.[Closed by Amount (LCY)]   AS AppAmountFCY,

        a.[Document No_]             AS AppliedDocumentNo,

        a.[Document Type]            AS AppliedDocumentTypeRaw,

        a.[Posting Date]             AS AppliedPostingDate,

        a.[Original Currency Factor] AS AppliedCurrencyFactor,

        a.[TDS Nature of Deduction]  AS AppliedTDSNature,

        a.[Reason for Late Accouting] AS AppliedReasonForLateAccountingRaw,

        a.[Global Dimension 1 Code]  AS Applied_GlobalDim1,

        a.[Global Dimension 2 Code]  AS Applied_GlobalDim2,

        a.[Advance Payment]          AS AppliedAdvancePaymentRaw   -- pulled from source VLE, not derived

    FROM #InvoiceBase ib

    JOIN [IPPL$Vendor Ledger Entry] a ON a.[Closed by Entry No_] = ib.InvEntryNo
 
    UNION ALL
 
    SELECT

        ib.InvEntryNo,

        a.[Entry No_]                AS AppliedEntryNo,

        ib.Inv_ClosedByAmount        AS AppAmount,

        ib.Inv_ClosedByAmountLCY     AS AppAmountFCY,

        a.[Document No_]             AS AppliedDocumentNo,

        a.[Document Type]            AS AppliedDocumentTypeRaw,

        a.[Posting Date]             AS AppliedPostingDate,

        a.[Original Currency Factor] AS AppliedCurrencyFactor,

        a.[TDS Nature of Deduction]  AS AppliedTDSNature,

        a.[Reason for Late Accouting] AS AppliedReasonForLateAccountingRaw,

        a.[Global Dimension 1 Code]  AS Applied_GlobalDim1,

        a.[Global Dimension 2 Code]  AS Applied_GlobalDim2,

        a.[Advance Payment]          AS AppliedAdvancePaymentRaw   -- pulled from source VLE, not derived

    FROM #InvoiceBase ib

    JOIN [IPPL$Vendor Ledger Entry] a ON a.[Entry No_] = ib.Inv_ClosedByEntryNo

    WHERE ib.Inv_ClosedByEntryNo <> 0

),

AppRows AS (

    SELECT *,

        ROW_NUMBER() OVER (PARTITION BY InvEntryNo, AppliedEntryNo ORDER BY AppliedEntryNo) AS dup_rn

    FROM AppRowsRaw

),

StagingRows AS (

    SELECT

        ib.*,

        ar.AppliedEntryNo, ar.AppAmount, ar.AppAmountFCY, ar.AppliedDocumentNo,

        ar.AppliedDocumentTypeRaw, ar.AppliedPostingDate, ar.AppliedCurrencyFactor,

        ar.AppliedReasonForLateAccountingRaw,

        CASE

            WHEN ib.Inv_ReasonForLateAccountingRaw IS NOT NULL AND ib.Inv_ReasonForLateAccountingRaw <> 0

            THEN ib.Inv_ReasonForLateAccountingRaw

            ELSE ar.AppliedReasonForLateAccountingRaw

        END AS ResolvedReasonForLateAccounting,

        ar.Applied_GlobalDim1, ar.Applied_GlobalDim2,

        ar.AppliedAdvancePaymentRaw,

        CASE WHEN ar.AppliedTDSNature IS NOT NULL AND ar.AppliedTDSNature <> ''

                  AND ar.AppliedDocumentTypeRaw = 0

             THEN 1 ELSE 0 END AS TDSEntry,

        ROW_NUMBER() OVER (PARTITION BY ib.InvEntryNo ORDER BY ar.AppliedEntryNo) AS row_rn,

        ABS(ISNULL(ar.AppAmount,0))    AS AppAmountAbs,

        ABS(ISNULL(ar.AppAmountFCY,0)) AS AppAmountFCYAbs,

        DATEDIFF(DAY, ar.AppliedPostingDate, ib.DueDate) AS NoofdaysCal

    FROM #InvoiceBase ib

    LEFT JOIN (SELECT * FROM AppRows WHERE dup_rn = 1) ar ON ar.InvEntryNo = ib.InvEntryNo

),

WithFlags AS (

SELECT *,

    CASE WHEN TDSEntry = 1 AND AppAmountAbs <> 0 THEN AppAmountAbs * -1 ELSE AppAmountAbs END AS ApplicationAmount,

    CASE WHEN row_rn = 1 THEN ABS(OriginalAmount) ELSE 0 END AS OriginalAmountOut,

    CASE WHEN row_rn = 1 THEN OriginalAmountLCY   ELSE 0 END AS OriginalAmountLCYOut,

    CASE WHEN row_rn = 1 THEN Inv_GlobalDim1 ELSE Applied_GlobalDim1 END AS BranchOut,

    CASE WHEN row_rn = 1 THEN Inv_GlobalDim2 ELSE Applied_GlobalDim2 END AS DivisionOut,

    CASE WHEN AppliedAdvancePaymentRaw = 1 THEN 'Yes' ELSE 'No' END AS AdvancePaymentOut,

    CASE

        WHEN AppliedPostingDate IS NULL AND DueDate >  @ToDate THEN 'Not overdue and not paid'

        WHEN AppliedPostingDate IS NULL AND DueDate <= @ToDate THEN 'Overdue but not paid'

        WHEN NoofdaysCal <= -16                       THEN 'Paid in more than 16 days'

        WHEN NoofdaysCal BETWEEN -15 AND -11          THEN 'Paid with Delay of 11-15 days'

        WHEN NoofdaysCal BETWEEN -10 AND -6           THEN 'Paid with Delay of 6-10 days'

        WHEN NoofdaysCal BETWEEN -5  AND -1           THEN 'Paid with Delay of 1-5 days'

        WHEN NoofdaysCal >= 0                         THEN 'Paid on time'

        ELSE ' '

    END AS DueTypeOut

FROM StagingRows

)

SELECT

VendorNo                            AS [Vendor number],

VendorName                          AS [Vendor Name],

VendorPostingGroup                  AS [Vendor Posting Group],

PurchaseOrderNo                     AS [Purchase order number],

PIH_OrderDate                       AS [Purchase order Date],

ExternalDocumentNo                  AS [External document number],

ApprovedBy                          AS [Approved by],

InvPostingDate                      AS [Posting Date],

DocumentNo                          AS [Purchase invoice number],

CreatedInERPDate                    AS [Created in ERP date],

PaymentTermsCode                    AS [Payment terms ERP],

DueDate                             AS [Due Date],

AppliedPostingDate                  AS [Applied Document Date],

OriginalAmountOut                   AS [Original amount],

CurrencyCode                        AS [Currency code],

OriginalAmountLCYOut                AS [Original amount(LCY)],

BranchOut                           AS [Branch],

DivisionOut                         AS [Division],

LocationCode                        AS [Location],

CASE PIH_PurchaseTypeRaw

    WHEN 0 THEN 'Blank' WHEN 1 THEN 'Commodity' WHEN 2 THEN 'Packing materials'

    WHEN 3 THEN 'Consumables' WHEN 4 THEN 'Service' WHEN 5 THEN 'Fixed Asset'

    ELSE 'Blank'

END                                  AS [Purchase type],

AppliedDocumentNo                   AS [Applied document number],

AppAmountFCYAbs                     AS [Applied bank amount(LCY)],

CASE AppliedDocumentTypeRaw

    WHEN 0 THEN 'Null' WHEN 1 THEN 'Payment' WHEN 2 THEN 'Invoice' WHEN 3 THEN 'Credit Memo'

    ELSE ' '

END                                  AS [Applied Document Type],

AdvancePaymentOut                   AS [Advance Payment],

NoofdaysCal                         AS [Number of days between Duedate and Payment],

GenBusPostingGroup                  AS [Vendor Gen. Bus Posting Group],

ApplicationAmount                   AS [Application Amount],

SUM(CASE WHEN TDSEntry = 0 THEN AppAmountFCYAbs ELSE -AppAmountFCYAbs END)

    OVER (PARTITION BY InvEntryNo) AS [Total Apllied amount],

SUM(ApplicationAmount) OVER (PARTITION BY InvEntryNo) AS [Total Apllied amountFCY],

RemainingAmountLCY                  AS [Invoice Remaining Amount LCY],

RemainingAmount                     AS [Invoice Remaining Amount],

CASE ResolvedReasonForLateAccounting

WHEN 0 THEN 'Blank' WHEN 1 THEN 'Missing Docs' WHEN 2 THEN 'Invoice mismatch'

WHEN 3 THEN 'Cash Flow' WHEN 4 THEN 'Dispute' WHEN 5 THEN 'Delay in approval'

WHEN 6 THEN 'Delay in submission for approval'

--WHEN 0 and AdvancePaymentOut = 'Yes' THEN 

ELSE 'Blank'

END AS [Reason for delay],

CASE WHEN MSME = 1 THEN 'Registered' ELSE 'Not Registered' END AS [MSME Vendor Type],

VendorInvoiceDate AS [Vendor Invoice Date],

DueTypeOut AS [DueType]

FROM WithFlags

ORDER BY DocumentNo, row_rn;
 
DROP TABLE #InvoicesInScope;

DROP TABLE #InvoiceBase;
 
