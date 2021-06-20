report 11567 "SR G/L Acc Sheet VAT Info"
{
    DefaultLayout = RDLC;
    RDLCLayout = './SRGLAccSheetVATInfo.rdlc';
    ApplicationArea = Basic, Suite;
    Caption = 'G/L Account Sheet with VAT Info';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = WHERE("Account Type" = CONST(Posting));
            RequestFilterFields = "No.", "Income/Balance", "Date Filter", "Global Dimension 1 Filter", "Global Dimension 2 Filter";
            column(CompanyName; COMPANYPROPERTY.DisplayName)
            {
            }
            column(PeriodGlJourDateFilter; Text001 + GlJourDateFilter)
            {
            }
            column(TodayFormatted; Format(Today, 0, 4))
            {
            }
            column(LayoutVATInfo; Text002)
            {
            }
            column(NewPagePerAccNo; NewPagePerAccNo)
            {
            }
            column(GLAccountName; "G/L Account".Name)
            {
            }
            column(GLAccountCurrencyCode; "G/L Account"."Currency Code")
            {
            }
            column(GLAccountNo; "G/L Account"."No.")
            {
            }
            column(StartBalanceTxt; StartBalanceTxt)
            {
            }
            column(FcyAcyBalance; FcyAcyBalance)
            {
                AutoFormatExpression = "G/L Account"."Currency Code";
                AutoFormatType = 1;
            }
            column(GlBalance; GlBalance)
            {
                AutoFormatType = 1;
            }
            column(PageCaption; PageCaptionLbl)
            {
            }
            column(GLAccountSheetCaption; GLAccountSheetCaptionLbl)
            {
            }
            column(PostDateCaption; PostDateCaptionLbl)
            {
            }
            column(DocNoCaption; DocNoCaptionLbl)
            {
            }
            column(TextCaption; TextCaptionLbl)
            {
            }
            column(BalAccCaption; BalAccCaptionLbl)
            {
            }
            column(BalanceCaption; BalanceCaptionLbl)
            {
            }
            column(CreditCaption; CreditCaptionLbl)
            {
            }
            column(DebitCaption; DebitCaptionLbl)
            {
            }
            column(VATBusPostingGroupCaption; VATBusPostingGroupCaptionLbl)
            {
            }
            column(VATProdPostingGroupCaption; VATProdPostingGroupCaptionLbl)
            {
            }
            column(VATCaption; VATCaptionLbl)
            {
            }
            column(VATAmountCaption; VATAmountCaptionLbl)
            {
            }
            column(GlobalDimension1Filter_GLAccount; "Global Dimension 1 Filter")
            {
            }
            column(BusinessUnitFilter_GLAccount; "Business Unit Filter")
            {
            }
            dataitem("G/L Entry"; "G/L Entry")
            {
                DataItemLink = "G/L Account No." = FIELD("No."), "Posting Date" = FIELD("Date Filter"), "Global Dimension 1 Code" = FIELD("Global Dimension 1 Filter"), "Global Dimension 2 Code" = FIELD("Global Dimension 2 Filter"), "Business Unit Code" = FIELD("Business Unit Filter");
                DataItemTableView = SORTING("G/L Account No.", "Posting Date");
                column(DebitAmount_GLEntry; "Debit Amount")
                {
                }
                column(CreditAmount_GLEntry; "Credit Amount")
                {
                }
                column(GLAccountCurrencyCode_GLEntry; "G/L Account"."Currency Code")
                {
                }
                column(GlBalanceExclAmount; GlBalance - Amount)
                {
                    AutoFormatType = 1;
                }
                column(FcyAcyBalanceExclFcyAcyAmt; FcyAcyBalance - FcyAcyAmt)
                {
                    AutoFormatExpression = "G/L Account"."Currency Code";
                    AutoFormatType = 1;
                }
                column(PostingDateFormatted; Format("Posting Date"))
                {
                }
                column(DocumentNo_GLEntry; "Document No.")
                {
                }
                column(Description_GLEntry; Description)
                {
                }
                column(BalAccType; BalAccType)
                {
                }
                column(BalAccountNo_GLEntry; "Bal. Account No.")
                {
                }
                column(GlBalance_GLEntry; GlBalance)
                {
                    AutoFormatType = 1;
                }
                column(VATBusPostingGroup_GLEntry; "VAT Bus. Posting Group")
                {
                }
                column(VATProdPostingGroup_GLEntry; "VAT Prod. Posting Group")
                {
                }
                column(VATAmount_GLEntry; "VAT Amount")
                {
                }
                column(VATPercent; VATPercent)
                {
                }
                column(TransferCaption; TransferCaptionLbl)
                {
                }
                column(GLAccountNo_GLEntry; "G/L Account No.")
                {
                }
                column(GlobalDimension1Code_GLEntry; "Global Dimension 1 Code")
                {
                }
                column(BusinessUnitCode_GLEntry; "Business Unit Code")
                {
                }

                trigger OnAfterGetRecord()
                var
                    VATEntryLink: Record "G/L Entry - VAT Entry Link";
                begin
                    if ("Posting Date" = ClosingDate("Posting Date")) and WithoutClosingEntries then
                        CurrReport.Skip();

                    GlBalance := GlBalance + Amount;
                    Entryno := Entryno + 1;

                    if "Bal. Account No." <> '' then
                        BalAccType := CopyStr(Format("Bal. Account Type"), 1, 1)
                    else
                        BalAccType := '';

                    if ("VAT Amount" <> 0) and (Amount <> 0) then begin
                        VATEntryLink.SetRange("G/L Entry No.", "Entry No.");
                        if VATEntryLink.FindFirst then
                            if VATEntry.Get(VATEntryLink."VAT Entry No.") then
                                VATPercent := VATEntry."VAT %";

                        if VATPercent = 0 then
                            VATPercent := Round("VAT Amount" * 100 / Amount);
                    end else
                        VATPercent := 0;
                end;

                trigger OnPreDataItem()
                begin
                    Entryno := 0;
                end;
            }
            dataitem(GlAccTotal; "Integer")
            {
                DataItemTableView = SORTING(Number);
                MaxIteration = 1;
                column(GlBalance_GlAccTotal; GlBalance)
                {
                    AutoFormatType = 1;
                }
                column(GLEntryDebitAmount; "G/L Entry"."Debit Amount")
                {
                }
                column(FcyAcyBalance_GlAccTotal; FcyAcyBalance)
                {
                    AutoFormatExpression = "G/L Account"."Currency Code";
                    AutoFormatType = 1;
                }
                column(Exrate; Exrate)
                {
                    DecimalPlaces = 2 : 3;
                }
                column(EndBalanceCaption; EndBalanceCaptionLbl)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Exrate := CalcExrate(FcyAcyBalance, GlBalance, "G/L Account"."Currency Code");
                end;
            }
            dataitem("Gen. Journal Line"; "Gen. Journal Line")
            {
                DataItemTableView = SORTING("Journal Template Name", "Journal Batch Name", "Line No.");
                column(PostingDateFormatted_GenJournalLine; Format("Posting Date"))
                {
                }
                column(DocumentNo_GenJournalLine; "Document No.")
                {
                }
                column(Description_GenJournalLine; Description)
                {
                }
                column(BalAccType_GenJournalLine; BalAccType)
                {
                }
                column(BalAccountNo_GenJournalLine; "Bal. Account No.")
                {
                }
                column(ProvDebit; ProvDebit)
                {
                }
                column(ProvCredit; ProvCredit)
                {
                }
                column(GlBalance_GenJournalLine; GlBalance)
                {
                    AutoFormatType = 1;
                }
                column(VATBusPostingGroup_GenJournalLine; "VAT Bus. Posting Group")
                {
                }
                column(VATProdPostingGroup_GenJournalLine; "VAT Prod. Posting Group")
                {
                }
                column(VAT_GenJournalLine; "VAT %")
                {
                }
                column(VATAmount_GenJournalLine; "VAT Amount")
                {
                }
                column(SumofGLEntryCreditAmountProvCredit; "G/L Entry"."Credit Amount" + ProvCredit)
                {
                }
                column(SumofGLEntryDebitAmountProvDebit; "G/L Entry"."Debit Amount" + ProvDebit)
                {
                }
                column(FcyAcyBalance_GenJournalLine; FcyAcyBalance)
                {
                    AutoFormatExpression = "Currency Code";
                    AutoFormatType = 1;
                }
                column(TemporaryPostingsCaption; TemporaryPostingsCaptionLbl)
                {
                }
                column(ProvisionalEndBalanceCaption; ProvisionalEndBalanceCaptionLbl)
                {
                }
                column(JournalBatchName_GenJournalLine; "Journal Batch Name")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    ProvEntry := false;
                    ProvDebit := 0;
                    ProvCredit := 0;

                    if ("Account Type" = "Account Type"::"G/L Account") and ("Account No." = "G/L Account"."No.") then begin
                        ProvEntry := true;
                        GlBalance := GlBalance + "Amount (LCY)" - "VAT Amount (LCY)";

                        if "Amount (LCY)" < 0 then
                            ProvCredit := -("Amount (LCY)" - "VAT Amount (LCY)")
                        else
                            ProvDebit := "Amount (LCY)" - "VAT Amount (LCY)";
                    end;

                    if ("Bal. Account Type" = "Bal. Account Type"::"G/L Account") and ("Bal. Account No." = "G/L Account"."No.") then begin
                        ProvEntry := true;

                        GlBalance := GlBalance - "Amount (LCY)" - "Bal. VAT Amount (LCY)";

                        if "Amount (LCY)" < 0 then
                            ProvDebit := -("Amount (LCY)" + "Bal. VAT Amount (LCY)")
                        else
                            ProvCredit := "Amount (LCY)" + "Bal. VAT Amount (LCY)";

                        "Bal. Account No." := "Account No.";

                        Amount := -Amount;
                        "Amount (LCY)" := -"Amount (LCY)";
                    end;

                    if Correction then begin
                        TempProvDebit := ProvDebit;
                        ProvDebit := -ProvCredit;
                        ProvCredit := -TempProvDebit;
                    end;

                    if not ProvEntry then
                        CurrReport.Skip();

                    Entryno := Entryno + 1;

                    if ("Posting Date" = ClosingDate("Posting Date")) and WithoutClosingEntries then
                        CurrReport.Skip();

                    if "Bal. Account No." <> '' then
                        BalAccType := CopyStr(Format("Bal. Account Type"), 1, 1)
                    else
                        BalAccType := '';
                end;

                trigger OnPreDataItem()
                begin
                    if not ProvEntryExist then
                        CurrReport.Break();

                    // Filter set in function SetGenJourLineFilter()
                    CopyFilters(GenJourLine2);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if NewPagePerAcc then
                    NewPagePerAccNo := NewPagePerAccNo + 1;
                GlBalance := 0;
                FcyAcyBalance := 0;

                if StartDate > 0D then begin
                    SetRange("Date Filter", 0D, ClosingDate(StartDate - 1));
                    CalcFields("Net Change", "Movement (FCY)", "Additional-Currency Net Change");

                    GlBalance := "Net Change";

                    SetFilter("Date Filter", GlJourDateFilter);
                end;

                GlEntry2.SetCurrentKey("G/L Account No.", "Posting Date");
                GlEntry2.SetRange("G/L Account No.", "No.");
                CopyFilter("Global Dimension 1 Filter", GlEntry2."Global Dimension 1 Code");
                CopyFilter("Global Dimension 2 Filter", GlEntry2."Global Dimension 2 Code");

                if GlJourDateFilter <> '' then
                    GlEntry2.SetFilter("Posting Date", GlJourDateFilter);
                CalcFields("Balance at Date");
                CalcFields("Balance at Date (FCY)");

                CheckProvEntry;

                if ("Balance at Date" = 0) and
                   ("Balance at Date (FCY)" = 0) and
                   (not GlEntry2.FindFirst) and
                   (not ProvEntryExist) and
                   (not ShowAllAccounts)
                then
                    CurrReport.Skip();

                if not(NotFirstPage and NewPagePerAcc) then
                    NotFirstPage := true;
            end;

            trigger OnPreDataItem()
            begin
                NewPagePerAccNo := 1;
                if GlJourDateFilter <> '' then
                    if GetRangeMin("Date Filter") <> 0D then begin
                        StartDate := GetRangeMin("Date Filter");
                        StartBalanceTxt := Text000 + Format(StartDate);
                    end;

                SetGenJourLineFilter;
                Clear(GlBalance);
                Clear(FcyAcyBalance);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(NewPagePerAcc; NewPagePerAcc)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'New Page per Account';
                        ToolTip = 'Specifies if you want to print a new page for each account.';
                    }
                    field(ShowAllAccounts; ShowAllAccounts)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Accounts w/o Balance or Net Change';
                        ToolTip = 'Specifies if you want to print the accounts without a balance on the report.';
                    }
                    field(WithoutClosingEntries; WithoutClosingEntries)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Without Closing Entries';
                        MultiLine = true;
                        ToolTip = 'Specifies if you want to print the report without closing entries.';
                    }
                    field(JourName1; JourName1)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'With Journal 1';
                        Lookup = true;
                        ToolTip = 'Specifies the first general journal batch that you want to include in the report.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            if PAGE.RunModal(PAGE::"General Journal Batches", GlJourName) = ACTION::LookupOK then
                                JourName1 := GlJourName.Name;
                        end;
                    }
                    field(JourName2; JourName2)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'With Journal 2';
                        Lookup = true;
                        ToolTip = 'Specifies the second general journal batch that you want to include in the report.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            if PAGE.RunModal(PAGE::"General Journal Batches", GlJourName) = ACTION::LookupOK then
                                JourName2 := GlJourName.Name;
                        end;
                    }
                    field(JourName3; JourName3)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'With Journal 3';
                        Lookup = true;
                        ToolTip = 'Specifies the third general journal batch that you want to include in the report.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            if PAGE.RunModal(PAGE::"General Journal Batches", GlJourName) = ACTION::LookupOK then
                                JourName3 := GlJourName.Name;
                        end;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            GenJourTemplate.SetRange(Type, GenJourTemplate.Type::General);
            GenJourTemplate.SetRange(Recurring, false);
            if GenJourTemplate.FindFirst then;
            GlJourName.FilterGroup(2);
            GlJourName.SetRange("Journal Template Name", GenJourTemplate.Name);
            GlJourName.FilterGroup(0);
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        GlJourDateFilter := "G/L Account".GetFilter("Date Filter");

        GLSetup.Get();
    end;

    var
        GlAcc2: Record "G/L Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        Bank: Record "Bank Account";
        FixedAsset: Record "Fixed Asset";
        GlEntry2: Record "G/L Entry";
        GenJourTemplate: Record "Gen. Journal Template";
        GLSetup: Record "General Ledger Setup";
        VATEntry: Record "VAT Entry";
        GenJourLine2: Record "Gen. Journal Line";
        GlJourName: Record "Gen. Journal Batch";
        Text000: Label 'Start Balance on ';
        Text001: Label 'Period: ';
        Text002: Label 'Layout VAT Info';
        GlJourDateFilter: Text[30];
        NotFirstPage: Boolean;
        StartBalanceTxt: Text[80];
        StartDate: Date;
        NewPagePerAcc: Boolean;
        WithoutClosingEntries: Boolean;
        BalAccType: Text[1];
        Entryno: Integer;
        GlBalance: Decimal;
        FcyAcyAmt: Decimal;
        FcyAcyBalance: Decimal;
        Exrate: Decimal;
        ProvDebit: Decimal;
        ProvCredit: Decimal;
        TempProvDebit: Decimal;
        JourName1: Code[10];
        JourName2: Code[10];
        JourName3: Code[10];
        VATPercent: Decimal;
        ProvEntry: Boolean;
        ProvEntryExist: Boolean;
        ShowAllAccounts: Boolean;
        NewPagePerAccNo: Integer;
        PageCaptionLbl: Label 'Page';
        GLAccountSheetCaptionLbl: Label 'G/L Account Sheet';
        PostDateCaptionLbl: Label 'Post Date';
        DocNoCaptionLbl: Label 'Doc. No.';
        TextCaptionLbl: Label 'Text';
        BalAccCaptionLbl: Label 'Bal. Acc.';
        BalanceCaptionLbl: Label 'Balance';
        CreditCaptionLbl: Label 'Credit';
        DebitCaptionLbl: Label 'Debit';
        VATBusPostingGroupCaptionLbl: Label 'VAT Bus. Posting Group';
        VATProdPostingGroupCaptionLbl: Label 'VAT Prod. Posting Group';
        VATCaptionLbl: Label 'VAT %';
        VATAmountCaptionLbl: Label 'VAT Amount';
        TransferCaptionLbl: Label 'Transfer';
        EndBalanceCaptionLbl: Label 'End Balance';
        TemporaryPostingsCaptionLbl: Label 'Temporary Postings';
        ProvisionalEndBalanceCaptionLbl: Label 'Provisional End Balance';

    [Scope('OnPrem')]
    procedure CalcExrate(_FcyAmt: Decimal; _LcyAmt: Decimal; _Curr: Code[10]): Decimal
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        if _FcyAmt <> 0 then begin
            CurrExchRate.SetRange("Currency Code", _Curr);
            if CurrExchRate.FindLast then
                exit(Round(_LcyAmt * CurrExchRate."Exchange Rate Amount" / _FcyAmt, 0.001))
        end;
        exit(0);
    end;

    [Scope('OnPrem')]
    procedure SetGenJourLineFilter()
    begin
        GenJourLine2.SetCurrentKey(
          "Journal Template Name", "Journal Batch Name", "Posting Date", Clearing, "Debit Bank", "Account No.", "Currency Code");
        GenJourLine2.SetRange("Journal Template Name", GenJourTemplate.Name);
        GenJourLine2.SetFilter("Journal Batch Name", '%1|%2|%3', JourName1, JourName2, JourName3);

        if "G/L Account".GetFilter("Date Filter") <> '' then
            if "G/L Account".GetRangeMax("Date Filter") <> 0D then
                GenJourLine2.SetRange("Posting Date", 0D, "G/L Account".GetRangeMax("Date Filter"));

        "G/L Account".CopyFilter("Global Dimension 1 Filter", GenJourLine2."Shortcut Dimension 1 Code");
        "G/L Account".CopyFilter("Global Dimension 2 Filter", GenJourLine2."Shortcut Dimension 2 Code");
    end;

    [Scope('OnPrem')]
    procedure CheckProvEntry()
    begin
        ProvEntryExist := false;
        GenJourLine2.SetRange("Account No.", "G/L Account"."No.");
        GenJourLine2.SetRange("Account Type", "G/L Account"."Account Type");
        if GenJourLine2.FindFirst then
            ProvEntryExist := true;
        GenJourLine2.SetRange("Account No.");
        GenJourLine2.SetRange("Account Type");
        if ProvEntryExist then
            exit;

        GenJourLine2.SetRange("Bal. Account No.", "G/L Account"."No.");
        GenJourLine2.SetRange("Bal. Account Type", "G/L Account"."Account Type");
        if GenJourLine2.FindFirst then
            ProvEntryExist := true;

        GenJourLine2.SetRange("Bal. Account No.");
        GenJourLine2.SetRange("Bal. Account Type");
    end;
}

