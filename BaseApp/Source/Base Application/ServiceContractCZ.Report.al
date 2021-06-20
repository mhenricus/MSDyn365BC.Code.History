report 31113 "Service Contract CZ"
{
    DefaultLayout = RDLC;
    RDLCLayout = './ServiceContractCZ.rdlc';
    Caption = 'Service Contract CZ';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("Company Information"; "Company Information")
        {
            DataItemTableView = SORTING("Primary Key");
            column(CompanyAddr1; CompanyAddr[1])
            {
            }
            column(CompanyAddr2; CompanyAddr[2])
            {
            }
            column(CompanyAddr3; CompanyAddr[3])
            {
            }
            column(CompanyAddr4; CompanyAddr[4])
            {
            }
            column(CompanyAddr5; CompanyAddr[5])
            {
            }
            column(CompanyAddr6; CompanyAddr[6])
            {
            }
            column(RegistrationNo_CompanyInformation; "Registration No.")
            {
            }
            column(VATRegistrationNo_CompanyInformation; "VAT Registration No.")
            {
            }
            column(HomePage_CompanyInformation; "Home Page")
            {
            }
            column(PhoneNo_CompanyInformation; "Phone No.")
            {
            }
            column(EMail_CompanyInformation; "E-Mail")
            {
            }
            column(Picture_CompanyInformation; Picture)
            {
            }
            dataitem("Service Mgt. Setup"; "Service Mgt. Setup")
            {
                DataItemTableView = SORTING("Primary Key");
                column(LogoPositiononDocuments_ServiceMgtSetup; Format("Logo Position on Documents", 0, 2))
                {
                }
            }

            trigger OnAfterGetRecord()
            begin
                FormatAddr.Company(CompanyAddr, "Company Information");
            end;
        }
        dataitem("Service Contract Header"; "Service Contract Header")
        {
            DataItemTableView = SORTING("Contract Type", "Contract No.") WHERE("Contract Type" = CONST(Contract));
            RequestFilterFields = "Contract No.", "Customer No.";
            column(DocumentLbl; DocumentLbl)
            {
            }
            column(PageLbl; PageLbl)
            {
            }
            column(CopyLbl; CopyLbl)
            {
            }
            column(VendorLbl; VendLbl)
            {
            }
            column(CustomerLbl; CustLbl)
            {
            }
            column(ShipToLbl; ShipToLbl)
            {
            }
            column(SalespersonLbl; SalespersonLbl)
            {
            }
            column(CreatorLbl; CreatorLbl)
            {
            }
            column(VATRegistrationNoLbl; VATRegistrationNoLbl)
            {
            }
            column(RegistrationNoLbl; RegistrationNoLbl)
            {
            }
            column(VATRegistrationNo; Customer."VAT Registration No.")
            {
            }
            column(RegistrationNo; Customer."Registration No.")
            {
            }
            column(ContractNo_ServiceContractHeader; "Contract No.")
            {
            }
            column(YourReference_ServiceContractHeaderCaption; FieldCaption("Your Reference"))
            {
            }
            column(YourReference_ServiceContractHeader; "Your Reference")
            {
            }
            column(PhoneNo_ServiceContractHeaderCaption; FieldCaption("Phone No."))
            {
            }
            column(PhoneNo_ServiceContractHeader; "Phone No.")
            {
            }
            column(EMail_ServiceContractHeaderCaption; FieldCaption("E-Mail"))
            {
            }
            column(EMail_ServiceContractHeader; "E-Mail")
            {
            }
            column(StartingDate_ServiceContractHeaderCaption; FieldCaption("Starting Date"))
            {
            }
            column(StartingDate_ServiceContractHeader; "Starting Date")
            {
            }
            column(InvoicePeriod_ServiceContractHeaderCaption; FieldCaption("Invoice Period"))
            {
            }
            column(InvoicePeriod_ServiceContractHeader; "Invoice Period")
            {
            }
            column(NextInvoiceDate_ServiceContractHeaderCaption; FieldCaption("Next Invoice Date"))
            {
            }
            column(NextInvoiceDate_ServiceContractHeader; "Next Invoice Date")
            {
            }
            column(AnnualAmount_ServiceContractHeaderCaption; FieldCaption("Annual Amount"))
            {
            }
            column(AnnualAmount_ServiceContractHeader; "Annual Amount")
            {
            }
            column(Status_ServiceContractHeaderCaption; FieldCaption(Status))
            {
            }
            column(Status_ServiceContractHeader; Status)
            {
            }
            column(DocFooterText; DocFooterText)
            {
            }
            column(CustAddr1; CustAddr[1])
            {
            }
            column(CustAddr2; CustAddr[2])
            {
            }
            column(CustAddr3; CustAddr[3])
            {
            }
            column(CustAddr4; CustAddr[4])
            {
            }
            column(CustAddr5; CustAddr[5])
            {
            }
            column(CustAddr6; CustAddr[6])
            {
            }
            column(ShipToAddr1; ShipToAddr[1])
            {
            }
            column(ShipToAddr2; ShipToAddr[2])
            {
            }
            column(ShipToAddr3; ShipToAddr[3])
            {
            }
            column(ShipToAddr4; ShipToAddr[4])
            {
            }
            column(ShipToAddr5; ShipToAddr[5])
            {
            }
            column(ShipToAddr6; ShipToAddr[6])
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                column(CopyNo; Number)
                {
                }
                dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
                {
                    DataItemLink = Code = FIELD("Salesperson Code");
                    DataItemLinkReference = "Service Contract Header";
                    DataItemTableView = SORTING(Code);
                    column(Name_SalespersonPurchaser; Name)
                    {
                    }
                    column(PhoneNo_SalespersonPurchaser; "Phone No.")
                    {
                    }
                    column(EMail_SalespersonPurchaser; "E-Mail")
                    {
                    }
                }
                dataitem("Service Contract Line"; "Service Contract Line")
                {
                    DataItemLink = "Contract Type" = FIELD("Contract Type"), "Contract No." = FIELD("Contract No.");
                    DataItemLinkReference = "Service Contract Header";
                    DataItemTableView = SORTING("Contract Type", "Contract No.", "Line No.");
                    column(ContractNo_ServiceContractLine; "Contract No.")
                    {
                    }
                    column(LineNo_ServiceContractLine; "Line No.")
                    {
                    }
                    column(ServiceItemNo_ServiceContractLineCaption; FieldCaption("Service Item No."))
                    {
                    }
                    column(ServiceItemNo_ServiceContractLine; "Service Item No.")
                    {
                    }
                    column(SerialNo_ServiceContractLineCaption; FieldCaption("Serial No."))
                    {
                    }
                    column(SerialNo_ServiceContractLine; "Serial No.")
                    {
                    }
                    column(Description_ServiceContractLineCaption; FieldCaption(Description))
                    {
                    }
                    column(Description_ServiceContractLine; Description)
                    {
                    }
                    column(ItemNo_ServiceContractLineCaption; FieldCaption("Item No."))
                    {
                    }
                    column(ItemNo_ServiceContractLine; "Item No.")
                    {
                    }
                    column(UnitofMeasureCode_ServiceContractLineCaption; FieldCaption("Unit of Measure Code"))
                    {
                    }
                    column(UnitofMeasureCode_ServiceContractLine; "Unit of Measure Code")
                    {
                    }
                    column(ResponseTimeHours_ServiceContractLineCaption; FieldCaption("Response Time (Hours)"))
                    {
                    }
                    column(ResponseTimeHours_ServiceContractLine; "Response Time (Hours)")
                    {
                    }
                    column(ServicePeriod_ServiceContractLineCaption; FieldCaption("Service Period"))
                    {
                    }
                    column(ServicePeriod_ServiceContractLine; "Service Period")
                    {
                    }
                    column(LineValue_ServiceContractLineCaption; FieldCaption("Line Value"))
                    {
                    }
                    column(LineValue_ServiceContractLine; "Line Value")
                    {
                    }
                    dataitem("Service Comment Line"; "Service Comment Line")
                    {
                        DataItemLink = "Table Subtype" = FIELD("Contract Type"), "Table Line No." = FIELD("Line No."), "No." = FIELD("Contract No.");
                        DataItemTableView = SORTING("Table Name", "Table Subtype", "No.", Type, "Table Line No.", "Line No.") WHERE("Table Name" = FILTER("Service Contract"));
                        column(Date_ServiceCommentLine; Date)
                        {
                        }
                        column(Comment_ServiceCommentLine; Comment)
                        {
                        }
                    }
                }
                dataitem("User Setup"; "User Setup")
                {
                    DataItemLink = "User ID" = FIELD("Original User ID");
                    DataItemLinkReference = "Service Contract Header";
                    DataItemTableView = SORTING("User ID");
                    dataitem(Employee; Employee)
                    {
                        DataItemLink = "No." = FIELD("Employee No.");
                        DataItemTableView = SORTING("No.");
                        column(FullName_Employee; FullName)
                        {
                        }
                        column(PhoneNo_Employee; "Phone No.")
                        {
                        }
                        column(CompanyEMail_Employee; "Company E-Mail")
                        {
                        }
                    }
                }

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(NoOfCopies) + 1;
                    if NoOfLoops <= 0 then
                        NoOfLoops := 1;

                    SetRange(Number, 1, NoOfLoops);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CurrReport.Language := Language.GetLanguageIdOrDefault("Language Code");

                FormatAddr.ServContractSellto(CustAddr, "Service Contract Header");
                FormatAddr.ServContractShipto(ShipToAddr, "Service Contract Header");

                DocFooter.SetFilter("Language Code", '%1|%2', '', "Language Code");
                if DocFooter.FindLast then
                    DocFooterText := DocFooter."Footer Text"
                else
                    DocFooterText := '';

                if not Customer.Get("Customer No.") then
                    Customer.Init;

                if LogInteraction and not IsReportInPreviewMode then
                    if "Contact No." <> '' then
                        SegMgt.LogDocument(
                          23, "Contract No.", 0, 0, DATABASE::Contact, "Contact No.", "Salesperson Code", '', Description, '')
                    else
                        SegMgt.LogDocument(
                          23, "Contract No.", 0, 0, DATABASE::Customer, "Customer No.", "Salesperson Code", '', Description, '');
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(NoOfCopies; NoOfCopies)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'No. of Copies';
                        ToolTip = 'Specifies the number of copies to print.';
                    }
                    field(LogInteraction; LogInteraction)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ToolTip = 'Specifies if you want the program to record the service contract quote you print as Interactions and add them to the Interaction Log Entry table.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            LogInteractionEnable := true;
        end;

        trigger OnOpenPage()
        begin
            InitLogInteraction;
            LogInteractionEnable := LogInteraction;
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        if not CurrReport.UseRequestPage then
            InitLogInteraction;
    end;

    var
        Customer: Record Customer;
        DocFooter: Record "Document Footer";
        Language: Codeunit Language;
        FormatAddr: Codeunit "Format Address";
        SegMgt: Codeunit SegManagement;
        CompanyAddr: array[8] of Text[100];
        CustAddr: array[8] of Text[100];
        ShipToAddr: array[8] of Text[100];
        DocFooterText: Text[250];
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        LogInteraction: Boolean;
        [InDataSet]
        LogInteractionEnable: Boolean;
        DocumentLbl: Label 'Service Contract';
        PageLbl: Label 'Page';
        CopyLbl: Label 'Copy';
        VendLbl: Label 'Vendor';
        CustLbl: Label 'Customer';
        ShipToLbl: Label 'Ship-to';
        SalespersonLbl: Label 'Salesperson';
        CreatorLbl: Label 'Posted by';
        VATRegistrationNoLbl: Label 'VAT Registration No.';
        RegistrationNoLbl: Label 'Registration No.';

    [Scope('OnPrem')]
    procedure InitializeRequest(NoOfCopiesFrom: Integer; LogInteractionFrom: Boolean)
    begin
        NoOfCopies := NoOfCopiesFrom;
        LogInteraction := LogInteractionFrom;
    end;

    local procedure InitLogInteraction()
    begin
        LogInteraction := SegMgt.FindInteractTmplCode(23) <> '';
    end;

    local procedure IsReportInPreviewMode(): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        exit(CurrReport.Preview or MailManagement.IsHandlingGetEmailBody);
    end;
}
