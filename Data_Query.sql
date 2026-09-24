SELECT [Entry No_], [Document Type], [Document No_], [Customer No_], [Customer Posting Group], [Advance Payment]
   FROM [IPPL$Cust_ Ledger Entry]
   INNER JOIN IPPL$Customer ON [Customer No_] = IPPL$Customer.No_
   WHERE [IPPL$Cust_ Ledger Entry].Customer Posting Group= 'DOMESTIC' AND [Advance Payment] = 1;
