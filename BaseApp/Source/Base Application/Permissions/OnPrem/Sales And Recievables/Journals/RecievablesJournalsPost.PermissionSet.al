permissionset 6207 "Recievables Journals - Post"
{
    Access = Public;
    Assignable = false;
    Caption = 'Post journals (S&R)';

    Permissions = tabledata "Accounting Period" = r,
                  tabledata "Additional Fee Setup" = r,
                  tabledata "Analysis View" = rimd,
                  tabledata "Analysis View Entry" = rim,
                  tabledata "Analysis View Filter" = r,
                  tabledata "Bank Account" = m,
                  tabledata "Bank Account Ledger Entry" = rim,
                  tabledata "Batch Processing Parameter" = Rimd,
                  tabledata "Check Ledger Entry" = rim,
                  tabledata Currency = r,
                  tabledata "Currency Exchange Rate" = r,
                  tabledata "Currency for Reminder Level" = r,
                  tabledata "Cust. Ledger Entry" = rim,
                  tabledata Customer = r,
                  tabledata "Customer Bank Account" = R,
                  tabledata "Customer Posting Group" = R,
                  tabledata "Date Compr. Register" = r,
                  tabledata "Detailed Cust. Ledg. Entry" = ri,
                  tabledata "Dimension Combination" = R,
                  tabledata "Dimension Value Combination" = R,
                  tabledata "G/L Account" = r,
                  tabledata "G/L Entry - VAT Entry Link" = Ri,
                  tabledata "G/L Entry" = Ri,
                  tabledata "G/L Register" = Rim,
                  tabledata "Gen. Jnl. Allocation" = RIMD,
                  tabledata "Gen. Journal Batch" = RID,
                  tabledata "Gen. Journal Line" = RIMD,
                  tabledata "Gen. Journal Template" = RI,
                  tabledata "General Ledger Setup" = r,
                  tabledata "General Posting Setup" = r,
                  tabledata "Line Fee Note on Report Hist." = rim,
                  tabledata "Native - Payment" = RIMD,
                  tabledata "Reminder Level" = r,
                  tabledata "Reminder Terms" = r,
                  tabledata "Reminder Terms Translation" = r,
                  tabledata "Reversal Entry" = RIMD,
                  tabledata "Tax Area" = R,
                  tabledata "Tax Area Line" = R,
                  tabledata "Tax Detail" = R,
                  tabledata "Tax Group" = R,
                  tabledata "Tax Jurisdiction" = R,
                  tabledata "User Setup" = r,
                  tabledata "VAT Assisted Setup Bus. Grp." = R,
                  tabledata "VAT Assisted Setup Templates" = R,
                  tabledata "VAT Entry" = Ri,
                  tabledata "VAT Posting Setup" = R,
                  tabledata "VAT Rate Change Log Entry" = Ri,
                  tabledata "VAT Rate Change Setup" = R,
                  tabledata "VAT Setup Posting Groups" = R;
}