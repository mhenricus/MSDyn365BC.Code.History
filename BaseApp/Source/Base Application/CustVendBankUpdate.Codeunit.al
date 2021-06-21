codeunit 5055 "CustVendBank-Update"
{
    TableNo = Contact;

    trigger OnRun()
    var
        ContBusRel: Record "Contact Business Relation";
    begin
        ContBusRel.SetRange("Contact No.", "No.");
        ContBusRel.SetFilter("Link to Table", '<>''''');

        if ContBusRel.Find('-') then
            repeat
                case ContBusRel."Link to Table" of
                    ContBusRel."Link to Table"::Customer:
                        UpdateCustomer(Rec, ContBusRel);
                    ContBusRel."Link to Table"::Vendor:
                        UpdateVendor(Rec, ContBusRel);
                    ContBusRel."Link to Table"::"Bank Account":
                        UpdateBankAccount(Rec, ContBusRel);
                    ContBusRel."Link to Table"::Employee:
                        UpdateEmployee(Rec, ContBusRel);
                    else
                        OnRunCustVendBankUpdateCaseElse(Rec, ContBusRel);
                end;
            until ContBusRel.Next() = 0;
    end;

    var
        Cust: Record Customer;
        Vend: Record Vendor;
        BankAcc: Record "Bank Account";
        NoSeries: Code[20];
        PurchaserCode: Code[20];
        OurContactCode: Code[20];

    procedure UpdateCustomer(var Cont: Record Contact; var ContBusRel: Record "Contact Business Relation")
    var
        VATRegistrationLogMgt: Codeunit "VAT Registration Log Mgt.";
        VATRegNo: Text[20];
    begin
        with Cust do begin
            Get(ContBusRel."No.");
            NoSeries := "No. Series";
            VATRegNo := "VAT Registration No.";
            CustCopyFieldsFromCont(Cont);
            "No." := ContBusRel."No.";
            "No. Series" := NoSeries;
            "Last Modified Date Time" := CurrentDateTime;
            "Last Date Modified" := Today;
            OnAfterUpdateCustomer(Cust, Cont, ContBusRel);
            Modify;
            if ("VAT Registration No." <> '') and ("VAT Registration No." <> VATRegNo) then
                VATRegistrationLogMgt.LogCustomer(Cust);
        end;

        OnAfterUpdateCustomerProcedure(Cust, Cont, ContBusRel);
    end;

    local procedure CustCopyFieldsFromCont(var Cont: Record Contact)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCustCopyFieldsFromCont(Cust, Cont, IsHandled);
        if IsHandled then
            exit;

        Cust.TransferFields(Cont);
    end;

    procedure UpdateVendor(var Cont: Record Contact; var ContBusRel: Record "Contact Business Relation")
    var
        VATRegistrationLogMgt: Codeunit "VAT Registration Log Mgt.";
        VATRegNo: Text[20];
    begin
        with Vend do begin
            Get(ContBusRel."No.");
            NoSeries := "No. Series";
            PurchaserCode := "Purchaser Code";
            VATRegNo := "VAT Registration No.";
            VendCopyFieldsFromCont(Cont);
            "No." := ContBusRel."No.";
            "No. Series" := NoSeries;
            "Purchaser Code" := PurchaserCode;
            "Last Modified Date Time" := CurrentDateTime;
            "Last Date Modified" := Today;
            OnAfterUpdateVendor(Vend, Cont, ContBusRel);
            Modify;
            if ("VAT Registration No." <> '') and ("VAT Registration No." <> VATRegNo) then
                VATRegistrationLogMgt.LogVendor(Vend);
        end;

        OnAfterUpdateVendorProcedure(Vend, Cont, ContBusRel);
    end;

    local procedure VendCopyFieldsFromCont(var Cont: Record Contact)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeVendCopyFieldsFromCont(Vend, Cont, IsHandled);
        if IsHandled then
            exit;

        Vend.TransferFields(Cont);
    end;

    procedure UpdateBankAccount(var Cont: Record Contact; var ContBusRel: Record "Contact Business Relation")
    begin
        with BankAcc do begin
            Get(ContBusRel."No.");
            NoSeries := "No. Series";
            OurContactCode := "Our Contact Code";
            Validate("Currency Code", Cont."Currency Code");
            BankAccountCopyFieldsFromCont(Cont);
            "No." := ContBusRel."No.";
            "No. Series" := NoSeries;
            "Our Contact Code" := OurContactCode;
            "Last Date Modified" := Today;
            OnAfterUpdateBankAccount(BankAcc, Cont, ContBusRel);
            Modify;
        end;
    end;

    local procedure BankAccountCopyFieldsFromCont(var Cont: Record Contact)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeBankAccountCopyFieldsFromCont(BankAcc, Cont, IsHandled);
        if IsHandled then
            exit;

        BankAcc.TransferFields(Cont);
    end;

    [Scope('Onprem')]
    procedure UpdateEmployee(Contact: Record Contact; ContBusRel: Record "Contact Business Relation")
    var
        Employee: Record Employee;
    begin
        Employee.Get(ContBusRel."No.");
        Employee.Address := Contact.Address;
        Employee."Address 2" := Contact."Address 2";
        Employee.City := Contact.City;
        Employee."Phone No." := Contact."Phone No.";
        Employee."Country/Region Code" := Contact."Country/Region Code";
        Employee.Comment := Contact.Comment;
        Employee."Fax No." := Contact."Fax No.";
        Employee."Post Code" := Contact."Post Code";
        Employee.County := Contact.County;
        Employee."E-Mail" := Contact."E-Mail";
        Employee.Image := Contact.Image;
        Employee."First Name" := Contact."First Name";
        Employee."Middle Name" := Contact."Middle Name";
        Employee."Last Name" := Contact.Surname;
        Employee."Job Title" := Contact."Job Title";
        Employee.Initials := Contact.Initials;
        Employee."Mobile Phone No." := Contact."Mobile Phone No.";
        Employee.Pager := Contact.Pager;
        Employee.Modify(true);

        OnAfterUpdateEmployee(Employee, Contact);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateCustomer(var Customer: Record Customer; Contact: Record Contact; var ContBusRel: Record "Contact Business Relation")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateCustomerProcedure(var Customer: Record Customer; var Contact: Record Contact; var ContBusRel: Record "Contact Business Relation")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateVendor(var Vendor: Record Vendor; Contact: Record Contact; var ContBusRel: Record "Contact Business Relation")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateVendorProcedure(var Vendor: Record Vendor; var Contact: Record Contact; var ContBusRel: Record "Contact Business Relation")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateBankAccount(var BankAccount: Record "Bank Account"; Contact: Record Contact; var ContBusRel: Record "Contact Business Relation")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeBankAccountCopyFieldsFromCont(var BankAccount: Record "Bank Account"; var Contact: Record Contact; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCustCopyFieldsFromCont(var Customer: Record Customer; var Contact: Record Contact; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeVendCopyFieldsFromCont(var Vendor: Record Vendor; var Contact: Record Contact; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunCustVendBankUpdateCaseElse(var Contact: Record Contact; var ContactBusinessRelation: Record "Contact Business Relation")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateEmployee(var Employee: Record Employee; Contact: Record Contact)
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::"Contact Business Relation", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertContBusRelation(var Rec: Record "Contact Business Relation"; RunTrigger: Boolean);
    begin
        Rec.UpdateContactBusinessRelation();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Contact Business Relation", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteContBusRelation(var Rec: Record "Contact Business Relation"; RunTrigger: Boolean);
    begin
        Rec.UpdateContactBusinessRelation();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Contact Business Relation", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyContBusRelation(var Rec: Record "Contact Business Relation"; RunTrigger: Boolean);
    begin
        Rec.UpdateContactBusinessRelation();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Contact Business Relation", 'OnAfterRenameEvent', '', false, false)]
    local procedure OnAfterRenameContBusRelation(var Rec: Record "Contact Business Relation"; var xRec: Record "Contact Business Relation"; RunTrigger: Boolean);
    begin
        xRec.UpdateContactBusinessRelation();
        Rec.UpdateContactBusinessRelation();
    end;
}

