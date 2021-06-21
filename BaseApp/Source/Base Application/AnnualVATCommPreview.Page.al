page 12127 "Annual VAT Comm. Preview"
{
    Caption = 'Annual VAT Comm. Preview';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    SourceTable = "VAT Statement Name";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Statement Template Name"; "Statement Template Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the template.';
                }
                field(Name; Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name.';
                }
                field("Activity Code"; ActivityCode)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Activity Code';
                    TableRelation = "Activity Code".Code;
                    ToolTip = 'Specifies a code that describes a primary activity for the company.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        SetFilter("Activity Code Filter", ActivityCode);
                        CurrPage.Update();
                    end;
                }
                field("Date Filter"; DateFilter)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Date Filter';
                    ToolTip = 'Specifies the date filter.';

                    trigger OnValidate()
                    var
                        FilterTokens: Codeunit "Filter Tokens";
                    begin
                        FilterTokens.MakeDateFilter(DateFilter);
                        SetFilter("Date Filter", DateFilter);
                        CurrPage.Update();
                    end;
                }
            }
            part(VATStatementLineSubForm; "VAT Statement Preview Line")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Statement Template Name" = FIELD("Statement Template Name"),
                              "Statement Name" = FIELD(Name);
                SubPageView = SORTING("Statement Template Name", "Statement Name", "Line No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(Export)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Export';
                    Ellipsis = true;
                    Image = Export;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Export the document.';

                    trigger OnAction()
                    begin
                        Export;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateSubForm;
    end;

    trigger OnInit()
    begin
        Selection := Selection::"Open and Closed";
        PeriodSelection := PeriodSelection::"Within Period";
    end;

    trigger OnOpenPage()
    begin
        UpdateSubForm;
    end;

    var
        Selection: Option Open,Closed,"Open and Closed";
        PeriodSelection: Option "Before and Within Period","Within Period";
        ActivityCode: Code[6];
        DateFilter: Text;

    [Obsolete('Function scope will be changed to OnPrem','15.1')]
    procedure UpdateSubForm()
    begin
        CurrPage.VATStatementLineSubForm.PAGE.UpdateForm(Rec, Selection, PeriodSelection, false, '');
    end;
}

