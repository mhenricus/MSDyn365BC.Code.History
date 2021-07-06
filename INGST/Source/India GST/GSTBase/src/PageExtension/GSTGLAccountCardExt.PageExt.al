pageextension 18005 "GST G/L Account Card Ext" extends "G/L Account Card"
{
    layout
    {
        addlast("Posting")
        {
            field("GST Group Code"; "GST Group Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies an unique identifier for the GST group code used to calculate and post GST.';

            }
            field("GST Credit"; "GST Credit")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the GST credit has to be availed or not.';

            }
            field("HSN/SAC Code"; "HSN/SAC Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies an unique identifier for the type of HSN or SAC that is used to calculate and post GST.';

            }
            field(Exempted; Exempted)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the account is exempted from GST or not.';

            }
        }
    }
}