
CREATE VIEW vw_GLEntry_AnalysisExport
AS
SELECT
      GLE.[Entry No_]
    , GLE.[Posting Date]
    , GLE.[Document No_]
    , GLE.[G_L Account No_]
    , GLA.[Name] AS [G_L Account Name]
    , GLE.[Amount]
    , GLE.[Debit Amount]
    , GLE.[Credit Amount]

    , GLE.[Global Dimension 1 Code] AS [Division]
    , GLE.[Global Dimension 2 Code] AS [Branch]

FROM [dbo].[IPPL$G_L Entry] GLE
INNER JOIN [dbo].[IPPL$G_L Account] GLA
    ON GLA.[No_] = GLE.[G_L Account No_];
GO

USE [Jayanti_UAT_JUN26];

GO

SELECT

    [Full Name]
   
FROM [dbo].[User]


-- If step 0c returns rows, Bulk/PL/Corp lives on G/L Entry directly —
-- use [Global Dimension 1 Code] (or 2) in the view below and DELETE
-- the Dimension Set Entry join in Step 2.
-- If it returns nothing, it's a non-shortcut dimension and you need
-- the Dimension Set Entry join that IS included below — confirm the
-- exact Dimension Code with:
-- SELECT * FROM [IPPL$Dimension] ;


/* ------------------------------------------------------------
   STEP 1 — MAPPING TABLE
   This is a plain SQL table living only in this reporting layer —
   it is NOT a NAV object and does not touch NAV's object license.
   Holds the JSA_grouping.xlsx logic so it's a single maintained
   source instead of a loose Excel file once this feeds a live report.
   ------------------------------------------------------------ */

CREATE TABLE [dbo].[MIS_GL_Mapping] (
    [GL_No]        NVARCHAR(20)  NOT NULL,
    [FS_Type]      NVARCHAR(10)  NULL,   -- 'BS' or 'P&L'
    [Grouping]     NVARCHAR(100) NULL,
    [Row_In_MIS]   INT           NULL,
    CONSTRAINT PK_MIS_GL_Mapping PRIMARY KEY ([GL_No])
);

-- Populate this from JSA_grouping.xlsx — easiest path is SSMS's
-- "Import Flat File" wizard (right-click database → Tasks → Import
-- Flat File) pointed at a CSV export of the sheet, targeting this
-- table. Alternatively, insert manually, e.g.:
--
-- INSERT INTO [dbo].[MIS_GL_Mapping] ([GL_No],[FS_Type],[Grouping],[Row_In_MIS])
-- VALUES ('11101','BS','Retained Earnings',104);


/* ------------------------------------------------------------
   STEP 2 — THE VIEW
   Adjust table/column names per your Step 0 findings.
   This version assumes Bulk/PL/Corp = Global Dimension 1
   (the common case). If it's Dimension Set Entry instead,
   see the commented alternative block below.
   ------------------------------------------------------------ */

SELECT
    E.[G_L Account No_]         AS GL_No,
    A.[Name]                    AS GL_Name,
    E.[Global Dimension 1 Code] AS Business_Unit,
    E.[Posting Date]            AS Posting_Date,
    E.[Amount]                  AS Amount,
    E.[Global Dimension 1 Code] AS Dimension
FROM [IPPL$G_L Entry] E
INNER JOIN [IPPL$G_L Account] A
    ON A.[No_] = E.[G_L Account No_]

/* -- ALTERNATIVE Step 2 join, only if Step 0c found nothing and
   -- Bulk/PL/Corp requires Dimension Set Entry instead:
   --
   -- ...FROM [IPPL$G/L Entry] E
   -- INNER JOIN [IPPL$G/L Account] A ON A.[No_] = E.[G/L Account No_]
   -- LEFT JOIN [IPPL$Dimension Set Entry] D
   --     ON D.[Dimension Set ID] = E.[Dimension Set ID]
   --     AND D.[Dimension Code] = 'BUSINESS UNIT'   -- confirm exact code from Step 0c note
   -- LEFT JOIN [dbo].[MIS_GL_Mapping] M ON M.[GL_No] = E.[G/L Account No_]
   -- ... then select D.[Dimension Value Code] AS Business_Unit
*/


/* ------------------------------------------------------------
   STEP 3 — INDEXES
   Required for DirectQuery — these are the columns every
   Power BI filter/slicer will hit on every interaction.
   Confirm existing indexes first; NAV's base tables usually
   already have some of these — don't duplicate.
   ------------------------------------------------------------ */

-- Check existing indexes before adding:
-- EXEC sp_helpindex '[IPPL$G/L Entry]';
CREATE NONCLUSTERED INDEX IX_GLEntry_MIS
ON [dbo].[IPPL$G_L Entry]
(
    [G_L Account No_],
    [Posting Date],
    [Global Dimension 1 Code]
)
INCLUDE ([Amount]);


/* ------------------------------------------------------------
   STEP 4 — READ-ONLY LOGIN FOR POWER BI
   Run in the master database, then grant view access in the
   NAV database itself. Replace password with a strong secret
   and store it wherever your team keeps DB credentials.
   ------------------------------------------------------------ */

-- In master:
CREATE LOGIN PowerBI_MIS_Reader WITH PASSWORD = 'REPLACE_WITH_STRONG_PASSWORD';

-- In the NAV database (e.g. Jayanti_UAT_JUN26, then repeat for prod):
CREATE USER PowerBI_MIS_Reader FOR LOGIN PowerBI_MIS_Reader;
GRANT SELECT ON [dbo].[IPPL$G_L Entry] TO PowerBI_MIS_Reader;
GRANT SELECT ON [dbo].[IPPL$G_L Account] TO PowerBI_MIS_Reader;
GRANT SELECT ON [dbo].[MIS_GL_Mapping] TO PowerBI_MIS_Reader;
-- Do NOT grant broader db_datareader — scope strictly to these two objects.


/* ------------------------------------------------------------
   STEP 5 — SANITY CHECK
   Run this as PowerBI_MIS_Reader to confirm it can read the
   view and nothing else, before connecting Power BI Desktop.
   ------------------------------------------------------------ */

SELECT TOP 100
    E.[G_L Account No_]         AS GL_No,
    A.[Name]                    AS GL_Name,
    E.[Global Dimension 1 Code] AS Business_Unit,
    E.[Posting Date]            AS Posting_Date,
    E.[Amount]                  AS Amount
FROM [IPPL$G_L Entry] E
INNER JOIN [IPPL$G_L Account] A
    ON A.[No_] = E.[G_L Account No_];

SELECT SUM(CAST(E.[Amount] AS DECIMAL(18,2))) AS TotalAmount
FROM [IPPL$G_L Entry] E
WHERE E.[Posting Date] >= '2024-04-01'   -- your real reporting window