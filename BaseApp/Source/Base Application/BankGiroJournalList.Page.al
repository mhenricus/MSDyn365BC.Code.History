page 11402 "Bank/Giro Journal List"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Bank/Giro Journal';
    CardPageID = "Bank/Giro Journal";
    Editable = false;
    PageType = List;
    SourceTable = "CBG Statement";
    SourceTableView = SORTING(Type)
                      WHERE(Type = CONST("Bank/Giro"));
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Journal Template Name"; "Journal Template Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the journal template.';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the statement.';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a document number for the CBG statement of type Bank/Giro.';
                }
                field(Date; Date)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when you created the CBG statement.';
                }
                field(Currency; Currency)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency code for the amounts on the statement lines.';
                }
                field("Opening Balance"; "Opening Balance")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the current balance (LCY) of the bank/giro or cash account.';
                }
                field("Closing Balance"; "Closing Balance")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the new closing balance, after you have entered all statements in the Bank/Giro journal or all payment/receipt entries.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Import Bank Statement")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Import Bank Statement';
                Image = Import;
                ToolTip = 'Import electronic bank statements from your bank to update transactions in your bank data.';

                trigger OnAction()
                begin
                    CODEUNIT.Run(CODEUNIT::"Import Protocol Management");
                end;
            }
        }
    }
}
