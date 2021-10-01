table 25 "Vendor Ledger Entry"
{
    Caption = 'Vendor Ledger Entry';
    DrillDownPageID = "Vendor Ledger Entries";
    LookupPageID = "Vendor Ledger Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(3; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
        }
        field(4; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(5; "Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';
        }
        field(6; "Document No."; Code[20])
        {
            Caption = 'Document No.';

            trigger OnLookup()
            var
                IncomingDocument: Record "Incoming Document";
            begin
                IncomingDocument.HyperlinkToDocument("Document No.", "Posting Date");
            end;
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(8; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
        }
        field(11; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(13; Amount; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum("Detailed Vendor Ledg. Entry".Amount WHERE("Ledger Entry Amount" = CONST(true),
                                                                          "Vendor Ledger Entry No." = FIELD("Entry No."),
                                                                          "Posting Date" = FIELD("Date Filter")));
            Caption = 'Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(14; "Remaining Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum("Detailed Vendor Ledg. Entry".Amount WHERE("Vendor Ledger Entry No." = FIELD("Entry No."),
                                                                          "Posting Date" = FIELD("Date Filter")));
            Caption = 'Remaining Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(15; "Original Amt. (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Detailed Vendor Ledg. Entry"."Amount (LCY)" WHERE("Vendor Ledger Entry No." = FIELD("Entry No."),
                                                                                  "Entry Type" = FILTER("Initial Entry"),
                                                                                  "Posting Date" = FIELD("Date Filter")));
            Caption = 'Original Amt. (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(16; "Remaining Amt. (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Detailed Vendor Ledg. Entry"."Amount (LCY)" WHERE("Vendor Ledger Entry No." = FIELD("Entry No."),
                                                                                  "Posting Date" = FIELD("Date Filter")));
            Caption = 'Remaining Amt. (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(17; "Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Detailed Vendor Ledg. Entry"."Amount (LCY)" WHERE("Ledger Entry Amount" = CONST(true),
                                                                                  "Vendor Ledger Entry No." = FIELD("Entry No."),
                                                                                  "Posting Date" = FIELD("Date Filter")));
            Caption = 'Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(18; "Purchase (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Purchase (LCY)';
        }
        field(20; "Inv. Discount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Inv. Discount (LCY)';
        }
        field(21; "Buy-from Vendor No."; Code[20])
        {
            Caption = 'Buy-from Vendor No.';
            TableRelation = Vendor;
        }
        field(22; "Vendor Posting Group"; Code[20])
        {
            Caption = 'Vendor Posting Group';
            TableRelation = "Vendor Posting Group";
        }
        field(23; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(24; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(25; "Purchaser Code"; Code[20])
        {
            Caption = 'Purchaser Code';
            TableRelation = "Salesperson/Purchaser";
        }
        field(27; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(28; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
        }
        field(33; "On Hold"; Code[3])
        {
            Caption = 'On Hold';
#if not CLEAN18

            trigger OnValidate()
            var
                GenJnlLine: Record "Gen. Journal Line";
            begin
                // NAVCZ
                GenJnlLine.SetRange("Account Type", GenJnlLine."Account Type"::Vendor);
                GenJnlLine.SetRange("Account No.", "Vendor No.");
                GenJnlLine.SetRange("Applies-to Doc. Type", "Document Type");
                GenJnlLine.SetRange("Applies-to Doc. No.", "Document No.");
                GenJnlLine.SetRange(Compensation, true);
                if GenJnlLine.FindFirst then
                    Error(OnHoldErr, GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name", GenJnlLine."Line No.");
            end;
#endif
        }
        field(34; "Applies-to Doc. Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Applies-to Doc. Type';
        }
        field(35; "Applies-to Doc. No."; Code[20])
        {
            Caption = 'Applies-to Doc. No.';
        }
        field(36; Open; Boolean)
        {
            Caption = 'Open';
        }
        field(37; "Due Date"; Date)
        {
            Caption = 'Due Date';

            trigger OnValidate()
            begin
                TestField(Open, true);
            end;
        }
        field(38; "Pmt. Discount Date"; Date)
        {
            Caption = 'Pmt. Discount Date';

            trigger OnValidate()
            begin
                TestField(Open, true);
            end;
        }
        field(39; "Original Pmt. Disc. Possible"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Original Pmt. Disc. Possible';
            Editable = false;
        }
        field(40; "Pmt. Disc. Rcd.(LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Pmt. Disc. Rcd.(LCY)';
        }
        field(43; Positive; Boolean)
        {
            Caption = 'Positive';
        }
        field(44; "Closed by Entry No."; Integer)
        {
            Caption = 'Closed by Entry No.';
            TableRelation = "Vendor Ledger Entry";
        }
        field(45; "Closed at Date"; Date)
        {
            Caption = 'Closed at Date';
        }
        field(46; "Closed by Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Closed by Amount';
        }
        field(47; "Applies-to ID"; Code[50])
        {
            Caption = 'Applies-to ID';

            trigger OnValidate()
            begin
                TestField(Open, true);
            end;
        }
        field(49; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(50; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(51; "Bal. Account Type"; enum "Gen. Journal Account Type")
        {
            Caption = 'Bal. Account Type';
        }
        field(52; "Bal. Account No."; Code[20])
        {
            Caption = 'Bal. Account No.';
            TableRelation = IF ("Bal. Account Type" = CONST("G/L Account")) "G/L Account"
            ELSE
            IF ("Bal. Account Type" = CONST(Customer)) Customer
            ELSE
            IF ("Bal. Account Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Bal. Account Type" = CONST("Bank Account")) "Bank Account"
            ELSE
            IF ("Bal. Account Type" = CONST("Fixed Asset")) "Fixed Asset";
        }
        field(53; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
        }
        field(54; "Closed by Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Closed by Amount (LCY)';
        }
        field(58; "Debit Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = Sum("Detailed Vendor Ledg. Entry"."Debit Amount" WHERE("Ledger Entry Amount" = CONST(true),
                                                                                  "Vendor Ledger Entry No." = FIELD("Entry No."),
                                                                                  "Posting Date" = FIELD("Date Filter")));
            Caption = 'Debit Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(59; "Credit Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = Sum("Detailed Vendor Ledg. Entry"."Credit Amount" WHERE("Ledger Entry Amount" = CONST(true),
                                                                                   "Vendor Ledger Entry No." = FIELD("Entry No."),
                                                                                   "Posting Date" = FIELD("Date Filter")));
            Caption = 'Credit Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(60; "Debit Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = Sum("Detailed Vendor Ledg. Entry"."Debit Amount (LCY)" WHERE("Ledger Entry Amount" = CONST(true),
                                                                                        "Vendor Ledger Entry No." = FIELD("Entry No."),
                                                                                        "Posting Date" = FIELD("Date Filter")));
            Caption = 'Debit Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(61; "Credit Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = Sum("Detailed Vendor Ledg. Entry"."Credit Amount (LCY)" WHERE("Ledger Entry Amount" = CONST(true),
                                                                                         "Vendor Ledger Entry No." = FIELD("Entry No."),
                                                                                         "Posting Date" = FIELD("Date Filter")));
            Caption = 'Credit Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(62; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(63; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(64; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(65; "Closed by Currency Code"; Code[10])
        {
            Caption = 'Closed by Currency Code';
            TableRelation = Currency;
        }
        field(66; "Closed by Currency Amount"; Decimal)
        {
            AccessByPermission = TableData Currency = R;
            AutoFormatExpression = "Closed by Currency Code";
            AutoFormatType = 1;
            Caption = 'Closed by Currency Amount';
        }
        field(73; "Adjusted Currency Factor"; Decimal)
        {
            Caption = 'Adjusted Currency Factor';
            DecimalPlaces = 0 : 15;
        }
        field(74; "Original Currency Factor"; Decimal)
        {
            Caption = 'Original Currency Factor';
            DecimalPlaces = 0 : 15;
        }
        field(75; "Original Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            CalcFormula = Sum("Detailed Vendor Ledg. Entry".Amount WHERE("Vendor Ledger Entry No." = FIELD("Entry No."),
                                                                          "Entry Type" = FILTER("Initial Entry"),
                                                                          "Posting Date" = FIELD("Date Filter")));
            Caption = 'Original Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(76; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(77; "Remaining Pmt. Disc. Possible"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Remaining Pmt. Disc. Possible';

            trigger OnValidate()
            begin
                TestField(Open, true);
                CalcFields(Amount, "Original Amount");

                if "Remaining Pmt. Disc. Possible" * Amount < 0 then
                    FieldError("Remaining Pmt. Disc. Possible", StrSubstNo(MustHaveSameSignErr, FieldCaption(Amount)));

                if Abs("Remaining Pmt. Disc. Possible") > Abs("Original Amount") then
                    FieldError("Remaining Pmt. Disc. Possible", StrSubstNo(MustNotBeLargerErr, FieldCaption("Original Amount")));
            end;
        }
        field(78; "Pmt. Disc. Tolerance Date"; Date)
        {
            Caption = 'Pmt. Disc. Tolerance Date';

            trigger OnValidate()
            begin
                TestField(Open, true);
            end;
        }
        field(79; "Max. Payment Tolerance"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Max. Payment Tolerance';

            trigger OnValidate()
            begin
                TestField(Open, true);
                CalcFields(Amount, "Remaining Amount");

                if "Max. Payment Tolerance" * Amount < 0 then
                    FieldError("Max. Payment Tolerance", StrSubstNo(MustHaveSameSignErr, FieldCaption(Amount)));

                if Abs("Max. Payment Tolerance") > Abs("Remaining Amount") then
                    FieldError("Max. Payment Tolerance", StrSubstNo(MustNotBeLargerErr, FieldCaption("Remaining Amount")));
            end;
        }
        field(81; "Accepted Payment Tolerance"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Accepted Payment Tolerance';
        }
        field(82; "Accepted Pmt. Disc. Tolerance"; Boolean)
        {
            Caption = 'Accepted Pmt. Disc. Tolerance';
        }
        field(83; "Pmt. Tolerance (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Pmt. Tolerance (LCY)';
        }
        field(84; "Amount to Apply"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount to Apply';

            trigger OnValidate()
            begin
                TestField(Open, true);
                CalcFields("Remaining Amount");

                if "Amount to Apply" * "Remaining Amount" < 0 then
                    FieldError("Amount to Apply", StrSubstNo(MustHaveSameSignErr, FieldCaption("Remaining Amount")));

                if Abs("Amount to Apply") > Abs("Remaining Amount") then
                    FieldError("Amount to Apply", StrSubstNo(MustNotBeLargerErr, FieldCaption("Remaining Amount")));
#if not CLEAN19
                TestAdvLink; // NAVCZ
#endif
            end;
        }
        field(85; "IC Partner Code"; Code[20])
        {
            Caption = 'IC Partner Code';
            TableRelation = "IC Partner";
        }
        field(86; "Applying Entry"; Boolean)
        {
            Caption = 'Applying Entry';
        }
        field(87; Reversed; Boolean)
        {
            Caption = 'Reversed';
        }
        field(88; "Reversed by Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Reversed by Entry No.';
            TableRelation = "Vendor Ledger Entry";
        }
        field(89; "Reversed Entry No."; Integer)
        {
            BlankZero = true;
            Caption = 'Reversed Entry No.';
            TableRelation = "Vendor Ledger Entry";
        }
        field(90; Prepayment; Boolean)
        {
            Caption = 'Prepayment';
        }
        field(170; "Creditor No."; Code[20])
        {
            Caption = 'Creditor No.';

            trigger OnValidate()
            begin
                if ("Creditor No." <> '') and ("Recipient Bank Account" <> '') then
                    FieldError("Recipient Bank Account",
                      StrSubstNo(FieldIsNotEmptyErr, FieldCaption("Creditor No."), FieldCaption("Recipient Bank Account")));
            end;
        }
        field(171; "Payment Reference"; Code[50])
        {
            Caption = 'Payment Reference';
            Numeric = true;
        }
        field(172; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";

            trigger OnValidate()
            begin
                TestField(Open, true);
            end;
        }
        field(173; "Applies-to Ext. Doc. No."; Code[35])
        {
            Caption = 'Applies-to Ext. Doc. No.';
        }
        field(288; "Recipient Bank Account"; Code[20])
        {
            Caption = 'Recipient Bank Account';
            TableRelation = "Vendor Bank Account".Code WHERE("Vendor No." = FIELD("Vendor No."));

            trigger OnValidate()
            begin
                if ("Recipient Bank Account" <> '') and ("Creditor No." <> '') then
                    FieldError("Creditor No.",
                      StrSubstNo(FieldIsNotEmptyErr, FieldCaption("Recipient Bank Account"), FieldCaption("Creditor No.")));
            end;
        }
        field(289; "Message to Recipient"; Text[140])
        {
            Caption = 'Message to Recipient';

            trigger OnValidate()
            begin
                TestField(Open, true);
            end;
        }
        field(290; "Exported to Payment File"; Boolean)
        {
            Caption = 'Exported to Payment File';
            Editable = false;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions();
            end;
        }
        field(481; "Shortcut Dimension 3 Code"; Code[20])
        {
            CaptionClass = '1,2,3';
            Caption = 'Shortcut Dimension 3 Code';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"),
                                                                                    "Global Dimension No." = const(3)));
        }
        field(482; "Shortcut Dimension 4 Code"; Code[20])
        {
            CaptionClass = '1,2,4';
            Caption = 'Shortcut Dimension 4 Code';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"),
                                                                                    "Global Dimension No." = const(4)));
        }
        field(483; "Shortcut Dimension 5 Code"; Code[20])
        {
            CaptionClass = '1,2,5';
            Caption = 'Shortcut Dimension 5 Code';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"),
                                                                                    "Global Dimension No." = const(5)));
        }
        field(484; "Shortcut Dimension 6 Code"; Code[20])
        {
            CaptionClass = '1,2,6';
            Caption = 'Shortcut Dimension 6 Code';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"),
                                                                                    "Global Dimension No." = const(6)));
        }
        field(485; "Shortcut Dimension 7 Code"; Code[20])
        {
            CaptionClass = '1,2,7';
            Caption = 'Shortcut Dimension 7 Code';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"),
                                                                                    "Global Dimension No." = const(7)));
        }
        field(486; "Shortcut Dimension 8 Code"; Code[20])
        {
            CaptionClass = '1,2,8';
            Caption = 'Shortcut Dimension 8 Code';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Dimension Set Entry"."Dimension Value Code" where("Dimension Set ID" = field("Dimension Set ID"),
                                                                                    "Global Dimension No." = const(8)));
        }
        field(11700; "Bank Account Code"; Code[20])
        {
            Caption = 'Bank Account Code';
            TableRelation = IF ("Document Type" = FILTER(Invoice | Payment | Reminder | "Finance Charge Memo")) "Vendor Bank Account".Code WHERE("Vendor No." = FIELD("Vendor No."))
            ELSE
#if CLEAN17
            IF ("Document Type" = FILTER("Credit Memo" | Refund)) "Bank Account"."No.";
#else
            IF ("Document Type" = FILTER("Credit Memo" | Refund)) "Bank Account"."No." WHERE("Account Type" = CONST("Bank Account"));
#endif
#if CLEAN18
            ObsoleteState = Removed;
#else
            ObsoleteState = Pending;
#endif
            ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
            ObsoleteTag = '18.0';
#if not CLEAN18

            trigger OnValidate()
            var
                VendBankAcc: Record "Vendor Bank Account";
                BankAcc: Record "Bank Account";
            begin
                if "Bank Account Code" = xRec."Bank Account Code" then
                    exit;
                if "Bank Account Code" = '' then begin
                    "Bank Account No." := '';
                    "Specific Symbol" := '';
                    "Transit No." := '';
                    IBAN := '';
                    "SWIFT Code" := '';
                    exit;
                end;
                TestField("Vendor No.");
                case "Document Type" of
                    "Document Type"::Payment, "Document Type"::"Finance Charge Memo",
                    "Document Type"::Invoice, "Document Type"::Reminder:
                        begin
                            VendBankAcc.Get("Vendor No.", "Bank Account Code");
                            "Bank Account No." := VendBankAcc."Bank Account No.";
                            "Specific Symbol" := VendBankAcc."Specific Symbol";
                            "Transit No." := VendBankAcc."Transit No.";
                            IBAN := VendBankAcc.IBAN;
                            "SWIFT Code" := VendBankAcc."SWIFT Code";
                        end;
                    "Document Type"::"Credit Memo", "Document Type"::Refund:
                        begin
                            BankAcc.Get("Bank Account Code");
                            "Bank Account No." := BankAcc."Bank Account No.";
                            "Specific Symbol" := BankAcc."Specific Symbol";
                            "Transit No." := BankAcc."Transit No.";
                            IBAN := BankAcc.IBAN;
                            "SWIFT Code" := BankAcc."SWIFT Code";
                        end;
                end;
            end;
#endif
        }
        field(11701; "Bank Account No."; Text[30])
        {
            Caption = 'Bank Account No.';
            Editable = false;
#if CLEAN18
            ObsoleteState = Removed;
#else
            ObsoleteState = Pending;
#endif
            ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
            ObsoleteTag = '18.0';
        }
        field(11703; "Specific Symbol"; Code[10])
        {
            Caption = 'Specific Symbol';
            CharAllowed = '09';
            Editable = false;
#if CLEAN18
            ObsoleteState = Removed;
#else
            ObsoleteState = Pending;
#endif
            ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
            ObsoleteTag = '18.0';
        }
        field(11704; "Variable Symbol"; Code[10])
        {
            Caption = 'Variable Symbol';
            CharAllowed = '09';
#if CLEAN18
            ObsoleteState = Removed;
#else
            ObsoleteState = Pending;
#endif
            ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
            ObsoleteTag = '18.0';
        }
        field(11705; "Constant Symbol"; Code[10])
        {
            Caption = 'Constant Symbol';
            CharAllowed = '09';
#if CLEAN18
            ObsoleteState = Removed;
#else
            TableRelation = "Constant Symbol";
            ObsoleteState = Pending;
#endif
            ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
            ObsoleteTag = '18.0';
        }
        field(11706; "Transit No."; Text[20])
        {
            Caption = 'Transit No.';
            Editable = false;
#if CLEAN18
            ObsoleteState = Removed;
#else
            ObsoleteState = Pending;
#endif
            ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
            ObsoleteTag = '18.0';
        }
        field(11707; IBAN; Code[50])
        {
            Caption = 'IBAN';
#if CLEAN18
            ObsoleteState = Removed;
#else
            ObsoleteState = Pending;
#endif
            ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
            ObsoleteTag = '18.0';
#if not CLEAN18

            trigger OnValidate()
            var
                CompanyInfo: Record "Company Information";
            begin
                CompanyInfo.CheckIBAN(IBAN);
            end;
#endif
        }
        field(11708; "SWIFT Code"; Code[20])
        {
            Caption = 'SWIFT Code';
#if CLEAN18
            ObsoleteState = Removed;
#else
            ObsoleteState = Pending;
#endif
            ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
            ObsoleteTag = '18.0';
        }
#if not CLEAN19
        field(11710; "Amount on Payment Order (LCY)"; Decimal)
        {
            CalcFormula = - Sum("Issued Payment Order Line"."Amount (LCY)" WHERE(Type = CONST(Vendor),
                                                                                 "Applies-to C/V/E Entry No." = FIELD("Entry No."),
                                                                                 Status = CONST(" ")));
            Caption = 'Amount on Payment Order (LCY)';
            Editable = false;
            FieldClass = FlowField;
            ObsoleteState = Pending;
            ObsoleteReason = 'Moved to Banking Documents Localization for Czech.';
            ObsoleteTag = '19.0';
        }
#endif
        field(11760; "VAT Date"; Date)
        {
            Caption = 'VAT Date';
            Editable = false;
#if CLEAN17
            ObsoleteState = Removed;
#else
            ObsoleteState = Pending;
#endif
            ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
            ObsoleteTag = '17.0';
        }
        field(11761; Compensation; Boolean)
        {
            Caption = 'Compensation';
#if CLEAN18
            ObsoleteState = Removed;
#else
            ObsoleteState = Pending;
#endif
            ObsoleteReason = 'Moved to Compensation Localization Pack for Czech.';
            ObsoleteTag = '18.0';
        }
        field(31000; "Prepayment Type"; Option)
        {
            Caption = 'Prepayment Type';
            Editable = false;
            OptionCaption = ' ,Prepayment,Advance';
            OptionMembers = " ",Prepayment,Advance;
#if CLEAN19
            ObsoleteState = Removed;
#else
            ObsoleteState = Pending;
#endif
            ObsoleteReason = 'Replaced by Advance Payments Localization for Czech.';
            ObsoleteTag = '19.0';
        }
#if not CLEAN19
        field(31001; "Remaining Amount to Link"; Decimal)
        {
            CalcFormula = Sum("Advance Link".Amount WHERE("CV Ledger Entry No." = FIELD("Entry No."),
                                                           "Entry Type" = FILTER(<> Application)));
            Caption = 'Remaining Amount to Link';
            Editable = false;
            FieldClass = FlowField;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced by Advance Payments Localization for Czech.';
            ObsoleteTag = '19.0';
        }
        field(31002; "Remaining Amount to Link (LCY)"; Decimal)
        {
            CalcFormula = Sum("Advance Link"."Amount (LCY)" WHERE("CV Ledger Entry No." = FIELD("Entry No."),
                                                                   "Entry Type" = FILTER(<> Application)));
            Caption = 'Remaining Amount to Link (LCY)';
            Editable = false;
            FieldClass = FlowField;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced by Advance Payments Localization for Czech.';
            ObsoleteTag = '19.0';
        }
#endif
        field(31003; "Open For Advance Letter"; Boolean)
        {
            Caption = 'Open For Advance Letter';
#if CLEAN19
            ObsoleteState = Removed;
#else
            ObsoleteState = Pending;
#endif
            ObsoleteReason = 'Replaced by Advance Payments Localization for Czech.';
            ObsoleteTag = '19.0';
        }
#if not CLEAN18
        field(31050; "Amount on Credit (LCY)"; Decimal)
        {
            CalcFormula = Sum("Credit Line"."Amount (LCY)" WHERE("Source Type" = CONST(Vendor),
                                                                  "Source Entry No." = FIELD("Entry No.")));
            Caption = 'Amount on Credit (LCY)';
            Editable = false;
            FieldClass = FlowField;
            ObsoleteState = Pending;
            ObsoleteReason = 'Moved to Compensation Localization Pack for Czech.';
            ObsoleteTag = '18.0';
        }
#endif
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Vendor No.", "Posting Date", "Currency Code")
        {
            SumIndexFields = "Purchase (LCY)", "Inv. Discount (LCY)";
        }
        key(Key3; "Vendor No.", "Currency Code", "Posting Date")
        {
            Enabled = false;
        }
        key(Key4; "Document No.")
        {
        }
        key(Key5; "External Document No.")
        {
        }
        key(Key6; "Vendor No.", Open, Positive, "Due Date", "Currency Code")
        {
        }
        key(Key7; Open, "Due Date")
        {
        }
        key(Key8; "Document Type", "Vendor No.", "Posting Date", "Currency Code")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Purchase (LCY)", "Inv. Discount (LCY)";
        }
        key(Key9; "Closed by Entry No.")
        {
        }
        key(Key10; "Transaction No.")
        {
        }
        key(Key11; "Vendor No.", "Global Dimension 1 Code", "Global Dimension 2 Code", "Posting Date", "Currency Code")
        {
            Enabled = false;
            SumIndexFields = "Purchase (LCY)", "Inv. Discount (LCY)";
        }
        key(Key12; "Vendor No.", Open, "Global Dimension 1 Code", "Global Dimension 2 Code", Positive, "Due Date", "Currency Code")
        {
            Enabled = false;
        }
        key(Key13; Open, "Global Dimension 1 Code", "Global Dimension 2 Code", "Due Date")
        {
            Enabled = false;
        }
        key(Key14; "Document Type", "Vendor No.", "Global Dimension 1 Code", "Global Dimension 2 Code", "Posting Date", "Currency Code")
        {
            Enabled = false;
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key15; "Vendor No.", "Applies-to ID", Open, Positive, "Due Date")
        {
        }
        key(Key16; "Vendor No.", "Currency Code", "Vendor Posting Group", "Document Type")
        {
        }
        key(Key17; "Document No.", "Posting Date", "Currency Code")
        {
        }
        key(Key18; "Vendor No.", "Vendor Posting Group", Prepayment, "Posting Date")
        {
        }
        key(Key19; "Document Type", "Document No.")
        {
        }
        key(Key20; "Vendor Posting Group")
        {
        }
        key(Key21; "Pmt. Discount Date")
        {
        }
        key(Key22; "Document Type", "Due Date", Open)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", Description, "Vendor No.", "Posting Date", "Document Type", "Document No.")
        {
        }
        fieldgroup(Brick; "Document No.", Description, "Remaining Amt. (LCY)", "Due Date")
        {
        }
    }

    var
        FieldIsNotEmptyErr: Label '%1 cannot be used while %2 has a value.', Comment = '%1=Field;%2=Field';
        MustHaveSameSignErr: Label 'must have the same sign as %1';
        MustNotBeLargerErr: Label 'must not be larger than %1';
#if not CLEAN18
        OnHoldErr: Label 'The operation is prohibited, until journal line of Journal Template Name = ''%1'', Journal Batch Name = ''%2'', Line No. = ''%3'' is deleted or posted.';
#endif

    procedure GetLastEntryNo(): Integer;
    var
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        exit(FindRecordManagement.GetLastEntryIntFieldValue(Rec, FieldNo("Entry No.")))
    end;

    procedure ShowDoc() Result: Boolean
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeShowDoc(Rec, Result, IsHandled);
        if IsHandled then
            exit(Result);

        case "Document Type" of
            "Document Type"::Invoice:
                if PurchInvHeader.Get("Document No.") then begin
                    PAGE.Run(PAGE::"Posted Purchase Invoice", PurchInvHeader);
                    exit(true);
                end;
            "Document Type"::"Credit Memo":
                if PurchCrMemoHdr.Get("Document No.") then begin
                    PAGE.Run(PAGE::"Posted Purchase Credit Memo", PurchCrMemoHdr);
                    exit(true);
                end
        end;

        OnAfterShowDoc(Rec);
    end;

    procedure ShowPostedDocAttachment()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        case "Document Type" of
            "Document Type"::Invoice:
                if PurchInvHeader.Get("Document No.") then
                    OpenDocumentAttachmentDetails(PurchInvHeader);
            "Document Type"::"Credit Memo":
                if PurchCrMemoHdr.Get("Document No.") then
                    OpenDocumentAttachmentDetails(PurchCrMemoHdr);
        end;

        OnAfterShowPostedDocAttachment(Rec);
    end;

    local procedure OpenDocumentAttachmentDetails("Record": Variant)
    var
        DocumentAttachmentDetails: Page "Document Attachment Details";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Record);
        DocumentAttachmentDetails.OpenForRecRef(RecRef);
        DocumentAttachmentDetails.RunModal;
    end;

    procedure HasPostedDocAttachment(): Boolean
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        PurchInvHeader: Record "Purch. Inv. Header";
        [SecurityFiltering(SecurityFilter::Filtered)]
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        DocumentAttachment: Record "Document Attachment";
        HasPostedDocumentAttachment: Boolean;
    begin
        case "Document Type" of
            "Document Type"::Invoice:
                if PurchInvHeader.Get("Document No.") then
                    exit(DocumentAttachment.HasPostedDocumentAttachment(PurchInvHeader));
            "Document Type"::"Credit Memo":
                if PurchCrMemoHdr.Get("Document No.") then
                    exit(DocumentAttachment.HasPostedDocumentAttachment(PurchCrMemoHdr));
        end;

        OnAfterHasPostedDocAttachment(Rec, HasPostedDocumentAttachment);
        exit(HasPostedDocumentAttachment);
    end;

    procedure DrillDownOnEntries(var DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry")
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
        DrillDownPageID: Integer;
    begin
        VendLedgEntry.Reset();
        DtldVendLedgEntry.CopyFilter("Vendor No.", VendLedgEntry."Vendor No.");
        DtldVendLedgEntry.CopyFilter("Currency Code", VendLedgEntry."Currency Code");
        DtldVendLedgEntry.CopyFilter("Initial Entry Global Dim. 1", VendLedgEntry."Global Dimension 1 Code");
        DtldVendLedgEntry.CopyFilter("Initial Entry Global Dim. 2", VendLedgEntry."Global Dimension 2 Code");
        DtldVendLedgEntry.CopyFilter("Initial Entry Due Date", VendLedgEntry."Due Date");
        VendLedgEntry.SetCurrentKey("Vendor No.", "Posting Date");
        VendLedgEntry.SetRange(Open, true);
        OnBeforeDrillDownEntries(VendLedgEntry, DtldVendLedgEntry, DrillDownPageID);
        PAGE.Run(DrillDownPageID, VendLedgEntry);
    end;

    procedure DrillDownOnOverdueEntries(var DtldVendLedgEntry: Record "Detailed Vendor Ledg. Entry")
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
        DrillDownPageID: Integer;
    begin
        VendLedgEntry.Reset();
        DtldVendLedgEntry.CopyFilter("Vendor No.", VendLedgEntry."Vendor No.");
        DtldVendLedgEntry.CopyFilter("Currency Code", VendLedgEntry."Currency Code");
        DtldVendLedgEntry.CopyFilter("Initial Entry Global Dim. 1", VendLedgEntry."Global Dimension 1 Code");
        DtldVendLedgEntry.CopyFilter("Initial Entry Global Dim. 2", VendLedgEntry."Global Dimension 2 Code");
        VendLedgEntry.SetCurrentKey("Vendor No.", "Posting Date");
        VendLedgEntry.SetFilter("Date Filter", '..%1', WorkDate);
        VendLedgEntry.SetFilter("Due Date", '<%1', WorkDate);
        VendLedgEntry.SetFilter("Remaining Amount", '<>%1', 0);
        OnBeforeDrillDownOnOverdueEntries(VendLedgEntry, DtldVendLedgEntry, DrillDownPageID);
        PAGE.Run(DrillDownPageID, VendLedgEntry);
    end;

    procedure GetOriginalCurrencyFactor(): Decimal
    begin
        if "Original Currency Factor" = 0 then
            exit(1);
        exit("Original Currency Factor");
    end;

    procedure GetAdjustedCurrencyFactor(): Decimal
    begin
        if "Adjusted Currency Factor" = 0 then
            exit(1);
        exit("Adjusted Currency Factor");
    end;

    procedure ShowDimensions()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimMgt.ShowDimensionSet("Dimension Set ID", StrSubstNo('%1 %2', TableCaption, "Entry No."));
    end;

    procedure SetStyle() Result: Text
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSetStyle(Result, IsHandled);
        if IsHandled then
            exit(Result);

        if Open then begin
            if WorkDate > "Due Date" then
                exit('Unfavorable')
        end else
            if "Closed at Date" > "Due Date" then
                exit('Attention');
        exit('');
    end;

    procedure CopyFromGenJnlLine(GenJnlLine: Record "Gen. Journal Line")
    begin
        "Vendor No." := GenJnlLine."Account No.";
        "Posting Date" := GenJnlLine."Posting Date";
        "Document Date" := GenJnlLine."Document Date";
        "Document Type" := GenJnlLine."Document Type";
        "Document No." := GenJnlLine."Document No.";
        "External Document No." := GenJnlLine."External Document No.";
        Description := GenJnlLine.Description;
        "Currency Code" := GenJnlLine."Currency Code";
        "Purchase (LCY)" := GenJnlLine."Sales/Purch. (LCY)";
        "Inv. Discount (LCY)" := GenJnlLine."Inv. Discount (LCY)";
        "Buy-from Vendor No." := GenJnlLine."Sell-to/Buy-from No.";
        "Vendor Posting Group" := GenJnlLine."Posting Group";
        "Global Dimension 1 Code" := GenJnlLine."Shortcut Dimension 1 Code";
        "Global Dimension 2 Code" := GenJnlLine."Shortcut Dimension 2 Code";
        "Dimension Set ID" := GenJnlLine."Dimension Set ID";
        "Purchaser Code" := GenJnlLine."Salespers./Purch. Code";
        "Source Code" := GenJnlLine."Source Code";
        "On Hold" := GenJnlLine."On Hold";
        "Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type";
        "Applies-to Doc. No." := GenJnlLine."Applies-to Doc. No.";
        "Due Date" := GenJnlLine."Due Date";
        "Pmt. Discount Date" := GenJnlLine."Pmt. Discount Date";
        "Applies-to ID" := GenJnlLine."Applies-to ID";
        "Journal Batch Name" := GenJnlLine."Journal Batch Name";
        "Reason Code" := GenJnlLine."Reason Code";
        "User ID" := UserId;
        "Bal. Account Type" := GenJnlLine."Bal. Account Type";
        "Bal. Account No." := GenJnlLine."Bal. Account No.";
        "No. Series" := GenJnlLine."Posting No. Series";
        "IC Partner Code" := GenJnlLine."IC Partner Code";
        Prepayment := GenJnlLine.Prepayment;
        "Recipient Bank Account" := GenJnlLine."Recipient Bank Account";
        "Message to Recipient" := GenJnlLine."Message to Recipient";
        "Applies-to Ext. Doc. No." := GenJnlLine."Applies-to Ext. Doc. No.";
        "Creditor No." := GenJnlLine."Creditor No.";
        "Payment Reference" := GenJnlLine."Payment Reference";
        "Payment Method Code" := GenJnlLine."Payment Method Code";
        "Exported to Payment File" := GenJnlLine."Exported to Payment File";
        // NAVCZ
#if not CLEAN17
        "VAT Date" := GenJnlLine."VAT Date";
#endif
#if not CLEAN18
        Compensation := GenJnlLine.Compensation;
#endif
#if not CLEAN19
        "Prepayment Type" := GenJnlLine."Prepayment Type";
#endif
#if not CLEAN18
        "Bank Account Code" := GenJnlLine."Bank Account Code";
        "Bank Account No." := GenJnlLine."Bank Account No.";
        "Specific Symbol" := GenJnlLine."Specific Symbol";
        "Variable Symbol" := GenJnlLine."Variable Symbol";
        "Constant Symbol" := GenJnlLine."Constant Symbol";
        "Transit No." := GenJnlLine."Transit No.";
        IBAN := GenJnlLine.IBAN;
        "SWIFT Code" := GenJnlLine."SWIFT Code";
#endif
        // NAVCZ

        OnAfterCopyVendLedgerEntryFromGenJnlLine(Rec, GenJnlLine);
    end;

    procedure CopyFromCVLedgEntryBuffer(var CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer")
    begin
        "Entry No." := CVLedgerEntryBuffer."Entry No.";
        "Vendor No." := CVLedgerEntryBuffer."CV No.";
        "Posting Date" := CVLedgerEntryBuffer."Posting Date";
        "Document Type" := CVLedgerEntryBuffer."Document Type";
        "Document No." := CVLedgerEntryBuffer."Document No.";
        Description := CVLedgerEntryBuffer.Description;
        "Currency Code" := CVLedgerEntryBuffer."Currency Code";
        Amount := CVLedgerEntryBuffer.Amount;
        "Remaining Amount" := CVLedgerEntryBuffer."Remaining Amount";
        "Original Amount" := CVLedgerEntryBuffer."Original Amount";
        "Original Amt. (LCY)" := CVLedgerEntryBuffer."Original Amt. (LCY)";
        "Remaining Amt. (LCY)" := CVLedgerEntryBuffer."Remaining Amt. (LCY)";
        "Amount (LCY)" := CVLedgerEntryBuffer."Amount (LCY)";
        "Purchase (LCY)" := CVLedgerEntryBuffer."Sales/Purchase (LCY)";
        "Inv. Discount (LCY)" := CVLedgerEntryBuffer."Inv. Discount (LCY)";
        "Buy-from Vendor No." := CVLedgerEntryBuffer."Bill-to/Pay-to CV No.";
        "Vendor Posting Group" := CVLedgerEntryBuffer."CV Posting Group";
        "Global Dimension 1 Code" := CVLedgerEntryBuffer."Global Dimension 1 Code";
        "Global Dimension 2 Code" := CVLedgerEntryBuffer."Global Dimension 2 Code";
        "Dimension Set ID" := CVLedgerEntryBuffer."Dimension Set ID";
        "Purchaser Code" := CVLedgerEntryBuffer."Salesperson Code";
        "User ID" := CVLedgerEntryBuffer."User ID";
        "Source Code" := CVLedgerEntryBuffer."Source Code";
        "On Hold" := CVLedgerEntryBuffer."On Hold";
        "Applies-to Doc. Type" := CVLedgerEntryBuffer."Applies-to Doc. Type";
        "Applies-to Doc. No." := CVLedgerEntryBuffer."Applies-to Doc. No.";
        Open := CVLedgerEntryBuffer.Open;
        "Due Date" := CVLedgerEntryBuffer."Due Date";
        "Pmt. Discount Date" := CVLedgerEntryBuffer."Pmt. Discount Date";
        "Original Pmt. Disc. Possible" := CVLedgerEntryBuffer."Original Pmt. Disc. Possible";
        "Remaining Pmt. Disc. Possible" := CVLedgerEntryBuffer."Remaining Pmt. Disc. Possible";
        "Pmt. Disc. Rcd.(LCY)" := CVLedgerEntryBuffer."Pmt. Disc. Given (LCY)";
        Positive := CVLedgerEntryBuffer.Positive;
        "Closed by Entry No." := CVLedgerEntryBuffer."Closed by Entry No.";
        "Closed at Date" := CVLedgerEntryBuffer."Closed at Date";
        "Closed by Amount" := CVLedgerEntryBuffer."Closed by Amount";
        "Applies-to ID" := CVLedgerEntryBuffer."Applies-to ID";
        "Journal Batch Name" := CVLedgerEntryBuffer."Journal Batch Name";
        "Reason Code" := CVLedgerEntryBuffer."Reason Code";
        "Bal. Account Type" := CVLedgerEntryBuffer."Bal. Account Type";
        "Bal. Account No." := CVLedgerEntryBuffer."Bal. Account No.";
        "Transaction No." := CVLedgerEntryBuffer."Transaction No.";
        "Closed by Amount (LCY)" := CVLedgerEntryBuffer."Closed by Amount (LCY)";
        "Debit Amount" := CVLedgerEntryBuffer."Debit Amount";
        "Credit Amount" := CVLedgerEntryBuffer."Credit Amount";
        "Debit Amount (LCY)" := CVLedgerEntryBuffer."Debit Amount (LCY)";
        "Credit Amount (LCY)" := CVLedgerEntryBuffer."Credit Amount (LCY)";
        "Document Date" := CVLedgerEntryBuffer."Document Date";
        "External Document No." := CVLedgerEntryBuffer."External Document No.";
        "No. Series" := CVLedgerEntryBuffer."No. Series";
        "Closed by Currency Code" := CVLedgerEntryBuffer."Closed by Currency Code";
        "Closed by Currency Amount" := CVLedgerEntryBuffer."Closed by Currency Amount";
        "Adjusted Currency Factor" := CVLedgerEntryBuffer."Adjusted Currency Factor";
        "Original Currency Factor" := CVLedgerEntryBuffer."Original Currency Factor";
        "Pmt. Disc. Tolerance Date" := CVLedgerEntryBuffer."Pmt. Disc. Tolerance Date";
        "Max. Payment Tolerance" := CVLedgerEntryBuffer."Max. Payment Tolerance";
        "Accepted Payment Tolerance" := CVLedgerEntryBuffer."Accepted Payment Tolerance";
        "Accepted Pmt. Disc. Tolerance" := CVLedgerEntryBuffer."Accepted Pmt. Disc. Tolerance";
        "Pmt. Tolerance (LCY)" := CVLedgerEntryBuffer."Pmt. Tolerance (LCY)";
        "Amount to Apply" := CVLedgerEntryBuffer."Amount to Apply";
        Prepayment := CVLedgerEntryBuffer.Prepayment;
#if not CLEAN19
        // NAVCZ
        "Prepayment Type" := CVLedgerEntryBuffer."Prepayment Type";
        "Open For Advance Letter" := CVLedgerEntryBuffer."Open For Advance Letter";
        // NAVCZ
#endif

        OnAfterCopyVendLedgerEntryFromCVLedgEntryBuffer(Rec, CVLedgerEntryBuffer);
    end;

    procedure RecalculateAmounts(FromCurrencyCode: Code[10]; ToCurrencyCode: Code[10]; PostingDate: Date)
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        if ToCurrencyCode = FromCurrencyCode then
            exit;

        "Remaining Amount" :=
          CurrExchRate.ExchangeAmount("Remaining Amount", FromCurrencyCode, ToCurrencyCode, PostingDate);
        "Remaining Pmt. Disc. Possible" :=
          CurrExchRate.ExchangeAmount("Remaining Pmt. Disc. Possible", FromCurrencyCode, ToCurrencyCode, PostingDate);
        "Accepted Payment Tolerance" :=
          CurrExchRate.ExchangeAmount("Accepted Payment Tolerance", FromCurrencyCode, ToCurrencyCode, PostingDate);
        "Amount to Apply" :=
          CurrExchRate.ExchangeAmount("Amount to Apply", FromCurrencyCode, ToCurrencyCode, PostingDate);

        OnAfterRecalculateAmounts(Rec, FromCurrencyCode, ToCurrencyCode, PostingDate);
    end;

#if not CLEAN19
    [Obsolete('Replaced by Advance Payments Localization for Czech.', '19.0')]
    [Scope('OnPrem')]
    procedure TestAdvLink()
    var
        LinkedNotUsedAmt: Decimal;
    begin
        // NAVCZ
        if "Document Type" = "Document Type"::Payment then
            if Prepayment then begin
                CalcFields("Remaining Amount");
                LinkedNotUsedAmt := CalcLinkAdvAmount;

                if Abs("Amount to Apply") > (Abs("Remaining Amount") - Abs(LinkedNotUsedAmt)) then
                    FieldError("Amount to Apply", StrSubstNo(MustNotBeLargerErr, FieldCaption("Remaining Amount to Link")));
            end;
    end;

    [Obsolete('Replaced by Advance Payments Localization for Czech.', '19.0')]
    [Scope('OnPrem')]
    procedure CalcLinkAdvAmount(): Decimal
    var
        AdvLink: Record "Advance Link";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        PurchInvLine: Record "Purch. Inv. Line";
        Amount2: Decimal;
        IsHandled: Boolean;
    begin
        // NAVCZ
        OnBeforeCalcLinkAdvAmount(Amount2, IsHandled);
        if IsHandled then
            exit(Amount2);

        AdvLink.SetCurrentKey("CV Ledger Entry No.");
        AdvLink.SetRange("CV Ledger Entry No.", "Entry No.");
        AdvLink.SetRange("Entry Type", AdvLink."Entry Type"::"Link To Letter");
        AdvLink.CalcSums(Amount);
        Amount2 := AdvLink.Amount;

        AdvLink.SetCurrentKey("CV Ledger Entry No.");
        AdvLink.SetRange("CV Ledger Entry No.", "Entry No.");
        AdvLink.SetRange("Entry Type", AdvLink."Entry Type"::Application);
        if AdvLink.FindSet(false, false) then begin
            repeat
                if PurchInvHeader.Get(AdvLink."Document No.") then begin
                    PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
                    PurchInvLine.SetRange("Prepayment Cancelled", true);
                    if PurchInvLine.IsEmpty() then
                        Amount2 := Amount2 - AdvLink.Amount
                end else
                    if PurchCrMemoHeader.Get(AdvLink."Document No.") then
                        Amount2 := Amount2 - AdvLink.Amount;

            until AdvLink.Next() = 0;
        end;
        exit(Amount2);
    end;

#endif
    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyVendLedgerEntryFromGenJnlLine(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyVendLedgerEntryFromCVLedgEntryBuffer(var VendorLedgerEntry: Record "Vendor Ledger Entry"; CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRecalculateAmounts(var VendorLedgerEntry: Record "Vendor Ledger Entry"; FromCurrencyCode: Code[10]; ToCurrencyCode: Code[10]; PostingDate: Date)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterShowDoc(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterShowPostedDocAttachment(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterHasPostedDocAttachment(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var HasPostedDocumentAttachment: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDrillDownEntries(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry"; var DrillDownPageID: Integer)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeDrillDownOnOverdueEntries(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry"; var DrillDownPageID: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShowDoc(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSetStyle(var Result: Text; var IsHandled: Boolean)
    begin
    end;
#if not CLEAN19
    [Obsolete('Replaced by Advance Payments Localization for Czech.', '19.0')]
    [IntegrationEvent(true, false)]
    local procedure OnBeforeCalcLinkAdvAmount(var Amount: Decimal; var IsHandled: Boolean)
    begin
    end;
#endif
}

