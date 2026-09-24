--Add to tool Active users
SELECT
    [Server Instance ID],
    [Session ID],
    [User ID],
    [Client Type],
    [Client Computer Name],
    [Login Datetime],
    CAST([Login Datetime] AS DATE) AS [Login Date],
    [Database Name],
    [Server Computer Name],
    [Server Instance Name]
    
FROM [Active Session]
ORDER BY [Login Datetime] DESC;

--Not Used
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Active Session'
ORDER BY ORDINAL_POSITION;

SELECT
      A.[User ID],
      U.[Full Name],
      A.[Login Datetime],
      A.[Client Computer Name]
  FROM [Active Session] A
  LEFT JOIN [User] U
      ON A.[User SID] = U.[User Security ID]
  ORDER BY A.[Login Datetime] DESC;

--Not Used
  SELECT
    DB_NAME(mf.data_space_id) AS [Database Name],
    CAST(SUM(mf.size) / 128.0 AS DECIMAL(18,2)) AS [Allocated Size (MB)],
    CAST(SUM(FILEPROPERTY(mf.name, 'SpaceUsed')) / 128.0 AS DECIMAL(18,2)) AS [Used Space (MB)]
FROM sys.database_files mf
GROUP BY mf.data_space_id
ORDER BY [Allocated Size (MB)] DESC;

--For DB Size Utilized/Remaining
SELECT
   DB_NAME() AS [Database Name],
    CAST(SUM(mf.size) / 128.0 AS DECIMAL(18,2)) AS [Total Allocated Size (MB)],
    CAST(SUM(CAST(FILEPROPERTY(mf.name, 'SpaceUsed') AS BIGINT)) / 128.0 AS DECIMAL(18,2)) AS [Total Used Space (MB)]
FROM sys.database_files mf;

SELECT
    DB_NAME() AS [Database Name],
    df.name AS [Logical File Name],
    df.physical_name AS [File Path],
    df.type_desc AS [File Type],
    CAST(df.size / 128.0 AS DECIMAL(18,2)) AS [Allocated Size (MB)],
    CAST(FILEPROPERTY(df.name, 'SpaceUsed') / 128.0 AS DECIMAL(18,2)) AS [Used Space (MB)],
    CAST((df.size - FILEPROPERTY(df.name, 'SpaceUsed')) / 128.0 AS DECIMAL(18,2)) AS [Free Space (MB)],
    CAST(
        (CAST(FILEPROPERTY(df.name, 'SpaceUsed') AS FLOAT) / df.size) * 100
        AS DECIMAL(5,2)
    ) AS [Used %]
FROM sys.database_files df
ORDER BY df.type_desc;

--Used in PBI
--For getting the JQ Success Failure
SELECT
    [ID],
    [Status],
    [Job Queue Category Code],
    [Start Date_Time],
    CAST([Start Date_Time] AS DATE) AS [Run Date]
FROM [IPPL$Job Queue Log Entry]
WHERE
CAST([Start Date_Time] AS DATE) = '2026-07-07';-- CAST(GETDATE() AS DATE)
SELECT COUNT(*) AS NoOfRows
FROM [IPPL$Job Queue Log Entry]
WHERE CAST(DATEADD(MINUTE, 330, [Start Date_Time]) AS DATE) = '2026-07-07';





SELECT DISTINCT [Status]
   FROM [IPPL$Job Queue Log Entry];

   SELECT COUNT(*) FROM [IPPL$Job Queue Log Entry] WHERE CAST([Start Date_Time] AS DATE) = CAST(GETDATE() AS DATE)
   USE [Jayanti_UAT_May’26];
GRANT VIEW DATABASE PERFORMANCE STATE TO [JAYANTI\SABARISHBABU];
   SELECT TOP 50
    DB_NAME(t.dbid) AS [Database Name],
    qs.execution_count AS [Times Run],
    qs.total_elapsed_time / 1000.0 AS [Total Duration (ms)],
    qs.total_elapsed_time / qs.execution_count / 1000.0 AS [Avg Duration (ms)],
    qs.max_elapsed_time / 1000.0 AS [Max Duration (ms)],
    qs.total_worker_time / qs.execution_count / 1000.0 AS [Avg CPU (ms)],
    qs.total_logical_reads / qs.execution_count AS [Avg Logical Reads],
    qs.last_execution_time AS [Last Run],
    qs.creation_time AS [First Seen],
    SUBSTRING(t.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(t.text)
            ELSE qs.statement_end_offset END
        - qs.statement_start_offset)/2)+1) AS [Query Text]
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) t
WHERE t.dbid = DB_ID()  -- restrict to current database; remove to see all databases on the server
ORDER BY [Avg Duration (ms)] DESC;

--Blocked sessions
--current blockers and blocked sessions
SELECT
r.session_id AS blocked_session_id,
r.status,
r.wait_type,
r.wait_time,
r.wait_resource,
r.blocking_session_id AS blocking_session_id,
DB_NAME(r.database_id) AS [database],
s.login_name AS blocked_login,
s.host_name  AS blocked_host,
s.program_name AS blocked_program,
st.text AS blocked_sql_text
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s
    ON r.session_id = s.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) st
WHERE r.blocking_session_id <> 0
ORDER BY r.wait_time DESC;

--current blockers and blocked sessions, with count and user name
SELECT
    r.session_id AS blocked_session_id,
    r.status,
    r.wait_type,
    r.wait_time,
    r.wait_resource,
    r.blocking_session_id AS blocking_session_id,
    DB_NAME(r.database_id) AS [database],
    s.login_name AS blocked_login,
    s.host_name  AS blocked_host,
    s.program_name AS blocked_program,
    st.text AS blocked_sql_text,
    COUNT(*) OVER (PARTITION BY s.login_name) AS blocked_count_by_user,
    COUNT(*) OVER () AS total_blocked_sessions
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s
    ON r.session_id = s.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) st
WHERE r.blocking_session_id <> 0
ORDER BY r.wait_time DESC;


SELECT
    CAST(xe.event_data AS XML) AS DeadlockGraph,
    xe.timestamp_utc
FROM sys.fn_xe_file_target_read_file(
    'system_health*.xel', NULL, NULL, NULL) AS xe
WHERE xe.object_name = 'xml_deadlock_report'
ORDER BY xe.timestamp_utc DESC;

SELECT
    [Session ID],
    [User ID],
    [Client Type],
    [Client Computer Name],
    [Login Datetime],
    [Server Instance Name]
FROM [Active Session]
WHERE CAST([Login Datetime] AS DATE) = CAST(GETDATE() AS DATE)
ORDER BY [User ID];

select
r.session_id AS blocked_session_id,r.status,r.wait_type,r.wait_time,r.wait_resource,r.blocking_session_id AS blocking_session_id,
DB_NAME(r.database_id) AS [database],s.login_name AS blocked_login,s.host_name  AS blocked_host,
s.program_name AS blocked_program,st.text AS blocked_sql_text
from sys.dm_exec_requests r
join sys.dm_exec_sessions s on r.session_id = s.session_id
outer apply sys.dm_exec_sql_text(r.sql_handle) st
where r.blocking_session_id <> 0
order by r.wait_time desc;


SELECT 'GCPL'   AS Company, * FROM dbo.[GCPL$Job Queue Log Entry]   WHERE [Status] = 2 AND [Start Date_Time] >= DATEADD(day, -90, GETDATE())
UNION ALL
SELECT 'IPPL'   AS Company, * FROM dbo.[IPPL$Job Queue Log Entry]   WHERE [Status] = 2 AND [Start Date_Time] >= DATEADD(day, -7, GETDATE())
UNION ALL
SELECT 'JAE'    AS Company, * FROM dbo.[JAE$Job Queue Log Entry]    WHERE [Status] = 2 AND [Start Date_Time] >= DATEADD(day, -7, GETDATE())
UNION ALL
SELECT 'JAM'    AS Company, * FROM dbo.[JAM$Job Queue Log Entry]    WHERE [Status] = 2 AND [Start Date_Time] >= DATEADD(day, -7, GETDATE())
UNION ALL
SELECT 'JSA'    AS Company, * FROM dbo.[JSA$Job Queue Log Entry]    WHERE [Status] = 2 AND [Start Date_Time] >= DATEADD(day, -7, GETDATE())
UNION ALL
SELECT 'JSMP'   AS Company, * FROM dbo.[JSMP$Job Queue Log Entry]   WHERE [Status] = 2 AND [Start Date_Time] >= DATEADD(day, -7, GETDATE())
UNION ALL
SELECT 'JTR-SL' AS Company, * FROM dbo.[JTR-SL$Job Queue Log Entry] WHERE [Status] = 2 AND [Start Date_Time] >= DATEADD(day, -7, GETDATE())
UNION ALL
SELECT 'JVN'    AS Company, * FROM dbo.[JVN$Job Queue Log Entry]    WHERE [Status] = 2 AND [Start Date_Time] >= DATEADD(day, -7, GETDATE())
UNION ALL
SELECT 'NNBTS'  AS Company, * FROM dbo.[NNBTS$Job Queue Log Entry]  WHERE [Status] = 2 AND [Start Date_Time] >= DATEADD(day, -7, GETDATE())


--For Companies Count
SELECT c.Name AS CompanyName, NULL AS TotalCompanyCount
FROM [Jayanti_UAT_JUN26].[dbo].[Company] c
UNION ALL
SELECT 'TOTAL', COUNT(*)
FROM [Jayanti_UAT_JUN26].[dbo].[Company]
UNION ALL


--Concurrent Licenses
SELECT 'Concurrent Licenses' AS Caption, 63 AS Value;

--
SELECT
    [User ID],
    [Client Type],
    [Client Computer Name],
    [Session ID],
    [Server Instance Name],
    [Server Instance ID],
    [Login Datetime] AS [Raw SQL Value],
    [Login Datetime] AT TIME ZONE 'UTC' AT TIME ZONE 'India Standard Time' AS [Converted to IST]
FROM [Active Session]
WHERE CAST([Login Datetime] AS DATE) = CAST(GETDATE() AS DATE)