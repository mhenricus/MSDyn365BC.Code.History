codeunit 144127 "ERM  Miscellaneous"
{
    // 1. Test to validate Issued Customer Bill after post Sales Invoice.
    // 2. Test to validate error when issue Customer Bill with wrong Posting Date.
    // 3. Test to validate values for Account Book Sheet - Print Report with Progressive Balance as True.
    // 4. Test to validate Job Ledger Entry after post Purchase Credit Memo with Job.
    // 
    // Covers Test Cases for WI - 345565
    // -----------------------------------------------------------------------------------------------------------------------
    // Test Function Name                                                                                               TFS ID
    // -----------------------------------------------------------------------------------------------------------------------
    // IssuingCustomerBillAfterPostSalesInvoice                                                                        251109
    // IssuingCustomerBillAfterPostSalesInvoiceError                                                                   152765
    // AccountBookSheetPrintWithProgressiveBalance                                                                     306902
    // JobLedgerEntryAfterPostPurchCrMemoWithJob                                                                       311038

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;
        LibraryJob: Codeunit "Library - Job";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySales: Codeunit "Library - Sales";
        LibraryService: Codeunit "Library - Service";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        CustomerBillMsg: Label '1 customer bills have been issued.';
        PostingDateErr: Label 'Posting Date is not within your range of allowed posting dates in Gen. Journal Line Journal Template Name='''',Journal Batch Name=''''';
        ValueMatchErr: Label 'Value must match.';
        BankAccErr: Label 'Wrong Bank Account.';
        WrongResultErr: Label 'Wrong result of GetTaxCode';

    [Test]
    [HandlerFunctions('IssuingCustomerBillRequestPageHandler,MessageHandler')]
    [Scope('OnPrem')]
    procedure IssuingCustomerBillAfterPostSalesInvoice()
    var
        SalesHeader: Record "Sales Header";
    begin
        // Test to validate Issued Customer Bill after post Sales Invoice.
        // Setup.
        Initialize;
        EnqueueValuesForHandler(WorkDate, CreateAndPostSalesInvoice(SalesHeader));  // Enqueue required for IssuingCustomerBillRequestPageHandler.

        // Exercise.
        REPORT.Run(REPORT::"Issuing Customer Bill");

        // Verify: Verification done in MessageHandler.
    end;

    [Test]
    [HandlerFunctions('IssuingCustomerBillRequestPageHandler')]
    [Scope('OnPrem')]
    procedure IssuingCustomerBillAfterPostSalesInvoiceError()
    var
        SalesHeader: Record "Sales Header";
    begin
        // Test to validate error when issue Customer Bill with wrong Posting Date.
        // Setup.
        Initialize;
        EnqueueValuesForHandler(
          CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'Y>', WorkDate), CreateAndPostSalesInvoice(SalesHeader));  // Enqueue required for IssuingCustomerBillRequestPageHandler.

        // Exercise.
        asserterror REPORT.Run(REPORT::"Issuing Customer Bill");

        // Verify.
        Assert.ExpectedError(StrSubstNo(PostingDateErr));
    end;

    [Test]
    [HandlerFunctions('AccountBookPrintRequestPageHandler')]
    [Scope('OnPrem')]
    procedure AccountBookSheetPrintWithProgressiveBalance()
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // Test to validate values for Account Book Sheet - Print Report with Progressive Balance as True.
        // Setup: Create G/L Account. Create and post General Journal Line.
        Initialize;
        CreateAndPostGeneralJournalLine(GenJournalLine);
        EnqueueValuesForHandler(WorkDate, GenJournalLine."Account No.");  // Enqueue required for AccountBookSheetPrintRequestPageHandler.

        // Exercise.
        REPORT.Run(REPORT::"Account Book Sheet - Print");

        // Verify.
        LibraryReportDataset.LoadDataSetFile;
        LibraryReportDataset.AssertElementWithValueExists('G_L_Account_No_', GenJournalLine."Account No.");
        LibraryReportDataset.AssertElementWithValueExists('TotalAmount', GenJournalLine.Amount);
        LibraryReportDataset.AssertElementWithValueExists('GL_Book_Entry__External_Document_No__', GenJournalLine."Document No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [Scope('OnPrem')]
    procedure JobLedgerEntryAfterPostPurchCrMemoWithJob()
    var
        PurchaseLine: Record "Purchase Line";
        PostedInvoiceNo: Code[20];
        PostedCrMemoNo: Code[20];
    begin
        // Test to validate Job Ledger Entry after post Purchase Credit Memo with Job.
        // Setup.
        Initialize;
        PostedInvoiceNo := CreateAndPostPurchaseInvoiceWithJob(PurchaseLine);

        // Exercise.
        PostedCrMemoNo := CreateAndPostPurchCrMemoWithCopyDocument(PostedInvoiceNo, PurchaseLine."Buy-from Vendor No.");

        // Verify: Verify Unit Cost and Total Cost on Job Ledger Entry.
        VerifyJobLedgerEntry(
          PostedCrMemoNo, PurchaseLine."No.", -PurchaseLine.Quantity, PurchaseLine."Direct Unit Cost", Round(
            -PurchaseLine.Quantity * PurchaseLine."Direct Unit Cost"));
        VerifyJobLedgerEntry(
          PostedInvoiceNo, PurchaseLine."No.", PurchaseLine.Quantity, PurchaseLine."Direct Unit Cost", Round(
            PurchaseLine.Quantity * PurchaseLine."Direct Unit Cost"));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PurchaseHeaderVendorBankAcc()
    var
        Vendor: Record Vendor;
        PurchHeader: Record "Purchase Header";
        VendBankAcc: Record "Vendor Bank Account";
    begin
        // [SCENARIO 361754] "Bank Account" on Purchase Header is related to "Pay-to Vendor No."
        Initialize;
        // [GIVEN] Vendor "X", vendor "Y", "X"."Pay-to Vendor No." = "Y"
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Pay-to Vendor No.", LibraryPurchase.CreateVendorNo);
        Vendor.Modify(true);
        // [GIVEN] Vendor Bank Account "Z" for vendor "Y"
        LibraryPurchase.CreateVendorBankAccount(VendBankAcc, Vendor."Pay-to Vendor No.");
        // [GIVEN] Purchase Order for vendor "X"
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Order, Vendor."No.");
        // [WHEN] Put "Z" to "Bank Account" on Purchase Order
        PurchHeader.Validate("Bank Account", VendBankAcc.Code);
        // [THEN] "Bank Account" is set to "Z"
        Assert.AreEqual(VendBankAcc.Code, PurchHeader."Bank Account", BankAccErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SalesHeaderCustomerBankAcc()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        CustBankAcc: Record "Customer Bank Account";
    begin
        // [SCENARIO 361754] "Bank Account" on Sales Header is related to "Bill-to Customer No."
        Initialize;
        // [GIVEN] Customer "X", customer "Y", "X"."Bill-to Customer No." = "Y"
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Bill-to Customer No.", LibrarySales.CreateCustomerNo);
        Customer.Modify(true);
        // [GIVEN] Customer Bank Account "Z" for customer "Y"
        LibrarySales.CreateCustomerBankAccount(CustBankAcc, Customer."Bill-to Customer No.");
        // [GIVEN] Sales Order for customer "X"
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."Bill-to Customer No.");
        // [WHEN] Put "Z" to "Bank Account" on Sales Order
        SalesHeader.Validate("Bank Account", CustBankAcc.Code);
        // [THEN] "Bank Account" is set to "Z"
        Assert.AreEqual(CustBankAcc.Code, SalesHeader."Bank Account", BankAccErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure UTCompInfoGetTaxCodeFiscalCodeFillingVATRegNoIsBlank()
    var
        CompanyInformation: Record "Company Information";
    begin
        // [FEATURE] [UT][Company Information][Fiscal Code]
        // [SCENARIO 375086] "Company Information".GetTaxCode should return "Fiscal Code"if "Fiscal Code"is not blank
        Initialize;

        // [GIVEN] "Company Information" with "Fiscal Code" = "X" and "VAT Registration No." are blank
        CreateCompInfoWithFiscalCodeAndVATRegNo(CompanyInformation, Format(LibraryRandom.RandInt(1000)), '');

        // [WHEN] Invoke "Company Information".GetTaxCode
        // [THEN] Result = "X"
        Assert.AreEqual(CompanyInformation."Fiscal Code", CompanyInformation.GetTaxCode, WrongResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure UTCompInfoGetTaxCodeFiscalCodeIsBlankVATRegNoFilling()
    var
        CompanyInformation: Record "Company Information";
    begin
        // [FEATURE] [UT][Company Information][Fiscal Code]
        // [SCENARIO 375086] "Company Information".GetTaxCode should return "VAT Registration No." if "Fiscal Code"is blank
        Initialize;

        // [GIVEN] "Company Information" with "Fiscal Code" is blank and "VAT Registration No." = "X"
        CreateCompInfoWithFiscalCodeAndVATRegNo(CompanyInformation, '', Format(LibraryRandom.RandInt(1000)));

        // [WHEN] Invoke "Company Information".GetTaxCode
        // [THEN] Result = "X"
        Assert.AreEqual(CompanyInformation."VAT Registration No.", CompanyInformation.GetTaxCode, WrongResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure UTVendGetTaxCodeFiscalCodeFillingVATRegNoIsBlank()
    var
        Vendor: Record Vendor;
    begin
        // [FEATURE] [UT][Vendor][Fiscal Code]
        // [SCENARIO 375086] Vendor.GetTaxCode should return "Fiscal Code"if "Fiscal Code"is not blank
        Initialize;
        // [GIVEN] Vendor with "Fiscal Code" = "X" and "VAT Registration No." is blank
        CreateVendorWithFiscalCodeAndVATRegNo(Vendor, Format(LibraryRandom.RandInt(1000)), '');

        // [WHEN] Invoke Vendor.GetTaxCode
        // [THEN] Result = "X"
        Assert.AreEqual(Vendor."Fiscal Code", Vendor.GetTaxCode, WrongResultErr);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure UTVendGetTaxCodeFiscalCodeIsBlankVATRegNoFilling()
    var
        Vendor: Record Vendor;
    begin
        // [FEATURE] [UT][Vendor][Fiscal Code]
        // [SCENARIO 375086] Vendor.GetTaxCode should return "VAT Registration No." if "Fiscal Code"is blank
        Initialize;

        // [GIVEN] Vendor with "Fiscal Code" is blank and "VAT Registration No." = "X"
        CreateVendorWithFiscalCodeAndVATRegNo(Vendor, '', Format(LibraryRandom.RandInt(1000)));

        // [WHEN] Invoke Vendor.GetTaxCode
        // [THEN] Result = "X"
        Assert.AreEqual(Vendor."VAT Registration No.", Vendor.GetTaxCode, WrongResultErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PrefferedBankAccInSalesHeader()
    var
        Customer: Record Customer;
        CustBankAcc: Record "Customer Bank Account";
        SalesHeader: Record "Sales Header";
    begin
        // [FEATURE] [Customer] [Sales]
        // [SCENARIO 219280] If Customer has "Preffered Bank Account Code", it must be populated in Sales Header
        Initialize;
        // [GIVEN] Customer "CCC"
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Customer Bank Account "BA111" for customer "CCC"
        LibrarySales.CreateCustomerBankAccount(CustBankAcc, Customer."No.");
        // [GIVEN] Customer Bank Account "BA222" for customer "CCC"
        LibrarySales.CreateCustomerBankAccount(CustBankAcc, Customer."No.");
        // [GIVEN] Bank Account "BA222" is set as "Preffered Bank Account Code" for Customer "CCC"
        Customer.Validate("Preferred Bank Account Code", CustBankAcc.Code);
        Customer.Modify(true);
        // [WHEN] Create Sales Order for customer "CCC"
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // [THEN] "Bank Account" is set to "BA222"
        Assert.AreEqual(CustBankAcc.Code, SalesHeader."Bank Account", BankAccErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PrefferedBankAccInPurchHeader()
    var
        Vendor: Record Vendor;
        VendBankAcc: Record "Vendor Bank Account";
        PurchaseHeader: Record "Purchase Header";
    begin
        // [FEATURE] [Vendor] [Purchase]
        // [SCENARIO 219280] If Vendor has "Preffered Bank Account Code", it must be populated in Purchase Header
        Initialize;
        // [GIVEN] Vendor "VVV"
        LibraryPurchase.CreateVendor(Vendor);
        // [GIVEN] Vendor Bank Account "BA111" for vendor "VVV"
        LibraryPurchase.CreateVendorBankAccount(VendBankAcc, Vendor."No.");
        // [GIVEN] Vendor Bank Account "BA222" for vendor "VVV"
        LibraryPurchase.CreateVendorBankAccount(VendBankAcc, Vendor."No.");
        // [GIVEN] Bank Account "BA222" is set as "Preffered Bank Account Code" for Vendor "VVV"
        Vendor.Validate("Preferred Bank Account Code", VendBankAcc.Code);
        Vendor.Modify(true);
        // [WHEN] Create Purchase Order forvendor "VVV"
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, Vendor."No.");
        // [THEN] "Bank Account" is set to "BA222"
        Assert.AreEqual(VendBankAcc.Code, PurchaseHeader."Bank Account", BankAccErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure EmptyPrefferedBankAccInSalesHeader()
    var
        Customer: Record Customer;
        CustBankAcc: Record "Customer Bank Account";
        SalesHeader: Record "Sales Header";
        BankAccCode: Code[20];
    begin
        // [FEATURE] [Customer] [Sales]
        // [SCENARIO 219280] If Customer has empty "Preffered Bank Account Code", "Bank Account" in Sales Header must be populated with the 1st Customer Bank Account by Code
        Initialize;
        // [GIVEN] Customer "CCC"
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Customer Bank Account "BA111" for customer "CCC"
        LibrarySales.CreateCustomerBankAccount(CustBankAcc, Customer."No.");
        BankAccCode := CustBankAcc.Code;
        // [GIVEN] Customer Bank Account "BA222" for customer "CCC"
        LibrarySales.CreateCustomerBankAccount(CustBankAcc, Customer."No.");
        // [GIVEN] "Preffered Bank Account Code" is empty for Customer "CCC"
        Customer.Validate("Preferred Bank Account Code", '');
        Customer.Modify(true);
        // [WHEN] Create Sales Order for customer "CCC"
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        // [THEN] "Bank Account" is set to "BA111"
        Assert.AreEqual(BankAccCode, SalesHeader."Bank Account", BankAccErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure EmptyPrefferedBankAccInPurchHeader()
    var
        Vendor: Record Vendor;
        VendBankAcc: Record "Vendor Bank Account";
        PurchaseHeader: Record "Purchase Header";
        BankAccCode: Code[20];
    begin
        // [FEATURE] [Vendor] [Purchase]
        // [SCENARIO 219280] If Vendor has empty "Preffered Bank Account Code", "Bank Account" in Purchase Header must be populated with the 1st Vendor Bank Account by Code
        Initialize;
        // [GIVEN] Vendor "VVV"
        LibraryPurchase.CreateVendor(Vendor);
        // [GIVEN] Vendor Bank Account "BA111" for vendor "VVV"
        LibraryPurchase.CreateVendorBankAccount(VendBankAcc, Vendor."No.");
        BankAccCode := VendBankAcc.Code;
        // [GIVEN] Vendor Bank Account "BA222" for vendor "VVV"
        LibraryPurchase.CreateVendorBankAccount(VendBankAcc, Vendor."No.");
        // [GIVEN] "Preffered Bank Account Code" is empty for Vendor "VVV"
        Vendor.Validate("Preferred Bank Account Code", '');
        Vendor.Modify(true);
        // [WHEN] Create Purchase Order forvendor "VVV"
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, Vendor."No.");
        // [THEN] "Bank Account" is set to "BA111"
        Assert.AreEqual(BankAccCode, PurchaseHeader."Bank Account", BankAccErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PrefferedBankAccInServiceHeader()
    var
        Customer: Record Customer;
        CustBankAcc: Record "Customer Bank Account";
        ServiceHeader: Record "Service Header";
    begin
        // [FEATURE] [Customer] [Service]
        // [SCENARIO 219280] If Customer has "Preffered Bank Account Code", it must be populated in Service Header
        Initialize;
        // [GIVEN] Customer "CCC"
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Customer Bank Account "BA111" for customer "CCC"
        LibrarySales.CreateCustomerBankAccount(CustBankAcc, Customer."No.");
        // [GIVEN] Customer Bank Account "BA222" for customer "CCC"
        LibrarySales.CreateCustomerBankAccount(CustBankAcc, Customer."No.");
        // [GIVEN] Bank Account "BA222" is set as "Preffered Bank Account Code" for Customer "CCC"
        Customer.Validate("Preferred Bank Account Code", CustBankAcc.Code);
        Customer.Modify(true);
        // [WHEN] Create Service Order for customer "CCC"
        LibraryService.CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::Order, Customer."No.");
        // [THEN] "Bank Account" is set to "BA222"
        Assert.AreEqual(CustBankAcc.Code, ServiceHeader."Bank Account", BankAccErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure EmptyPrefferedBankAccInServiceHeader()
    var
        Customer: Record Customer;
        CustBankAcc: Record "Customer Bank Account";
        ServiceHeader: Record "Service Header";
        BankAccCode: Code[20];
    begin
        // [FEATURE] [Customer] [Service]
        // [SCENARIO 219280] If Customer has empty "Preffered Bank Account Code", "Bank Account" in Service Header must be populated with the 1st Customer Bank Account by Code
        Initialize;
        // [GIVEN] Customer "CCC"
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Customer Bank Account "BA111" for customer "CCC"
        LibrarySales.CreateCustomerBankAccount(CustBankAcc, Customer."No.");
        BankAccCode := CustBankAcc.Code;
        // [GIVEN] Customer Bank Account "BA222" for customer "CCC"
        LibrarySales.CreateCustomerBankAccount(CustBankAcc, Customer."No.");
        // [GIVEN] "Preffered Bank Account Code" is empty for Customer "CCC"
        Customer.Validate("Preferred Bank Account Code", '');
        Customer.Modify(true);
        // [WHEN] Create Service Order for customer "CCC"
        LibraryService.CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::Order, Customer."No.");
        // [THEN] "Bank Account" is set to "BA111"
        Assert.AreEqual(BankAccCode, ServiceHeader."Bank Account", BankAccErr);
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear;
        UpdateGeneralLedgerSetup;
    end;

    local procedure CreateAndPostGeneralJournalLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        CreateGeneralJournalBatch(GenJournalBatch);
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
          GenJournalLine."Account Type"::"G/L Account", CreateGLAccount('', ''), LibraryRandom.RandDec(100, 2));  // Use random Amount, VAT Prod Posting Group and Gen. Prod posting group as blank.
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateAndPostPurchCrMemoWithCopyDocument(PostedInvoiceNo: Code[20]; VendorNo: Code[20]): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        DocumentType: Option Quote,"Blanket Order","Order",Invoice,"Return Order","Credit Memo","Posted Receipt","Posted Invoice","Posted Return Shipment","Posted Credit Memo";
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo", VendorNo);
        LibraryPurchase.CopyPurchaseDocument(PurchaseHeader, DocumentType::"Posted Invoice", PostedInvoiceNo, true, false);  // Incluse Header as True and RecalcLine as False.
        PurchaseHeader.Validate("Vendor Cr. Memo No.", PurchaseHeader."No.");
        PurchaseHeader.Modify(true);
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));  // Post as receive and invoice.
    end;

    local procedure CreateAndPostPurchaseInvoiceWithJob(var PurchaseLine: Record "Purchase Line"): Code[20]
    var
        GeneralPostingSetup: Record "General Posting Setup";
        JobTask: Record "Job Task";
        PurchaseHeader: Record "Purchase Header";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        CreateJobWithJobsUtil(JobTask);
        LibraryERM.FindGeneralPostingSetup(GeneralPostingSetup);
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        LibraryPurchase.CreatePurchHeader(
          PurchaseHeader, PurchaseHeader."Document Type"::Invoice, CreateVendor(
            VATPostingSetup."VAT Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group"));
        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", CreateGLAccount(
            VATPostingSetup."VAT Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group"), LibraryRandom.RandDec(10, 2));  // Use random Quantity.
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDec(100, 2));  // Use random Unit Cost.
        PurchaseLine.Validate("Job No.", JobTask."Job No.");
        PurchaseLine.Validate("Job Task No.", JobTask."Job Task No.");
        PurchaseLine.Modify(true);
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));  // Post as receive and invoice.
    end;

    local procedure CreateAndPostSalesInvoice(var SalesHeader: Record "Sales Header"): Code[20]
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, CreateCustomer);
        LibrarySales.CreateSalesLine(
          SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItem(Item), LibraryRandom.RandDec(10, 2));  // Use Random Quantity.
        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(100, 2));  // Use random Unit Price.
        SalesLine.Modify(true);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));  // Post as ship and invoice.
    end;

    local procedure CreateCustomer(): Code[20]
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Payment Method Code", FindPaymentMethod);
        Customer.Modify(true);
        exit(Customer."No.");
    end;

    local procedure CreateGeneralJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        LibraryERM.FindGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch.Validate("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"G/L Account");
        GenJournalBatch.Validate("Bal. Account No.", CreateGLAccount('', ''));  // VAT Prod Posting Group and Gen. Prod posting group as blank.
        GenJournalBatch.Modify(true);
    end;

    local procedure CreateGLAccount(VATProdPostingGroup: Code[20]; GenProductPostingGroup: Code[20]): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Gen. Prod. Posting Group", GenProductPostingGroup);
        GLAccount.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        GLAccount.Modify(true);
        exit(GLAccount."No.");
    end;

    local procedure CreateJobWithJobsUtil(var JobTask: Record "Job Task")
    var
        Job: Record Job;
    begin
        LibraryJob.CreateJob(Job);
        LibraryJob.CreateJobTask(Job, JobTask);
    end;

    local procedure CreateVendor(VATBusPostingGroup: Code[20]; GenBusPostingGroup: Code[20]): Code[20]
    var
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Gen. Bus. Posting Group", GenBusPostingGroup);
        Vendor.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        Vendor.Modify(true);
        exit(Vendor."No.");
    end;

    local procedure CreateCompInfoWithFiscalCodeAndVATRegNo(var CompanyInformation: Record "Company Information"; FiscalCode: Code[20]; VATRegistrationNo: Text[20])
    begin
        with CompanyInformation do begin
            Get;
            "Fiscal Code" := FiscalCode;
            "VAT Registration No." := VATRegistrationNo;
            Modify;
        end;
    end;

    local procedure CreateVendorWithFiscalCodeAndVATRegNo(var Vendor: Record Vendor; FiscalCode: Code[20]; VATRegistrationNo: Text[20])
    begin
        with Vendor do begin
            Init;
            "Fiscal Code" := FiscalCode;
            "VAT Registration No." := VATRegistrationNo;
            Insert;
        end;
    end;

    local procedure EnqueueValuesForHandler(PostingDate: Date; No: Code[20])
    begin
        LibraryVariableStorage.Enqueue(PostingDate);
        LibraryVariableStorage.Enqueue(No);
    end;

    local procedure FindBill(): Code[20]
    var
        Bill: Record Bill;
    begin
        Bill.SetRange("Allow Issue", true);
        Bill.FindFirst;
        exit(Bill.Code);
    end;

    local procedure FindPaymentMethod(): Code[10]
    var
        PaymentMethod: Record "Payment Method";
    begin
        PaymentMethod.SetRange("Bill Code", FindBill);
        LibraryERM.FindPaymentMethod(PaymentMethod);
        exit(PaymentMethod.Code);
    end;

    local procedure UpdateGeneralLedgerSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get;
        GeneralLedgerSetup.Validate("Allow Posting From", WorkDate);
        GeneralLedgerSetup.Validate("Allow Posting To", WorkDate);
        GeneralLedgerSetup.Validate("Last Gen. Jour. Printing Date", 0D);
        GeneralLedgerSetup.Modify(true);
    end;

    local procedure VerifyJobLedgerEntry(DocumentNo: Code[20]; No: Code[20]; Quantity: Decimal; UnitCost: Decimal; TotalCost: Decimal)
    var
        JobLedgerEntry: Record "Job Ledger Entry";
    begin
        JobLedgerEntry.SetRange("Document No.", DocumentNo);
        JobLedgerEntry.SetRange("No.", No);
        JobLedgerEntry.FindFirst;
        JobLedgerEntry.TestField(Quantity, Quantity);
        JobLedgerEntry.TestField("Unit Cost", UnitCost);
        JobLedgerEntry.TestField("Total Cost", TotalCost);
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure AccountBookPrintRequestPageHandler(var AccountBookSheetPrint: TestRequestPage "Account Book Sheet - Print")
    var
        DateFilter: Variant;
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(DateFilter);
        LibraryVariableStorage.Dequeue(No);
        AccountBookSheetPrint."G/L Account".SetFilter("No.", No);
        AccountBookSheetPrint."G/L Account".SetFilter("Date Filter", Format(DateFilter));
        AccountBookSheetPrint.ProgressiveBalance.SetValue(true);
        AccountBookSheetPrint.ShowAmountsInAddReportingCurrency.SetValue(true);
        AccountBookSheetPrint.SaveAsXml(LibraryReportDataset.GetParametersFileName, LibraryReportDataset.GetFileName);
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure IssuingCustomerBillRequestPageHandler(var IssuingCustomerBill: TestRequestPage "Issuing Customer Bill")
    var
        DocumentNo: Variant;
        PostingDate: Variant;
    begin
        LibraryVariableStorage.Dequeue(PostingDate);
        LibraryVariableStorage.Dequeue(DocumentNo);
        IssuingCustomerBill."Cust. Ledger Entry".SetFilter("Document No.", DocumentNo);
        IssuingCustomerBill.PostingDescription.SetValue(Format(PostingDate));
        IssuingCustomerBill.DoNotCheckDimensions.SetValue(true);
        IssuingCustomerBill.PostingDate.SetValue(PostingDate);
        IssuingCustomerBill.DocumentDate.SetValue(PostingDate);
        IssuingCustomerBill.OK.Invoke;
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MessageHandler(Message: Text[1024])
    begin
        Assert.IsTrue(StrPos(Message, CustomerBillMsg) > 0, ValueMatchErr);
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;
}
