codeunit 9997 "Upgrade Tag Def - Country"
{

    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetReportSelectionForGLVATReconciliationTag);
        PerCompanyUpgradeTags.Add(GetPhysInvntOrdersUpgradeTag);
        PerCompanyUpgradeTags.Add(GetCleanupPhysOrders);
    end;

    procedure GetPhysInvntOrdersUpgradeTag(): Code[250]
    begin
        exit('302317-PhysInvntOrders-20192702');
    end;

    procedure GetCleanupPhysOrders(): Code[250]
    begin
        exit('MS-327839-CleanupPhysOrders-20191007');
    end;

    procedure GetReportSelectionForGLVATReconciliationTag(): Code[250]
    begin
        exit('MS-306584-GLVATReconciliation-20190403');
    end;
}
