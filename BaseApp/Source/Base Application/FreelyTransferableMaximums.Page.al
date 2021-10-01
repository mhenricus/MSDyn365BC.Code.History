page 11406 "Freely Transferable Maximums"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Freely Transferable Maximums';
    PageType = List;
    SourceTable = "Freely Transferable Maximum";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1000000)
            {
                ShowCaption = false;
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for the country/region that the freely transferable maximum applies to.';
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency code that the freely transferable maximum applies to.';
                }
                field(Amount; Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the maximum amount that can be transferred without reason given.';
                }
            }
        }
    }

    actions
    {
    }
}
