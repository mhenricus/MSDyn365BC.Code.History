page 9100 "Purchase Line FactBox"
{
    Caption = 'Purchase Line Details';
    PageType = CardPart;
    SourceTable = "Purchase Line";

    layout
    {
        area(content)
        {
            field("No."; "No.")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Item No.';
                Lookup = false;
                ToolTip = 'Specifies the number of a general ledger account, item, resource, additional cost, or fixed asset, depending on the contents of the Type field.';

                trigger OnDrillDown()
                begin
                    ShowDetails();
                end;
            }
            field(Availability; PurchInfoPaneMgt.CalcAvailability(Rec))
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Availability';
                DecimalPlaces = 0 : 5;
                DrillDown = true;
                Editable = true;
                ToolTip = 'Specifies how many units of the item on the purchase line are available.';

                trigger OnDrillDown()
                begin
                    ItemAvailFormsMgt.ShowItemAvailFromPurchLine(Rec, ItemAvailFormsMgt.ByEvent());
                    CurrPage.Update(true);
                end;
            }
            field(PurchasePrices; StrSubstNo('%1', PurchInfoPaneMgt.CalcNoOfPurchasePrices(Rec)))
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Purchase Prices';
                DrillDown = true;
                Editable = true;
                ToolTip = 'Specifies how many special prices your vendor grants you for the purchase line. Choose the value to see the special purchase prices.';

                trigger OnDrillDown()
                begin
                    PickPrice();
                    CurrPage.Update();
                end;
            }
            field(PurchaseLineDiscounts; StrSubstNo('%1', PurchInfoPaneMgt.CalcNoOfPurchLineDisc(Rec)))
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Purchase Line Discounts';
                DrillDown = true;
                Editable = true;
                ToolTip = 'Specifies how many special discounts your vendor grants you for the purchase line. Choose the value to see the purchase line discounts.';

                trigger OnDrillDown()
                begin
                    PickDiscount();
                    CurrPage.Update();
                end;
            }
            group(Attachments)
            {
                Caption = 'Attachments';
                field("Attached Doc Count"; "Attached Doc Count")
                {
                    ApplicationArea = All;
                    Caption = 'Documents';
                    ToolTip = 'Specifies the number of attachments.';

                    trigger OnDrillDown()
                    var
                        DocumentAttachmentDetails: Page "Document Attachment Details";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        DocumentAttachmentDetails.OpenForRecRef(RecRef);
                        DocumentAttachmentDetails.RunModal;
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        Rec.ClearPurchaseHeader();
    end;

    protected var
        PurchInfoPaneMgt: Codeunit "Purchases Info-Pane Management";
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";

    local procedure ShowDetails()
    var
        Item: Record Item;
    begin
        if Rec.Type = Rec.Type::Item then begin
            Item.Get(Rec."No.");
            PAGE.Run(PAGE::"Item Card", Item);
        end;
    end;
}

