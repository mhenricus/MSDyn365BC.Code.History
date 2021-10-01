table 11782 "Subst. Vendor Posting Group"
{
    Caption = 'Subst. Vendor Posting Group';
#if CLEAN18
    ObsoleteState = Removed;
#else
    ObsoleteState = Pending;
#endif
    ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
    ObsoleteTag = '18.0';

    fields
    {
        field(1; "Parent Vend. Posting Group"; Code[20])
        {
            Caption = 'Parent Vend. Posting Group';
            TableRelation = "Vendor Posting Group";
        }
        field(2; "Vendor Posting Group"; Code[20])
        {
            Caption = 'Vendor Posting Group';
            TableRelation = "Vendor Posting Group";

            trigger OnValidate()
            begin
                if "Vendor Posting Group" = "Parent Vend. Posting Group" then
                    Error(PostGrpSubstErr);
            end;
        }
    }

    keys
    {
        key(Key1; "Parent Vend. Posting Group", "Vendor Posting Group")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        PostGrpSubstErr: Label 'Posting Group cannot substitute itself.';
}

