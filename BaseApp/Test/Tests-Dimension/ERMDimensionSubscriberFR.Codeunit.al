codeunit 143002 "ERM Dimension Subscriber - FR"
{

    trigger OnRun()
    begin
    end;

    var
        LibraryDim: Codeunit "Library - Dimension";

    [EventSubscriber(ObjectType::Codeunit, 131001, 'OnGetLocalTablesWithDimSetIDValidationIgnored', '', false, false)]
    [Scope('OnPrem')]
    procedure GetCountOfLocalTablesWithDimSetIDValidationIgnored(var CountOfTablesIgnored: Integer)
    begin
        // Specifies how many tables with "Dimension Set ID" field related to "Dimension Set Entry" table should not have OnValidate trigger which updates shortcut dimensions

        CountOfTablesIgnored += 5;
    end;

    [EventSubscriber(ObjectType::Codeunit, 131001, 'OnVerifyShorcutDimCodesUpdatedOnDimSetIDValidationLocal', '', false, false)]
    [Scope('OnPrem')]
    procedure VerifyShorcutDimCodesUpdatedOnDimSetIDValidation(var TempAllObj: Record AllObj temporary; DimSetID: Integer; GlobalDim1ValueCode: Code[20]; GlobalDim2ValueCode: Code[20])
    var
        PaymentHeader: Record "Payment Header";
    begin
        // Verifies local tables with "Dimension Set ID" field related to "Dimension Set Entry" and OnValidate trigger which updates shortcut dimensions

        LibraryDim.VerifyShorcutDimCodesUpdatedOnDimSetIDValidation(
          TempAllObj, PaymentHeader, PaymentHeader.FieldNo("Dimension Set ID"),
          PaymentHeader.FieldNo("Shortcut Dimension 1 Code"), PaymentHeader.FieldNo("Shortcut Dimension 2 Code"),
          DimSetID, GlobalDim1ValueCode, GlobalDim2ValueCode);
    end;
}
