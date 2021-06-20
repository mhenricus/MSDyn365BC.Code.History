page 31020 "Purchase Advance Letter"
{
    Caption = 'Purchase Advance Letter';
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Approve,Request Approval';
    RefreshOnActivate = true;
    SourceTable = "Purch. Advance Letter Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the number of the purchase advance letter.';
                    Visible = DocNoVisible;

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field("Pay-to Vendor No."; "Pay-to Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the vendor who is sending the invoice.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Pay-to Name"; "Pay-to Name")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the name of the vendor sending the invoice.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                group("Pay-to")
                {
                    Caption = 'Pay-to';
                    field("Pay-to Address"; "Pay-to Address")
                    {
                        ApplicationArea = Basic, Suite;
                        Importance = Additional;
                        ToolTip = 'Specifies the address of the payee that will appear on the check.';
                    }
                    field("Pay-to Address 2"; "Pay-to Address 2")
                    {
                        ApplicationArea = Basic, Suite;
                        Importance = Additional;
                        ToolTip = 'Specifies the extended address of the payee that will appear on the check.';
                    }
                    field("Pay-to Post Code"; "Pay-to Post Code")
                    {
                        ApplicationArea = Basic, Suite;
                        Importance = Additional;
                        ToolTip = 'Specifies the postal code of the address.';
                    }
                    field("Pay-to City"; "Pay-to City")
                    {
                        ApplicationArea = Basic, Suite;
                        Importance = Additional;
                        ToolTip = 'Specifies the post code and city of the payee that will appear on the check.';
                    }
                }
                field("Pay-to Contact"; "Pay-to Contact")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the contact sending the invoice.';
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies external document no of purchase advance letter.';
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of puchase advance.';
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which you created the document.';
                }
                field("VAT Date"; "VAT Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT date. This date must be shown on the VAT statement.';
                }
                field("Original Document VAT Date"; "Original Document VAT Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies original document vat date of purchase advance letter.';
                }
                field("Order No."; "Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the number of the purchase order that this advance was posted from.';
                }
                field("Purchaser Code"; "Purchaser Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the salesperson who is addigned to the vendor.';
                }
                field(Status; Status)
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the stage during advance process.';
                }
                field("Amount Including VAT"; "Amount Including VAT")
                {
                    ToolTip = 'Specifies whether the unit price on the line should be displayed including or excluding VAT.';
                    Visible = false;
                }
                field("Vendor Adv. Payment No."; "Vendor Adv. Payment No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of vendor advance payment.';
                }
                field("Post Advance VAT Option"; "Post Advance VAT Option")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the option for advance posting with or without VAT.';
                }
                field("Amounts Including VAT"; "Amounts Including VAT")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the unit price on the line should be displayed including or excluding VAT.';

                    trigger OnValidate()
                    begin
                        CurrPage.LetterLines.PAGE.SetShowMandatoryConditions(Rec);
                        CurrPage.Update(true);
                    end;
                }
            }
            part(LetterLines; "Purch. Advance Letter Subform")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Letter No." = FIELD("No.");
            }
            group("Foreign Trade")
            {
                Caption = 'Foreign Trade';
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the currency of amounts on the document.';

                    trigger OnAssistEdit()
                    var
                        ChangeExchangeRate: Page "Change Exchange Rate";
                        PostingDate: Date;
                    begin
                        Clear(ChangeExchangeRate);
                        PostingDate := "Posting Date";
                        if PostingDate = 0D then
                            PostingDate := WorkDate;
                        ChangeExchangeRate.SetParameter("Currency Code", "Currency Factor", PostingDate);
                        if ChangeExchangeRate.RunModal = ACTION::OK then begin
                            Validate("Currency Factor", ChangeExchangeRate.GetParameter);
                            CurrPage.Update;
                        end;
                        Clear(ChangeExchangeRate);
                    end;

                    trigger OnValidate()
                    begin
                        CurrencyCodeOnAfterValidate;
                    end;
                }
                field("Registration No."; "Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the registration number of vendor.';
                }
                field("VAT Registration No."; "VAT Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT registration number. The field will be used when you do business with partners from EU countries/regions.';
                }
                field("Language Code"; "Language Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the language to be used on printouts for this document.';
                }
                field("Perform. Country/Region Code"; "Perform. Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region code. It is mandatory field by creating documents with VAT registration number for other countries.';
                }
                field("VAT Country/Region Code"; "VAT Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT country/region code of vendor.';
                }
            }
            group(Payments)
            {
                Caption = 'Payments';
                field("Bank Account Code"; "Bank Account Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies companie''s bank account.';
                }
                field("Bank Account No."; "Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number used by the bank for the bank account.';
                }
                field("Transit No."; "Transit No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a bank identification number of your own choice.';
                }
                field("SWIFT Code"; "SWIFT Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the international bank identifier code (SWIFT) of the bank where you have the account.';
                }
                field(IBAN; IBAN)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank account''s international bank account number.';
                }
                field("Variable Symbol"; "Variable Symbol")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the detail information for advance payment.';
                }
                field("Specific Symbol"; "Specific Symbol")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the additional symbol of bank payments.';
                }
                field("Constant Symbol"; "Constant Symbol")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the additional symbol of bank payments.';
                }
                field("Payment Terms Code"; "Payment Terms Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a formula that calculates the payment due date, payment discount date and payment discount amount on the document.';
                }
                field("Payment Method Code"; "Payment Method Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how the vendor must advance pay.';
                }
                field("Advance Due Date"; "Advance Due Date")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies when the advance must be paid.';
                }
                field("On Hold"; "On Hold")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the posted document will be included in the payment suggestion.';
                }
                field("Amount on Payment Order (LCY)"; "Amount on Payment Order (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount on payment order.';
                }
                field("Due Date from Line"; "Due Date from Line")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies due date from line of purchase advance letter.';

                    trigger OnValidate()
                    begin
                        CurrPage.LetterLines.PAGE.SetAdvDueDateFieldEditable("Due Date from Line");
                    end;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1220065; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1220064; Notes)
            {
                ApplicationArea = Notes;
                Visible = true;
            }
            part(WorkflowStatus; "Workflow Status FactBox")
            {
                ApplicationArea = All;
                Editable = false;
                Enabled = false;
                ShowFilter = false;
                Visible = ShowWorkflowStatus;
            }
            part(Control1220073; "Approval FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Table ID" = CONST(31020),
                              "Document No." = FIELD("No.");
                Visible = false;
            }
            part(IncomingDocAttachFactBox; "Incoming Doc. Attach. FactBox")
            {
                ApplicationArea = Basic, Suite;
                ShowFilter = false;
                Visible = false;
            }
            part(Control1220094; "Vendor Details FactBox")
            {
                SubPageLink = "No." = FIELD("Pay-to Vendor No.");
                Visible = false;
            }
            part(Control1220093; "Vendor Statistics FactBox")
            {
                SubPageLink = "No." = FIELD("Pay-to Vendor No.");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Letter")
            {
                Caption = '&Letter';
                action(Statistics)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'F7';
                    ToolTip = 'View the statistics on the selected advance letter.';

                    trigger OnAction()
                    begin
                        PAGE.RunModal(PAGE::"Purch. Adv. Letter Statistics", Rec);
                    end;
                }
                action(Card)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Card';
                    Image = EditLines;
                    RunObject = Page "Vendor Card";
                    RunPageLink = "No." = FIELD("Pay-to Vendor No.");
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'Show the vendor''s card.';
                }
                action("Co&mments")
                {
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Purch. Comment Sheet";
                    RunPageLink = "No." = FIELD("No."),
                                  "Document Line No." = CONST(0),
                                  "Document Type" = CONST("Advance Letter");
                    ToolTip = 'Specifies advance comments.';
                }
                action(Dimensions)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ToolTip = 'Specifies advance dimensions.';

                    trigger OnAction()
                    begin
                        ShowDocDim;
                    end;
                }
                action("A&pprovals")
                {
                    ApplicationArea = Suite;
                    Caption = 'A&pprovals';
                    Image = Approvals;
                    ToolTip = 'View a list of the records that are waiting to be approved. For example, you can see who requested the record to be approved, when it was sent, and when it is due to be approved.';

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.OpenApprovalEntriesPage(RecordId);
                    end;
                }
                separator(Action1220046)
                {
                }
                action("Deduction Entries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Deduction Entries';
                    Image = CheckLedger;
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'Specifies the purchase documents where the advance was added.';

                    trigger OnAction()
                    var
                        PurchAdvanceLetterEntry: Record "Purch. Advance Letter Entry";
                    begin
                        PurchAdvanceLetterEntry.SetCurrentKey("Letter No.", "Letter Line No.", "Entry Type", "Posting Date");
                        PurchAdvanceLetterEntry.SetRange("Letter No.", "No.");
                        PurchAdvanceLetterEntry.SetRange("Entry Type", PurchAdvanceLetterEntry."Entry Type"::Deduction);
                        PAGE.Run(0, PurchAdvanceLetterEntry);
                    end;
                }
                action("VAT Entries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Entries';
                    Image = VATLedger;
                    ShortCutKey = 'Shift+Ctrl+F5';
                    ToolTip = 'Open the page with VAT entries of this advance letter.';

                    trigger OnAction()
                    var
                        PurchAdvanceLetterEntry: Record "Purch. Advance Letter Entry";
                    begin
                        PurchAdvanceLetterEntry.SetCurrentKey("Letter No.", "Letter Line No.", "Entry Type", "Posting Date");
                        PurchAdvanceLetterEntry.SetRange("Letter No.", "No.");
                        PurchAdvanceLetterEntry.SetFilter("Entry Type", '%1|%2|%3', PurchAdvanceLetterEntry."Entry Type"::VAT,
                          PurchAdvanceLetterEntry."Entry Type"::"VAT Deduction", PurchAdvanceLetterEntry."Entry Type"::"VAT Rate");
                        PAGE.Run(0, PurchAdvanceLetterEntry);
                    end;
                }
                action("Assignment Documents")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Assignment Documents';
                    Image = Documents;
                    ToolTip = 'Conection to the purchase document.';

                    trigger OnAction()
                    begin
                        ShowDocs;
                    end;
                }
                action("Assignment Documents - detail")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Assignment Documents - detail';
                    Image = ViewDetails;
                    RunObject = Page "Advance Letter Line Relations";
                    RunPageLink = Type = CONST(Purchase),
                                  "Letter No." = FIELD("No.");
                    RunPageView = SORTING(Type, "Letter No.", "Letter Line No.", "Document No.", "Document Line No.");
                    ToolTip = 'Conection to the purchase document.';
                }
                action("Li&nked Advance Payments")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Li&nked Advance Payments';
                    Image = Payment;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Show the advance payments by vendor';

                    trigger OnAction()
                    begin
                        ShowLinkedAdvances;
                    end;
                }
                action("Advance Invoices")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Advance Invoices';
                    Image = Invoice;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Posted Purchase Invoices";
                    RunPageLink = "Letter No." = FIELD("No.");
                    RunPageView = SORTING("Letter No.");
                    ToolTip = 'Show advance invoice if they were posted.';
                }
                action("Advance Credi&t Memos")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Advance Credi&t Memos';
                    Image = CreditMemo;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Posted Purchase Credit Memos";
                    RunPageLink = "Letter No." = FIELD("No.");
                    RunPageView = SORTING("Letter No.");
                    ToolTip = 'Show advance credit memos if they were posted.';
                }
            }
        }
        area(processing)
        {
            group(Approval)
            {
                Caption = 'Approval';
                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'Relations to the workflow.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.ApproveRecordApprovalRequest(RecordId);
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Reject;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ToolTip = 'Specifies enu reject of purchase advance letter.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.RejectRecordApprovalRequest(RecordId);
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = All;
                    Caption = 'Delegate';
                    Image = Delegate;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Specifies enu delegate of purchase advance letter.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.DelegateRecordApprovalRequest(RecordId);
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = All;
                    Caption = 'Comments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Specifies advance comments.';
                    Visible = OpenApprovalEntriesExistForCurrUser;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
            }
            group(Release)
            {
                Caption = 'Release';
                action(Action1220062)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Release';
                    Image = ReleaseDoc;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Ctrl+F9';
                    ToolTip = 'Release the purchase advance to indicate that it has been printed or exported. The status then changes to Released.';

                    trigger OnAction()
                    begin
                        PerformManualRelease;
                    end;
                }
                action(Reopen)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Reopen';
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Specifies enu reopen of purchase advance letter.';

                    trigger OnAction()
                    begin
                        PerformManualReopen;
                    end;
                }
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Transfer Amount without VAT Document")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Transfer Amount without VAT Document';
                    Image = Export;
                    ToolTip = 'Use if you don''t want post VAT advance invoice.';

                    trigger OnAction()
                    var
                        PurchPostAdvances: Codeunit "Purchase-Post Advances";
                    begin
                        PurchPostAdvances.TransAmountWithoutInv(Rec);
                    end;
                }
                action("Restore Amount To Invoicing")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Restore Amount To Invoicing';
                    Image = Import;
                    ToolTip = 'Set up the amount invoiced and amount to deduct.';

                    trigger OnAction()
                    var
                        PurchPostAdvances: Codeunit "Purchase-Post Advances";
                    begin
                        PurchPostAdvances.RestoreTransfAmountWithoutInv(Rec);
                    end;
                }
                group(IncomingDocument)
                {
                    Caption = 'Incoming Document';
                    Image = Documents;
                    action(IncomingDocCard)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'View Incoming Document';
                        Enabled = HasIncomingDocument;
                        Image = ViewOrder;
                        ToolTip = 'View any incoming document records and file attachments that exist for the entry or document.';

                        trigger OnAction()
                        var
                            IncomingDocument: Record "Incoming Document";
                        begin
                            IncomingDocument.ShowCardFromEntryNo("Incoming Document Entry No.");
                        end;
                    }
                    action(SelectIncomingDoc)
                    {
                        AccessByPermission = TableData "Incoming Document" = R;
                        ApplicationArea = Basic, Suite;
                        Caption = 'Select Incoming Document';
                        Image = SelectLineToApply;
                        ToolTip = 'Select an incoming document record and file attachment that you want to link to the entry or document.';

                        trigger OnAction()
                        var
                            IncomingDocument: Record "Incoming Document";
                        begin
                            Validate("Incoming Document Entry No.", IncomingDocument.SelectIncomingDocument("Incoming Document Entry No.", RecordId));
                        end;
                    }
                    action(IncomingDocAttachFile)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Create Incoming Document from File';
                        Ellipsis = true;
                        Enabled = NOT HasIncomingDocument;
                        Image = Attach;
                        ToolTip = 'Create an incoming document record by selecting a file to attach, and then link the incoming document record to the entry or document.';

                        trigger OnAction()
                        var
                            IncomingDocumentAttachment: Record "Incoming Document Attachment";
                        begin
                            IncomingDocumentAttachment.NewAttachmentFromPurchAdvLetterDocument(Rec);
                        end;
                    }
                    action(RemoveIncomingDoc)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Remove Incoming Document';
                        Enabled = HasIncomingDocument;
                        Image = RemoveLine;
                        ToolTip = 'It is reverse process to transfer amount without VAT document.';

                        trigger OnAction()
                        begin
                            "Incoming Document Entry No." := 0;
                        end;
                    }
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                action("Post Advance &Invoice")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post Advance &Invoice';
                    Ellipsis = true;
                    Image = PrepaymentPost;
                    ToolTip = 'Allow post advance invoice.';

                    trigger OnAction()
                    begin
                        PostInvoice(false);
                    end;
                }
                action("Post and Print Adv. Invoic&e")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post and Print Adv. Invoic&e';
                    Ellipsis = true;
                    Image = PrepaymentPostPrint;
                    ToolTip = 'Allow post and print advance invoice.';

                    trigger OnAction()
                    begin
                        PostInvoice(true);
                    end;
                }
                action(PreviewPostingInvoice)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Preview Posting Advance Invoice';
                    Image = ViewPostedOrder;
                    ToolTip = 'Review the result of the posting lines before the actual posting.';

                    trigger OnAction()
                    begin
                        ShowPreviewInvoice;
                    end;
                }
                action("Post Advance &Credit Memo")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post Advance &Credit Memo';
                    Ellipsis = true;
                    Image = PrepaymentPost;
                    ToolTip = 'Allow post advance credit memo.';

                    trigger OnAction()
                    begin
                        PostCrMemo(false);
                    end;
                }
                action("Post and Print Adv. Cr. Mem&o")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post and Print Adv. Cr. Mem&o';
                    Ellipsis = true;
                    Image = PrepaymentPostPrint;
                    ToolTip = 'Allow post and print advance credit memo.';

                    trigger OnAction()
                    begin
                        PostCrMemo(true);
                    end;
                }
                action(PreviewPostingCrMemo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Preview Posting Credit Memo';
                    Image = ViewPostedOrder;
                    ToolTip = 'Review the result of the posting lines before the actual posting.';

                    trigger OnAction()
                    begin
                        ShowPreviewCrMemo;
                    end;
                }
                separator(Action1220055)
                {
                }
                action("Post Refund and Close Adv. Letter")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post Refund and Close Adv. Letter';
                    Image = ReturnOrder;
                    ToolTip = 'Allow post the refund and close advance letter.';

                    trigger OnAction()
                    var
                        PurchPostAdvances: Codeunit "Purchase-Post Advances";
                    begin
                        PurchPostAdvances.RefundAndCloseLetterYesNo('', Rec, "Posting Date", "VAT Date", false);
                        CurrPage.Update(false);
                    end;
                }
                action(PreviewPostingPostAndRef)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Preview Posting Post Refund and Close Adv. Letter';
                    Image = ViewPostedOrder;
                    ToolTip = 'Review the result of the posting lines before the actual posting.';

                    trigger OnAction()
                    begin
                        ShowPreviewRefundAndCloseLetter;
                    end;
                }
            }
            group("&Print")
            {
                Caption = '&Print';
                action("Advance Letter")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Advance Letter';
                    Ellipsis = true;
                    Image = PrintReport;
                    Promoted = true;
                    PromotedCategory = "Report";
                    ToolTip = 'Allows the print of advance letter.';

                    trigger OnAction()
                    begin
                        PurchAdvanceLetterHeader := Rec;
                        CurrPage.SetSelectionFilter(PurchAdvanceLetterHeader);
                        PurchAdvanceLetterHeader.PrintRecords(true);
                    end;
                }
            }
            group("Request Approval")
            {
                Caption = 'Request Approval';
                Image = SendApprovalRequest;
                action(SendApprovalRequest)
                {
                    ApplicationArea = Suite;
                    Caption = 'Send A&pproval Request';
                    Enabled = NOT OpenApprovalEntriesExist;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category5;
                    ToolTip = 'Relations to the workflow.';

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if ApprovalsMgmt.CheckPurchaseAdvanceLetterApprovalsWorkflowEnabled(Rec) then
                            ApprovalsMgmt.OnSendPurchaseAdvanceLetterForApproval(Rec);
                    end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = Suite;
                    Caption = 'Cancel Approval Re&quest';
                    Enabled = OpenApprovalEntriesExist;
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category5;
                    ToolTip = 'Relations to the workflow.';

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        ApprovalsMgmt.OnCancelPurchaseAdvanceLetterApprovalRequest(Rec);
                    end;
                }
            }
        }
        area(reporting)
        {
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.IncomingDocAttachFactBox.PAGE.LoadDataFromRecord(Rec);
        CurrPage.LetterLines.PAGE.SetShowMandatoryConditions(Rec);
        ShowWorkflowStatus := CurrPage.WorkflowStatus.PAGE.SetFilterOnWorkflowRecord(RecordId);
    end;

    trigger OnAfterGetRecord()
    begin
        FilterGroup(2);
        if not (GetFilter("Template Code") <> '') then begin
            if "Template Code" <> '' then
                SetRange("Template Code", "Template Code");
        end;
        FilterGroup(0);

        SetControlVisibility;
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.SaveRecord;
        exit(ConfirmDeletion);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Responsibility Center" := UserSetupManagement.GetPurchasesFilter;
        FilterGroup(2);
        if GetFilter("Template Code") <> '' then
            "Template Code" := GetRangeMin("Template Code");
        FilterGroup(0);
    end;

    trigger OnOpenPage()
    begin
        if UserSetupManagement.GetSalesFilter <> '' then begin
            FilterGroup(2);
            SetRange("Responsibility Center", UserSetupManagement.GetPurchasesFilter);
            FilterGroup(0);
        end;
        SetDocNoVisible;
    end;

    var
        PurchAdvanceLetterHeader: Record "Purch. Advance Letter Header";
        UserSetupManagement: Codeunit "User Setup Management";
        DocNoVisible: Boolean;
        ShowWorkflowStatus: Boolean;
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        HasIncomingDocument: Boolean;

    [Scope('OnPrem')]
    procedure PostInvoice(ToPrint: Boolean)
    var
        AdvLetterPostPrint: Codeunit "Adv.Letter-Post+Print";
    begin
        if Status > Status::"Pending Invoice" then
            TestField(Status, Status::"Pending Invoice");
        AdvLetterPostPrint.PurchPostAdvInvoice(Rec, ToPrint);
    end;

    [Scope('OnPrem')]
    procedure PostCrMemo(ToPrint: Boolean)
    var
        AdvLetterPostPrint: Codeunit "Adv.Letter-Post+Print";
    begin
        if Status > Status::"Pending Final Invoice" then
            TestField(Status, Status::"Pending Final Invoice");
        AdvLetterPostPrint.PurchPostAdvCrMemo(Rec, ToPrint);
    end;

    local procedure CurrencyCodeOnAfterValidate()
    begin
        CurrPage.LetterLines.PAGE.UpdateForm(true);
    end;

    local procedure SetDocNoVisible()
    var
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
    begin
        DocNoVisible := DocumentNoVisibility.PurchaseAdvanceLetterNoIsVisible("Template Code", "No.");
    end;

    local procedure SetControlVisibility()
    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        HasIncomingDocument := "Incoming Document Entry No." <> 0;

        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(RecordId);
    end;

    local procedure ShowPreviewInvoice()
    var
        AdvLetterPostPrint: Codeunit "Adv.Letter-Post+Print";
    begin
        AdvLetterPostPrint.PreviewPurchInv(Rec);
    end;

    local procedure ShowPreviewCrMemo()
    var
        AdvLetterPostPrint: Codeunit "Adv.Letter-Post+Print";
    begin
        AdvLetterPostPrint.PreviewPurchCrMemo(Rec);
    end;

    local procedure ShowPreviewRefundAndCloseLetter()
    var
        AdvLetterPostPrint: Codeunit "Adv.Letter-Post+Print";
    begin
        AdvLetterPostPrint.PreviewPurchRefundAndCloseLetter(Rec, "Posting Date", "VAT Date");
    end;
}
