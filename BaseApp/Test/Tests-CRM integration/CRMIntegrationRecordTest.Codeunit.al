codeunit 139161 "CRM Integration Record Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [CRM Integration] [CRM Integration Record]
    end;

    var
        Assert: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        LibraryCRMIntegration: Codeunit "Library - CRM Integration";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";

    [Test]
    [Scope('OnPrem')]
    procedure SimpleCRMToNAVLookup()
    var
        Customer: Record Customer;
        CRMIntegrationRecord: Record "CRM Integration Record";
        NAVRecordId: RecordID;
        CRMId: Guid;
    begin
        LibraryCRMIntegration.ResetEnvironment;
        LibraryCRMIntegration.ConfigureCRM;
        LibrarySales.CreateCustomer(Customer);

        Assert.IsFalse(
          CRMIntegrationRecord.FindIDFromRecordID(Customer.RecordId, CRMId),
          'Did not expect a CRM Integration record to be created at this time');
        CRMId := CreateGuid;
        CRMIntegrationRecord.CoupleCRMIDToRecordID(CRMId, Customer.RecordId);

        // Verify Lookup
        Assert.IsTrue(
          CRMIntegrationRecord.FindRecordIDFromID(
            CRMId, DATABASE::Customer, NAVRecordId),
          'Expected FindRecordIdFromId to return true');
        Assert.IsTrue(Customer.RecordId = NAVRecordId, 'Expected to find the same record id');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SimpleNAVToCRMLookup()
    var
        Customer: Record Customer;
        CRMIntegrationRecord: Record "CRM Integration Record";
        CRMId: Guid;
        FoundCRMId: Guid;
    begin
        LibraryCRMIntegration.ResetEnvironment;
        LibraryCRMIntegration.ConfigureCRM;

        LibrarySales.CreateCustomer(Customer);

        CRMId := CreateGuid;
        CRMIntegrationRecord.CoupleCRMIDToRecordID(CRMId, Customer.RecordId);

        // Verify Lookup
        Assert.IsTrue(
          CRMIntegrationRecord.FindIDFromRecordID(Customer.RecordId, FoundCRMId),
          'Expected FindIdFromRecordId to return true');
        Assert.IsTrue(CRMId = FoundCRMId, 'Expected to find the same id');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CanCoupleCRMIDToRecord()
    var
        Customer: Record Customer;
        CRMIntegrationRecord: Record "CRM Integration Record";
        CRMID: Guid;
    begin
        LibraryCRMIntegration.ResetEnvironment;

        // [GIVEN] A valid CRM Setup
        LibraryCRMIntegration.CreateCRMConnectionSetup('', 'testhostname.domain.int', true);
        LibrarySales.CreateCustomer(Customer);

        // [GIVEN] A valid Integration ID
        // [GIVEN] A New CRMID
        // [WHEN] Creating a coupling between CRMID and Record
        // [THEN] CRM Integration Record is created
        CRMIntegrationRecord.SetFilter("Integration ID", Customer.SystemId);
        Assert.AreEqual(0, CRMIntegrationRecord.Count, 'Did not expect any couplings to CRM');
        CRMID := CreateGuid;
        CRMIntegrationRecord.Reset();
        CRMIntegrationRecord.CoupleCRMIDToRecordID(CRMID, Customer.RecordId);
        CRMIntegrationRecord.Reset();
        CRMIntegrationRecord.SetFilter("Integration ID", Customer.SystemId);
        Assert.AreEqual(1, CRMIntegrationRecord.Count, 'Expected coupling to be created');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CannotCreateCouplingToAlreadyCoupledRecord()
    var
        Customer: Record Customer;
        CRMIntegrationRecord: Record "CRM Integration Record";
        CRMID: Guid;
        NewCRMID: Guid;
    begin
        LibraryCRMIntegration.ResetEnvironment;
        // [GIVEN] A valid CRM Setup
        // [GIVEN] An existing coupling to a record
        // [GIVEN] A new CRMID
        // [WHEN] Creating a coupling between CRMID and Record
        // [THEN] Error - Already coupled.
        LibraryCRMIntegration.CreateCRMConnectionSetup('', 'testhostname.domain.int', true);
        CRMID := CreateGuid;

        LibrarySales.CreateCustomer(Customer);
        CRMIntegrationRecord.CoupleCRMIDToRecordID(CRMID, Customer.RecordId);

        NewCRMID := CreateGuid;
        asserterror CRMIntegrationRecord.CoupleCRMIDToRecordID(NewCRMID, Customer.RecordId);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CannotUpdateCouplingToAlreadyCoupledRecord()
    var
        Customer: Record Customer;
        NewCustomer: Record Customer;
        CRMIntegrationRecord: Record "CRM Integration Record";
        CRMID: Guid;
    begin
        LibraryCRMIntegration.ResetEnvironment;
        // [GIVEN] A valid CRM Setup
        // [GIVEN] An existing coupling to CRM AccountA from CustomerA
        // [GIVEN] An existing coupling to CRM AccountB from CustomerB
        // [WHEN] Creating a coupling between CustomerB and CRM AccountA
        // [THEN] Error - Already coupled.
        LibraryCRMIntegration.CreateCRMConnectionSetup('', 'testhostname.domain.int', true);
        CRMID := CreateGuid();

        LibrarySales.CreateCustomer(Customer);
        CRMIntegrationRecord.CoupleCRMIDToRecordID(CRMID, Customer.RecordId);

        LibrarySales.CreateCustomer(NewCustomer);
        CRMIntegrationRecord.CoupleCRMIDToRecordID(CreateGuid(), NewCustomer.RecordId);

        asserterror CRMIntegrationRecord.CoupleCRMIDToRecordID(CRMID, NewCustomer.RecordId);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CanCoupleRecordToCRMID()
    var
        Customer: Record Customer;
        CRMIntegrationRecord: Record "CRM Integration Record";
        CRMID: Guid;
    begin
        LibraryCRMIntegration.ResetEnvironment;
        // [GIVEN] A valid CRM Setup
        LibraryCRMIntegration.CreateCRMConnectionSetup('', 'testhostname.domain.int', true);
        LibrarySales.CreateCustomer(Customer);
        CRMID := CreateGuid;

        // [GIVEN] A CRMID
        // [GIVEN] A New Record
        // [WHEN] Creating a coupling between Record and CRMID
        // [THEN] CRM Integration Record is created
        CRMIntegrationRecord.Reset();
        CRMIntegrationRecord.CoupleRecordIdToCRMID(Customer.RecordId, CRMID);
        CRMIntegrationRecord.Reset();
        CRMIntegrationRecord.SetFilter("CRM ID", CRMID);
        Assert.AreEqual(1, CRMIntegrationRecord.Count, 'Expected coupling to be created');

        // [GIVEN] An existing CRMID
        // [GIVEN] New Cutomer record
        // [WHEN] Creating a coupling between Record and CRMID
        // [THEN] CRM Integration Record is updated with the new Integration ID
        CRMID := CreateGuid;
        CRMIntegrationRecord.SetFilter("CRM ID", CRMID);
        Assert.AreEqual(0, CRMIntegrationRecord.Count, 'Did not expect any couplings to CRM for the newly created crm id');

        CRMIntegrationRecord.Reset();
        CRMIntegrationRecord.SetFilter("Integration ID", Customer.SystemId);
        Assert.AreEqual(1, CRMIntegrationRecord.Count, 'Expected coupling to stay');

        CRMIntegrationRecord.CoupleRecordIdToCRMID(Customer.RecordId, CRMID);
        CRMIntegrationRecord.Reset();
        CRMIntegrationRecord.SetFilter("CRM ID", CRMID);
        CRMIntegrationRecord.SetFilter("Integration ID", Customer.SystemId);
        Assert.AreEqual(1, CRMIntegrationRecord.Count, 'Expected coupling to be updated');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CannotCreateCouplingToAlreadyCoupledCRMID()
    var
        Customer: Record Customer;
        NewCustomer: Record Customer;
        CRMIntegrationRecord: Record "CRM Integration Record";
        CRMID: Guid;
    begin
        LibraryCRMIntegration.ResetEnvironment;
        // [GIVEN] A valid CRM Setup
        // [GIVEN] An existing coupling
        // [GIVEN] A new record
        // [WHEN] Creating a coupling between new Record and already coupled CRMID
        // [THEN] Error - Already coupled.
        LibraryCRMIntegration.CreateCRMConnectionSetup('', 'testhostname.domain.int', true);
        LibrarySales.CreateCustomer(Customer);
        CRMID := CreateGuid;
        CRMIntegrationRecord.CoupleRecordIdToCRMID(Customer.RecordId, CRMID);

        CRMIntegrationRecord.Reset();
        LibrarySales.CreateCustomer(NewCustomer);
        asserterror CRMIntegrationRecord.CoupleRecordIdToCRMID(NewCustomer.RecordId, CRMID);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CanCreateCouplingToCRMIDCoupledToDeletedIntegrationRecord()
    var
        Customer: Record Customer;
        NewCustomer: Record Customer;
        CRMIntegrationRecord: Record "CRM Integration Record";
        CRMID: Guid;
    begin
        LibraryCRMIntegration.ResetEnvironment;

        // [GIVEN] A valid CRM setup
        LibraryCRMIntegration.CreateCRMConnectionSetup('', 'testhostname.domain.int', true);
        LibrarySales.CreateCustomer(Customer);
        CRMID := CreateGuid;
        CRMIntegrationRecord.CoupleRecordIdToCRMID(Customer.RecordId, CRMID);

        // [GIVEN] An existing but 'broken' coupling to a deleted NAV entity
        CRMIntegrationRecord.FindByCRMID(CRMID);
        CRMIntegrationRecord.Delete();
        Customer.Delete();
        CRMIntegrationRecord.Insert();

        // [GIVEN] A new record
        LibrarySales.CreateCustomer(NewCustomer);
        // [WHEN] Creating a coupling between the new record and the CRMID in the broken coupling
        CRMIntegrationRecord.CoupleRecordIdToCRMID(NewCustomer.RecordId, CRMID);

        // [THEN] The CRM Integration Record is updated with the new Integration ID
        CRMIntegrationRecord.Reset();
        CRMIntegrationRecord.SetFilter("CRM ID", CRMID);
        CRMIntegrationRecord.SetFilter("Integration ID", NewCustomer.SystemId);
        Assert.AreEqual(1, CRMIntegrationRecord.Count, 'Expected coupling to be updated');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CannotUpdateCouplingToAlreadyCoupledCRMID()
    var
        Customer: Record Customer;
        NewCustomer: Record Customer;
        CRMIntegrationRecord: Record "CRM Integration Record";
        CRMID: Guid;
    begin
        LibraryCRMIntegration.ResetEnvironment;

        // [GIVEN] A valid CRM Setup
        // [GIVEN] An existing coupling to CRM AccountA from CustomerA
        // [GIVEN] An existing coupling to CRM AccountB from CustomerB
        // [WHEN] Creating a coupling between CustomerB and CRM AccountA
        // [THEN] Error - Already coupled.
        LibraryCRMIntegration.CreateCRMConnectionSetup('', 'testhostname.domain.int', true);
        LibrarySales.CreateCustomer(Customer);
        CRMID := CreateGuid;
        CRMIntegrationRecord.CoupleRecordIdToCRMID(Customer.RecordId, CRMID);

        LibrarySales.CreateCustomer(NewCustomer);
        CRMIntegrationRecord.CoupleRecordIdToCRMID(NewCustomer.RecordId, CreateGuid);

        asserterror CRMIntegrationRecord.CoupleRecordIdToCRMID(NewCustomer.RecordId, CRMID);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CanUpdateCouplingToCRMIDCoupledDeletedIntegrationRecord()
    var
        CustomerA: Record Customer;
        CustomerB: Record Customer;
        CRMIntegrationRecord: Record "CRM Integration Record";
        CRMIDA: Guid;
        CRMIDB: Guid;
    begin
        LibraryCRMIntegration.ResetEnvironment;

        // [GIVEN] A valid CRM setup
        // [GIVEN] An existing coupling from CRM AccountA to a deleted CustomerA
        // [GIVEN] An existing coupling to CRM AccountB from CustomerB
        // [WHEN] Creating a coupling between CustomerB and CRM AccountA
        // [THEN] The two CRM Integration Records are replaced by one, coupling CustomerB and CRM AccountA
        LibraryCRMIntegration.CreateCRMConnectionSetup('', 'testhostname.domain.int', true);
        LibrarySales.CreateCustomer(CustomerA);
        CRMIDA := CreateGuid;
        CRMIntegrationRecord.CoupleRecordIdToCRMID(CustomerA.RecordId, CRMIDA);

        LibrarySales.CreateCustomer(CustomerB);
        CRMIDB := CreateGuid;
        CRMIntegrationRecord.CoupleRecordIdToCRMID(CustomerB.RecordId, CRMIDB);

        CRMIntegrationRecord.FindByCRMID(CRMIDA);
        CRMIntegrationRecord.Delete();
        CustomerA.Delete();
        CRMIntegrationRecord.Insert();

        CRMIntegrationRecord.CoupleRecordIdToCRMID(CustomerB.RecordId, CRMIDA);

        CRMIntegrationRecord.Reset();
        CRMIntegrationRecord.SetFilter("CRM ID", CRMIDA);
        Assert.AreEqual(1, CRMIntegrationRecord.Count,
          'Expected there to be only one CRM Integration Record referring to CRM AccountA');

        CRMIntegrationRecord.Reset();
        CRMIntegrationRecord.SetFilter("CRM ID", CRMIDB);
        Assert.AreEqual(0, CRMIntegrationRecord.Count,
          'Did not expect there to be a CRM Integration Record referring to CRM AccountB');

        CRMIntegrationRecord.Reset();
        CRMIntegrationRecord.SetFilter("Integration ID", CustomerB.SystemId);
        Assert.AreEqual(1, CRMIntegrationRecord.Count,
          'Expected there to be only one CRM Integration Record referring to Customer B');

        CRMIntegrationRecord.Reset();
        CRMIntegrationRecord.SetFilter("Integration ID", CustomerA.SystemId);
        Assert.AreEqual(0, CRMIntegrationRecord.Count,
          'Did not expect there to be a CRM Integration Record referring to Customer A');

        CRMIntegrationRecord.Reset();
        CRMIntegrationRecord.SetFilter("CRM ID", CRMIDA);
        CRMIntegrationRecord.SetFilter("Integration ID", CustomerB.SystemId);
        Assert.AreEqual(1, CRMIntegrationRecord.Count, 'Expected CustomerB to be coupled to CRM AccountA');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure RemoveCoupling()
    var
        Customer: Record Customer;
        CRMIntegrationRecord: Record "CRM Integration Record";
    begin
        LibraryCRMIntegration.ResetEnvironment;

        // [GIVEN] A valid CRM Setup
        LibraryCRMIntegration.CreateCRMConnectionSetup('', 'testhostname.domain.int', true);
        LibrarySales.CreateCustomer(Customer);
        CRMIntegrationRecord.CoupleRecordIdToCRMID(Customer.RecordId, CreateGuid());

        // [GIVEN] An existing coupling for CustomerA
        // [WHEN] Deleting coupling copyling for CustomerA
        // [THEN] Record is no longer coupled
        Assert.IsTrue(CRMIntegrationRecord.IsRecordCoupled(Customer.RecordId), 'Expected record to be coupled');
        CRMIntegrationRecord.RemoveCouplingToRecord(Customer.RecordId);
        Assert.IsFalse(CRMIntegrationRecord.IsRecordCoupled(Customer.RecordId), 'Did not expect record to be coupled');

        // [GIVEN] No coupling for CustomerA
        // [WHEN] Deleting coupling
        // [THEN] Nothing happens no matter how many times you try to delete it
        CRMIntegrationRecord.RemoveCouplingToRecord(Customer.RecordId);
        CRMIntegrationRecord.RemoveCouplingToRecord(Customer.RecordId);
        CRMIntegrationRecord.RemoveCouplingToRecord(Customer.RecordId);
        CRMIntegrationRecord.RemoveCouplingToRecord(Customer.RecordId);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure RemovalOfCoupledRecordDoesNotMarkCouplingAsSkipped()
    var
        CRMAccount: Record "CRM Account";
        CRMIntegrationRecord: Record "CRM Integration Record";
        Customer: Record Customer;
    begin
        // [FEATURE] [Skipped Record]
        // [SCENARIO] Removal of the coupled record should mark CRM Integration Record as "Skipped"
        LibraryCRMIntegration.ResetEnvironment;

        // [GIVEN] A valid CRM setup
        LibraryCRMIntegration.ConfigureCRM;
        // [GIVEN] An existing coupling between a Customer and a CRM Account
        LibraryCRMIntegration.CreateCoupledCustomerAndAccount(Customer, CRMAccount);

        // [WHEN] Delete Customer
        Customer.Delete();
        // [THEN] CRM Integration Record for Customer, where "Skipped" is 'Yes'
        Assert.IsFalse(CRMIntegrationRecord.FindByRecordID(Customer.RecordId), 'FindByRecordID should fail.');
        Assert.IsTrue(CRMIntegrationRecord.FindByCRMID(CRMAccount.AccountId), 'FindByCRMID should not fail.');
        CRMIntegrationRecord.TestField(Skipped, false);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure RemovalOfCoupledSalesHeaderWithLinesIsNotBlocked()
    var
        CRMSalesorder: Record "CRM Salesorder";
        CRMIntegrationRecord: Record "CRM Integration Record";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"CRM Integration Record Test");

        // [FEATURE] [Sales] [Order]
        // [SCENARIO] Removal of the coupled Sales Order should remove the coupling.
        LibraryCRMIntegration.ResetEnvironment;

        // [GIVEN] A valid CRM setup
        LibraryCRMIntegration.ConfigureCRM;
        // [GIVEN] Sales Order is coupled ot CRMSalesorder
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, LibrarySales.CreateCustomerNo);
        LibrarySales.CreateSalesLineSimple(SalesLine, SalesHeader);
        CRMSalesorder.SalesOrderId := CreateGuid;
        CRMSalesorder.Insert();
        CRMIntegrationRecord.CoupleCRMIDToRecordID(CRMSalesorder.SalesOrderId, SalesHeader.RecordId);

        // [WHEN] Delete Sales Order
        SalesHeader.Delete(true);

        // [THEN] Coupling is removed.
        Assert.IsFalse(CRMIntegrationRecord.FindByCRMID(CRMSalesorder.SalesOrderId), 'Coupling should be removed');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CoupledRecordsAreNewerUntilSynched()
    var
        Customer: Record Customer;
        CRMAccount: Record "CRM Account";
        CRMIntegrationRecord: Record "CRM Integration Record";
        NewDateTime: DateTime;
    begin
        // [FEATURE] [Modified On]
        // [SCENARIO] Testing if record has changed since last synch.
        LibraryCRMIntegration.ResetEnvironment;

        // [GIVEN] A valid CRM setup
        // [GIVEN] An existing coupling between a Customer and a CRM Account
        // [WHEN] Testing the  coupled records have changed
        // [THEN] Last Modified On is considered newer until set.
        LibraryCRMIntegration.ConfigureCRM;
        LibraryCRMIntegration.CreateCoupledCustomerAndAccount(Customer, CRMAccount);

        CRMIntegrationRecord.SetFilter("CRM ID", CRMAccount.AccountId);
        CRMIntegrationRecord.FindFirst;

        Assert.IsTrue(CRMIntegrationRecord.IsModifiedAfterLastSynchonizedCRMRecord(
            CRMAccount.AccountId, DATABASE::Customer,
            CreateDateTime(DMY2Date(1, 1, 1900), Time)),
          'Expected any date is newer after coupling.');
        Assert.IsTrue(CRMIntegrationRecord.IsModifiedAfterLastSynchronizedRecord(
            Customer.RecordId, CreateDateTime(DMY2Date(1, 1, 1900), Time)),
          'Expected any date is newer after coupling.');

        CRMIntegrationRecord.SetLastSynchModifiedOns(
          CRMAccount.AccountId, DATABASE::Customer,
          CRMAccount.ModifiedOn, Customer.SystemModifiedAt, CreateGuid, 2);

        // [GIVEN] The Last Synch. dates has been set to the respective Modified On values.
        // [WHEN] Testing if the coupled record is newer than long ago (01-01-1900)
        // [THEN] Last Modified is not considered newer than the coupled records.
        Assert.IsFalse(CRMIntegrationRecord.IsModifiedAfterLastSynchonizedCRMRecord(
            CRMAccount.AccountId, DATABASE::Customer,
            CreateDateTime(DMY2Date(1, 1, 1900), Time)),
          'Did not expect the CRM Acccount table was changed after setting the last modified dates.');
        Assert.IsFalse(CRMIntegrationRecord.IsModifiedAfterLastSynchronizedRecord(
            Customer.RecordId, CreateDateTime(DMY2Date(1, 1, 1900), Time)),
          'Did not expect the Customer table was changed after setting the last modified dates.');

        // [GIVEN] The Last Synch. dates has been set to the respective Modified On values.
        // [WHEN] Testing if the coupled record is newer than their respective Modified On values.
        // [THEN] Last Modified is not considered newer than the coupled records.
        Assert.IsFalse(CRMIntegrationRecord.IsModifiedAfterLastSynchonizedCRMRecord(
            CRMAccount.AccountId, DATABASE::Customer, CRMAccount.ModifiedOn),
          'Did not expect the CRM Acccount table was changed after setting the last modified dates.');
        Assert.IsFalse(CRMIntegrationRecord.IsModifiedAfterLastSynchronizedRecord(
            Customer.RecordId, Customer.SystemModifiedAt),
          'Did not expect the Customer table was changed after setting the last modified dates.');

        // [GIVEN] The Last Synch. dates has been set to the respective Modified On values.
        // [WHEN] Testing if the coupled record is newer than their respective Modified On Value + 1 Minute
        // [THEN] Last Modified IS considered newer than the coupled records.
        NewDateTime :=
          CRMAccount.ModifiedOn +
          (CreateDateTime(DT2Date(CRMAccount.ModifiedOn), 010000T) - CreateDateTime(DT2Date(CRMAccount.ModifiedOn), 0T));
        Assert.IsTrue(CRMIntegrationRecord.IsModifiedAfterLastSynchonizedCRMRecord(
            CRMAccount.AccountId, DATABASE::Customer, NewDateTime),
          StrSubstNo(
            'Expected %1 to be considered newer than the synchronized CRM Account ModifiedOn %2', NewDateTime, CRMAccount.ModifiedOn));
        NewDateTime :=
          Customer.SystemModifiedAt +
          (CreateDateTime(DT2Date(Customer.SystemModifiedAt), 010000T) - CreateDateTime(DT2Date(Customer.SystemModifiedAt), 0T));
        Assert.IsTrue(CRMIntegrationRecord.IsModifiedAfterLastSynchronizedRecord(
            Customer.RecordId, NewDateTime),
          StrSubstNo(
            'Expected %1 to be considered newer than the synchronized Customer Modified On %2', NewDateTime,
            Customer.SystemModifiedAt));
    end;
}

