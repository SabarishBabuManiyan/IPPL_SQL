SELECT 'GCPL'   AS Company, * FROM dbo.[GCPL$Job Queue Log Entry]   WHERE [Status] = 2 AND [Start Date_Time] >= DATEADD(day, -60, GETDATE())
UNION ALL
SELECT 'IPPL'   AS Company, * FROM dbo.[IPPL$Job Queue Log Entry]   WHERE [Status] = 2 AND [Start Date_Time] >= DATEADD(day, -60, GETDATE())
UNION ALL
SELECT 'JAE'    AS Company, * FROM dbo.[JAE$Job Queue Log Entry]    WHERE [Status] = 2 AND [Start Date_Time] >= DATEADD(day, -60, GETDATE())
UNION ALL
SELECT 'JAM'    AS Company, * FROM dbo.[JAM$Job Queue Log Entry]    WHERE [Status] = 2 AND [Start Date_Time] >= DATEADD(day, -60, GETDATE())
UNION ALL
SELECT 'JSA'    AS Company, * FROM dbo.[JSA$Job Queue Log Entry]    WHERE [Status] = 2 AND [Start Date_Time] >= DATEADD(day, -60, GETDATE())
UNION ALL
SELECT 'JSMP'   AS Company, * FROM dbo.[JSMP$Job Queue Log Entry]   WHERE [Status] = 2 AND [Start Date_Time] >= DATEADD(day, -60, GETDATE())
UNION ALL
SELECT 'JTR-SL' AS Company, * FROM dbo.[JTR-SL$Job Queue Log Entry] WHERE [Status] = 2 AND [Start Date_Time] >= DATEADD(day, -60, GETDATE())
UNION ALL
SELECT 'JVN'    AS Company, * FROM dbo.[JVN$Job Queue Log Entry]    WHERE [Status] = 2 AND [Start Date_Time] >= DATEADD(day, -60, GETDATE())
UNION ALL
SELECT 'NNBTS'  AS Company, * FROM dbo.[NNBTS$Job Queue Log Entry]  WHERE [Status] = 2 AND [Start Date_Time] >= DATEADD(day, -60, GETDATE())