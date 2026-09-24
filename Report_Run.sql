UPDATE [dbo].[IPPL$Job Queue]

SET [Started] = 1,                          -- 0 = Ready (so the NAS picks it up)
    [Last Heartbeat] = SYSDATETIME(),
    [Running as User ID] = 'JAYANTI\SABARISHBABU',
    [Server Instance ID] = '5717',
    [Start on This NAS Computer] = 'indjay-navlive.jayanti.local'

    WHERE [Code] = 'REPORT';

   


