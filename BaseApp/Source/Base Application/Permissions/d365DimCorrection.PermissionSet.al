permissionset 2980 "D365 DIM CORRECTION"
{
    Assignable = true;

    Caption = 'D365 Dimension Correction';
    Permissions = tabledata "Dim Correct Selection Criteria" = RIMD,
                  tabledata "Dim Correction Blocked Setup" = RIMD,
                  tabledata "Dim Correction Change" = RIMD,
                  tabledata "Dim Correction Set Buffer" = RIMD,
                  tabledata "Dim Correction Entry Log" = RIMD,
                  tabledata "Dimension Correction" = RIMD,
                  tabledata "Change Global Dim. Header" = RIMD,
                  tabledata "Change Global Dim. Log Entry" = RIMD,
                  tabledata "Invalidated Dim Correction" = RIMD;
}
