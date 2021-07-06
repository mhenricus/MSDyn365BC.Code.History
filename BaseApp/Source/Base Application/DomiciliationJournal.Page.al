page 2000022 "Domiciliation Journal"
{
    ApplicationArea = Basic, Suite;
    AutoSplitKey = true;
    Caption = 'Domiciliation Journals';
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Domiciliation Journal Line";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            field(CurrentJnlBatchName; CurrentJnlBatchName)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Batch Name';
                Lookup = true;
                ToolTip = 'Specifies the batch name of the domiciliation journal.';

                trigger OnLookup(var Text: Text): Boolean
                begin
                    if GetFilter("Journal Template Name") = '' then
                        SetRange("Journal Template Name", "Journal Template Name");
                    DoLookup := DomJnlManagement.LookupName(GetRangeMax("Journal Template Name"), CurrentJnlBatchName, Text);
                    CurrPage.Update;
                    exit(DoLookup);
                end;

                trigger OnValidate()
                begin
                    DomJnlManagement.CheckName(CurrentJnlBatchName, Rec);
                    CurrentJnlBatchNameOnAfterVali;
                end;
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which you want the payment to be posted.';
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the customer linked to the journal line.';

                    trigger OnValidate()
                    begin
                        DomJnlManagement.GetAccounts(Rec, CustName, BankAccName);
                        ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field("Applies-to Doc. Type"; "Applies-to Doc. Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of the posted document that this document or journal line will be applied to when you post, for example to register payment.';
                }
                field("Applies-to Doc. No."; "Applies-to Doc. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the posted document that this document or journal line will be applied to when you post, for example to register payment.';
                }
                field("Message 1"; "Message 1")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a message for the domiciliation.';
                }
                field("Message 2"; "Message 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a second message for the domiciliation.';
                    Visible = false;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the outstanding amount. The payment discounts are automatically subtracted from this amount.';
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency code of the domiciliation.';
                }
                field("Pmt. Disc. Possible"; "Pmt. Disc. Possible")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the payment discount that is subtracted from the remaining amount of the outstanding entry.';
                    Visible = false;
                }
                field("Pmt. Discount Date"; "Pmt. Discount Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date used to determine the payment discount.';
                    Visible = false;
                }
                field(Reference; Reference)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the standard format message for the domiciliation.';
                }
                field("Bank Account No."; "Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the bank account on which you want the domiciliations to be made.';

                    trigger OnValidate()
                    begin
                        ShowShortcutDimCode(ShortcutDimCode);
                        BankAccountNoOnAfterValidate();
                    end;
                }
                field("Direct Debit Mandate ID"; "Direct Debit Mandate ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the identification of the direct-debit mandate that is being used on the journal lines to process a direct debit collection.';
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("ShortcutDimCode[3]"; ShortcutDimCode[3])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]"; ShortcutDimCode[4])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]"; ShortcutDimCode[5])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]"; ShortcutDimCode[6])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(6),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]"; ShortcutDimCode[7])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(7),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]"; ShortcutDimCode[8])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                field(Status; Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that to see the available status, click the AssistButton.';
                }
            }
            group(Control60)
            {
                ShowCaption = false;
                fixed(Control1901775801)
                {
                    ShowCaption = false;
                    group("Bank Account Name")
                    {
                        Caption = 'Bank Account Name';
                        field(BankAccName; BankAccName)
                        {
                            ApplicationArea = Basic, Suite;
                            Editable = false;
                        }
                    }
                    group("Customer Name")
                    {
                        Caption = 'Customer Name';
                        field(CustName; CustName)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Customer Name';
                            Editable = false;
                            ToolTip = 'Specifies the name of the customer who has been entered on the domiciliation journal line.';
                        }
                    }
                    group("Total Customer")
                    {
                        Caption = 'Total Customer';
                        field(BalanceRem; Amt + Amount - xRec.Amount)
                        {
                            ApplicationArea = All;
                            AutoFormatType = 1;
                            Caption = 'Total Customer';
                            Editable = false;
                            ToolTip = 'Specifies the total amount of the domiciliations of the customer who has been entered on the domiciliation journal line.';
                            Visible = BalanceRemVisible;
                        }
                    }
                    group("Total Balance")
                    {
                        Caption = 'Total Balance';
                        field(TotalBalance; TotalAmount + Amount - xRec.Amount)
                        {
                            ApplicationArea = All;
                            AutoFormatType = 1;
                            Caption = 'Total Balance';
                            Editable = false;
                            ToolTip = 'Specifies the total balance in the domiciliation journal.';
                            Visible = TotalBalanceVisible;
                        }
                    }
                }
            }
        }
        area(factboxes)
        {
            part(Control1900919607; "Dimension Set Entries FactBox")
            {
                ApplicationArea = Dimensions;
                SubPageLink = "Dimension Set ID" = FIELD("Dimension Set ID");
                Visible = false;
            }
            part("Domiciliation File Errors"; "Payment Journal Errors Part")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Domiciliation File Errors';
                SubPageLink = "Journal Template Name" = FIELD("Journal Template Name"),
                              "Journal Batch Name" = FIELD("Journal Batch Name"),
                              "Journal Line No." = FIELD("Line No.");
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                action(Dimensions)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        ShowDimensions();
                        CurrPage.SaveRecord;
                    end;
                }
            }
            group("A&ccount")
            {
                Caption = 'A&ccount';
                action(Card)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Card';
                    Image = EditLines;
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'View or change detailed information about the record on the document or journal line.';

                    trigger OnAction()
                    begin
                        DomJnlManagement.ShowCard(Rec);
                    end;
                }
                action(LedgerEntries)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ledger E&ntries';
                    Image = GLRegisters;
                    Promoted = false;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View the history of transactions that have been posted for the selected record.';

                    trigger OnAction()
                    begin
                        DomJnlManagement.ShowEntries(Rec);
                    end;
                }
            }
            group("D&omicil.")
            {
                Caption = 'D&omicil.';
                action(SuggestDomiciliations)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Suggest Domiciliations';
                    Ellipsis = true;
                    Image = Suggest;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Let the program create the journal lines based on a number of criteria. ';

                    trigger OnAction()
                    begin
                        SuggestDomiciliations.SetJournal(Rec);
                        SuggestDomiciliations.RunModal;
                        Clear(SuggestDomiciliations);
                    end;
                }
                action(FileDomiciliations)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'File Domiciliations';
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Generate a report that contains the domiciliations to be made by the bank that you have selected. Only euro domiciliations will be included in the report. You must create a separate file for each currency. In addition, this report generates an accompanying document that you can submit with a disk. You can also send the generated file to the bank by data modem or by using the Isabel third-party software program. For this purpose neither the file nor the Isabel program must be modified.';

                    trigger OnAction()
                    begin
                        ExportToFile;
                        CurrPage.Update(false);
                    end;
                }
            }
        }
        area(processing)
        {
            group(Print)
            {
                Caption = 'Print';
                action(TestReport)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;
                    ToolTip = 'View a test report so that you can find and correct any errors before you perform the actual posting of the journal or document.';

                    trigger OnAction()
                    begin
                        DomJnlBatch.Get("Journal Template Name", "Journal Batch Name");
                        DomJnlManagement.PrintTestReport(DomJnlBatch);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        DomJnlManagement.GetAccounts(Rec, CustName, BankAccName);
        UpdateAmount;
    end;

    trigger OnAfterGetRecord()
    begin
        ShowShortcutDimCode(ShortcutDimCode);
    end;

    trigger OnInit()
    begin
        TotalBalanceVisible := true;
        BalanceRemVisible := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        DomJnlManagement.SetUpNewLine(Rec, xRec);
        Clear(ShortcutDimCode);
        Clear(CustName);
    end;

    trigger OnOpenPage()
    var
        JnlSelected: Boolean;
        OpenedFromBatch: Boolean;
    begin
        OpenedFromBatch := ("Journal Batch Name" <> '') and ("Journal Template Name" = '');
        if OpenedFromBatch then begin
            CurrentJnlBatchName := "Journal Batch Name";
            DomJnlManagement.OpenJournal(CurrentJnlBatchName, Rec);
            exit;
        end;
        DomJnlManagement.TemplateSelection(Rec, JnlSelected);
        if not JnlSelected then
            Error('');
        DomJnlManagement.OpenJournal(CurrentJnlBatchName, Rec);
    end;

    var
        DomJnlBatch: Record "Domiciliation Journal Batch";
        DomJnlLine: Record "Domiciliation Journal Line";
        SuggestDomiciliations: Report "Suggest domicilations";
        DomJnlManagement: Codeunit DomiciliationJnlManagement;
        CurrentJnlBatchName: Code[10];
        CustName: Text[100];
        BankAccName: Text[100];
        Amt: Decimal;
        TotalAmount: Decimal;
        ShowAmount: Boolean;
        ShowTotalAmount: Boolean;
        DoLookup: Boolean;
        BankAccount: Code[20];
        ShortcutDimCode: array[8] of Code[20];
        [InDataSet]
        BalanceRemVisible: Boolean;
        [InDataSet]
        TotalBalanceVisible: Boolean;

    local procedure UpdateAmount()
    begin
        DomJnlManagement.CalculateTotals(Rec, xRec, Amt, TotalAmount, ShowAmount, ShowTotalAmount);
        BalanceRemVisible := ShowAmount;
        TotalBalanceVisible := ShowTotalAmount;
    end;

    local procedure BankAccountNoOnAfterValidate()
    begin
        if not (Status = Status::Posted) then begin
            BankAccount := xRec."Bank Account No.";
            CurrPage.SaveRecord;
            DomJnlManagement.AssignBankAccount(Rec, BankAccount);
            CurrPage.Update(false);
        end;
    end;

    local procedure CurrentJnlBatchNameOnAfterVali()
    begin
        CurrPage.SaveRecord;
        DomJnlManagement.SetName(CurrentJnlBatchName, Rec);
        CurrPage.Update(false);
    end;
}
