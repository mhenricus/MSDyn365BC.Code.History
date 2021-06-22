codeunit 141008 "UT PAG Bank Deposit"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Deposit] [UI]
    end;

    var
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        LibraryUTUtility: Codeunit "Library UT Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        ValueMustExistMsg: Label 'Value must exist.';
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        PostingDateErr: Label 'Validation error for Field: Posting Date,  Message = ''Posting Date must have a value in Deposit Header: No.=%1. It cannot be zero or empty. (Select Refresh to discard errors)''';

    [Test]
    [HandlerFunctions('DepositTestReportRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnActionTestReportDeposits()
    var
        GenJournalLine: Record "Gen. Journal Line";
        DepositHeader: Record "Deposit Header";
        Deposits: TestPage Deposits;
    begin
        // Purpose of the test is to validate TestReport - OnAction trigger of the Page ID: 36646, Deposits.
        // Setup.
        Initialize;
        CreateDepositHeader(DepositHeader);
        CreateGenJournalLine(GenJournalLine, DepositHeader, GenJournalLine."Account Type"::"G/L Account", CreateGLAccount);
        LibraryVariableStorage.Enqueue(DepositHeader."No.");  // Enqueue value for use in DepositTestReportRequestPageHandler.

        // Exercise & Verify: Verify the Deposit Test Report after calling action Test Report on Deposits page through DepositTestReportRequestPageHandler.
        Deposits.OpenEdit;
        Deposits.GotoRecord(DepositHeader);
        Deposits.TestReport.Invoke;  // Invokes DepositTestReportRequestPageHandler.
        Deposits.Close;
    end;

    [Test]
    [HandlerFunctions('DimensionSetEntriesPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnActionDimensionsPostedDepositList()
    var
        PostedDepositHeader: Record "Posted Deposit Header";
        PostedDepositLine: Record "Posted Deposit Line";
        PostedDepositList: TestPage "Posted Deposit List";
    begin
        // Purpose of the test is to validate Dimensions - OnAction trigger of the Page ID: 10147, Posted Deposit List.
        // Setup.
        Initialize;
        CreatePostedDepositForCustomer(PostedDepositHeader, PostedDepositLine);
        UpdateDimensionOnPostedDepositHeader(PostedDepositHeader, CreateDimension);

        // Exercise & Verify: Verify the Dimensions on Posted Deposits List page through DimensionSetEntriesPageHandler.
        PostedDepositList.OpenEdit;
        PostedDepositList.GotoRecord(PostedDepositHeader);
        PostedDepositList.Dimensions.Invoke;  // Invokes DimensionSetEntriesPageHandler.
        PostedDepositList.Close;
    end;

    [Test]
    [HandlerFunctions('DimensionSetEntriesPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnActionDimensionsPostedDepositSubform()
    var
        PostedDepositHeader: Record "Posted Deposit Header";
        PostedDepositLine: Record "Posted Deposit Line";
        PostedDepositSubform: Page "Posted Deposit Subform";
    begin
        // Purpose of the test is to validate Dimensions - OnAction trigger of the Page ID: 10144, Posted Deposit Subform.
        // Setup.
        Initialize;
        CreatePostedDepositForCustomer(PostedDepositHeader, PostedDepositLine);
        PostedDepositLine."Dimension Set ID" := CreateDimension;
        PostedDepositLine.Modify();

        // Exercise & Verify: Verify the Dimensions on Posted Deposits Subform page through DimensionSetEntriesPageHandler.
        PostedDepositSubform.SetRecord(PostedDepositLine);
        PostedDepositSubform.ShowDimensions();  // Invokes DimensionSetEntriesPageHandler.
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnActionAccountLedgerEntriesPostedDepositSubform()
    var
        PostedDepositHeader: Record "Posted Deposit Header";
        PostedDepositLine: Record "Posted Deposit Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PostedDepositSubform: Page "Posted Deposit Subform";
        CustomerLedgerEntries: TestPage "Customer Ledger Entries";
    begin
        // Purpose of the test is to validate AccountLedgerEntries - OnAction trigger of the Page ID: 10144, Posted Deposit Subform.
        // Setup.
        Initialize;
        CreatePostedDepositForCustomer(PostedDepositHeader, PostedDepositLine);
        CreatePostedSalesInvoiceLine(PostedDepositLine."Account No.");
        CreateCustomerLedgerEntry(CustLedgerEntry, PostedDepositLine."Document No.", PostedDepositLine."Account No.");
        CreateDetailedCustomerLedgerEntry(CustLedgerEntry."Entry No.", PostedDepositLine."Account No.");

        // Exercise: Show Account Ledger Entries.
        PostedDepositSubform.SetRecord(PostedDepositLine);
        CustomerLedgerEntries.Trap;
        PostedDepositSubform.ShowAccountLedgerEntries;

        // Verify: Verify Customer No and Amount on the Customer Ledger Entries.
        CustomerLedgerEntries."Customer No.".AssertEquals(PostedDepositLine."Account No.");
        CustomerLedgerEntries.Amount.AssertEquals(PostedDepositLine.Amount);
        CustomerLedgerEntries.Close;
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnActionAccountCardPostedDepositSubform()
    var
        PostedDepositHeader: Record "Posted Deposit Header";
        PostedDepositLine: Record "Posted Deposit Line";
        PostedDepositSubform: Page "Posted Deposit Subform";
        CustomerCard: TestPage "Customer Card";
    begin
        // Purpose of the test is to validate AccountCard - OnAction trigger of the Page ID: 10144, Posted Deposit Subform.
        // Setup.
        Initialize;
        CreatePostedDepositForCustomer(PostedDepositHeader, PostedDepositLine);
        LibraryVariableStorage.Enqueue(PostedDepositLine."Account No.");  // Enqueue values for use in CustomerCardPageHandler.

        // Exercise: Show Account Card - Customer Card.
        PostedDepositSubform.SetRecord(PostedDepositLine);
        CustomerCard.Trap;
        PostedDepositSubform.ShowAccountCard;

        // Verify: Verify Customer No on Customer Card.
        CustomerCard."No.".AssertEquals(PostedDepositLine."Account No.");
        CustomerCard.Close;
    end;

    [Test]
    [HandlerFunctions('DepositRequestPageHandler')]
    [Scope('OnPrem')]
    procedure OnActionPrintPostedDeposit()
    var
        PostedDepositHeader: Record "Posted Deposit Header";
        PostedDepositLine: Record "Posted Deposit Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PostedDeposit: TestPage "Posted Deposit";
    begin
        // Purpose of the test is to validate Print - OnAction trigger of the Page ID: 10143, Posted Deposit.
        // Setup.
        Initialize;
        CreatePostedDepositForCustomer(PostedDepositHeader, PostedDepositLine);
        CreatePostedSalesInvoiceLine(PostedDepositLine."Account No.");
        CreateCustomerLedgerEntry(CustLedgerEntry, PostedDepositLine."Document No.", PostedDepositLine."Account No.");
        CreateDetailedCustomerLedgerEntry(CustLedgerEntry."Entry No.", PostedDepositLine."Account No.");
        LibraryVariableStorage.Enqueue(PostedDepositHeader."No.");  // Enqueue values for use in DepositRequestPageHandler.
        Commit();  // Explicit Commit Required, because explicit commit used in Codeunit ID: 10143, Deposit-Printed.

        // Exercise & Verify: Verify the Account Ledger Entries on Posted Deposits Subform page through DepositRequestPageHandler.
        OpenPostedDepositPage(PostedDeposit, PostedDepositHeader);
        PostedDeposit.Print.Invoke;  // Invokes DepositRequestPageHandler.
        PostedDeposit.Close;
    end;

    [Test]
    [HandlerFunctions('DimensionSetEntriesPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnActionDimensionsPostedDeposit()
    var
        PostedDepositHeader: Record "Posted Deposit Header";
        PostedDepositLine: Record "Posted Deposit Line";
        PostedDeposit: TestPage "Posted Deposit";
    begin
        // Purpose of the test is to validate Dimensions - OnAction trigger of the Page ID: 10143, Posted Deposit.
        // Setup.
        Initialize;
        CreatePostedDepositForCustomer(PostedDepositHeader, PostedDepositLine);
        UpdateDimensionOnPostedDepositHeader(PostedDepositHeader, CreateDimension);

        // Exercise & Verify: Verify the Dimension on Posted Deposit page through DimensionSetEntriesPageHandler.
        OpenPostedDepositPage(PostedDeposit, PostedDepositHeader);
        PostedDeposit.Dimensions.Invoke;  // Invokes DimensionSetEntriesPageHandler.
        PostedDeposit.Close;
    end;

    [Test]
    [HandlerFunctions('GeneralJournalTemplateListPageHandler,EditDimensionSetEntriesPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnActionDimensionsDepositSubform()
    var
        GenJournalLine: Record "Gen. Journal Line";
        DepositHeader: Record "Deposit Header";
        Deposit: TestPage Deposit;
    begin
        // Purpose of the test is to validate Dimensions - OnAction trigger of the Page ID: 10141, Deposit Subform.
        // Setup.
        Initialize;
        CreateDepositHeader(DepositHeader);
        CreateGenJournalLine(GenJournalLine, DepositHeader, GenJournalLine."Account Type"::Customer, CreateCustomer);

        // Exercise: Update the Dimension on Deposit Subform page through EditDimensionSetEntriesPageHandler.
        OpenDepositSubForm(Deposit, GenJournalLine);
        Deposit.Subform.Dimensions.Invoke;  // Invokes EditDimensionSetEntriesPageHandler.
        Deposit.Close;

        // Verify: Verify Dimension Set ID on Gen. Journal Line.
        GenJournalLine.Get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name", GenJournalLine."Line No.");
        GenJournalLine.TestField("Dimension Set ID");
    end;

    [Test]
    [HandlerFunctions('GeneralJournalTemplateListPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnActionAccountCardDepositSubform()
    var
        GenJournalLine: Record "Gen. Journal Line";
        DepositHeader: Record "Deposit Header";
        Deposit: TestPage Deposit;
        CustomerCard: TestPage "Customer Card";
    begin
        // Purpose of the test is to validate AccountCard - OnAction trigger of the Page ID: 10141, Deposit Subform.
        // Setup.
        Initialize;
        CreateDepositHeader(DepositHeader);
        CreateGenJournalLine(GenJournalLine, DepositHeader, GenJournalLine."Account Type"::Customer, CreateCustomer);
        LibraryVariableStorage.Enqueue(GenJournalLine."Account No.");  // Enqueue values for use in CustomerCardPageHandler.

        // Exercise: Show Customer Card.
        OpenDepositSubForm(Deposit, GenJournalLine);
        CustomerCard.Trap;
        Deposit.Subform.AccountCard.Invoke;

        // Verify: Verify Customer Number on Customer Card.
        CustomerCard."No.".AssertEquals(GenJournalLine."Account No.");
        CustomerCard.Close;
        Deposit.Close;
    end;

    [Test]
    [HandlerFunctions('GeneralJournalTemplateListPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnActionAccountLedgerEntriesDepositSubform()
    var
        GenJournalLine: Record "Gen. Journal Line";
        DepositHeader: Record "Deposit Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Deposit: TestPage Deposit;
        CustomerLedgerEntries: TestPage "Customer Ledger Entries";
    begin
        // Purpose of the test is to validate AccountLedgerEntries - OnAction trigger of the Page ID: 10141, Deposit Subform.
        // Setup.
        Initialize;
        CreateDepositHeader(DepositHeader);
        CreateGenJournalLine(GenJournalLine, DepositHeader, GenJournalLine."Account Type"::Customer, CreateCustomer);
        CreatePostedSalesInvoiceLine(GenJournalLine."Account No.");
        CreateCustomerLedgerEntry(CustLedgerEntry, GenJournalLine."Document No.", GenJournalLine."Account No.");
        CreateDetailedCustomerLedgerEntry(CustLedgerEntry."Entry No.", GenJournalLine."Account No.");

        // Exercise: Open Customer Ledger Entries
        OpenDepositSubForm(Deposit, GenJournalLine);
        CustomerLedgerEntries.Trap;
        Deposit.Subform.AccountLedgerEntries.Invoke;  // Invokes CustomerLedgerEntriesPageHandler.

        // Verify: Verify the Customer Ledger Entries.
        CustomerLedgerEntries."Customer No.".AssertEquals(CustLedgerEntry."Customer No.");
        CustomerLedgerEntries.Amount.AssertEquals(CustLedgerEntry.Amount);
        CustomerLedgerEntries.OK.Invoke;
        Deposit.Close;
    end;

    [Test]
    [HandlerFunctions('GeneralJournalTemplateListPageHandler,ApplyCustomerEntriesPageHandler')]
    [Scope('OnPrem')]
    procedure OnActionApplyEntriesDepositSubform()
    var
        GenJournalLine: Record "Gen. Journal Line";
        DepositHeader: Record "Deposit Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Deposit: TestPage Deposit;
    begin
        // Purpose of the test is to validate ApplyEntries - OnAction trigger of the Page ID: 10141, Deposit Subform.
        // Setup.
        Initialize;
        CreateDepositHeader(DepositHeader);
        CreateGenJournalLine(GenJournalLine, DepositHeader, GenJournalLine."Account Type"::Customer, CreateCustomer);
        CreatePostedSalesInvoiceLine(GenJournalLine."Account No.");
        CreateCustomerLedgerEntry(CustLedgerEntry, GenJournalLine."Document No.", GenJournalLine."Account No.");
        CreateDetailedCustomerLedgerEntry(CustLedgerEntry."Entry No.", GenJournalLine."Account No.");

        // Enqueue values for use in ApplyCustomerEntriesPageHandler.
        CustLedgerEntry.CalcFields("Remaining Amount");
        LibraryVariableStorage.Enqueue(GenJournalLine."Account No.");
        LibraryVariableStorage.Enqueue(CustLedgerEntry."Remaining Amount");

        // Exercise & Verify: Verify the Apply Customer Entries on Deposit Subform page through ApplyCustomerEntriesPageHandler.
        OpenDepositSubForm(Deposit, GenJournalLine);
        Deposit.Subform.ApplyEntries.Invoke;  // Invokes ApplyCustomerEntriesPageHandler.
        Deposit.Close;
    end;

    [Test]
    [HandlerFunctions('GeneralJournalTemplateListPageHandler,ConfirmHandlerTRUE')]
    [Scope('OnPrem')]
    procedure OnActionPostDeposit()
    var
        GenJournalLine: Record "Gen. Journal Line";
        DepositHeader: Record "Deposit Header";
        PostedDepositHeader: Record "Posted Deposit Header";
        Deposit: TestPage Deposit;
    begin
        // Purpose of the test is to validate Post - OnAction trigger of the Page ID: 10140, Deposit. Transaction model is AutoCommit for explicit commit used in Codeunit ID: 10140, Deposit-Post.
        // Setup.
        Initialize;
        CreateDepositHeader(DepositHeader);
        CreateGenJournalLine(GenJournalLine, DepositHeader, GenJournalLine."Account Type"::"G/L Account", CreateGLAccount);

        // Exercise.
        OpenDepositPage(Deposit, DepositHeader);
        Deposit.Post.Invoke;

        // Verify: Verify the Posted Deposit exist after posting Deposit.
        Assert.IsTrue(PostedDepositHeader.Get(DepositHeader."No."), ValueMustExistMsg);
    end;

    [Test]
    [HandlerFunctions('GeneralJournalTemplateListPageHandler,DepositTestReportRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnActionDepositTestReportDeposit()
    var
        DepositHeader: Record "Deposit Header";
        Deposit: TestPage Deposit;
    begin
        // Purpose of the test is to validate DepositTestReport - OnAction trigger of the Page ID: 10140, Deposit.
        // Setup.
        Initialize;
        CreateDepositHeader(DepositHeader);
        LibraryVariableStorage.Enqueue(DepositHeader."No.");  // Enqueue values for use in DepositTestReportRequestPageHandler.

        // Exercise & verify: Verify the Deposit Test Report run from Deposit page through DepositTestReportRequestPageHandler.
        OpenDepositPage(Deposit, DepositHeader);
        Deposit."Test Report".Invoke;  // Invokes DepositTestReportRequestPageHandler.
        Deposit.Close;
    end;

    [Test]
    [HandlerFunctions('GeneralJournalTemplateListPageHandler,DepositReportHandler,ConfirmHandlerTRUE')]
    [Scope('OnPrem')]
    procedure OnActionPostAndPrintDeposit()
    var
        GenJournalLine: Record "Gen. Journal Line";
        DepositHeader: Record "Deposit Header";
        PostedDepositHeader: Record "Posted Deposit Header";
        Deposit: TestPage Deposit;
    begin
        // Purpose of the test is to validate PostAndPrint - OnAction trigger of the Page ID: 10140, Deposit. Transaction model is AutoCommit for explicit commit used in Codeunit ID: 10140, Deposit-Post.
        // Setup.
        Initialize;
        CreateDepositHeader(DepositHeader);
        CreateGenJournalLine(GenJournalLine, DepositHeader, GenJournalLine."Account Type"::"G/L Account", CreateGLAccount);

        // Exercise.
        OpenDepositPage(Deposit, DepositHeader);
        Deposit.PostAndPrint.Invoke;  // Invokes DepositReportHandler.

        // Verify: Verify the Posted Deposit Header exist after Post and Print of Deposit.
        Assert.IsTrue(PostedDepositHeader.Get(DepositHeader."No."), ValueMustExistMsg);
    end;

    [Test]
    [HandlerFunctions('GeneralJournalTemplateListPageHandler,EditDimensionSetEntriesPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnActionDimensionsDeposit()
    var
        DepositHeader: Record "Deposit Header";
        Deposit: TestPage Deposit;
    begin
        // Purpose of the test is to validate Dimensions - OnAction trigger of the Page ID: 10140, Deposit.
        // Setup.
        Initialize;
        CreateDepositHeader(DepositHeader);

        // Exercise: Update the Dimension on Deposit page through EditDimensionSetEntriesPageHandler.
        OpenDepositPage(Deposit, DepositHeader);
        Deposit.Dimensions.Invoke;  // Invokes EditDimensionSetEntriesPageHandler.
        Deposit.Close;

        // Verify: Verify Dimension Set ID on Deposit Header.
        DepositHeader.Get(DepositHeader."No.");
        DepositHeader.TestField("Dimension Set ID");
    end;

    [Test]
    [HandlerFunctions('GeneralJournalTemplateListPageHandler')]
    [Scope('OnPrem')]
    procedure TotalDepositLinesControlIsUpdatedWhenCreateDepositLine()
    var
        DepositHeader: Record "Deposit Header";
        Deposit: TestPage Deposit;
        CreditAmount: Decimal;
    begin
        // [SCENARIO 218101] 'Total Deposit Lines' and Difference controls are updated when Credit Amount is updated on Deposit Subpage
        Initialize;

        // [GIVEN] Deposit page is opened with 'Total Deposit Amount' = 100
        CreateDepositHeader(DepositHeader);

        DepositHeader.Validate("Total Deposit Amount", LibraryRandom.RandDecInRange(100, 200, 2));
        DepositHeader.Modify(true);
        OpenDepositPage(Deposit, DepositHeader);

        // [WHEN] Set Credit Amount = 20
        CreditAmount := LibraryRandom.RandDec(10, 2);
        Deposit.Subform."Credit Amount".SetValue(CreditAmount);

        // [THEN] 'Total Deposit Lines' is updated with 20
        // [THEN] 'Difference' is updated with 80
        Deposit."Total Deposit Lines".AssertEquals(CreditAmount);
        Deposit.Difference.AssertEquals(DepositHeader."Total Deposit Amount" - CreditAmount);
    end;

    [Test]
    [HandlerFunctions('GeneralJournalTemplateListPageHandler')]
    [Scope('OnPrem')]
    procedure CloseDepositPageWithEmptyPostingDate()
    var
        DepositHeader: Record "Deposit Header";
        Deposit: TestPage Deposit;
    begin
        // [FEATURE] [Posting Date]
        // [SCENARIO 317751] User can validate an empty Posting Date on a Deposit Card
        Initialize;

        // [GIVEN] Created a Deposit Header and opened its Deposit Card
        CreateDepositHeader(DepositHeader);
        OpenDepositPage(Deposit, DepositHeader);

        // [WHEN] Try to validate an empty Posting Date
        asserterror Deposit."Posting Date".Value := '';

        // [THEN] Error is thrown: "Validation error for Field: Posting Date,  Message = 'Posting Date must have a value.."
        Assert.ExpectedError(StrSubstNo(PostingDateErr, DepositHeader."No."));
        LibraryVariableStorage.AssertEmpty;
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear;
    end;

    local procedure CreateDepositHeader(var DepositHeader: Record "Deposit Header")
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalBatch2: Record "Gen. Journal Batch";
    begin
        CreateGenJournalBatch(GenJournalBatch2);  // Create multiple General Journal Template and Batch to open GeneralJournalTemplateListPageHandler.
        CreateGenJournalBatch(GenJournalBatch);
        DepositHeader."No." := LibraryUTUtility.GetNewCode;
        DepositHeader."Journal Template Name" := GenJournalBatch."Journal Template Name";
        DepositHeader."Journal Batch Name" := GenJournalBatch.Name;
        DepositHeader."Posting Date" := WorkDate;
        DepositHeader."Document Date" := WorkDate;
        DepositHeader."Bank Account No." := CreateBankAccount;
        DepositHeader."Total Deposit Amount" := LibraryRandom.RandDec(10, 2);
        DepositHeader.Insert();
        LibraryVariableStorage.Enqueue(DepositHeader."Journal Template Name");  // Enqueue value in GeneralJournalTemplateListPageHandler.
    end;

    local procedure CreatePostedDepositForCustomer(var PostedDepositHeader: Record "Posted Deposit Header"; var PostedDepositLine: Record "Posted Deposit Line")
    begin
        PostedDepositHeader."No." := LibraryUTUtility.GetNewCode;
        PostedDepositHeader.Insert();

        PostedDepositLine."Deposit No." := PostedDepositHeader."No.";
        PostedDepositLine."Line No." := LibraryRandom.RandInt(10);
        PostedDepositLine."Account Type" := PostedDepositLine."Account Type"::Customer;
        PostedDepositLine."Document Type" := PostedDepositLine."Document Type"::Payment;
        PostedDepositLine."Account No." := CreateCustomer;
        PostedDepositLine.Insert();
    end;

    local procedure CreateGenJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.Name := LibraryUTUtility.GetNewCode10;
        GenJournalTemplate.Type := GenJournalTemplate.Type::Deposits;
        GenJournalTemplate."Page ID" := PAGE::Deposit;
        GenJournalTemplate.Insert();

        GenJournalBatch."Journal Template Name" := GenJournalTemplate.Name;
        GenJournalBatch.Name := LibraryUTUtility.GetNewCode10;
        GenJournalBatch.Insert();
    end;

    local procedure CreateGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; DepositHeader: Record "Deposit Header"; AccountType: Option; AccountNo: Code[20])
    begin
        GenJournalLine."Journal Template Name" := DepositHeader."Journal Template Name";
        GenJournalLine."Journal Batch Name" := DepositHeader."Journal Batch Name";
        GenJournalLine."Line No." := LibraryRandom.RandInt(10);
        GenJournalLine."Posting Date" := WorkDate;
        GenJournalLine."Document Type" := GenJournalLine."Document Type"::Payment;
        GenJournalLine."Account Type" := AccountType;
        GenJournalLine."Account No." := AccountNo;
        GenJournalLine.Amount := -DepositHeader."Total Deposit Amount";
        GenJournalLine."Document No." := LibraryUTUtility.GetNewCode;
        GenJournalLine.Insert();
    end;

    local procedure CreateBankAccount(): Code[20]
    var
        BankAccountPostingGroup: Record "Bank Account Posting Group";
        BankAccount: Record "Bank Account";
    begin
        BankAccountPostingGroup.FindFirst;
        BankAccount."No." := LibraryUTUtility.GetNewCode;
        BankAccount."Bank Acc. Posting Group" := BankAccountPostingGroup.Code;
        BankAccount.Insert();
        exit(BankAccount."No.");
    end;

    local procedure CreateGLAccount(): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount."No." := LibraryUTUtility.GetNewCode;
        GLAccount.Insert();
        exit(GLAccount."No.");
    end;

    local procedure CreateCustomer(): Code[20]
    var
        Customer: Record Customer;
    begin
        Customer."No." := LibraryUTUtility.GetNewCode;
        Customer.Insert(true);
        exit(Customer."No.");
    end;

    local procedure CreateDimension() DimensionSetID: Integer
    var
        DimensionValue: Record "Dimension Value";
        Dimension: Record Dimension;
    begin
        Dimension.Code := LibraryUTUtility.GetNewCode;
        Dimension.Insert();
        DimensionValue.Code := LibraryUTUtility.GetNewCode;
        DimensionValue."Dimension Code" := Dimension.Code;
        DimensionValue.Insert();
        DimensionSetID := CreateDimensionSetEntry(DimensionValue."Dimension Code", DimensionValue.Code);
        LibraryVariableStorage.Enqueue(DimensionValue."Dimension Code");  // Enqueue value for Page Handler - EditDimensionSetEntriesPageHandler or DimensionSetEntriesPageHandler.
    end;

    local procedure CreateDimensionSetEntry(DimensionCode: Code[20]; DimensionValueCode: Code[20]): Integer
    var
        DimensionSetEntry: Record "Dimension Set Entry";
        DimensionSetEntry2: Record "Dimension Set Entry";
    begin
        DimensionSetEntry2.FindLast;
        DimensionSetEntry."Dimension Set ID" := DimensionSetEntry2."Dimension Set ID" + 1;
        DimensionSetEntry."Dimension Code" := DimensionCode;
        DimensionSetEntry."Dimension Value Code" := DimensionValueCode;
        DimensionSetEntry."Dimension Value ID" := DimensionSetEntry."Dimension Set ID";
        DimensionSetEntry.Insert();
        exit(DimensionSetEntry."Dimension Set ID");
    end;

    local procedure CreateCustomerLedgerEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; DocumentNo: Code[20]; CustomerNo: Code[20])
    var
        CustLedgerEntry2: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry2.FindLast;
        CustLedgerEntry."Entry No." := CustLedgerEntry2."Entry No." + 1;
        CustLedgerEntry."Document Type" := CustLedgerEntry."Document Type"::Invoice;
        CustLedgerEntry."Document No." := DocumentNo;
        CustLedgerEntry.Open := true;
        CustLedgerEntry."Customer No." := CustomerNo;
        CustLedgerEntry.Insert();
    end;

    local procedure CreateDetailedCustomerLedgerEntry(CustLedgerEntryNo: Integer; CustomerNo: Code[20])
    var
        DetailedCustomerLedgEntry: Record "Detailed Cust. Ledg. Entry";
        DetailedCustomerLedgEntry2: Record "Detailed Cust. Ledg. Entry";
    begin
        DetailedCustomerLedgEntry2.FindLast;
        DetailedCustomerLedgEntry."Entry No." := DetailedCustomerLedgEntry2."Entry No." + 1;
        DetailedCustomerLedgEntry."Cust. Ledger Entry No." := CustLedgerEntryNo;
        DetailedCustomerLedgEntry."Customer No." := CustomerNo;
        DetailedCustomerLedgEntry.Amount := LibraryRandom.RandDec(10, 2);
        DetailedCustomerLedgEntry.Insert();
    end;

    local procedure CreatePostedSalesInvoiceLine(SellToCustomerNo: Code[20])
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceLine."Document No." := LibraryUTUtility.GetNewCode;
        SalesInvoiceLine."Sell-to Customer No." := SellToCustomerNo;
        SalesInvoiceLine."Unit Price" := LibraryRandom.RandDec(10, 2);
        SalesInvoiceLine.Insert();
    end;

    local procedure OpenDepositPage(var Deposit: TestPage Deposit; DepositHeader: Record "Deposit Header")
    begin
        Deposit.OpenEdit;
        Deposit.GotoRecord(DepositHeader);
    end;

    local procedure OpenDepositSubForm(var Deposit: TestPage Deposit; GenJournalLine: Record "Gen. Journal Line")
    begin
        Deposit.OpenEdit;
        Deposit.Subform.GotoRecord(GenJournalLine);
    end;

    local procedure OpenPostedDepositPage(var PostedDeposit: TestPage "Posted Deposit"; PostedDepositHeader: Record "Posted Deposit Header")
    begin
        PostedDeposit.OpenEdit;
        PostedDeposit.GotoRecord(PostedDepositHeader);
    end;

    local procedure UpdateDimensionOnPostedDepositHeader(var PostedDepositHeader: Record "Posted Deposit Header"; DimensionSetID: Integer)
    begin
        PostedDepositHeader."Dimension Set ID" := DimensionSetID;
        PostedDepositHeader.Modify();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure EditDimensionSetEntriesPageHandler(var EditDimensionSetEntries: TestPage "Edit Dimension Set Entries")
    var
        DimensionValue: Record "Dimension Value";
    begin
        DimensionValue.SetRange("Global Dimension No.", 1);  // Global Dimension - 1.
        DimensionValue.FindFirst;
        EditDimensionSetEntries."Dimension Code".SetValue(DimensionValue."Dimension Code");
        EditDimensionSetEntries.DimensionValueCode.SetValue(DimensionValue.Code);
        EditDimensionSetEntries.OK.Invoke;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure DimensionSetEntriesPageHandler(var DimensionSetEntries: TestPage "Dimension Set Entries")
    var
        DimensionCode: Variant;
    begin
        LibraryVariableStorage.Dequeue(DimensionCode);
        DimensionSetEntries."Dimension Code".AssertEquals(DimensionCode);
        DimensionSetEntries.OK.Invoke;
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure DepositRequestPageHandler(var Deposit: TestRequestPage Deposit)
    var
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        Deposit."Posted Deposit Header".SetFilter("No.", No);
        Deposit.SaveAsXml(LibraryReportDataset.GetParametersFileName, LibraryReportDataset.GetFileName);
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure DepositTestReportRequestPageHandler(var DepositTestReport: TestRequestPage "Deposit Test Report")
    var
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        DepositTestReport."Deposit Header".SetFilter("No.", No);
        DepositTestReport.SaveAsXml(LibraryReportDataset.GetParametersFileName, LibraryReportDataset.GetFileName);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ApplyCustomerEntriesPageHandler(var ApplyCustomerEntries: TestPage "Apply Customer Entries")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustomerNo: Variant;
        RemainingAmount: Variant;
    begin
        LibraryVariableStorage.Dequeue(CustomerNo);
        LibraryVariableStorage.Dequeue(RemainingAmount);
        ApplyCustomerEntries."Document Type".AssertEquals(CustLedgerEntry."Document Type"::Invoice);
        ApplyCustomerEntries."Customer No.".AssertEquals(CustomerNo);
        ApplyCustomerEntries."Remaining Amount".AssertEquals(RemainingAmount);
        ApplyCustomerEntries.OK.Invoke;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure GeneralJournalTemplateListPageHandler(var GeneralJournalTemplateList: TestPage "General Journal Template List")
    var
        Name: Variant;
    begin
        LibraryVariableStorage.Dequeue(Name);
        GeneralJournalTemplateList.FILTER.SetFilter(Name, Name);
        GeneralJournalTemplateList.OK.Invoke;
    end;

    [ReportHandler]
    [Scope('OnPrem')]
    procedure DepositReportHandler(var Deposit: Report Deposit)
    begin
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandlerTRUE(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;
}
