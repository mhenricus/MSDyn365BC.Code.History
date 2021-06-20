page 5005271 "Delivery Reminder Sub."
{
    AutoSplitKey = true;
    Caption = 'Lines';
    PageType = ListPart;
    SourceTable = "Delivery Reminder Line";

    layout
    {
        area(content)
        {
            repeater(Control1140000)
            {
                ShowCaption = false;
                field("Order No."; "Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the reminded purchase order.';
                }
                field(Type; Type)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the line type.';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the G/L account number or item number that identifies the G/L account or item specified on the line.';

                    trigger OnValidate()
                    begin
                        NoOnAfterValidate();
                    end;
                }
                field("Vendor Item No."; "Vendor Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the vendor who you want to post a delivery reminder for.';
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies either the name of or a description of the item or G/L account.';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies the quantity to remind.';
                }
                field("Unit of Measure"; "Unit of Measure")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the unit of measure used for the item, for example bottle or piece.';
                }
                field("Reorder Quantity"; "Reorder Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies the reorder quantity of the purchase order which will be reminded.';
                }
                field("Remaining Quantity"; "Remaining Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies the remaining quantity of the purchase order which will be reminded.';
                }
                field("Order Date"; "Order Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Order Date of the purchase order to remind.';
                }
                field("Del. Rem. Date Field"; "Del. Rem. Date Field")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date field of the purchase order line corresponding to the delivery reminder.';
                }
                field("Requested Receipt Date"; "Requested Receipt Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date that you want the vendor to deliver your order. The field is used to calculate the latest date you can order, as follows: requested receipt date - lead time calculation = order date. If you do not need delivery on a specific date, you can leave the field blank.';
                }
                field("Promised Receipt Date"; "Promised Receipt Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date that the vendor has promised to deliver the order.';
                }
                field("Expected Receipt Date"; "Expected Receipt Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the expected receipt date.';
                }
                field("Days overdue"; "Days overdue")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies the amount of days the delivery is overdue.';
                }
                field("Reminder Level"; "Reminder Level")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies the delivery reminder''s level.';
                }
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
                action(InsertExtTexts)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Insert &Ext. Texts';
                    Image = Text;
                    ToolTip = 'Insert the extended item description that is set up for the item that is being processed on the line.';

                    trigger OnAction()
                    begin
                        InsertExtendedText(true);
                    end;
                }
            }
        }
    }

    var
        TransferExtendedDelivRemText: Codeunit "Deliv.-Rem. Ext. Text Transfer";

    [Scope('OnPrem')]
    procedure InsertExtendedText(Unconditionally: Boolean)
    begin
        OnBeforeInsertExtendedText(Rec);
        if TransferExtendedDelivRemText.ReminderCheckIfAnyExtText(Rec, Unconditionally) then begin
            CurrPage.SaveRecord;
            TransferExtendedDelivRemText.DelivReminInsertExtendedText(Rec);
        end;
        if TransferExtendedDelivRemText.MakeUpdate then
            CurrPage.Update;
    end;

    local procedure NoOnAfterValidate()
    begin
        InsertExtendedText(false);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertExtendedText(var DeliveryReminderLine: Record "Delivery Reminder Line")
    begin
    end;
}

