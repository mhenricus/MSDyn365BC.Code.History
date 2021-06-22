codeunit 229 "Document-Print"
{

    trigger OnRun()
    begin
    end;

    var
        Text001: Label '%1 is missing for %2 %3.';
        Text002: Label '%1 for %2 is missing in %3.';
        SalesSetup: Record "Sales & Receivables Setup";
        PurchSetup: Record "Purchases & Payables Setup";

    procedure EmailSalesHeader(SalesHeader: Record "Sales Header")
    begin
        DoPrintSalesHeader(SalesHeader, true);
    end;

    procedure PrintSalesHeader(SalesHeader: Record "Sales Header")
    begin
        DoPrintSalesHeader(SalesHeader, false);
    end;

    procedure PrintSalesHeaderToDocumentAttachment(var SalesHeader: Record "Sales Header");
    var
        ShowNotificationAction: Boolean;
    begin
        ShowNotificationAction := SalesHeader.Count() = 1;
        if SalesHeader.FindSet() then
            repeat
                DoPrintSalesHeaderToDocumentAttachment(SalesHeader, ShowNotificationAction);
            until SalesHeader.Next() = 0;
    end;

    local procedure DoPrintSalesHeaderToDocumentAttachment(SalesHeader: Record "Sales Header"; ShowNotificationAction: Boolean);
    var
        ReportSelections: Record "Report Selections";
        ReportUsage: Enum "Report Selection Usage";
    begin
        ReportUsage := GetSalesDocTypeUsage(SalesHeader);

        SalesHeader.SetRecFilter();
        CalcSalesDisc(SalesHeader);
        ReportSelections.SaveAsDocumentAttachment(ReportUsage.AsInteger(), SalesHeader, SalesHeader."No.", SalesHeader.GetBillToNo(), ShowNotificationAction);
    end;

    procedure PrintSalesInvoiceToDocumentAttachment(var SalesHeader: Record "Sales Header"; SalesInvoicePrintToAttachmentOption: Integer)
    begin
        case "Sales Invoice Print Option".FromInteger(SalesInvoicePrintToAttachmentOption) of
            "Sales Invoice Print Option"::"Draft Invoice":
                PrintSalesHeaderToDocumentAttachment(SalesHeader);
            "Sales Invoice Print Option"::"Pro Forma Invoice":
                PrintProformaSalesInvoiceToDocumentAttachment(SalesHeader);
        end;
        OnAfterPrintSalesInvoiceToDocumentAttachment(SalesHeader, SalesInvoicePrintToAttachmentOption);
    end;

    procedure GetSalesInvoicePrintToAttachmentOption(SalesHeader: Record "Sales Header"): Integer
    var
        StrMenuText: Text;
        PrintOptionCaption: Text;
        i: Integer;
    begin
        foreach i in "Sales Invoice Print Option".Ordinals() do begin
            PrintOptionCaption := Format("Sales Invoice Print Option".FromInteger(i));
            if StrMenuText = '' then
                StrMenuText := PrintOptionCaption
            else
                StrMenuText := StrMenuText + ',' + PrintOptionCaption;
        end;
        exit(StrMenu(StrMenuText));
    end;

    procedure PrintSalesOrderToDocumentAttachment(var SalesHeader: Record "Sales Header"; SalesOrderPrintToAttachmentOption: Integer)
    var
        Usage: Option "Order Confirmation","Work Order","Pick Instruction";
    begin
        case "Sales Order Print Option".FromInteger(SalesOrderPrintToAttachmentOption) of
            "Sales Order Print Option"::"Order Confirmation":
                PrintSalesOrderToAttachment(SalesHeader, Usage::"Order Confirmation");
            "Sales Order Print Option"::"Pro Forma Invoice":
                PrintProformaSalesInvoiceToDocumentAttachment(SalesHeader);
            "Sales Order Print Option"::"Work Order":
                PrintSalesOrderToAttachment(SalesHeader, Usage::"Work Order");
            "Sales Order Print Option"::"Pick Instruction":
                PrintSalesOrderToAttachment(SalesHeader, Usage::"Pick Instruction");
        end;
        OnAfterPrintSalesOrderToDocumentAttachment(SalesHeader, SalesOrderPrintToAttachmentOption);
    end;

    procedure GetSalesOrderPrintToAttachmentOption(SalesHeader: Record "Sales Header"): Integer
    var
        StrMenuText: Text;
        PrintOptionCaption: Text;
        i: Integer;
    begin
        foreach i in "Sales Order Print Option".Ordinals() do begin
            PrintOptionCaption := Format("Sales Order Print Option".FromInteger(i));
            if StrMenuText = '' then
                StrMenuText := PrintOptionCaption
            else
                StrMenuText := StrMenuText + ',' + PrintOptionCaption;
        end;
        exit(StrMenu(StrMenuText));
    end;

    procedure PrintProformaSalesInvoiceToDocumentAttachment(var SalesHeader: Record "Sales Header")
    begin
        if SalesHeader.FindSet() then
            repeat
                DoPrintProformaSalesInvoiceToDocumentAttachment(SalesHeader, SalesHeader.Count() = 1)
            until SalesHeader.Next() = 0;
    end;

    local procedure DoPrintProformaSalesInvoiceToDocumentAttachment(SalesHeader: Record "Sales Header"; ShowNotificationAction: Boolean)
    var
        ReportSelections: Record "Report Selections";
    begin
        SalesHeader.SetRecFilter();
        CalcSalesDisc(SalesHeader);
        ReportSelections.SaveAsDocumentAttachment(
            ReportSelections.Usage::"Pro Forma S. Invoice".AsInteger(), SalesHeader, SalesHeader."No.", SalesHeader.GetBillToNo(), ShowNotificationAction);
    end;

    procedure PrintSalesOrderToAttachment(var SalesHeader: Record "Sales Header"; Usage: Option "Order Confirmation","Work Order","Pick Instruction")
    var
        ShowNotificationAction: Boolean;
    begin
        ShowNotificationAction := SalesHeader.Count() = 1;
        if SalesHeader.FindSet() then
            repeat
                DoPrintSalesOrderToAttachment(SalesHeader, Usage, ShowNotificationAction);
            until SalesHeader.Next() = 0;
    end;

    local procedure DoPrintSalesOrderToAttachment(SalesHeader: Record "Sales Header"; Usage: Option "Order Confirmation","Work Order","Pick Instruction"; ShowNotificationAction: Boolean)
    var
        ReportSelections: Record "Report Selections";
        ReportUsage: Enum "Report Selection Usage";
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;

        ReportUsage := GetSalesOrderUsage(Usage);

        SalesHeader.SetRange("No.", SalesHeader."No.");
        CalcSalesDisc(SalesHeader);

        ReportSelections.SaveAsDocumentAttachment(
            ReportUsage.AsInteger(), SalesHeader, SalesHeader."No.", SalesHeader.GetBillToNo(), ShowNotificationAction);
    end;

    local procedure DoPrintSalesHeader(SalesHeader: Record "Sales Header"; SendAsEmail: Boolean)
    var
        ReportSelections: Record "Report Selections";
        ReportUsage: Enum "Report Selection Usage";
        IsPrinted: Boolean;
    begin
        ReportUsage := GetSalesDocTypeUsage(SalesHeader);

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type");
        SalesHeader.SetRange("No.", SalesHeader."No.");
        CalcSalesDisc(SalesHeader);
        OnBeforeDoPrintSalesHeader(SalesHeader, ReportUsage.AsInteger(), SendAsEmail, IsPrinted);
        if IsPrinted then
            exit;

        if SendAsEmail then
            ReportSelections.SendEmailToCust(
                ReportUsage.AsInteger(), SalesHeader, SalesHeader."No.", SalesHeader.GetDocTypeTxt, true, SalesHeader.GetBillToNo)
        else
            ReportSelections.PrintForCust(ReportUsage, SalesHeader, SalesHeader.FieldNo("Bill-to Customer No."));
    end;

    [Scope('OnPrem')]
    procedure PrintSalesInvoiceHeader(SalesInvoiceHeader: Record "Sales Invoice Header"; SendAsEmail: Boolean; ShowRequestForm: Boolean)
    var
        ReportSelections: Record "Report Selections";
        SalesInvHeader: Record "Sales Invoice Header";
        DocPrintBuffer: Record "Document Print Buffer";
        ReportDistributionMgt: Codeunit "Report Distribution Management";
    begin
        with SalesInvHeader do begin
            Copy(SalesInvoiceHeader);
            SetRecFilter;

            InsertDocPrintBuffer(DocPrintBuffer, DATABASE::"Sales Invoice Header", 0, "No.");

            Commit();
            if SendAsEmail then
                ReportSelections.SendEmailToCust(
                  GetSalesInvoiceDocTypeUsage(SalesInvHeader).AsInteger(), SalesInvHeader, "No.",
                  ReportDistributionMgt.GetFullDocumentTypeText(SalesInvHeader), ShowRequestForm, "Bill-to Customer No.")
            else
                ReportSelections.PrintWithDocPrintOption(
                  GetSalesInvoiceDocTypeUsage(SalesInvHeader).AsInteger(), SalesInvHeader, FieldNo("Bill-to Customer No."),
                  ShowRequestForm, DATABASE::Customer, DocPrintBuffer);
        end;
    end;

    procedure PrintPurchHeader(PurchHeader: Record "Purchase Header")
    var
        ReportSelections: Record "Report Selections";
        ReportUsage: Enum "Report Selection Usage";
        IsPrinted: Boolean;
    begin
        ReportUsage := GetPurchDocTypeUsage(PurchHeader);

        PurchHeader.SetRange("Document Type", PurchHeader."Document Type");
        PurchHeader.SetRange("No.", PurchHeader."No.");
        CalcPurchDisc(PurchHeader);
        OnBeforeDoPrintPurchHeader(PurchHeader, ReportUsage.AsInteger(), IsPrinted);
        if IsPrinted then
            exit;

        ReportSelections.PrintWithDialogForVend(ReportUsage, PurchHeader, true, PurchHeader.FieldNo("Buy-from Vendor No."));
    end;

    procedure PrintPurchaseHeaderToDocumentAttachment(var PurchaseHeader: Record "Purchase Header");
    var
        ShowNotificationAction: Boolean;
    begin
        ShowNotificationAction := PurchaseHeader.Count() = 1;
        if PurchaseHeader.FindSet() then
            repeat
                DoPrintPurchaseHeaderToDocumentAttachment(PurchaseHeader, ShowNotificationAction);
            until PurchaseHeader.Next() = 0;
    end;

    local procedure DoPrintPurchaseHeaderToDocumentAttachment(PurchaseHeader: Record "Purchase Header"; ShowNotificationAction: Boolean)
    var
        ReportSelections: Record "Report Selections";
        ReportUsage: Enum "Report Selection Usage";
    begin
        ReportUsage := GetPurchDocTypeUsage(PurchaseHeader);

        PurchaseHeader.SetRecFilter();
        CalcPurchDisc(PurchaseHeader);
        ReportSelections.SaveAsDocumentAttachment(ReportUsage.AsInteger(), PurchaseHeader, PurchaseHeader."No.", PurchaseHeader."Pay-to Vendor No.", ShowNotificationAction);
    end;

    procedure PrintBankAccStmt(BankAccStmt: Record "Bank Account Statement")
    var
        ReportSelections: Record "Report Selections";
        IsPrinted: Boolean;
    begin
        BankAccStmt.SetRecFilter;
        OnBeforePrintBankAccStmt(BankAccStmt, IsPrinted);
        if IsPrinted then
            exit;

        ReportSelections.PrintReport(ReportSelections.Usage::"B.Stmt", BankAccStmt);
    end;

    procedure PrintCheck(var NewGenJnlLine: Record "Gen. Journal Line")
    var
        GenJnlLine: Record "Gen. Journal Line";
        ReportSelections: Record "Report Selections";
        IsPrinted: Boolean;
    begin
        GenJnlLine.Copy(NewGenJnlLine);
        GenJnlLine.OnCheckGenJournalLinePrintCheckRestrictions;
        OnBeforePrintCheck(GenJnlLine, IsPrinted);
        if IsPrinted then
            exit;

        ReportSelections.PrintReport(ReportSelections.Usage::"B.Check", GenJnlLine);
    end;

    procedure PrintTransferHeader(TransHeader: Record "Transfer Header")
    var
        ReportSelections: Record "Report Selections";
        IsPrinted: Boolean;
    begin
        TransHeader.SetRecFilter;
        OnBeforePrintTransferHeader(TransHeader, IsPrinted);
        if IsPrinted then
            exit;

        ReportSelections.PrintReport(ReportSelections.Usage::Inv1, TransHeader);
    end;

    procedure PrintServiceContract(ServiceContract: Record "Service Contract Header")
    var
        ReportSelection: Record "Report Selections";
        ReportUsage: Enum "Report Selection Usage";
        IsPrinted: Boolean;
    begin
        ReportUsage := GetServContractTypeUsage(ServiceContract);

        ServiceContract.SetRange("Contract No.", ServiceContract."Contract No.");
        OnBeforePrintServiceContract(ServiceContract, ReportUsage.AsInteger(), IsPrinted);
        if IsPrinted then
            exit;

        ReportSelection.Reset();
        ReportSelection.SetRange(Usage, ReportUsage);
        if ReportSelection.IsEmpty then
            Error(Text001, ReportSelection.TableCaption, Format(ServiceContract."Contract Type"), ServiceContract."Contract No.");

        ReportSelection.PrintForCust(ReportUsage, ServiceContract, ServiceContract.FieldNo("Bill-to Customer No."));
    end;

    procedure PrintServiceHeader(ServiceHeader: Record "Service Header")
    var
        ReportSelection: Record "Report Selections";
        ReportUsage: Enum "Report Selection Usage";
        IsPrinted: Boolean;
    begin
        ReportUsage := GetServHeaderDocTypeUsage(ServiceHeader);
        ServiceHeader.SetRange("Document Type", ServiceHeader."Document Type");
        ServiceHeader.SetRange("No.", ServiceHeader."No.");
        CalcServDisc(ServiceHeader);
        OnBeforePrintServiceHeader(ServiceHeader, ReportUsage.AsInteger(), IsPrinted);
        if IsPrinted then
            exit;

        ReportSelection.Reset();
        ReportSelection.SetRange(Usage, ReportUsage);
        if ReportSelection.IsEmpty then
            Error(Text002, ReportSelection.FieldCaption("Report ID"), ServiceHeader.TableCaption, ReportSelection.TableCaption);

        ReportSelection.PrintForCust(ReportUsage, ServiceHeader, ServiceHeader.FieldNo("Customer No."));
    end;

    procedure PrintAsmHeader(AsmHeader: Record "Assembly Header")
    var
        ReportSelections: Record "Report Selections";
        ReportUsage: Enum "Report Selection Usage";
        IsPrinted: Boolean;
    begin
        ReportUsage := GetAsmHeaderDocTypeUsage(AsmHeader);

        AsmHeader.SetRange("Document Type", AsmHeader."Document Type");
        AsmHeader.SetRange("No.", AsmHeader."No.");
        OnBeforePrintAsmHeader(AsmHeader, ReportUsage.AsInteger(), IsPrinted);
        if IsPrinted then
            exit;

        ReportSelections.PrintReport(ReportUsage, AsmHeader);
    end;

    [Scope('OnPrem')]
    procedure PrintCashOrder(var NewGenJnlLine: Record "Gen. Journal Line")
    var
        GenJnlLine: Record "Gen. Journal Line";
        ReportSelection: Record "Report Selections";
    begin
        GenJnlLine.Copy(NewGenJnlLine);
        GenJnlLine.TestField(Amount);
        if NewGenJnlLine."Credit Amount" <> 0 then
            ReportSelection.PrintReport(ReportSelection.Usage::UCI, GenJnlLine)
        else
            ReportSelection.PrintReport(ReportSelection.Usage::UCO, GenJnlLine);
    end;

    procedure PrintSalesOrder(SalesHeader: Record "Sales Header"; Usage: Option "Order Confirmation","Work Order","Pick Instruction")
    var
        ReportSelection: Record "Report Selections";
        ReportUsage: Enum "Report Selection Usage";
        IsPrinted: Boolean;
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;

        ReportUsage := GetSalesOrderUsage(Usage);

        SalesHeader.SetRange("No.", SalesHeader."No.");
        CalcSalesDisc(SalesHeader);
        OnBeforePrintSalesOrder(SalesHeader, ReportUsage.AsInteger(), IsPrinted);
        if IsPrinted then
            exit;

        ReportSelection.PrintWithDialogForCust(
            ReportUsage, SalesHeader, GuiAllowed, SalesHeader.FieldNo("Bill-to Customer No."));
    end;

    procedure PrintSalesHeaderArch(SalesHeaderArch: Record "Sales Header Archive")
    var
        ReportSelection: Record "Report Selections";
        ReportUsage: Enum "Report Selection Usage";
        IsPrinted: Boolean;
    begin
        ReportUsage := GetSalesArchDocTypeUsage(SalesHeaderArch);

        SalesHeaderArch.SetRecFilter();
        OnBeforePrintSalesHeaderArch(SalesHeaderArch, ReportUsage.AsInteger(), IsPrinted);
        if IsPrinted then
            exit;

        ReportSelection.PrintForCust(
            ReportUsage, SalesHeaderArch, SalesHeaderArch.FieldNo("Bill-to Customer No."));
    end;

    procedure PrintPurchHeaderArch(PurchHeaderArch: Record "Purchase Header Archive")
    var
        ReportSelection: Record "Report Selections";
        ReportUsage: Enum "Report Selection Usage";
        IsPrinted: Boolean;
    begin
        ReportUsage := GetPurchArchDocTypeUsage(PurchHeaderArch);

        PurchHeaderArch.SetRecFilter();
        OnBeforePrintPurchHeaderArch(PurchHeaderArch, ReportUsage.AsInteger(), IsPrinted);
        if IsPrinted then
            exit;

        ReportSelection.PrintWithDialogForVend(
            ReportUsage, PurchHeaderArch, true, PurchHeaderArch.FieldNo("Buy-from Vendor No."));
    end;

    procedure PrintProformaSalesInvoice(SalesHeader: Record "Sales Header")
    var
        ReportSelections: Record "Report Selections";
        IsPrinted: Boolean;
    begin
        SalesHeader.SetRecFilter;
        OnBeforePrintProformaSalesInvoice(SalesHeader, ReportSelections.Usage::"Pro Forma S. Invoice".AsInteger(), IsPrinted);
        if IsPrinted then
            exit;

        ReportSelections.PrintForCust(
            ReportSelections.Usage::"Pro Forma S. Invoice", SalesHeader, SalesHeader.FieldNo("Bill-to Customer No."));
    end;

    procedure PrintInvtOrderTest(PhysInvtOrderHeader: Record "Phys. Invt. Order Header"; ShowRequestForm: Boolean)
    var
        ReportSelections: Record "Report Selections";
    begin
        PhysInvtOrderHeader.SetRange("No.", PhysInvtOrderHeader."No.");
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"Phys.Invt.Order Test");
        ReportSelections.SetFilter("Report ID", '<>0');
        if ReportSelections.FindSet then
            repeat
                REPORT.RunModal(ReportSelections."Report ID", ShowRequestForm, false, PhysInvtOrderHeader);
            until ReportSelections.Next = 0;
    end;

    procedure PrintInvtOrder(PhysInvtOrderHeader: Record "Phys. Invt. Order Header"; ShowRequestForm: Boolean)
    var
        ReportSelections: Record "Report Selections";
    begin
        PhysInvtOrderHeader.SetRange("No.", PhysInvtOrderHeader."No.");
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"Phys.Invt.Order");
        ReportSelections.SetFilter("Report ID", '<>0');
        if ReportSelections.FindSet then
            repeat
                REPORT.RunModal(ReportSelections."Report ID", ShowRequestForm, false, PhysInvtOrderHeader);
            until ReportSelections.Next = 0;
    end;

    procedure PrintPostedInvtOrder(PstdPhysInvtOrderHdr: Record "Pstd. Phys. Invt. Order Hdr"; ShowRequestForm: Boolean)
    var
        ReportSelections: Record "Report Selections";
    begin
        PstdPhysInvtOrderHdr.SetRange("No.", PstdPhysInvtOrderHdr."No.");
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"P.Phys.Invt.Order");
        ReportSelections.SetFilter("Report ID", '<>0');
        if ReportSelections.FindSet then
            repeat
                REPORT.RunModal(ReportSelections."Report ID", ShowRequestForm, false, PstdPhysInvtOrderHdr);
            until ReportSelections.Next = 0;
    end;

    procedure PrintInvtRecording(PhysInvtRecordHeader: Record "Phys. Invt. Record Header"; ShowRequestForm: Boolean)
    var
        ReportSelections: Record "Report Selections";
    begin
        PhysInvtRecordHeader.SetRange("Order No.", PhysInvtRecordHeader."Order No.");
        PhysInvtRecordHeader.SetRange("Recording No.", PhysInvtRecordHeader."Recording No.");
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"Phys.Invt.Rec.");
        ReportSelections.SetFilter("Report ID", '<>0');
        if ReportSelections.FindSet then
            repeat
                REPORT.RunModal(ReportSelections."Report ID", ShowRequestForm, false, PhysInvtRecordHeader);
            until ReportSelections.Next = 0;
    end;

    procedure PrintPostedInvtRecording(PstdPhysInvtRecordHdr: Record "Pstd. Phys. Invt. Record Hdr"; ShowRequestForm: Boolean)
    var
        ReportSelections: Record "Report Selections";
    begin
        PstdPhysInvtRecordHdr.SetRange("Order No.", PstdPhysInvtRecordHdr."Order No.");
        PstdPhysInvtRecordHdr.SetRange("Recording No.", PstdPhysInvtRecordHdr."Recording No.");
        ReportSelections.SetRange(Usage, ReportSelections.Usage::"P.Phys.Invt.Rec.");
        ReportSelections.SetFilter("Report ID", '<>0');
        if ReportSelections.FindSet then
            repeat
                REPORT.RunModal(ReportSelections."Report ID", ShowRequestForm, false, PstdPhysInvtRecordHdr);
            until ReportSelections.Next = 0;
    end;

    [Scope('OnPrem')]
    procedure PrintAdvStmt(var NewPurchHeader: Record "Purchase Header")
    var
        PurchHeader: Record "Purchase Header";
        ReportSelection: Record "Report Selections";
    begin
        PurchHeader.Copy(NewPurchHeader);
        PurchHeader.SetRecFilter;
        ReportSelection.PrintWithDialogWithCheckForVend(
          ReportSelection.Usage::UAS, PurchHeader, true, PurchHeader.FieldNo("Buy-from Vendor No."));
    end;

    [Scope('OnPrem')]
    procedure PrintItemDoc(var NewItemDocHeader: Record "Item Document Header")
    var
        ItemDocHeader: Record "Item Document Header";
        ReportSelection: Record "Report Selections";
        DocPrintBuffer: Record "Document Print Buffer";
    begin
        with ItemDocHeader do begin
            Copy(NewItemDocHeader);
            SetRecFilter;

            InsertDocPrintBuffer(DocPrintBuffer, DATABASE::"Item Document Header", "Document Type", "No.");

            Commit();
            case "Document Type" of
                "Document Type"::Shipment:
                    ReportSelection.PrintWithDocPrintOption(
                      ReportSelection.Usage::UIS.AsInteger(), ItemDocHeader, 0, true, DATABASE::Customer, DocPrintBuffer);
                "Document Type"::Receipt:
                    ReportSelection.PrintWithDocPrintOption(
                      ReportSelection.Usage::UIR.AsInteger(), ItemDocHeader, 0, true, DATABASE::Customer, DocPrintBuffer);
            end;
        end;
    end;

    [Scope('OnPrem')]
    procedure PrintItemReceipt(ItemReceiptHeader: Record "Item Receipt Header"; ShowRequestForm: Boolean)
    var
        ReportSelections: Record "Report Selections";
        ItemRcptHeader: Record "Item Receipt Header";
        DocPrintBuffer: Record "Document Print Buffer";
    begin
        with ItemRcptHeader do begin
            Copy(ItemReceiptHeader);
            SetRecFilter;

            InsertDocPrintBuffer(DocPrintBuffer, DATABASE::"Item Receipt Header", 0, "No.");

            Commit();
            ReportSelections.PrintWithDocPrintOption(
              ReportSelections.Usage::IR.AsInteger(), ItemRcptHeader, 0, ShowRequestForm, DATABASE::Customer, DocPrintBuffer);
        end;
    end;

    [Scope('OnPrem')]
    procedure PrintItemJnlDoc(NewItemJnlLine: Record "Item Journal Line"; Reclass: Boolean)
    var
        ItemJnlLine: Record "Item Journal Line";
        ReportSelection: Record "Report Selections";
    begin
        with ItemJnlLine do begin
            Copy(NewItemJnlLine);
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");
            if Reclass then
                ReportSelection.PrintReport(ReportSelection.Usage::IRJ, ItemJnlLine)
            else
                ReportSelection.PrintReport(ReportSelection.Usage::PIJ, ItemJnlLine);
        end;
    end;

    [Scope('OnPrem')]
    procedure PrintFAJnlDoc(NewFAJnlLine: Record "FA Journal Line")
    var
        FAJnlLine: Record "FA Journal Line";
        ReportSelection: Record "Report Selections";
        DocPrintBuffer: Record "Document Print Buffer";
    begin
        with FAJnlLine do begin
            Copy(NewFAJnlLine);
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");

            InsertJournalPrintBuffer(DocPrintBuffer, DATABASE::"FA Journal Line", "Journal Template Name", "Journal Batch Name");

            Commit();
            ReportSelection.PrintWithDocPrintOption(
              ReportSelection.Usage::FAJ.AsInteger(), FAJnlLine, 0, true, DATABASE::Customer, DocPrintBuffer);
        end;
    end;

    [Scope('OnPrem')]
    procedure PrintFAReclassJnlDoc(NewFAReclassJnlLine: Record "FA Reclass. Journal Line")
    var
        FAReclassJnlLine: Record "FA Reclass. Journal Line";
        ReportSelection: Record "Report Selections";
    begin
        with FAReclassJnlLine do begin
            Copy(NewFAReclassJnlLine);
            SetRange("Journal Template Name", "Journal Template Name");
            SetRange("Journal Batch Name", "Journal Batch Name");
            ReportSelection.PrintReport(ReportSelection.Usage::FARJ, FAReclassJnlLine);
        end;
    end;

    [Scope('OnPrem')]
    procedure InsertDocPrintBuffer(var DocPrintBuffer: Record "Document Print Buffer"; TableID: Integer; DocType: Option; DocNo: Code[20])
    begin
        with DocPrintBuffer do begin
            Init;
            "User ID" := UserId;
            "Table ID" := TableID;
            "Document Type" := DocType;
            "Document No." := DocNo;
            if not Modify then
                Insert;
        end;
    end;

    local procedure InsertJournalPrintBuffer(var DocPrintBuffer: Record "Document Print Buffer"; TableID: Integer; JnlTemplate: Code[10]; JnlBatch: Code[10])
    begin
        with DocPrintBuffer do begin
            Init;
            "User ID" := UserId;
            "Table ID" := TableID;
            "Journal Template Name" := JnlTemplate;
            "Journal Batch Name" := JnlBatch;
            if not Modify then
                Insert;
        end;
    end;

    local procedure GetSalesDocTypeUsage(SalesHeader: Record "Sales Header"): Enum "Report Selection Usage"
    var
        ReportSelections: Record "Report Selections";
        CopyOfSalesHeader: Record "Sales Header";
        CorrDocMgt: Codeunit "Corrective Document Mgt.";
        TypeUsage: Integer;
        IsHandled: Boolean;
    begin
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Quote:
                exit(ReportSelections.Usage::"S.Quote");
            SalesHeader."Document Type"::"Blanket Order":
                exit(ReportSelections.Usage::"S.Blanket");
            SalesHeader."Document Type"::Order:
                exit(ReportSelections.Usage::"S.Order");
            SalesHeader."Document Type"::"Return Order":
                exit(ReportSelections.Usage::"S.Return");
            SalesHeader."Document Type"::Invoice:
                begin
                    CopyOfSalesHeader := SalesHeader;
                    if CorrDocMgt.IsCorrDocument(CopyOfSalesHeader) then
                        exit(ReportSelections.Usage::UCSD);
                    exit(ReportSelections.Usage::USI);
                end;
            SalesHeader."Document Type"::"Credit Memo":
                begin
                    CopyOfSalesHeader := SalesHeader;
                    if CorrDocMgt.IsCorrDocument(CopyOfSalesHeader) then
                        exit(ReportSelections.Usage::UCSD);
                    exit(ReportSelections.Usage::USCM);
                end;
            else begin
                    IsHandled := false;
                    OnGetSalesDocTypeUsageElseCase(SalesHeader, TypeUsage, IsHandled);
                    if IsHandled then
                        exit("Report Selection Usage".FromInteger(TypeUsage));
                    Error('');
                end;
        end;
    end;

    local procedure GetSalesInvoiceDocTypeUsage(SalesInvoiceHeader: Record "Sales Invoice Header"): Enum "Report Selection Usage"
    var
        ReportSelections: Record "Report Selections";
        TempSalesHeader: Record "Sales Header" temporary;
        CorrectiveDocMgt: Codeunit "Corrective Document Mgt.";
    begin
        CorrectiveDocMgt.FillSalesInvCorrHeader(TempSalesHeader, SalesInvoiceHeader);
        if CorrectiveDocMgt.IsCorrDocument(TempSalesHeader) then
            exit(ReportSelections.Usage::CSI);
        exit(ReportSelections.Usage::"S.Invoice");
    end;

    local procedure GetPurchDocTypeUsage(PurchHeader: Record "Purchase Header"): Enum "Report Selection Usage"
    var
        ReportSelections: Record "Report Selections";
        TypeUsage: Integer;
        IsHandled: Boolean;
    begin
        case PurchHeader."Document Type" of
            PurchHeader."Document Type"::Quote:
                exit(ReportSelections.Usage::"P.Quote");
            PurchHeader."Document Type"::"Blanket Order":
                exit(ReportSelections.Usage::"P.Blanket");
            PurchHeader."Document Type"::Order:
                exit(ReportSelections.Usage::"P.Order");
            PurchHeader."Document Type"::Invoice:
                exit(ReportSelections.Usage::UPI);
            PurchHeader."Document Type"::"Credit Memo":
                exit(ReportSelections.Usage::UPCM);
            PurchHeader."Document Type"::"Return Order":
                exit(ReportSelections.Usage::"P.Return");
            else begin
                    IsHandled := false;
                    OnGetPurchDocTypeUsageElseCase(PurchHeader, TypeUsage, IsHandled);
                    if IsHandled then
                        exit("Report Selection Usage".FromInteger(TypeUsage));
                    Error('');
                end;
        end;
    end;

    local procedure GetServContractTypeUsage(ServiceContractHeader: Record "Service Contract Header"): Enum "Report Selection Usage"
    var
        ReportSelections: Record "Report Selections";
        TypeUsage: Integer;
        IsHandled: Boolean;
    begin
        case ServiceContractHeader."Contract Type" of
            ServiceContractHeader."Contract Type"::Quote:
                exit(ReportSelections.Usage::"SM.Contract Quote");
            ServiceContractHeader."Contract Type"::Contract:
                exit(ReportSelections.Usage::"SM.Contract");
            else begin
                    IsHandled := false;
                    OnGetServContractTypeUsageElseCase(ServiceContractHeader, TypeUsage, IsHandled);
                    if IsHandled then
                        exit("Report Selection Usage".FromInteger(TypeUsage));
                    Error('');
                end;
        end;
    end;

    local procedure GetServHeaderDocTypeUsage(ServiceHeader: Record "Service Header"): Enum "Report Selection Usage"
    var
        ReportSelections: Record "Report Selections";
        TypeUsage: Integer;
        IsHandled: Boolean;
    begin
        case ServiceHeader."Document Type" of
            ServiceHeader."Document Type"::Quote:
                exit(ReportSelections.Usage::"SM.Quote");
            ServiceHeader."Document Type"::Order:
                exit(ReportSelections.Usage::"SM.Order");
            ServiceHeader."Document Type"::Invoice:
                exit(ReportSelections.Usage::"SM.Invoice");
            ServiceHeader."Document Type"::"Credit Memo":
                exit(ReportSelections.Usage::"SM.Credit Memo");
            else begin
                    IsHandled := false;
                    OnGetServHeaderDocTypeUsageElseCase(ServiceHeader, TypeUsage, IsHandled);
                    if IsHandled then
                        exit("Report Selection Usage".FromInteger(TypeUsage));
                    Error('');
                end;
        end;
    end;

    local procedure GetAsmHeaderDocTypeUsage(AsmHeader: Record "Assembly Header"): Enum "Report Selection Usage"
    var
        ReportSelections: Record "Report Selections";
        TypeUsage: Integer;
        IsHandled: Boolean;
    begin
        case AsmHeader."Document Type" of
            AsmHeader."Document Type"::Quote,
            AsmHeader."Document Type"::"Blanket Order",
            AsmHeader."Document Type"::Order:
                exit(ReportSelections.Usage::"Asm.Order");
            else begin
                    IsHandled := false;
                    OnGetAsmHeaderTypeUsageElseCase(AsmHeader, TypeUsage, IsHandled);
                    if IsHandled then
                        exit("Report Selection Usage".FromInteger(TypeUsage));
                    Error('');
                end;
        end;
    end;

    local procedure GetSalesOrderUsage(Usage: Option "Order Confirmation","Work Order","Pick Instruction"): Enum "Report Selection Usage"
    var
        ReportSelections: Record "Report Selections";
    begin
        case Usage of
            Usage::"Order Confirmation":
                exit(ReportSelections.Usage::"S.Order");
            Usage::"Work Order":
                exit(ReportSelections.Usage::"S.Work Order");
            Usage::"Pick Instruction":
                exit(ReportSelections.Usage::"S.Order Pick Instruction");
            else
                Error('');
        end;
    end;

    local procedure GetSalesArchDocTypeUsage(SalesHeaderArchive: Record "Sales Header Archive"): Enum "Report Selection Usage"
    var
        ReportSelections: Record "Report Selections";
        TypeUsage: Integer;
        IsHandled: Boolean;
    begin
        case SalesHeaderArchive."Document Type" of
            SalesHeaderArchive."Document Type"::Quote:
                exit(ReportSelections.Usage::"S.Arch.Quote");
            SalesHeaderArchive."Document Type"::Order:
                exit(ReportSelections.Usage::"S.Arch.Order");
            SalesHeaderArchive."Document Type"::"Return Order":
                exit(ReportSelections.Usage::"S.Arch.Return");
            SalesHeaderArchive."Document Type"::"Blanket Order":
                exit(ReportSelections.Usage::"S.Arch.Blanket");
            else begin
                    IsHandled := false;
                    OnGetSalesArchDocTypeUsageElseCase(SalesHeaderArchive, TypeUsage, IsHandled);
                    if IsHandled then
                        exit("Report Selection Usage".FromInteger(TypeUsage));
                    Error('');
                end;
        end
    end;

    local procedure GetPurchArchDocTypeUsage(PurchHeaderArchive: Record "Purchase Header Archive"): Enum "Report Selection Usage"
    var
        ReportSelections: Record "Report Selections";
        TypeUsage: Integer;
        IsHandled: Boolean;
    begin
        case PurchHeaderArchive."Document Type" of
            PurchHeaderArchive."Document Type"::Quote:
                exit(ReportSelections.Usage::"P.Arch.Quote");
            PurchHeaderArchive."Document Type"::Order:
                exit(ReportSelections.Usage::"P.Arch.Order");
            PurchHeaderArchive."Document Type"::"Return Order":
                exit(ReportSelections.Usage::"P.Arch.Return");
            PurchHeaderArchive."Document Type"::"Blanket Order":
                exit(ReportSelections.Usage::"P.Arch.Blanket");
            else begin
                    IsHandled := false;
                    OnGetPurchArchDocTypeUsageElseCase(PurchHeaderArchive, TypeUsage, IsHandled);
                    if IsHandled then
                        exit("Report Selection Usage".FromInteger(TypeUsage));
                    Error('');
                end;
        end;
    end;

    local procedure CalcSalesDisc(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalcSalesDisc(SalesHeader, IsHandled);
        if IsHandled then
            exit;

        SalesSetup.Get();
        if SalesSetup."Calc. Inv. Discount" then begin
            SalesLine.Reset();
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.FindFirst;
            CODEUNIT.Run(CODEUNIT::"Sales-Calc. Discount", SalesLine);
            SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
            Commit();
        end;
    end;

    local procedure CalcPurchDisc(var PurchHeader: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalcPurchDisc(PurchHeader, IsHandled);
        if IsHandled then
            exit;

        PurchSetup.Get();
        if PurchSetup."Calc. Inv. Discount" then begin
            PurchLine.Reset();
            PurchLine.SetRange("Document Type", PurchHeader."Document Type");
            PurchLine.SetRange("Document No.", PurchHeader."No.");
            PurchLine.FindFirst;
            CODEUNIT.Run(CODEUNIT::"Purch.-Calc.Discount", PurchLine);
            PurchHeader.Get(PurchHeader."Document Type", PurchHeader."No.");
            Commit();
        end;
    end;

    local procedure CalcServDisc(var ServHeader: Record "Service Header")
    var
        ServLine: Record "Service Line";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalcServDisc(ServHeader, IsHandled);
        if IsHandled then
            exit;

        SalesSetup.Get();
        if SalesSetup."Calc. Inv. Discount" then begin
            ServLine.Reset();
            ServLine.SetRange("Document Type", ServHeader."Document Type");
            ServLine.SetRange("Document No.", ServHeader."No.");
            ServLine.FindFirst;
            CODEUNIT.Run(CODEUNIT::"Service-Calc. Discount", ServLine);
            ServHeader.Get(ServHeader."Document Type", ServHeader."No.");
            Commit();
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPrintSalesInvoiceToDocumentAttachment(var SalesHeader: Record "Sales Header"; SalesInvoicePrintToAttachmentOption: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPrintSalesOrderToDocumentAttachment(var SalesHeader: Record "Sales Header"; SalesOrderPrintToAttachmentOption: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcSalesDisc(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcServDisc(var ServiceHeader: Record "Service Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcPurchDisc(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDoPrintSalesHeader(var SalesHeader: Record "Sales Header"; ReportUsage: Integer; SendAsEmail: Boolean; var IsPrinted: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDoPrintPurchHeader(var PurchHeader: Record "Purchase Header"; ReportUsage: Integer; var IsPrinted: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintBankAccStmt(var BankAccountStatement: Record "Bank Account Statement"; var IsPrinted: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintCheck(var GenJournalLine: Record "Gen. Journal Line"; var IsPrinted: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintTransferHeader(var TransferHeader: Record "Transfer Header"; var IsPrinted: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintServiceContract(var ServiceContractHeader: Record "Service Contract Header"; ReportUsage: Integer; var IsPrinted: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintServiceHeader(var ServiceHeader: Record "Service Header"; ReportUsage: Integer; var IsPrinted: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintAsmHeader(var AssemblyHeader: Record "Assembly Header"; ReportUsage: Integer; var IsPrinted: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintSalesOrder(var SalesHeader: Record "Sales Header"; ReportUsage: Integer; var IsPrinted: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintSalesHeaderArch(var SalesHeaderArchive: Record "Sales Header Archive"; ReportUsage: Integer; var IsPrinted: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintPurchHeaderArch(var PurchaseHeaderArchive: Record "Purchase Header Archive"; ReportUsage: Integer; var IsPrinted: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrintProformaSalesInvoice(var SalesHeader: Record "Sales Header"; ReportUsage: Integer; var IsPrinted: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetAsmHeaderTypeUsageElseCase(AssemblyHeader: Record "Assembly Header"; var TypeUsage: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetPurchDocTypeUsageElseCase(PurchaseHeader: Record "Purchase Header"; var TypeUsage: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetSalesDocTypeUsageElseCase(SalesHeader: Record "Sales Header"; var TypeUsage: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetServHeaderDocTypeUsageElseCase(ServiceHeader: Record "Service Header"; var TypeUsage: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetServContractTypeUsageElseCase(ServiceContractHeader: Record "Service Contract Header"; var TypeUsage: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetSalesArchDocTypeUsageElseCase(SalesHeaderArchive: Record "Sales Header Archive"; var TypeUsage: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetPurchArchDocTypeUsageElseCase(PurchaseHeaderArchive: Record "Purchase Header Archive"; var TypeUsage: Integer; var IsHandled: Boolean)
    begin
    end;
}

