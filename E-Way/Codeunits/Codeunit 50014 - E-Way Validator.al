codeunit 50014 "E-Way Validator"
{

    trigger OnRun()
    begin
    end;

    var
        EwayEntry: Record "E-Way Billing Entry";

    procedure CheckValidations(Variant: Variant; RequestType: Option Eway,Vehicle,EWayCancel,RejectEway,ExtendValidity,UpdateTrasporter,AccessToken)
    var
        CompanyInformation: Record "Company Information";
        LocationBuff: Record Location;
        StateBuff: Record state;
        SalesLine: Record "Sales Line";
        Contact: Record Contact;
        ShipToAddr: Record "Ship-to Address";
    begin
        CASE RequestType OF
            RequestType::Eway:
                BEGIN
                    CheckAtleaseOneItem(Variant);
                    CheckEWayAmount(Variant);
                    CheckGSTEWaySetup;
                    CheckEWayLocation(Variant);
                    CheckSellerValidations(Variant);
                    CheckBuyerValidations(Variant);
                    CheckTransportValidations(Variant);
                    CheckLineValidations(Variant);
                END;
            RequestType::Vehicle:
                BEGIN
                    CheckGSTEWaySetup;
                    CheckSellerValidations(Variant);
                    CheckBuyerValidations(Variant);
                    CheckTransportValidations(Variant);
                END;
            RequestType::EWayCancel:
                BEGIN
                    CheckGSTEWaySetup();
                    CheckCancelValidations(Variant);
                END;
            RequestType::RejectEway:
                BEGIN
                    CheckGSTEWaySetup();
                    CheckRejectValidations(Variant);
                END;
            RequestType::UpdateTrasporter:
                BEGIN
                    CheckCancelValidations(Variant);
                END;
            RequestType::ExtendValidity:
                BEGIN
                    CheckGSTEWaySetup;
                    CheckExtendedValidity(Variant);
                    CheckSellerValidations(Variant);
                    CheckBuyerValidations(Variant);
                    CheckTransportValidations(Variant);
                END;
        END;
    end;

    local procedure CheckGSTEWaySetup()
    var
        EWaySetup: Record "E-Way Billing Setup";
    begin
        EWaySetup.GET;
        // EWaySetup.TESTFIELD("E-Way File Storage Path");
        EWaySetup.TESTFIELD("User Name");
        EWaySetup.TESTFIELD(Password);
        EWaySetup.TESTFIELD("Access Token Period");
        EWaySetup.TESTFIELD("Reject E-Way No. Series");
        EWaySetup.TESTFIELD("E-Way Request URL");
        EWaySetup.TESTFIELD("Vehicle Request URL");
        EWaySetup.TESTFIELD("E-Way Reject URL");
        EWaySetup.TESTFIELD("E-Way Reject URL");
        EWaySetup.TESTFIELD("Extend Validity URL");
        EWaySetup.TESTFIELD("Update Transporter URL");
    end;

    local procedure CheckSellerValidations(Variant: Variant)
    var
        RecRef: RecordRef;
        SalesHeader: Record "Sales Header";
        SalesInvHdr: Record "Sales Invoice Header";
        SalesShipHdr: Record "Sales Shipment Header";
        CompanyInfo: Record "Company Information";
        LocationBuff: Record Location;
        StateBuff: Record State;
        PostindDateErr: Label 'The posting date should be today or yesterday.';
        AddrLenErr: Label 'The field %1 Address must be a string with a minimum length of 3 and a maximum length of 100.';
        PurchHead: Record "Purchase Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TransferHeader: Record "Transfer Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
    begin
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            36:
                BEGIN
                    SalesHeader := Variant;
                    SalesHeader.TESTFIELD("Posting Date");
                    IF NOT (SalesHeader."Posting Date" IN [TODAY, TODAY - 1]) THEN
                        ERROR(PostindDateErr);
                    SalesHeader.TESTFIELD("Location GST Reg. No.");
                    CompanyInfo.GET;
                    CompanyInfo.TESTFIELD(Name);
                    SalesHeader.TESTFIELD("Location Code");
                    LocationBuff.GET(SalesHeader."Location Code");
                    LocationBuff.TESTFIELD(Address);
                    IF STRLEN(LocationBuff.Address) < 3 THEN
                        ERROR(AddrLenErr, 'Location');
                    LocationBuff.TESTFIELD(City);
                    LocationBuff.TESTFIELD("Post Code");
                    LocationBuff.TESTFIELD("State Code");
                    StateBuff.GET(LocationBuff."State Code");
                    StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                END;
            110:
                BEGIN
                    SalesShipHdr := Variant;
                    IF NOT (SalesShipHdr."Posting Date" IN [TODAY, TODAY - 1]) THEN
                        ERROR(PostindDateErr);
                    SalesShipHdr.TESTFIELD("Location GST Reg. No.");
                    CompanyInfo.GET;
                    CompanyInfo.TESTFIELD(Name);
                    SalesShipHdr.TESTFIELD("Location Code");
                    LocationBuff.GET(SalesShipHdr."Location Code");
                    LocationBuff.TESTFIELD(Address);
                    IF STRLEN(LocationBuff.Address) < 3 THEN
                        ERROR(AddrLenErr, 'Location');
                    LocationBuff.TESTFIELD(City);
                    LocationBuff.TESTFIELD("Post Code");
                    LocationBuff.TESTFIELD("State Code");
                    StateBuff.GET(LocationBuff."State Code");
                    StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                END;
            112:
                BEGIN
                    SalesInvHdr := Variant;
                    IF NOT (SalesInvHdr."Posting Date" IN [TODAY, TODAY - 1]) THEN
                        ERROR(PostindDateErr);
                    SalesInvHdr.TESTFIELD("Location GST Reg. No.");
                    CompanyInfo.GET;
                    CompanyInfo.TESTFIELD(Name);
                    SalesInvHdr.TESTFIELD("Location Code");
                    LocationBuff.GET(SalesInvHdr."Location Code");
                    LocationBuff.TESTFIELD(Address);
                    IF STRLEN(LocationBuff.Address) < 3 THEN
                        ERROR(AddrLenErr, 'Location');
                    LocationBuff.TESTFIELD(City);
                    LocationBuff.TESTFIELD("Post Code");
                    LocationBuff.TESTFIELD("State Code");
                    StateBuff.GET(LocationBuff."State Code");
                    StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                END;
            38:
                BEGIN
                    PurchHead := Variant;
                    IF NOT (PurchHead."Posting Date" IN [TODAY, TODAY - 1]) THEN
                        ERROR(PostindDateErr);
                    PurchHead.TESTFIELD("Location GST Reg. No.");
                    CompanyInfo.GET;
                    CompanyInfo.TESTFIELD(Name);
                    PurchHead.TESTFIELD("Location Code");
                    LocationBuff.GET(PurchHead."Location Code");
                    LocationBuff.TESTFIELD(Address);
                    IF STRLEN(LocationBuff.Address) < 3 THEN
                        ERROR(AddrLenErr, 'Location');
                    LocationBuff.TESTFIELD(City);
                    LocationBuff.TESTFIELD("Post Code");
                    LocationBuff.TESTFIELD("State Code");
                    StateBuff.GET(LocationBuff."State Code");
                    StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                END;
            114:
                BEGIN
                    SalesCrMemoHeader := Variant;
                    IF NOT (SalesCrMemoHeader."Posting Date" IN [TODAY, TODAY - 1]) THEN
                        ERROR(PostindDateErr);
                    SalesCrMemoHeader.TESTFIELD("Location GST Reg. No.");
                    CompanyInfo.GET;
                    CompanyInfo.TESTFIELD(Name);
                    SalesCrMemoHeader.TESTFIELD("Location Code");
                    LocationBuff.GET(SalesCrMemoHeader."Location Code");
                    LocationBuff.TESTFIELD(Address);
                    IF STRLEN(LocationBuff.Address) < 3 THEN
                        ERROR(AddrLenErr, 'Location');
                    LocationBuff.TESTFIELD(City);
                    LocationBuff.TESTFIELD("Post Code");
                    LocationBuff.TESTFIELD("State Code");
                    StateBuff.GET(LocationBuff."State Code");
                    StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                END;
            5740:
                BEGIN
                    TransferHeader := Variant;
                    IF NOT (TransferHeader."Posting Date" IN [TODAY, TODAY - 1]) THEN
                        ERROR(PostindDateErr);
                    CompanyInfo.GET;
                    CompanyInfo.TESTFIELD(Name);
                    TransferHeader.TESTFIELD("Transfer-from Code");
                    LocationBuff.GET(TransferHeader."Transfer-from Code");
                    LocationBuff.TESTFIELD(Address);
                    IF STRLEN(LocationBuff.Address) < 3 THEN
                        ERROR(AddrLenErr, 'Location');
                    LocationBuff.TESTFIELD(City);
                    LocationBuff.TESTFIELD("Post Code");
                    LocationBuff.TESTFIELD("State Code");
                    LocationBuff.TESTFIELD("GST Registration No.");
                    StateBuff.GET(LocationBuff."State Code");
                    StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                END;
            5744:
                BEGIN
                    TransferShipmentHeader := Variant;
                    IF NOT (TransferShipmentHeader."Posting Date" IN [TODAY, TODAY - 1]) THEN
                        ERROR(PostindDateErr);
                    //TESTFIELD("Location GST Reg. No.");
                    CompanyInfo.GET;
                    CompanyInfo.TESTFIELD(Name);
                    TransferShipmentHeader.TESTFIELD("Transfer-from Code");
                    LocationBuff.GET(TransferShipmentHeader."Transfer-from Code");
                    LocationBuff.TESTFIELD(Address);
                    IF STRLEN(LocationBuff.Address) < 3 THEN
                        ERROR(AddrLenErr, 'Location');
                    LocationBuff.TESTFIELD(City);
                    LocationBuff.TESTFIELD("Post Code");
                    LocationBuff.TESTFIELD("State Code");
                    LocationBuff.TESTFIELD("GST Registration No.");
                    StateBuff.GET(LocationBuff."State Code");
                    StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                END;
        END;
    end;

    local procedure CheckBuyerValidations(Variant: Variant)
    var
        RecRef: RecordRef;
        SalesHeader: Record "Sales Header";
        SalesInvHdr: Record "Sales Invoice Header";
        SalesShipHdr: Record "Sales Shipment Header";
        LocationBuff: Record Location;
        StateBuff: Record State;
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesLine: Record "Sales Line";
        AddrLenErr: Label 'The field %1 Address must be a string with a minimum length of 3 and a maximum length of 100.';
        PurchHead: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            36:
                BEGIN
                    SalesHeader := Variant;
                    SalesHeader.TESTFIELD("Bill-to Name");
                    SalesHeader.TESTFIELD("Bill-to Address");
                    IF STRLEN(SalesHeader."Bill-to Address") < 3 THEN
                        ERROR(AddrLenErr, 'Bill-to Address');
                    SalesHeader.TESTFIELD("Bill-to City");
                    IF SalesHeader."GST Customer Type" = SalesHeader."GST Customer Type"::Export THEN
                        EXIT;
                    //EWB1.2 >>
                    IF SalesHeader."GST Customer Type" <> SalesHeader."GST Customer Type"::Unregistered THEN
                        SalesHeader.TESTFIELD("Customer GST Reg. No.");
                    //EWB1.2 <<
                    SalesLine.SETRANGE("Document No.", SalesHeader."No.");
                    SalesLine.SETFILTER("No.", '<>%1', '');

                    IF SalesLine.FINDFIRST THEN
                        IF SalesLine."GST Place of Supply" = SalesLine."GST Place of Supply"::"Bill-to Address" THEN
                            IF NOT (SalesHeader."GST Customer Type" = SalesHeader."GST Customer Type"::Export) THEN BEGIN
                                SalesHeader.TESTFIELD("GST Bill-to State Code");
                                StateBuff.GET(SalesHeader."GST Bill-to State Code");
                                StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                            END
                            ELSE
                                IF SalesLine."GST Place of Supply" = SalesLine."GST Place of Supply"::"Ship-to Address" THEN
                                    IF NOT (SalesHeader."GST Customer Type" = SalesHeader."GST Customer Type"::Export) THEN BEGIN
                                        SalesHeader.TESTFIELD("GST Ship-to State Code");
                                        StateBuff.GET(SalesHeader."GST Ship-to State Code");
                                        StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                                    END;
                END;
            110:
                BEGIN
                    SalesShipHdr := Variant;
                    SalesShipHdr.TESTFIELD("Bill-to Name");
                    SalesShipHdr.TESTFIELD("Bill-to Address");
                    IF STRLEN(SalesShipHdr."Bill-to Address") < 3 THEN
                        ERROR(AddrLenErr, 'Bill-to Address');
                    SalesShipHdr.TESTFIELD("Bill-to City");

                    IF SalesShipHdr."GST Customer Type" = SalesShipHdr."GST Customer Type"::Export THEN
                        EXIT;
                    //EWB1.2 >>
                    IF SalesShipHdr."GST Customer Type" <> SalesShipHdr."GST Customer Type"::Unregistered THEN
                        SalesShipHdr.TESTFIELD("Customer GST Reg. No.");
                    //EWB1.2 >>

                    SalesLine.SETRANGE("Document No.", SalesShipHdr."No.");
                    SalesLine.SETFILTER("No.", '<>%1', '');
                    IF SalesLine.FINDFIRST THEN
                        IF SalesLine."GST Place of Supply" = SalesLine."GST Place of Supply"::"Bill-to Address" THEN
                            IF NOT (SalesShipHdr."GST Customer Type" = SalesShipHdr."GST Customer Type"::Export) THEN BEGIN
                                SalesShipHdr.TESTFIELD("GST Bill-to State Code");
                                StateBuff.GET(SalesShipHdr."GST Bill-to State Code");
                                StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                            END
                            ELSE
                                IF SalesLine."GST Place of Supply" = SalesLine."GST Place of Supply"::"Ship-to Address" THEN
                                    IF NOT (SalesShipHdr."GST Customer Type" = SalesShipHdr."GST Customer Type"::Export) THEN BEGIN
                                        SalesShipHdr.TESTFIELD("GST Ship-to State Code");
                                        StateBuff.GET(SalesShipHdr."GST Ship-to State Code");
                                        StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                                    END;
                END;
            112:
                BEGIN
                    SalesInvHdr := Variant;
                    SalesInvHdr.TESTFIELD("Bill-to Name");
                    SalesInvHdr.TESTFIELD("Bill-to Address");
                    IF STRLEN(SalesInvHdr."Bill-to Address") < 3 THEN
                        ERROR(AddrLenErr, 'Bill-to Address');
                    SalesInvHdr.TESTFIELD("Bill-to City");
                    IF SalesInvHdr."GST Customer Type" = SalesInvHdr."GST Customer Type"::Export THEN
                        EXIT;
                    //EWB1.2 >>
                    IF SalesInvHdr."GST Customer Type" <> SalesInvHdr."GST Customer Type"::Unregistered THEN
                        SalesInvHdr.TESTFIELD("Customer GST Reg. No.");
                    //EWB1.2 >>
                    SalesInvoiceLine.SETRANGE("Document No.", SalesInvHdr."No.");
                    SalesInvoiceLine.SETFILTER("No.", '<>%1', '');
                    IF SalesInvoiceLine.FINDFIRST THEN
                        IF SalesInvoiceLine."GST Place of Supply" = SalesInvoiceLine."GST Place of Supply"::"Bill-to Address" THEN
                            IF NOT (SalesInvHdr."GST Customer Type" = SalesInvHdr."GST Customer Type"::Export) THEN BEGIN
                                SalesInvHdr.TESTFIELD("GST Bill-to State Code");
                                StateBuff.GET(SalesInvHdr."GST Bill-to State Code");
                                StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                            END
                            ELSE
                                IF SalesInvoiceLine."GST Place of Supply" = SalesInvoiceLine."GST Place of Supply"::"Ship-to Address" THEN
                                    IF NOT (SalesInvHdr."GST Customer Type" = SalesInvHdr."GST Customer Type"::Export) THEN BEGIN
                                        SalesInvHdr.TESTFIELD("GST Ship-to State Code");
                                        StateBuff.GET(SalesInvHdr."GST Ship-to State Code");
                                        StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                                    END;
                END;
            38:
                BEGIN
                    PurchHead := Variant;
                    PurchHead.TESTFIELD("Pay-to Name");
                    PurchHead.TESTFIELD("Pay-to Address");
                    IF STRLEN(PurchHead."Pay-to Address") < 3 THEN
                        ERROR(AddrLenErr, 'Bill-to Address');
                    PurchHead.TESTFIELD("Pay-to City");
                    IF PurchHead."Order Address Code" <> '' THEN BEGIN
                        StateBuff.GET(PurchHead."Order Address Code");
                        StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                    END ELSE BEGIN
                        StateBuff.GET(PurchHead.State);
                        StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                    END;
                END;
            114:
                BEGIN
                    SalesCrMemoHeader := Variant;
                    SalesCrMemoHeader.TESTFIELD("Bill-to Name");
                    SalesCrMemoHeader.TESTFIELD("Bill-to Address");
                    IF STRLEN(SalesCrMemoHeader."Bill-to Address") < 3 THEN
                        ERROR(AddrLenErr, 'Bill-to Address');
                    SalesCrMemoHeader.TESTFIELD("Bill-to City");
                    IF SalesCrMemoHeader."GST Customer Type" = SalesCrMemoHeader."GST Customer Type"::Export THEN
                        EXIT;
                    //EWB1.2 >>
                    IF SalesCrMemoHeader."GST Customer Type" <> SalesCrMemoHeader."GST Customer Type"::Unregistered THEN
                        SalesCrMemoHeader.TESTFIELD("Customer GST Reg. No.");
                    //EWB1.2 >>
                    SalesCrMemoLine.SETRANGE("Document No.", SalesCrMemoHeader."No.");
                    SalesCrMemoLine.SETFILTER("No.", '<>%1', '');
                    IF SalesCrMemoLine.FINDFIRST THEN
                        IF SalesCrMemoLine."GST Place of Supply" = SalesCrMemoLine."GST Place of Supply"::"Bill-to Address" THEN
                            IF NOT (SalesCrMemoHeader."GST Customer Type" = SalesCrMemoHeader."GST Customer Type"::Export) THEN BEGIN
                                SalesCrMemoHeader.TESTFIELD("GST Bill-to State Code");
                                StateBuff.GET(SalesCrMemoHeader."GST Bill-to State Code");
                                StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                            END
                            ELSE
                                IF SalesCrMemoLine."GST Place of Supply" = SalesCrMemoLine."GST Place of Supply"::"Ship-to Address" THEN
                                    IF NOT (SalesCrMemoHeader."GST Customer Type" = SalesCrMemoHeader."GST Customer Type"::Export) THEN BEGIN
                                        SalesCrMemoHeader.TESTFIELD("GST Ship-to State Code");
                                        StateBuff.GET(SalesCrMemoHeader."GST Ship-to State Code");
                                        StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                                    END;
                END;
        END;
    end;

    local procedure CheckTransportValidations(Variant: Variant)
    var
        RecRef: RecordRef;
        SalesHeader: Record "Sales Header";
        SalesInvHdr: Record "Sales Invoice Header";
        SalesShipHrd: Record "Sales Shipment Header";
        PurchHead: Record "Purchase Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TransferHeader: Record "Transfer Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
    begin
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            36:
                BEGIN
                    SalesHeader := Variant;
                    SalesHeader.TESTFIELD("Transaction Type");
                    SalesHeader.TESTFIELD("Transport Method");
                    SalesHeader.TESTFIELD("Vehicle Type");
                    SalesHeader.TESTFIELD("Vehicle No.");
                END;
            110:
                BEGIN
                    SalesShipHrd := Variant;
                    SalesShipHrd.TESTFIELD("Transaction Type");
                    SalesShipHrd.TESTFIELD("Transport Method");
                    SalesShipHrd.TESTFIELD("Vehicle Type");
                    SalesShipHrd.TESTFIELD("Vehicle No.");
                END;
            112:
                BEGIN
                    SalesInvHdr := Variant;
                    SalesInvHdr.TESTFIELD("Transaction Type");
                    SalesInvHdr.TESTFIELD("Transport Method");
                    SalesInvHdr.TESTFIELD("Vehicle Type");
                    //TESTFIELD("Vehicle No.");
                END;
            38:
                BEGIN
                    PurchHead := Variant;
                    PurchHead.TESTFIELD("Transaction Type");
                    PurchHead.TESTFIELD("Transport Method");
                    PurchHead.TESTFIELD("Vehicle Type");
                    PurchHead.TESTFIELD("Vehicle No.");
                END;
            114:
                BEGIN
                    SalesCrMemoHeader := Variant;
                    SalesCrMemoHeader.TESTFIELD("Transaction Type");
                    SalesCrMemoHeader.TESTFIELD("Transport Method");
                    SalesCrMemoHeader.TESTFIELD("Vehicle Type");
                    SalesCrMemoHeader.TESTFIELD("Vehicle No.");
                END;
            5740:
                BEGIN
                    TransferHeader := Variant;
                    TransferHeader.TESTFIELD("Transaction Type");
                    TransferHeader.TESTFIELD("Transport Method");
                    TransferHeader.TESTFIELD("Vehicle Type");
                    TransferHeader.TESTFIELD("Vehicle No.");
                END;
            5744:
                BEGIN
                    TransferShipmentHeader := Variant;
                    TransferShipmentHeader.TESTFIELD("Transaction Type");
                    TransferShipmentHeader.TESTFIELD("Transport Method");
                    TransferShipmentHeader.TESTFIELD("Vehicle Type");
                    TransferShipmentHeader.TESTFIELD("Vehicle No.");
                END;
        END;
    end;

    local procedure CheckLineValidations(Variant: Variant)
    var
        RecRef: RecordRef;
        SalesLine: Record "Sales Line";
        SalesInvLine: Record "Sales Invoice Line";
        SalesHeader: Record "Sales Header";
        SalesInvHdr: Record "Sales Invoice Header";
        SaleShipHdr: Record "Sales Shipment Header";
        SalesShipLine: Record "Sales Shipment Line";
        PurchHead: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        TransferShipmentLine: Record "Transfer Shipment Line";
    begin
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            36:
                BEGIN
                    SalesHeader := Variant;
                    SalesLine.RESET;
                    SalesLine.SETRANGE("Document No.", SalesHeader."No.");
                    SalesLine.SETFILTER("No.", '<>%1', '');
                    SalesLine.SETRANGE(Type, SalesLine.Type::Item);
                    SalesLine.SETFILTER(Quantity, '>%1', 0);
                    IF SalesLine.FINDSET THEN
                        REPEAT
                            SalesLine.TESTFIELD(Quantity);
                            IF SalesLine.Type = SalesLine.Type::Item THEN
                                SalesLine.TESTFIELD("Unit of Measure Code");
                            SalesLine.TESTFIELD("HSN/SAC Code");
                        UNTIL SalesLine.NEXT = 0;
                END;
            110:
                BEGIN
                    SaleShipHdr := Variant;
                    SalesShipLine.RESET;
                    SalesShipLine.SETRANGE("Document No.", SaleShipHdr."No.");
                    SalesShipLine.SETFILTER("No.", '<>%1', '');
                    SalesShipLine.SETRANGE(Type, SalesLine.Type::Item);
                    SalesShipLine.SETFILTER(Quantity, '>%1', 0);
                    IF SalesShipLine.FINDSET THEN
                        REPEAT
                            SalesShipLine.TESTFIELD(Quantity);
                            IF SalesShipLine.Type = SalesShipLine.Type::Item THEN
                                SalesShipLine.TESTFIELD("Unit of Measure Code");
                            SalesShipLine.TESTFIELD("HSN/SAC Code");
                        UNTIL SalesShipLine.NEXT = 0;
                END;
            112:
                BEGIN
                    SalesInvHdr := Variant;
                    SalesInvLine.RESET;
                    SalesInvLine.SETRANGE("Document No.", SalesInvHdr."No.");
                    SalesInvLine.SETFILTER("No.", '<>%1', '');
                    SalesInvLine.SETRANGE(Type, SalesLine.Type::Item);
                    SalesInvLine.SETFILTER(Quantity, '>%1', 0);
                    IF SalesInvLine.FINDSET THEN
                        REPEAT
                            SalesInvLine.TESTFIELD(Quantity);
                            IF SalesInvLine.Type = SalesInvLine.Type::Item THEN
                                SalesInvLine.TESTFIELD("Unit of Measure Code");
                            SalesInvLine.TESTFIELD("HSN/SAC Code");
                        UNTIL SalesInvLine.NEXT = 0;
                END;
            38:
                BEGIN
                    PurchHead := Variant;
                    PurchLine.RESET;
                    PurchLine.SETRANGE("Document No.", PurchHead."No.");
                    PurchLine.SETFILTER("No.", '<>%1', '');
                    PurchLine.SETRANGE(Type, SalesLine.Type::Item);
                    PurchLine.SETFILTER(Quantity, '>%1', 0);
                    IF PurchLine.FINDSET THEN
                        REPEAT
                            PurchLine.TESTFIELD(Quantity);
                            IF PurchLine.Type = PurchLine.Type::Item THEN
                                PurchLine.TESTFIELD("Unit of Measure Code");
                            PurchLine.TESTFIELD("HSN/SAC Code");
                        UNTIL PurchLine.NEXT = 0;
                END;
            114:
                BEGIN
                    SalesCrMemoHeader := Variant;
                    SalesCrMemoLine.RESET;
                    SalesCrMemoLine.SETRANGE("Document No.", SalesCrMemoHeader."No.");
                    SalesCrMemoLine.SETFILTER("No.", '<>%1', '');
                    SalesCrMemoLine.SETRANGE(Type, SalesCrMemoLine.Type::Item);
                    IF SalesCrMemoLine.FINDSET THEN
                        REPEAT
                            SalesCrMemoLine.TESTFIELD(Quantity);
                            IF SalesCrMemoLine.Type = SalesCrMemoLine.Type::Item THEN
                                SalesCrMemoLine.TESTFIELD("Unit of Measure Code");
                            SalesCrMemoLine.TESTFIELD("HSN/SAC Code");
                        UNTIL SalesCrMemoLine.NEXT = 0;
                END;
            5740:
                BEGIN
                    TransferHeader := Variant;
                    TransferLine.RESET;
                    TransferLine.SETRANGE("Document No.", TransferHeader."No.");
                    TransferLine.SETFILTER("Item No.", '<>%1', '');
                    IF TransferLine.FINDSET THEN
                        REPEAT
                            TransferLine.TESTFIELD(Quantity);
                            TransferLine.TESTFIELD("Unit of Measure Code");
                            TransferLine.TESTFIELD("HSN/SAC Code");
                        UNTIL TransferLine.NEXT = 0;
                END;
            5744:
                BEGIN
                    TransferShipmentHeader := Variant;
                    TransferShipmentLine.RESET;
                    TransferShipmentLine.SETRANGE("Document No.", TransferShipmentHeader."No.");
                    TransferShipmentLine.SETFILTER("Item No.", '<>%1', '');
                    IF TransferShipmentLine.FINDSET THEN
                        REPEAT
                            TransferShipmentLine.TESTFIELD(Quantity);
                            TransferShipmentLine.TESTFIELD("Unit of Measure Code");
                            TransferShipmentLine.TESTFIELD("HSN/SAC Code");
                        UNTIL TransferShipmentLine.NEXT = 0;
                END;
        END;
    end;

    local procedure CheckCancelValidations(Variant: Variant)
    var
        RecRef: RecordRef;
        SalesInvHdr: Record "Sales Invoice Header";
        SalesShipHdr: Record "Sales Shipment Header";
        PurchHead: Record "Purchase Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TransferHeader: Record "Transfer Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
    begin
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            110:
                BEGIN
                    SalesShipHdr := Variant;
                    GetEwayBillIngNo(EwayEntry."Transaction Type"::"Sales Shpt", SalesShipHdr."No.");
                END;
            112:
                BEGIN
                    SalesInvHdr := Variant;
                    GetEwayBillIngNo(EwayEntry."Transaction Type"::"Sales Invoice", SalesInvHdr."No.");
                END;
            38:
                BEGIN
                    PurchHead := Variant;
                    GetEwayBillIngNo(EwayEntry."Transaction Type"::"Purch. Order", PurchHead."No.");
                END;
            114:
                BEGIN
                    SalesCrMemoHeader := Variant;
                    GetEwayBillIngNo(EwayEntry."Transaction Type"::"Sales Crd Memo", SalesCrMemoHeader."No.");
                END;
            5740:
                BEGIN
                    TransferShipmentHeader := Variant;
                    GetEwayBillIngNo(EwayEntry."Transaction Type"::"Transfer Order", TransferShipmentHeader."No.");
                END;
        END;
    end;

    local procedure CheckRejectValidations(Variant: Variant)
    var
        Ewbno: BigInteger;
        SalesInvHdr: Record "Sales Invoice Header";
        EwbRejErr: Label 'E-Way Bill No. %1 is created by your self so cant be Rejected.';
        SalesShipHdr: Record "Sales Shipment Header";
        PuchHead: Record "Purchase Header";
        PurchRectHead: Record "Purch. Rcpt. Header";
    begin
        Ewbno := Variant;
        EwayEntry.RESET;
        EwayEntry.SETRANGE("E-Way Bill No.", Ewbno);
        IF EwayEntry.FINDFIRST THEN
            ERROR(EwbRejErr, Ewbno);
    end;

    local procedure CheckExtendedValidity(Variant: Variant)
    var
        RecRef: RecordRef;
        SalesInvHdr: Record "Sales Invoice Header";
        ValidTill: DateTime;
        ValidAfter: DateTime;
        ValidTillErr: Label 'E-Way Can''t be extended after %1 and before %2';
        SalesShipHdr: Record "Sales Shipment Header";
        PurchHead: Record "Purchase Header";
        PresentDate: DateTime;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
    begin
        PresentDate := CURRENTDATETIME;
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            110:
                BEGIN
                    SalesShipHdr := Variant;
                    EwayEntry.GET(EwayEntry."Transaction Type"::"Sales Shpt", SalesShipHdr."No.");
                    ValidTill := EwayEntry."E-Way Valid Upto" + (-((1000 * 60) * 60) * 4);
                    ValidAfter := EwayEntry."E-Way Valid Upto" + (((1000 * 60) * 60) * 4);
                    IF (CURRENTDATETIME > ValidTill) AND (CURRENTDATETIME < ValidAfter) THEN
                        ERROR(ValidTillErr, ValidTill, ValidAfter);
                END;
            112:
                BEGIN
                    SalesInvHdr := Variant;
                    EwayEntry.GET(EwayEntry."Transaction Type"::"Sales Invoice", SalesInvHdr."No.");
                    ValidTill := EwayEntry."E-Way Valid Upto" + (-((1000 * 60) * 60) * 4);
                    ValidAfter := EwayEntry."E-Way Valid Upto" + (((1000 * 60) * 60) * 4);
                    IF (CURRENTDATETIME > ValidTill) AND (CURRENTDATETIME < ValidAfter) THEN
                        ERROR(ValidTillErr, ValidTill, ValidAfter);
                END;
            38:
                BEGIN
                    PurchHead := Variant;
                    EwayEntry.GET(EwayEntry."Transaction Type"::"Purch. Order", PurchHead."No.");
                    ValidTill := EwayEntry."E-Way Valid Upto" + (-((1000 * 60) * 60) * 4);
                    ValidAfter := EwayEntry."E-Way Valid Upto" + (((1000 * 60) * 60) * 4);
                    IF (CURRENTDATETIME > ValidTill) AND (CURRENTDATETIME < ValidAfter) THEN
                        ERROR(ValidTillErr, ValidTill, ValidAfter);
                END;
            114:
                BEGIN
                    SalesCrMemoHeader := Variant;
                    EwayEntry.GET(EwayEntry."Transaction Type"::"Sales Crd Memo", SalesCrMemoHeader."No.");
                    ValidTill := EwayEntry."E-Way Valid Upto" + (-((1000 * 60) * 60) * 4);
                    ValidAfter := EwayEntry."E-Way Valid Upto" + (((1000 * 60) * 60) * 4);
                    IF (CURRENTDATETIME > ValidTill) AND (CURRENTDATETIME < ValidAfter) THEN
                        ERROR(ValidTillErr, ValidTill, ValidAfter);
                END;
            5744:
                BEGIN
                    TransferShipmentHeader := Variant;
                    EwayEntry.GET(EwayEntry."Transaction Type"::"Transfer Order", TransferShipmentHeader."No.");
                    ValidTill := EwayEntry."E-Way Valid Upto" + (-((1000 * 60) * 60) * 4);
                    ValidAfter := EwayEntry."E-Way Valid Upto" + (((1000 * 60) * 60) * 4);
                    IF (CURRENTDATETIME > ValidTill) AND (CURRENTDATETIME < ValidAfter) THEN
                        ERROR(ValidTillErr, ValidTill, ValidAfter);
                END;
        END;
    end;

    local procedure CheckAtleaseOneItem(Variant: Variant)
    var
        RecRef: RecordRef;
        SalesInvHdr: Record "Sales Invoice Header";
        SalesItemError: Label 'Atlease 1 Item Should be there in Document';
        SalesShipHdr: Record "Sales Shipment Header";
        SalesShipLine: Record "Sales Shipment Line";
        SalesInvLine: Record "Sales Invoice Line";
        SalesAmtError: Label 'Document Value must be grater that 50000 for E-Way bill generation';
        PurchHead: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        CheckVendorShip: Record "Purch. Rcpt. Header";
        PurchError: Label 'E-way Bill is applicable only for Un-Regestered and Import Vendors only.';
        ShipmntNoError: Label 'Vendor Shipment No. Should be Unique for E-Way bill Generation';
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            110:
                BEGIN
                    SalesShipHdr := Variant;
                    GetEwayBillIngNo(EwayEntry."Transaction Type"::"Sales Shpt", SalesShipHdr."No.");
                    SalesShipLine.RESET;
                    SalesShipLine.SETRANGE("Document No.", SalesShipHdr."No.");
                    SalesShipLine.SETRANGE(Type, SalesShipLine.Type::Item);
                    IF NOT SalesShipLine.FINDFIRST THEN
                        ERROR(SalesItemError);
                END;
            112:
                BEGIN
                    SalesInvHdr := Variant;
                    GetEwayBillIngNo(EwayEntry."Transaction Type"::"Sales Invoice", SalesShipHdr."No.");
                    CheckSalesInvoiceShipEwayExists(SalesInvHdr);
                    SalesInvLine.RESET;
                    SalesInvLine.SETRANGE("Document No.", SalesInvHdr."No.");
                    SalesInvLine.SETRANGE(Type, SalesInvLine.Type::Item);
                    IF NOT SalesInvLine.FINDFIRST THEN
                        ERROR(SalesItemError);
                END;
            38:
                BEGIN
                    PurchHead := Variant;
                    IF PurchHead."GST Vendor Type" IN [PurchHead."GST Vendor Type"::Unregistered, PurchHead."GST Vendor Type"::Import] THEN BEGIN
                        PurchHead.TESTFIELD("Vendor Shipment No.");
                        CheckVendorShip.RESET;
                        CheckVendorShip.SETRANGE("Vendor Shipment No.", PurchHead."Vendor Shipment No.");
                        IF CheckVendorShip.FINDFIRST THEN
                            ERROR(ShipmntNoError);
                        PurchLine.RESET;
                        PurchLine.SETRANGE("Document No.", PurchHead."No.");
                        PurchLine.SETRANGE(Type, SalesInvLine.Type::Item);
                        IF NOT PurchLine.FINDFIRST THEN
                            ERROR(SalesItemError);
                    END ELSE
                        ERROR(PurchError);
                END;
            114:
                BEGIN
                    SalesCrMemoHeader := Variant;
                    GetEwayBillIngNo(EwayEntry."Transaction Type"::"Sales Crd Memo", SalesCrMemoHeader."No.");
                    SalesCrMemoLine.RESET;
                    SalesCrMemoLine.SETRANGE("Document No.", SalesCrMemoHeader."No.");
                    SalesCrMemoLine.SETRANGE(Type, SalesCrMemoLine.Type::Item);
                    IF NOT SalesCrMemoLine.FINDFIRST THEN
                        ERROR(SalesItemError);
                END;
        END;
    end;

    local procedure CheckEWayAmount(Variant: Variant)
    var
        RecRef: RecordRef;
        SalesInvHdr: Record "Sales Invoice Header";
        SalesItemError: Label 'Atlease 1 Item Should be there in Document';
        SalesShipHdr: Record "Sales Shipment Header";
        SalesShipLine: Record "Sales Shipment Line";
        SalesInvLine: Record "Sales Invoice Line";
        SalesAmtError: Label 'Document Value must be grater that 50000 for E-Way bill generation';
        LineAmt: Decimal;
        PurchHead: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            110:
                BEGIN
                    SalesShipHdr := Variant;
                    SalesShipLine.RESET;
                    SalesShipLine.SETRANGE("Document No.", SalesShipHdr."No.");
                    SalesShipLine.SETRANGE(Type, SalesShipLine.Type::Item);
                    IF SalesShipLine.FINDSET THEN
                        REPEAT
                            LineAmt += (SalesShipLine.Quantity * SalesShipLine."Unit Price") -
                                       ((SalesShipLine.Quantity * SalesShipLine."Unit Price") * SalesShipLine."Line Discount %" / 100)
                                       + ((SalesShipLine.Quantity * SalesShipLine."Unit Price") * ReturnGSTPercent(SalesShipLine."Document No.", SalesShipLine."Line No.") / 100);

                        UNTIL SalesShipLine.NEXT = 0;
                    IF SalesShipHdr."Currency Code" <> '' THEN
                        LineAmt := (1 / SalesShipHdr."Currency Factor") * LineAmt;
                    IF LineAmt < 50000 THEN
                        ERROR(SalesAmtError);
                END;
            112:
                BEGIN
                    SalesInvHdr := Variant;
                    SalesInvLine.RESET;
                    SalesInvLine.SETRANGE("Document No.", SalesInvHdr."No.");
                    SalesInvLine.SETRANGE(Type, SalesInvLine.Type::Item);
                    IF SalesInvLine.FINDSET THEN
                        REPEAT
                            LineAmt += ((SalesInvLine.Quantity * SalesInvLine."Unit Price") -
                                       ((SalesInvLine.Quantity * SalesInvLine."Unit Price") * SalesInvLine."Line Discount %" / 100)) +
                                       ((SalesInvLine.Quantity * SalesInvLine."Unit Price") * ReturnGSTPercent(SalesInvLine."Document No.", SalesInvLine."Line No.") / 100);
                        UNTIL SalesInvLine.NEXT = 0;
                    IF SalesInvHdr."Currency Code" <> '' THEN
                        LineAmt := (1 / SalesInvHdr."Currency Factor") * LineAmt;
                    IF LineAmt < 50000 THEN
                        ERROR(SalesAmtError);
                END;
            38:
                BEGIN
                    PurchHead := Variant;

                    PurchLine.RESET;
                    PurchLine.SETRANGE("Document No.", PurchHead."No.");
                    PurchLine.SETRANGE(Type, PurchLine.Type::Item);
                    IF PurchLine.FINDSET THEN
                        REPEAT
                            LineAmt += ((PurchLine.Quantity * PurchLine."Direct Unit Cost") -
                                       ((PurchLine.Quantity * PurchLine."Direct Unit Cost") * PurchLine."Line Discount %" / 100)) +
                                       ((PurchLine.Quantity * PurchLine."Direct Unit Cost") * ReturnGSTPercent(PurchLine."Document No.", PurchLine."Line No.") / 100);
                        UNTIL PurchLine.NEXT = 0;
                    IF PurchHead."Currency Code" <> '' THEN
                        LineAmt := (1 / PurchHead."Currency Factor") * LineAmt;
                    IF LineAmt < 50000 THEN
                        ERROR(SalesAmtError);
                END;
            114:
                BEGIN
                    SalesCrMemoHeader := Variant;
                    SalesCrMemoLine.RESET;
                    SalesCrMemoLine.SETRANGE("Document No.", SalesCrMemoHeader."No.");
                    SalesCrMemoLine.SETRANGE(Type, SalesCrMemoLine.Type::Item);
                    IF SalesCrMemoLine.FINDSET THEN
                        REPEAT
                            LineAmt += (SalesCrMemoLine.Quantity * SalesCrMemoLine."Unit Price") -
                                       ((SalesCrMemoLine.Quantity * SalesCrMemoLine."Unit Price") * SalesCrMemoLine."Line Discount %" / 100)
                                       + ((SalesCrMemoLine.Quantity * SalesCrMemoLine."Unit Price") * ReturnGSTPercent(SalesCrMemoLine."Document No.", SalesCrMemoLine."Line No.") / 100);

                        UNTIL SalesCrMemoLine.NEXT = 0;
                    IF SalesCrMemoHeader."Currency Code" <> '' THEN
                        LineAmt := (1 / SalesCrMemoHeader."Currency Factor") * LineAmt;
                    IF LineAmt < 50000 THEN
                        ERROR(SalesAmtError);
                END;
        END;
    end;

    local procedure CheckSalesInvoiceShipEwayExists(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        EwayExistErro: Label 'E-Way Bill Already exists for shipment.';
        ShipExistsError: Label 'Shipment already exists so generate E-Way Bill From shipment document';
        EWayBillingSetup: Record "E-Way Billing Setup";
    begin
        EWayBillingSetup.GET;
        SalesInvoiceLine.RESET;
        SalesInvoiceLine.SETRANGE("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SETRANGE(Type, SalesInvoiceLine.Type::Item);
        SalesInvoiceLine.SETFILTER("Shipment No.", '<>%1', '');
        IF SalesInvoiceLine.FINDSET THEN BEGIN
            REPEAT
                SalesShipmentHeader.GET(SalesInvoiceLine."Shipment No.");
                IF GetEwayBillIngNo(EwayEntry."Transaction Type"::"Sales Shpt", SalesShipmentHeader."No.") <> 0 THEN
                    ERROR(EwayExistErro);
            UNTIL SalesInvoiceLine.NEXT = 0;
        END;
        IF SalesInvoiceHeader."Order No." <> '' THEN BEGIN
            SalesShipmentHeader.RESET;
            SalesShipmentHeader.SETRANGE("Order No.", SalesInvoiceHeader."Order No.");
            IF SalesShipmentHeader.FINDFIRST THEN BEGIN
                IF GetEwayBillIngNo(EwayEntry."Transaction Type"::"Sales Shpt", SalesShipmentHeader."No.") <> 0 THEN
                    ERROR(EwayExistErro)
                ELSE BEGIN
                    IF EWayBillingSetup."S.O EWay Applicability" = EWayBillingSetup."S.O EWay Applicability"::Shipment THEN
                        ERROR(ShipExistsError);
                END;
            END;
        END;
    end;

    local procedure CheckEWayLocation(Variant: Variant)
    var
        RecRef: RecordRef;
        SalesInvHdr: Record "Sales Invoice Header";
        SalesItemError: Label 'Atlease 1 Item Should be there in Document';
        SalesShipHdr: Record "Sales Shipment Header";
        SalesShipLine: Record "Sales Shipment Line";
        SalesInvLine: Record "Sales Invoice Line";
        SalesAmtError: Label 'Document Value must be grater that 50000 for E-Way bill generation';
        LineAmt: Decimal;
        PurchHead: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        Location: Record Location;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        TransferHeader: Record "Transfer Header";
        TransferShipmentHeader: Record "Transfer Shipment Header";
    begin
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            110:
                BEGIN
                    SalesShipHdr := Variant;
                    Location.GET(SalesShipHdr."Location Code");
                    Location.TESTFIELD("User Name");
                    Location.TESTFIELD(Password);
                    Location.TESTFIELD("GST Registration No.");
                END;
            112:
                BEGIN
                    SalesInvHdr := Variant;
                    Location.GET(SalesInvHdr."Location Code");
                    Location.TESTFIELD("User Name");
                    Location.TESTFIELD(Password);
                    Location.TESTFIELD("GST Registration No.");
                END;
            38:
                BEGIN
                    PurchHead := Variant;
                    Location.GET(PurchHead."Location Code");
                    Location.TESTFIELD("User Name");
                    Location.TESTFIELD(Password);
                    Location.TESTFIELD("GST Registration No.");
                END;
            114:
                BEGIN
                    SalesCrMemoHeader := Variant;
                    Location.GET(SalesCrMemoHeader."Location Code");
                    Location.TESTFIELD("User Name");
                    Location.TESTFIELD(Password);
                    Location.TESTFIELD("GST Registration No.");
                END;
            5740:
                BEGIN
                    TransferHeader := Variant;
                    Location.GET(TransferHeader."Transfer-from Code");
                    Location.TESTFIELD("User Name");
                    Location.TESTFIELD(Password);
                    Location.TESTFIELD("GST Registration No.");
                END;
            5744:
                BEGIN
                    TransferShipmentHeader := Variant;
                    Location.GET(TransferShipmentHeader."Transfer-from Code");
                    Location.TESTFIELD("User Name");
                    Location.TESTFIELD(Password);
                    Location.TESTFIELD("GST Registration No.");
                END;
        END;
    end;

    local procedure GetEwayBillIngNo(TransType: Option " ","Sales Invoice","Sales Shpt","Purch. Order","Whse. Shipment","Whse. Rect","Transfer Order","Sales Crd Memo","Purch. Crd Memo","Sales R.O","Purchase R.O",Subcontracting; DocNo: Code[20]): BigInteger
    var
        EWayBillingEntry: Record "E-Way Billing Entry";
    begin
        IF EWayBillingEntry.GET(TransType, DocNo) THEN;
        EXIT(EWayBillingEntry."E-Way Bill No.");
    end;




    local procedure ReturnGSTPercent(DocumentNo: Code[20]; LineNo: Integer): Decimal
    var
        GSTLedger: Record "Detailed GST Ledger Entry";
        GSTPer: Decimal;
    begin
        GSTLedger.Reset();
        GSTLedger.SetRange("Document No.", DocumentNo);
        if LineNo <> 0 then
            GSTLedger.SetRange("Document Line No.", LineNo);
        if GSTLedger.FindSet() then begin
            repeat
                GSTPer += abs(GSTLedger."GST Amount");
            until GSTLedger.Next() = 0;
        end;
        exit(GSTPer);

    end;

}

