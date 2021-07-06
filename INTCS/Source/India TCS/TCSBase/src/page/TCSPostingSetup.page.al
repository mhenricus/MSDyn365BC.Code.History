page 18812 "TCS Posting Setup"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "TCS posting setup";
    Caption = 'TCS Posting Setup';
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("TCS Nature of Collection"; "TCS Nature of Collection")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies TCS Nature of Collection of the customer account to link transactions made to this customer with the appropriate general ledger account according to TCS posting setup.';
                }
                field("Effective Date"; "Effective Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which the TCS rate on this line comes into effect.';
                }
                field("TCS Account No."; "TCS Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general ledger account number to which TCS amount will be posted for the TCS Nature of Collection.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(EditInExcel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Edit in Excel';
                Image = Excel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Send the data in the page to an Excel file for analysis or editing';

                trigger OnAction()
                var
                    ODataUtility: Codeunit ODataUtility;
                    CodeLbl: Label 'Code eq ''%1''', Comment = '%1=TCS Nature of Collection Code';
                begin
                    ODataUtility.EditWorksheetInExcel('TCS Posting Setup', CurrPage.ObjectId(false), StrSubstNo(CodeLbl, Rec."TCS Nature of Collection"));
                end;
            }
        }
    }
}