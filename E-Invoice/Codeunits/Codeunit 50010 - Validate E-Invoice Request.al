codeunit 50010 "Validate E-Invoice Request"
{
    // version E-INV,TokenExpiryFix,POSShipToGSTINFix,ValidIRNFix

    // //TokenExpiryFix
    // //HSNFix
    // //ValidIRNFix


    trigger OnRun();
    begin
    end;

    var
        AddrLenErr: Label 'The field %1 Address must be a string with a minimum length of 3 and a maximum length of 100.';
        CancelValidToErr: Label 'IRN Cancellation is allowed within 24 Hours Only.';
        CrMemoAppliedErr: Label 'Active Credit Memo has been applied, you cannot cancel e-invoice.';
        InActiveInvAppliedErr: Label 'InActive Invoice has been applied, you cannot generate e-invoice for this document.';
        ActiveInActiveInvErr: Label 'You cannot apply Active and Inactive invoices to a single document.';
        CrMemoAppliedErr2: Label 'Credit Memo has been applied, you cannot Generate IRN.';
        Structure: Code[10];

    procedure CheckValidations(Variant: Variant);
    var
        CompanyInformation: Record 79;
        LocationBuff: Record 14;
        StateBuff: Record state;
        SalesLine: Record 37;
        Contact: Record 5050;
        ShipToAddr: Record 222;
    begin
        CheckGSTEInvSetup;
        CheckSellerValidations(Variant);
        CheckBuyerValidations(Variant);
        CheckShipToValidations(Variant);
        CheckLineValidations(Variant);
        CheckGenerateIRNValidaitons(Variant);//ValidIRNFix
    end;

    local procedure CheckGSTEInvSetup();
    var
        EInvoiceSetup: Record "E-Invoice Setup";
    begin
        EInvoiceSetup.GET;
        EInvoiceSetup.TESTFIELD("Request URL");
        //  EInvoiceSetup.TESTFIELD("JSON Request Path");
        //  EInvoiceSetup.TESTFIELD("JSON Response Path");
        // EInvoiceSetup.TESTFIELD("User Name");
        // EInvoiceSetup.TESTFIELD(Password);
        //  EInvoiceSetup.TESTFIELD("Access Token Response Path");
        //EInvoiceSetup.TESTFIELD("Access Token Period");//TokenExpiryFix
        EInvoiceSetup.TESTFIELD("Cancel Request URL");
    end;

    local procedure CheckSellerValidations(Variant: Variant);
    var
        RecRef: RecordRef;
        SalesHeader: Record 36;
        SalesInvHdr: Record "Sales Invoice Header";
        SalesCredHdr: Record "Sales Cr.Memo Header";
        CompanyInfo: Record 79;
        LocationBuff: Record 14;
        StateBuff: Record State;
        PostindDateErr: Label 'The posting date should be today or yesterday.';
        TransferShipHdr: Record "Transfer Shipment Header";
        TransferHeader: Record "Transfer Header";
    begin
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            36:
                BEGIN
                    SalesHeader := Variant;
                    SalesHeader.TESTFIELD("Posting Date");
                    //IF NOT ("Posting Date" IN [TODAY,TODAY - 1]) THEN
                    // ERROR(PostindDateErr);//v1.03
                    SalesHeader.TESTFIELD("Location Code");
                    LocationBuff.GET(SalesHeader."Location Code");
                    //LocationBuff.TESTFIELD("GST Registration No.");//2016CU19
                    SalesHeader.TESTFIELD("Location GST Reg. No.");
                    //LocationBuff.TESTFIELD("User Name");
                    //LocationBuff.TESTFIELD(Password);
                    CompanyInfo.GET;
                    CompanyInfo.TESTFIELD(Name);
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
                    //        IF NOT ("Posting Date" IN [TODAY,TODAY - 1]) THEN
                    //          ERROR(PostindDateErr);//v1.03
                    SalesInvHdr.TESTFIELD("Location Code");
                    LocationBuff.GET(SalesInvHdr."Location Code");
                    //LocationBuff.TESTFIELD("GST Registration No.");//2016CU19
                    SalesInvHdr.TESTFIELD("Location GST Reg. No.");
                    //LocationBuff.TESTFIELD("User Name");
                    //LocationBuff.TESTFIELD(Password);
                    CompanyInfo.GET;
                    CompanyInfo.TESTFIELD(Name);
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
                    SalesCredHdr := Variant;
                    //ValidIRNFix >>
                    /*
                    IF IsCancelledInvoiceApplied(SalesCredHdr) THEN
                      ERROR(CancelInvAppliedErr);
                    */
                    //ValidIRNFix <<
                    //        IF NOT ("Posting Date" IN [TODAY,TODAY - 1]) THEN
                    //          ERROR(PostindDateErr);//v1.03
                    SalesCredHdr.TESTFIELD("Location Code");
                    LocationBuff.GET(SalesCredHdr."Location Code");
                    //LocationBuff.TESTFIELD("GST Registration No.");//2016CU19
                    SalesCredHdr.TESTFIELD("Location GST Reg. No.");
                    //LocationBuff.TESTFIELD("User Name");
                    //LocationBuff.TESTFIELD(Password);
                    CompanyInfo.GET;
                    CompanyInfo.TESTFIELD(Name);
                    LocationBuff.TESTFIELD(Address);
                    IF STRLEN(LocationBuff.Address) < 3 THEN
                        ERROR(AddrLenErr, 'Location');
                    LocationBuff.TESTFIELD(City);
                    LocationBuff.TESTFIELD("Post Code");
                    LocationBuff.TESTFIELD("State Code");
                    StateBuff.GET(LocationBuff."State Code");
                    StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                END;
            //EInvTrans >>
            5740:
                BEGIN
                    TransferHeader := Variant;
                    TransferHeader.TESTFIELD("Transfer-from Code");
                    LocationBuff.GET(TransferHeader."Transfer-from Code");
                    LocationBuff.TESTFIELD("GST Registration No.");//2016CU19
                                                                   //TESTFIELD("Location GST Reg. No.");
                                                                   //LocationBuff.TESTFIELD("User Name");
                                                                   //LocationBuff.TESTFIELD(Password);
                    CompanyInfo.GET;
                    CompanyInfo.TESTFIELD(Name);
                    LocationBuff.TESTFIELD(Address);
                    IF STRLEN(LocationBuff.Address) < 3 THEN
                        ERROR(AddrLenErr, 'Location');
                    LocationBuff.TESTFIELD(City);
                    LocationBuff.TESTFIELD("Post Code");
                    LocationBuff.TESTFIELD("State Code");
                    StateBuff.GET(LocationBuff."State Code");
                    StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                END;
            5744:
                BEGIN
                    TransferShipHdr := Variant;
                    TransferShipHdr.TESTFIELD("Transfer-from Code");
                    LocationBuff.GET(TransferShipHdr."Transfer-from Code");
                    LocationBuff.TESTFIELD("GST Registration No.");//2016CU19
                                                                   //TESTFIELD("Location GST Reg. No.");
                                                                   //LocationBuff.TESTFIELD("User Name");
                                                                   //LocationBuff.TESTFIELD(Password);
                    CompanyInfo.GET;
                    CompanyInfo.TESTFIELD(Name);
                    LocationBuff.TESTFIELD(Address);
                    IF STRLEN(LocationBuff.Address) < 3 THEN
                        ERROR(AddrLenErr, 'Location');
                    LocationBuff.TESTFIELD(City);
                    LocationBuff.TESTFIELD("Post Code");
                    LocationBuff.TESTFIELD("State Code");
                    StateBuff.GET(LocationBuff."State Code");
                    StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                END;
        //EInvTrans <<
        END;

    end;

    local procedure CheckBuyerValidations(Variant: Variant);
    var
        RecRef: RecordRef;
        SalesCredHdr: Record "Sales Cr.Memo Header";
        SalesHeader: Record "Sales Header";
        SalesInvHdr: Record "Sales Invoice Header";
        LocationBuff: Record Location;
        StateBuff: Record State;
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        ShipToAddr: Record "Ship-to Address";
        TransferShipHdr: Record "Transfer Shipment Header";
        TransferHeader: Record "Transfer Header";
    begin
        //>> POSShipToGSTINFix
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            36:
                BEGIN
                    SalesHeader := Variant;
                    IF SalesHeader."GST Customer Type" = SalesHeader."GST Customer Type"::Export THEN BEGIN
                        SalesHeader.TESTFIELD("Bill-to Name");
                        SalesHeader.TESTFIELD("Bill-to Address");
                        IF STRLEN(SalesHeader."Bill-to Address") < 3 THEN
                            ERROR(AddrLenErr, 'Bill-to Address');
                        SalesHeader.TESTFIELD("Bill-to City");
                    END ELSE BEGIN
                        SalesHeader.TESTFIELD("Customer GST Reg. No.");
                        //Customer.GET("Bill-to Customer No.");
                        //Customer.TESTFIELD("GST Registration No.");
                        SalesLine.SETRANGE("Document No.", SalesHeader."No.");
                        SalesLine.SETFILTER("No.", '<>%1', '');
                        IF SalesLine.FINDFIRST THEN
                            IF (SalesLine."GST Place of Supply" = SalesLine."GST Place of Supply"::"Ship-to Address") AND
                              (ShipToAddr.GET(SalesHeader."Sell-to Customer No.", SalesHeader."Ship-to Code"))
                            THEN BEGIN
                                SalesHeader.TESTFIELD("Ship-to Name");
                                SalesHeader.TESTFIELD("Ship-to Address");
                                IF STRLEN(SalesHeader."Ship-to Address") < 3 THEN
                                    ERROR(AddrLenErr, 'Ship-to Address');
                                SalesHeader.TESTFIELD("Ship-to City");
                                //RtnOrdFix >>
                                //              TESTFIELD("GST Ship-to State Code");
                                //              StateBuff.GET("GST Ship-to State Code");
                                //ShipToAddr.GET("Sell-to Customer No.","Ship-to Code");
                                StateBuff.GET(ShipToAddr.State);
                                //RtnOrdFix <<
                                StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                            END ELSE BEGIN
                                SalesHeader.TESTFIELD("Bill-to Name");
                                SalesHeader.TESTFIELD("Bill-to Address");
                                IF STRLEN(SalesHeader."Bill-to Address") < 3 THEN
                                    ERROR(AddrLenErr, 'Bill-to Address');
                                SalesHeader.TESTFIELD("Bill-to City");
                                SalesHeader.TESTFIELD("GST Bill-to State Code");
                                StateBuff.GET(SalesHeader."GST Bill-to State Code");
                                //Customer.GET("Bill-to Customer No.");
                                //StateBuff.GET(Customer."State Code");
                                StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                            END;
                    END;
                END;
            112:
                BEGIN
                    SalesInvHdr := Variant;
                    IF SalesInvHdr."GST Customer Type" = SalesInvHdr."GST Customer Type"::Export THEN BEGIN
                        SalesInvHdr.TESTFIELD("Bill-to Name");
                        SalesInvHdr.TESTFIELD("Bill-to Address");
                        IF STRLEN(SalesInvHdr."Bill-to Address") < 3 THEN
                            ERROR(AddrLenErr, 'Bill-to Address');
                        SalesInvHdr.TESTFIELD("Bill-to City");
                    END ELSE BEGIN
                        SalesInvHdr.TESTFIELD("Customer GST Reg. No.");
                        //Customer.GET("Bill-to Customer No.");
                        //Customer.TESTFIELD("GST Registration No.");
                        SalesInvoiceLine.SETRANGE("Document No.", SalesInvHdr."No.");
                        SalesInvoiceLine.SETFILTER("No.", '<>%1', '');
                        IF SalesInvoiceLine.FINDFIRST THEN
                            IF (SalesInvoiceLine."GST Place of Supply" = SalesInvoiceLine."GST Place of Supply"::"Ship-to Address") AND
                              (ShipToAddr.GET(SalesInvHdr."Sell-to Customer No.", SalesInvHdr."Ship-to Code"))
                            THEN BEGIN
                                SalesInvHdr.TESTFIELD("Ship-to Name");
                                SalesInvHdr.TESTFIELD("Ship-to Address");
                                IF STRLEN(SalesInvHdr."Ship-to Address") < 3 THEN
                                    ERROR(AddrLenErr, 'Ship-to Address');
                                SalesInvHdr.TESTFIELD("Ship-to City");
                                //RtnOrdFix >>
                                //              TESTFIELD("GST Ship-to State Code");
                                //              StateBuff.GET("GST Ship-to State Code");
                                //ShipToAddr.GET("Sell-to Customer No.","Ship-to Code");
                                StateBuff.GET(ShipToAddr.State);
                                //RtnOrdFix <<
                                StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                            END ELSE BEGIN
                                SalesInvHdr.TESTFIELD("Bill-to Name");
                                SalesInvHdr.TESTFIELD("Bill-to Address");
                                IF STRLEN(SalesInvHdr."Bill-to Address") < 3 THEN
                                    ERROR(AddrLenErr, 'Bill-to Address');
                                SalesInvHdr.TESTFIELD("Bill-to City");
                                SalesInvHdr.TESTFIELD("GST Bill-to State Code");
                                StateBuff.GET(SalesInvHdr."GST Bill-to State Code");
                                //Customer.GET("Bill-to Customer No.");
                                //StateBuff.GET(Customer."State Code");
                                StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                            END;
                    END;
                END;
            114:
                BEGIN
                    SalesCredHdr := Variant;
                    IF SalesCredHdr."GST Customer Type" = SalesCredHdr."GST Customer Type"::Export THEN BEGIN
                        SalesCredHdr.TESTFIELD("Bill-to Name");
                        SalesCredHdr.TESTFIELD("Bill-to Address");
                        IF STRLEN(SalesCredHdr."Bill-to Address") < 3 THEN
                            ERROR(AddrLenErr, 'Bill-to Address');
                        SalesCredHdr.TESTFIELD("Bill-to City");
                    END ELSE BEGIN
                        SalesCredHdr.TESTFIELD("Customer GST Reg. No.");
                        //Customer.GET("Bill-to Customer No.");
                        //Customer.TESTFIELD("GST Registration No.");
                        SalesCrMemoLine.SETRANGE("Document No.", SalesCredHdr."No.");
                        SalesCrMemoLine.SETFILTER("No.", '<>%1', '');
                        IF SalesCrMemoLine.FINDFIRST THEN
                            IF (SalesCrMemoLine."GST Place of Supply" = SalesCrMemoLine."GST Place of Supply"::"Ship-to Address") AND
                              (ShipToAddr.GET(SalesCredHdr."Sell-to Customer No.", SalesCredHdr."Ship-to Code"))
                            THEN BEGIN
                                SalesCredHdr.TESTFIELD("Ship-to Name");
                                SalesCredHdr.TESTFIELD("Ship-to Address");
                                IF STRLEN(SalesCredHdr."Ship-to Address") < 3 THEN
                                    ERROR(AddrLenErr, 'Ship-to Address');
                                SalesCredHdr.TESTFIELD("Ship-to City");
                                //RtnOrdFix >>
                                //              TESTFIELD("GST Ship-to State Code");
                                //              StateBuff.GET("GST Ship-to State Code");
                                //ShipToAddr.GET("Sell-to Customer No.","Ship-to Code");
                                StateBuff.GET(ShipToAddr.State);
                                //RtnOrdFix <<
                                StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                            END ELSE BEGIN
                                SalesCredHdr.TESTFIELD("Bill-to Name");
                                SalesCredHdr.TESTFIELD("Bill-to Address");
                                IF STRLEN(SalesCredHdr."Bill-to Address") < 3 THEN
                                    ERROR(AddrLenErr, 'Bill-to Address');
                                SalesCredHdr.TESTFIELD("Bill-to City");
                                SalesCredHdr.TESTFIELD("GST Bill-to State Code");
                                StateBuff.GET(SalesCredHdr."GST Bill-to State Code");
                                //Customer.GET("Bill-to Customer No.");
                                //StateBuff.GET(Customer."State Code");
                                StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                            END;
                    END;

                end;
            //EInvTrans >>
            5740:
                BEGIN
                    TransferHeader := Variant;
                    LocationBuff.GET(TransferHeader."Transfer-to Code");
                    LocationBuff.TESTFIELD("GST Registration No.");
                    TransferHeader.TESTFIELD("Transfer-to Name");
                    TransferHeader.TESTFIELD("Transfer-to Address");
                    TransferHeader.TESTFIELD("Transfer-to Address 2");
                    //StateBuff.GET(Customer."State Code");
                    StateBuff.GET(LocationBuff."State Code");
                    StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                END;
            5744:
                BEGIN
                    TransferShipHdr := Variant;
                    LocationBuff.GET(TransferShipHdr."Transfer-to Code");
                    LocationBuff.TESTFIELD("GST Registration No.");
                    TransferShipHdr.TESTFIELD("Transfer-to Name");
                    TransferShipHdr.TESTFIELD("Transfer-to Address");
                    TransferShipHdr.TESTFIELD("Transfer-to Address 2");
                    //StateBuff.GET(Customer."State Code");
                    StateBuff.GET(LocationBuff."State Code");
                    StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                END;
        //EInvTrans <<
        END;
        //<< POSShipToGSTINFix
    end;

    local procedure CheckShipToValidations(Variant: Variant);
    var
        RecRef: RecordRef;
        ShipToAddr: Record "Ship-to Address";
        SalesLine: Record "Sales Line";
        SalesInvLine: Record "Sales Invoice Line";
        SalesCredLine: Record "Sales Cr.Memo Line";
        StateBuff: Record State;
        SalesCredHdr: Record "Sales Cr.Memo Header";
        SalesHeader: Record "Sales Header";
        SalesInvHdr: Record "Sales Invoice Header";
        Customer: Record Customer;
        TransferShipHdr: Record "Transfer Shipment Header";
    begin
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            36:
                BEGIN
                    SalesHeader := Variant;
                    IF ShipToAddr.GET(SalesHeader."Sell-to Customer No.", SalesHeader."Ship-to Code") THEN BEGIN
                        SalesHeader.TESTFIELD("Ship-to Name");
                        SalesHeader.TESTFIELD("Ship-to Address");
                        IF STRLEN(SalesHeader."Ship-to Address") < 3 THEN
                            ERROR(AddrLenErr, 'Ship-to Address');
                        SalesHeader.TESTFIELD("Ship-to City");
                        IF SalesHeader."GST Customer Type" = SalesHeader."GST Customer Type"::Export THEN
                            EXIT;
                        //ShipToAddr.TESTFIELD("GST Registration No.");
                        //RtnOrdFix >>
                        //StateBuff.GET("GST Ship-to State Code");
                        ShipToAddr.TESTFIELD(State);
                        StateBuff.GET(ShipToAddr.State);
                        //RtnOrdFix <<
                        StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                    END ELSE BEGIN
                        SalesHeader.TESTFIELD("Bill-to Name");
                        SalesHeader.TESTFIELD("Bill-to Address");
                        IF STRLEN(SalesHeader."Bill-to Address") < 3 THEN
                            ERROR(AddrLenErr, 'Bill-to Address');
                        SalesHeader.TESTFIELD("Ship-to City");
                        IF SalesHeader."GST Customer Type" = SalesHeader."GST Customer Type"::Export THEN
                            EXIT;
                        SalesHeader.TESTFIELD("Customer GST Reg. No.");
                        StateBuff.GET(SalesHeader."GST Bill-to State Code");
                        //Customer.GET("Bill-to Customer No.");
                        //Customer.TESTFIELD("GST Registration No.");
                        //StateBuff.GET(Customer."State Code");
                        StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                    END;
                END;
            112:
                BEGIN
                    SalesInvHdr := Variant;
                    IF ShipToAddr.GET(SalesInvHdr."Sell-to Customer No.", SalesInvHdr."Ship-to Code") THEN BEGIN
                        SalesInvHdr.TESTFIELD("Ship-to Name");
                        SalesInvHdr.TESTFIELD("Ship-to Address");
                        IF STRLEN(SalesInvHdr."Ship-to Address") < 3 THEN
                            ERROR(AddrLenErr, 'Ship-to Address');
                        SalesInvHdr.TESTFIELD("Ship-to City");
                        IF SalesInvHdr."GST Customer Type" = SalesInvHdr."GST Customer Type"::Export THEN
                            EXIT;
                        //ShipToAddr.TESTFIELD("GST Registration No.");
                        //RtnOrdFix >>
                        //StateBuff.GET("GST Ship-to State Code");
                        ShipToAddr.TESTFIELD(State);
                        StateBuff.GET(ShipToAddr.State);
                        //RtnOrdFix <<
                        StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                    END ELSE BEGIN
                        SalesInvHdr.TESTFIELD("Bill-to Name");
                        SalesInvHdr.TESTFIELD("Bill-to Address");
                        IF STRLEN(SalesInvHdr."Bill-to Address") < 3 THEN
                            ERROR(AddrLenErr, 'Bill-to Address');
                        SalesInvHdr.TESTFIELD("Ship-to City");
                        IF SalesInvHdr."GST Customer Type" = SalesInvHdr."GST Customer Type"::Export THEN
                            EXIT;
                        SalesInvHdr.TESTFIELD("Customer GST Reg. No.");
                        StateBuff.GET(SalesInvHdr."GST Bill-to State Code");
                        //Customer.GET("Bill-to Customer No.");
                        //Customer.TESTFIELD("GST Registration No.");
                        //StateBuff.GET(Customer."State Code");
                        StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                    END;
                END;
            114:
                BEGIN
                    SalesCredHdr := Variant;
                    IF ShipToAddr.GET(SalesCredHdr."Sell-to Customer No.", SalesCredHdr."Ship-to Code") THEN BEGIN
                        SalesCredHdr.TESTFIELD("Ship-to Name");
                        SalesCredHdr.TESTFIELD("Ship-to Address");
                        IF STRLEN(SalesCredHdr."Ship-to Address") < 3 THEN
                            ERROR(AddrLenErr, 'Ship-to Address');
                        SalesCredHdr.TESTFIELD("Ship-to City");
                        IF SalesCredHdr."GST Customer Type" = SalesCredHdr."GST Customer Type"::Export THEN
                            EXIT;
                        //ShipToAddr.TESTFIELD("GST Registration No.");
                        //RtnOrdFix >>
                        //StateBuff.GET("GST Ship-to State Code");
                        ShipToAddr.TESTFIELD(State);
                        StateBuff.GET(ShipToAddr.State);
                        //RtnOrdFix <<
                        StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                    END ELSE BEGIN
                        SalesCredHdr.TESTFIELD("Bill-to Name");
                        SalesCredHdr.TESTFIELD("Bill-to Address");
                        IF STRLEN(SalesCredHdr."Bill-to Address") < 3 THEN
                            ERROR(AddrLenErr, 'Bill-to Address');
                        SalesCredHdr.TESTFIELD("Ship-to City");
                        IF SalesCredHdr."GST Customer Type" = SalesCredHdr."GST Customer Type"::Export THEN
                            EXIT;
                        SalesCredHdr.TESTFIELD("Customer GST Reg. No.");
                        StateBuff.GET(SalesCredHdr."GST Bill-to State Code");
                        //Customer.GET("Bill-to Customer No.");
                        //Customer.TESTFIELD("GST Registration No.");
                        //StateBuff.GET(Customer."State Code");
                        StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                    END;
                END;
        /*
        //EInvTrans >>
        5744:
          BEGIN
            TransferShipHdr := Variant;
            WITH TransferShipHdr DO BEGIN
              LocationBuff.GET("Transfer-to Code");
              LocationBuff.TESTFIELD("GST Registration No.");
              TESTFIELD("Transfer-to Name");
              TESTFIELD("Transfer-to Address");
              TESTFIELD("Transfer-to Address 2");
              //StateBuff.GET(Customer."State Code");
              StateBuff.GET(LocationBuff."State Code");
              StateBuff.TESTFIELD("State Code (GST Reg. No.)");
            END;
          END;
        //EInvTrans <<
        */
        END;
    end;

    local procedure CheckLineValidations(Variant: Variant);
    var
        RecRef: RecordRef;
        SalesLine: Record "Sales Line";
        SalesInvLine: Record "Sales Invoice Line";
        SalesCredLine: Record "Sales Cr.Memo Line";
        SalesCredHdr: Record "Sales Cr.Memo Header";
        SalesHeader: Record "Sales Header";
        SalesInvHdr: Record "Sales Invoice Header";
        UOM: Record "Unit of Measure";
    //GSTManagement: Codeunit 16401;
    begin
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            36:
                BEGIN
                    SalesHeader := Variant;
                    SalesLine.RESET;
                    SalesLine.SETRANGE("Document Type", SalesHeader."Document Type");
                    SalesLine.SETRANGE("Document No.", SalesHeader."No.");
                    //B2BUPG1.0>>
                    //SalesLine.SETFILTER("No.", '<>%1&<>%2&<>%3', '', GetInvRoundingAcc(SalesHeader), GetGSTRoundingAcc);
                    SalesLine.SETFILTER("No.", '<>%1&<>%2', '', GetInvRoundingAcc(SalesHeader));
                    //B2BUPG1.0<<
                    IF SalesLine.FINDSET THEN
                        REPEAT
                            SalesLine.TESTFIELD(Quantity);
                            IF SalesLine.Type = SalesLine.Type::Item THEN BEGIN
                                SalesLine.TESTFIELD("Unit of Measure Code");
                                UOM.GET(SalesLine."Unit of Measure Code");
                                //UOM.TESTFIELD(Code);
                                UOM.TESTFIELD("GST UQC Code B2B");
                            END;
                            //IF GSTManagement.IsGSTApplicable(Structure) THEN//HSNFix  //B2BUPG1.0
                            SalesLine.TESTFIELD("HSN/SAC Code");
                        UNTIL SalesLine.NEXT = 0;
                END;
            112:
                BEGIN
                    SalesInvHdr := Variant;
                    SalesInvLine.RESET;
                    SalesInvLine.SETRANGE("Document No.", SalesInvHdr."No.");
                    //B2BUPG1.0>>
                    //SalesInvLine.SETFILTER("No.", '<>%1&<>%2&<>%3', '', GetInvRoundingAcc(SalesInvHdr), GetGSTRoundingAcc);
                    SalesInvLine.SETFILTER("No.", '<>%1&<>%2', '', GetInvRoundingAcc(SalesInvHdr));
                    //B2BUPG1.0<<
                    SalesInvLine.SETFILTER(Quantity, '<>%1', 0);
                    IF SalesInvLine.FINDSET THEN
                        REPEAT
                            SalesInvLine.TESTFIELD(Quantity);
                            IF SalesInvLine.Type = SalesInvLine.Type::Item THEN BEGIN
                                SalesInvLine.TESTFIELD("Unit of Measure Code");
                                UOM.GET(SalesInvLine."Unit of Measure Code");
                                //UOM.TESTFIELD(Code);
                                UOM.TESTFIELD("GST UQC Code B2B");
                            END;
                            //IF GSTManagement.IsGSTApplicable(Structure) THEN//HSNFix  //B2BUPG1.0
                            SalesInvLine.TESTFIELD("HSN/SAC Code");
                        UNTIL SalesInvLine.NEXT = 0;
                END;
            114:
                BEGIN
                    SalesCredHdr := Variant;
                    SalesCredLine.RESET;
                    SalesCredLine.SETRANGE("Document No.", SalesCredHdr."No.");
                    //B2BUPG1.0>>
                    //SalesCredLine.SETFILTER("No.", '<>%1&<>%2&<>%3', '', GetInvRoundingAcc(SalesCredHdr), GetGSTRoundingAcc);
                    SalesCredLine.SETFILTER("No.", '<>%1&<>%2', '', GetInvRoundingAcc(SalesCredHdr));
                    //B2BUPG1.0<<
                    SalesCredLine.SETFILTER(Quantity, '<>%1', 0);
                    IF SalesCredLine.FINDSET THEN
                        REPEAT
                            SalesCredLine.TESTFIELD(Quantity);
                            IF SalesCredLine.Type = SalesCredLine.Type::Item THEN BEGIN
                                SalesCredLine.TESTFIELD("Unit of Measure Code");
                                UOM.GET(SalesCredLine."Unit of Measure Code");
                                //UOM.TESTFIELD(Code);
                                UOM.TESTFIELD("GST UQC Code B2B");
                            END;
                            //IF GSTManagement.IsGSTApplicable(Structure) THEN//HSNFix  //B2BUPG1.0
                            SalesCredLine.TESTFIELD("HSN/SAC Code");
                        UNTIL SalesCredLine.NEXT = 0;
                END;
        END;
    end;

    procedure CheckCancelIRNValidaitons(Variant: Variant);
    var
        SalesInvHead: Record "Sales Invoice Header";
        SalesCrdHead: Record "Sales Cr.Memo Header";
        ValidTo: DateTime;
        RecRef: RecordRef;
        EInvoiceEntry: Record "E-Invoice Entry";
        TransferShipmentHeader: Record "Transfer Shipment Header";
    begin
        CheckGSTEInvSetup;
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            112:
                BEGIN
                    SalesInvHead := Variant;
                    EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Invoice", SalesInvHead."No.");
                    EInvoiceEntry.TESTFIELD("IRN Cancelled", FALSE);
                    ValidTo := CREATEDATETIME(CALCDATE('1D', DT2DATE(EInvoiceEntry."Ack Date")), DT2TIME(EInvoiceEntry."Ack Date"));
                    IF ValidTo < CURRENTDATETIME THEN
                        ERROR(CancelValidToErr);

                    IF CheckCrMemoActiveApplicationExist(SalesInvHead) THEN
                        ERROR(CrMemoAppliedErr);
                END;
            114:
                BEGIN
                    SalesCrdHead := Variant;
                    EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Cr. Memo", SalesCrdHead."No.");
                    EInvoiceEntry.TESTFIELD("IRN Cancelled", FALSE);
                    ValidTo := CREATEDATETIME(CALCDATE('1D', DT2DATE(EInvoiceEntry."Ack Date")), DT2TIME(EInvoiceEntry."Ack Date"));
                    IF ValidTo < CURRENTDATETIME THEN
                        ERROR(CancelValidToErr);
                END;
            5744:
                BEGIN
                    TransferShipmentHeader := Variant;
                    EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Transfer Shipment", TransferShipmentHeader."No.");
                    EInvoiceEntry.TESTFIELD("IRN Cancelled", FALSE);
                    ValidTo := CREATEDATETIME(CALCDATE('1D', DT2DATE(EInvoiceEntry."Ack Date")), DT2TIME(EInvoiceEntry."Ack Date"));
                    IF ValidTo < CURRENTDATETIME THEN
                        ERROR(CancelValidToErr);
                END;
        END;
    end;

    local procedure GetInvRoundingAcc(Variant: Variant): Code[20];
    var
        CustomerPostingGroup: Record "Customer Posting Group";
        RecRef: RecordRef;
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            36:
                BEGIN
                    SalesHeader := Variant;
                    IF SalesHeader."Customer Posting Group" <> '' THEN
                        CustomerPostingGroup.GET(SalesHeader."Customer Posting Group");
                END;
            112:
                BEGIN
                    SalesInvoiceHeader := Variant;
                    IF SalesInvoiceHeader."Customer Posting Group" <> '' THEN
                        CustomerPostingGroup.GET(SalesInvoiceHeader."Customer Posting Group");
                END;
            114:
                BEGIN
                    SalesCrMemoHeader := Variant;
                    IF SalesCrMemoHeader."Customer Posting Group" <> '' THEN
                        CustomerPostingGroup.GET(SalesCrMemoHeader."Customer Posting Group");
                END;
        END;
        EXIT(CustomerPostingGroup."Invoice Rounding Account");
    end;

    //B2BUPG1.0>> - Commented due to missing of fields.
    /*local procedure GetGSTRoundingAcc(): Code[20];
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.GET;
        EXIT(GLSetup."GST Inv. Rounding Account");
    end;*/
    //B2BUPG1.0<<

    procedure CheckValidEntriesApplied(SalesHeader: Record "Sales Header");
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        SalesInvHdr: Record "Sales Invoice Header";
        ActiveInvoice: Boolean;
        InActiveInvoice: Boolean;
        EInvoiceEntry: Record "E-Invoice Entry";
        CustLedgEntry: Record "Cust. Ledger Entry";
        EInvoiceSetupL: Record "E-Invoice Setup";
    begin
        IF SalesHeader."Document Type" <> SalesHeader."Document Type"::"Credit Memo" THEN
            EXIT;
        EInvoiceSetupL.Get();
        ReferenceInvoiceNo.SETRANGE("Document Type", SalesHeader."Document Type".AsInteger());
        ReferenceInvoiceNo.SETRANGE("Document No.", SalesHeader."No.");
        ReferenceInvoiceNo.SETRANGE("Source No.", SalesHeader."Bill-to Customer No.");
        ReferenceInvoiceNo.SETRANGE("Source Type", ReferenceInvoiceNo."Source Type"::Customer);
        IF ReferenceInvoiceNo.FINDSET THEN
            REPEAT
                SalesInvHdr.GET(ReferenceInvoiceNo."Reference Invoice Nos.");
                //IF SalesInvHdr."Posting Date" >= DMY2DATE(1, 10, 2020) THEN BEGIN//Fix 01Oct2020
                IF SalesInvHdr."Posting Date" >= EInvoiceSetupL."Effective Date" THEN BEGIN
                    EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Invoice", SalesInvHdr."No.");
                    IF NOT ActiveInvoice THEN
                        ActiveInvoice := NOT EInvoiceEntry."IRN Cancelled";
                    IF NOT InActiveInvoice THEN
                        InActiveInvoice := EInvoiceEntry."IRN Cancelled";
                END;
            UNTIL (ReferenceInvoiceNo.NEXT = 0) OR (ActiveInvoice AND InActiveInvoice);

        //>>2016CU19
        // IF (SalesHeader."Applies-to Doc. Type" = SalesHeader."Applies-to Doc. Type"::Invoice) AND
        //  (SalesHeader."Applies-to Doc. No." <> '')
        // THEN BEGIN
        //  SalesInvHdr.GET(SalesHeader."Applies-to Doc. No.");
        //  EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Invoice",SalesInvHdr."No.");
        //  IF NOT ActiveInvoice THEN
        //    ActiveInvoice := NOT EInvoiceEntry."IRN Cancelled";
        //  IF NOT InActiveInvoice THEN
        //    InActiveInvoice := EInvoiceEntry."IRN Cancelled";
        // END ELSE IF SalesHeader."Applies-to ID" <> '' THEN BEGIN
        //  CustLedgEntry.RESET;
        //  CustLedgEntry.SETCURRENTKEY("Customer No.",Open);
        //  CustLedgEntry.SETRANGE("Customer No.",SalesHeader."Bill-to Customer No.");
        //  CustLedgEntry.SETRANGE(Open,TRUE);
        //  CustLedgEntry.SETRANGE("Applies-to ID",SalesHeader."Applies-to ID");
        //  IF CustLedgEntry.FINDSET THEN
        //    REPEAT
        //      IF SalesInvHdr.GET(CustLedgEntry."Document No.") THEN
        //          IF SalesInvHdr."Posting Date" >= DMY2DATE(1,10,2020) THEN BEGIN//Fix 01Oct2020
        //            EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Invoice",SalesInvHdr."No.");
        //            IF NOT ActiveInvoice THEN
        //              ActiveInvoice := NOT EInvoiceEntry."IRN Cancelled";
        //            IF NOT InActiveInvoice THEN
        //              InActiveInvoice := EInvoiceEntry."IRN Cancelled";
        //          END;
        //    UNTIL (CustLedgEntry.NEXT = 0) OR (ActiveInvoice AND InActiveInvoice);
        // END;
        //<<2016CU19
        IF ActiveInvoice AND InActiveInvoice THEN
            ERROR(ActiveInActiveInvErr);
    end;

    local procedure CheckCrMemoActiveApplicationExist(SalesInvHdr: Record "Sales Invoice Header"): Boolean;
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ActiveApplicationFound: Boolean;
        EInvoiceEntry: Record "E-Invoice Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        AppliedCustLedgEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SETRANGE("Document No.", SalesInvHdr."No.");
        CustLedgerEntry.SETRANGE("Posting Date", SalesInvHdr."Posting Date");
        CustLedgerEntry.FINDFIRST;

        FindApplnEntriesDtldtLedgEntry(CustLedgerEntry, AppliedCustLedgEntry);
        AppliedCustLedgEntry.MARKEDONLY(TRUE);
        IF AppliedCustLedgEntry.FINDSET THEN
            REPEAT
                IF SalesCrMemoHeader.GET(AppliedCustLedgEntry."Document No.") THEN BEGIN
                    EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Cr. Memo", SalesCrMemoHeader."No.");
                    ActiveApplicationFound := (NOT EInvoiceEntry."IRN Cancelled");
                END;
            UNTIL (AppliedCustLedgEntry.NEXT = 0) OR ActiveApplicationFound;

        EXIT(ActiveApplicationFound);
    end;

    procedure IsInActiveInvoiceApplied(SalesCrMemoHeader: Record "Sales Cr.Memo Header"): Boolean;
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        SalesInvHdr: Record "Sales Invoice Header";
        ActiveInvoice: Boolean;
        InActiveInvoice: Boolean;
        EInvoiceEntry: Record "E-Invoice Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        AppliedCustLedgEntry: Record "Cust. Ledger Entry";
        EInvoiceSetupL: Record "E-Invoice Setup";
    begin
        EInvoiceSetupL.Get();
        ReferenceInvoiceNo.SETRANGE("Document No.", SalesCrMemoHeader."No.");
        IF ReferenceInvoiceNo.FINDSET THEN
            REPEAT
                SalesInvHdr.GET(ReferenceInvoiceNo."Reference Invoice Nos.");
                //IF SalesInvHdr."Posting Date" >= DMY2DATE(1, 10, 2020) THEN BEGIN//Fix 01Oct2020
                IF SalesInvHdr."Posting Date" >= EInvoiceSetupL."Effective Date" THEN BEGIN
                    EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Invoice", SalesInvHdr."No.");
                    InActiveInvoice := (EInvoiceEntry."IRN No." = '') OR EInvoiceEntry."IRN Cancelled";
                END;
            UNTIL (ReferenceInvoiceNo.NEXT = 0) OR InActiveInvoice
        ELSE BEGIN
            CustLedgerEntry.SETRANGE("Document No.", SalesCrMemoHeader."No.");
            CustLedgerEntry.SETRANGE("Posting Date", SalesCrMemoHeader."Posting Date");
            CustLedgerEntry.FINDFIRST;

            FindApplnEntriesDtldtLedgEntry(CustLedgerEntry, AppliedCustLedgEntry);
            AppliedCustLedgEntry.MARKEDONLY(TRUE);
            IF AppliedCustLedgEntry.FINDSET THEN
                REPEAT
                    IF SalesInvHdr.GET(AppliedCustLedgEntry."Document No.") THEN
                        //IF SalesInvHdr."Posting Date" >= DMY2DATE(1, 10, 2020) THEN BEGIN//Fix 01Oct2020
                        IF SalesInvHdr."Posting Date" >= EInvoiceSetupL."Effective Date" THEN BEGIN
                            EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Invoice", SalesInvHdr."No.");
                            InActiveInvoice := (EInvoiceEntry."IRN No." = '') OR EInvoiceEntry."IRN Cancelled";
                        END;
                UNTIL (AppliedCustLedgEntry.NEXT = 0) OR InActiveInvoice;
        END;

        EXIT(InActiveInvoice);
    end;

    local procedure FindApplnEntriesDtldtLedgEntry(CreateCustLedgEntry: Record "Cust. Ledger Entry"; var AppliedCustLedgEntry: Record "Cust. Ledger Entry");
    var
        DtldCustLedgEntry1: Record "Detailed Cust. Ledg. Entry";
        DtldCustLedgEntry2: Record "Detailed Cust. Ledg. Entry";
    begin
        DtldCustLedgEntry1.SETCURRENTKEY("Cust. Ledger Entry No.");
        DtldCustLedgEntry1.SETRANGE("Cust. Ledger Entry No.", CreateCustLedgEntry."Entry No.");
        DtldCustLedgEntry1.SETRANGE(Unapplied, FALSE);
        IF DtldCustLedgEntry1.FIND('-') THEN
            REPEAT
                IF DtldCustLedgEntry1."Cust. Ledger Entry No." =
                   DtldCustLedgEntry1."Applied Cust. Ledger Entry No."
                THEN BEGIN
                    DtldCustLedgEntry2.INIT;
                    DtldCustLedgEntry2.SETCURRENTKEY("Applied Cust. Ledger Entry No.", "Entry Type");
                    DtldCustLedgEntry2.SETRANGE(
                      "Applied Cust. Ledger Entry No.", DtldCustLedgEntry1."Applied Cust. Ledger Entry No.");
                    DtldCustLedgEntry2.SETRANGE("Entry Type", DtldCustLedgEntry2."Entry Type"::Application);
                    DtldCustLedgEntry2.SETRANGE(Unapplied, FALSE);
                    IF DtldCustLedgEntry2.FIND('-') THEN
                        REPEAT
                            IF DtldCustLedgEntry2."Cust. Ledger Entry No." <>
                               DtldCustLedgEntry2."Applied Cust. Ledger Entry No."
                            THEN BEGIN
                                AppliedCustLedgEntry.SETCURRENTKEY("Entry No.");
                                AppliedCustLedgEntry.SETRANGE("Entry No.", DtldCustLedgEntry2."Cust. Ledger Entry No.");
                                IF AppliedCustLedgEntry.FIND('-') THEN
                                    AppliedCustLedgEntry.MARK(TRUE);
                            END;
                        UNTIL DtldCustLedgEntry2.NEXT = 0;
                END ELSE BEGIN
                    AppliedCustLedgEntry.SETCURRENTKEY("Entry No.");
                    AppliedCustLedgEntry.SETRANGE("Entry No.", DtldCustLedgEntry1."Applied Cust. Ledger Entry No.");
                    IF AppliedCustLedgEntry.FIND('-') THEN
                        AppliedCustLedgEntry.MARK(TRUE);
                END;
            UNTIL DtldCustLedgEntry1.NEXT = 0;
    end;

    procedure CheckGenerateIRNValidaitons(Variant: Variant);
    var
        SalesInvHead: Record "Sales Invoice Header";
        SalesCrdHead: Record "Sales Cr.Memo Header";
        ValidTo: DateTime;
        RecRef: RecordRef;
        EInvoiceEntry: Record "E-Invoice Entry";
    begin
        //>> ValidIRNFix
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            112:
                BEGIN
                    SalesInvHead := Variant;
                    IF CheckCrMemoApplicationExist(SalesInvHead) THEN
                        ERROR(CrMemoAppliedErr2);
                END;
            114:
                BEGIN
                    SalesCrdHead := Variant;
                    IF IsInActiveInvoiceApplied(SalesCrdHead) THEN
                        ERROR(InActiveInvAppliedErr);
                END;
        END;
        //<< ValidIRNFix
    end;

    local procedure CheckCrMemoApplicationExist(SalesInvHdr: Record "Sales Invoice Header"): Boolean;
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ApplicationFound: Boolean;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        AppliedCustLedgEntry: Record "Cust. Ledger Entry";
    begin
        //>> ValidIRNFix
        CustLedgerEntry.SETRANGE("Document No.", SalesInvHdr."No.");
        CustLedgerEntry.SETRANGE("Posting Date", SalesInvHdr."Posting Date");
        CustLedgerEntry.FINDFIRST;

        FindApplnEntriesDtldtLedgEntry(CustLedgerEntry, AppliedCustLedgEntry);
        AppliedCustLedgEntry.MARKEDONLY(TRUE);
        IF AppliedCustLedgEntry.FINDSET THEN
            REPEAT
                ApplicationFound := SalesCrMemoHeader.GET(AppliedCustLedgEntry."Document No.");
            UNTIL (AppliedCustLedgEntry.NEXT = 0) OR ApplicationFound;

        EXIT(ApplicationFound);
        //<< ValidIRNFix
    end;

    //B2BUPGSERVICE1.0>> Service Orders
    local procedure "-----Service Order------"();
    begin
    end;

    procedure CheckValidationsService(Variant: Variant);
    var
        CompanyInformation: Record 79;
        LocationBuff: Record 14;
        StateBuff: Record State;
        SalesLine: Record 37;
        Contact: Record 5050;
        ShipToAddr: Record 222;
    begin
        CheckGSTEInvSetupService;
        CheckSellerValidationsService(Variant);
        CheckBuyerValidationsService(Variant);
        CheckShipToValidationsService(Variant);
        CheckLineValidationsService(Variant);
        CheckGenerateIRNValidaitonsService(Variant);//ValidIRNFix
    end;

    local procedure CheckGSTEInvSetupService();
    var
        EInvoiceSetup: Record "E-Invoice Setup";
    begin
        EInvoiceSetup.GET;
        EInvoiceSetup.TESTFIELD("Request URL");
        //   EInvoiceSetup.TESTFIELD("JSON Request Path");
        //  EInvoiceSetup.TESTFIELD("JSON Response Path");
        // EInvoiceSetup.TESTFIELD("User Name");
        // EInvoiceSetup.TESTFIELD(Password);
        //  EInvoiceSetup.TESTFIELD("Access Token Response Path");
        //EInvoiceSetup.TESTFIELD("Access Token Period");//TokenExpiryFix
        EInvoiceSetup.TESTFIELD("Cancel Request URL");
    end;

    local procedure CheckSellerValidationsService(Variant: Variant);
    var
        RecRef: RecordRef;
        ServiceHeader: Record "Service Header";
        ServiceInvHdr: Record "Service Invoice Header";
        ServiceCredHdr: Record "Service Cr.Memo Header";
        CompanyInfo: Record 79;
        LocationBuff: Record Location;
        StateBuff: Record State;
        PostindDateErr: Label 'The posting date should be today or yesterday.';
    begin
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            5900:
                BEGIN
                    ServiceHeader := Variant;
                    ServiceHeader.TESTFIELD("Posting Date");
                    //IF NOT ("Posting Date" IN [TODAY,TODAY - 1]) THEN
                    // ERROR(PostindDateErr);//v1.03
                    ServiceHeader.TESTFIELD("Location Code");
                    LocationBuff.GET(ServiceHeader."Location Code");
                    //LocationBuff.TESTFIELD("GST Registration No.");//2016CU19
                    ServiceHeader.TESTFIELD("Location GST Reg. No.");
                    //LocationBuff.TESTFIELD("User Name");
                    //LocationBuff.TESTFIELD(Password);
                    CompanyInfo.GET;
                    CompanyInfo.TESTFIELD(Name);
                    LocationBuff.TESTFIELD(Address);
                    IF STRLEN(LocationBuff.Address) < 3 THEN
                        ERROR(AddrLenErr, 'Location');
                    LocationBuff.TESTFIELD(City);
                    LocationBuff.TESTFIELD("Post Code");
                    LocationBuff.TESTFIELD("State Code");
                    StateBuff.GET(LocationBuff."State Code");
                    StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                END;
            5992:
                BEGIN
                    ServiceInvHdr := Variant;
                    //        IF NOT ("Posting Date" IN [TODAY,TODAY - 1]) THEN
                    //          ERROR(PostindDateErr);//v1.03
                    ServiceInvHdr.TESTFIELD("Location Code");
                    LocationBuff.GET(ServiceInvHdr."Location Code");
                    //LocationBuff.TESTFIELD("GST Registration No.");//2016CU19
                    ServiceInvHdr.TESTFIELD("Location GST Reg. No.");
                    //LocationBuff.TESTFIELD("User Name");
                    //LocationBuff.TESTFIELD(Password);
                    CompanyInfo.GET;
                    CompanyInfo.TESTFIELD(Name);
                    LocationBuff.TESTFIELD(Address);
                    IF STRLEN(LocationBuff.Address) < 3 THEN
                        ERROR(AddrLenErr, 'Location');
                    LocationBuff.TESTFIELD(City);
                    LocationBuff.TESTFIELD("Post Code");
                    LocationBuff.TESTFIELD("State Code");
                    StateBuff.GET(LocationBuff."State Code");
                    StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                END;
            5994:
                BEGIN
                    ServiceCredHdr := Variant;
                    //ValidIRNFix >>
                    /*
                    IF IsCancelledInvoiceApplied(SalesCredHdr) THEN
                      ERROR(CancelInvAppliedErr);
                    */
                    //ValidIRNFix <<
                    //        IF NOT ("Posting Date" IN [TODAY,TODAY - 1]) THEN
                    //          ERROR(PostindDateErr);//v1.03
                    ServiceCredHdr.TESTFIELD("Location Code");
                    LocationBuff.GET(ServiceCredHdr."Location Code");
                    //LocationBuff.TESTFIELD("GST Registration No.");//2016CU19
                    ServiceCredHdr.TESTFIELD("Location GST Reg. No.");
                    //LocationBuff.TESTFIELD("User Name");
                    //LocationBuff.TESTFIELD(Password);
                    CompanyInfo.GET;
                    CompanyInfo.TESTFIELD(Name);
                    LocationBuff.TESTFIELD(Address);
                    IF STRLEN(LocationBuff.Address) < 3 THEN
                        ERROR(AddrLenErr, 'Location');
                    LocationBuff.TESTFIELD(City);
                    LocationBuff.TESTFIELD("Post Code");
                    LocationBuff.TESTFIELD("State Code");
                    StateBuff.GET(LocationBuff."State Code");
                    StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                END;
        END;

    end;

    local procedure CheckBuyerValidationsService(Variant: Variant);
    var
        RecRef: RecordRef;
        ServiceCredHdr: Record "Service Cr.Memo Header";
        ServiceHeader: Record "Service Header";
        ServiceInvHdr: Record "Service Invoice Header";
        LocationBuff: Record Location;
        StateBuff: Record State;
        ServiceInvoiceLine: Record "Service Invoice Line";
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
        ServiceLine: Record "Service Line";
        Customer: Record Customer;
        ShipToAddr: Record "Ship-to Address";
    begin
        //>> POSShipToGSTINFix
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            5900:
                BEGIN
                    ServiceHeader := Variant;
                    IF ServiceHeader."GST Customer Type" = ServiceHeader."GST Customer Type"::Export THEN BEGIN
                        ServiceHeader.TESTFIELD("Bill-to Name");
                        ServiceHeader.TESTFIELD("Bill-to Address");
                        IF STRLEN(ServiceHeader."Bill-to Address") < 3 THEN
                            ERROR(AddrLenErr, 'Bill-to Address');
                        ServiceHeader.TESTFIELD("Bill-to City");
                    END ELSE BEGIN
                        ServiceHeader.TESTFIELD("Customer GST Reg. No.");
                        //Customer.GET("Bill-to Customer No.");
                        //Customer.TESTFIELD("GST Registration No.");
                        ServiceLine.SETRANGE("Document No.", ServiceHeader."No.");
                        ServiceLine.SETFILTER("No.", '<>%1', '');
                        IF ServiceLine.FINDFIRST THEN
                            IF (ServiceLine."GST Place Of Supply" = ServiceLine."GST Place Of Supply"::"Ship-to Address") AND
                              (ShipToAddr.GET(ServiceHeader."Customer No.", ServiceHeader."Ship-to Code"))
                            THEN BEGIN
                                ServiceHeader.TESTFIELD("Ship-to Name");
                                ServiceHeader.TESTFIELD("Ship-to Address");
                                IF STRLEN(ServiceHeader."Ship-to Address") < 3 THEN
                                    ERROR(AddrLenErr, 'Ship-to Address');
                                ServiceHeader.TESTFIELD("Ship-to City");
                                //RtnOrdFix >>
                                //              TESTFIELD("GST Ship-to State Code");
                                //              StateBuff.GET("GST Ship-to State Code");
                                //ShipToAddr.GET("Sell-to Customer No.","Ship-to Code");
                                StateBuff.GET(ShipToAddr.State);
                                //RtnOrdFix <<
                                StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                            END ELSE BEGIN
                                ServiceHeader.TESTFIELD("Bill-to Name");
                                ServiceHeader.TESTFIELD("Bill-to Address");
                                IF STRLEN(ServiceHeader."Bill-to Address") < 3 THEN
                                    ERROR(AddrLenErr, 'Bill-to Address');
                                ServiceHeader.TESTFIELD("Bill-to City");
                                ServiceHeader.TESTFIELD("GST Bill-to State Code");
                                StateBuff.GET(ServiceHeader."GST Bill-to State Code");
                                //Customer.GET("Bill-to Customer No.");
                                //StateBuff.GET(Customer."State Code");
                                StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                            END;
                    END;
                END;
            5992:
                BEGIN
                    ServiceInvHdr := Variant;
                    IF ServiceInvHdr."GST Customer Type" = ServiceInvHdr."GST Customer Type"::Export THEN BEGIN
                        ServiceInvHdr.TESTFIELD("Bill-to Name");
                        ServiceInvHdr.TESTFIELD("Bill-to Address");
                        IF STRLEN(ServiceInvHdr."Bill-to Address") < 3 THEN
                            ERROR(AddrLenErr, 'Bill-to Address');
                        ServiceInvHdr.TESTFIELD("Bill-to City");
                    END ELSE BEGIN
                        ServiceInvHdr.TESTFIELD("Customer GST Reg. No.");
                        //Customer.GET("Bill-to Customer No.");
                        //Customer.TESTFIELD("GST Registration No.");
                        ServiceInvoiceLine.SETRANGE("Document No.", ServiceInvHdr."No.");
                        ServiceInvoiceLine.SETFILTER("No.", '<>%1', '');
                        IF ServiceInvoiceLine.FINDFIRST THEN
                            IF (ServiceInvoiceLine."GST Place Of Supply" = ServiceInvoiceLine."GST Place Of Supply"::"Ship-to Address") AND
                              (ShipToAddr.GET(ServiceInvHdr."Customer No.", ServiceInvHdr."Ship-to Code"))
                            THEN BEGIN
                                ServiceInvHdr.TESTFIELD("Ship-to Name");
                                ServiceInvHdr.TESTFIELD("Ship-to Address");
                                IF STRLEN(ServiceInvHdr."Ship-to Address") < 3 THEN
                                    ERROR(AddrLenErr, 'Ship-to Address');
                                ServiceInvHdr.TESTFIELD("Ship-to City");
                                //RtnOrdFix >>
                                //              TESTFIELD("GST Ship-to State Code");
                                //              StateBuff.GET("GST Ship-to State Code");
                                //ShipToAddr.GET("Sell-to Customer No.","Ship-to Code");
                                StateBuff.GET(ShipToAddr.State);
                                //RtnOrdFix <<
                                StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                            END ELSE BEGIN
                                ServiceInvHdr.TESTFIELD("Bill-to Name");
                                ServiceInvHdr.TESTFIELD("Bill-to Address");
                                IF STRLEN(ServiceInvHdr."Bill-to Address") < 3 THEN
                                    ERROR(AddrLenErr, 'Bill-to Address');
                                ServiceInvHdr.TESTFIELD("Bill-to City");
                                ServiceInvHdr.TESTFIELD("GST Bill-to State Code");
                                StateBuff.GET(ServiceInvHdr."GST Bill-to State Code");
                                //Customer.GET("Bill-to Customer No.");
                                //StateBuff.GET(Customer."State Code");
                                StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                            END;
                    END;
                END;
            5994:
                BEGIN
                    ServiceCredHdr := Variant;
                    IF ServiceCredHdr."GST Customer Type" = ServiceCredHdr."GST Customer Type"::Export THEN BEGIN
                        ServiceCredHdr.TESTFIELD("Bill-to Name");
                        ServiceCredHdr.TESTFIELD("Bill-to Address");
                        IF STRLEN(ServiceCredHdr."Bill-to Address") < 3 THEN
                            ERROR(AddrLenErr, 'Bill-to Address');
                        ServiceCredHdr.TESTFIELD("Bill-to City");
                    END ELSE BEGIN
                        ServiceCredHdr.TESTFIELD("Customer GST Reg. No.");
                        //Customer.GET("Bill-to Customer No.");
                        //Customer.TESTFIELD("GST Registration No.");
                        ServiceCrMemoLine.SETRANGE("Document No.", ServiceCredHdr."No.");
                        ServiceCrMemoLine.SETFILTER("No.", '<>%1', '');
                        IF ServiceCrMemoLine.FINDFIRST THEN
                            IF (ServiceCrMemoLine."GST Place Of Supply" = ServiceCrMemoLine."GST Place Of Supply"::"Ship-to Address") AND
                              (ShipToAddr.GET(ServiceCredHdr."Customer No.", ServiceCredHdr."Ship-to Code"))
                            THEN BEGIN
                                ServiceCredHdr.TESTFIELD("Ship-to Name");
                                ServiceCredHdr.TESTFIELD("Ship-to Address");
                                IF STRLEN(ServiceCredHdr."Ship-to Address") < 3 THEN
                                    ERROR(AddrLenErr, 'Ship-to Address');
                                ServiceCredHdr.TESTFIELD("Ship-to City");
                                //RtnOrdFix >>
                                //              TESTFIELD("GST Ship-to State Code");
                                //              StateBuff.GET("GST Ship-to State Code");
                                //ShipToAddr.GET("Sell-to Customer No.","Ship-to Code");
                                StateBuff.GET(ShipToAddr.State);
                                //RtnOrdFix <<
                                StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                            END ELSE BEGIN
                                ServiceCredHdr.TESTFIELD("Bill-to Name");
                                ServiceCredHdr.TESTFIELD("Bill-to Address");
                                IF STRLEN(ServiceCredHdr."Bill-to Address") < 3 THEN
                                    ERROR(AddrLenErr, 'Bill-to Address');
                                ServiceCredHdr.TESTFIELD("Bill-to City");
                                ServiceCredHdr.TESTFIELD("GST Bill-to State Code");
                                StateBuff.GET(ServiceCredHdr."GST Bill-to State Code");
                                //Customer.GET("Bill-to Customer No.");
                                //StateBuff.GET(Customer."State Code");
                                StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                            END;
                    END;
                END;
        END;
        //<< POSShipToGSTINFix
    end;

    local procedure CheckShipToValidationsService(Variant: Variant);
    var
        RecRef: RecordRef;
        ShipToAddr: Record "Ship-to Address";
        ServiceLine: Record "Service Line";
        ServiceInvLine: Record "Service Invoice Line";
        ServiceCredLine: Record "Service Cr.Memo Line";
        StateBuff: Record State;
        ServiceCredHdr: Record "Service Cr.Memo Header";
        ServiceHeader: Record "Service Header";
        ServiceInvHdr: Record "Service Invoice Header";
        Customer: Record Customer;
    begin
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            5900:
                BEGIN
                    ServiceHeader := Variant;
                    IF ShipToAddr.GET(ServiceHeader."Customer No.", ServiceHeader."Ship-to Code") THEN BEGIN
                        ServiceHeader.TESTFIELD("Ship-to Name");
                        ServiceHeader.TESTFIELD("Ship-to Address");
                        IF STRLEN(ServiceHeader."Ship-to Address") < 3 THEN
                            ERROR(AddrLenErr, 'Ship-to Address');
                        ServiceHeader.TESTFIELD("Ship-to City");
                        IF ServiceHeader."GST Customer Type" = ServiceHeader."GST Customer Type"::Export THEN
                            EXIT;
                        //ShipToAddr.TESTFIELD("GST Registration No.");
                        //RtnOrdFix >>
                        //StateBuff.GET("GST Ship-to State Code");
                        ShipToAddr.TESTFIELD(State);
                        StateBuff.GET(ShipToAddr.State);
                        //RtnOrdFix <<
                        StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                    END ELSE BEGIN
                        ServiceHeader.TESTFIELD("Bill-to Name");
                        ServiceHeader.TESTFIELD("Bill-to Address");
                        IF STRLEN(ServiceHeader."Bill-to Address") < 3 THEN
                            ERROR(AddrLenErr, 'Bill-to Address');
                        ServiceHeader.TESTFIELD("Ship-to City");
                        IF ServiceHeader."GST Customer Type" = ServiceHeader."GST Customer Type"::Export THEN
                            EXIT;
                        ServiceHeader.TESTFIELD("Customer GST Reg. No.");
                        StateBuff.GET(ServiceHeader."GST Bill-to State Code");
                        //Customer.GET("Bill-to Customer No.");
                        //Customer.TESTFIELD("GST Registration No.");
                        //StateBuff.GET(Customer."State Code");
                        StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                    END;
                END;
            5992:
                BEGIN
                    ServiceInvHdr := Variant;
                    IF ShipToAddr.GET(ServiceInvHdr."Customer No.", ServiceInvHdr."Ship-to Code") THEN BEGIN
                        ServiceInvHdr.TESTFIELD("Ship-to Name");
                        ServiceInvHdr.TESTFIELD("Ship-to Address");
                        IF STRLEN(ServiceInvHdr."Ship-to Address") < 3 THEN
                            ERROR(AddrLenErr, 'Ship-to Address');
                        ServiceInvHdr.TESTFIELD("Ship-to City");
                        IF ServiceInvHdr."GST Customer Type" = ServiceInvHdr."GST Customer Type"::Export THEN
                            EXIT;
                        //ShipToAddr.TESTFIELD("GST Registration No.");
                        //RtnOrdFix >>
                        //StateBuff.GET("GST Ship-to State Code");
                        ShipToAddr.TESTFIELD(State);
                        StateBuff.GET(ShipToAddr.State);
                        //RtnOrdFix <<
                        StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                    END ELSE BEGIN
                        ServiceInvHdr.TESTFIELD("Bill-to Name");
                        ServiceInvHdr.TESTFIELD("Bill-to Address");
                        IF STRLEN(ServiceInvHdr."Bill-to Address") < 3 THEN
                            ERROR(AddrLenErr, 'Bill-to Address');
                        ServiceInvHdr.TESTFIELD("Ship-to City");
                        IF ServiceInvHdr."GST Customer Type" = ServiceInvHdr."GST Customer Type"::Export THEN
                            EXIT;
                        ServiceInvHdr.TESTFIELD("Customer GST Reg. No.");
                        StateBuff.GET(ServiceInvHdr."GST Bill-to State Code");
                        //Customer.GET("Bill-to Customer No.");
                        //Customer.TESTFIELD("GST Registration No.");
                        //StateBuff.GET(Customer."State Code");
                        StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                    END;
                END;
            5994:
                BEGIN
                    ServiceCredHdr := Variant;
                    IF ShipToAddr.GET(ServiceCredHdr."Customer No.", ServiceCredHdr."Ship-to Code") THEN BEGIN
                        ServiceCredHdr.TESTFIELD("Ship-to Name");
                        ServiceCredHdr.TESTFIELD("Ship-to Address");
                        IF STRLEN(ServiceCredHdr."Ship-to Address") < 3 THEN
                            ERROR(AddrLenErr, 'Ship-to Address');
                        ServiceCredHdr.TESTFIELD("Ship-to City");
                        IF ServiceCredHdr."GST Customer Type" = ServiceCredHdr."GST Customer Type"::Export THEN
                            EXIT;
                        //ShipToAddr.TESTFIELD("GST Registration No.");
                        //RtnOrdFix >>
                        //StateBuff.GET("GST Ship-to State Code");
                        ShipToAddr.TESTFIELD(State);
                        StateBuff.GET(ShipToAddr.State);
                        //RtnOrdFix <<
                        StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                    END ELSE BEGIN
                        ServiceCredHdr.TESTFIELD("Bill-to Name");
                        ServiceCredHdr.TESTFIELD("Bill-to Address");
                        IF STRLEN(ServiceCredHdr."Bill-to Address") < 3 THEN
                            ERROR(AddrLenErr, 'Bill-to Address');
                        ServiceCredHdr.TESTFIELD("Ship-to City");
                        IF ServiceCredHdr."GST Customer Type" = ServiceCredHdr."GST Customer Type"::Export THEN
                            EXIT;
                        ServiceCredHdr.TESTFIELD("Customer GST Reg. No.");
                        StateBuff.GET(ServiceCredHdr."GST Bill-to State Code");
                        //Customer.GET("Bill-to Customer No.");
                        //Customer.TESTFIELD("GST Registration No.");
                        //StateBuff.GET(Customer."State Code");
                        StateBuff.TESTFIELD("State Code (GST Reg. No.)");
                    END;
                END;
        END;
    end;

    local procedure CheckLineValidationsService(Variant: Variant);
    var
        RecRef: RecordRef;
        ServiceLine: Record "Service Line";
        ServiceInvLine: Record "Service Invoice Line";
        ServiceCredLine: Record "Service Cr.Memo Line";
        ServiceCredHdr: Record "Service Cr.Memo Header";
        ServiceHeader: Record "Service Header";
        ServiceInvHdr: Record "Service Invoice Header";
        UOM: Record 204;
    //GSTManagement: Codeunit "16401";
    begin
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            5900:
                BEGIN
                    ServiceHeader := Variant;
                    ServiceLine.RESET;
                    ServiceLine.SETRANGE("Document Type", ServiceHeader."Document Type");
                    ServiceLine.SETRANGE("Document No.", ServiceHeader."No.");
                    //B2BUPG1.0>>
                    //ServiceLine.SETFILTER("No.", '<>%1&<>%2&<>%3', '', GetInvRoundingAccService(ServiceHeader), GetGSTRoundingAccService);
                    ServiceLine.SETFILTER("No.", '<>%1&<>%2', '', GetInvRoundingAccService(ServiceHeader));
                    //B2BUPG1.0<<
                    IF ServiceLine.FINDSET THEN
                        REPEAT
                            ServiceLine.TESTFIELD(Quantity);
                            IF ServiceLine.Type = ServiceLine.Type::Item THEN BEGIN
                                ServiceLine.TESTFIELD("Unit of Measure Code");
                                UOM.GET(ServiceLine."Unit of Measure Code");
                                //UOM.TESTFIELD(Code);
                                UOM.TESTFIELD("GST UQC Code B2B");
                            END;
                            //IF GSTManagement.IsGSTApplicable(Structure) THEN//HSNFix //B2BUPG1.0
                            ServiceLine.TESTFIELD("HSN/SAC Code");
                        UNTIL ServiceLine.NEXT = 0;
                END;
            5992:
                BEGIN
                    ServiceInvHdr := Variant;
                    ServiceInvLine.RESET;
                    ServiceInvLine.SETRANGE("Document No.", ServiceInvHdr."No.");
                    //B2BUPG1.0>>
                    //ServiceInvLine.SETFILTER("No.", '<>%1&<>%2&<>%3', '', GetInvRoundingAccService(ServiceInvHdr), GetGSTRoundingAccService);
                    ServiceInvLine.SETFILTER("No.", '<>%1&<>%2', '', GetInvRoundingAccService(ServiceHeader));
                    //B2BUPG1.0<<
                    ServiceInvLine.SETFILTER(Quantity, '<>%1', 0);
                    IF ServiceInvLine.FINDSET THEN
                        REPEAT
                            ServiceInvLine.TESTFIELD(Quantity);
                            IF ServiceInvLine.Type = ServiceInvLine.Type::Item THEN BEGIN
                                ServiceInvLine.TESTFIELD("Unit of Measure Code");
                                UOM.GET(ServiceInvLine."Unit of Measure Code");
                                //UOM.TESTFIELD(Code);
                                UOM.TESTFIELD("GST UQC Code B2B");
                            END;
                            //IF GSTManagement.IsGSTApplicable(Structure) THEN//HSNFix B2BUPG1.0
                            ServiceInvLine.TESTFIELD("HSN/SAC Code");
                        UNTIL ServiceInvLine.NEXT = 0;
                END;
            5994:
                BEGIN
                    ServiceCredHdr := Variant;
                    ServiceCredLine.RESET;
                    ServiceCredLine.SETRANGE("Document No.", ServiceCredHdr."No.");
                    //B2BUPG1.0>>
                    //ServiceCredLine.SETFILTER("No.", '<>%1&<>%2&<>%3', '', GetInvRoundingAccService(ServiceCredHdr), GetGSTRoundingAccService);
                    ServiceCredLine.SETFILTER("No.", '<>%1&<>%2', '', GetInvRoundingAccService(ServiceHeader));
                    //B2BUPG1.0<<
                    ServiceCredLine.SETFILTER(Quantity, '<>%1', 0);
                    IF ServiceCredLine.FINDSET THEN
                        REPEAT
                            ServiceCredLine.TESTFIELD(Quantity);
                            IF ServiceCredLine.Type = ServiceCredLine.Type::Item THEN BEGIN
                                ServiceCredLine.TESTFIELD("Unit of Measure Code");
                                UOM.GET(ServiceCredLine."Unit of Measure Code");
                                //UOM.TESTFIELD(Code);
                                UOM.TESTFIELD("GST UQC Code B2B");
                            END;
                            //IF GSTManagement.IsGSTApplicable(Structure) THEN//HSNFix B2BUPG1.0
                            ServiceCredLine.TESTFIELD("HSN/SAC Code");
                        UNTIL ServiceCredLine.NEXT = 0;
                END;
        END;
    end;

    procedure CheckCancelIRNValidaitonsService(Variant: Variant);
    var
        ServiceInvHead: Record "Service Invoice Header";
        ServiceCrdHead: Record "Service Cr.Memo Header";
        ValidTo: DateTime;
        RecRef: RecordRef;
        EInvoiceEntry: Record "E-Invoice Entry";
    begin
        CheckGSTEInvSetup;
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            5992:
                BEGIN
                    ServiceInvHead := Variant;
                    EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Invoice", ServiceInvHead."No.");
                    EInvoiceEntry.TESTFIELD("IRN Cancelled", FALSE);
                    ValidTo := CREATEDATETIME(CALCDATE('1D', DT2DATE(EInvoiceEntry."Ack Date")), DT2TIME(EInvoiceEntry."Ack Date"));
                    IF ValidTo < CURRENTDATETIME THEN
                        ERROR(CancelValidToErr);

                    IF CheckCrMemoActiveApplicationExistService(ServiceInvHead) THEN
                        ERROR(CrMemoAppliedErr);
                END;
            5994:
                BEGIN
                    ServiceCrdHead := Variant;
                    EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Cr. Memo", ServiceCrdHead."No.");
                    EInvoiceEntry.TESTFIELD("IRN Cancelled", FALSE);
                    ValidTo := CREATEDATETIME(CALCDATE('1D', DT2DATE(EInvoiceEntry."Ack Date")), DT2TIME(EInvoiceEntry."Ack Date"));
                    IF ValidTo < CURRENTDATETIME THEN
                        ERROR(CancelValidToErr);
                END;
        END;
    end;

    local procedure GetInvRoundingAccService(Variant: Variant): Code[20];
    var
        CustomerPostingGroup: Record 92;
        RecRef: RecordRef;
        ServiceHeader: Record "Service Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
    begin
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            5900:
                BEGIN
                    ServiceHeader := Variant;
                    IF ServiceHeader."Customer Posting Group" <> '' THEN
                        CustomerPostingGroup.GET(ServiceHeader."Customer Posting Group");
                END;
            5992:
                BEGIN
                    ServiceInvoiceHeader := Variant;
                    IF ServiceInvoiceHeader."Customer Posting Group" <> '' THEN
                        CustomerPostingGroup.GET(ServiceInvoiceHeader."Customer Posting Group");
                END;
            5994:
                BEGIN
                    ServiceCrMemoHeader := Variant;
                    IF ServiceCrMemoHeader."Customer Posting Group" <> '' THEN
                        CustomerPostingGroup.GET(ServiceCrMemoHeader."Customer Posting Group");
                END;
        END;
        EXIT(CustomerPostingGroup."Invoice Rounding Account");
    end;

    //B2BUPG1.0
    /*
    local procedure GetGSTRoundingAccService(): Code[20];
    var
        GLSetup: Record 98;
    begin
        GLSetup.GET;
        EXIT(GLSetup."GST Inv. Rounding Account");
    end;
    */
    //B2BUPG1.0<<

    procedure CheckValidEntriesAppliedService(ServiceHeader: Record "Service Header");
    var
        ServiceInvHdr: Record "Service Invoice Header";
        ActiveInvoice: Boolean;
        InActiveInvoice: Boolean;
        EInvoiceEntry: Record "E-Invoice Entry";
        CustLedgEntry: Record 21;
        EInvoiceSetupL: Record "E-Invoice Setup";
    begin
        /*
        IF ServiceHeader."Document Type" <> ServiceHeader."Document Type"::"Credit Memo" THEN
          EXIT;
        
        ReferenceInvoiceNo.SETRANGE("Document Type",ServiceHeader."Document Type");
        ReferenceInvoiceNo.SETRANGE("Document No.",ServiceHeader."No.");
        ReferenceInvoiceNo.SETRANGE("Source No.",ServiceHeader."Customer No.");
        ReferenceInvoiceNo.SETRANGE("Source Type",ReferenceInvoiceNo."Source Type"::Customer);
        IF ReferenceInvoiceNo.FINDSET THEN
          REPEAT
            ServiceInvHdr.GET(ReferenceInvoiceNo."Reference Invoice Nos.");
            IF ServiceInvHdr."Posting Date" >= DMY2DATE(1,10,2020) THEN BEGIN//Fix 01Oct2020
              EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Invoice",ServiceInvHdr."No.");
              IF NOT ActiveInvoice THEN
                ActiveInvoice := NOT EInvoiceEntry."IRN Cancelled";
              IF NOT InActiveInvoice THEN
                InActiveInvoice := EInvoiceEntry."IRN Cancelled";
            END;
          UNTIL (ReferenceInvoiceNo.NEXT = 0) OR (ActiveInvoice AND InActiveInvoice);
        */
        //>>2016CU19
        // IF (SalesHeader."Applies-to Doc. Type" = SalesHeader."Applies-to Doc. Type"::Invoice) AND
        //  (SalesHeader."Applies-to Doc. No." <> '')
        // THEN BEGIN
        //  SalesInvHdr.GET(SalesHeader."Applies-to Doc. No.");
        //  EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Invoice",SalesInvHdr."No.");
        //  IF NOT ActiveInvoice THEN
        //    ActiveInvoice := NOT EInvoiceEntry."IRN Cancelled";
        //  IF NOT InActiveInvoice THEN
        //    InActiveInvoice := EInvoiceEntry."IRN Cancelled";
        // END ELSE IF SalesHeader."Applies-to ID" <> '' THEN BEGIN
        //  CustLedgEntry.RESET;
        //  CustLedgEntry.SETCURRENTKEY("Customer No.",Open);
        //  CustLedgEntry.SETRANGE("Customer No.",SalesHeader."Bill-to Customer No.");
        //  CustLedgEntry.SETRANGE(Open,TRUE);
        //  CustLedgEntry.SETRANGE("Applies-to ID",SalesHeader."Applies-to ID");
        //  IF CustLedgEntry.FINDSET THEN
        //    REPEAT
        //      IF SalesInvHdr.GET(CustLedgEntry."Document No.") THEN
        //          IF SalesInvHdr."Posting Date" >= DMY2DATE(1,10,2020) THEN BEGIN//Fix 01Oct2020
        //            EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Invoice",SalesInvHdr."No.");
        //            IF NOT ActiveInvoice THEN
        //              ActiveInvoice := NOT EInvoiceEntry."IRN Cancelled";
        //            IF NOT InActiveInvoice THEN
        //              InActiveInvoice := EInvoiceEntry."IRN Cancelled";
        //          END;
        //    UNTIL (CustLedgEntry.NEXT = 0) OR (ActiveInvoice AND InActiveInvoice);
        // END;
        //<<2016CU19

        IF ServiceHeader."Document Type" <> ServiceHeader."Document Type"::"Credit Memo" THEN
            EXIT;

        EInvoiceSetupL.Get();
        IF (ServiceHeader."Applies-to Doc. Type" = ServiceHeader."Applies-to Doc. Type"::Invoice) AND
          (ServiceHeader."Applies-to Doc. No." <> '')
        THEN BEGIN
            ServiceInvHdr.GET(ServiceHeader."Applies-to Doc. No.");
            //IF ServiceInvHdr."Posting Date" >= DMY2DATE(1, 12, 2020) THEN BEGIN   //B2B1.0
            IF ServiceInvHdr."Posting Date" >= EInvoiceSetupL."Effective Date" THEN BEGIN
                EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Invoice", ServiceInvHdr."No.");
                IF NOT ActiveInvoice THEN
                    ActiveInvoice := NOT EInvoiceEntry."IRN Cancelled";
                IF NOT InActiveInvoice THEN
                    InActiveInvoice := EInvoiceEntry."IRN Cancelled";
            END;//B2B1.0
        END ELSE
            IF ServiceHeader."Applies-to ID" <> '' THEN BEGIN
                CustLedgEntry.RESET;
                CustLedgEntry.SETCURRENTKEY("Customer No.", Open);
                CustLedgEntry.SETRANGE("Customer No.", ServiceHeader."Bill-to Customer No.");
                CustLedgEntry.SETRANGE(Open, TRUE);
                CustLedgEntry.SETRANGE("Applies-to ID", ServiceHeader."Applies-to ID");
                IF CustLedgEntry.FINDSET THEN
                    REPEAT
                        //IF (ServiceInvHdr.GET(CustLedgEntry."Document No.") AND (ServiceInvHdr."Posting Date" >= DMY2DATE(1, 12, 2020))) THEN BEGIN  //B2B1.0
                        IF (ServiceInvHdr.GET(CustLedgEntry."Document No.") AND (ServiceInvHdr."Posting Date" >= EInvoiceSetupL."Effective Date")) THEN BEGIN
                            EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Invoice", ServiceInvHdr."No.");
                            IF NOT ActiveInvoice THEN
                                ActiveInvoice := NOT EInvoiceEntry."IRN Cancelled";
                            IF NOT InActiveInvoice THEN
                                InActiveInvoice := EInvoiceEntry."IRN Cancelled";
                        END;
                    UNTIL (CustLedgEntry.NEXT = 0) OR (ActiveInvoice AND InActiveInvoice);
            END;
        IF ActiveInvoice AND InActiveInvoice THEN
            ERROR(ActiveInActiveInvErr);

    end;

    local procedure CheckCrMemoActiveApplicationExistService(ServiceInvHdr: Record "Service Invoice Header"): Boolean;
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ActiveApplicationFound: Boolean;
        EInvoiceEntry: Record "E-Invoice Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        AppliedCustLedgEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SETRANGE("Document No.", ServiceInvHdr."No.");
        CustLedgerEntry.SETRANGE("Posting Date", ServiceInvHdr."Posting Date");
        CustLedgerEntry.FINDFIRST;

        FindApplnEntriesDtldtLedgEntryService(CustLedgerEntry, AppliedCustLedgEntry);
        AppliedCustLedgEntry.MARKEDONLY(TRUE);
        IF AppliedCustLedgEntry.FINDSET THEN
            REPEAT
                IF ServiceCrMemoHeader.GET(AppliedCustLedgEntry."Document No.") THEN BEGIN
                    EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Cr. Memo", ServiceCrMemoHeader."No.");
                    ActiveApplicationFound := (NOT EInvoiceEntry."IRN Cancelled");
                END;
            UNTIL (AppliedCustLedgEntry.NEXT = 0) OR ActiveApplicationFound;

        EXIT(ActiveApplicationFound);
    end;

    procedure IsInActiveInvoiceAppliedService(ServiceCrMemoHeader: Record "Service Cr.Memo Header"): Boolean;
    var
        ServiceInvHdr: Record "Service Invoice Header";
        ActiveInvoice: Boolean;
        InActiveInvoice: Boolean;
        EInvoiceEntry: Record "E-Invoice Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        AppliedCustLedgEntry: Record "Cust. Ledger Entry";
        EInvoiceSetupL: Record "E-Invoice Setup";
    begin
        /*
        ReferenceInvoiceNo.SETRANGE("Document No.",ServiceCrMemoHeader."No.");
        IF ReferenceInvoiceNo.FINDSET THEN
          REPEAT
            ServiceInvHdr.GET(ReferenceInvoiceNo."Reference Invoice Nos.");
            IF ServiceInvHdr."Posting Date" >= DMY2DATE(1,10,2020) THEN BEGIN//Fix 01Oct2020
              EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Invoice",ServiceInvHdr."No.");
              InActiveInvoice := (EInvoiceEntry."IRN No." = '') OR EInvoiceEntry."IRN Cancelled";
            END;
          UNTIL (ReferenceInvoiceNo.NEXT = 0) OR InActiveInvoice
        ELSE
        */
        EInvoiceSetupL.Get();
        CustLedgerEntry.SETRANGE("Document No.", ServiceCrMemoHeader."No.");
        CustLedgerEntry.SETRANGE("Posting Date", ServiceCrMemoHeader."Posting Date");
        CustLedgerEntry.FINDFIRST;

        FindApplnEntriesDtldtLedgEntryService(CustLedgerEntry, AppliedCustLedgEntry);
        AppliedCustLedgEntry.MARKEDONLY(TRUE);
        IF AppliedCustLedgEntry.FINDSET THEN
            REPEAT
                IF ServiceInvHdr.GET(AppliedCustLedgEntry."Document No.") THEN
                    //IF ServiceInvHdr."Posting Date" >= DMY2DATE(1, 10, 2020) THEN BEGIN//Fix 01Oct2020
                    IF ServiceInvHdr."Posting Date" >= EInvoiceSetupL."Effective Date" THEN BEGIN
                        EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Invoice", ServiceInvHdr."No.");
                        InActiveInvoice := (EInvoiceEntry."IRN No." = '') OR EInvoiceEntry."IRN Cancelled";
                    END;
            UNTIL (AppliedCustLedgEntry.NEXT = 0) OR InActiveInvoice;

        EXIT(InActiveInvoice);

    end;

    local procedure FindApplnEntriesDtldtLedgEntryService(CreateCustLedgEntry: Record "Cust. Ledger Entry"; var AppliedCustLedgEntry: Record "Cust. Ledger Entry");
    var
        DtldCustLedgEntry1: Record "Detailed Cust. Ledg. Entry";
        DtldCustLedgEntry2: Record "Detailed Cust. Ledg. Entry";
    begin
        DtldCustLedgEntry1.SETCURRENTKEY("Cust. Ledger Entry No.");
        DtldCustLedgEntry1.SETRANGE("Cust. Ledger Entry No.", CreateCustLedgEntry."Entry No.");
        DtldCustLedgEntry1.SETRANGE(Unapplied, FALSE);
        IF DtldCustLedgEntry1.FIND('-') THEN
            REPEAT
                IF DtldCustLedgEntry1."Cust. Ledger Entry No." =
                   DtldCustLedgEntry1."Applied Cust. Ledger Entry No."
                THEN BEGIN
                    DtldCustLedgEntry2.INIT;
                    DtldCustLedgEntry2.SETCURRENTKEY("Applied Cust. Ledger Entry No.", "Entry Type");
                    DtldCustLedgEntry2.SETRANGE(
                      "Applied Cust. Ledger Entry No.", DtldCustLedgEntry1."Applied Cust. Ledger Entry No.");
                    DtldCustLedgEntry2.SETRANGE("Entry Type", DtldCustLedgEntry2."Entry Type"::Application);
                    DtldCustLedgEntry2.SETRANGE(Unapplied, FALSE);
                    IF DtldCustLedgEntry2.FIND('-') THEN
                        REPEAT
                            IF DtldCustLedgEntry2."Cust. Ledger Entry No." <>
                               DtldCustLedgEntry2."Applied Cust. Ledger Entry No."
                            THEN BEGIN
                                AppliedCustLedgEntry.SETCURRENTKEY("Entry No.");
                                AppliedCustLedgEntry.SETRANGE("Entry No.", DtldCustLedgEntry2."Cust. Ledger Entry No.");
                                IF AppliedCustLedgEntry.FIND('-') THEN
                                    AppliedCustLedgEntry.MARK(TRUE);
                            END;
                        UNTIL DtldCustLedgEntry2.NEXT = 0;
                END ELSE BEGIN
                    AppliedCustLedgEntry.SETCURRENTKEY("Entry No.");
                    AppliedCustLedgEntry.SETRANGE("Entry No.", DtldCustLedgEntry1."Applied Cust. Ledger Entry No.");
                    IF AppliedCustLedgEntry.FIND('-') THEN
                        AppliedCustLedgEntry.MARK(TRUE);
                END;
            UNTIL DtldCustLedgEntry1.NEXT = 0;
    end;

    procedure CheckGenerateIRNValidaitonsService(Variant: Variant);
    var
        ServiceInvHead: Record "Service Invoice Header";
        ServiceCrdHead: Record "Service Cr.Memo Header";
        ValidTo: DateTime;
        RecRef: RecordRef;
        EInvoiceEntry: Record "E-Invoice Entry";
    begin
        //>> ValidIRNFix
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            5992:
                BEGIN
                    ServiceInvHead := Variant;
                    IF CheckCrMemoApplicationExistService(ServiceInvHead) THEN
                        ERROR(CrMemoAppliedErr2);
                END;
            5994:
                BEGIN
                    ServiceCrdHead := Variant;
                    IF IsInActiveInvoiceAppliedService(ServiceCrdHead) THEN
                        ERROR(InActiveInvAppliedErr);
                END;
        END;
        //<< ValidIRNFix
    end;

    local procedure CheckCrMemoApplicationExistService(ServiceInvHdr: Record "Service Invoice Header"): Boolean;
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        ApplicationFound: Boolean;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        AppliedCustLedgEntry: Record "Cust. Ledger Entry";
    begin
        //>> ValidIRNFix
        CustLedgerEntry.SETRANGE("Document No.", ServiceInvHdr."No.");
        CustLedgerEntry.SETRANGE("Posting Date", ServiceInvHdr."Posting Date");
        CustLedgerEntry.FINDFIRST;

        FindApplnEntriesDtldtLedgEntry(CustLedgerEntry, AppliedCustLedgEntry);
        AppliedCustLedgEntry.MARKEDONLY(TRUE);
        IF AppliedCustLedgEntry.FINDSET THEN
            REPEAT
                ApplicationFound := ServiceCrMemoHeader.GET(AppliedCustLedgEntry."Document No.");
            UNTIL (AppliedCustLedgEntry.NEXT = 0) OR ApplicationFound;

        EXIT(ApplicationFound);
        //<< ValidIRNFix
    end;
    //B2BUPGSERVICE1.0<< Service Orders
}

