codeunit 104101 "UPG.FR"
{
    Subtype = Upgrade;

    trigger OnRun()
    begin
    end;

    trigger OnUpgradePerCompany()
    begin
        UpgradeDetailedCVLedgerEntries;
    end;

    local procedure UpgradeDetailedCVLedgerEntries()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefCountry: Codeunit "Upgrade Tag Def - Country";
    begin
        IF UpgradeTag.HasUpgradeTag(UpgradeTagDefCountry.GetUpgradeDetailedCVLedgerEntriesTag) THEN
            EXIT;

        CODEUNIT.RUN(CODEUNIT::"Update Dtld. CV Ledger Entries");

        UpgradeTag.SetUpgradeTag(UpgradeTagDefCountry.GetUpgradeDetailedCVLedgerEntriesTag);
    end;
}
