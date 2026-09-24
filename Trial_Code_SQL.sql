
UPDATE [Jayanti_UAT_May’26].dbo.[IPPL$Job Queue]
SET [Started] = 1
WHERE [Code] = 'NOTIFYPO';
SELECT *
FROM [Jayanti_UAT_May’26].dbo.[IPPL$Job Queue]
WHERE [Code] = 'NOTIFYPO';
