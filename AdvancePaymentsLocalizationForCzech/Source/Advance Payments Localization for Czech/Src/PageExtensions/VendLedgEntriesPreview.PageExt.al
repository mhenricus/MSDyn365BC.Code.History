#if not CLEAN19
pageextension 31055 "Vend. Ledg. Entries PreviewCZZ" extends "Vend. Ledg. Entries Preview"
{
    layout
    {
#pragma warning disable AL0432
        modify(Prepayment)
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Prepayment Type")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Open For Advance Letter")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
#pragma warning restore AL0432
    }

    var
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
        AdvancePaymentsEnabledCZZ: Boolean;

    trigger OnOpenPage()
    begin
        AdvancePaymentsEnabledCZZ := AdvancePaymentsMgtCZZ.IsEnabled();
    end;
}

#endif