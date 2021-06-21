enum 1370 "Batch Posting Parameter Type"
{
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; "Invoice") { Caption = 'Invoice'; }
    value(1; "Ship") { Caption = 'Ship'; }
    value(2; "Receive") { Caption = 'Receive'; }
    value(3; "Posting Date") { Caption = 'Posting Date'; }
    value(4; "Replace Posting Date") { Caption = 'Replace Posting Date'; }
    value(5; "Replace Document Date") { Caption = 'Replace Document Date'; }
    value(6; "Calculate Invoice Discount") { Caption = 'Calculate Invoice Discount'; }
    value(7; "Print") { Caption = 'Print'; }
    value(10000; "VAT Date") { Caption = 'VAT Date'; ObsoleteState = Pending; ObsoleteReason = 'Moved to Core Localization Pack for Czech.'; ObsoleteTag = '17.4'; }
    value(10001; "Replace VAT Date") { Caption = 'Replace VAT Date'; ObsoleteState = Pending; ObsoleteReason = 'Moved to Core Localization Pack for Czech.'; ObsoleteTag = '17.4'; }
}