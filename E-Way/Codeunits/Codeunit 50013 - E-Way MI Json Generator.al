codeunit 50013 "E-Way MI Json Generator"
{

    trigger OnRun()
    begin

        CompanyInfo.GET;
        EWayBillingSetup.GET;

        ProcessJSONFormat();


    end;

    var

        GlobalNULL: Variant;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        JOBJAcctokenG: JsonObject;
        CompanyInfo: Record "Company Information";
        RequestType: Option Eway,Vehicle,EWayCancel,RejectEway,ExtendValidity,UpdateTrasporter,AccessToken;
        DocumentNo: Code[20];
        PathSaved: Text;
        EWayBillingSetup: Record "E-Way Billing Setup";
        IsPosting: Boolean;
        SalesShipHeader: Record "Sales Shipment Header";
        DocType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order",Shipment;
        PurchHeader: Record "Purchase Header";
        TransType: Option " ","Sales Invoice","Sales Shpt","Purch. Order","Whse. Shipment","Whse. Rect","Transfer Order","Sales Crd Memo","Purch. Crd Memo","Sales R.O","Purchase R.O",Subcontracting;
        WareHouseRectHead: Record "Warehouse Receipt Header";
        SalesCreditHeader: Record "Sales Cr.Memo Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        //B2BUPG1.0>>
        GSTLbl: Label 'GST';
        IGSTLbl: Label 'IGST';
        CGSTLbl: Label 'CGST';
        GSTCESSLbl: Label 'GST CESS';
        CESSLbl: Label 'CESS';
        EWayUpdate: Page "E-Way Bill Update Window";
        JOsupplyTypeG: JsonObject;
        JOItemsG: JsonObject;
        JArrayItemsG: JsonArray;

        JOCancelG: JsonObject;
        JOVehicleG: JsonObject;
        JORejEWayNoG: JsonObject;

        JOUpdatetransportIDG: JsonObject;

        JOExtendValidityJsonG: JsonObject;

    //B2BUPG1.0<<




    local procedure ProcessJSONFormat()
    begin
        IF SalesInvoiceHeader."No." <> '' THEN BEGIN
            DocumentNo := SalesInvoiceHeader."No.";
            CASE RequestType OF
                RequestType::Eway:
                    BEGIN
                        InvEWayJson();
                    END;
                RequestType::Vehicle:
                    BEGIN
                        InvVechileJson();
                    END;
                RequestType::EWayCancel:
                    BEGIN
                        InvCancelEwayJson();
                    END;
                RequestType::RejectEway:
                    BEGIN

                    END;
                RequestType::UpdateTrasporter:
                    BEGIN
                        InvUpdateTransportJson();
                    END;
                RequestType::ExtendValidity:
                    BEGIN
                        InvExtendValidityJson();
                    END;
            END;
        END;
        IF SalesShipHeader."No." <> '' THEN BEGIN
            DocumentNo := SalesShipHeader."No.";
            CASE RequestType OF
                RequestType::Eway:
                    BEGIN
                        ShipEWayJson();
                    END;
                RequestType::Vehicle:
                    BEGIN
                        ShipVechileJson();
                    END;
                RequestType::EWayCancel:
                    BEGIN
                        ShipCancelEwayJson();
                    END;
                RequestType::RejectEway:
                    BEGIN

                    END;
                RequestType::UpdateTrasporter:
                    BEGIN
                        ShipUpdateTransportJson();
                    END;
                RequestType::ExtendValidity:
                    BEGIN
                        ShipExtendValidityJson();
                    END;
            END;
        END;
        IF PurchHeader."No." <> '' THEN BEGIN
            IF WareHouseRectHead."No." <> '' THEN
                DocumentNo := WareHouseRectHead."No."
            ELSE
                DocumentNo := PurchHeader."Vendor Shipment No.";
            CASE RequestType OF
                RequestType::Eway:
                    BEGIN
                        PurchEWayJson();
                    END;
                RequestType::Vehicle:
                    BEGIN
                        PurchVechileJson();
                    END;
                RequestType::EWayCancel:
                    BEGIN
                        PurchCancelEwayJson();
                    END;
                RequestType::RejectEway:
                    BEGIN

                    END;
                RequestType::UpdateTrasporter:
                    BEGIN
                        PurchUpdateTransportJson();
                    END;
                RequestType::ExtendValidity:
                    BEGIN
                        PurchExtendValidityJson();
                    END;
            END;
        END;
        IF SalesCreditHeader."No." <> '' THEN BEGIN
            DocumentNo := SalesCreditHeader."No.";
            CASE RequestType OF
                RequestType::Eway:
                    BEGIN
                        CreditEWayJson();
                    END;
                RequestType::Vehicle:
                    BEGIN
                        CreditVechileJson();
                    END;
                RequestType::EWayCancel:
                    BEGIN
                        CreditCancelEwayJson();
                    END;
                RequestType::RejectEway:
                    BEGIN

                    END;
                RequestType::UpdateTrasporter:
                    BEGIN
                        CreditUpdateTransportJson();
                    END;
                RequestType::ExtendValidity:
                    BEGIN
                        CreditExtendValidityJson();
                    END;
            END;
        END;
        IF PurchCrMemoHdr."No." <> '' THEN BEGIN
            DocumentNo := PurchCrMemoHdr."No.";
            CASE RequestType OF
                RequestType::Eway:
                    BEGIN
                        PurchCreditEWayJson();
                    END;
                RequestType::Vehicle:
                    BEGIN
                        PurchCreditVechileJson();
                    END;
                RequestType::EWayCancel:
                    BEGIN
                        PurchCreditCancelEwayJson();
                    END;
                RequestType::RejectEway:
                    BEGIN

                    END;
                RequestType::UpdateTrasporter:
                    BEGIN
                        PurchCreditUpdateTransportJson();
                    END;
                RequestType::ExtendValidity:
                    BEGIN
                        PurchCreditExtendValidityJson();
                    END;
            END;
        END;
        IF TransferShipmentHeader."No." <> '' THEN BEGIN
            DocumentNo := TransferShipmentHeader."No.";
            CASE RequestType OF
                RequestType::Eway:
                    BEGIN
                        TransOrderEWayJson();
                    END;
                RequestType::Vehicle:
                    BEGIN
                        TransOrderVechileJson();
                    END;
                RequestType::EWayCancel:
                    BEGIN
                        TransOrderCancelEwayJson();
                    END;
                RequestType::RejectEway:
                    BEGIN

                    END;
                RequestType::UpdateTrasporter:
                    BEGIN
                        TransOrderUpdateTransportJson();
                    END;
                RequestType::ExtendValidity:
                    BEGIN
                        TransOrderExtendValidityJson();
                    END;
            END;
        END;
    end;

    procedure MIAccessTokenJson()
    var
        HeaderTitle: Label 'Enter Cancel Details';
        Title1: Label 'Cancel Reason :';
        Title2: Label 'Cancel Remarks :';
        RejectEwayBillNo: Text;
        EWayValidator: Codeunit "E-Way Validator";
        RejectErr: Label 'E-Way bill no must be provided to Reject.';

        AccesstokenReq: Text;
    begin
        EWayBillingSetup.GET;
        RequestType := RequestType::AccessToken;

        // JsonTextWriter.WriteStartObject();
        // JsonTextWriter.WritePropertyName('username');
        // JsonTextWriter.WriteValue('testeway@mastersindia.co');

        // JsonTextWriter.WritePropertyName('password');
        // JsonTextWriter.WriteValue('!@#Demo!@#123');

        // JsonTextWriter.WritePropertyName('client_id');
        // JsonTextWriter.WriteValue('fIXefFyxGNfDWOcCWnj');

        // JsonTextWriter.WritePropertyName('client_secret');
        // JsonTextWriter.WriteValue('QFd6dZvCGqckabKxTapfZgJc');

        // JsonTextWriter.WritePropertyName('grant_type');
        // JsonTextWriter.WriteValue('password');
        // JsonTextWriter.WriteEndObject();

        // ExportAsJson('MIAccessToken', PathSaved);
        // EXIT(PathSaved);
        JOBJAcctokenG.Add('username', 'testeway@mastersindia.co');
        JOBJAcctokenG.Add('password', '!@#Demo!@#123');
        JOBJAcctokenG.Add('client_id', 'fIXefFyxGNfDWOcCWnj');
        JOBJAcctokenG.Add('client_secret', 'QFd6dZvCGqckabKxTapfZgJc');
        JOBJAcctokenG.Add('grant_type', 'password');
        JOBJAcctokenG.WriteTo(AccesstokenReq);

    end;

    procedure AccessTokenJSON(var JsonFile: Text)
    begin
        JOBJAcctokenG.WriteTo(JsonFile);
    end;

    local procedure UpdateOldVechileNoInEWayEntry(TransType: Option " ","Sales Invoice","Sales Shpt","Purch. Order","Whse. Shipment","Whse. Rect","Transfer Order","Sales Crd Memo","Purch. Crd Memo","Sales R.O","Purchase R.O",Subcontracting; DocNo: Code[20]; OldVechileNo: Code[20])
    var
        EWayBillingEntry: Record "E-Way Billing Entry";
    begin
        EWayBillingEntry.GET(TransType, DocNo);
        //EWayBillingEntry."Old Vehicle No" := OldVechileNo;
        EWayBillingEntry.MODIFY;
    end;

    local procedure "-----------------------------------------INVOICE START------------------------------"()
    begin
    end;

    procedure SetSalesInvHeader(var SalesInvHdrBuff: Record "Sales Invoice Header"; RequestTypePar: Option Eway,Vehicle,EWayCancel,RejectEway,ExtendValidity,UpdateTrasporter,AccessToken; IsPostingPar: Boolean)
    begin
        SalesInvoiceHeader := SalesInvHdrBuff;
        RequestType := RequestTypePar;
        IsPosting := IsPostingPar;
    end;

    procedure InvEWayJson()
    var
        LocationBuff: Record Location;
        StateBuff: Record State;
        Gstin: Text;
        Pin: Text;
        Pos: Text;
        Path: Text;
        SubSupplyType: Text;
        SubType: Text;
    begin
        IF SalesInvoiceHeader."GST Customer Type" = SalesInvoiceHeader."GST Customer Type"::Export THEN BEGIN
            Gstin := 'URP';
            Pin := '999999';
            SubSupplyType := 'Export';
            SubType := 'outward';
        END ELSE BEGIN
            Gstin := SalesInvoiceHeader."Customer GST Reg. No.";
            Pin := COPYSTR(SalesInvoiceHeader."Bill-to Post Code", 1, 6);
            SubSupplyType := 'Supply';
            SubType := 'outward';
        END;
        IF SalesInvoiceHeader."GST Customer Type" = SalesInvoiceHeader."GST Customer Type"::Unregistered THEN
            Gstin := 'URP';

        LocationBuff.GET(SalesInvoiceHeader."Location Code");
        InvEWayHeadDetails('', SalesInvoiceHeader."Location GST Reg. No.", SubType, SubSupplyType, 'tax invoice', SalesInvoiceHeader."No.", FORMAT(SalesInvoiceHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>')); //Header

        //From Details >>
        StateBuff.GET(LocationBuff."State Code");
        InvEwayFromDetails(SalesInvoiceHeader."Location GST Reg. No.", CompanyInfo.Name, LocationBuff.Address, LocationBuff."Address 2", LocationBuff.City
                        , LocationBuff."Post Code", StateBuff.Description, StateBuff.Description);
        //From Details <<

        //To Details >>
        Pos := InvGetEwayPos(SalesInvoiceHeader."No.");

        InvEwayToDetails(Gstin, SalesInvoiceHeader."Bill-to Name", SalesInvoiceHeader."Bill-to Address", SalesInvoiceHeader."Bill-to Address 2", SalesInvoiceHeader."Bill-to City", Pin, Pos, Pos);
        //To Details <<
        InvGetGSTCompRate(SalesInvoiceHeader."No.", 0, JOItemsG);//Update GST calculations
        InvReadEwbDtls();//Update Transport Details

        InvReadItemList();
        //JsonTextWriter.WriteEndObject;
        //ExportAsJson(SalesInvoiceHeader."No.", Path);
    end;

    local procedure InvEWayHeadDetails(AccessTokenNo: Text; GstIn: Text; SupplyType: Text; SupplySubType: Text; Doctype: Text; DocNo: Text; DocDate: Text)
    begin
        EWayBillingSetup.GET();
        // JsonTextWriter.WriteStartObject;
        // JsonTextWriter.WritePropertyName('access_token');
        // JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        // JsonTextWriter.WritePropertyName('userGstin');
        // JsonTextWriter.WriteValue(GstIn);
        // JsonTextWriter.WritePropertyName('supply_type');
        // JsonTextWriter.WriteValue(SupplyType);
        // JsonTextWriter.WritePropertyName('sub_supply_type');
        // JsonTextWriter.WriteValue(SupplySubType);
        // JsonTextWriter.WritePropertyName('sub_supply_description');
        // JsonTextWriter.WriteValue('');
        // JsonTextWriter.WritePropertyName('document_type');
        // JsonTextWriter.WriteValue(Doctype);
        // JsonTextWriter.WritePropertyName('document_number');
        // JsonTextWriter.WriteValue(DocNo);
        // JsonTextWriter.WritePropertyName('document_date');
        // JsonTextWriter.WriteValue(DocDate);
        JOsupplyTypeG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOsupplyTypeG.Add('userGstin', GstIn);
        JOsupplyTypeG.Add('supply_type', SupplyType);
        JOsupplyTypeG.Add('sub_supply_type', SupplySubType);
        if SupplySubType = '3' then begin
            JOsupplyTypeG.Add('sub_supply_description', '');
        end;
        JOsupplyTypeG.Add('document_type', Doctype);
        JOsupplyTypeG.Add('document_number', DocNo);
        JOsupplyTypeG.Add('document_date', DocDate);


    end;

    procedure InvEwayFromDetails(FromGstin: Text; FromTrdName: Text; FromAdd1: Text; FromAdd2: Text; FromPlace: Text; FromPinCode: Text; ActFromStateCode: Text; FromStateCode: Text): Boolean
    var
        FromPinCodeInt: Integer;
        ActFromStateCodeInt: Integer;
        FromStateCodeInt: Integer;
    begin
        IF FromPinCode <> '' THEN
            EVALUATE(FromPinCodeInt, FromPinCode);
        // JsonTextWriter.WritePropertyName('gstin_of_consignor');
        // JsonTextWriter.WriteValue(FromGstin);
        // JsonTextWriter.WritePropertyName('legal_name_of_consignor');
        // JsonTextWriter.WriteValue(FromTrdName);
        // JsonTextWriter.WritePropertyName('address1_of_consignor');
        // JsonTextWriter.WriteValue(FromAdd1);
        // JsonTextWriter.WritePropertyName('address2_of_consignor');
        // JsonTextWriter.WriteValue(FromAdd2);
        // JsonTextWriter.WritePropertyName('place_of_consignor');
        // JsonTextWriter.WriteValue(FromPlace);
        // JsonTextWriter.WritePropertyName('pincode_of_consignor');
        // JsonTextWriter.WriteValue(FromPinCodeInt);
        // JsonTextWriter.WritePropertyName('state_of_consignor');
        // JsonTextWriter.WriteValue(FromStateCode);
        // JsonTextWriter.WritePropertyName('actual_from_state_name');
        // JsonTextWriter.WriteValue(ActFromStateCode);
        JOsupplyTypeG.Add('gstin_of_consignor', FromGstin);
        JOsupplyTypeG.Add('legal_name_of_consignor', FromTrdName);
        JOsupplyTypeG.Add('address1_of_consignor', FromAdd1);
        JOsupplyTypeG.Add('address2_of_consignor', FromAdd2);
        JOsupplyTypeG.Add('place_of_consignor', FromPlace);
        JOsupplyTypeG.Add('pincode_of_consignor', FromPinCodeInt);
        JOsupplyTypeG.Add('state_of_consignor', ActFromStateCodeInt);
        JOsupplyTypeG.Add('actual_from_state_name', FromStateCodeInt);


    end;

    procedure InvEwayToDetails(ToGstin: Text; ToTrdName: Text; ToAdd1: Text; ToAdd2: Text; ToPlace: Text; ToPinCode: Text; ActFromStateCode: Text; ToStateCode: Text): Boolean
    var
        ToPinCodeInt: Integer;
        ActToStateCodeInt: Integer;
        ToStateCodeInt: Integer;
    begin
        IF ToPinCode <> '' THEN
            EVALUATE(ToPinCodeInt, ToPinCode);
        // JsonTextWriter.WritePropertyName('gstin_of_consignee');
        // JsonTextWriter.WriteValue(ToGstin);
        // JsonTextWriter.WritePropertyName('legal_name_of_consignee');
        // JsonTextWriter.WriteValue(ToTrdName);
        // JsonTextWriter.WritePropertyName('address1_of_consignee');
        // JsonTextWriter.WriteValue(ToAdd1);
        // JsonTextWriter.WritePropertyName('address2_of_consignee');
        // JsonTextWriter.WriteValue(ToAdd2);
        // JsonTextWriter.WritePropertyName('place_of_consignee');
        // JsonTextWriter.WriteValue(ToPlace);
        // JsonTextWriter.WritePropertyName('pincode_of_consignee');
        // JsonTextWriter.WriteValue(ToPinCodeInt);
        // JsonTextWriter.WritePropertyName('state_of_supply');
        JOsupplyTypeG.Add('gstin_of_consignee', ToGstin);
        JOsupplyTypeG.Add('legal_name_of_consignee', ToTrdName);
        JOsupplyTypeG.Add('address1_of_consignee', ToAdd1);
        JOsupplyTypeG.Add('address2_of_consignee', ToAdd2);
        JOsupplyTypeG.Add('place_of_consignee', ToPlace);
        JOsupplyTypeG.Add('pincode_of_consignee', ToPinCodeInt);

        //Export >>
        IF (SalesInvoiceHeader."GST Customer Type" IN [SalesInvoiceHeader."GST Customer Type"::Export, SalesInvoiceHeader."GST Customer Type"::"SEZ Development",
                                                  SalesInvoiceHeader."GST Customer Type"::"SEZ Unit"]) THEN
            //JsonTextWriter.WriteValue('OTHER TERRITORY')
            JOsupplyTypeG.Add('state_of_supply', 'OTHER TERRITORY')
        ELSE
            // JsonTextWriter.WriteValue(ToStateCode);
            JOsupplyTypeG.Add('state_of_supply', ToStateCode);

        // JsonTextWriter.WritePropertyName('actual_to_state_name');
        IF (SalesInvoiceHeader."GST Customer Type" IN [SalesInvoiceHeader."GST Customer Type"::Export, SalesInvoiceHeader."GST Customer Type"::"SEZ Development",
                                                  SalesInvoiceHeader."GST Customer Type"::"SEZ Unit"]) THEN
            // JsonTextWriter.WriteValue('OTHER TERRITORY')
            JOsupplyTypeG.Add('actual_to_state_name', 'OTHER TERRITORY')
        ELSE
            //     JsonTextWriter.WriteValue(ActFromStateCode);
            // JsonTextWriter.WritePropertyName('transaction_type');
            // JsonTextWriter.WriteValue(FORMAT(SalesInvoiceHeader."Transaction Type"));
            // JsonTextWriter.WritePropertyName('other_value');
            // JsonTextWriter.WriteValue('');
            JOsupplyTypeG.Add('actual_to_state_name', ActFromStateCode);
        JOsupplyTypeG.Add('transaction_type', SalesInvoiceHeader."Transaction Type");
        JOsupplyTypeG.Add('other_value', '');

    end;

    local procedure InvGetEwayPos(No: Code[20]): Text
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCredLine: Record "Sales Cr.Memo Line";
        StateBuff: Record State;
    begin
        SalesInvoiceLine.SETRANGE("Document No.", No);
        SalesInvoiceLine.SETFILTER("No.", '<>%1', '');//BugFix
        SalesInvoiceLine.SETRANGE(Exempted, FALSE);
        IF SalesInvoiceLine.FINDFIRST THEN
            IF SalesInvoiceLine."GST Place of Supply" = SalesInvoiceLine."GST Place of Supply"::"Bill-to Address" THEN BEGIN
                IF NOT (SalesInvoiceHeader."GST Customer Type" = SalesInvoiceHeader."GST Customer Type"::Export) THEN BEGIN
                    StateBuff.GET(SalesInvoiceHeader."GST Bill-to State Code");
                    EXIT(StateBuff.Description);
                END ELSE
                    EXIT('Other Country');
            END ELSE
                IF SalesInvoiceLine."GST Place of Supply" = SalesInvoiceLine."GST Place of Supply"::"Ship-to Address" THEN BEGIN
                    IF NOT (SalesInvoiceHeader."GST Customer Type" = SalesInvoiceHeader."GST Customer Type"::Export) THEN BEGIN
                        StateBuff.GET(SalesInvoiceHeader."GST Ship-to State Code");
                        EXIT(StateBuff.Description);
                    END ELSE
                        EXIT('Other Country');
                END;
    end;

    local procedure InvUpdateEwayCalculations(TotalValue: Decimal; CgstValue: Decimal; SgstValue: Decimal; IgstValue: Decimal; CessValue: Decimal)
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        TotalInvValue: Decimal;
        TCSEntry: Record "TCS Entry";
        OtherCharges: Decimal;
    begin
        SalesInvoiceLine.RESET;
        SalesInvoiceLine.SETRANGE("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SETRANGE(Type, SalesInvoiceLine.Type::Item);
        SalesInvoiceLine.SETRANGE(Exempted, FALSE);
        IF SalesInvoiceLine.FINDSET THEN BEGIN
            REPEAT
                TotalInvValue += (SalesInvoiceLine.Quantity * SalesInvoiceLine."Unit Price") -
                                 ((SalesInvoiceLine.Quantity * SalesInvoiceLine."Unit Price") * SalesInvoiceLine."Line Discount %" / 100) - SalesInvoiceLine."Inv. Discount Amount";
            UNTIL SalesInvoiceLine.NEXT = 0;
        END;

        IF SalesInvoiceHeader."Currency Code" <> '' THEN BEGIN
            TotalInvValue := (1 / SalesInvoiceHeader."Currency Factor") * TotalInvValue;
        END;
        //Tcs>>
        Clear(OtherCharges);
        TCSEntry.Reset();
        TCSEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        if TCSEntry.FindSet() then begin
            TCSEntry.CalcSums("Total TCS Including SHE CESS");
            OtherCharges := TCSEntry."Total TCS Including SHE CESS";
        end;
        TotalValue := CgstValue + SgstValue + IgstValue + CessValue + OtherCharges;
        // JsonTextWriter.WritePropertyName('otherValue');
        // JsonTextWriter.WriteValue(OtherCharges);
        // //TCS<<
        // JsonTextWriter.WritePropertyName('total_invoice_value');
        // JsonTextWriter.WriteValue(TotalInvValue + TotalValue);
        // JsonTextWriter.WritePropertyName('taxable_amount');
        // JsonTextWriter.WriteValue(ABS(TotalInvValue));
        // JsonTextWriter.WritePropertyName('cgst_amount');
        // JsonTextWriter.WriteValue(CgstValue);
        // JsonTextWriter.WritePropertyName('sgst_amount');
        // JsonTextWriter.WriteValue(SgstValue);
        // JsonTextWriter.WritePropertyName('igst_amount');
        // JsonTextWriter.WriteValue(IgstValue);
        // JsonTextWriter.WritePropertyName('cess_amount');
        // JsonTextWriter.WriteValue(CessValue);
        // JsonTextWriter.WritePropertyName('cess_nonadvol_value');
        // JsonTextWriter.WriteValue('');
        JOsupplyTypeG.Add('otherValue', OtherCharges);
        JOsupplyTypeG.Add('total_invoice_value', TotalInvValue + TotalValue);
        JOsupplyTypeG.Add('taxable_amount', ABS(TotalInvValue));
        JOsupplyTypeG.Add('cgst_amount', CgstValue);
        JOsupplyTypeG.Add('sgst_amount', SgstValue);
        JOsupplyTypeG.Add('igst_amount', IgstValue);
        JOsupplyTypeG.Add('cess_amount', CessValue);
        JOsupplyTypeG.Add('cess_nonadvol_value', '');
    end;

    local procedure InvGetGSTCompRate(DocNo: Code[20]; LineNo: Integer; var JSONItemL: JsonObject)
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTComponent: Record "Tax Component";
        CurrExchRate: Record "Currency Exchange Rate";
        CurrencyCode: Code[10];
        CurrencyFactor: Decimal;
        CgstAmt: Decimal;
        SgstAmt: Decimal;
        IgstAmt: Decimal;
        CesRt: Decimal;
        CessAmt: Decimal;
        CesNonAdvlAmt: Decimal;
        StateCesRt: Decimal;
        StateCesAmt: Decimal;
        StateCesNonAdvlAmt: Decimal;
        CgstRt: Decimal;
        SgstRt: Decimal;
        IgstRt: Decimal;
        CesAdvlAmt: Decimal;
        TotalValue: Decimal;
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        DetailedGSTLedgerEntry.RESET;
        DetailedGSTLedgerEntry.SETRANGE("Document No.", DocNo);
        DetailedGSTLedgerEntry.SETRANGE(Type, DetailedGSTLedgerEntry.Type::Item);
        IF LineNo <> 0 THEN
            DetailedGSTLedgerEntry.SETRANGE("Document Line No.", LineNo);

        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'CGST');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS("GST Amount");
            CgstAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            CgstRt := ABS(DetailedGSTLedgerEntry."GST %");
        END ELSE BEGIN
            CgstAmt := 0;
            CgstRt := 0;
        END;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'SGST');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS("GST Amount");
            SgstAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            SgstRt := ABS(DetailedGSTLedgerEntry."GST %");
        END ELSE BEGIN
            SgstAmt := 0;
            SgstRt := 0
        END;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'IGST');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS("GST Amount");
            IgstAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            IgstRt := ABS(DetailedGSTLedgerEntry."GST %");
        END ELSE BEGIN
            IgstAmt := 0;
            IgstRt := 0;
        END;
        CesRt := 0;
        CessAmt := 0;
        CesNonAdvlAmt := 0;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'CESS');
        IF DetailedGSTLedgerEntry.FINDSET THEN
            IF DetailedGSTLedgerEntry."GST %" > 0 THEN BEGIN
                DetailedGSTLedgerEntry.CALCSUMS("GST Amount");
                CesRt := DetailedGSTLedgerEntry."GST %";
                CessAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            END ELSE
                CesNonAdvlAmt := ABS(DetailedGSTLedgerEntry."GST Amount");

        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'INTERCESS');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS("GST Amount");
            CesRt := DetailedGSTLedgerEntry."GST %";
            CessAmt := DetailedGSTLedgerEntry."GST Amount";
        END;

        StateCesRt := 0;
        StateCesAmt := 0;
        StateCesNonAdvlAmt := 0;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code");
        IF DetailedGSTLedgerEntry.FINDSET THEN
            REPEAT
                IF NOT (DetailedGSTLedgerEntry."GST Component Code" IN ['CGST', 'SGST', 'IGST', 'CESS', 'INTERCESS']) THEN
                    IF GSTComponent.GET(DetailedGSTLedgerEntry."GST Component Code") THEN
                        IF DetailedGSTLedgerEntry."GST %" > 0 THEN BEGIN
                            StateCesRt := DetailedGSTLedgerEntry."GST %";
                            StateCesAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
                        END ELSE
                            StateCesNonAdvlAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            UNTIL DetailedGSTLedgerEntry.NEXT = 0;

        TotalValue := DetailedGSTLedgerEntry."GST Base Amount";

        IF SalesInvoiceHeader."Currency Code" <> '' THEN
            IF TotalValue <> 0 THEN
                TotalValue := ROUND((1 / SalesInvoiceHeader."Currency Factor") * TotalValue, 0.01, '=');
        IF LineNo = 0 THEN
            InvUpdateEwayCalculations(TotalValue, CgstAmt, SgstAmt, IgstAmt, CessAmt)//Header Json
        ELSE BEGIN
            // JsonTextWriter.WritePropertyName('cgst_rate');
            // JsonTextWriter.WriteValue(CgstRt);
            // JsonTextWriter.WritePropertyName('sgst_rate');
            // JsonTextWriter.WriteValue(SgstRt);
            // JsonTextWriter.WritePropertyName('igst_rate');
            // JsonTextWriter.WriteValue(IgstRt);
            // JsonTextWriter.WritePropertyName('cess_rate');
            // JsonTextWriter.WriteValue(CesRt);
            // SalesInvoiceLine.GET(DocNo, LineNo);
            // JsonTextWriter.WritePropertyName('quantity');
            // JsonTextWriter.WriteValue(SalesInvoiceLine.Quantity);
            // JsonTextWriter.WritePropertyName('cessNonAdvolValue');
            // JsonTextWriter.WriteValue(CesNonAdvlAmt);
            JSONItemL.Add('cgst_rate', CgstRt);
            JSONItemL.Add('sgst_rate', SgstRt);
            JSONItemL.Add('igst_rate', IgstRt);
            JSONItemL.Add('cess_rate', CesRt);
            SalesInvoiceLine.GET(DocNo, LineNo);
            JSONItemL.Add('quantity', SalesInvoiceLine.Quantity);
            JSONItemL.Add('cessNonAdvolValue', CesNonAdvlAmt);


        END;
    end;

    local procedure InvReadEwbDtls()
    var
        TransId: Text[15];
        TransName: Text[100];
        TransMode: Text[20];
        Distance: Text[4];
        TransDocNo: Text[15];
        TransDocDt: Text[10];
        VehNo: Text[20];
        VehType: Text[10];
        TransportMethod: Record "Transport Method";
        DistanceTxt: Text;
        TransactionType: Text;
    begin
        TransId := '';//Transit/GSTIN
        TransactionType := SalesInvoiceHeader."Transaction Type";
        IF TransportMethod.GET(SalesInvoiceHeader."Transport Method") THEN BEGIN
            TransName := '';
            TransMode := TransportMethod.Description;
        END;
        IF SalesInvoiceHeader."Distance (Km)" <> 0 THEN BEGIN
            DistanceTxt := DELCHR(FORMAT(ROUND(SalesInvoiceHeader."Distance (Km)", 1, '=')), '=', ',');

            IF STRLEN(DistanceTxt) > 4 THEN
                Distance := COPYSTR(DistanceTxt, 1, 4)
            ELSE
                Distance := DistanceTxt;
        END ELSE
            Distance := '';
        TransDocNo := '';//Trnasport Document No.
        TransDocDt := '';//Transport Doc Date
        VehNo := SalesInvoiceHeader."Vehicle No.";
        CASE SalesInvoiceHeader."Vehicle Type" OF
            SalesInvoiceHeader."Vehicle Type"::" ":
                VehType := '';
            SalesInvoiceHeader."Vehicle Type"::ODC:
                VehType := 'odc';
            SalesInvoiceHeader."Vehicle Type"::Regular:
                VehType := 'Regular';
        END;


        InvWriteEwbDtls(TransId, TransName, TransMode, Distance, TransDocNo, TransDocDt, VehNo, VehType, TransactionType);
    end;

    local procedure InvWriteEwbDtls(TransId: Text[15]; TransName: Text[100]; TransMode: Text[4]; Distance: Text[4]; TransDocNo: Text[15]; TransDocDt: Text[10]; VehNo: Text[20]; VehType: Text[10]; TransactionType: Text)
    begin
        // JsonTextWriter.WritePropertyName('transporter_id');
        // JsonTextWriter.WriteValue(TransId);
        // JsonTextWriter.WritePropertyName('transporter_name');
        // JsonTextWriter.WriteValue(TransName);
        // JsonTextWriter.WritePropertyName('transporter_document_number');
        // JsonTextWriter.WriteValue(TransDocNo);
        // JsonTextWriter.WritePropertyName('transporter_document_date');
        // JsonTextWriter.WriteValue(TransDocDt);
        // JsonTextWriter.WritePropertyName('transportation_mode');
        // JsonTextWriter.WriteValue(TransMode);
        // JsonTextWriter.WritePropertyName('transportation_distance');
        // JsonTextWriter.WriteValue(Distance);
        // JsonTextWriter.WritePropertyName('vehicle_number');
        // JsonTextWriter.WriteValue(VehNo);
        // JsonTextWriter.WritePropertyName('vehicle_type');
        // JsonTextWriter.WriteValue(VehType);
        // JsonTextWriter.WritePropertyName('generate_status');
        // JsonTextWriter.WriteValue('1');
        // JsonTextWriter.WritePropertyName('data_source');
        // JsonTextWriter.WriteValue('erp');
        // JsonTextWriter.WritePropertyName('user_ref');
        // JsonTextWriter.WriteValue(SalesInvoiceHeader."No.");
        // JsonTextWriter.WritePropertyName('location_code');
        // JsonTextWriter.WriteValue(SalesInvoiceHeader."Location Code");
        // JsonTextWriter.WritePropertyName('eway_bill_status');
        // JsonTextWriter.WriteValue('ABC');
        // JsonTextWriter.WritePropertyName('auto_print');
        // JsonTextWriter.WriteValue('Y');
        // //JsonTextWriter.WritePropertyName('EWB_print_type');
        // //JsonTextWriter.WriteValue('d');
        // JsonTextWriter.WritePropertyName('email');
        // JsonTextWriter.WriteValue(CompanyInfo."E-Mail");
        JOsupplyTypeG.Add('transporterId', TransId);
        JOsupplyTypeG.Add('transporterName', TransName);
        JOsupplyTypeG.Add('transDocNo', TransDocNo);
        JOsupplyTypeG.Add('transMode', TransMode);
        JOsupplyTypeG.Add('transDistance', Distance);
        JOsupplyTypeG.Add('transDocDate', TransDocDt);
        JOsupplyTypeG.Add('vehicleNo', VehNo);
        JOsupplyTypeG.Add('vehicleType', VehType);
        JOsupplyTypeG.Add('generate_status', '1');
        JOsupplyTypeG.Add('data_source', 'erp');
        JOsupplyTypeG.Add('user_ref', SalesInvoiceHeader."No.");
        JOsupplyTypeG.Add('location_code', SalesInvoiceHeader."Location Code");
        JOsupplyTypeG.Add('eway_bill_status', 'ABC');
        JOsupplyTypeG.Add('auto_print', 'Y');
        JOsupplyTypeG.Add('EWB_print_type', 'd');
        JOsupplyTypeG.Add('email', CompanyInfo."E-Mail");


    end;

    local procedure InvReadItemList()
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesLinesErr: Label 'E-Invoice allowes only 1000 lines per Invoice. Curent transaction is having %1 lines.', Comment = '%1 = Sales Lines count';
        HSNInt: Integer;
        Uom: Record "Unit of Measure";
    begin
        SalesInvoiceLine.RESET;
        SalesInvoiceLine.SETRANGE("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SETFILTER("No.", '<>%1', '');
        SalesInvoiceLine.SETRANGE(Type, SalesInvoiceLine.Type::Item);
        SalesInvoiceLine.SETFILTER(Quantity, '>%1', 0);
        SalesInvoiceLine.SETRANGE(Exempted, FALSE);
        IF SalesInvoiceLine.FINDSET THEN BEGIN
            IF SalesInvoiceLine.COUNT > 1000 THEN
                ERROR(SalesLinesErr, SalesInvoiceLine.COUNT);
            // JsonTextWriter.WritePropertyName('itemList');
            //JsonTextWriter.WriteStartArray;
            REPEAT
                EVALUATE(HSNInt, SalesInvoiceLine."HSN/SAC Code");
                /* JsonTextWriter.WriteStartObject;
                 JsonTextWriter.WritePropertyName('product_name');
                 JsonTextWriter.WriteValue(SalesInvoiceLine."No.");
                 JsonTextWriter.WritePropertyName('product_description');
                 JsonTextWriter.WriteValue(SalesInvoiceLine.Description);
                 JsonTextWriter.WritePropertyName('hsn_code');
                 JsonTextWriter.WriteValue(HSNInt);
                 Uom.GET(SalesInvoiceLine."Unit of Measure Code");
                 JsonTextWriter.WritePropertyName('unit_of_product');
                 JsonTextWriter.WriteValue(Uom."International Standard Code");

                 InvGetGSTCompRate(SalesInvoiceHeader."No.", SalesInvoiceLine."Line No.");

                 //JsonTextWriter.WritePropertyName('quantity');
                 //JsonTextWriter.WriteValue(SalesInvoiceLine.Quantity);
                 JsonTextWriter.WritePropertyName('taxableAmount');
                 IF SalesInvoiceHeader."Currency Code" <> '' THEN
                     JsonTextWriter.WriteValue((1 / SalesInvoiceHeader."Currency Factor") * SalesInvoiceLine."Line Amount")
                 ELSE
                     JsonTextWriter.WriteValue(SalesInvoiceLine."Line Amount");
                 JsonTextWriter.WriteEndObject;
                 */
                Uom.GET(SalesInvoiceLine."Unit of Measure Code");
                JOItemsG.Add('product_name', SalesInvoiceLine."No.");
                JOItemsG.Add('product_description', SalesInvoiceLine.Description);
                JOItemsG.Add('hsn_code', HSNInt);
                JOItemsG.Add('unit_of_product', Uom."International Standard Code");
                // JOItemsG.Add('quantity', SalesInvoiceLine.Quantity);

                InvGetGSTCompRate(SalesInvoiceHeader."No.", SalesInvoiceLine."Line No.", JOItemsG);
                IF SalesInvoiceHeader."Currency Code" <> '' THEN
                    JOItemsG.Add('taxableAmount', ((1 / SalesInvoiceHeader."Currency Factor") * SalesInvoiceLine."Line Amount"))
                else
                    JOItemsG.Add('taxableAmount', SalesInvoiceLine."Line Amount");
                JArrayItemsG.Add(JOItemsG);

            UNTIL SalesInvoiceLine.NEXT = 0;
            JOsupplyTypeG.Add('itemList', JArrayItemsG);
            //JsonTextWriter.WriteEndArray;
        END;
    end;

    procedure InvVechileJson()
    var
        LocationBuff: Record Location;
        StateBuff: Record State;
        Reason: Text;
        ReasonRemarks: Text;
        TransDocNo: Text;
        TransDocDate: Date;
        HeaderTitle: Label 'Enter Details';
        Title3: Label 'Vehicle No :';
        VehicleNo: Text;
        TransMode: Text;
        TransportMethod: Record "Transport Method";
        Title1: Text;
        Title2: Text;
        VehType: Text;
    begin
        LocationBuff.GET(SalesInvoiceHeader."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        IF IsPosting THEN BEGIN
            Reason := 'Others';//EWayBillingSetup."Vehicle Reason";
            ReasonRemarks := EWayBillingSetup."Vehicle Remarks";
            VehicleNo := SalesInvoiceHeader."Vehicle No.";
        END ELSE BEGIN
            Reason := 'Others';//EWayBillingSetup."Vehicle Reason";
            ReasonRemarks := EWayBillingSetup."Vehicle Remarks";
            //B2BUPG1.0>>
            // VehicleNo := Windows.InputBox(Title3, '', '', 10, 10);
            Clear(EWayUpdate);
            Commit();
            EWayUpdate.SetData(0);
            if EWayUpdate.RunModal() = Action::Yes then
                EWayUpdate.GetData(0, VehicleNo);
            //B2BUPG1.0<<
            IF VehicleNo = ' ' THEN
                EXIT;
            //SalesInvoiceHeader."Old Vehicle No" := SalesInvoiceHeader."Vehicle No.";
            SalesInvoiceHeader."Vehicle No." := VehicleNo;
            SalesInvoiceHeader.MODIFY();
        END;
        CASE SalesInvoiceHeader."Vehicle Type" OF
            SalesInvoiceHeader."Vehicle Type"::" ":
                VehType := '';
            SalesInvoiceHeader."Vehicle Type"::ODC:
                VehType := 'odc';
            SalesInvoiceHeader."Vehicle Type"::Regular:
                VehType := 'Regular';
        END;
        IF TransportMethod.GET(SalesInvoiceHeader."Transport Method") THEN BEGIN
            TransMode := TransportMethod.Description;
        END;
        TransDocNo := '';
        TransDocDate := 0D;
        InvWriteVechileJson(GetEwayBillIngNo(TransType::"Sales Invoice", SalesInvoiceHeader."No."), SalesInvoiceHeader."Location GST Reg. No.", VehicleNo, VehType, LocationBuff.City, StateBuff.Description, Reason, ReasonRemarks,
                        TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode);
    end;

    local procedure InvWriteVechileJson(EwbNo: Text; GSTIN: Text; VehicleNo: Text; VechicleType: Text; FromPlace: Text; FromState: Text; ReasonCode: Text; ReasonRem: Text; TransDocNo: Text; TransDocDate: Text; TransMode: Text)
    var
        EwbBigInt: BigInteger;
    begin
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('access_token');
         JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
         JsonTextWriter.WritePropertyName('userGstin');
         JsonTextWriter.WriteValue(GSTIN);
         JsonTextWriter.WritePropertyName('eway_bill_number');
         JsonTextWriter.WriteValue(EwbNo);
         JsonTextWriter.WritePropertyName('vehicle_number');
         JsonTextWriter.WriteValue(VehicleNo);
         JsonTextWriter.WritePropertyName('vehicle_type');
         JsonTextWriter.WriteValue(VechicleType);
         JsonTextWriter.WritePropertyName('place_of_consignor');
         JsonTextWriter.WriteValue(FromPlace);
         JsonTextWriter.WritePropertyName('state_of_consignor');
         JsonTextWriter.WriteValue(FromState);
         JsonTextWriter.WritePropertyName('reason_code_for_vehicle_updation');
         JsonTextWriter.WriteValue(ReasonCode);
         JsonTextWriter.WritePropertyName('reason_for_vehicle_updation');
         JsonTextWriter.WriteValue(ReasonRem);
         JsonTextWriter.WritePropertyName('transporter_document_number');
         JsonTextWriter.WriteValue(TransDocNo);
         JsonTextWriter.WritePropertyName('transporter_document_date');
         JsonTextWriter.WriteValue(TransDocDate);
         JsonTextWriter.WritePropertyName('mode_of_transport');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WritePropertyName('data_source');
         JsonTextWriter.WriteValue('erp');
         JsonTextWriter.WriteEndObject();*/
        JOVehicleG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOVehicleG.Add('userGstin', GSTIN);
        JOVehicleG.Add('eway_bill_number', EwbNo);
        JOVehicleG.Add('vehicle_number', VehicleNo);
        JOVehicleG.Add('vehicle_type', VechicleType);
        JOVehicleG.Add('place_of_consignor', FromPlace);
        JOVehicleG.Add('state_of_consignor', FromState);
        JOVehicleG.Add('reason_code_for_vehicle_updation', ReasonCode);
        JOVehicleG.Add('reason_for_vehicle_updation', ReasonRem);
        JOVehicleG.Add('transporter_document_number', TransDocNo);
        JOVehicleG.Add('transporter_document_date', '');
        JOVehicleG.add('mode_of_transport', TransMode);
        JOVehicleG.Add('data_source', 'erp');


    end;

    local procedure InvCancelEwayJson()
    var
        HeaderTitle: Label 'Enter Cancel Details';
        Title1: Label 'Cancel Reason :';
        Title2: Label 'Cancel Remarks :';
        LocationBuff: Record Location;
        StateBuff: Record State;
        Reason: Text;
        ReasonRemarks: Text;
        TransDocNo: Text;
        TransDocDate: Date;
        Title3: Text;
        RemainingDist: Text;
    begin
        //B2BUPG1.0>>
        //IF NOT OpenWindow(HeaderTitle, Title1, Title2, Title3, Reason, ReasonRemarks, RemainingDist) THEN
        //    EXIT;
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(3);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetCancelTransportData(3, Reason, ReasonRemarks, RemainingDist);
        IF (Reason = '') or (ReasonRemarks = '') THEN
            EXIT;
        //B2BUPG1.0<<
        InvWriteCancelJson(GetEwayBillIngNo(TransType::"Sales Invoice", SalesInvoiceHeader."No."), SalesInvoiceHeader."Location GST Reg. No.", Reason, ReasonRemarks);
    end;

    local procedure InvWriteCancelJson(EWBNo: Text; GSTIN: Text; CancelReason: Text; CancelRemarks: Text)
    begin

        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('access_token');
         JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
         JsonTextWriter.WritePropertyName('userGstin');
         JsonTextWriter.WriteValue(GSTIN);
         JsonTextWriter.WritePropertyName('eway_bill_number');
         JsonTextWriter.WriteValue(EWBNo);
         JsonTextWriter.WritePropertyName('reason_of_cancel');
         JsonTextWriter.WriteValue(CancelReason);
         JsonTextWriter.WritePropertyName('cancel_remark');
         JsonTextWriter.WriteValue(CancelRemarks);
         JsonTextWriter.WritePropertyName('data_source');
         JsonTextWriter.WriteValue('erp');
         JsonTextWriter.WriteEndObject();*/
        JOCancelG.add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOCancelG.Add('userGstin', GSTIN);
        JOCancelG.Add('eway_bill_number', EWBNo);
        JOCancelG.Add('reason_of_cancel', CancelReason);
        JOCancelG.Add('cancel_remark', CancelRemarks);
        JOCancelG.Add('data_source', 'erp');

    end;

    procedure InvRejectEwayJson(RejDocumentNo: Code[20]; var RejEwayBillNo: BigInteger)
    var
        HeaderTitle: Label 'Enter Cancel Details';
        Title1: Label 'Cancel Reason :';
        Title2: Label 'Cancel Remarks :';
        RejectEwayBillNo: Text;

        EWayValidator: Codeunit "E-Way Validator";
        RejectErr: Label 'E-Way bill no must be provided to Reject.';
    begin
        EWayBillingSetup.GET;
        RequestType := RequestType::RejectEway;


        //B2BUPG1.0<<
        //RejectEwayBillNo := Windows.InputBox('Rejecting E-Way Bill No :', '', '', 10, 10);
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(1);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetData(1, RejectEwayBillNo);
        //B2BUPG1.0<<
        IF RejectEwayBillNo = '' THEN
            ERROR(RejectErr);
        EWayValidator.CheckValidations(RejectEwayBillNo, RequestType);//Check Validations

        /*JsonTextWriter.WriteStartObject();
        JsonTextWriter.WritePropertyName('access_token');
        JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JsonTextWriter.WritePropertyName('userGstin');
        JsonTextWriter.WriteValue(CompanyInfo."GST Registration No.");
        JsonTextWriter.WritePropertyName('eway_bill_number');
        JsonTextWriter.WriteValue(RejectEwayBillNo);
        JsonTextWriter.WritePropertyName('data_source');
        JsonTextWriter.WriteValue('erp');
        JsonTextWriter.WriteEndObject();
        EVALUATE(RejEwayBillNo, RejectEwayBillNo);
        ExportAsJson(RejDocumentNo, PathSaved);*/
        JORejEWayNoG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JORejEWayNoG.Add('userGstin', CompanyInfo."GST Registration No.");
        EVALUATE(RejEwayBillNo, RejectEwayBillNo);
        JORejEWayNoG.Add('eway_bill_number', RejectEwayBillNo);
        JORejEWayNoG.Add('data_source', 'erp');

    end;

    local procedure InvUpdateTransportJson()
    var
        TransportID: Text;
        TransportIDError: Label 'Transport Id must have value';
        HeaderTitle: Label 'Trasporter Details';
        Title1: Label 'Transporter ID';
        Title2: Label 'Transporter Name';
        Title3: Text;
        TransporterName: Text;
        Blank: Text;
    begin
        //  TransportID := Windows.InputBox('Transporter ID :','','',10,10);
        //  IF TransportID = '' THEN
        //    ERROR(TransportIDError);
        //B2BUPG1.0>>
        //IF NOT OpenWindow(HeaderTitle, Title1, Title2, Title3, TransportID, TransporterName, Blank) THEN
        //    EXIT;
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(3);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetCancelTransportData(3, TransportID, TransporterName, Blank);
        IF (TransportID = '') or (TransporterName = '') THEN
            EXIT;
        //B2BUPG1.0<<
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(2);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetData(2, TransportID);
        IF TransportID = '' THEN
            exit;
        //B2BUPG1.0<<
        /*  JsonTextWriter.WriteStartObject();
          JsonTextWriter.WritePropertyName('access_token');
          JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
          JsonTextWriter.WritePropertyName('userGstin');
          JsonTextWriter.WriteValue(SalesInvoiceHeader."Location GST Reg. No.");
          JsonTextWriter.WritePropertyName('eway_bill_number');
          JsonTextWriter.WriteValue(GetEwayBillIngNo(TransType::"Sales Invoice", SalesInvoiceHeader."No."));
          JsonTextWriter.WritePropertyName('transporter_id');
          JsonTextWriter.WriteValue(TransportID);
          JsonTextWriter.WritePropertyName('transporter_name');
          JsonTextWriter.WriteValue(TransporterName);
          JsonTextWriter.WriteEndObject();*/
        JOUpdatetransportIDG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOUpdatetransportIDG.Add('userGstin', SalesInvoiceHeader."Location GST Reg. No.");
        JOUpdatetransportIDG.Add('eway_bill_number', GetEwayBillIngNo(TransType::"Sales Invoice", SalesInvoiceHeader."No."));
        JOUpdatetransportIDG.Add('transporter_id', TransportID);
        JOUpdatetransportIDG.Add('transporter_name', TransporterName);

    end;

    local procedure InvExtendValidityJson()
    var
        LocationBuff: Record Location;
        StateBuff: Record State;
        HeaderTitle: Label 'Enter Details';
        Title1: Label 'Reason :';
        Title2: Label 'Remarks :';
        Title3: Label 'Rem. Dist :';
        Reason: Text;
        ReasonRemarks: Text;
        TransDocNo: Text;
        TransDocDate: Date;
        RemainingDist: Integer;
        RemainingDistText: Text;
        Pin: Integer;
        ExtendErr: Label 'Reason,Remarks and Remaining Distance has to be given to Extend E-Way validity.';
        TransportMethod: Record "Transport Method";
        TransMode: Text;
    begin
        LocationBuff.GET(SalesInvoiceHeader."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        //B2BUPG1.0>>
        //IF NOT OpenWindow(HeaderTitle, Title1, Title2, Title3, Reason, ReasonRemarks, RemainingDistText) THEN
        //    ERROR(ExtendErr);
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(3);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetCancelTransportData(3, Reason, ReasonRemarks, RemainingDistText);
        IF (Reason = '') or (ReasonRemarks = '') THEN
            ERROR(ExtendErr);
        //B2BUPG1.0<<
        EVALUATE(RemainingDist, RemainingDistText);
        IF SalesInvoiceHeader."GST Customer Type" = SalesInvoiceHeader."GST Customer Type"::Export THEN
            EVALUATE(Pin, '999999')
        ELSE
            EVALUATE(Pin, COPYSTR(SalesInvoiceHeader."Bill-to Post Code", 1, 6));

        IF TransportMethod.GET(SalesInvoiceHeader."Transport Method") THEN BEGIN
            // CASE TransportMethod."Transportation Mode" OF
            //     TransportMethod."Transportation Mode"::Road:
            //         TransMode := 'road';
            //     TransportMethod."Transportation Mode"::Rail:
            //         TransMode := 'rail';
            //     TransportMethod."Transportation Mode"::Air:
            //         TransMode := 'air';
            //     TransportMethod."Transportation Mode"::Ship:
            //         TransMode := 'ship';
            // END;
            TransMode := TransportMethod.Description;
        END;

        TransDocNo := '';
        TransDocDate := 0D;
        InvWriteExtendValidityJson(GetEwayBillIngNo(TransType::"Sales Invoice", SalesInvoiceHeader."No."), SalesInvoiceHeader."Location GST Reg. No.", SalesInvoiceHeader."Vehicle No.", LocationBuff.City, StateBuff.Description,
        RemainingDist, TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode, Reason, ReasonRemarks, Pin, 'M', SalesInvoiceHeader."Transaction Type",
                      SalesInvoiceHeader."Sell-to Address", SalesInvoiceHeader."Sell-to Address 2", SalesInvoiceHeader."Sell-to City");
    end;

    local procedure InvWriteExtendValidityJson(EwbNo: Text; GSTIN: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; RemainingDist: Integer; TransDocNo: Text; TransDocDate: Text; TransMode: Text; ReasonCode: Text; ReasonRem: Text; FromPincode: Integer; ConsignmentStatus: Text; TransitType: Text; AddressLine1: Text; AddressLine2: Text; AddressLine3: Text)
    begin
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('access_token');
         JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
         JsonTextWriter.WritePropertyName('userGstin');
         JsonTextWriter.WriteValue(GSTIN);
         JsonTextWriter.WritePropertyName('eway_bill_number');
         JsonTextWriter.WriteValue(EwbNo);
         JsonTextWriter.WritePropertyName('vehicle_number');
         JsonTextWriter.WriteValue(VehicleNo);
         JsonTextWriter.WritePropertyName('place_of_consignor');
         JsonTextWriter.WriteValue(FromPlace);
         JsonTextWriter.WritePropertyName('state_of_consignor');
         JsonTextWriter.WriteValue(FromState);
         JsonTextWriter.WritePropertyName('remaining_distance');
         JsonTextWriter.WriteValue(RemainingDist);
         JsonTextWriter.WritePropertyName('transporter_document_number');
         JsonTextWriter.WriteValue(TransDocNo);
         JsonTextWriter.WritePropertyName('transporter_document_date');
         JsonTextWriter.WriteValue(TransDocDate);
         JsonTextWriter.WritePropertyName('mode_of_transport');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WritePropertyName('extend_validity_reason');
         JsonTextWriter.WriteValue(ReasonCode);
         JsonTextWriter.WritePropertyName('extend_remarks');
         JsonTextWriter.WriteValue(ReasonRem);
         JsonTextWriter.WritePropertyName('from_pincode');
         JsonTextWriter.WriteValue(FromPincode);
         JsonTextWriter.WritePropertyName('consignment_status');
         JsonTextWriter.WriteValue(ConsignmentStatus);
         JsonTextWriter.WritePropertyName('transit_type');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WritePropertyName('address_line1');
         JsonTextWriter.WriteValue(AddressLine1);
         JsonTextWriter.WritePropertyName('address_line2');
         JsonTextWriter.WriteValue(AddressLine2);
         JsonTextWriter.WritePropertyName('address_line3');
         JsonTextWriter.WriteValue(AddressLine3);
         JsonTextWriter.WriteEndObject();*/
        JOExtendValidityJsonG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOExtendValidityJsonG.Add('userGstin', GSTIN);
        JOExtendValidityJsonG.Add('eway_bill_number', EwbNo);
        JOExtendValidityJsonG.Add('vehicle_number', VehicleNo);
        JOExtendValidityJsonG.Add('place_of_consignor', FromPlace);
        JOExtendValidityJsonG.Add('state_of_consignor', FromState);
        JOExtendValidityJsonG.Add('remaining_distance', RemainingDist);
        JOExtendValidityJsonG.Add('transporter_document_number', TransDocNo);
        JOExtendValidityJsonG.Add('transporter_document_date', TransDocDate);
        JOExtendValidityJsonG.Add('mode_of_transport', '5');
        JOExtendValidityJsonG.Add('extend_validity_reason', ReasonCode);
        JOExtendValidityJsonG.Add('extend_remarks', ReasonRem);
        JOExtendValidityJsonG.add('from_pincode', FromPincode);
        JOExtendValidityJsonG.add('consignment_status', ConsignmentStatus);
        JOExtendValidityJsonG.add('transit_type', 'R');
        JOExtendValidityJsonG.Add('address_line1', AddressLine1);
        JOExtendValidityJsonG.Add('address_line2', AddressLine2);
        JOExtendValidityJsonG.Add('address_line3', AddressLine3);
    end;

    local procedure "-----------------------------------------SHIPMENT START --------------------"()
    begin
    end;

    procedure SetSalesShipHeader(var SalesShipHdrBuff: Record "Sales Shipment Header"; RequestTypePar: Option Eway,Vehicle,EWayCancel,RejectEway,ExtendValidity,UpdateTrasporter,AccessToken; IsPostingPar: Boolean)
    begin
        SalesShipHeader := SalesShipHdrBuff;
        RequestType := RequestTypePar;
        IsPosting := IsPostingPar;
    end;

    procedure ShipEWayJson()
    var
        LocationBuff: Record Location;
        StateBuff: Record State;
        Gstin: Text;
        Pin: Text;
        Pos: Text;
        Path: Text;
        SubSupplyType: Text;
        SubType: Text;
    begin
        IF SalesShipHeader."GST Customer Type" = SalesShipHeader."GST Customer Type"::Export THEN BEGIN
            Gstin := 'URP';
            Pin := '999999';
            SubSupplyType := 'Export';
            SubType := 'outward';
        END ELSE BEGIN
            Gstin := SalesShipHeader."Customer GST Reg. No.";//
            Pin := COPYSTR(SalesShipHeader."Bill-to Post Code", 1, 6);
            SubSupplyType := 'Supply';
            SubType := 'outward';
        END;
        ShipEWayHeadDetails(SalesShipHeader."Location GST Reg. No.", SubType, SubSupplyType, 'Tax Invoice', SalesShipHeader."No.", FORMAT(SalesShipHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>')); //Header

        //From Details >>
        LocationBuff.GET(SalesShipHeader."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        ShipEwayFromDetails(SalesShipHeader."Location GST Reg. No.", CompanyInfo.Name, LocationBuff.Address, LocationBuff."Address 2", LocationBuff.City
                        , LocationBuff."Post Code", StateBuff.Description, StateBuff.Description);
        //From Details <<

        //To Details >>

        Pos := ShipGetEwayPos(SalesShipHeader."No.");
        ShipEwayToDetails(Gstin, SalesShipHeader."Bill-to Name", SalesShipHeader."Bill-to Address", SalesShipHeader."Bill-to Address 2", SalesShipHeader."Bill-to City", Pin, Pos, Pos);
        //To Details <<
        ShipGetGSTCompRate(SalesShipHeader."No.", 0, JOItemsG);//Update GST calculations
        ShipReadEwbDtls();//Update Transport Details

        ShipReadItemList();
        //  JsonTextWriter.WriteEndObject;
        //ExportAsJson(SalesShipHeader."No.", Path);
    end;

    local procedure ShipEWayHeadDetails(GstIn: Text; SupplyType: Text; SupplySubType: Text; Doctype: Text; DocNo: Text; DocDate: Text)
    begin
        EWayBillingSetup.GET();
        /*   JsonTextWriter.WriteStartObject;
           JsonTextWriter.WritePropertyName('access_token');
           JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
           JsonTextWriter.WritePropertyName('userGstin');
           JsonTextWriter.WriteValue(GstIn);
           JsonTextWriter.WritePropertyName('supply_type');
           JsonTextWriter.WriteValue(SupplyType);
           JsonTextWriter.WritePropertyName('sub_supply_type');
           JsonTextWriter.WriteValue(SupplySubType);
           JsonTextWriter.WritePropertyName('sub_supply_description');
           JsonTextWriter.WriteValue('');
           JsonTextWriter.WritePropertyName('document_type');
           JsonTextWriter.WriteValue(Doctype);
           JsonTextWriter.WritePropertyName('document_number');
           JsonTextWriter.WriteValue(DocNo);
           JsonTextWriter.WritePropertyName('document_date');
           JsonTextWriter.WriteValue(DocDate);*/
        JOsupplyTypeG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOsupplyTypeG.Add('supply_type', SupplyType);
        JOsupplyTypeG.Add('sub_supply_type', SupplySubType);

        JOsupplyTypeG.Add('sub_supply_description', '');

        JOsupplyTypeG.Add('document_type', Doctype);
        JOsupplyTypeG.Add('document_number', DocNo);
        JOsupplyTypeG.Add('document_date', DocDate);
    end;

    procedure ShipEwayFromDetails(FromGstin: Text; FromTrdName: Text; FromAdd1: Text; FromAdd2: Text; FromPlace: Text; FromPinCode: Text; ActFromStateCode: Text; FromStateCode: Text): Boolean
    var
        FromPinCodeInt: Integer;
        ActFromStateCodeInt: Integer;
        FromStateCodeInt: Integer;
    begin
        IF FromPinCode <> '' THEN
            EVALUATE(FromPinCodeInt, FromPinCode);
        /* JsonTextWriter.WritePropertyName('gstin_of_consignor');
         JsonTextWriter.WriteValue(FromGstin);
         JsonTextWriter.WritePropertyName('legal_name_of_consignor');
         JsonTextWriter.WriteValue(FromTrdName);
         JsonTextWriter.WritePropertyName('address1_of_consignor');
         JsonTextWriter.WriteValue(FromAdd1);
         JsonTextWriter.WritePropertyName('address2_of_consignor');
         JsonTextWriter.WriteValue(FromAdd2);
         JsonTextWriter.WritePropertyName('place_of_consignor');
         JsonTextWriter.WriteValue(FromPlace);
         JsonTextWriter.WritePropertyName('pincode_of_consignor');
         JsonTextWriter.WriteValue(FromPinCodeInt);
         JsonTextWriter.WritePropertyName('state_of_consignor');
         JsonTextWriter.WriteValue(FromStateCode);
         JsonTextWriter.WritePropertyName('actual_from_state_name');
         JsonTextWriter.WriteValue(ActFromStateCode);*/
        JOsupplyTypeG.Add('gstin_of_consignor', FromGstin);
        JOsupplyTypeG.Add('legal_name_of_consignor', FromTrdName);
        JOsupplyTypeG.Add('address1_of_consignor', FromAdd1);
        JOsupplyTypeG.Add('address2_of_consignor', FromAdd2);
        JOsupplyTypeG.Add('place_of_consignor', FromPlace);
        JOsupplyTypeG.Add('pincode_of_consignor', FromPinCodeInt);
        JOsupplyTypeG.Add('state_of_consignor', FromStateCodeInt);
        JOsupplyTypeG.Add('actual_from_state_name', ActFromStateCode);

    end;

    procedure ShipEwayToDetails(ToGstin: Text; ToTrdName: Text; ToAdd1: Text; ToAdd2: Text; ToPlace: Text; ToPinCode: Text; ActFromStateCode: Text; ToStateCode: Text): Boolean
    var
        ToPinCodeInt: Integer;
        ActToStateCodeInt: Integer;
        ToStateCodeInt: Integer;
    begin
        IF ToPinCode <> '' THEN
            EVALUATE(ToPinCodeInt, ToPinCode);
        /* JsonTextWriter.WritePropertyName('gstin_of_consignee');
         JsonTextWriter.WriteValue(ToGstin);
         JsonTextWriter.WritePropertyName('legal_name_of_consignee');
         JsonTextWriter.WriteValue(ToTrdName);
         JsonTextWriter.WritePropertyName('address1_of_consignee');
         JsonTextWriter.WriteValue(ToAdd1);
         JsonTextWriter.WritePropertyName('address2_of_consignee');
         JsonTextWriter.WriteValue(ToAdd2);
         JsonTextWriter.WritePropertyName('place_of_consignee');
         JsonTextWriter.WriteValue(ToPlace);
         JsonTextWriter.WritePropertyName('pincode_of_consignee');
         JsonTextWriter.WriteValue(ToPinCodeInt);
         JsonTextWriter.WritePropertyName('state_of_supply');*/
        JOsupplyTypeG.Add('gstin_of_consignee', ToGstin);
        JOsupplyTypeG.Add('legal_name_of_consignee', ToTrdName);
        JOsupplyTypeG.Add('address1_of_consignee', ToAdd1);
        JOsupplyTypeG.Add('address2_of_consignee', ToAdd2);
        JOsupplyTypeG.Add('place_of_consignee', ToPlace);
        JOsupplyTypeG.Add('pincode_of_consignee', ToPinCodeInt);
        //Export >>
        IF (SalesInvoiceHeader."GST Customer Type" IN [SalesInvoiceHeader."GST Customer Type"::Export, SalesInvoiceHeader."GST Customer Type"::"SEZ Development",
                                                  SalesInvoiceHeader."GST Customer Type"::"SEZ Unit"]) THEN
            //  JsonTextWriter.WriteValue('OTHER TERRITORY')
            JOsupplyTypeG.Add('state_of_supply', 'OTHER TERRITORY')

        ELSE
            // JsonTextWriter.WriteValue(ToStateCode);
            JOsupplyTypeG.Add('state_of_supply', ToStateCode);

        // JsonTextWriter.WritePropertyName('actual_to_state_name');
        IF (SalesInvoiceHeader."GST Customer Type" IN [SalesInvoiceHeader."GST Customer Type"::Export, SalesInvoiceHeader."GST Customer Type"::"SEZ Development",
                                                  SalesInvoiceHeader."GST Customer Type"::"SEZ Unit"]) THEN
            //   JsonTextWriter.WriteValue('OTHER TERRITORY')
             JOsupplyTypeG.Add('actual_to_state_name', 'OTHER TERRITORY')
        ELSE
            //  JsonTextWriter.WriteValue(ActFromStateCode);
            /* JsonTextWriter.WritePropertyName('transaction_type');
             JsonTextWriter.WriteValue(FORMAT(SalesInvoiceHeader."Transaction Type"));
             JsonTextWriter.WritePropertyName('other_value');
             JsonTextWriter.WriteValue('');*/

        JOsupplyTypeG.Add('actual_to_state_name', ActFromStateCode);
        JOsupplyTypeG.Add('transaction_type', SalesInvoiceHeader."Transaction Type");
        JOsupplyTypeG.Add('other_value', '');


    end;

    local procedure ShipGetEwayPos(No: Code[20]): Text
    var
        SalesShipLine: Record "Sales Shipment Line";
        SalesCredLine: Record "Sales Cr.Memo Line";
        StateBuff: Record State;
    begin
        SalesShipLine.RESET;
        SalesShipLine.SETRANGE("Document No.", No);
        SalesShipLine.SETFILTER("No.", '<>%1', '');//BugFix
        SalesShipLine.SETRANGE(Exempted, FALSE);
        IF SalesShipLine.FINDFIRST THEN
            IF SalesShipLine."GST Place of Supply" = SalesShipLine."GST Place of Supply"::"Bill-to Address" THEN BEGIN
                IF NOT (SalesShipHeader."GST Customer Type" = SalesShipHeader."GST Customer Type"::Export) THEN BEGIN
                    StateBuff.GET(SalesShipHeader."GST Bill-to State Code");
                    EXIT(StateBuff.Description);
                END ELSE
                    EXIT('OTHER COUNTRY');
            END ELSE
                IF SalesShipLine."GST Place of Supply" = SalesShipLine."GST Place of Supply"::"Ship-to Address" THEN BEGIN
                    IF NOT (SalesShipHeader."GST Customer Type" = SalesShipHeader."GST Customer Type"::Export) THEN BEGIN
                        StateBuff.GET(SalesShipHeader."GST Ship-to State Code");
                        EXIT(StateBuff.Description);
                    END ELSE
                        EXIT('OTHER COUNTRY');
                END;
    end;

    local procedure ShipUpdateEwayCalculations(CgstValue: Decimal; SgstValue: Decimal; IgstValue: Decimal; CessValue: Decimal)
    var
        SalesShipLine: Record "Sales Shipment Line";
        TotalValue: Decimal;
        TotalInvValue: Decimal;
    begin
        SalesShipLine.RESET;
        SalesShipLine.SETRANGE("Document No.", SalesShipHeader."No.");
        SalesShipLine.SETRANGE(Type, SalesShipLine.Type::Item);
        SalesShipLine.SETRANGE(Exempted, FALSE);
        IF SalesShipLine.FINDSET THEN BEGIN
            REPEAT
                TotalInvValue += (SalesShipLine.Quantity * SalesShipLine."Unit Price") -
                                 ((SalesShipLine.Quantity * SalesShipLine."Unit Price") * SalesShipLine."Line Discount %" / 100);
            UNTIL SalesShipLine.NEXT = 0;
        END;
        IF SalesShipHeader."Currency Code" <> '' THEN BEGIN
            TotalInvValue := (1 / SalesShipHeader."Currency Factor") * TotalInvValue
        END;
        TotalValue := CgstValue + SgstValue + IgstValue + CessValue;
        /* JsonTextWriter.WritePropertyName('total_invoice_value');
         JsonTextWriter.WriteValue(TotalInvValue + TotalValue);
         JsonTextWriter.WritePropertyName('taxable_amount');
         JsonTextWriter.WriteValue(ABS(TotalInvValue));
         JsonTextWriter.WritePropertyName('cgst_amount');
         JsonTextWriter.WriteValue(CgstValue);
         JsonTextWriter.WritePropertyName('sgst_amount');
         JsonTextWriter.WriteValue(SgstValue);
         JsonTextWriter.WritePropertyName('igst_amount');
         JsonTextWriter.WriteValue(IgstValue);
         JsonTextWriter.WritePropertyName('cess_amount');
         JsonTextWriter.WriteValue(CessValue);
         JsonTextWriter.WritePropertyName('cess_nonadvol_value');
         JsonTextWriter.WriteValue('');*/

        JOsupplyTypeG.Add('total_invoice_value', TotalInvValue + TotalValue);
        JOsupplyTypeG.Add('taxable_amount', ABS(TotalInvValue));
        JOsupplyTypeG.Add('cgst_amount', CgstValue);
        JOsupplyTypeG.Add('sgst_amount', SgstValue);
        JOsupplyTypeG.Add('igst_amount', IgstValue);
        JOsupplyTypeG.Add('cess_amount', CessValue);
        JOsupplyTypeG.Add('cess_nonadvol_value', '');

    end;

    local procedure ShipGetGSTCompRate(DocNo: Code[20]; LineNo: Integer; var JSONItemL: JsonObject)
    var
        DetailedGSTLedgerEntry: Record "GST Entry";
        GSTComponent: Record "Tax Component";
        CurrExchRate: Record "Currency Exchange Rate";
        CurrencyCode: Code[10];
        CurrencyFactor: Decimal;
        CgstAmt: Decimal;
        SgstAmt: Decimal;
        IgstAmt: Decimal;
        CesRt: Decimal;
        CessAmt: Decimal;
        CesNonAdvlAmt: Decimal;
        StateCesRt: Decimal;
        StateCesAmt: Decimal;
        StateCesNonAdvlAmt: Decimal;
        CgstRt: Decimal;
        SgstRt: Decimal;
        IgstRt: Decimal;
        CesAdvlAmt: Decimal;
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        ShipCalCulateShipmentGST(SalesShipHeader);
        DetailedGSTLedgerEntry.SETRANGE("Document No.", DocNo);

        IF LineNo <> 0 THEN
            DetailedGSTLedgerEntry.SETRANGE("Document Line No.", LineNo);

        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'CGST');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS(Amount);
            CgstAmt := ABS(DetailedGSTLedgerEntry.Amount);
            CgstRt := ABS(DetailedGSTLedgerEntry."GST Component %");
        END ELSE BEGIN
            CgstAmt := 0;
            CgstRt := 0;
        END;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'SGST');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS(Amount);
            SgstAmt := ABS(DetailedGSTLedgerEntry.Amount);
            SgstRt := ABS(DetailedGSTLedgerEntry."GST Component %");
        END ELSE BEGIN
            SgstAmt := 0;
            SgstRt := 0
        END;

        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'IGST');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS(Amount);
            IgstAmt := ABS(DetailedGSTLedgerEntry.Amount);
            IgstRt := ABS(DetailedGSTLedgerEntry."GST Component %");
        END ELSE BEGIN
            IgstAmt := 0;
            IgstRt := 0;
        END;
        CesRt := 0;
        CessAmt := 0;
        CesNonAdvlAmt := 0;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'CESS');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS(Amount);
            IF DetailedGSTLedgerEntry."GST Component %" > 0 THEN BEGIN
                CesRt := DetailedGSTLedgerEntry."GST Component %";
                CessAmt := ABS(DetailedGSTLedgerEntry.Amount);
            END ELSE
                CesNonAdvlAmt := ABS(DetailedGSTLedgerEntry.Amount);
        END;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'INTERCESS');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS(Amount);
            CesRt := DetailedGSTLedgerEntry."GST Component %";
            CessAmt := DetailedGSTLedgerEntry.Amount;
        END;

        StateCesRt := 0;
        StateCesAmt := 0;
        StateCesNonAdvlAmt := 0;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code");
        IF DetailedGSTLedgerEntry.FINDSET THEN
            REPEAT
                IF NOT (DetailedGSTLedgerEntry."GST Component Code" IN ['CGST', 'SGST', 'IGST', 'CESS', 'INTERCESS']) THEN
                    IF GSTComponent.GET(DetailedGSTLedgerEntry."GST Component Code") THEN
                        IF DetailedGSTLedgerEntry."GST Component %" > 0 THEN BEGIN
                            StateCesRt := DetailedGSTLedgerEntry."GST Component %";
                            StateCesAmt := ABS(DetailedGSTLedgerEntry.Amount);
                        END ELSE
                            StateCesNonAdvlAmt := ABS(DetailedGSTLedgerEntry.Amount);
            UNTIL DetailedGSTLedgerEntry.NEXT = 0;

        IF SalesShipHeader."Currency Code" <> '' THEN BEGIN
            CurrencyCode := SalesShipHeader."Currency Code";
            CurrencyFactor := SalesShipHeader."Currency Factor";

            IF IgstAmt <> 0 THEN
                IgstAmt := ROUND((1 / SalesShipHeader."Currency Factor") * IgstAmt, 0.01, '=');
            IF CgstAmt <> 0 THEN
                CgstAmt := ROUND((1 / SalesShipHeader."Currency Factor") * CgstAmt, 0.01, '=');
            IF SgstAmt <> 0 THEN
                SgstAmt := ROUND((1 / SalesShipHeader."Currency Factor") * SgstAmt, 0.01, '=');
            IF CessAmt <> 0 THEN
                CessAmt := ROUND((1 / SalesShipHeader."Currency Factor") * CessAmt, 0.01, '=');
            IF CesNonAdvlAmt <> 0 THEN
                CesNonAdvlAmt := ROUND((1 / SalesShipHeader."Currency Factor") * CesNonAdvlAmt, 0.01, '=');
            IF StateCesAmt <> 0 THEN
                StateCesAmt := ROUND((1 / SalesShipHeader."Currency Factor") * StateCesAmt, 0.01, '=');
            IF StateCesNonAdvlAmt <> 0 THEN
                StateCesNonAdvlAmt := ROUND((1 / SalesShipHeader."Currency Factor") * StateCesNonAdvlAmt, 0.01, '=');
        END;

        IF LineNo = 0 THEN
            ShipUpdateEwayCalculations(CgstAmt, SgstAmt, IgstAmt, CessAmt)//Header Json
        ELSE BEGIN
            /* JsonTextWriter.WritePropertyName('cgst_rate');
             JsonTextWriter.WriteValue(CgstRt);
             JsonTextWriter.WritePropertyName('sgst_rate');
             JsonTextWriter.WriteValue(SgstRt);
             JsonTextWriter.WritePropertyName('igst_rate');
             JsonTextWriter.WriteValue(IgstRt);
             JsonTextWriter.WritePropertyName('cess_rate');
             JsonTextWriter.WriteValue(CesRt);
             SalesShipmentLine.GET(DocNo, LineNo);
             JsonTextWriter.WritePropertyName('quantity');
             JsonTextWriter.WriteValue(SalesShipmentLine.Quantity);
             JsonTextWriter.WritePropertyName('cessNonAdvolValue');
             JsonTextWriter.WriteValue(CesNonAdvlAmt);*/
            JSONItemL.Add('cgst_rate', CgstRt);
            JSONItemL.Add('sgst_rate', SgstRt);
            JSONItemL.Add('igst_rate', IgstRt);
            JSONItemL.Add('cess_rate', CesRt);
            SalesShipmentLine.GET(DocNo, LineNo);
            JSONItemL.Add('quantity', SalesShipmentLine.Quantity);
            JSONItemL.Add('cessNonAdvolValue', CesNonAdvlAmt);
        END;
    end;

    local procedure ShipEWayTransportDetails()
    begin
    end;

    local procedure ShipReadEwbDtls()
    var
        TransId: Text[15];
        TransName: Text[100];
        TransMode: Text[20];
        Distance: Text[4];
        TransDocNo: Text[15];
        TransDocDt: Text[10];
        VehNo: Text[20];
        VehType: Text[20];
        TransportMethod: Record "Transport Method";
        DistanceTxt: Text;
        TransactionType: Text;
    begin
        TransId := '';//Transit/GSTIN
        TransactionType := SalesShipHeader."Transaction Type";
        IF TransportMethod.GET(SalesShipHeader."Transport Method") THEN BEGIN
            TransName := '';
            TransMode := TransportMethod.Description;
        END;
        IF SalesShipHeader."Distance (Km)" <> 0 THEN BEGIN
            DistanceTxt := DELCHR(FORMAT(ROUND(SalesShipHeader."Distance (Km)", 1, '=')), '=', ',');

            IF STRLEN(DistanceTxt) > 4 THEN
                Distance := COPYSTR(DistanceTxt, 1, 4)
            ELSE
                Distance := DistanceTxt;
        END ELSE
            Distance := '';
        TransDocNo := '';//Trnasport Document No.
        TransDocDt := '';//Transport Doc Date
        VehNo := SalesShipHeader."Vehicle No.";
        CASE SalesShipHeader."Vehicle Type" OF
            SalesShipHeader."Vehicle Type"::" ":
                VehType := '';
            SalesShipHeader."Vehicle Type"::ODC:
                VehType := 'ODC';
            SalesShipHeader."Vehicle Type"::Regular:
                VehType := 'Regular';
        END;


        ShipWriteEwbDtls(TransId, TransName, TransMode, Distance, TransDocNo, TransDocDt, VehNo, VehType, TransactionType);
    end;

    local procedure ShipWriteEwbDtls(TransId: Text[15]; TransName: Text[100]; TransMode: Text[20]; Distance: Text[4]; TransDocNo: Text[15]; TransDocDt: Text[10]; VehNo: Text[20]; VehType: Text[20]; TransactionType: Text)
    begin
        /* JsonTextWriter.WritePropertyName('transporter_id');
         JsonTextWriter.WriteValue(TransId);
         JsonTextWriter.WritePropertyName('transporter_name');
         JsonTextWriter.WriteValue(TransName);
         JsonTextWriter.WritePropertyName('transporter_document_number');
         JsonTextWriter.WriteValue(TransDocNo);
         JsonTextWriter.WritePropertyName('transporter_document_date');
         JsonTextWriter.WriteValue(TransDocDt);
         JsonTextWriter.WritePropertyName('transportation_mode');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WritePropertyName('transportation_distance');
         JsonTextWriter.WriteValue(Distance);
         JsonTextWriter.WritePropertyName('vehicle_number');
         JsonTextWriter.WriteValue(VehNo);
         JsonTextWriter.WritePropertyName('vehicle_type');
         JsonTextWriter.WriteValue(VehType);
         JsonTextWriter.WritePropertyName('generate_status');
         JsonTextWriter.WriteValue('1');
         JsonTextWriter.WritePropertyName('data_source');
         JsonTextWriter.WriteValue('erp');
         JsonTextWriter.WritePropertyName('user_ref');
         JsonTextWriter.WriteValue(SalesShipHeader."No.");
         JsonTextWriter.WritePropertyName('location_code');
         JsonTextWriter.WriteValue(SalesShipHeader."Location Code");
         JsonTextWriter.WritePropertyName('eway_bill_status');
         JsonTextWriter.WriteValue('ABC');
         JsonTextWriter.WritePropertyName('auto_print');
         JsonTextWriter.WriteValue('Y');
         //JsonTextWriter.WritePropertyName('EWB_print_type');
         //JsonTextWriter.WriteValue('d');
         JsonTextWriter.WritePropertyName('email');
         JsonTextWriter.WriteValue(CompanyInfo."E-Mail");*/
        JOsupplyTypeG.Add('transporterId', TransId);
        JOsupplyTypeG.Add('transporterName', TransName);
        JOsupplyTypeG.Add('transDocNo', TransDocNo);
        JOsupplyTypeG.Add('transMode', TransMode);
        JOsupplyTypeG.Add('transDistance', Distance);
        JOsupplyTypeG.Add('transDocDate', TransDocDt);
        JOsupplyTypeG.Add('vehicleNo', VehNo);
        JOsupplyTypeG.Add('vehicleType', VehType);
        JOsupplyTypeG.Add('generate_status', '1');
        JOsupplyTypeG.Add('data_source', 'erp');
        JOsupplyTypeG.Add('user_ref', SalesInvoiceHeader."No.");
        JOsupplyTypeG.Add('location_code', SalesInvoiceHeader."Location Code");
        JOsupplyTypeG.Add('eway_bill_status', 'ABC');
        JOsupplyTypeG.Add('auto_print', 'Y');
        JOsupplyTypeG.Add('EWB_print_type', 'd');
        JOsupplyTypeG.Add('email', CompanyInfo."E-Mail");

    end;

    local procedure ShipReadItemList()
    var
        SalesShipLine: Record "Sales Shipment Line";
        SalesLinesErr: Label 'E-Invoice allowes only 1000 lines per Invoice. Curent transaction is having %1 lines.', Comment = '%1 = Sales Lines count';
        HSNInt: Integer;
        Uom: Record "Unit of Measure";
        TaxableValue: Decimal;
    begin
        SalesShipLine.SETRANGE("Document No.", SalesShipHeader."No.");
        SalesShipLine.SETFILTER("No.", '<>%1', '');
        SalesShipLine.SETRANGE(Type, SalesShipLine.Type::Item);
        SalesShipLine.SETFILTER(Quantity, '>%1', 0);
        SalesShipLine.SETRANGE(Exempted, FALSE);
        IF SalesShipLine.FINDSET THEN BEGIN
            IF SalesShipLine.COUNT > 1000 THEN
                ERROR(SalesLinesErr, SalesShipLine.COUNT);
            //  JsonTextWriter.WritePropertyName('itemList');
            //  JsonTextWriter.WriteStartArray;
            REPEAT
                EVALUATE(HSNInt, SalesShipLine."HSN/SAC Code");
                /*   JsonTextWriter.WriteStartObject;
                   JsonTextWriter.WritePropertyName('product_name');
                   JsonTextWriter.WriteValue(SalesShipLine."No.");
                   JsonTextWriter.WritePropertyName('product_description');
                   JsonTextWriter.WriteValue(SalesShipLine.Description);
                   JsonTextWriter.WritePropertyName('hsn_code');
                   JsonTextWriter.WriteValue(HSNInt);
                   Uom.GET(SalesShipLine."Unit of Measure Code");
                   JsonTextWriter.WritePropertyName('unit_of_product');
                   JsonTextWriter.WriteValue(Uom."International Standard Code");

                   ShipGetGSTCompRate(SalesShipHeader."No.", SalesShipLine."Line No.");
                   TaxableValue := (SalesShipLine.Quantity * SalesShipLine."Unit Price") -
                                    ((SalesShipLine.Quantity * SalesShipLine."Unit Price") * SalesShipLine."Line Discount %" / 100);
                   IF SalesShipHeader."Currency Code" <> '' THEN
                       TaxableValue := (1 / SalesShipHeader."Currency Factor") * TaxableValue;
                   JsonTextWriter.WritePropertyName('taxableAmount');
                   JsonTextWriter.WriteValue(TaxableValue);
                   JsonTextWriter.WriteEndObject;*/
                Uom.GET(SalesShipLine."Unit of Measure Code");
                JOItemsG.Add('product_name', SalesShipLine."No.");
                JOItemsG.Add('product_description', SalesShipLine.Description);
                JOItemsG.Add('hsn_code', HSNInt);
                JOItemsG.Add('unit_of_product', Uom."International Standard Code");
                //JOItemsG.Add('quantity', SalesShipLine.Quantity);

                InvGetGSTCompRate(SalesShipHeader."No.", SalesShipLine."Line No.", JOItemsG);
                TaxableValue := (SalesShipLine.Quantity * SalesShipLine."Unit Price") -
                                    ((SalesShipLine.Quantity * SalesShipLine."Unit Price") * SalesShipLine."Line Discount %" / 100);
                IF SalesShipHeader."Currency Code" <> '' THEN
                    TaxableValue := (1 / SalesShipHeader."Currency Factor") * TaxableValue;

                JOItemsG.Add('taxableAmount', TaxableValue);
                JArrayItemsG.Add(JOItemsG);

            UNTIL SalesShipLine.NEXT = 0;
            JOsupplyTypeG.Add('itemList', JArrayItemsG);
            //JsonTextWriter.WriteEndArray;
        END;
    end;

    procedure ShipVechileJson()
    var
        LocationBuff: Record Location;
        StateBuff: Record State;
        Reason: Text;
        ReasonRemarks: Text;
        TransDocNo: Text;
        TransDocDate: Date;
        HeaderTitle: Label 'Enter Details';
        Title3: Label 'Vehicle No :';
        VechileNo: Text;
        TransMode: Text;
        TransportMethod: Record "Transport Method";
        Title1: Text;
        Title2: Text;
        VehType: Text;
    begin
        LocationBuff.GET(SalesShipHeader."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        IF IsPosting THEN BEGIN
            Reason := 'Others';//EWayBillingSetup."Vehicle Reason";
            ReasonRemarks := EWayBillingSetup."Vehicle Remarks";
            VechileNo := SalesShipHeader."Vehicle No.";
        END ELSE BEGIN
            Reason := 'Others';//EWayBillingSetup."Vehicle Reason";
            ReasonRemarks := EWayBillingSetup."Vehicle Remarks";
            //B2BUPG1.0>>
            // VehicleNo := Windows.InputBox(Title3, '', '', 10, 10);
            Clear(EWayUpdate);
            Commit();
            EWayUpdate.SetData(0);
            if EWayUpdate.RunModal() = Action::Yes then
                EWayUpdate.GetData(0, VechileNo);
            //B2BUPG1.0<<
            IF VechileNo = ' ' THEN
                EXIT;
            //SalesShipHeader."Old Vehicle No" := SalesShipHeader."Vehicle No.";
            SalesShipHeader."Vehicle No." := VechileNo;
            SalesShipHeader.MODIFY;
        END;
        CASE SalesShipHeader."Vehicle Type" OF
            SalesShipHeader."Vehicle Type"::" ":
                VehType := '';
            SalesShipHeader."Vehicle Type"::ODC:
                VehType := 'odc';
            SalesShipHeader."Vehicle Type"::Regular:
                VehType := 'Regular';
        END;
        IF TransportMethod.GET(SalesShipHeader."Transport Method") THEN BEGIN
            TransMode := TransportMethod.Description;
        END;

        TransDocNo := '';
        TransDocDate := 0D;
        ShipWriteVechileJson(GetEwayBillIngNo(TransType::"Sales Shpt", SalesShipHeader."No."), SalesShipHeader."Location GST Reg. No.", VechileNo, LocationBuff.City, StateBuff.Description, Reason, ReasonRemarks,
                        TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode, VehType);
    end;

    local procedure ShipWriteVechileJson(EwbNo: Text; GSTIN: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; ReasonCode: Text; ReasonRem: Text; TransDocNo: Text; TransDocDate: Text; TransMode: Text; VehType: Text)
    var
        EwbBigInt: BigInteger;
    begin
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('access_token');
         JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
         JsonTextWriter.WritePropertyName('userGstin');
         JsonTextWriter.WriteValue(GSTIN);
         JsonTextWriter.WritePropertyName('eway_bill_number');
         JsonTextWriter.WriteValue(EwbNo);
         JsonTextWriter.WritePropertyName('vehicle_number');
         JsonTextWriter.WriteValue(VehicleNo);
         JsonTextWriter.WritePropertyName('vehicle_type');
         JsonTextWriter.WriteValue(VehType);
         JsonTextWriter.WritePropertyName('place_of_consignor');
         JsonTextWriter.WriteValue(FromPlace);
         JsonTextWriter.WritePropertyName('state_of_consignor');
         JsonTextWriter.WriteValue(FromState);
         JsonTextWriter.WritePropertyName('reason_code_for_vehicle_updation');
         JsonTextWriter.WriteValue(ReasonCode);
         JsonTextWriter.WritePropertyName('reason_for_vehicle_updation');
         JsonTextWriter.WriteValue(ReasonRem);
         JsonTextWriter.WritePropertyName('transporter_document_number');
         JsonTextWriter.WriteValue(TransDocNo);
         JsonTextWriter.WritePropertyName('transporter_document_date');
         JsonTextWriter.WriteValue(TransDocDate);
         JsonTextWriter.WritePropertyName('mode_of_transport');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WritePropertyName('data_source');
         JsonTextWriter.WriteValue('erp');
         JsonTextWriter.WriteEndObject();*/
        JOVehicleG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOVehicleG.Add('userGstin', GSTIN);
        JOVehicleG.Add('eway_bill_number', EwbNo);
        JOVehicleG.Add('vehicle_number', VehicleNo);
        JOVehicleG.Add('vehicle_type', VehType);
        JOVehicleG.Add('place_of_consignor', FromPlace);
        JOVehicleG.Add('state_of_consignor', FromState);
        JOVehicleG.Add('reason_code_for_vehicle_updation', ReasonCode);
        JOVehicleG.Add('reason_for_vehicle_updation', ReasonRem);
        JOVehicleG.Add('transporter_document_number', TransDocNo);
        JOVehicleG.Add('transporter_document_date', '');
        JOVehicleG.add('mode_of_transport', TransMode);
        JOVehicleG.Add('data_source', 'erp');
    end;

    local procedure ShipCancelEwayJson()
    var
        HeaderTitle: Label 'Enter Cancel Details';
        Title1: Label 'Cancel Reason :';
        Title2: Label 'Cancel Remarks :';
        LocationBuff: Record Location;
        StateBuff: Record State;
        Reason: Text;
        ReasonRemarks: Text;
        TransDocNo: Text;
        TransDocDate: Date;
        Title3: Text;
        RemainingDist: Text;
    begin
        //B2BUPG1.0>>
        //IF NOT OpenWindow(HeaderTitle, Title1, Title2, Title3, Reason, ReasonRemarks, RemainingDist) THEN
        //    EXIT;
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(3);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetCancelTransportData(3, Reason, ReasonRemarks, RemainingDist);
        IF (Reason = '') or (ReasonRemarks = '') THEN
            EXIT;
        //B2BUPG1.0<<
        ShipWriteCancelJson(GetEwayBillIngNo(TransType::"Sales Shpt", SalesShipHeader."No."), SalesShipHeader."Location GST Reg. No.", Reason, ReasonRemarks);
    end;

    local procedure ShipWriteCancelJson(EWBNo: Text; GSTIN: Text; CancelReason: Text; CancelRemarks: Text)
    begin
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('access_token');
         JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
         JsonTextWriter.WritePropertyName('userGstin');
         JsonTextWriter.WriteValue(GSTIN);
         JsonTextWriter.WritePropertyName('eway_bill_number');
         JsonTextWriter.WriteValue(EWBNo);
         JsonTextWriter.WritePropertyName('reason_of_cancel');
         JsonTextWriter.WriteValue(CancelReason);
         JsonTextWriter.WritePropertyName('cancel_remark');
         JsonTextWriter.WriteValue(CancelRemarks);
         JsonTextWriter.WritePropertyName('data_source');
         JsonTextWriter.WriteValue('erp');
         JsonTextWriter.WriteEndObject();*/
        JOCancelG.add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOCancelG.Add('userGstin', GSTIN);
        JOCancelG.Add('eway_bill_number', EWBNo);
        JOCancelG.Add('reason_of_cancel', CancelReason);
        JOCancelG.Add('cancel_remark', CancelRemarks);
        JOCancelG.Add('data_source', 'erp');
    end;

    procedure ShipRejectEwayJson(RejDocumentNo: Code[20]; var RejEwayBillNo: BigInteger)
    var
        HeaderTitle: Label 'Enter Cancel Details';
        Title1: Label 'Cancel Reason :';
        Title2: Label 'Cancel Remarks :';
        RejectEwayBillNo: Text;
        EWayValidator: Codeunit "E-Way Validator";
        RejectErr: Label 'E-Way bill no must be provided to Reject.';
    begin
        EWayBillingSetup.GET;
        RequestType := RequestType::RejectEway;
        //B2BUPG1.0<<
        //RejectEwayBillNo := Windows.InputBox('Rejecting E-Way Bill No :', '', '', 10, 10);
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(1);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetData(1, RejectEwayBillNo);
        //B2BUPG1.0<<
        IF RejectEwayBillNo = '' THEN
            ERROR(RejectErr);
        EWayValidator.CheckValidations(RejectEwayBillNo, RequestType);//Check Validations

        /*  JsonTextWriter.WriteStartObject();
          JsonTextWriter.WritePropertyName('access_token');
          JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
          JsonTextWriter.WritePropertyName('userGstin');
          JsonTextWriter.WriteValue(CompanyInfo."GST Registration No.");
          JsonTextWriter.WritePropertyName('eway_bill_number');
          JsonTextWriter.WriteValue(RejectEwayBillNo);
          JsonTextWriter.WritePropertyName('data_source');
          JsonTextWriter.WriteValue('erp');
          JsonTextWriter.WriteEndObject();
          EVALUATE(RejEwayBillNo, RejectEwayBillNo);
          ExportAsJson(RejDocumentNo, PathSaved);*/
        JORejEWayNoG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JORejEWayNoG.Add('userGstin', CompanyInfo."GST Registration No.");
        EVALUATE(RejEwayBillNo, RejectEwayBillNo);
        JORejEWayNoG.Add('eway_bill_number', RejectEwayBillNo);
        JORejEWayNoG.Add('data_source', 'erp');
    end;

    local procedure ShipUpdateTransportJson()
    var
        TransportIDError: Label 'Transport Id must have value';
        TransportID: Text;
        TransporterName: Text;
        Blank: Text;
        HeaderTitle: Label 'Trasporter Details';
        Title1: Label 'Transporter ID';
        Title2: Label 'Transporter Name';
        Title3: Text;
    begin
        //B2BUPG1.0>>
        //IF NOT OpenWindow(HeaderTitle, Title1, Title2, Title3, TransportID, TransporterName, Blank) THEN
        //    EXIT;
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(3);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetCancelTransportData(3, TransportID, TransporterName, Blank);
        IF (TransportID = '') or (TransporterName = '') THEN
            EXIT;
        //B2BUPG1.0<<
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('access_token');
         JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
         JsonTextWriter.WritePropertyName('userGstin');
         JsonTextWriter.WriteValue(SalesShipHeader."Location GST Reg. No.");
         JsonTextWriter.WritePropertyName('eway_bill_number');
         JsonTextWriter.WriteValue(GetEwayBillIngNo(TransType::"Sales Shpt", SalesShipHeader."No."));
         JsonTextWriter.WritePropertyName('transporter_id');
         JsonTextWriter.WriteValue(TransportID);
         JsonTextWriter.WritePropertyName('transporter_name');
         JsonTextWriter.WriteValue(TransporterName);
         JsonTextWriter.WriteEndObject();*/
        JOUpdatetransportIDG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOUpdatetransportIDG.Add('userGstin', SalesInvoiceHeader."Location GST Reg. No.");
        JOUpdatetransportIDG.Add('eway_bill_number', GetEwayBillIngNo(TransType::"Sales Invoice", SalesInvoiceHeader."No."));
        JOUpdatetransportIDG.Add('transporter_id', TransportID);
        JOUpdatetransportIDG.Add('transporter_name', TransporterName);
    end;

    local procedure ShipExtendValidityJson()
    var
        LocationBuff: Record Location;
        StateBuff: Record State;
        HeaderTitle: Label 'Enter Details';
        Title1: Label 'Reason :';
        Title2: Label 'Remarks :';
        Title3: Label 'Rem. Dist :';
        Reason: Text;
        ReasonRemarks: Text;
        TransDocNo: Text;
        TransDocDate: Date;
        RemainingDist: Integer;
        RemainingDistText: Text;
        Pin: Integer;
        ExtendErr: Label 'Reason,Remarks and Remaining Distance has to be given to Extend E-Way validity.';
        TransportMethod: Record "Transport Method";
        TransMode: Text;
    begin
        LocationBuff.GET(SalesShipHeader."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        //B2BUPG1.0>>
        //IF NOT OpenWindow(HeaderTitle, Title1, Title2, Title3, Reason, ReasonRemarks, RemainingDistText) THEN
        //    ERROR(ExtendErr);
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(3);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetCancelTransportData(3, Reason, ReasonRemarks, RemainingDistText);
        IF (Reason = '') or (ReasonRemarks = '') THEN
            ERROR(ExtendErr);
        //B2BUPG1.0<<
        EVALUATE(RemainingDist, RemainingDistText);
        IF SalesShipHeader."GST Customer Type" = SalesShipHeader."GST Customer Type"::Export THEN
            EVALUATE(Pin, '999999')
        ELSE
            EVALUATE(Pin, COPYSTR(SalesShipHeader."Bill-to Post Code", 1, 6));

        IF TransportMethod.GET(SalesShipHeader."Transport Method") THEN BEGIN
            TransMode := TransportMethod.Description;
        END;
        TransDocNo := '';
        TransDocDate := 0D;
        ShipWriteExtendValidityJson(GetEwayBillIngNo(TransType::"Sales Shpt", SalesShipHeader."No."), SalesShipHeader."Location GST Reg. No.", SalesShipHeader."Vehicle No.", LocationBuff.City, StateBuff.Description, RemainingDist, TransDocNo,
                      FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode, Reason, ReasonRemarks, Pin, 'T', SalesShipHeader."Transaction Type",
                      '', '', '');
    end;

    local procedure ShipWriteExtendValidityJson(EwbNo: Text; GSTIN: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; RemainingDist: Integer; TransDocNo: Text; TransDocDate: Text; TransMode: Text; ReasonCode: Text; ReasonRem: Text; FromPincode: Integer; ConsignmentStatus: Text; TransitType: Text; AddressLine1: Text; AddressLine2: Text; AddressLine3: Text)
    begin
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('access_token');
         JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
         JsonTextWriter.WritePropertyName('userGstin');
         JsonTextWriter.WriteValue(GSTIN);
         JsonTextWriter.WritePropertyName('eway_bill_number');
         JsonTextWriter.WriteValue(EwbNo);
         JsonTextWriter.WritePropertyName('vehicle_number');
         JsonTextWriter.WriteValue(VehicleNo);
         JsonTextWriter.WritePropertyName('place_of_consignor');
         JsonTextWriter.WriteValue(FromPlace);
         JsonTextWriter.WritePropertyName('state_of_consignor');
         JsonTextWriter.WriteValue(FromState);
         JsonTextWriter.WritePropertyName('remaining_distance');
         JsonTextWriter.WriteValue(RemainingDist);
         JsonTextWriter.WritePropertyName('transporter_document_number');
         JsonTextWriter.WriteValue(TransDocNo);
         JsonTextWriter.WritePropertyName('transporter_document_date');
         JsonTextWriter.WriteValue(TransDocDate);
         JsonTextWriter.WritePropertyName('mode_of_transport');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WritePropertyName('extend_validity_reason');
         JsonTextWriter.WriteValue(ReasonCode);
         JsonTextWriter.WritePropertyName('extend_remarks');
         JsonTextWriter.WriteValue(ReasonRem);
         JsonTextWriter.WritePropertyName('from_pincode');
         JsonTextWriter.WriteValue(FromPincode);
         JsonTextWriter.WritePropertyName('consignment_status');
         JsonTextWriter.WriteValue(ConsignmentStatus);
         JsonTextWriter.WritePropertyName('transit_type');
         JsonTextWriter.WriteValue('');//TransMode
         JsonTextWriter.WritePropertyName('address_line1');
         JsonTextWriter.WriteValue(AddressLine1);
         JsonTextWriter.WritePropertyName('address_line2');
         JsonTextWriter.WriteValue(AddressLine2);
         JsonTextWriter.WritePropertyName('address_line3');
         JsonTextWriter.WriteValue(AddressLine3);
         JsonTextWriter.WriteEndObject();*/
        JOExtendValidityJsonG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOExtendValidityJsonG.Add('userGstin', GSTIN);
        JOExtendValidityJsonG.Add('eway_bill_number', EwbNo);
        JOExtendValidityJsonG.Add('vehicle_number', VehicleNo);
        JOExtendValidityJsonG.Add('place_of_consignor', FromPlace);
        JOExtendValidityJsonG.Add('state_of_consignor', FromState);
        JOExtendValidityJsonG.Add('remaining_distance', RemainingDist);
        JOExtendValidityJsonG.Add('transporter_document_number', TransDocNo);
        JOExtendValidityJsonG.Add('transporter_document_date', TransDocDate);
        JOExtendValidityJsonG.Add('mode_of_transport', '5');
        JOExtendValidityJsonG.Add('extend_validity_reason', ReasonCode);
        JOExtendValidityJsonG.Add('extend_remarks', ReasonRem);
        JOExtendValidityJsonG.add('from_pincode', FromPincode);
        JOExtendValidityJsonG.add('consignment_status', ConsignmentStatus);
        JOExtendValidityJsonG.add('transit_type', 'R');
        JOExtendValidityJsonG.Add('address_line1', AddressLine1);
        JOExtendValidityJsonG.Add('address_line2', AddressLine2);
        JOExtendValidityJsonG.Add('address_line3', AddressLine3);
    end;

    procedure ShipCalCulateShipmentGST(ShipmentHead: Record "Sales Shipment Header")
    var
        SalesShipLine: Record "Sales Shipment Line";
        StateBuff: Record State;
    begin
        ShipDeleteGSTEntry(); //
        SalesShipLine.RESET;
        SalesShipLine.SETRANGE("Document No.", ShipmentHead."No.");
        SalesShipLine.SETRANGE(Type, SalesShipLine.Type::Item);
        SalesShipLine.SETFILTER("No.", '<>%1', '');
        SalesShipLine.SETRANGE(Exempted, FALSE);
        IF SalesShipLine.FINDSET THEN BEGIN
            REPEAT
                DocType := DocType::Shipment;
                IF SalesShipLine."GST Place of Supply" = SalesShipLine."GST Place of Supply"::"Bill-to Address" THEN BEGIN
                    IF NOT (ShipmentHead."GST Customer Type" = ShipmentHead."GST Customer Type"::Export) THEN
                        StateBuff.GET(ShipmentHead."GST Bill-to State Code");
                END ELSE
                    IF SalesShipLine."GST Place of Supply" = SalesShipLine."GST Place of Supply"::"Ship-to Address" THEN BEGIN
                        IF NOT (ShipmentHead."GST Customer Type" = ShipmentHead."GST Customer Type"::Export) THEN
                            StateBuff.GET(ShipmentHead."GST Ship-to State Code");
                    END;

                //B2BUPG1.0>>
                // ShipCalculateGSTAmounts(ShipmentHead."No.", SalesShipLine."Line No.", SalesShipLine."GST Jurisdiction Type".AsInteger, StateBuff."State Code (GST Reg. No.)",
                //   SalesShipLine."GST Group Code", ShipmentHead."Posting Date", SalesShipLine.Quantity * SalesShipLine."Unit Price",
                //   ShipmentHead."Currency Code", ShipmentHead."Currency Factor", SalesShipLine."Unit Cost", SalesShipLine.Quantity,
                //   SalesShipLine."Unit of Measure Code", SalesShipLine."No.", SalesShipLine."Line Discount %");
                GetGSTAmountsSales(SalesShipLine);
            //B2BUPG1.0<<
            UNTIL SalesShipLine.NEXT = 0;
        END;
    end;

    //local procedure ShipCalculateGSTAmounts(DocumentNo: Code[20]; LineNo: Integer; GSTJurisdiction: Option; GSTStateCode: Code[10]; GSTGroupCode: Code[20]; EffectiveDate: Date; Amount: Decimal; CurrencyCode: Code[10]; CurrencyFactor: Decimal; UnitCost: Decimal; LineQty: Decimal; UOM: Code[10]; ItemNo: Code[20]; Discount: Decimal)
    local procedure ShipCalculateGSTAmounts(SaleShipmentHdr: Record "Sales Shipment Header"; SalesShipmentLine: Record "Sales Shipment Line")
    var
        GSTComponent: Record "Tax Component";
        GSTSetup: Record "GST Setup";
        //GSTCalculationBuffer: Record Table16421;
        TotalGSTAmount: Decimal;
        Test: Page "Sales Order";
        SalePost: Codeunit "GST Posting Management";
    begin
        //B2BUPG1.0>>
        /*GSTComponent.SETCURRENTKEY("Calculation Order");
        GSTComponent.SETRANGE("GST Jurisdiction Type", GSTJurisdiction);
        IF GSTComponent.FINDSET THEN
            REPEAT
                IF ShipGetGSTSetup(GSTSetup, GSTStateCode, GSTGroupCode, GSTComponent.Code, EffectiveDate) <> '' THEN BEGIN
                    ShipInitGSTCalculationBuffer(
                              GSTSetup, DocumentNo, LineNo, UnitCost,
                              EffectiveDate, CurrencyCode, CurrencyFactor, Amount, Discount)
                END;
            UNTIL GSTComponent.NEXT = 0;*/

        //B2BUPG1.0<<
    end;

    //B2BUPG1.0>>
    /*procedure ShipGetGSTSetup(var GSTSetup: Record "GST Setup"; GSTStateCode: Code[10]; GSTGroupCode: Code[20]; GSTComponentCode: Code[10]; EffectiveDate: Date): Code[20]
    begin

        WITH GSTSetup DO BEGIN
            SETRANGE( , GSTStateCode);
            SETRANGE("GST Group Code", GSTGroupCode);
            SETRANGE("GST Component Code", GSTComponentCode);
            IF EffectiveDate = 0D THEN
                SETFILTER("Effective Date", '<=%1', WORKDATE)
            ELSE
                SETFILTER("Effective Date", '<=%1', EffectiveDate);
            IF FINDLAST THEN
                EXIT("GST Component Code");
            SETRANGE("GST State Code");
            SETRANGE("GST State Code", '');
            IF FINDLAST THEN
                EXIT("GST Component Code");
        END;
    end;*/

    //local procedure ShipInitGSTCalculationBuffer(GSTSetup: Record "GST Setup"; DocumentNo: Code[20]; LineNo: Integer; UnitCost: Decimal; PostingDate: Date; CurrencyCode: Code[10]; CurrencyFactor: Decimal; SaleAmount: Decimal; DiscountPer: Decimal)
    local procedure ShipInitGSTCalculationBuffer(LineNo: Integer; GSTGrpCode: Code[20]; GSTCompCode: Code[30]; SaleAmount: Decimal; Percentage: Decimal)
    //B2BUPG1.0<<
    var
        //Percentage: Decimal;
        Threshold: Decimal;
        GSTEntry: Record "GST Entry";
        TransactionType: Option Purchase,Sales,Transfer,Service,"Service Transfer",Production;
    begin
        //B2BUPG1.0>>
        GSTEntry.INIT;
        GSTEntry."Transaction Type" := GSTEntry."Transaction Type"::Sales;
        GSTEntry."Document Type" := DocType;
        GSTEntry."Document No." := DocumentNo;
        GSTEntry."GST Group Code" := GSTGrpCode;
        GSTEntry."GST Component Code" := GSTCompCode;
        //"Effective Date" := GSTSetup."Effective Date";
        GSTEntry."Document Line No." := LineNo;
        /*
        CASE GSTSetup."Component Calc. Type" OF
            GSTSetup."Component Calc. Type"::Threshold:
                IF NOT ("Transaction Type" IN ["Transaction Type"::"Service Transfer"]) THEN
                    IF UnitCost <= Threshold THEN
                        Percentage := GSTSetup."Before Threshold %"
                    ELSE
                        Percentage := GSTSetup."GST Component %";
            GSTSetup."Component Calc. Type"::General, GSTSetup."Component Calc. Type"::"Cess %",
            GSTSetup."Component Calc. Type"::"Cess % + Amount / Unit Factor",
            GSTSetup."Component Calc. Type"::"Cess % Or Amount / Unit Factor Whichever Higher":
                Percentage := GSTSetup."GST Component %"
        END;
        */
        GSTEntry."GST Component %" := Percentage;
        //Amount := (SaleAmount - (SaleAmount * DiscountPer / 100)) * "GST Component %" / 100;
        GSTEntry.Amount := SaleAmount;
        GSTEntry.INSERT(TRUE);
        //B2BUPG1.0<<
    end;

    //B2BUPG1.0>>
    local procedure GetComponentName(SalesShipLine: Record "Sales Shipment Line";
        GSTSetup: Record "GST Setup"): Code[30]
    var
        ComponentName: Code[30];
    begin
        if GSTSetup."GST Tax Type" = GSTLbl then
            if SalesShipLine."GST Jurisdiction Type" = SalesShipLine."GST Jurisdiction Type"::Interstate then
                ComponentName := IGSTLbl
            else
                ComponentName := CGSTLbl
        else
            if GSTSetup."Cess Tax Type" = GSTCESSLbl then
                ComponentName := CESSLbl;
        exit(ComponentName)
    end;

    procedure GetGSTRoundingPrecision(ComponentName: Code[30]): Decimal
    var
        TaxComponent: Record "Tax Component";
        GSTSetup: Record "GST Setup";
        GSTRoundingPrecision: Decimal;
    begin
        if not GSTSetup.Get() then
            exit;
        GSTSetup.TestField("GST Tax Type");

        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxComponent.SetRange(Name, ComponentName);
        TaxComponent.FindFirst();
        if TaxComponent."Rounding Precision" <> 0 then
            GSTRoundingPrecision := TaxComponent."Rounding Precision"
        else
            GSTRoundingPrecision := 1;
        exit(GSTRoundingPrecision);
    end;
    //B2BUPG1.0<<

    local procedure ShipDeleteGSTEntry()
    var
        GSTEntry: Record "GST Entry";
    begin
        GSTEntry.RESET;
        GSTEntry.SETRANGE("Document No.", SalesShipHeader."No.");
        IF GSTEntry.FINDSET THEN
            GSTEntry.DELETEALL;
    end;

    local procedure ShipConvertAmountLCYToFCYRoundSmall(CurrencyCode: Code[10]; Amount: Decimal; CurrencyFactor: Decimal; PostingDate: Date): Decimal
    var
        CurrExchRate: Record "Currency Exchange Rate";
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.GET;
        IF CurrencyCode = '' THEN
            EXIT(Amount);
        EXIT(
          ROUND(
            CurrExchRate.ExchangeAmtLCYToFCY(
              PostingDate, CurrencyCode, Amount, CurrencyFactor),
            GLSetup."Unit-Amount Rounding Precision"));
    end;

    local procedure GetEwayBillIngNo(TransType: Option " ","Sales Invoice","Sales Shpt","Purch. Order","Whse. Shipment","Whse. Rect","Transfer Order","Sales Crd Memo","Purch. Crd Memo","Sales R.O","Purchase R.O",Subcontracting; DocNo: Code[20]): Text
    var
        EWayBillingEntry: Record "E-Way Billing Entry";
    begin
        EWayBillingEntry.GET(TransType, DocNo);
        EXIT(FORMAT(EWayBillingEntry."E-Way Bill No."));
    end;

    local procedure "------------------------------------PURCH START------------------------"()
    begin
    end;

    procedure SetPurchHeader(var PurchHeaderTemp: Record "Purchase Header"; RequestTypePar: Option Eway,Vehicle,EWayCancel,RejectEway,ExtendValidity,UpdateTrasporter,AccessToken; IsPostingPar: Boolean)
    begin
        PurchHeader := PurchHeaderTemp;
        RequestType := RequestTypePar;
        IsPosting := IsPostingPar;
    end;

    procedure SetWhseHeader(var WhseRectHead: Record "Warehouse Receipt Header"; RequestTypePar: Option Eway,Vehicle,EWayCancel,RejectEway,ExtendValidity,UpdateTrasporter,AccessToken; IsPostingPar: Boolean)
    var
        WhseRectLine: Record "Warehouse Receipt Line";
    begin
        WareHouseRectHead := WhseRectHead;
        RequestType := RequestTypePar;
        IsPosting := IsPostingPar;
        WhseRectLine.RESET;
        WhseRectLine.SETRANGE("No.", WareHouseRectHead."No.");
        IF WhseRectLine.FINDFIRST THEN BEGIN
            PurchHeader.GET(PurchHeader."Document Type"::Order, WhseRectLine."Source No.");
        END;
    end;

    procedure PurchEWayJson()
    var
        LocationBuff: Record Location;
        StateBuff: Record State;
        Gstin: Text;
        Pin: Text;
        Pos: Text;
        Path: Text;
        SubSupplyType: Text;
        SubType: Text;
        TransactionType: Record "Transaction Type";
    begin
        IF PurchHeader."GST Vendor Type" = PurchHeader."GST Vendor Type"::Import THEN BEGIN
            Gstin := 'URP';
            Pin := '999999';
            SubSupplyType := 'Import';
            SubType := 'Inward';
        END ELSE BEGIN
            Gstin := PurchHeader."Vendor GST Reg. No.";
            Pin := COPYSTR(PurchHeader."Pay-to Post Code", 1, 6);
            SubSupplyType := 'Supply';
            SubType := 'Inward';
        END;
        //EWB1.2 >>
        IF PurchHeader."GST Vendor Type" = PurchHeader."GST Vendor Type"::Unregistered THEN
            Gstin := 'URP';
        //EWB1.2 <<
        IF WareHouseRectHead."No." = '' THEN
            PurchEWayHeadDetails(PurchHeader."Location GST Reg. No.", SubType, SubSupplyType, 'Tax Invoice', PurchHeader."Vendor Shipment No.", FORMAT(PurchHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>'))
        ELSE
            PurchEWayHeadDetails(PurchHeader."Location GST Reg. No.", SubType, SubSupplyType, 'Tax Invoice', WareHouseRectHead."No.", FORMAT(WareHouseRectHead."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>')); //Header

        //From Details >>

        Pos := PurchGetEwayPos(PurchHeader."No.");
        PurchEwayFromDetails(Gstin, PurchHeader."Pay-to Name", PurchHeader."Pay-to Address", PurchHeader."Pay-to Address 2", PurchHeader."Pay-to City", Pin, Pos, Pos);
        //From Details <<

        //To Details >>
        LocationBuff.GET(PurchHeader."Location Code");
        StateBuff.GET(LocationBuff."State Code");

        //LocationBuff."GST Registration No."
        PurchEwayToDetails(PurchHeader."Location GST Reg. No.", CompanyInfo.Name, LocationBuff.Address, LocationBuff."Address 2", LocationBuff.City
                        , LocationBuff."Post Code", StateBuff.Description, StateBuff.Description);
        //To Details <<
        IF WareHouseRectHead."No." = '' THEN
            PurchGetGSTCompRate(PurchHeader."No.", 0, JOItemsG)
        ELSE
            PurchGetGSTCompRate(WareHouseRectHead."No.", 0, JOItemsG);

        PurchReadEwbDtls();//Update Transport Details
        IF WareHouseRectHead."No." = '' THEN
            PurchReadItemList()
        ELSE
            WhseReadItemList();
        //JsonTextWriter.WriteEndObject;
        //ExportAsJson(PurchHeader."No.",Path);
    end;

    local procedure PurchEWayHeadDetails(Gstin: Text; SupplyType: Text; SupplySubType: Text; Doctype: Text; DocNo: Text; DocDate: Text)
    begin
        /* JsonTextWriter.WriteStartObject;
         JsonTextWriter.WritePropertyName('access_token');
         JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
         JsonTextWriter.WritePropertyName('userGstin');
         JsonTextWriter.WriteValue(Gstin);
         JsonTextWriter.WritePropertyName('supply_type');
         JsonTextWriter.WriteValue(SupplyType);
         JsonTextWriter.WritePropertyName('sub_supply_type');
         JsonTextWriter.WriteValue(SupplySubType);
         JsonTextWriter.WritePropertyName('sub_supply_description');
         JsonTextWriter.WriteValue('');
         JsonTextWriter.WritePropertyName('document_type');
         JsonTextWriter.WriteValue(Doctype);
         JsonTextWriter.WritePropertyName('document_number');
         JsonTextWriter.WriteValue(DocNo);
         JsonTextWriter.WritePropertyName('document_date');
         JsonTextWriter.WriteValue(DocDate);*/
        JOsupplyTypeG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOsupplyTypeG.Add('supply_type', SupplyType);
        JOsupplyTypeG.Add('sub_supply_type', SupplySubType);

        JOsupplyTypeG.Add('sub_supply_description', '');

        JOsupplyTypeG.Add('document_type', Doctype);
        JOsupplyTypeG.Add('document_number', DocNo);
        JOsupplyTypeG.Add('document_date', DocDate);
    end;

    procedure PurchEwayFromDetails(FromGstin: Text; FromTrdName: Text; FromAdd1: Text; FromAdd2: Text; FromPlace: Text; FromPinCode: Text; ActFromStateCode: Text; FromStateCode: Text): Boolean
    var
        FromPinCodeInt: Integer;
        ActFromStateCodeInt: Integer;
        FromStateCodeInt: Integer;
    begin
        IF FromPinCode <> '' THEN
            EVALUATE(FromPinCodeInt, FromPinCode);
        /* JsonTextWriter.WritePropertyName('gstin_of_consignor');
         JsonTextWriter.WriteValue(FromGstin);
         JsonTextWriter.WritePropertyName('legal_name_of_consignor');
         JsonTextWriter.WriteValue(FromTrdName);
         JsonTextWriter.WritePropertyName('address1_of_consignor');
         JsonTextWriter.WriteValue(FromAdd1);
         JsonTextWriter.WritePropertyName('address2_of_consignor');
         JsonTextWriter.WriteValue(FromAdd2);
         JsonTextWriter.WritePropertyName('place_of_consignor');
         JsonTextWriter.WriteValue(FromPlace);
         JsonTextWriter.WritePropertyName('pincode_of_consignor');
         JsonTextWriter.WriteValue(FromPinCodeInt);
         JsonTextWriter.WritePropertyName('state_of_consignor');
         JsonTextWriter.WriteValue(FromStateCode);
         JsonTextWriter.WritePropertyName('actual_from_state_name');
         JsonTextWriter.WriteValue(ActFromStateCode);*/
        JOsupplyTypeG.Add('gstin_of_consignor', FromGstin);
        JOsupplyTypeG.Add('legal_name_of_consignor', FromTrdName);
        JOsupplyTypeG.Add('address1_of_consignor', FromAdd1);
        JOsupplyTypeG.Add('address2_of_consignor', FromAdd2);
        JOsupplyTypeG.Add('place_of_consignor', FromPlace);
        JOsupplyTypeG.Add('pincode_of_consignor', FromPinCodeInt);
        JOsupplyTypeG.Add('state_of_consignor', FromStateCodeInt);
        JOsupplyTypeG.Add('actual_from_state_name', ActFromStateCode);

    end;

    procedure PurchEwayToDetails(ToGstin: Text; ToTrdName: Text; ToAdd1: Text; ToAdd2: Text; ToPlace: Text; ToPinCode: Text; ActFromStateCode: Text; ToStateCode: Text): Boolean
    var
        ToPinCodeInt: Integer;
        ActToStateCodeInt: Integer;
        ToStateCodeInt: Integer;
    begin
        IF ToPinCode <> '' THEN
            EVALUATE(ToPinCodeInt, ToPinCode);
        /* JsonTextWriter.WritePropertyName('gstin_of_consignee');
         JsonTextWriter.WriteValue(ToGstin);
         JsonTextWriter.WritePropertyName('legal_name_of_consignee');
         JsonTextWriter.WriteValue(ToTrdName);
         JsonTextWriter.WritePropertyName('address1_of_consignee');
         JsonTextWriter.WriteValue(ToAdd1);
         JsonTextWriter.WritePropertyName('address2_of_consignee');
         JsonTextWriter.WriteValue(ToAdd2);
         JsonTextWriter.WritePropertyName('place_of_consignee');
         JsonTextWriter.WriteValue(ToPlace);
         JsonTextWriter.WritePropertyName('pincode_of_consignee');
         JsonTextWriter.WriteValue(ToPinCodeInt);
         JsonTextWriter.WritePropertyName('state_of_supply');
         JsonTextWriter.WriteValue(ToStateCode);
         JsonTextWriter.WritePropertyName('actual_to_state_name');
         JsonTextWriter.WriteValue(ActFromStateCode);
         JsonTextWriter.WritePropertyName('transaction_type');
         JsonTextWriter.WriteValue(FORMAT(PurchHeader."Transaction Type"));
         JsonTextWriter.WritePropertyName('other_value');
         JsonTextWriter.WriteValue('');*/
        JOsupplyTypeG.Add('gstin_of_consignee', ToGstin);
        JOsupplyTypeG.Add('legal_name_of_consignee', ToTrdName);
        JOsupplyTypeG.Add('address1_of_consignee', ToAdd1);
        JOsupplyTypeG.Add('address2_of_consignee', ToAdd2);
        JOsupplyTypeG.Add('place_of_consignee', ToPlace);
        JOsupplyTypeG.Add('pincode_of_consignee', ToPinCodeInt);
        JOsupplyTypeG.Add('state_of_supply', ToStateCode);
        JOsupplyTypeG.Add('actual_to_state_name', ActFromStateCode);
        JOsupplyTypeG.Add('transaction_type', FORMAT(PurchHeader."Transaction Type"));
        JOsupplyTypeG.Add('other_value', '');

    end;

    local procedure PurchGetEwayPos(No: Code[20]): Text
    var
        PurchLine: Record "Purchase Line";
        StateBuff: Record State;
    begin
        PurchLine.SETRANGE("Document No.", No);
        PurchLine.SETFILTER("No.", '<>%1', '');//BugFix
        PurchLine.SETRANGE(Exempted, FALSE);
        IF PurchLine.FINDFIRST THEN
            IF PurchLine."Order Address Code" <> '' THEN BEGIN
                StateBuff.GET(PurchLine."Order Address Code");
                EXIT(StateBuff.Description);
            END ELSE BEGIN
                StateBuff.GET(PurchHeader.State);
                EXIT(StateBuff.Description);
            END;
    end;

    local procedure PurchUpdateEwayCalculations(CgstValue: Decimal; SgstValue: Decimal; IgstValue: Decimal; CessValue: Decimal)
    var
        PurchLine: Record "Purchase Line";
        TotalInvValue: Decimal;
        TotalValue: Decimal;
    begin
        PurchLine.RESET;
        PurchLine.SETRANGE("Document No.", PurchHeader."No.");
        PurchLine.SETRANGE(Type, PurchLine.Type::Item);
        PurchLine.SETRANGE(Exempted, FALSE);
        IF PurchLine.FINDSET THEN BEGIN
            REPEAT
                TotalInvValue += (PurchLine.Quantity * PurchLine."Direct Unit Cost") -
                                 ((PurchLine.Quantity * PurchLine."Direct Unit Cost") * PurchLine."Line Discount %" / 100) - PurchLine."Inv. Discount Amount";
            UNTIL PurchLine.NEXT = 0;
        END;
        IF PurchHeader."Currency Code" <> '' THEN
            TotalInvValue := (1 / PurchHeader."Currency Factor") * TotalInvValue;
        TotalValue := CgstValue + SgstValue + IgstValue + CessValue;
        /*  JsonTextWriter.WritePropertyName('total_invoice_value');
          JsonTextWriter.WriteValue(TotalInvValue + TotalValue);
          JsonTextWriter.WritePropertyName('taxable_amount');
          JsonTextWriter.WriteValue(ABS(TotalInvValue));
          JsonTextWriter.WritePropertyName('cgst_amount');
          JsonTextWriter.WriteValue(CgstValue);
          JsonTextWriter.WritePropertyName('sgst_amount');
          JsonTextWriter.WriteValue(SgstValue);
          JsonTextWriter.WritePropertyName('igst_amount');
          JsonTextWriter.WriteValue(IgstValue);
          JsonTextWriter.WritePropertyName('cess_amount');
          JsonTextWriter.WriteValue(CessValue);
          JsonTextWriter.WritePropertyName('cess_nonadvol_value');
          JsonTextWriter.WriteValue('');*/
        JOsupplyTypeG.Add('total_invoice_value', TotalInvValue + TotalValue);
        JOsupplyTypeG.Add('taxable_amount', ABS(TotalInvValue));
        JOsupplyTypeG.Add('cgst_amount', CgstValue);
        JOsupplyTypeG.Add('sgst_amount', SgstValue);
        JOsupplyTypeG.Add('igst_amount', IgstValue);
        JOsupplyTypeG.Add('cess_amount', CessValue);
        JOsupplyTypeG.Add('cess_nonadvol_value', '');
    end;

    local procedure PurchGetGSTCompRate(DocNo: Code[20]; LineNo: Integer; Var JSONItemL: JsonObject)
    var
        DetailedGSTLedgerEntry: Record "GST Entry";
        GSTComponent: Record "Tax Component";
        CurrExchRate: Record "Currency Exchange Rate";
        CurrencyCode: Code[10];
        CurrencyFactor: Decimal;
        CgstAmt: Decimal;
        SgstAmt: Decimal;
        IgstAmt: Decimal;
        CesRt: Decimal;
        CessAmt: Decimal;
        CesNonAdvlAmt: Decimal;
        StateCesRt: Decimal;
        StateCesAmt: Decimal;
        StateCesNonAdvlAmt: Decimal;
        CgstRt: Decimal;
        SgstRt: Decimal;
        IgstRt: Decimal;
        CesAdvlAmt: Decimal;
        WhseRectLine: Record "Warehouse Receipt Line";
        PurchaseLine: Record "Purchase Line";
    begin
        IF WareHouseRectHead."No." = '' THEN
            PurchCalCulateShipmentGST(PurchHeader)
        ELSE
            WhseCalCulateShipmentGST(WareHouseRectHead);//WH
        DetailedGSTLedgerEntry.RESET;
        DetailedGSTLedgerEntry.SETRANGE("Document No.", DocNo);
        IF LineNo <> 0 THEN
            DetailedGSTLedgerEntry.SETRANGE("Document Line No.", LineNo);


        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'CGST');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS(Amount);
            CgstAmt := ABS(DetailedGSTLedgerEntry.Amount);
            CgstRt := ABS(DetailedGSTLedgerEntry."GST Component %");
        END ELSE BEGIN
            CgstAmt := 0;
            CgstRt := 0;
        END;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'SGST');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS(Amount);
            SgstAmt := ABS(DetailedGSTLedgerEntry.Amount);
            SgstRt := ABS(DetailedGSTLedgerEntry."GST Component %");
        END ELSE BEGIN
            SgstAmt := 0;
            SgstRt := 0
        END;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'IGST');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS(Amount);
            IgstAmt := ABS(DetailedGSTLedgerEntry.Amount);
            IgstRt := ABS(DetailedGSTLedgerEntry."GST Component %");
        END ELSE BEGIN
            IgstAmt := 0;
            IgstRt := 0;
        END;
        CesRt := 0;
        CessAmt := 0;
        CesNonAdvlAmt := 0;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'CESS');
        IF DetailedGSTLedgerEntry.FINDSET THEN
            IF DetailedGSTLedgerEntry."GST Component %" > 0 THEN BEGIN
                DetailedGSTLedgerEntry.CALCSUMS(Amount);
                CesRt := DetailedGSTLedgerEntry."GST Component %";
                CessAmt := ABS(DetailedGSTLedgerEntry.Amount);
            END ELSE
                CesNonAdvlAmt := ABS(DetailedGSTLedgerEntry.Amount);

        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'INTERCESS');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS(Amount);
            CesRt := DetailedGSTLedgerEntry."GST Component %";
            CessAmt := DetailedGSTLedgerEntry.Amount;
        END;

        StateCesRt := 0;
        StateCesAmt := 0;
        StateCesNonAdvlAmt := 0;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code");
        IF DetailedGSTLedgerEntry.FINDSET THEN
            REPEAT
                IF NOT (DetailedGSTLedgerEntry."GST Component Code" IN ['CGST', 'SGST', 'IGST', 'CESS', 'INTERCESS']) THEN
                    IF GSTComponent.GET(DetailedGSTLedgerEntry."GST Component Code") THEN
                        IF DetailedGSTLedgerEntry."GST Component %" > 0 THEN BEGIN
                            StateCesRt := DetailedGSTLedgerEntry."GST Component %";
                            StateCesAmt := ABS(DetailedGSTLedgerEntry.Amount);
                        END ELSE
                            StateCesNonAdvlAmt := ABS(DetailedGSTLedgerEntry.Amount);
            UNTIL DetailedGSTLedgerEntry.NEXT = 0;

        IF PurchHeader."Currency Code" <> '' THEN BEGIN
            CurrencyCode := PurchHeader."Currency Code";
            CurrencyFactor := PurchHeader."Currency Factor";

            IF IgstAmt <> 0 THEN
                IgstAmt := ROUND((1 / PurchHeader."Currency Factor") * IgstAmt, 0.01, '=');
            IF CgstAmt <> 0 THEN
                CgstAmt := ROUND((1 / PurchHeader."Currency Factor") * CgstAmt, 0.01, '=');
            IF SgstAmt <> 0 THEN
                SgstAmt := ROUND((1 / PurchHeader."Currency Factor") * SgstAmt, 0.01, '=');
            IF CessAmt <> 0 THEN
                CessAmt := ROUND((1 / PurchHeader."Currency Factor") * CessAmt, 0.01, '=');
            IF CesNonAdvlAmt <> 0 THEN
                CesNonAdvlAmt := ROUND((1 / PurchHeader."Currency Factor") * CesNonAdvlAmt, 0.01, '=');
            IF StateCesAmt <> 0 THEN
                StateCesAmt := ROUND((1 / PurchHeader."Currency Factor") * StateCesAmt, 0.01, '=');
            IF StateCesNonAdvlAmt <> 0 THEN
                StateCesNonAdvlAmt := ROUND((1 / PurchHeader."Currency Factor") * StateCesNonAdvlAmt, 0.01, '=');
        END;

        IF LineNo = 0 THEN
            PurchUpdateEwayCalculations(CgstAmt, SgstAmt, IgstAmt, CessAmt)//Header Json
        ELSE BEGIN
            /* JsonTextWriter.WritePropertyName('cgst_rate');
             JsonTextWriter.WriteValue(CgstRt);
             JsonTextWriter.WritePropertyName('sgst_rate');
             JsonTextWriter.WriteValue(SgstRt);
             JsonTextWriter.WritePropertyName('igst_rate');
             JsonTextWriter.WriteValue(IgstRt);
             JsonTextWriter.WritePropertyName('cess_rate');
             JsonTextWriter.WriteValue(CesRt);*/
            JSONItemL.Add('cgst_rate', CgstRt);
            JSONItemL.Add('sgst_rate', SgstRt);
            JSONItemL.Add('igst_rate', IgstRt);
            JSONItemL.Add('cess_rate', CesRt);
            IF WareHouseRectHead."No." = '' THEN BEGIN
                PurchaseLine.GET(PurchHeader."Document Type", DocNo, LineNo);
                //  JsonTextWriter.WritePropertyName('quantity');
                //  JsonTextWriter.WriteValue(PurchaseLine."Qty. to Receive");
                JSONItemL.Add('quantity', PurchaseLine."Qty. to Receive");
            END ELSE BEGIN
                WhseRectLine.GET(DocNo, LineNo);
                //  JsonTextWriter.WritePropertyName('quantity');
                // JsonTextWriter.WriteValue(WhseRectLine."Qty. to Receive");
                JSONItemL.Add('quantity', PurchaseLine."Qty. to Receive");
            END;

            // JsonTextWriter.WritePropertyName('cessNonAdvolValue');
            // JsonTextWriter.WriteValue(CesNonAdvlAmt);
            JSONItemL.Add('cessNonAdvolValue', CesNonAdvlAmt);
        END;
    end;

    local procedure PurchReadEwbDtls()
    var
        TransId: Text[15];
        TransName: Text[100];
        TransMode: Text[20];
        Distance: Text[4];
        TransDocNo: Text[15];
        TransDocDt: Text[10];
        VehNo: Text[20];
        VehType: Text[20];
        TransportMethod: Record "Transport Method";
        DistanceTxt: Text;
        TransactionType: Text;
    begin
        TransId := '';//Transit/GSTIN
        TransactionType := PurchHeader."Transaction Type";
        IF TransportMethod.GET(PurchHeader."Transport Method") THEN BEGIN
            TransName := TransportMethod.Description;
            CASE TransportMethod."Transportation Mode" OF
                TransportMethod."Transportation Mode"::Road:
                    TransMode := 'road';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := 'rail';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := 'air';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := 'ship';
            END;
        END;
        IF PurchHeader."Distance (Km)" <> 0 THEN BEGIN
            DistanceTxt := DELCHR(FORMAT(ROUND(PurchHeader."Distance (Km)", 1, '=')), '=', ',');

            IF STRLEN(DistanceTxt) > 4 THEN
                Distance := COPYSTR(DistanceTxt, 1, 4)
            ELSE
                Distance := DistanceTxt;
        END ELSE
            Distance := '';
        TransDocNo := '';//Trnasport Document No.
        TransDocDt := '';//Transport Doc Date
        VehNo := PurchHeader."Vehicle No.";
        CASE PurchHeader."Vehicle Type" OF
            PurchHeader."Vehicle Type"::" ":
                VehType := '';
            PurchHeader."Vehicle Type"::ODC:
                VehType := 'Odc';
            PurchHeader."Vehicle Type"::Regular:
                VehType := 'Regular';
        END;


        PurchWriteEwbDtls(TransId, TransName, TransMode, Distance, TransDocNo, TransDocDt, VehNo, VehType, TransactionType);
    end;

    local procedure PurchWriteEwbDtls(TransId: Text[15]; TransName: Text[100]; TransMode: Text[20]; Distance: Text[4]; TransDocNo: Text[15]; TransDocDt: Text[10]; VehNo: Text[20]; VehType: Text[20]; TransactionType: Text)
    begin
        /*  JsonTextWriter.WritePropertyName('transporter_id');
          JsonTextWriter.WriteValue(TransId);
          JsonTextWriter.WritePropertyName('transporter_name');
          JsonTextWriter.WriteValue(TransName);
          JsonTextWriter.WritePropertyName('transporter_document_number');
          JsonTextWriter.WriteValue(TransDocNo);
          JsonTextWriter.WritePropertyName('transporter_document_date');
          JsonTextWriter.WriteValue(TransDocDt);
          JsonTextWriter.WritePropertyName('transportation_mode');
          JsonTextWriter.WriteValue(TransMode);
          JsonTextWriter.WritePropertyName('transportation_distance');
          JsonTextWriter.WriteValue(Distance);
          JsonTextWriter.WritePropertyName('vehicle_number');
          JsonTextWriter.WriteValue(VehNo);
          JsonTextWriter.WritePropertyName('vehicle_type');
          JsonTextWriter.WriteValue(VehType);
          JsonTextWriter.WritePropertyName('generate_status');
          JsonTextWriter.WriteValue('1');
          JsonTextWriter.WritePropertyName('data_source');
          JsonTextWriter.WriteValue('erp');
          JsonTextWriter.WritePropertyName('user_ref');
          JsonTextWriter.WriteValue(PurchHeader."No.");
          JsonTextWriter.WritePropertyName('location_code');
          JsonTextWriter.WriteValue(PurchHeader."Location Code");
          JsonTextWriter.WritePropertyName('eway_bill_status');
          JsonTextWriter.WriteValue('ABC');
          JsonTextWriter.WritePropertyName('auto_print');
          JsonTextWriter.WriteValue('Y');
          //JsonTextWriter.WritePropertyName('EWB_print_type');
          //JsonTextWriter.WriteValue('d');
          JsonTextWriter.WritePropertyName('email');
          JsonTextWriter.WriteValue(CompanyInfo."E-Mail");*/
        JOsupplyTypeG.Add('transporterId', TransId);
        JOsupplyTypeG.Add('transporterName', TransName);
        JOsupplyTypeG.Add('transDocNo', TransDocNo);
        JOsupplyTypeG.Add('transMode', TransMode);
        JOsupplyTypeG.Add('transDistance', Distance);
        JOsupplyTypeG.Add('transDocDate', TransDocDt);
        JOsupplyTypeG.Add('vehicleNo', VehNo);
        JOsupplyTypeG.Add('vehicleType', VehType);
        JOsupplyTypeG.Add('generate_status', '1');
        JOsupplyTypeG.Add('data_source', 'erp');
        JOsupplyTypeG.Add('user_ref', SalesInvoiceHeader."No.");
        JOsupplyTypeG.Add('location_code', SalesInvoiceHeader."Location Code");
        JOsupplyTypeG.Add('eway_bill_status', 'ABC');
        JOsupplyTypeG.Add('auto_print', 'Y');
        JOsupplyTypeG.Add('EWB_print_type', 'd');
        JOsupplyTypeG.Add('email', CompanyInfo."E-Mail");

    end;

    local procedure PurchReadItemList()
    var
        PurchLine: Record "Purchase Line";
        SalesLinesErr: Label 'E-Invoice allowes only 1000 lines per Invoice. Curent transaction is having %1 lines.', Comment = '%1 = Sales Lines count';
        HSNInt: Integer;
        Uom: Record "Unit of Measure";
    begin
        PurchLine.RESET;
        PurchLine.SETRANGE("Document No.", PurchHeader."No.");
        PurchLine.SETFILTER("No.", '<>%1', '');
        PurchLine.SETRANGE(Type, PurchLine.Type::Item);
        PurchLine.SETFILTER(Quantity, '>%1', 0);
        PurchLine.SETRANGE(Exempted, FALSE);
        IF PurchLine.FINDSET THEN BEGIN
            IF PurchLine.COUNT > 1000 THEN
                ERROR(SalesLinesErr, PurchLine.COUNT);
            //JsonTextWriter.WritePropertyName('itemList');
            //  JsonTextWriter.WriteStartArray;
            REPEAT
                EVALUATE(HSNInt, PurchLine."HSN/SAC Code");
                /*   JsonTextWriter.WriteStartObject;
                   JsonTextWriter.WritePropertyName('product_name');
                   JsonTextWriter.WriteValue(PurchLine."No.");
                   JsonTextWriter.WritePropertyName('product_description');
                   JsonTextWriter.WriteValue(PurchLine.Description);
                   JsonTextWriter.WritePropertyName('hsn_code');
                   JsonTextWriter.WriteValue(HSNInt);
                   Uom.GET(PurchLine."Unit of Measure Code");
                   JsonTextWriter.WritePropertyName('unit_of_product');
                   JsonTextWriter.WriteValue(Uom."International Standard Code");

                   PurchGetGSTCompRate(PurchHeader."No.", PurchLine."Line No.");

                   JsonTextWriter.WritePropertyName('taxableAmount');
                   IF PurchHeader."Currency Code" <> '' THEN
                       JsonTextWriter.WriteValue((1 / PurchHeader."Currency Factor") * PurchLine."Line Amount")
                   ELSE
                       JsonTextWriter.WriteValue(PurchLine."Line Amount");
                   JsonTextWriter.WriteEndObject;*/
                Uom.GET(PurchLine."Unit of Measure Code");
                JOItemsG.Add('product_name', PurchLine."No.");
                JOItemsG.Add('product_description', PurchLine.Description);
                JOItemsG.Add('hsn_code', HSNInt);
                JOItemsG.Add('unit_of_product', Uom."International Standard Code");
                JOItemsG.Add('quantity', PurchLine.Quantity);

                PurchGetGSTCompRate(PurchHeader."No.", PurchLine."Line No.", JOItemsG);
                IF PurchHeader."Currency Code" <> '' THEN
                    JOItemsG.Add('taxableAmount', ((1 / PurchHeader."Currency Factor") * PurchLine."Line Amount"))
                else
                    JOItemsG.Add('taxableAmount', PurchLine."Line Amount");
                JArrayItemsG.Add(JOItemsG);
            UNTIL PurchLine.NEXT = 0;
            JOsupplyTypeG.Add('itemList', JArrayItemsG);
            //JsonTextWriter.WriteEndArray;
        END;
    end;

    local procedure WhseReadItemList()
    var
        WhseRectLine: Record "Warehouse Receipt Line";
        SalesLinesErr: Label 'E-Invoice allowes only 1000 lines per Invoice. Curent transaction is having %1 lines.', Comment = '%1 = Sales Lines count';
        PurchLine: Record "Purchase Line";
        HSNInt: Integer;
        Uom: Record "Unit of Measure";
    begin
        WhseRectLine.RESET;
        WhseRectLine.SETRANGE("Source Document", WhseRectLine."Source Document"::"Purchase Order");
        WhseRectLine.SETRANGE("Source No.", PurchHeader."No.");
        WhseRectLine.SETFILTER("Qty. to Receive", '>%1', 0);
        IF WhseRectLine.FINDSET THEN BEGIN
            IF WhseRectLine.COUNT > 1000 THEN
                ERROR(SalesLinesErr, WhseRectLine.COUNT);
            //   JsonTextWriter.WritePropertyName('itemList');
            //  JsonTextWriter.WriteStartArray;
            REPEAT
                PurchLine.RESET;
                PurchLine.SETRANGE("Document Type", PurchLine."Document Type"::Order);
                PurchLine.SETRANGE("Document No.", WhseRectLine."Source No.");
                PurchLine.SETRANGE("Line No.", WhseRectLine."Source Line No.");
                IF PurchLine.FINDFIRST THEN;

                EVALUATE(HSNInt, PurchLine."HSN/SAC Code");
                /*   JsonTextWriter.WriteStartObject;
                   JsonTextWriter.WritePropertyName('product_name');
                   JsonTextWriter.WriteValue(PurchLine."No.");
                   JsonTextWriter.WritePropertyName('product_description');
                   JsonTextWriter.WriteValue(PurchLine.Description);
                   JsonTextWriter.WritePropertyName('hsn_code');
                   JsonTextWriter.WriteValue(HSNInt);
                   Uom.GET(PurchLine."Unit of Measure Code");
                   JsonTextWriter.WritePropertyName('unit_of_product');
                   JsonTextWriter.WriteValue(Uom."International Standard Code");

                   PurchGetGSTCompRate(WhseRectLine."No.", WhseRectLine."Line No.");

                   JsonTextWriter.WritePropertyName('taxableAmount');
                   IF PurchHeader."Currency Code" <> '' THEN
                       JsonTextWriter.WriteValue((1 / PurchHeader."Currency Factor") * (PurchLine."Direct Unit Cost" * WhseRectLine."Qty. to Receive"))
                   ELSE
                       JsonTextWriter.WriteValue(PurchLine."Direct Unit Cost" * WhseRectLine."Qty. to Receive");
                   JsonTextWriter.WriteEndObject;*/
                Uom.GET(PurchLine."Unit of Measure Code");
                JOItemsG.Add('product_name', PurchLine."No.");
                JOItemsG.Add('product_description', PurchLine.Description);
                JOItemsG.Add('hsn_code', HSNInt);
                JOItemsG.Add('unit_of_product', Uom."International Standard Code");
                JOItemsG.Add('quantity', PurchLine.Quantity);

                PurchGetGSTCompRate(PurchHeader."No.", PurchLine."Line No.", JOItemsG);
                IF PurchHeader."Currency Code" <> '' THEN
                    JOItemsG.Add('taxableAmount', (1 / PurchHeader."Currency Factor") * (PurchLine."Direct Unit Cost" * WhseRectLine."Qty. to Receive"))
                else
                    JOItemsG.Add('taxableAmount', PurchLine."Direct Unit Cost" * WhseRectLine."Qty. to Receive");
                JArrayItemsG.Add(JOItemsG);
            UNTIL WhseRectLine.NEXT = 0;
            //JsonTextWriter.WriteEndArray;
            JOsupplyTypeG.Add('itemList', JArrayItemsG);
        END;
    end;

    procedure PurchVechileJson()
    var
        LocationBuff: Record Location;
        StateBuff: Record State;
        Reason: Text;
        ReasonRemarks: Text;
        TransDocNo: Text;
        TransDocDate: Date;
        HeaderTitle: Label 'Enter Details';
        Title1: Label 'Reason :';
        Title2: Label 'Remarks :';
        Title3: Label 'Vehicle No :';
        VehicleNo: Text;
        TransMode: Text;
        TransportMethod: Record "Transport Method";
        VehType: Text;
    begin
        LocationBuff.GET(PurchHeader."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        IF IsPosting THEN BEGIN
            Reason := 'Others';//EWayBillingSetup."Vehicle Reason";
            ReasonRemarks := EWayBillingSetup."Vehicle Remarks";
            VehicleNo := PurchHeader."Vehicle No.";
        END ELSE BEGIN
            Reason := 'Others';//EWayBillingSetup."Vehicle Reason";
            ReasonRemarks := EWayBillingSetup."Vehicle Remarks";
            //B2BUPG1.0>>
            // VehicleNo := Windows.InputBox(Title3, '', '', 10, 10);
            Clear(EWayUpdate);
            Commit();
            EWayUpdate.SetData(0);
            if EWayUpdate.RunModal() = Action::Yes then
                EWayUpdate.GetData(0, VehicleNo);
            //B2BUPG1.0<<
            IF VehicleNo = ' ' THEN
                EXIT;
            //PurchHeader."Old Vehicle No" := PurchHeader."Vehicle No.";
            PurchHeader."Vehicle No." := VehicleNo;
            PurchHeader.MODIFY();
        END;

        IF TransportMethod.GET(PurchHeader."Transport Method") THEN BEGIN
            TransMode := TransportMethod.Description;
        END;
        CASE PurchHeader."Vehicle Type" OF
            PurchHeader."Vehicle Type"::" ":
                VehType := '';
            PurchHeader."Vehicle Type"::ODC:
                VehType := 'odc';
            PurchHeader."Vehicle Type"::Regular:
                VehType := 'Regular';
        END;
        TransDocNo := '';
        TransDocDate := 0D;
        IF WareHouseRectHead."No." = '' THEN
            PurchWriteVechileJson(GetEwayBillIngNo(TransType::"Purch. Order", PurchHeader."No."), PurchHeader."Location GST Reg. No.", VehicleNo, LocationBuff.City, StateBuff.Description, Reason, ReasonRemarks,
                          TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode, VehType)
        ELSE
            PurchWriteVechileJson(GetEwayBillIngNo(TransType::"Whse. Rect", WareHouseRectHead."No."), PurchHeader."Location GST Reg. No.", VehicleNo, LocationBuff.City, StateBuff.Description, Reason, ReasonRemarks,
                      TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode, VehType)
    end;

    local procedure PurchWriteVechileJson(EwbNo: Text; GSTIN: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; ReasonCode: Text; ReasonRem: Text; TransDocNo: Text; TransDocDate: Text; TransMode: Text; VehType: Text)
    var
        EwbBigInt: BigInteger;
    begin
        /*  JsonTextWriter.WriteStartObject();
          JsonTextWriter.WritePropertyName('access_token');
          JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
          JsonTextWriter.WritePropertyName('userGstin');
          JsonTextWriter.WriteValue(GSTIN);
          JsonTextWriter.WritePropertyName('eway_bill_number');
          JsonTextWriter.WriteValue(EwbNo);
          JsonTextWriter.WritePropertyName('vehicle_number');
          JsonTextWriter.WriteValue(VehicleNo);
          JsonTextWriter.WritePropertyName('vehicle_type');
          JsonTextWriter.WriteValue(VehType);
          JsonTextWriter.WritePropertyName('place_of_consignor');
          JsonTextWriter.WriteValue(FromPlace);
          JsonTextWriter.WritePropertyName('state_of_consignor');
          JsonTextWriter.WriteValue(FromState);
          JsonTextWriter.WritePropertyName('reason_code_for_vehicle_updation');
          JsonTextWriter.WriteValue(ReasonCode);
          JsonTextWriter.WritePropertyName('reason_for_vehicle_updation');
          JsonTextWriter.WriteValue(ReasonRem);
          JsonTextWriter.WritePropertyName('transporter_document_number');
          JsonTextWriter.WriteValue(TransDocNo);
          JsonTextWriter.WritePropertyName('transporter_document_date');
          JsonTextWriter.WriteValue(TransDocDate);
          JsonTextWriter.WritePropertyName('mode_of_transport');
          JsonTextWriter.WriteValue(TransMode);
          JsonTextWriter.WritePropertyName('data_source');
          JsonTextWriter.WriteValue('erp');
          JsonTextWriter.WriteEndObject();*/
        JOVehicleG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOVehicleG.Add('userGstin', GSTIN);
        JOVehicleG.Add('eway_bill_number', EwbNo);
        JOVehicleG.Add('vehicle_number', VehicleNo);
        JOVehicleG.Add('vehicle_type', VehType);
        JOVehicleG.Add('place_of_consignor', FromPlace);
        JOVehicleG.Add('state_of_consignor', FromState);
        JOVehicleG.Add('reason_code_for_vehicle_updation', ReasonCode);
        JOVehicleG.Add('reason_for_vehicle_updation', ReasonRem);
        JOVehicleG.Add('transporter_document_number', TransDocNo);
        JOVehicleG.Add('transporter_document_date', '');
        JOVehicleG.add('mode_of_transport', TransMode);
        JOVehicleG.Add('data_source', 'erp');
    end;

    local procedure PurchCancelEwayJson()
    var
        HeaderTitle: Label 'Enter Cancel Details';
        Title1: Label 'Cancel Reason :';
        Title2: Label 'Cancel Remarks :';
        LocationBuff: Record Location;
        StateBuff: Record State;
        Reason: Text;
        ReasonRemarks: Text;
        TransDocNo: Text;
        TransDocDate: Date;
        Title3: Text;
        RemainingDist: Text;
    begin
        //B2BUPG1.0>>
        //IF NOT OpenWindow(HeaderTitle, Title1, Title2, Title3, Reason, ReasonRemarks, RemainingDist) THEN
        //    EXIT;
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(3);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetCancelTransportData(3, Reason, ReasonRemarks, RemainingDist);
        IF (Reason = '') or (ReasonRemarks = '') THEN
            EXIT;
        //B2BUPG1.0<<
        IF WareHouseRectHead."No." = '' THEN
            PurchWriteCancelJson(GetEwayBillIngNo(TransType::"Purch. Order", PurchHeader."No."), PurchHeader."Location GST Reg. No.", Reason, ReasonRemarks)
        ELSE
            PurchWriteCancelJson(GetEwayBillIngNo(TransType::"Whse. Rect", WareHouseRectHead."No."), PurchHeader."Location GST Reg. No.", Reason, ReasonRemarks);
    end;

    local procedure PurchWriteCancelJson(EWBNo: Text; GSTIN: Text; CancelReason: Text; CancelRemarks: Text)
    begin
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('access_token');
         JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
         JsonTextWriter.WritePropertyName('userGstin');
         JsonTextWriter.WriteValue(GSTIN);
         JsonTextWriter.WritePropertyName('eway_bill_number');
         JsonTextWriter.WriteValue(EWBNo);
         JsonTextWriter.WritePropertyName('reason_of_cancel');
         JsonTextWriter.WriteValue(CancelReason);
         JsonTextWriter.WritePropertyName('cancel_remark');
         JsonTextWriter.WriteValue(CancelRemarks);
         JsonTextWriter.WritePropertyName('data_source');
         JsonTextWriter.WriteValue('erp');
         JsonTextWriter.WriteEndObject();*/
        JOCancelG.add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOCancelG.Add('userGstin', GSTIN);
        JOCancelG.Add('eway_bill_number', EWBNo);
        JOCancelG.Add('reason_of_cancel', CancelReason);
        JOCancelG.Add('cancel_remark', CancelRemarks);
        JOCancelG.Add('data_source', 'erp');
    end;

    procedure PurchRejectEwayJson(RejDocumentNo: Code[20]; var RejEwayBillNo: BigInteger)
    var
        HeaderTitle: Label 'Enter Cancel Details';
        Title1: Label 'Cancel Reason :';
        Title2: Label 'Cancel Remarks :';
        RejectEwayBillNo: Text;

        EWayValidator: Codeunit "E-Way Validator";
        RejectErr: Label 'E-Way bill no must be provided to Reject.';
    begin
        EWayBillingSetup.GET;
        RequestType := RequestType::RejectEway;

        //B2BUPG1.0<<
        //RejectEwayBillNo := Windows.InputBox('Rejecting E-Way Bill No :', '', '', 10, 10);
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(1);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetData(1, RejectEwayBillNo);
        //B2BUPG1.0<<
        IF RejectEwayBillNo = '' THEN
            ERROR(RejectErr);
        EWayValidator.CheckValidations(RejectEwayBillNo, RequestType);//Check Validations

        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('access_token');
         JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
         JsonTextWriter.WritePropertyName('userGstin');
         JsonTextWriter.WriteValue(CompanyInfo."GST Registration No.");
         JsonTextWriter.WritePropertyName('eway_bill_number');
         JsonTextWriter.WriteValue(RejectEwayBillNo);
         JsonTextWriter.WritePropertyName('data_source');
         JsonTextWriter.WriteValue('erp');
         JsonTextWriter.WriteEndObject();
         EVALUATE(RejEwayBillNo, RejectEwayBillNo);
         ExportAsJson(RejDocumentNo, PathSaved);*/
        JORejEWayNoG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JORejEWayNoG.Add('userGstin', CompanyInfo."GST Registration No.");
        EVALUATE(RejEwayBillNo, RejectEwayBillNo);
        JORejEWayNoG.Add('eway_bill_number', RejectEwayBillNo);
        JORejEWayNoG.Add('data_source', 'erp');
    end;

    local procedure PurchUpdateTransportJson()
    var
        TransportID: Text;

        TransportIDError: Label 'Transport Id must have value';
        HeaderTitle: Label 'Trasporter Details';
        Title1: Label 'Transporter ID';
        Title2: Label 'Transporter Name';
        Title3: Text;
        TransporterName: Text;
        Blank: Text;
    begin
        //B2BUPG1.0>>
        //IF NOT OpenWindow(HeaderTitle, Title1, Title2, Title3, TransportID, TransporterName, Blank) THEN
        //    EXIT;
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(3);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetCancelTransportData(3, TransportID, TransporterName, Blank);
        IF (TransportID = '') or (TransporterName = '') THEN
            EXIT;
        //B2BUPG1.0<<
        /*  JsonTextWriter.WriteStartObject();
          JsonTextWriter.WritePropertyName('access_token');
          JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
          JsonTextWriter.WritePropertyName('userGstin');
          JsonTextWriter.WriteValue(PurchHeader."Location GST Reg. No.");
          JsonTextWriter.WritePropertyName('eway_bill_number');
          IF WareHouseRectHead."No." = '' THEN
              JsonTextWriter.WriteValue(GetEwayBillIngNo(TransType::"Purch. Order", PurchHeader."No."))
          ELSE
              JsonTextWriter.WriteValue(GetEwayBillIngNo(TransType::"Whse. Rect", WareHouseRectHead."No."));
          JsonTextWriter.WritePropertyName('transporter_id');
          JsonTextWriter.WriteValue(TransportID);
          JsonTextWriter.WritePropertyName('transporter_name');
          JsonTextWriter.WriteValue(TransporterName);
          JsonTextWriter.WriteEndObject();*/
        JOUpdatetransportIDG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOUpdatetransportIDG.Add('userGstin', PurchHeader."Location GST Reg. No.");
        if WareHouseRectHead."No." = '' then
            JOUpdatetransportIDG.Add('eway_bill_number', GetEwayBillIngNo(TransType::"Purch. Order", PurchHeader."No."))
        else
            JOUpdatetransportIDG.Add('eway_bill_number', GetEwayBillIngNo(TransType::"Whse. Rect", WareHouseRectHead."No."));

        JOUpdatetransportIDG.Add('transporter_id', TransportID);
        JOUpdatetransportIDG.Add('transporter_name', TransporterName);
    end;

    local procedure PurchExtendValidityJson()
    var
        LocationBuff: Record Location;
        StateBuff: Record State;
        HeaderTitle: Label 'Enter Details';
        Title1: Label 'Reason :';
        Title2: Label 'Remarks :';
        Title3: Label 'Rem. Dist :';
        Reason: Text;
        ReasonRemarks: Text;
        TransDocNo: Text;
        TransDocDate: Date;
        RemainingDist: Integer;
        RemainingDistText: Text;
        Pin: Integer;
        ExtendErr: Label 'Reason,Remarks and Remaining Distance has to be given to Extend E-Way validity.';
        TransportMethod: Record "Transport Method";
        TransMode: Text;
    begin
        LocationBuff.GET(PurchHeader."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        //B2BUPG1.0>>
        //IF NOT OpenWindow(HeaderTitle, Title1, Title2, Title3, Reason, ReasonRemarks, RemainingDistText) THEN
        //    ERROR(ExtendErr);
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(3);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetCancelTransportData(3, Reason, ReasonRemarks, RemainingDistText);
        IF (Reason = '') or (ReasonRemarks = '') THEN
            ERROR(ExtendErr);
        //B2BUPG1.0<<
        EVALUATE(RemainingDist, RemainingDistText);
        IF PurchHeader."GST Vendor Type" = PurchHeader."GST Vendor Type"::Import THEN
            EVALUATE(Pin, '999999')
        ELSE
            EVALUATE(Pin, COPYSTR(PurchHeader."Buy-from Post Code", 1, 6));

        IF TransportMethod.GET(PurchHeader."Transport Method") THEN BEGIN
            CASE TransportMethod."Transportation Mode" OF
                TransportMethod."Transportation Mode"::Road:
                    TransMode := 'road';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := 'rail';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := 'air';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := 'ship';
            END;
        END;

        TransDocNo := '';
        TransDocDate := 0D;
        IF WareHouseRectHead."No." = '' THEN
            PurchWriteExtendValidityJson(GetEwayBillIngNo(TransType::"Purch. Order", PurchHeader."No."), PurchHeader."Location GST Reg. No.", PurchHeader."Vehicle No.", LocationBuff.City, StateBuff.Description, RemainingDist, TransDocNo,
                        FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode, Reason, ReasonRemarks, Pin, 'T', PurchHeader."Transaction Type",
                        '', '', '')
        ELSE
            PurchWriteExtendValidityJson(GetEwayBillIngNo(TransType::"Whse. Rect", WareHouseRectHead."No."), PurchHeader."Location GST Reg. No.", PurchHeader."Vehicle No.", LocationBuff.City, StateBuff.Description, RemainingDist, TransDocNo,
                        FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode, Reason, ReasonRemarks, Pin, 'T', PurchHeader."Transaction Type",
                        '', '', '');
    end;

    local procedure PurchWriteExtendValidityJson(EwbNo: Text; GSTIN: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; RemainingDist: Integer; TransDocNo: Text; TransDocDate: Text; TransMode: Text; ReasonCode: Text; ReasonRem: Text; FromPincode: Integer; ConsignmentStatus: Text; TransitType: Text; AddressLine1: Text; AddressLine2: Text; AddressLine3: Text)
    begin
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('access_token');
         JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."Access Token 2");
         JsonTextWriter.WritePropertyName('userGstin');
         JsonTextWriter.WriteValue(GSTIN);
         JsonTextWriter.WritePropertyName('eway_bill_number');
         JsonTextWriter.WriteValue(EwbNo);
         JsonTextWriter.WritePropertyName('vehicle_number');
         JsonTextWriter.WriteValue(VehicleNo);
         JsonTextWriter.WritePropertyName('place_of_consignor');
         JsonTextWriter.WriteValue(FromPlace);
         JsonTextWriter.WritePropertyName('state_of_consignor');
         JsonTextWriter.WriteValue(FromState);
         JsonTextWriter.WritePropertyName('remaining_distance');
         JsonTextWriter.WriteValue(RemainingDist);
         JsonTextWriter.WritePropertyName('transporter_document_number');
         JsonTextWriter.WriteValue(TransDocNo);
         JsonTextWriter.WritePropertyName('transporter_document_date');
         JsonTextWriter.WriteValue(TransDocDate);
         JsonTextWriter.WritePropertyName('mode_of_transport');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WritePropertyName('extend_validity_reason');
         JsonTextWriter.WriteValue(ReasonCode);
         JsonTextWriter.WritePropertyName('extend_remarks');
         JsonTextWriter.WriteValue(ReasonRem);
         JsonTextWriter.WritePropertyName('from_pincode');
         JsonTextWriter.WriteValue(FromPincode);
         JsonTextWriter.WritePropertyName('consignment_status');
         JsonTextWriter.WriteValue(ConsignmentStatus);
         JsonTextWriter.WritePropertyName('transit_type');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WritePropertyName('address_line1');
         JsonTextWriter.WriteValue(AddressLine1);
         JsonTextWriter.WritePropertyName('address_line2');
         JsonTextWriter.WriteValue(AddressLine2);
         JsonTextWriter.WritePropertyName('address_line3');
         JsonTextWriter.WriteValue(AddressLine3);
         JsonTextWriter.WriteEndObject();*/
        JOExtendValidityJsonG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOExtendValidityJsonG.Add('userGstin', GSTIN);
        JOExtendValidityJsonG.Add('eway_bill_number', EwbNo);
        JOExtendValidityJsonG.Add('vehicle_number', VehicleNo);
        JOExtendValidityJsonG.Add('place_of_consignor', FromPlace);
        JOExtendValidityJsonG.Add('state_of_consignor', FromState);
        JOExtendValidityJsonG.Add('remaining_distance', RemainingDist);
        JOExtendValidityJsonG.Add('transporter_document_number', TransDocNo);
        JOExtendValidityJsonG.Add('transporter_document_date', TransDocDate);
        JOExtendValidityJsonG.Add('mode_of_transport', '5');
        JOExtendValidityJsonG.Add('extend_validity_reason', ReasonCode);
        JOExtendValidityJsonG.Add('extend_remarks', ReasonRem);
        JOExtendValidityJsonG.add('from_pincode', FromPincode);
        JOExtendValidityJsonG.add('consignment_status', ConsignmentStatus);
        JOExtendValidityJsonG.add('transit_type', 'R');
        JOExtendValidityJsonG.Add('address_line1', AddressLine1);
        JOExtendValidityJsonG.Add('address_line2', AddressLine2);
        JOExtendValidityJsonG.Add('address_line3', AddressLine3);
    end;

    procedure PurchCalCulateShipmentGST(PurchHead: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
        StateBuff: Record State;
    begin
        PurchDeleteGSTEntry(); //
        PurchLine.RESET;
        PurchLine.SETRANGE("Document No.", PurchHead."No.");
        PurchLine.SETRANGE(Type, PurchLine.Type::Item);
        PurchLine.SETFILTER("No.", '<>%1', '');
        PurchLine.SETRANGE(Exempted, FALSE);
        IF PurchLine.FINDSET THEN BEGIN
            REPEAT
                DocType := DocType::Shipment;

                IF PurchHead."Order Address Code" <> '' THEN
                    StateBuff.GET(PurchHead."Order Address Code")
                ELSE
                    StateBuff.GET(PurchHead.State);

                PurchCalculateGSTAmounts(PurchHead."No.", PurchLine."Line No.", PurchLine."GST Jurisdiction Type".AsInteger, StateBuff."State Code (GST Reg. No.)",
                  PurchLine."GST Group Code", PurchHead."Posting Date", PurchLine."Qty. to Receive" * PurchLine."Direct Unit Cost",
                  PurchHead."Currency Code", PurchHead."Currency Factor", PurchLine."Direct Unit Cost", PurchLine.Quantity,
                  PurchLine."Unit of Measure Code", PurchLine."No.", PurchLine."Line Discount %");

            UNTIL PurchLine.NEXT = 0;
        END;
    end;

    procedure WhseCalCulateShipmentGST(WhseRectHead: Record "Warehouse Receipt Header")
    var
        WhseRectLine: Record "Warehouse Receipt Line";
        PurchLine: Record "Purchase Line";
        StateBuff: Record State;
    begin
        PurchDeleteGSTEntry();
        WhseRectLine.RESET();
        WhseRectLine.SETRANGE("No.", WhseRectHead."No.");
        WhseRectLine.SETFILTER("Qty. to Receive", '>%1', 0);
        IF WhseRectLine.FINDSET THEN BEGIN
            REPEAT
                PurchLine.RESET;
                PurchLine.SETRANGE("Document No.", WhseRectLine."Source No.");
                PurchLine.SETRANGE(Type, PurchLine.Type::Item);
                PurchLine.SETRANGE("Line No.", WhseRectLine."Source Line No.");
                IF PurchLine.FINDSET THEN;
                DocType := DocType::Shipment;

                IF PurchHeader."Order Address Code" <> '' THEN
                    StateBuff.GET(PurchHeader."Order Address Code")
                ELSE
                    StateBuff.GET(PurchHeader.State);
                //B2BUPG1.0>>
                /*
                PurchCalculateGSTAmounts(WhseRectHead."No.", WhseRectLine."Line No.", PurchLine."GST Jurisdiction Type".AsInteger, StateBuff."State Code (GST Reg. No.)",
                  PurchLine."GST Group Code", WhseRectHead."Posting Date", WhseRectLine."Qty. to Receive" * PurchLine."Direct Unit Cost",
                  PurchHeader."Currency Code", PurchHeader."Currency Factor", PurchLine."Direct Unit Cost", PurchLine.Quantity,
                  PurchLine."Unit of Measure Code", PurchLine."No.", PurchLine."Line Discount %");
                */
                GetGSTAmountsPurchase(PurchLine);
            //B2BUPG1.0<<
            UNTIL WhseRectLine.NEXT = 0;
        END;
    end;

    local procedure PurchCalculateGSTAmounts(DocumentNo: Code[20]; LineNo: Integer; GSTJurisdiction: Option; GSTStateCode: Code[10]; GSTGroupCode: Code[20]; EffectiveDate: Date; Amount: Decimal; CurrencyCode: Code[10]; CurrencyFactor: Decimal; UnitCost: Decimal; LineQty: Decimal; UOM: Code[10]; ItemNo: Code[20]; Discount: Decimal)
    var
        GSTComponent: Record "Tax Component";
        GSTSetup: Record "GST Setup";
        //GSTCalculationBuffer: Record Table16421;
        TotalGSTAmount: Decimal;
    begin
        /*
        GSTComponent.SETCURRENTKEY("Calculation Order");
        GSTComponent.SETRANGE("GST Jurisdiction Type", GSTJurisdiction);
        IF GSTComponent.FINDSET THEN
            REPEAT
                IF PurchGetGSTSetup(GSTSetup, GSTStateCode, GSTGroupCode, GSTComponent.Code, EffectiveDate) <> '' THEN BEGIN
                    PurchInitGSTCalculationBuffer(
                              GSTSetup, DocumentNo, LineNo, UnitCost,
                              EffectiveDate, CurrencyCode, CurrencyFactor, Amount, Discount)
                END;
            UNTIL GSTComponent.NEXT = 0;
            */
    end;

    procedure PurchGetGSTSetup(var GSTSetup: Record "GST Setup"; GSTStateCode: Code[10]; GSTGroupCode: Code[20]; GSTComponentCode: Code[10]; EffectiveDate: Date): Code[20]
    begin
        /*
        WITH GSTSetup DO BEGIN
            SETRANGE("GST State Code", GSTStateCode);
            SETRANGE("GST Group Code", GSTGroupCode);
            SETRANGE("GST Component Code", GSTComponentCode);
            IF EffectiveDate = 0D THEN
                SETFILTER("Effective Date", '<=%1', WORKDATE)
            ELSE
                SETFILTER("Effective Date", '<=%1', EffectiveDate);
            IF FINDLAST THEN
                EXIT("GST Component Code");
            SETRANGE("GST State Code");
            SETRANGE("GST State Code", '');
            IF FINDLAST THEN
                EXIT("GST Component Code");
        END;
        */
    end;

    local procedure PurchInitGSTCalculationBuffer(LineNo: Integer; SaleAmount: Decimal; Percentage: Decimal; GStGroupCode: Code[20]; GSTComponent: Code[10]; QtytoReceive: Decimal; Qty: Decimal)
    var

        Threshold: Decimal;
        GSTEntry: Record "GST Entry";
        TransactionType: Option Purchase,Sales,Transfer,Service,"Service Transfer",Production;
    begin
        GSTEntry.INIT;
        GSTEntry."Transaction Type" := GSTEntry."Transaction Type"::Purchase;
        GSTEntry."Document Type" := DocType;
        GSTEntry."Document No." := DocumentNo;
        GSTEntry."GST Group Code" := GStGroupCode;
        GSTEntry."GST Component Code" := GSTComponent;
        //"Effective Date" := GSTSetup."Effective Date";
        GSTEntry."Document Line No." := LineNo;
        /*
        CASE GSTSetup."Component Calc. Type" OF
            GSTSetup."Component Calc. Type"::Threshold:
                IF NOT ("Transaction Type" IN ["Transaction Type"::"Service Transfer"]) THEN
                    IF UnitCost <= Threshold THEN
                        Percentage := GSTSetup."Before Threshold %"
                    ELSE
                        Percentage := GSTSetup."GST Component %";
            GSTSetup."Component Calc. Type"::General, GSTSetup."Component Calc. Type"::"Cess %",
          GSTSetup."Component Calc. Type"::"Cess % + Amount / Unit Factor",
          GSTSetup."Component Calc. Type"::"Cess % Or Amount / Unit Factor Whichever Higher":
                Percentage := GSTSetup."GST Component %"
        END;
        */

        GSTEntry."GST Component %" := Percentage;
        //Amount := (SaleAmount - (SaleAmount * DiscountPer / 100)) * "GST Component %" / 100;
        if qty <> 0 then
            GSTEntry.Amount := (SaleAmount / Qty) * QtytoReceive;
        GSTEntry.INSERT(TRUE);
    end;

    local procedure PurchDeleteGSTEntry()
    var
        GSTEntry: Record "GST Entry";
    begin
        GSTEntry.RESET;
        IF WareHouseRectHead."No." = '' THEN
            GSTEntry.SETRANGE("Document No.", PurchHeader."No.")
        ELSE
            GSTEntry.SETRANGE("Document No.", WareHouseRectHead."No.");//WH
        IF GSTEntry.FINDSET THEN
            GSTEntry.DELETEALL;
    end;

    local procedure PurchConvertAmountLCYToFCYRoundSmall(CurrencyCode: Code[10]; Amount: Decimal; CurrencyFactor: Decimal; PostingDate: Date): Decimal
    var
        CurrExchRate: Record "Currency Exchange Rate";
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.GET;
        IF CurrencyCode = '' THEN
            EXIT(Amount);
        EXIT(
          ROUND(
            CurrExchRate.ExchangeAmtLCYToFCY(
              PostingDate, CurrencyCode, Amount, CurrencyFactor),
            GLSetup."Unit-Amount Rounding Precision"));
    end;

    local procedure "------------------------------------PURCH END---------------------------"()
    begin
    end;

    local procedure "-----------------------------------------SALES CREDIT START------------------------------"()
    begin
    end;

    procedure SetSalesCrdHeader(var SalesCredHdrBuff: Record "Sales Cr.Memo Header"; RequestTypePar: Option Eway,Vehicle,EWayCancel,RejectEway,ExtendValidity,UpdateTrasporter,AccessToken; IsPostingPar: Boolean)
    begin
        SalesCreditHeader := SalesCredHdrBuff;
        RequestType := RequestTypePar;
        IsPosting := IsPostingPar;
    end;

    procedure CreditEWayJson()
    var
        LocationBuff: Record Location;
        StateBuff: Record State;
        Gstin: Text;
        Pin: Text;
        Pos: Text;
        Path: Text;
        SubSupplyType: Text;
        SubType: Text;
    begin
        IF SalesCreditHeader."GST Customer Type" = SalesCreditHeader."GST Customer Type"::Export THEN BEGIN
            Gstin := 'URP';
            Pin := '999999';
            SubSupplyType := 'Export';
            SubType := 'Inward';
        END ELSE BEGIN
            Gstin := SalesCreditHeader."Customer GST Reg. No.";
            Pin := COPYSTR(SalesCreditHeader."Bill-to Post Code", 1, 6);
            SubSupplyType := 'Supply';
            SubType := 'Inward';
        END;
        IF SalesCreditHeader."GST Customer Type" = SalesCreditHeader."GST Customer Type"::Unregistered THEN
            Gstin := 'URP';
        CreditEWayHeadDetails(SalesCreditHeader."Location GST Reg. No.", SubType, SubSupplyType, 'Tax Invoice', SalesCreditHeader."No.", FORMAT(SalesCreditHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>')); //Header

        //From Details >>
        Pos := CreditGetEwayPos(SalesCreditHeader."No.");
        LocationBuff.GET(SalesCreditHeader."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        CreditEwayFromDetails(Gstin, SalesCreditHeader."Bill-to Name", SalesCreditHeader."Bill-to Address", SalesCreditHeader."Bill-to Address 2", SalesCreditHeader."Bill-to City", Pin, Pos, Pos);
        //From Details <<

        //To Details >>
        CreditEwayToDetails(SalesCreditHeader."Location GST Reg. No.", CompanyInfo.Name, LocationBuff.Address, LocationBuff."Address 2", LocationBuff.City
                        , LocationBuff."Post Code", StateBuff.Description, StateBuff.Description);
        //To Details <<


        CreditGetGSTCompRate(SalesCreditHeader."No.", 0, JOItemsG);//Update GST calculations
        CreditReadEwbDtls();//Update Transport Details

        CreditReadItemList();
        // JsonTextWriter.WriteEndObject;
        //ExportAsJson("No.", Path);
    end;

    local procedure CreditEWayHeadDetails(GstIn: Text; SupplyType: Text; SupplySubType: Text; Doctype: Text; DocNo: Text; DocDate: Text)
    begin
        /* JsonTextWriter.WriteStartObject;
         JsonTextWriter.WritePropertyName('access_token');
         JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
         JsonTextWriter.WritePropertyName('userGstin');
         JsonTextWriter.WriteValue(GstIn);
         JsonTextWriter.WritePropertyName('supply_type');
         JsonTextWriter.WriteValue(SupplyType);
         JsonTextWriter.WritePropertyName('sub_supply_type');
         JsonTextWriter.WriteValue(SupplySubType);
         JsonTextWriter.WritePropertyName('sub_supply_description');
         JsonTextWriter.WriteValue('');
         JsonTextWriter.WritePropertyName('document_type');
         JsonTextWriter.WriteValue(Doctype);
         JsonTextWriter.WritePropertyName('document_number');
         JsonTextWriter.WriteValue(DocNo);
         JsonTextWriter.WritePropertyName('document_date');
         JsonTextWriter.WriteValue(DocDate);*/
        JOsupplyTypeG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOsupplyTypeG.Add('supply_type', SupplyType);
        JOsupplyTypeG.Add('sub_supply_type', SupplySubType);

        JOsupplyTypeG.Add('sub_supply_description', '');
        JOsupplyTypeG.Add('document_type', Doctype);
        JOsupplyTypeG.Add('document_number', DocNo);
        JOsupplyTypeG.Add('document_date', DocDate);
    end;

    procedure CreditEwayFromDetails(FromGstin: Text; FromTrdName: Text; FromAdd1: Text; FromAdd2: Text; FromPlace: Text; FromPinCode: Text; ActFromStateCode: Text; FromStateCode: Text): Boolean
    var
        FromPinCodeInt: Integer;
        ActFromStateCodeInt: Integer;
        FromStateCodeInt: Integer;
    begin
        IF FromPinCode <> '' THEN
            EVALUATE(FromPinCodeInt, FromPinCode);
        /* JsonTextWriter.WritePropertyName('gstin_of_consignor');
         JsonTextWriter.WriteValue(FromGstin);
         JsonTextWriter.WritePropertyName('legal_name_of_consignor');
         JsonTextWriter.WriteValue(FromTrdName);
         JsonTextWriter.WritePropertyName('address1_of_consignor');
         JsonTextWriter.WriteValue(FromAdd1);
         JsonTextWriter.WritePropertyName('address2_of_consignor');
         JsonTextWriter.WriteValue(FromAdd2);
         JsonTextWriter.WritePropertyName('place_of_consignor');
         JsonTextWriter.WriteValue(FromPlace);
         JsonTextWriter.WritePropertyName('pincode_of_consignor');
         JsonTextWriter.WriteValue(FromPinCodeInt);
         JsonTextWriter.WritePropertyName('state_of_consignor');
         JsonTextWriter.WriteValue(FromStateCode);
         JsonTextWriter.WritePropertyName('actual_from_state_name');
         JsonTextWriter.WriteValue(ActFromStateCode);*/
        JOsupplyTypeG.Add('gstin_of_consignor', FromGstin);
        JOsupplyTypeG.Add('legal_name_of_consignor', FromTrdName);
        JOsupplyTypeG.Add('address1_of_consignor', FromAdd1);
        JOsupplyTypeG.Add('address2_of_consignor', FromAdd2);
        JOsupplyTypeG.Add('place_of_consignor', FromPlace);
        JOsupplyTypeG.Add('pincode_of_consignor', FromPinCodeInt);
        JOsupplyTypeG.Add('state_of_consignor', FromStateCodeInt);
        JOsupplyTypeG.Add('actual_from_state_name', ActFromStateCode);

    end;

    procedure CreditEwayToDetails(ToGstin: Text; ToTrdName: Text; ToAdd1: Text; ToAdd2: Text; ToPlace: Text; ToPinCode: Text; ActFromStateCode: Text; ToStateCode: Text): Boolean
    var
        ToPinCodeInt: Integer;
        ActToStateCodeInt: Integer;
        ToStateCodeInt: Integer;
    begin
        IF ToPinCode <> '' THEN
            EVALUATE(ToPinCodeInt, ToPinCode);
        /*  JsonTextWriter.WritePropertyName('gstin_of_consignee');
          JsonTextWriter.WriteValue(ToGstin);
          JsonTextWriter.WritePropertyName('legal_name_of_consignee');
          JsonTextWriter.WriteValue(ToTrdName);
          JsonTextWriter.WritePropertyName('address1_of_consignee');
          JsonTextWriter.WriteValue(ToAdd1);
          JsonTextWriter.WritePropertyName('address2_of_consignee');
          JsonTextWriter.WriteValue(ToAdd2);
          JsonTextWriter.WritePropertyName('place_of_consignee');
          JsonTextWriter.WriteValue(ToPlace);
          JsonTextWriter.WritePropertyName('pincode_of_consignee');
          JsonTextWriter.WriteValue(ToPinCodeInt);
          JsonTextWriter.WritePropertyName('state_of_supply');*/
        JOsupplyTypeG.Add('gstin_of_consignee', ToGstin);
        JOsupplyTypeG.Add('legal_name_of_consignee', ToTrdName);
        JOsupplyTypeG.Add('address1_of_consignee', ToAdd1);
        JOsupplyTypeG.Add('address2_of_consignee', ToAdd2);
        JOsupplyTypeG.Add('place_of_consignee', ToPlace);
        JOsupplyTypeG.Add('pincode_of_consignee', ToPinCodeInt);
        //Export >>
        IF (SalesCreditHeader."GST Customer Type" IN [SalesCreditHeader."GST Customer Type"::Export, SalesCreditHeader."GST Customer Type"::"SEZ Development",
                                                  SalesCreditHeader."GST Customer Type"::"SEZ Unit"]) THEN
            //JsonTextWriter.WriteValue('OTHER TERRITORY')
            JOsupplyTypeG.Add('state_of_supply', 'OTHER TERRITORY')
        ELSE
            // JsonTextWriter.WriteValue(ToStateCode);
            JOsupplyTypeG.Add('state_of_supply', ToStateCode);


        // JsonTextWriter.WritePropertyName('actual_to_state_name');
        IF (SalesCreditHeader."GST Customer Type" IN [SalesCreditHeader."GST Customer Type"::Export, SalesCreditHeader."GST Customer Type"::"SEZ Development",
                                                  SalesCreditHeader."GST Customer Type"::"SEZ Unit"]) THEN
            //   JsonTextWriter.WriteValue('OTHER TERRITORY')
            JOsupplyTypeG.Add('actual_to_state_name', 'OTHER TERRITORY')
        ELSE
            JOsupplyTypeG.Add('actual_to_state_name', ActFromStateCode);
        //   JsonTextWriter.WriteValue(ActFromStateCode);
        //Export <<

        /* JsonTextWriter.WritePropertyName('transaction_type');
         JsonTextWriter.WriteValue(FORMAT(SalesCreditHeader."Transaction Type"));
         JsonTextWriter.WritePropertyName('other_value');
         JsonTextWriter.WriteValue('');*/
        JOsupplyTypeG.Add('transaction_type', SalesCreditHeader."Transaction Type");
        JOsupplyTypeG.Add('other_value', '');

    end;

    local procedure CreditGetEwayPos(No: Code[20]): Text
    var
        SalesCredLine: Record "Sales Cr.Memo Line";
        StateBuff: Record State;
    begin
        SalesCredLine.SETRANGE("Document No.", No);
        SalesCredLine.SETFILTER("No.", '<>%1', '');//BugFix
        SalesCredLine.SETRANGE(Exempted, FALSE);
        IF SalesCredLine.FINDFIRST THEN
            IF SalesCredLine."GST Place of Supply" = SalesCredLine."GST Place of Supply"::"Bill-to Address" THEN BEGIN
                IF NOT (SalesCreditHeader."GST Customer Type" = SalesCreditHeader."GST Customer Type"::Export) THEN BEGIN
                    StateBuff.GET(SalesCreditHeader."GST Bill-to State Code");
                    EXIT(StateBuff.Description);
                END ELSE
                    EXIT('OTHER COUNTRY');
            END ELSE
                IF SalesCredLine."GST Place of Supply" = SalesCredLine."GST Place of Supply"::"Ship-to Address" THEN BEGIN
                    IF NOT (SalesCreditHeader."GST Customer Type" = SalesCreditHeader."GST Customer Type"::Export) THEN BEGIN
                        StateBuff.GET(SalesCreditHeader."GST Ship-to State Code");
                        EXIT(StateBuff.Description);
                    END ELSE
                        EXIT('OTHER COUNTRY');
                END;
    end;

    local procedure CreditUpdateEwayCalculations(TotalValue: Decimal; CgstValue: Decimal; SgstValue: Decimal; IgstValue: Decimal; CessValue: Decimal)
    var
        SalesCredLine: Record "Sales Cr.Memo Line";
        TotalInvValue: Decimal;
    begin
        SalesCredLine.RESET;
        SalesCredLine.SETRANGE("Document No.", SalesCreditHeader."No.");
        SalesCredLine.SETRANGE(Type, SalesCredLine.Type::Item);
        SalesCredLine.SETRANGE(Exempted, FALSE);
        IF SalesCredLine.FINDSET THEN BEGIN
            REPEAT
                TotalInvValue += (SalesCredLine.Quantity * SalesCredLine."Unit Price") -
                                 ((SalesCredLine.Quantity * SalesCredLine."Unit Price") * SalesCredLine."Line Discount %" / 100) - SalesCredLine."Inv. Discount Amount";
            UNTIL SalesCredLine.NEXT = 0;
        END;

        IF SalesCreditHeader."Currency Code" <> '' THEN BEGIN
            TotalInvValue := (1 / SalesCreditHeader."Currency Factor") * TotalInvValue;
        END;
        TotalValue := CgstValue + SgstValue + IgstValue + CessValue;
        /*  JsonTextWriter.WritePropertyName('total_invoice_value');
          JsonTextWriter.WriteValue(TotalInvValue + TotalValue);
          JsonTextWriter.WritePropertyName('taxable_amount');
          JsonTextWriter.WriteValue(ABS(TotalInvValue));
          JsonTextWriter.WritePropertyName('cgst_amount');
          JsonTextWriter.WriteValue(CgstValue);
          JsonTextWriter.WritePropertyName('sgst_amount');
          JsonTextWriter.WriteValue(SgstValue);
          JsonTextWriter.WritePropertyName('igst_amount');
          JsonTextWriter.WriteValue(IgstValue);
          JsonTextWriter.WritePropertyName('cess_amount');
          JsonTextWriter.WriteValue(CessValue);
          JsonTextWriter.WritePropertyName('cess_nonadvol_value');
          JsonTextWriter.WriteValue('');*/
        JOsupplyTypeG.Add('total_invoice_value', TotalInvValue + TotalValue);
        JOsupplyTypeG.Add('taxable_amount', ABS(TotalInvValue));
        JOsupplyTypeG.Add('cgst_amount', CgstValue);
        JOsupplyTypeG.Add('sgst_amount', SgstValue);
        JOsupplyTypeG.Add('igst_amount', IgstValue);
        JOsupplyTypeG.Add('cess_amount', CessValue);
        JOsupplyTypeG.Add('cess_nonadvol_value', '');
    end;

    local procedure CreditGetGSTCompRate(DocNo: Code[20]; LineNo: Integer; var JSONItemL: JsonObject)
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTComponent: Record "Tax Component";
        CurrExchRate: Record "Currency Exchange Rate";
        CurrencyCode: Code[10];
        CurrencyFactor: Decimal;
        CgstAmt: Decimal;
        SgstAmt: Decimal;
        IgstAmt: Decimal;
        CesRt: Decimal;
        CessAmt: Decimal;
        CesNonAdvlAmt: Decimal;
        StateCesRt: Decimal;
        StateCesAmt: Decimal;
        StateCesNonAdvlAmt: Decimal;
        CgstRt: Decimal;
        SgstRt: Decimal;
        IgstRt: Decimal;
        CesAdvlAmt: Decimal;
        TotalValue: Decimal;
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        DetailedGSTLedgerEntry.RESET;
        DetailedGSTLedgerEntry.SETRANGE("Document No.", DocNo);
        DetailedGSTLedgerEntry.SETRANGE(Type, DetailedGSTLedgerEntry.Type::Item);
        IF LineNo <> 0 THEN
            DetailedGSTLedgerEntry.SETRANGE("Document Line No.", LineNo);

        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'CGST');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS("GST Amount");
            CgstAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            CgstRt := ABS(DetailedGSTLedgerEntry."GST %");
        END ELSE BEGIN
            CgstAmt := 0;
            CgstRt := 0;
        END;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'SGST');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS("GST Amount");
            SgstAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            SgstRt := ABS(DetailedGSTLedgerEntry."GST %");
        END ELSE BEGIN
            SgstAmt := 0;
            SgstRt := 0
        END;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'IGST');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS("GST Amount");
            IgstAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            IgstRt := ABS(DetailedGSTLedgerEntry."GST %");
        END ELSE BEGIN
            IgstAmt := 0;
            IgstRt := 0;
        END;
        CesRt := 0;
        CessAmt := 0;
        CesNonAdvlAmt := 0;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'CESS');
        IF DetailedGSTLedgerEntry.FINDSET THEN
            IF DetailedGSTLedgerEntry."GST %" > 0 THEN BEGIN
                DetailedGSTLedgerEntry.CALCSUMS("GST Amount");
                CesRt := DetailedGSTLedgerEntry."GST %";
                CessAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            END ELSE
                CesNonAdvlAmt := ABS(DetailedGSTLedgerEntry."GST Amount");

        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'INTERCESS');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS("GST Amount");
            CesRt := DetailedGSTLedgerEntry."GST %";
            CessAmt := DetailedGSTLedgerEntry."GST Amount";
        END;

        StateCesRt := 0;
        StateCesAmt := 0;
        StateCesNonAdvlAmt := 0;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code");
        IF DetailedGSTLedgerEntry.FINDSET THEN
            REPEAT
                IF NOT (DetailedGSTLedgerEntry."GST Component Code" IN ['CGST', 'SGST', 'IGST', 'CESS', 'INTERCESS']) THEN
                    IF GSTComponent.GET(DetailedGSTLedgerEntry."GST Component Code") THEN
                        IF DetailedGSTLedgerEntry."GST %" > 0 THEN BEGIN
                            StateCesRt := DetailedGSTLedgerEntry."GST %";
                            StateCesAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
                        END ELSE
                            StateCesNonAdvlAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            UNTIL DetailedGSTLedgerEntry.NEXT = 0;

        TotalValue := DetailedGSTLedgerEntry."GST Base Amount";

        IF SalesCreditHeader."Currency Code" <> '' THEN BEGIN
            CurrencyCode := SalesCreditHeader."Currency Code";
            CurrencyFactor := SalesCreditHeader."Currency Factor";
            /*
            IF IgstAmt <> 0 THEN
              IgstAmt := ROUND((1/SalesCreditHeader."Currency Factor")*IgstAmt,0.01,'=');
            IF CgstAmt <> 0 THEN
              CgstAmt := ROUND((1/SalesCreditHeader."Currency Factor")*CgstAmt,0.01,'=');
            IF SgstAmt <> 0 THEN
              SgstAmt := ROUND((1/SalesCreditHeader."Currency Factor")*SgstAmt,0.01,'=');
            IF CessAmt <> 0 THEN
              CessAmt := ROUND((1/SalesCreditHeader."Currency Factor")*CessAmt,0.01,'=');
            IF CesNonAdvlAmt <> 0 THEN
              CesNonAdvlAmt := ROUND((1/SalesCreditHeader."Currency Factor")*CesNonAdvlAmt,0.01,'=');
            IF StateCesAmt <> 0 THEN
              StateCesAmt := ROUND((1/SalesCreditHeader."Currency Factor")*StateCesAmt,0.01,'=');
            IF StateCesNonAdvlAmt <> 0 THEN
              StateCesNonAdvlAmt := ROUND((1/SalesCreditHeader."Currency Factor")*StateCesNonAdvlAmt,0.01,'=');*/
            IF TotalValue <> 0 THEN
                TotalValue := ROUND((1 / SalesCreditHeader."Currency Factor") * TotalValue, 0.01, '=');
        END;
        IF LineNo = 0 THEN
            CreditUpdateEwayCalculations(TotalValue, CgstAmt, SgstAmt, IgstAmt, CessAmt)//Header Json
        ELSE BEGIN
            /*JsonTextWriter.WritePropertyName('cgst_rate');
            JsonTextWriter.WriteValue(CgstRt);
            JsonTextWriter.WritePropertyName('sgst_rate');
            JsonTextWriter.WriteValue(SgstRt);
            JsonTextWriter.WritePropertyName('igst_rate');
            JsonTextWriter.WriteValue(IgstRt);
            JsonTextWriter.WritePropertyName('cess_rate');
            JsonTextWriter.WriteValue(CesRt);
            SalesCrMemoLine.GET(DocNo, LineNo);
            JsonTextWriter.WritePropertyName('quantity');
            JsonTextWriter.WriteValue(SalesCrMemoLine.Quantity);
            JsonTextWriter.WritePropertyName('cessNonAdvolValue');
            JsonTextWriter.WriteValue(CesNonAdvlAmt);*/
            JSONItemL.Add('cgst_rate', CgstRt);
            JSONItemL.Add('sgst_rate', SgstRt);
            JSONItemL.Add('igst_rate', IgstRt);
            JSONItemL.Add('cess_rate', CesRt);
            SalesCrMemoLine.GET(DocNo, LineNo);
            JSONItemL.Add('quantity', SalesCrMemoLine.Quantity);
            JSONItemL.Add('cessNonAdvolValue', CesNonAdvlAmt);
        END;

    end;

    local procedure CreditReadEwbDtls()
    var
        TransId: Text[15];
        TransName: Text[100];
        TransMode: Text[20];
        Distance: Text[4];
        TransDocNo: Text[15];
        TransDocDt: Text[10];
        VehNo: Text[20];
        VehType: Text[20];
        TransportMethod: Record "Transport Method";
        DistanceTxt: Text;
        TransactionType: Text;
    begin
        TransId := '';//Transit/GSTIN
        TransactionType := SalesCreditHeader."Transaction Type";
        IF TransportMethod.GET(SalesCreditHeader."Transport Method") THEN BEGIN
            TransName := '';
            TransMode := TransportMethod.Description;
        END;
        IF SalesCreditHeader."Distance (Km)" <> 0 THEN BEGIN
            DistanceTxt := DELCHR(FORMAT(ROUND(SalesCreditHeader."Distance (Km)", 1, '=')), '=', ',');

            IF STRLEN(DistanceTxt) > 4 THEN
                Distance := COPYSTR(DistanceTxt, 1, 4)
            ELSE
                Distance := DistanceTxt;
        END ELSE
            Distance := '';
        TransDocNo := '';//Trnasport Document No.
        TransDocDt := '';//Transport Doc Date
        VehNo := SalesCreditHeader."Vehicle No.";
        CASE SalesCreditHeader."Vehicle Type" OF
            SalesCreditHeader."Vehicle Type"::" ":
                VehType := '';
            SalesCreditHeader."Vehicle Type"::ODC:
                VehType := 'ODC';
            SalesCreditHeader."Vehicle Type"::Regular:
                VehType := 'Regular';
        END;
        CreditWriteEwbDtls(TransId, TransName, TransMode, Distance, TransDocNo, TransDocDt, VehNo, VehType, TransactionType);
    end;

    local procedure CreditWriteEwbDtls(TransId: Text[15]; TransName: Text[100]; TransMode: Text[20]; Distance: Text[4]; TransDocNo: Text[15]; TransDocDt: Text[10]; VehNo: Text[20]; VehType: Text[20]; TransactionType: Text)
    begin
        /*  JsonTextWriter.WritePropertyName('transporter_id');
          JsonTextWriter.WriteValue(TransId);
          JsonTextWriter.WritePropertyName('transporter_name');
          JsonTextWriter.WriteValue(TransName);
          JsonTextWriter.WritePropertyName('transporter_document_number');
          JsonTextWriter.WriteValue(TransDocNo);
          JsonTextWriter.WritePropertyName('transporter_document_date');
          JsonTextWriter.WriteValue(TransDocDt);
          JsonTextWriter.WritePropertyName('transportation_mode');
          JsonTextWriter.WriteValue(TransMode);
          JsonTextWriter.WritePropertyName('transportation_distance');
          JsonTextWriter.WriteValue(Distance);
          JsonTextWriter.WritePropertyName('vehicle_number');
          JsonTextWriter.WriteValue(VehNo);
          JsonTextWriter.WritePropertyName('vehicle_type');
          JsonTextWriter.WriteValue(VehType);
          JsonTextWriter.WritePropertyName('generate_status');
          JsonTextWriter.WriteValue('1');
          JsonTextWriter.WritePropertyName('data_source');
          JsonTextWriter.WriteValue('erp');
          JsonTextWriter.WritePropertyName('user_ref');
          JsonTextWriter.WriteValue(SalesCreditHeader."No.");
          JsonTextWriter.WritePropertyName('location_code');
          JsonTextWriter.WriteValue(SalesCreditHeader."Location Code");
          JsonTextWriter.WritePropertyName('eway_bill_status');
          JsonTextWriter.WriteValue('ABC');
          JsonTextWriter.WritePropertyName('auto_print');
          JsonTextWriter.WriteValue('Y');
          //JsonTextWriter.WritePropertyName('EWB_print_type');
          //JsonTextWriter.WriteValue('d');
          JsonTextWriter.WritePropertyName('email');
          JsonTextWriter.WriteValue(CompanyInfo."E-Mail");*/
        JOsupplyTypeG.Add('transporterId', TransId);
        JOsupplyTypeG.Add('transporterName', TransName);
        JOsupplyTypeG.Add('transDocNo', TransDocNo);
        JOsupplyTypeG.Add('transMode', TransMode);
        JOsupplyTypeG.Add('transDistance', Distance);
        JOsupplyTypeG.Add('transDocDate', TransDocDt);
        JOsupplyTypeG.Add('vehicleNo', VehNo);
        JOsupplyTypeG.Add('vehicleType', VehType);
        JOsupplyTypeG.Add('generate_status', '1');
        JOsupplyTypeG.Add('data_source', 'erp');
        JOsupplyTypeG.Add('user_ref', SalesInvoiceHeader."No.");
        JOsupplyTypeG.Add('location_code', SalesInvoiceHeader."Location Code");
        JOsupplyTypeG.Add('eway_bill_status', 'ABC');
        JOsupplyTypeG.Add('auto_print', 'Y');
        JOsupplyTypeG.Add('EWB_print_type', 'd');
        JOsupplyTypeG.Add('email', CompanyInfo."E-Mail");
    end;

    local procedure CreditReadItemList()
    var
        SalesCreditLine: Record "Sales Cr.Memo Line";
        PurchCrMemoLine2: Record "Purch. Cr. Memo Line";
        SalesLinesErr: Label 'E-Invoice allowes only 1000 lines per Invoice. Curent transaction is having %1 lines.', Comment = '%1 = Sales Lines count';
        HSNInt: Integer;
        Uom: Record "Unit of Measure";
    begin
        SalesCreditLine.RESET;
        SalesCreditLine.SETRANGE("Document No.", SalesCreditHeader."No.");
        SalesCreditLine.SETFILTER("No.", '<>%1', '');
        SalesCreditLine.SETRANGE(Type, SalesCreditLine.Type::Item);
        SalesCreditLine.SETFILTER(Quantity, '>%1', 0);
        SalesCreditLine.SETRANGE(Exempted, FALSE);
        IF SalesCreditLine.FINDSET THEN BEGIN
            IF SalesCreditLine.COUNT > 1000 THEN
                ERROR(SalesLinesErr, SalesCreditLine.COUNT);
            //  JsonTextWriter.WritePropertyName('itemList');
            //  JsonTextWriter.WriteStartArray;
            REPEAT
                EVALUATE(HSNInt, SalesCreditLine."HSN/SAC Code");
                /*   JsonTextWriter.WriteStartObject;
                   JsonTextWriter.WritePropertyName('product_name');
                   JsonTextWriter.WriteValue(SalesCreditLine."No.");
                   JsonTextWriter.WritePropertyName('product_description');
                   JsonTextWriter.WriteValue(SalesCreditLine.Description);
                   JsonTextWriter.WritePropertyName('hsn_code');
                   JsonTextWriter.WriteValue(HSNInt);
                   Uom.GET(SalesCreditLine."Unit of Measure Code");
                   JsonTextWriter.WritePropertyName('unit_of_product');
                   JsonTextWriter.WriteValue(Uom."International Standard Code");


                   CreditGetGSTCompRate(SalesCreditHeader."No.", SalesCreditLine."Line No.");

                   JsonTextWriter.WritePropertyName('taxableAmount');
                   IF SalesCreditHeader."Currency Code" <> '' THEN
                       JsonTextWriter.WriteValue((1 / SalesCreditHeader."Currency Factor") * SalesCreditLine."Line Amount")
                   ELSE
                       JsonTextWriter.WriteValue(SalesCreditLine."Line Amount");
                   JsonTextWriter.WriteEndObject;*/
                Uom.GET(SalesCreditLine."Unit of Measure Code");
                JOItemsG.Add('product_name', SalesCreditLine."No.");
                JOItemsG.Add('product_description', SalesCreditLine.Description);
                JOItemsG.Add('hsn_code', HSNInt);
                JOItemsG.Add('unit_of_product', Uom."International Standard Code");
                JOItemsG.Add('quantity', SalesCreditLine.Quantity);

                CreditGetGSTCompRate(SalesCreditHeader."No.", SalesCreditLine."Line No.", JOItemsG);
                IF SalesCreditHeader."Currency Code" <> '' THEN
                    JOItemsG.Add('taxableAmount', ((1 / SalesCreditHeader."Currency Factor") * SalesCreditLine."Line Amount"))
                else
                    JOItemsG.Add('taxableAmount', SalesCreditLine."Line Amount");
                JArrayItemsG.Add(JOItemsG);
            UNTIL SalesCreditLine.NEXT = 0;
            // JsonTextWriter.WriteEndArray;
            JOsupplyTypeG.Add('itemList', JArrayItemsG);
        END;
    end;

    procedure CreditVechileJson()
    var
        LocationBuff: Record Location;
        StateBuff: Record State;
        Reason: Text;
        ReasonRemarks: Text;
        TransDocNo: Text;
        TransDocDate: Date;
        HeaderTitle: Label 'Enter Details';
        Title3: Label 'Vehicle No :';
        VehicleNo: Text;
        TransMode: Text;
        TransportMethod: Record "Transport Method";
        Title1: Text;
        Title2: Text;

        VehType: Text;
    begin
        LocationBuff.GET(SalesCreditHeader."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        IF IsPosting THEN BEGIN
            Reason := 'Others';//EWayBillingSetup."Vehicle Reason";
            ReasonRemarks := EWayBillingSetup."Vehicle Remarks";
            VehicleNo := SalesCreditHeader."Vehicle No.";
        END ELSE BEGIN
            Reason := 'Others';//EWayBillingSetup."Vehicle Reason";
            ReasonRemarks := EWayBillingSetup."Vehicle Remarks";
            //B2BUPG1.0>>
            // VehicleNo := Windows.InputBox(Title3, '', '', 10, 10);
            Clear(EWayUpdate);
            Commit();
            EWayUpdate.SetData(0);
            if EWayUpdate.RunModal() = Action::Yes then
                EWayUpdate.GetData(0, VehicleNo);
            //B2BUPG1.0<<
            IF VehicleNo = ' ' THEN
                EXIT;
            //"Old Vehicle No" := "Vehicle No.";
            SalesCreditHeader."Vehicle No." := VehicleNo;
            SalesCreditHeader.MODIFY;
        END;
        CASE SalesCreditHeader."Vehicle Type" OF
            SalesCreditHeader."Vehicle Type"::" ":
                VehType := '';
            SalesCreditHeader."Vehicle Type"::ODC:
                VehType := 'odc';
            SalesCreditHeader."Vehicle Type"::Regular:
                VehType := 'Regular';
        END;
        IF TransportMethod.GET(SalesCreditHeader."Transport Method") THEN BEGIN
            CASE TransportMethod."Transportation Mode" OF
                TransportMethod."Transportation Mode"::Road:
                    TransMode := 'road';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := 'rail';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := 'air';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := 'ship';
            END;
        END;
        TransDocNo := '';
        TransDocDate := 0D;
        CreditWriteVechileJson(GetEwayBillIngNo(TransType::"Sales Crd Memo", SalesCreditHeader."No."), SalesCreditHeader."Location GST Reg. No.", VehicleNo, LocationBuff.City, StateBuff.Description, Reason, ReasonRemarks,
                        TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode, VehType);
    end;

    local procedure CreditWriteVechileJson(EwbNo: Text; GSTIN: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; ReasonCode: Text; ReasonRem: Text; TransDocNo: Text; TransDocDate: Text; TransMode: Text; VehType: Text)
    var
        EwbBigInt: BigInteger;
    begin
        /*  JsonTextWriter.WriteStartObject();
          JsonTextWriter.WritePropertyName('access_token');
          JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
          JsonTextWriter.WritePropertyName('userGstin');
          JsonTextWriter.WriteValue(GSTIN);
          JsonTextWriter.WritePropertyName('eway_bill_number');
          JsonTextWriter.WriteValue(EwbNo);
          JsonTextWriter.WritePropertyName('vehicle_number');
          JsonTextWriter.WriteValue(VehicleNo);
          JsonTextWriter.WritePropertyName('vehicle_type');
          JsonTextWriter.WriteValue(VehType);
          JsonTextWriter.WritePropertyName('place_of_consignor');
          JsonTextWriter.WriteValue(FromPlace);
          JsonTextWriter.WritePropertyName('state_of_consignor');
          JsonTextWriter.WriteValue(FromState);
          JsonTextWriter.WritePropertyName('reason_code_for_vehicle_updation');
          JsonTextWriter.WriteValue(ReasonCode);
          JsonTextWriter.WritePropertyName('reason_for_vehicle_updation');
          JsonTextWriter.WriteValue(ReasonRem);
          JsonTextWriter.WritePropertyName('transporter_document_number');
          JsonTextWriter.WriteValue(TransDocNo);
          JsonTextWriter.WritePropertyName('transporter_document_date');
          JsonTextWriter.WriteValue(TransDocDate);
          JsonTextWriter.WritePropertyName('mode_of_transport');
          JsonTextWriter.WriteValue(TransMode);
          JsonTextWriter.WritePropertyName('data_source');
          JsonTextWriter.WriteValue('erp');
          JsonTextWriter.WriteEndObject();*/
        JOVehicleG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOVehicleG.Add('userGstin', GSTIN);
        JOVehicleG.Add('eway_bill_number', EwbNo);
        JOVehicleG.Add('vehicle_number', VehicleNo);
        JOVehicleG.Add('vehicle_type', VehType);
        JOVehicleG.Add('place_of_consignor', FromPlace);
        JOVehicleG.Add('state_of_consignor', FromState);
        JOVehicleG.Add('reason_code_for_vehicle_updation', ReasonCode);
        JOVehicleG.Add('reason_for_vehicle_updation', ReasonRem);
        JOVehicleG.Add('transporter_document_number', TransDocNo);
        JOVehicleG.Add('transporter_document_date', '');
        JOVehicleG.add('mode_of_transport', TransMode);
        JOVehicleG.Add('data_source', 'erp');
    end;

    local procedure CreditCancelEwayJson()
    var
        HeaderTitle: Label 'Enter Cancel Details';
        Title1: Label 'Cancel Reason :';
        Title2: Label 'Cancel Remarks :';
        LocationBuff: Record Location;
        StateBuff: Record State;
        Reason: Text;
        ReasonRemarks: Text;
        TransDocNo: Text;
        TransDocDate: Date;
        Title3: Text;
        RemainingDist: Text;
    begin
        //B2BUPG1.0>>
        //IF NOT OpenWindow(HeaderTitle, Title1, Title2, Title3, Reason, ReasonRemarks, RemainingDist) THEN
        //    EXIT;
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(3);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetCancelTransportData(3, Reason, ReasonRemarks, RemainingDist);
        IF (Reason = '') or (ReasonRemarks = '') THEN
            EXIT;
        //B2BUPG1.0<<
        CreditWriteCancelJson(GetEwayBillIngNo(TransType::"Sales Crd Memo", SalesCreditHeader."No."), SalesCreditHeader."Location GST Reg. No.", Reason, ReasonRemarks);
    end;

    local procedure CreditWriteCancelJson(EWBNo: Text; GSTIN: Text; CancelReason: Text; CancelRemarks: Text)
    begin
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('access_token');
         JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
         JsonTextWriter.WritePropertyName('userGstin');
         JsonTextWriter.WriteValue(GSTIN);
         JsonTextWriter.WritePropertyName('eway_bill_number');
         JsonTextWriter.WriteValue(EWBNo);
         JsonTextWriter.WritePropertyName('reason_of_cancel');
         JsonTextWriter.WriteValue(CancelReason);
         JsonTextWriter.WritePropertyName('cancel_remark');
         JsonTextWriter.WriteValue(CancelRemarks);
         JsonTextWriter.WritePropertyName('data_source');
         JsonTextWriter.WriteValue('erp');
         JsonTextWriter.WriteEndObject();*/
        JOCancelG.add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOCancelG.Add('userGstin', GSTIN);
        JOCancelG.Add('eway_bill_number', EWBNo);
        JOCancelG.Add('reason_of_cancel', CancelReason);
        JOCancelG.Add('cancel_remark', CancelRemarks);
        JOCancelG.Add('data_source', 'erp');
    end;

    procedure CreditRejectEwayJson(RejDocumentNo: Code[20]; var RejEwayBillNo: BigInteger)
    var
        HeaderTitle: Label 'Enter Cancel Details';
        Title1: Label 'Cancel Reason :';
        Title2: Label 'Cancel Remarks :';
        RejectEwayBillNo: Text;

        EWayValidator: Codeunit "E-Way Validator";
        RejectErr: Label 'E-Way bill no must be provided to Reject.';
    begin
        EWayBillingSetup.GET;
        RequestType := RequestType::RejectEway;

        //B2BUPG1.0<<
        //RejectEwayBillNo := Windows.InputBox('Rejecting E-Way Bill No :', '', '', 10, 10);
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(1);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetData(1, RejectEwayBillNo);
        //B2BUPG1.0<<
        IF RejectEwayBillNo = '' THEN
            ERROR(RejectErr);
        EWayValidator.CheckValidations(RejectEwayBillNo, RequestType);//Check Validations

        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('access_token');
         JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
         JsonTextWriter.WritePropertyName('userGstin');
         JsonTextWriter.WriteValue(CompanyInfo."GST Registration No.");
         JsonTextWriter.WritePropertyName('eway_bill_number');
         JsonTextWriter.WriteValue(RejectEwayBillNo);
         JsonTextWriter.WritePropertyName('data_source');
         JsonTextWriter.WriteValue('erp');
         JsonTextWriter.WriteEndObject();
         EVALUATE(RejEwayBillNo, RejectEwayBillNo);
         ExportAsJson(RejDocumentNo, PathSaved);*/
        JORejEWayNoG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JORejEWayNoG.Add('userGstin', CompanyInfo."GST Registration No.");
        EVALUATE(RejEwayBillNo, RejectEwayBillNo);
        JORejEWayNoG.Add('eway_bill_number', RejectEwayBillNo);
        JORejEWayNoG.Add('data_source', 'erp');
    end;

    local procedure CreditUpdateTransportJson()
    var
        TransportID: Text;
        TransportIDError: Label 'Transport Id must have value';
        TransporterName: Text;
        Blank: Text;
        Title1: Label 'Transport ID';
        Title2: Label 'Transport Name';
        Title3: Text;
        HeaderTitle: Label 'Transporter Details';
    begin
        //B2BUPG1.0>>
        //IF NOT OpenWindow(HeaderTitle, Title1, Title2, Title3, TransportID, TransporterName, Blank) THEN
        //    EXIT;
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(3);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetCancelTransportData(3, TransportID, TransporterName, Blank);
        IF (TransportID = '') or (TransporterName = '') THEN
            EXIT;
        //B2BUPG1.0<<
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('access_token');
         JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
         JsonTextWriter.WritePropertyName('userGstin');
         JsonTextWriter.WriteValue(SalesCreditHeader."Location GST Reg. No.");
         JsonTextWriter.WritePropertyName('eway_bill_number');
         JsonTextWriter.WriteValue(GetEwayBillIngNo(TransType::"Sales Shpt", SalesCreditHeader."No."));
         JsonTextWriter.WritePropertyName('transporter_id');
         JsonTextWriter.WriteValue(TransportID);
         JsonTextWriter.WritePropertyName('transporter_name');
         JsonTextWriter.WriteValue(TransporterName);
         JsonTextWriter.WriteEndObject();*/
        JOUpdatetransportIDG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOUpdatetransportIDG.Add('userGstin', SalesCreditHeader."Location GST Reg. No.");
        JOUpdatetransportIDG.Add('eway_bill_number', GetEwayBillIngNo(TransType::"Sales Invoice", SalesCreditHeader."No."));
        JOUpdatetransportIDG.Add('transporter_id', TransportID);
        JOUpdatetransportIDG.Add('transporter_name', TransporterName);
    end;

    local procedure CreditExtendValidityJson()
    var
        LocationBuff: Record Location;
        StateBuff: Record State;
        HeaderTitle: Label 'Enter Details';
        Title1: Label 'Reason :';
        Title2: Label 'Remarks :';
        Title3: Label 'Rem. Dist :';
        Reason: Text;
        ReasonRemarks: Text;
        TransDocNo: Text;
        TransDocDate: Date;
        RemainingDist: Integer;
        RemainingDistText: Text;
        Pin: Integer;
        ExtendErr: Label 'Reason,Remarks and Remaining Distance has to be given to Extend E-Way validity.';
        TransportMethod: Record "Transport Method";
        TransMode: Text;
    begin
        LocationBuff.GET(SalesCreditHeader."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        //B2BUPG1.0>>
        //IF NOT OpenWindow(HeaderTitle, Title1, Title2, Title3, Reason, ReasonRemarks, RemainingDistText) THEN
        //    ERROR(ExtendErr);
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(3);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetCancelTransportData(3, Reason, ReasonRemarks, RemainingDistText);
        IF (Reason = '') or (ReasonRemarks = '') THEN
            ERROR(ExtendErr);
        //B2BUPG1.0<<
        EVALUATE(RemainingDist, RemainingDistText);
        IF SalesCreditHeader."GST Customer Type" = SalesCreditHeader."GST Customer Type"::Export THEN
            EVALUATE(Pin, '999999')
        ELSE
            EVALUATE(Pin, COPYSTR(SalesCreditHeader."Bill-to Post Code", 1, 6));

        IF TransportMethod.GET(SalesCreditHeader."Transport Method") THEN BEGIN
            CASE TransportMethod."Transportation Mode" OF
                TransportMethod."Transportation Mode"::Road:
                    TransMode := 'road';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := 'rail';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := 'air';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := 'ship';
            END;
        END;

        TransDocNo := '';
        TransDocDate := 0D;
        CreditWriteExtendValidityJson(GetEwayBillIngNo(TransType::"Sales Crd Memo", SalesCreditHeader."No."), SalesCreditHeader."Location GST Reg. No.", SalesCreditHeader."Vehicle No.", LocationBuff.City, StateBuff."State Code (GST Reg. No.)",
        RemainingDist, TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode, Reason, ReasonRemarks, Pin, 'T', SalesCreditHeader."Transaction Type",
                      SalesCreditHeader."Sell-to Address", SalesCreditHeader."Sell-to Address", SalesCreditHeader."Sell-to Address");
    end;

    local procedure CreditWriteExtendValidityJson(EwbNo: Text; GSTIN: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; RemainingDist: Integer; TransDocNo: Text; TransDocDate: Text; TransMode: Text; ReasonCode: Text; ReasonRem: Text; FromPincode: Integer; ConsignmentStatus: Text; TransitType: Text; AddressLine1: Text; AddressLine2: Text; AddressLine3: Text)
    begin
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('access_token');
         JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."Access Token 2");
         JsonTextWriter.WritePropertyName('userGstin');
         JsonTextWriter.WriteValue(GSTIN);
         JsonTextWriter.WritePropertyName('eway_bill_number');
         JsonTextWriter.WriteValue(EwbNo);
         JsonTextWriter.WritePropertyName('vehicle_number');
         JsonTextWriter.WriteValue(VehicleNo);
         JsonTextWriter.WritePropertyName('place_of_consignor');
         JsonTextWriter.WriteValue(FromPlace);
         JsonTextWriter.WritePropertyName('state_of_consignor');
         JsonTextWriter.WriteValue(FromState);
         JsonTextWriter.WritePropertyName('remaining_distance');
         JsonTextWriter.WriteValue(RemainingDist);
         JsonTextWriter.WritePropertyName('transporter_document_number');
         JsonTextWriter.WriteValue(TransDocNo);
         JsonTextWriter.WritePropertyName('transporter_document_date');
         JsonTextWriter.WriteValue(TransDocDate);
         JsonTextWriter.WritePropertyName('mode_of_transport');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WritePropertyName('extend_validity_reason');
         JsonTextWriter.WriteValue(ReasonCode);
         JsonTextWriter.WritePropertyName('extend_remarks');
         JsonTextWriter.WriteValue(ReasonRem);
         JsonTextWriter.WritePropertyName('from_pincode');
         JsonTextWriter.WriteValue(FromPincode);
         JsonTextWriter.WritePropertyName('consignment_status');
         JsonTextWriter.WriteValue(ConsignmentStatus);
         JsonTextWriter.WritePropertyName('transit_type');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WritePropertyName('address_line1');
         JsonTextWriter.WriteValue(AddressLine1);
         JsonTextWriter.WritePropertyName('address_line2');
         JsonTextWriter.WriteValue(AddressLine2);
         JsonTextWriter.WritePropertyName('address_line3');
         JsonTextWriter.WriteValue(AddressLine3);
         JsonTextWriter.WriteEndObject();*/
        JOExtendValidityJsonG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOExtendValidityJsonG.Add('userGstin', GSTIN);
        JOExtendValidityJsonG.Add('eway_bill_number', EwbNo);
        JOExtendValidityJsonG.Add('vehicle_number', VehicleNo);
        JOExtendValidityJsonG.Add('place_of_consignor', FromPlace);
        JOExtendValidityJsonG.Add('state_of_consignor', FromState);
        JOExtendValidityJsonG.Add('remaining_distance', RemainingDist);
        JOExtendValidityJsonG.Add('transporter_document_number', TransDocNo);
        JOExtendValidityJsonG.Add('transporter_document_date', TransDocDate);
        JOExtendValidityJsonG.Add('mode_of_transport', '5');
        JOExtendValidityJsonG.Add('extend_validity_reason', ReasonCode);
        JOExtendValidityJsonG.Add('extend_remarks', ReasonRem);
        JOExtendValidityJsonG.add('from_pincode', FromPincode);
        JOExtendValidityJsonG.add('consignment_status', ConsignmentStatus);
        JOExtendValidityJsonG.add('transit_type', 'R');
        JOExtendValidityJsonG.Add('address_line1', AddressLine1);
        JOExtendValidityJsonG.Add('address_line2', AddressLine2);
        JOExtendValidityJsonG.Add('address_line3', AddressLine3);
    end;

    local procedure "-----------------------------------------Purchase CREDIT START------------------------------"()
    begin
    end;

    procedure SetPurchCrdHeader(var PurchCredHdrBuff: Record "Purch. Cr. Memo Hdr."; RequestTypePar: Option Eway,Vehicle,EWayCancel,RejectEway,ExtendValidity,UpdateTrasporter,AccessToken; IsPostingPar: Boolean)
    begin
        PurchCrMemoHdr := PurchCredHdrBuff;
        RequestType := RequestTypePar;
        IsPosting := IsPostingPar;
    end;

    procedure PurchCreditEWayJson()
    var
        LocationBuff: Record Location;
        StateBuff: Record State;
        Gstin: Text;
        Pin: Text;
        Pos: Text;
        Path: Text;
        SubSupplyType: Text;
        SubType: Text;
    begin
        IF PurchCrMemoHdr."GST Vendor Type" = PurchCrMemoHdr."GST Vendor Type"::Import THEN BEGIN
            Gstin := 'URP';
            Pin := '999999';
            SubSupplyType := 'Export';
            SubType := 'Outward';
        END ELSE BEGIN
            Gstin := PurchCrMemoHdr."Vendor GST Reg. No.";
            Pin := COPYSTR(PurchCrMemoHdr."Pay-to Post Code", 1, 6);
            SubSupplyType := 'Supply';
            SubType := 'Outward';
        END;
        IF PurchCrMemoHdr."GST Vendor Type" = PurchCrMemoHdr."GST Vendor Type"::Unregistered THEN
            Gstin := 'URP';
        PurchCreditEWayHeadDetails(PurchCrMemoHdr."Location GST Reg. No.", SubType, SubSupplyType, 'Tax Invoice', PurchCrMemoHdr."No.", FORMAT(PurchCrMemoHdr."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>')); //Header

        //From Details >>

        LocationBuff.GET(PurchCrMemoHdr."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        PurchCreditEwayFromDetails(PurchCrMemoHdr."Location GST Reg. No.", CompanyInfo.Name, LocationBuff.Address, LocationBuff."Address 2", LocationBuff.City, LocationBuff."Post Code", StateBuff.Description, StateBuff.Description);
        //From Details <<

        //To Details >>
        Pos := PurchCreditGetEwayPos(PurchCrMemoHdr."No.");
        PurchCreditEwayToDetails(Gstin, PurchCrMemoHdr."Pay-to Name", PurchCrMemoHdr."Pay-to Address", PurchCrMemoHdr."Pay-to Address 2", PurchCrMemoHdr."Pay-to City", Pin, Pos, Pos);
        //To Details <<

        PurchCreditGetGSTCompRate(PurchCrMemoHdr."No.", 0, JOItemsG);//Update GST calculations
        PurchCreditReadEwbDtls();//Update Transport Details

        PurchCreditReadItemList();
        //JsonTextWriter.WriteEndObject;
        //ExportAsJson("No.", Path);
    end;

    local procedure PurchCreditEWayHeadDetails(GstIn: Text; SupplyType: Text; SupplySubType: Text; Doctype: Text; DocNo: Text; DocDate: Text)
    begin
        /*  JsonTextWriter.WriteStartObject;
          JsonTextWriter.WritePropertyName('access_token');
          JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
          JsonTextWriter.WritePropertyName('userGstin');
          JsonTextWriter.WriteValue(GstIn);
          JsonTextWriter.WritePropertyName('supply_type');
          JsonTextWriter.WriteValue(SupplyType);
          JsonTextWriter.WritePropertyName('sub_supply_type');
          JsonTextWriter.WriteValue(SupplySubType);
          JsonTextWriter.WritePropertyName('sub_supply_description');
          JsonTextWriter.WriteValue('');
          JsonTextWriter.WritePropertyName('document_type');
          JsonTextWriter.WriteValue(Doctype);
          JsonTextWriter.WritePropertyName('document_number');
          JsonTextWriter.WriteValue(DocNo);
          JsonTextWriter.WritePropertyName('document_date');
          JsonTextWriter.WriteValue(DocDate);*/
        JOsupplyTypeG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOsupplyTypeG.Add('supply_type', SupplyType);
        JOsupplyTypeG.Add('sub_supply_type', SupplySubType);
        if SupplySubType = '3' then begin
            JOsupplyTypeG.Add('sub_supply_description', '');
        end;
        JOsupplyTypeG.Add('document_type', Doctype);
        JOsupplyTypeG.Add('document_number', DocNo);
        JOsupplyTypeG.Add('document_date', DocDate);
    end;

    procedure PurchCreditEwayFromDetails(FromGstin: Text; FromTrdName: Text; FromAdd1: Text; FromAdd2: Text; FromPlace: Text; FromPinCode: Text; ActFromStateCode: Text; FromStateCode: Text): Boolean
    var
        FromPinCodeInt: Integer;
        ActFromStateCodeInt: Integer;
        FromStateCodeInt: Integer;
    begin
        IF FromPinCode <> '' THEN
            EVALUATE(FromPinCodeInt, FromPinCode);
        /* JsonTextWriter.WritePropertyName('gstin_of_consignor');
         JsonTextWriter.WriteValue(FromGstin);
         JsonTextWriter.WritePropertyName('legal_name_of_consignor');
         JsonTextWriter.WriteValue(FromTrdName);
         JsonTextWriter.WritePropertyName('address1_of_consignor');
         JsonTextWriter.WriteValue(FromAdd1);
         JsonTextWriter.WritePropertyName('address2_of_consignor');
         JsonTextWriter.WriteValue(FromAdd2);
         JsonTextWriter.WritePropertyName('place_of_consignor');
         JsonTextWriter.WriteValue(FromPlace);
         JsonTextWriter.WritePropertyName('pincode_of_consignor');
         JsonTextWriter.WriteValue(FromPinCodeInt);
         JsonTextWriter.WritePropertyName('state_of_consignor');
         JsonTextWriter.WriteValue(FromStateCode);
         JsonTextWriter.WritePropertyName('actual_from_state_name');
         JsonTextWriter.WriteValue(ActFromStateCode);*/
        JOsupplyTypeG.Add('gstin_of_consignor', FromGstin);
        JOsupplyTypeG.Add('legal_name_of_consignor', FromTrdName);
        JOsupplyTypeG.Add('address1_of_consignor', FromAdd1);
        JOsupplyTypeG.Add('address2_of_consignor', FromAdd2);
        JOsupplyTypeG.Add('place_of_consignor', FromPlace);
        JOsupplyTypeG.Add('pincode_of_consignor', FromPinCodeInt);
        JOsupplyTypeG.Add('state_of_consignor', FromStateCodeInt);
        JOsupplyTypeG.Add('actual_from_state_name', ActFromStateCode);

    end;

    procedure PurchCreditEwayToDetails(ToGstin: Text; ToTrdName: Text; ToAdd1: Text; ToAdd2: Text; ToPlace: Text; ToPinCode: Text; ActFromStateCode: Text; ToStateCode: Text): Boolean
    var
        ToPinCodeInt: Integer;
        ActToStateCodeInt: Integer;
        ToStateCodeInt: Integer;
    begin
        IF ToPinCode <> '' THEN
            EVALUATE(ToPinCodeInt, ToPinCode);
        /* JsonTextWriter.WritePropertyName('gstin_of_consignee');
         JsonTextWriter.WriteValue(ToGstin);
         JsonTextWriter.WritePropertyName('legal_name_of_consignee');
         JsonTextWriter.WriteValue(ToTrdName);
         JsonTextWriter.WritePropertyName('address1_of_consignee');
         JsonTextWriter.WriteValue(ToAdd1);
         JsonTextWriter.WritePropertyName('address2_of_consignee');
         JsonTextWriter.WriteValue(ToAdd2);
         JsonTextWriter.WritePropertyName('place_of_consignee');
         JsonTextWriter.WriteValue(ToPlace);
         JsonTextWriter.WritePropertyName('pincode_of_consignee');
         JsonTextWriter.WriteValue(ToPinCodeInt);
         JsonTextWriter.WritePropertyName('state_of_supply');*/
        JOsupplyTypeG.Add('gstin_of_consignee', ToGstin);
        JOsupplyTypeG.Add('legal_name_of_consignee', ToTrdName);
        JOsupplyTypeG.Add('address1_of_consignee', ToAdd1);
        JOsupplyTypeG.Add('address2_of_consignee', ToAdd2);
        JOsupplyTypeG.Add('place_of_consignee', ToPlace);
        JOsupplyTypeG.Add('pincode_of_consignee', ToPinCodeInt);
        //Import >>
        IF (PurchCrMemoHdr."GST Vendor Type" IN [PurchCrMemoHdr."GST Vendor Type"::Import, PurchCrMemoHdr."GST Vendor Type"::Exempted,
                                                  PurchCrMemoHdr."GST Vendor Type"::SEZ]) THEN
            // JsonTextWriter.WriteValue('OTHER TERRITORY')
            JOsupplyTypeG.Add('state_of_supply', 'OTHER TERRITORY')

        ELSE
            JOsupplyTypeG.Add('state_of_supply', ToStateCode);
        //  JsonTextWriter.WriteValue(ToStateCode);


        //  JsonTextWriter.WritePropertyName('actual_to_state_name');
        IF (PurchCrMemoHdr."GST Vendor Type" IN [PurchCrMemoHdr."GST Vendor Type"::Import, PurchCrMemoHdr."GST Vendor Type"::Exempted,
                                                  PurchCrMemoHdr."GST Vendor Type"::SEZ]) THEN
            //  JsonTextWriter.WriteValue('OTHER TERRITORY')
            JOsupplyTypeG.Add('actual_to_state_name', 'OTHER TERRITORY')

        ELSE
            JOsupplyTypeG.Add('actual_to_state_name', ActFromStateCode);
        JOsupplyTypeG.Add('transaction_type', SalesInvoiceHeader."Transaction Type");
        JOsupplyTypeG.Add('other_value', '');
        //  JsonTextWriter.WriteValue(ActFromStateCode);
        //Import <<

        /* JsonTextWriter.WritePropertyName('transaction_type');
         JsonTextWriter.WriteValue(FORMAT(PurchCrMemoHdr."Transaction Type"));
         JsonTextWriter.WritePropertyName('other_value');
         JsonTextWriter.WriteValue('');*/

    end;

    local procedure PurchCreditGetEwayPos(No: Code[20]): Text
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        StateBuff: Record State;
    begin
        PurchCrMemoLine.SETRANGE("Document No.", No);
        PurchCrMemoLine.SETFILTER("No.", '<>%1', '');//BugFix
        PurchCrMemoLine.SETRANGE(Exempted, FALSE);
        IF PurchCrMemoLine.FINDFIRST THEN
            IF PurchCrMemoLine."Order Address Code" <> '' THEN BEGIN
                StateBuff.GET(PurchCrMemoLine."Order Address Code");
                EXIT(StateBuff.Description);
            END ELSE BEGIN
                StateBuff.GET(PurchCrMemoHdr."Location State Code");
                EXIT(StateBuff.Description);
            END;
    end;

    local procedure PurchCreditUpdateEwayCalculations(TotalValue: Decimal; CgstValue: Decimal; SgstValue: Decimal; IgstValue: Decimal; CessValue: Decimal)
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        TotalInvValue: Decimal;
    begin
        PurchCrMemoLine.RESET;
        PurchCrMemoLine.SETRANGE("Document No.", PurchCrMemoHdr."No.");
        PurchCrMemoLine.SETRANGE(Type, PurchCrMemoLine.Type::Item);
        PurchCrMemoLine.SETRANGE(Exempted, FALSE);
        IF PurchCrMemoLine.FINDSET THEN BEGIN
            REPEAT
                TotalInvValue += (PurchCrMemoLine.Quantity * PurchCrMemoLine."Direct Unit Cost") -
                                 ((PurchCrMemoLine.Quantity * PurchCrMemoLine."Direct Unit Cost") * PurchCrMemoLine."Line Discount %" / 100) - PurchCrMemoLine."Inv. Discount Amount";
            UNTIL PurchCrMemoLine.NEXT = 0;
        END;

        IF PurchCrMemoHdr."Currency Code" <> '' THEN BEGIN
            TotalInvValue := (1 / PurchCrMemoHdr."Currency Factor") * TotalInvValue;
        END;
        TotalValue := CgstValue + SgstValue + IgstValue + CessValue;
        /*  JsonTextWriter.WritePropertyName('total_invoice_value');
          JsonTextWriter.WriteValue(TotalInvValue + TotalValue);
          JsonTextWriter.WritePropertyName('taxable_amount');
          JsonTextWriter.WriteValue(ABS(TotalInvValue));
          JsonTextWriter.WritePropertyName('cgst_amount');
          JsonTextWriter.WriteValue(CgstValue);
          JsonTextWriter.WritePropertyName('sgst_amount');
          JsonTextWriter.WriteValue(SgstValue);
          JsonTextWriter.WritePropertyName('igst_amount');
          JsonTextWriter.WriteValue(IgstValue);
          JsonTextWriter.WritePropertyName('cess_amount');
          JsonTextWriter.WriteValue(CessValue);
          JsonTextWriter.WritePropertyName('cess_nonadvol_value');
          JsonTextWriter.WriteValue('');*/
        JOsupplyTypeG.Add('total_invoice_value', TotalInvValue + TotalValue);
        JOsupplyTypeG.Add('taxable_amount', ABS(TotalInvValue));
        JOsupplyTypeG.Add('cgst_amount', CgstValue);
        JOsupplyTypeG.Add('sgst_amount', SgstValue);
        JOsupplyTypeG.Add('igst_amount', IgstValue);
        JOsupplyTypeG.Add('cess_amount', CessValue);
        JOsupplyTypeG.Add('cess_nonadvol_value', '');
    end;

    local procedure PurchCreditGetGSTCompRate(DocNo: Code[20]; LineNo: Integer; Var JSONItemL: JsonObject)
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTComponent: Record "Tax Component";
        CurrExchRate: Record "Currency Exchange Rate";
        CurrencyCode: Code[10];
        CurrencyFactor: Decimal;
        CgstAmt: Decimal;
        SgstAmt: Decimal;
        IgstAmt: Decimal;
        CesRt: Decimal;
        CessAmt: Decimal;
        CesNonAdvlAmt: Decimal;
        StateCesRt: Decimal;
        StateCesAmt: Decimal;
        StateCesNonAdvlAmt: Decimal;
        CgstRt: Decimal;
        SgstRt: Decimal;
        IgstRt: Decimal;
        CesAdvlAmt: Decimal;
        TotalValue: Decimal;
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        DetailedGSTLedgerEntry.RESET;
        DetailedGSTLedgerEntry.SETRANGE("Document No.", DocNo);
        DetailedGSTLedgerEntry.SETRANGE(Type, DetailedGSTLedgerEntry.Type::Item);
        IF LineNo <> 0 THEN
            DetailedGSTLedgerEntry.SETRANGE("Document Line No.", LineNo);

        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'CGST');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS("GST Amount");
            CgstAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            CgstRt := ABS(DetailedGSTLedgerEntry."GST %");
        END ELSE BEGIN
            CgstAmt := 0;
            CgstRt := 0;
        END;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'SGST');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS("GST Amount");
            SgstAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            SgstRt := ABS(DetailedGSTLedgerEntry."GST %");
        END ELSE BEGIN
            SgstAmt := 0;
            SgstRt := 0
        END;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'IGST');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS("GST Amount");
            IgstAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            IgstRt := ABS(DetailedGSTLedgerEntry."GST %");
        END ELSE BEGIN
            IgstAmt := 0;
            IgstRt := 0;
        END;
        CesRt := 0;
        CessAmt := 0;
        CesNonAdvlAmt := 0;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'CESS');
        IF DetailedGSTLedgerEntry.FINDSET THEN
            IF DetailedGSTLedgerEntry."GST %" > 0 THEN BEGIN
                DetailedGSTLedgerEntry.CALCSUMS("GST Amount");
                CesRt := DetailedGSTLedgerEntry."GST %";
                CessAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            END ELSE
                CesNonAdvlAmt := ABS(DetailedGSTLedgerEntry."GST Amount");

        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'INTERCESS');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS("GST Amount");
            CesRt := DetailedGSTLedgerEntry."GST %";
            CessAmt := DetailedGSTLedgerEntry."GST Amount";
        END;

        StateCesRt := 0;
        StateCesAmt := 0;
        StateCesNonAdvlAmt := 0;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code");
        IF DetailedGSTLedgerEntry.FINDSET THEN
            REPEAT
                IF NOT (DetailedGSTLedgerEntry."GST Component Code" IN ['CGST', 'SGST', 'IGST', 'CESS', 'INTERCESS']) THEN
                    IF GSTComponent.GET(DetailedGSTLedgerEntry."GST Component Code") THEN
                        IF DetailedGSTLedgerEntry."GST %" > 0 THEN BEGIN
                            StateCesRt := DetailedGSTLedgerEntry."GST %";
                            StateCesAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
                        END ELSE
                            StateCesNonAdvlAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            UNTIL DetailedGSTLedgerEntry.NEXT = 0;

        TotalValue := DetailedGSTLedgerEntry."GST Base Amount";

        IF PurchCrMemoHdr."Currency Code" <> '' THEN BEGIN
            CurrencyCode := PurchCrMemoHdr."Currency Code";
            CurrencyFactor := PurchCrMemoHdr."Currency Factor";
            /*
            IF IgstAmt <> 0 THEN
              IgstAmt := ROUND((1/SalesCreditHeader."Currency Factor")*IgstAmt,0.01,'=');
            IF CgstAmt <> 0 THEN
              CgstAmt := ROUND((1/SalesCreditHeader."Currency Factor")*CgstAmt,0.01,'=');
            IF SgstAmt <> 0 THEN
              SgstAmt := ROUND((1/SalesCreditHeader."Currency Factor")*SgstAmt,0.01,'=');
            IF CessAmt <> 0 THEN
              CessAmt := ROUND((1/SalesCreditHeader."Currency Factor")*CessAmt,0.01,'=');
            IF CesNonAdvlAmt <> 0 THEN
              CesNonAdvlAmt := ROUND((1/SalesCreditHeader."Currency Factor")*CesNonAdvlAmt,0.01,'=');
            IF StateCesAmt <> 0 THEN
              StateCesAmt := ROUND((1/SalesCreditHeader."Currency Factor")*StateCesAmt,0.01,'=');
            IF StateCesNonAdvlAmt <> 0 THEN
              StateCesNonAdvlAmt := ROUND((1/SalesCreditHeader."Currency Factor")*StateCesNonAdvlAmt,0.01,'=');*/
            IF TotalValue <> 0 THEN
                TotalValue := ROUND((1 / PurchCrMemoHdr."Currency Factor") * TotalValue, 0.01, '=');
        END;
        IF LineNo = 0 THEN
            PurchCreditUpdateEwayCalculations(TotalValue, CgstAmt, SgstAmt, IgstAmt, CessAmt)//Header Json
        ELSE BEGIN
            /* JsonTextWriter.WritePropertyName('cgst_rate');
             JsonTextWriter.WriteValue(CgstRt);
             JsonTextWriter.WritePropertyName('sgst_rate');
             JsonTextWriter.WriteValue(SgstRt);
             JsonTextWriter.WritePropertyName('igst_rate');
             JsonTextWriter.WriteValue(IgstRt);
             JsonTextWriter.WritePropertyName('cess_rate');
             JsonTextWriter.WriteValue(CesRt);
             PurchCrMemoLine.GET(DocNo, LineNo);
             JsonTextWriter.WritePropertyName('quantity');
             JsonTextWriter.WriteValue(PurchCrMemoLine.Quantity);
             JsonTextWriter.WritePropertyName('cessNonAdvolValue');
             JsonTextWriter.WriteValue(CesNonAdvlAmt);*/
            JSONItemL.Add('cgst_rate', CgstRt);
            JSONItemL.Add('sgst_rate', SgstRt);
            JSONItemL.Add('igst_rate', IgstRt);
            JSONItemL.Add('cess_rate', CesRt);
            PurchCrMemoLine.GET(DocNo, LineNo);
            JSONItemL.Add('quantity', PurchCrMemoLine.Quantity);
            JSONItemL.Add('cessNonAdvolValue', CesNonAdvlAmt);
        END;

    end;

    local procedure PurchCreditReadEwbDtls()
    var
        TransId: Text[15];
        TransName: Text[100];
        TransMode: Text[20];
        Distance: Text[4];
        TransDocNo: Text[15];
        TransDocDt: Text[10];
        VehNo: Text[20];
        VehType: Text[20];
        TransportMethod: Record "Transport Method";
        DistanceTxt: Text;
        TransactionType: Text;
    begin
        TransId := '';//Transit/GSTIN
        TransactionType := PurchCrMemoHdr."Transaction Type";
        IF TransportMethod.GET(PurchCrMemoHdr."Transport Method") THEN BEGIN
            TransName := '';
            CASE TransportMethod."Transportation Mode" OF
                TransportMethod."Transportation Mode"::Road:
                    TransMode := 'road';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := 'rail';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := 'air';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := 'ship';
            END;
        END;
        IF PurchCrMemoHdr."Distance (Km)" <> 0 THEN BEGIN
            DistanceTxt := DELCHR(FORMAT(ROUND(PurchCrMemoHdr."Distance (Km)", 1, '=')), '=', ',');

            IF STRLEN(DistanceTxt) > 4 THEN
                Distance := COPYSTR(DistanceTxt, 1, 4)
            ELSE
                Distance := DistanceTxt;
        END ELSE
            Distance := '';
        TransDocNo := '';//Trnasport Document No.
        TransDocDt := '';//Transport Doc Date
        VehNo := PurchCrMemoHdr."Vehicle No.";
        CASE PurchCrMemoHdr."Vehicle Type" OF
            PurchCrMemoHdr."Vehicle Type"::" ":
                VehType := '';
            PurchCrMemoHdr."Vehicle Type"::ODC:
                VehType := 'ODC';
            PurchCrMemoHdr."Vehicle Type"::Regular:
                VehType := 'Regular';
        END;


        PurchCreditWriteEwbDtls(TransId, TransName, TransMode, Distance, TransDocNo, TransDocDt, VehNo, VehType, TransactionType);
    end;

    local procedure PurchCreditWriteEwbDtls(TransId: Text[15]; TransName: Text[100]; TransMode: Text[20]; Distance: Text[4]; TransDocNo: Text[15]; TransDocDt: Text[10]; VehNo: Text[20]; VehType: Text[20]; TransactionType: Text)
    begin
        /* JsonTextWriter.WritePropertyName('transporter_id');
         JsonTextWriter.WriteValue(TransId);
         JsonTextWriter.WritePropertyName('transporter_name');
         JsonTextWriter.WriteValue(TransName);
         JsonTextWriter.WritePropertyName('transporter_document_number');
         JsonTextWriter.WriteValue(TransDocNo);
         JsonTextWriter.WritePropertyName('transporter_document_date');
         JsonTextWriter.WriteValue(TransDocDt);
         JsonTextWriter.WritePropertyName('transportation_mode');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WritePropertyName('transportation_distance');
         JsonTextWriter.WriteValue(Distance);
         JsonTextWriter.WritePropertyName('vehicle_number');
         JsonTextWriter.WriteValue(VehNo);
         JsonTextWriter.WritePropertyName('vehicle_type');
         JsonTextWriter.WriteValue(VehType);
         JsonTextWriter.WritePropertyName('generate_status');
         JsonTextWriter.WriteValue('1');
         JsonTextWriter.WritePropertyName('data_source');
         JsonTextWriter.WriteValue('erp');
         JsonTextWriter.WritePropertyName('user_ref');
         JsonTextWriter.WriteValue(PurchCrMemoHdr."No.");
         JsonTextWriter.WritePropertyName('location_code');
         JsonTextWriter.WriteValue(PurchCrMemoHdr."Location Code");
         JsonTextWriter.WritePropertyName('eway_bill_status');
         JsonTextWriter.WriteValue('ABC');
         JsonTextWriter.WritePropertyName('auto_print');
         JsonTextWriter.WriteValue('Y');
         //JsonTextWriter.WritePropertyName('EWB_print_type');
         //JsonTextWriter.WriteValue('d');
         JsonTextWriter.WritePropertyName('email');
         JsonTextWriter.WriteValue(CompanyInfo."E-Mail");*/
        JOsupplyTypeG.Add('transporterId', TransId);
        JOsupplyTypeG.Add('transporterName', TransName);
        JOsupplyTypeG.Add('transDocNo', TransDocNo);
        JOsupplyTypeG.Add('transMode', TransMode);
        JOsupplyTypeG.Add('transDistance', Distance);
        JOsupplyTypeG.Add('transDocDate', TransDocDt);
        JOsupplyTypeG.Add('vehicleNo', VehNo);
        JOsupplyTypeG.Add('vehicleType', VehType);
        JOsupplyTypeG.Add('generate_status', '1');
        JOsupplyTypeG.Add('data_source', 'erp');
        JOsupplyTypeG.Add('user_ref', SalesInvoiceHeader."No.");
        JOsupplyTypeG.Add('location_code', SalesInvoiceHeader."Location Code");
        JOsupplyTypeG.Add('eway_bill_status', 'ABC');
        JOsupplyTypeG.Add('auto_print', 'Y');
        JOsupplyTypeG.Add('EWB_print_type', 'd');
        JOsupplyTypeG.Add('email', CompanyInfo."E-Mail");
    end;

    local procedure PurchCreditReadItemList()
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        SalesLinesErr: Label 'E-Invoice allowes only 1000 lines per Invoice. Curent transaction is having %1 lines.', Comment = '%1 = Sales Lines count';
        HSNInt: Integer;
        Uom: Record "Unit of Measure";
    begin
        PurchCrMemoLine.RESET;
        PurchCrMemoLine.SETRANGE("Document No.", PurchCrMemoHdr."No.");
        PurchCrMemoLine.SETFILTER("No.", '<>%1', '');
        PurchCrMemoLine.SETRANGE(Type, PurchCrMemoLine.Type::Item);
        PurchCrMemoLine.SETFILTER(Quantity, '>%1', 0);
        PurchCrMemoLine.SETRANGE(Exempted, FALSE);
        IF PurchCrMemoLine.FINDSET THEN BEGIN
            IF PurchCrMemoLine.COUNT > 1000 THEN
                ERROR(SalesLinesErr, PurchCrMemoLine.COUNT);
            // JsonTextWriter.WritePropertyName('itemList');
            //  JsonTextWriter.WriteStartArray;
            REPEAT
                EVALUATE(HSNInt, PurchCrMemoLine."HSN/SAC Code");
                /*    JsonTextWriter.WriteStartObject;
                    JsonTextWriter.WritePropertyName('product_name');
                    JsonTextWriter.WriteValue(PurchCrMemoLine."No.");
                    JsonTextWriter.WritePropertyName('product_description');
                    JsonTextWriter.WriteValue(PurchCrMemoLine.Description);
                    JsonTextWriter.WritePropertyName('hsn_code');
                    JsonTextWriter.WriteValue(HSNInt);
                    Uom.GET(PurchCrMemoLine."Unit of Measure Code");
                    JsonTextWriter.WritePropertyName('unit_of_product');
                    JsonTextWriter.WriteValue(Uom."International Standard Code");


                    PurchCreditGetGSTCompRate(PurchCrMemoHdr."No.", PurchCrMemoLine."Line No.");

                    JsonTextWriter.WritePropertyName('taxableAmount');
                    IF SalesCreditHeader."Currency Code" <> '' THEN
                        JsonTextWriter.WriteValue((1 / PurchCrMemoHdr."Currency Factor") * PurchCrMemoLine."Line Amount")
                    ELSE
                        JsonTextWriter.WriteValue(PurchCrMemoLine."Line Amount");
                    JsonTextWriter.WriteEndObject;*/
                Uom.GET(PurchCrMemoLine."Unit of Measure Code");
                JOItemsG.Add('product_name', PurchCrMemoLine."No.");
                JOItemsG.Add('product_description', PurchCrMemoLine.Description);
                JOItemsG.Add('hsn_code', HSNInt);
                JOItemsG.Add('unit_of_product', Uom."International Standard Code");
                JOItemsG.Add('quantity', PurchCrMemoLine.Quantity);

                PurchCreditGetGSTCompRate(PurchCrMemoHdr."No.", PurchCrMemoLine."Line No.", JOItemsG);
                IF PurchCrMemoHdr."Currency Code" <> '' THEN
                    JOItemsG.Add('taxableAmount', ((1 / PurchCrMemoHdr."Currency Factor") * PurchCrMemoLine."Line Amount"))
                else
                    JOItemsG.Add('taxableAmount', PurchCrMemoLine."Line Amount");
                JArrayItemsG.Add(JOItemsG);
            UNTIL PurchCrMemoLine.NEXT = 0;
            JOsupplyTypeG.Add('itemList', JArrayItemsG);
            //JsonTextWriter.WriteEndArray;
        END;
    end;

    procedure PurchCreditVechileJson()
    var
        LocationBuff: Record Location;
        StateBuff: Record State;
        Reason: Text;
        ReasonRemarks: Text;
        TransDocNo: Text;
        TransDocDate: Date;
        HeaderTitle: Label 'Enter Details';
        Title3: Label 'Vehicle No :';
        VehicleNo: Text;
        TransMode: Text;
        TransportMethod: Record "Transport Method";
        Title1: Text;
        Title2: Text;

        VehType: Text;
    begin
        LocationBuff.GET(PurchCrMemoHdr."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        IF IsPosting THEN BEGIN
            Reason := 'Others';//EWayBillingSetup."Vehicle Reason";
            ReasonRemarks := EWayBillingSetup."Vehicle Remarks";
            VehicleNo := PurchCrMemoHdr."Vehicle No.";
        END ELSE BEGIN
            Reason := 'Others';//EWayBillingSetup."Vehicle Reason";
            ReasonRemarks := EWayBillingSetup."Vehicle Remarks";
            //B2BUPG1.0>>
            // VehicleNo := Windows.InputBox(Title3, '', '', 10, 10);
            Clear(EWayUpdate);
            Commit();
            EWayUpdate.SetData(0);
            if EWayUpdate.RunModal() = Action::Yes then
                EWayUpdate.GetData(0, VehicleNo);
            //B2BUPG1.0<<
            IF VehicleNo = ' ' THEN
                EXIT;
            //"Old Vehicle No" := "Vehicle No.";
            PurchCrMemoHdr."Vehicle No." := VehicleNo;
            PurchCrMemoHdr.MODIFY;
        END;
        CASE PurchCrMemoHdr."Vehicle Type" OF
            PurchCrMemoHdr."Vehicle Type"::" ":
                VehType := '';
            PurchCrMemoHdr."Vehicle Type"::ODC:
                VehType := 'odc';
            PurchCrMemoHdr."Vehicle Type"::Regular:
                VehType := 'Regular';
        END;
        IF TransportMethod.GET(PurchCrMemoHdr."Transport Method") THEN BEGIN
            CASE TransportMethod."Transportation Mode" OF
                TransportMethod."Transportation Mode"::Road:
                    TransMode := 'road';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := 'rail';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := 'air';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := 'ship';
            END;
        END;
        TransDocNo := '';
        TransDocDate := 0D;
        PurchCreditWriteVechileJson(GetEwayBillIngNo(TransType::"Purch. Crd Memo", PurchCrMemoHdr."No."), PurchCrMemoHdr."Location GST Reg. No.", VehicleNo, LocationBuff.City, StateBuff.Description, Reason, ReasonRemarks,
                        TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode, VehType);
    end;

    local procedure PurchCreditWriteVechileJson(EwbNo: Text; GSTIN: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; ReasonCode: Text; ReasonRem: Text; TransDocNo: Text; TransDocDate: Text; TransMode: Text; VehType: Text)
    var
        EwbBigInt: BigInteger;
    begin
        /*  JsonTextWriter.WriteStartObject();
          JsonTextWriter.WritePropertyName('access_token');
          JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
          JsonTextWriter.WritePropertyName('userGstin');
          JsonTextWriter.WriteValue(GSTIN);
          JsonTextWriter.WritePropertyName('eway_bill_number');
          JsonTextWriter.WriteValue(EwbNo);
          JsonTextWriter.WritePropertyName('vehicle_number');
          JsonTextWriter.WriteValue(VehicleNo);
          JsonTextWriter.WritePropertyName('vehicle_type');
          JsonTextWriter.WriteValue(VehType);
          JsonTextWriter.WritePropertyName('place_of_consignor');
          JsonTextWriter.WriteValue(FromPlace);
          JsonTextWriter.WritePropertyName('state_of_consignor');
          JsonTextWriter.WriteValue(FromState);
          JsonTextWriter.WritePropertyName('reason_code_for_vehicle_updation');
          JsonTextWriter.WriteValue(ReasonCode);
          JsonTextWriter.WritePropertyName('reason_for_vehicle_updation');
          JsonTextWriter.WriteValue(ReasonRem);
          JsonTextWriter.WritePropertyName('transporter_document_number');
          JsonTextWriter.WriteValue(TransDocNo);
          JsonTextWriter.WritePropertyName('transporter_document_date');
          JsonTextWriter.WriteValue(TransDocDate);
          JsonTextWriter.WritePropertyName('mode_of_transport');
          JsonTextWriter.WriteValue(TransMode);
          JsonTextWriter.WritePropertyName('data_source');
          JsonTextWriter.WriteValue('erp');
          JsonTextWriter.WriteEndObject();*/
        JOVehicleG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOVehicleG.Add('userGstin', GSTIN);
        JOVehicleG.Add('eway_bill_number', EwbNo);
        JOVehicleG.Add('vehicle_number', VehicleNo);
        JOVehicleG.Add('vehicle_type', VehType);
        JOVehicleG.Add('place_of_consignor', FromPlace);
        JOVehicleG.Add('state_of_consignor', FromState);
        JOVehicleG.Add('reason_code_for_vehicle_updation', ReasonCode);
        JOVehicleG.Add('reason_for_vehicle_updation', ReasonRem);
        JOVehicleG.Add('transporter_document_number', TransDocNo);
        JOVehicleG.Add('transporter_document_date', '');
        JOVehicleG.add('mode_of_transport', TransMode);
        JOVehicleG.Add('data_source', 'erp');
    end;

    local procedure PurchCreditCancelEwayJson()
    var
        HeaderTitle: Label 'Enter Cancel Details';
        Title1: Label 'Cancel Reason :';
        Title2: Label 'Cancel Remarks :';
        LocationBuff: Record Location;
        StateBuff: Record State;
        Reason: Text;
        ReasonRemarks: Text;
        TransDocNo: Text;
        TransDocDate: Date;
        Title3: Text;
        RemainingDist: Text;
    begin
        //B2BUPG1.0>>
        //IF NOT OpenWindow(HeaderTitle, Title1, Title2, Title3, Reason, ReasonRemarks, RemainingDist) THEN
        //    EXIT;
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(3);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetCancelTransportData(3, Reason, ReasonRemarks, RemainingDist);
        IF (Reason = '') or (ReasonRemarks = '') THEN
            EXIT;
        //B2BUPG1.0<<
        PurchCreditWriteCancelJson(GetEwayBillIngNo(TransType::"Purch. Crd Memo", PurchCrMemoHdr."No."), PurchCrMemoHdr."Location GST Reg. No.", Reason, ReasonRemarks);
    end;

    local procedure PurchCreditWriteCancelJson(EWBNo: Text; GSTIN: Text; CancelReason: Text; CancelRemarks: Text)
    begin
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('access_token');
         JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
         JsonTextWriter.WritePropertyName('userGstin');
         JsonTextWriter.WriteValue(GSTIN);
         JsonTextWriter.WritePropertyName('eway_bill_number');
         JsonTextWriter.WriteValue(EWBNo);
         JsonTextWriter.WritePropertyName('reason_of_cancel');
         JsonTextWriter.WriteValue(CancelReason);
         JsonTextWriter.WritePropertyName('cancel_remark');
         JsonTextWriter.WriteValue(CancelRemarks);
         JsonTextWriter.WritePropertyName('data_source');
         JsonTextWriter.WriteValue('erp');
         JsonTextWriter.WriteEndObject();*/
        JOCancelG.add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOCancelG.Add('userGstin', GSTIN);
        JOCancelG.Add('eway_bill_number', EWBNo);
        JOCancelG.Add('reason_of_cancel', CancelReason);
        JOCancelG.Add('cancel_remark', CancelRemarks);
        JOCancelG.Add('data_source', 'erp');

    end;

    procedure PurchCreditRejectEwayJson(RejDocumentNo: Code[20]; var RejEwayBillNo: BigInteger)
    var
        HeaderTitle: Label 'Enter Cancel Details';
        Title1: Label 'Cancel Reason :';
        Title2: Label 'Cancel Remarks :';
        RejectEwayBillNo: Text;

        EWayValidator: Codeunit "E-Way Validator";
        RejectErr: Label 'E-Way bill no must be provided to Reject.';
    begin
        EWayBillingSetup.GET;
        RequestType := RequestType::RejectEway;

        //B2BUPG1.0<<
        //RejectEwayBillNo := Windows.InputBox('Rejecting E-Way Bill No :', '', '', 10, 10);
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(1);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetData(1, RejectEwayBillNo);
        //B2BUPG1.0<<
        IF RejectEwayBillNo = '' THEN
            ERROR(RejectErr);
        EWayValidator.CheckValidations(RejectEwayBillNo, RequestType);//Check Validations

        /*JsonTextWriter.WriteStartObject();
        JsonTextWriter.WritePropertyName('access_token');
        JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JsonTextWriter.WritePropertyName('userGstin');
        JsonTextWriter.WriteValue(CompanyInfo."GST Registration No.");
        JsonTextWriter.WritePropertyName('eway_bill_number');
        JsonTextWriter.WriteValue(RejectEwayBillNo);
        JsonTextWriter.WritePropertyName('data_source');
        JsonTextWriter.WriteValue('erp');
        JsonTextWriter.WriteEndObject();
        EVALUATE(RejEwayBillNo, RejectEwayBillNo);
        ExportAsJson(RejDocumentNo, PathSaved);*/
        JORejEWayNoG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JORejEWayNoG.Add('userGstin', CompanyInfo."GST Registration No.");
        EVALUATE(RejEwayBillNo, RejectEwayBillNo);
        JORejEWayNoG.Add('eway_bill_number', RejectEwayBillNo);
        JORejEWayNoG.Add('data_source', 'erp');
    end;

    local procedure PurchCreditUpdateTransportJson()
    var
        TransportID: Text;

        TransportIDError: Label 'Transport Id must have value';
        TransporterName: Text;
        Blank: Text;
        Title1: Label 'Transport ID';
        Title2: Label 'Transport Name';
        Title3: Text;
        HeaderTitle: Label 'Transporter Details';
    begin
        //B2BUPG1.0>>
        //IF NOT OpenWindow(HeaderTitle, Title1, Title2, Title3, TransportID, TransporterName, Blank) THEN
        //    EXIT;
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(3);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetCancelTransportData(3, TransportID, TransporterName, Blank);
        IF (TransportID = '') or (TransporterName = '') THEN
            EXIT;
        //B2BUPG1.0<<
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('access_token');
         JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
         JsonTextWriter.WritePropertyName('userGstin');
         JsonTextWriter.WriteValue(PurchCrMemoHdr."Location GST Reg. No.");
         JsonTextWriter.WritePropertyName('eway_bill_number');
         JsonTextWriter.WriteValue(GetEwayBillIngNo(TransType::"Purch. Crd Memo", PurchCrMemoHdr."No."));
         JsonTextWriter.WritePropertyName('transporter_id');
         JsonTextWriter.WriteValue(TransportID);
         JsonTextWriter.WritePropertyName('transporter_name');
         JsonTextWriter.WriteValue(TransporterName);
         JsonTextWriter.WriteEndObject();*/
        JOUpdatetransportIDG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOUpdatetransportIDG.Add('userGstin', SalesInvoiceHeader."Location GST Reg. No.");
        JOUpdatetransportIDG.Add('eway_bill_number', GetEwayBillIngNo(TransType::"Sales Invoice", SalesInvoiceHeader."No."));
        JOUpdatetransportIDG.Add('transporter_id', TransportID);
        JOUpdatetransportIDG.Add('transporter_name', TransporterName);
    end;

    local procedure PurchCreditExtendValidityJson()
    var
        LocationBuff: Record Location;
        StateBuff: Record State;
        HeaderTitle: Label 'Enter Details';
        Title1: Label 'Reason :';
        Title2: Label 'Remarks :';
        Title3: Label 'Rem. Dist :';
        Reason: Text;
        ReasonRemarks: Text;
        TransDocNo: Text;
        TransDocDate: Date;
        RemainingDist: Integer;
        RemainingDistText: Text;
        Pin: Integer;
        ExtendErr: Label 'Reason,Remarks and Remaining Distance has to be given to Extend E-Way validity.';
        TransportMethod: Record "Transport Method";
        TransMode: Text;
    begin
        LocationBuff.GET(PurchCrMemoHdr."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        //B2BUPG1.0>>
        //IF NOT OpenWindow(HeaderTitle, Title1, Title2, Title3, Reason, ReasonRemarks, RemainingDistText) THEN
        //    ERROR(ExtendErr);
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(3);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetCancelTransportData(3, Reason, ReasonRemarks, RemainingDistText);
        IF (Reason = '') or (ReasonRemarks = '') THEN
            ERROR(ExtendErr);
        //B2BUPG1.0<<
        EVALUATE(RemainingDist, RemainingDistText);
        IF PurchCrMemoHdr."GST Vendor Type" = PurchCrMemoHdr."GST Vendor Type"::Import THEN
            EVALUATE(Pin, '999999')
        ELSE
            EVALUATE(Pin, COPYSTR(PurchCrMemoHdr."Pay-to Post Code", 1, 6));

        IF TransportMethod.GET(PurchCrMemoHdr."Transport Method") THEN BEGIN
            CASE TransportMethod."Transportation Mode" OF
                TransportMethod."Transportation Mode"::Road:
                    TransMode := 'road';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := 'rail';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := 'air';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := 'ship';
            END;
        END;

        TransDocNo := '';
        TransDocDate := 0D;
        PurchCreditWriteExtendValidityJson(GetEwayBillIngNo(TransType::"Purch. Crd Memo", PurchCrMemoHdr."No."), PurchCrMemoHdr."Location GST Reg. No.", PurchCrMemoHdr."Vehicle No.", LocationBuff.City, StateBuff.Description,
        RemainingDist, TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode, Reason, ReasonRemarks, Pin, 'T', PurchCrMemoHdr."Transaction Type",
                      PurchCrMemoHdr."Pay-to Address", PurchCrMemoHdr."Pay-to Address", PurchCrMemoHdr."Pay-to Address");
    end;

    local procedure PurchCreditWriteExtendValidityJson(EwbNo: Text; GSTIN: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; RemainingDist: Integer; TransDocNo: Text; TransDocDate: Text; TransMode: Text; ReasonCode: Text; ReasonRem: Text; FromPincode: Integer; ConsignmentStatus: Text; TransitType: Text; AddressLine1: Text; AddressLine2: Text; AddressLine3: Text)
    begin
        /*JsonTextWriter.WriteStartObject();
        JsonTextWriter.WritePropertyName('access_token');
        JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."Access Token 2");
        JsonTextWriter.WritePropertyName('userGstin');
        JsonTextWriter.WriteValue(GSTIN);
        JsonTextWriter.WritePropertyName('eway_bill_number');
        JsonTextWriter.WriteValue(EwbNo);
        JsonTextWriter.WritePropertyName('vehicle_number');
        JsonTextWriter.WriteValue(VehicleNo);
        JsonTextWriter.WritePropertyName('place_of_consignor');
        JsonTextWriter.WriteValue(FromPlace);
        JsonTextWriter.WritePropertyName('state_of_consignor');
        JsonTextWriter.WriteValue(FromState);
        JsonTextWriter.WritePropertyName('remaining_distance');
        JsonTextWriter.WriteValue(RemainingDist);
        JsonTextWriter.WritePropertyName('transporter_document_number');
        JsonTextWriter.WriteValue(TransDocNo);
        JsonTextWriter.WritePropertyName('transporter_document_date');
        JsonTextWriter.WriteValue(TransDocDate);
        JsonTextWriter.WritePropertyName('mode_of_transport');
        JsonTextWriter.WriteValue(TransMode);
        JsonTextWriter.WritePropertyName('extend_validity_reason');
        JsonTextWriter.WriteValue(ReasonCode);
        JsonTextWriter.WritePropertyName('extend_remarks');
        JsonTextWriter.WriteValue(ReasonRem);
        JsonTextWriter.WritePropertyName('from_pincode');
        JsonTextWriter.WriteValue(FromPincode);
        JsonTextWriter.WritePropertyName('consignment_status');
        JsonTextWriter.WriteValue(ConsignmentStatus);
        JsonTextWriter.WritePropertyName('transit_type');
        JsonTextWriter.WriteValue(TransMode);
        JsonTextWriter.WritePropertyName('address_line1');
        JsonTextWriter.WriteValue(AddressLine1);
        JsonTextWriter.WritePropertyName('address_line2');
        JsonTextWriter.WriteValue(AddressLine2);
        JsonTextWriter.WritePropertyName('address_line3');
        JsonTextWriter.WriteValue(AddressLine3);
        JsonTextWriter.WriteEndObject();*/
        JOExtendValidityJsonG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOExtendValidityJsonG.Add('userGstin', GSTIN);
        JOExtendValidityJsonG.Add('eway_bill_number', EwbNo);
        JOExtendValidityJsonG.Add('vehicle_number', VehicleNo);
        JOExtendValidityJsonG.Add('place_of_consignor', FromPlace);
        JOExtendValidityJsonG.Add('state_of_consignor', FromState);
        JOExtendValidityJsonG.Add('remaining_distance', RemainingDist);
        JOExtendValidityJsonG.Add('transporter_document_number', TransDocNo);
        JOExtendValidityJsonG.Add('transporter_document_date', TransDocDate);
        JOExtendValidityJsonG.Add('mode_of_transport', '5');
        JOExtendValidityJsonG.Add('extend_validity_reason', ReasonCode);
        JOExtendValidityJsonG.Add('extend_remarks', ReasonRem);
        JOExtendValidityJsonG.add('from_pincode', FromPincode);
        JOExtendValidityJsonG.add('consignment_status', ConsignmentStatus);
        JOExtendValidityJsonG.add('transit_type', 'R');
        JOExtendValidityJsonG.Add('address_line1', AddressLine1);
        JOExtendValidityJsonG.Add('address_line2', AddressLine2);
        JOExtendValidityJsonG.Add('address_line3', AddressLine3);
    end;

    local procedure "-----------------------------------------Transfer Order START------------------------------"()
    begin
    end;

    procedure SetTransOrderHeader(var TransferShipmentHeaderBuff: Record "Transfer Shipment Header"; RequestTypePar: Option Eway,Vehicle,EWayCancel,RejectEway,ExtendValidity,UpdateTrasporter,AccessToken; IsPostingPar: Boolean)
    begin
        TransferShipmentHeader := TransferShipmentHeaderBuff;
        RequestType := RequestTypePar;
        IsPosting := IsPostingPar;
    end;

    procedure TransOrderEWayJson()
    var
        LocationBuff: Record Location;
        StateBuff: Record State;
        Gstin: Text;
        Pin: Text;
        Pos: Text;
        Path: Text;
        SubSupplyType: Text;
        SubType: Text;
    begin
        Pin := COPYSTR(TransferShipmentHeader."Transfer-to Post Code", 1, 6);
        SubSupplyType := 'Supply';
        SubType := 'Outward';

        LocationBuff.GET(TransferShipmentHeader."Transfer-from Code");
        StateBuff.GET(LocationBuff."State Code");

        TransOrderEWayHeadDetails(LocationBuff."GST Registration No.", SubType, SubSupplyType, 'Tax Invoice', TransferShipmentHeader."No.", FORMAT(TransferShipmentHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>')); //Header

        //From Details >>
        TransOrderEwayFromDetails(LocationBuff."GST Registration No.", CompanyInfo.Name, LocationBuff.Address, LocationBuff."Address 2", LocationBuff.City, LocationBuff."Post Code", StateBuff.Description, StateBuff.Description);
        //From Details <<

        //To Details >>
        LocationBuff.GET(TransferShipmentHeader."Transfer-to Code");
        StateBuff.GET(LocationBuff."State Code");

        TransOrderEwayToDetails(LocationBuff."GST Registration No.", TransferShipmentHeader."Transfer-to Name", LocationBuff.Address, LocationBuff."Address 2", LocationBuff.City, LocationBuff."Post Code", StateBuff.Description, StateBuff.Description);
        //To Details <<

        TransOrderGetGSTCompRate(TransferShipmentHeader."No.", 0, JOItemsG);//Update GST calculations
        TransOrderReadEwbDtls();//Update Transport Details

        TransOrderReadItemList();
        // JsonTextWriter.WriteEndObject;
        //ExportAsJson("No.", Path);
    end;

    local procedure TransOrderEWayHeadDetails(GstIn: Text; SupplyType: Text; SupplySubType: Text; Doctype: Text; DocNo: Text; DocDate: Text)
    begin
        /* JsonTextWriter.WriteStartObject;
         JsonTextWriter.WritePropertyName('access_token');
         JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
         JsonTextWriter.WritePropertyName('userGstin');
         JsonTextWriter.WriteValue(GstIn);
         JsonTextWriter.WritePropertyName('supply_type');
         JsonTextWriter.WriteValue(SupplyType);
         JsonTextWriter.WritePropertyName('sub_supply_type');
         JsonTextWriter.WriteValue(SupplySubType);
         JsonTextWriter.WritePropertyName('sub_supply_description');
         JsonTextWriter.WriteValue('');
         JsonTextWriter.WritePropertyName('document_type');
         JsonTextWriter.WriteValue(Doctype);
         JsonTextWriter.WritePropertyName('document_number');
         JsonTextWriter.WriteValue(DocNo);
         JsonTextWriter.WritePropertyName('document_date');
         JsonTextWriter.WriteValue(DocDate);*/
        JOsupplyTypeG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOsupplyTypeG.Add('supply_type', SupplyType);
        JOsupplyTypeG.Add('sub_supply_type', SupplySubType);

        JOsupplyTypeG.Add('sub_supply_description', '');

        JOsupplyTypeG.Add('document_type', Doctype);
        JOsupplyTypeG.Add('document_number', DocNo);
        JOsupplyTypeG.Add('document_date', DocDate);
    end;

    procedure TransOrderEwayFromDetails(FromGstin: Text; FromTrdName: Text; FromAdd1: Text; FromAdd2: Text; FromPlace: Text; FromPinCode: Text; ActFromStateCode: Text; FromStateCode: Text): Boolean
    var
        FromPinCodeInt: Integer;
        ActFromStateCodeInt: Integer;
        FromStateCodeInt: Integer;
    begin
        IF FromPinCode <> '' THEN
            EVALUATE(FromPinCodeInt, FromPinCode);
        /* JsonTextWriter.WritePropertyName('gstin_of_consignor');
         JsonTextWriter.WriteValue(FromGstin);
         JsonTextWriter.WritePropertyName('legal_name_of_consignor');
         JsonTextWriter.WriteValue(FromTrdName);
         JsonTextWriter.WritePropertyName('address1_of_consignor');
         JsonTextWriter.WriteValue(FromAdd1);
         JsonTextWriter.WritePropertyName('address2_of_consignor');
         JsonTextWriter.WriteValue(FromAdd2);
         JsonTextWriter.WritePropertyName('place_of_consignor');
         JsonTextWriter.WriteValue(FromPlace);
         JsonTextWriter.WritePropertyName('pincode_of_consignor');
         JsonTextWriter.WriteValue(FromPinCodeInt);
         JsonTextWriter.WritePropertyName('state_of_consignor');
         JsonTextWriter.WriteValue(FromStateCode);
         JsonTextWriter.WritePropertyName('actual_from_state_name');
         JsonTextWriter.WriteValue(ActFromStateCode);*/
        JOsupplyTypeG.Add('gstin_of_consignor', FromGstin);
        JOsupplyTypeG.Add('legal_name_of_consignor', FromTrdName);
        JOsupplyTypeG.Add('address1_of_consignor', FromAdd1);
        JOsupplyTypeG.Add('address2_of_consignor', FromAdd2);
        JOsupplyTypeG.Add('place_of_consignor', FromPlace);
        JOsupplyTypeG.Add('pincode_of_consignor', FromPinCodeInt);
        JOsupplyTypeG.Add('state_of_consignor', FromStateCodeInt);
        JOsupplyTypeG.Add('actual_from_state_name', ActFromStateCode);
    end;

    procedure TransOrderEwayToDetails(ToGstin: Text; ToTrdName: Text; ToAdd1: Text; ToAdd2: Text; ToPlace: Text; ToPinCode: Text; ActFromStateCode: Text; ToStateCode: Text): Boolean
    var
        ToPinCodeInt: Integer;
        ActToStateCodeInt: Integer;
        ToStateCodeInt: Integer;
    begin
        IF ToPinCode <> '' THEN
            EVALUATE(ToPinCodeInt, ToPinCode);
        /*  JsonTextWriter.WritePropertyName('gstin_of_consignee');
          JsonTextWriter.WriteValue(ToGstin);
          JsonTextWriter.WritePropertyName('legal_name_of_consignee');
          JsonTextWriter.WriteValue(ToTrdName);
          JsonTextWriter.WritePropertyName('address1_of_consignee');
          JsonTextWriter.WriteValue(ToAdd1);
          JsonTextWriter.WritePropertyName('address2_of_consignee');
          JsonTextWriter.WriteValue(ToAdd2);
          JsonTextWriter.WritePropertyName('place_of_consignee');
          JsonTextWriter.WriteValue(ToPlace);
          JsonTextWriter.WritePropertyName('pincode_of_consignee');
          JsonTextWriter.WriteValue(ToPinCodeInt);
          JsonTextWriter.WritePropertyName('state_of_supply');
          JsonTextWriter.WriteValue(ToStateCode);
          JsonTextWriter.WritePropertyName('actual_to_state_name');
          JsonTextWriter.WriteValue(ActFromStateCode);
          JsonTextWriter.WritePropertyName('transaction_type');
          JsonTextWriter.WriteValue(FORMAT(TransferShipmentHeader."Transaction Type"));
          JsonTextWriter.WritePropertyName('other_value');
          JsonTextWriter.WriteValue('');*/
        JOsupplyTypeG.Add('gstin_of_consignee', ToGstin);
        JOsupplyTypeG.Add('legal_name_of_consignee', ToTrdName);
        JOsupplyTypeG.Add('address1_of_consignee', ToAdd1);
        JOsupplyTypeG.Add('address2_of_consignee', ToAdd2);
        JOsupplyTypeG.Add('place_of_consignee', ToPlace);
        JOsupplyTypeG.Add('pincode_of_consignee', ToPinCodeInt);

        JOsupplyTypeG.Add('state_of_supply', ToStateCode);

        JOsupplyTypeG.Add('actual_to_state_name', ActFromStateCode);
        JOsupplyTypeG.Add('transaction_type', TransferShipmentHeader."Transaction Type");
        JOsupplyTypeG.Add('other_value', '');
    end;

    local procedure TransOrderUpdateEwayCalculations(TotalValue: Decimal; CgstValue: Decimal; SgstValue: Decimal; IgstValue: Decimal; CessValue: Decimal)
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
        TotalInvValue: Decimal;
    begin
        TransferShipmentLine.RESET;
        TransferShipmentLine.SETRANGE("Document No.", TransferShipmentHeader."No.");
        //TransferShipmentLine.SETRANGE(Type,TransferShipmentLine.Type::Item);
        TransferShipmentLine.SETRANGE(Exempted, FALSE);
        IF TransferShipmentLine.FINDSET THEN BEGIN
            REPEAT
                TotalInvValue += (TransferShipmentLine.Quantity * TransferShipmentLine."Unit Price");
            UNTIL TransferShipmentLine.NEXT = 0;
        END;

        TotalValue := CgstValue + SgstValue + IgstValue + CessValue;
        /* JsonTextWriter.WritePropertyName('total_invoice_value');
         JsonTextWriter.WriteValue(TotalInvValue + TotalValue);
         JsonTextWriter.WritePropertyName('taxable_amount');
         JsonTextWriter.WriteValue(ABS(TotalInvValue));
         JsonTextWriter.WritePropertyName('cgst_amount');
         JsonTextWriter.WriteValue(CgstValue);
         JsonTextWriter.WritePropertyName('sgst_amount');
         JsonTextWriter.WriteValue(SgstValue);
         JsonTextWriter.WritePropertyName('igst_amount');
         JsonTextWriter.WriteValue(IgstValue);
         JsonTextWriter.WritePropertyName('cess_amount');
         JsonTextWriter.WriteValue(CessValue);
         JsonTextWriter.WritePropertyName('cess_nonadvol_value');
         JsonTextWriter.WriteValue('');*/
        JOsupplyTypeG.Add('total_invoice_value', TotalInvValue + TotalValue);
        JOsupplyTypeG.Add('taxable_amount', ABS(TotalInvValue));
        JOsupplyTypeG.Add('cgst_amount', CgstValue);
        JOsupplyTypeG.Add('sgst_amount', SgstValue);
        JOsupplyTypeG.Add('igst_amount', IgstValue);
        JOsupplyTypeG.Add('cess_amount', CessValue);
        JOsupplyTypeG.Add('cess_nonadvol_value', '');
    end;

    local procedure TransOrderGetGSTCompRate(DocNo: Code[20]; LineNo: Integer; var JSONItemL: JsonObject)
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTComponent: Record "Tax Component";
        CurrExchRate: Record "Currency Exchange Rate";
        CurrencyCode: Code[10];
        CurrencyFactor: Decimal;
        CgstAmt: Decimal;
        SgstAmt: Decimal;
        IgstAmt: Decimal;
        CesRt: Decimal;
        CessAmt: Decimal;
        CesNonAdvlAmt: Decimal;
        StateCesRt: Decimal;
        StateCesAmt: Decimal;
        StateCesNonAdvlAmt: Decimal;
        CgstRt: Decimal;
        SgstRt: Decimal;
        IgstRt: Decimal;
        CesAdvlAmt: Decimal;
        TotalValue: Decimal;
        TransferShipmentLine: Record "Transfer Shipment Line";
    begin
        DetailedGSTLedgerEntry.RESET;
        DetailedGSTLedgerEntry.SETRANGE("Document No.", DocNo);
        DetailedGSTLedgerEntry.SETRANGE(Type, DetailedGSTLedgerEntry.Type::Item);
        IF LineNo <> 0 THEN
            DetailedGSTLedgerEntry.SETRANGE("Document Line No.", LineNo);

        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'CGST');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS("GST Amount");
            CgstAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            CgstRt := ABS(DetailedGSTLedgerEntry."GST %");
        END ELSE BEGIN
            CgstAmt := 0;
            CgstRt := 0;
        END;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'SGST');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS("GST Amount");
            SgstAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            SgstRt := ABS(DetailedGSTLedgerEntry."GST %");
        END ELSE BEGIN
            SgstAmt := 0;
            SgstRt := 0
        END;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'IGST');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS("GST Amount");
            IgstAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            IgstRt := ABS(DetailedGSTLedgerEntry."GST %");
        END ELSE BEGIN
            IgstAmt := 0;
            IgstRt := 0;
        END;
        CesRt := 0;
        CessAmt := 0;
        CesNonAdvlAmt := 0;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'CESS');
        IF DetailedGSTLedgerEntry.FINDSET THEN
            IF DetailedGSTLedgerEntry."GST %" > 0 THEN BEGIN
                DetailedGSTLedgerEntry.CALCSUMS("GST Amount");
                CesRt := DetailedGSTLedgerEntry."GST %";
                CessAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            END ELSE
                CesNonAdvlAmt := ABS(DetailedGSTLedgerEntry."GST Amount");

        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'INTERCESS');
        IF DetailedGSTLedgerEntry.FINDSET THEN BEGIN
            DetailedGSTLedgerEntry.CALCSUMS("GST Amount");
            CesRt := DetailedGSTLedgerEntry."GST %";
            CessAmt := DetailedGSTLedgerEntry."GST Amount";
        END;

        StateCesRt := 0;
        StateCesAmt := 0;
        StateCesNonAdvlAmt := 0;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code");
        IF DetailedGSTLedgerEntry.FINDSET THEN
            REPEAT
                IF NOT (DetailedGSTLedgerEntry."GST Component Code" IN ['CGST', 'SGST', 'IGST', 'CESS', 'INTERCESS']) THEN
                    IF GSTComponent.GET(DetailedGSTLedgerEntry."GST Component Code") THEN
                        IF DetailedGSTLedgerEntry."GST %" > 0 THEN BEGIN
                            StateCesRt := DetailedGSTLedgerEntry."GST %";
                            StateCesAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
                        END ELSE
                            StateCesNonAdvlAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            UNTIL DetailedGSTLedgerEntry.NEXT = 0;

        TotalValue := DetailedGSTLedgerEntry."GST Base Amount";

        IF LineNo = 0 THEN
            TransOrderUpdateEwayCalculations(TotalValue, CgstAmt, SgstAmt, IgstAmt, CessAmt)//Header Json
        ELSE BEGIN
            /* JsonTextWriter.WritePropertyName('cgst_rate');
             JsonTextWriter.WriteValue(CgstRt);
             JsonTextWriter.WritePropertyName('sgst_rate');
             JsonTextWriter.WriteValue(SgstRt);
             JsonTextWriter.WritePropertyName('igst_rate');
             JsonTextWriter.WriteValue(IgstRt);
             JsonTextWriter.WritePropertyName('cess_rate');
             JsonTextWriter.WriteValue(CesRt);
             TransferShipmentLine.GET(DocNo, LineNo);
             JsonTextWriter.WritePropertyName('quantity');
             JsonTextWriter.WriteValue(TransferShipmentLine.Quantity);
             JsonTextWriter.WritePropertyName('cessNonAdvolValue');
             JsonTextWriter.WriteValue(CesNonAdvlAmt);*/
            JSONItemL.Add('cgst_rate', CgstRt);
            JSONItemL.Add('sgst_rate', SgstRt);
            JSONItemL.Add('igst_rate', IgstRt);
            JSONItemL.Add('cess_rate', CesRt);
            TransferShipmentLine.GET(DocNo, LineNo);
            JSONItemL.Add('quantity', TransferShipmentLine.Quantity);
            JSONItemL.Add('cessNonAdvolValue', CesNonAdvlAmt);
        END;
    end;

    local procedure TransOrderReadEwbDtls()
    var
        TransId: Text[15];
        TransName: Text[100];
        TransMode: Text[20];
        Distance: Text[4];
        TransDocNo: Text[15];
        TransDocDt: Text[10];
        VehNo: Text[20];
        VehType: Text[20];
        TransportMethod: Record "Transport Method";
        DistanceTxt: Text;
        TransactionType: Text;
    begin
        TransId := '';//Transit/GSTIN
        TransactionType := TransferShipmentHeader."Transaction Type";
        IF TransportMethod.GET(TransferShipmentHeader."Transport Method") THEN BEGIN
            TransName := '';
            CASE TransportMethod."Transportation Mode" OF
                TransportMethod."Transportation Mode"::Road:
                    TransMode := 'road';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := 'rail';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := 'air';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := 'ship';
            END;
        END;
        IF TransferShipmentHeader."Distance (Km)" <> 0 THEN BEGIN
            DistanceTxt := DELCHR(FORMAT(ROUND(TransferShipmentHeader."Distance (Km)", 1, '=')), '=', ',');

            IF STRLEN(DistanceTxt) > 4 THEN
                Distance := COPYSTR(DistanceTxt, 1, 4)
            ELSE
                Distance := DistanceTxt;
        END ELSE
            Distance := '';
        TransDocNo := '';//Trnasport Document No.
        TransDocDt := '';//Transport Doc Date
        VehNo := TransferShipmentHeader."Vehicle No.";
        CASE TransferShipmentHeader."Vehicle Type" OF
            TransferShipmentHeader."Vehicle Type"::" ":
                VehType := '';
            TransferShipmentHeader."Vehicle Type"::ODC:
                VehType := 'ODC';
            TransferShipmentHeader."Vehicle Type"::Regular:
                VehType := 'Regular';
        END;


        TransOrderWriteEwbDtls(TransId, TransName, TransMode, Distance, TransDocNo, TransDocDt, VehNo, VehType, TransactionType);
    end;

    local procedure TransOrderWriteEwbDtls(TransId: Text[15]; TransName: Text[100]; TransMode: Text[20]; Distance: Text[4]; TransDocNo: Text[15]; TransDocDt: Text[10]; VehNo: Text[20]; VehType: Text[20]; TransactionType: Text)
    begin
        /* JsonTextWriter.WritePropertyName('transporter_id');
         JsonTextWriter.WriteValue(TransId);
         JsonTextWriter.WritePropertyName('transporter_name');
         JsonTextWriter.WriteValue(TransName);
         JsonTextWriter.WritePropertyName('transporter_document_number');
         JsonTextWriter.WriteValue(TransDocNo);
         JsonTextWriter.WritePropertyName('transporter_document_date');
         JsonTextWriter.WriteValue(TransDocDt);
         JsonTextWriter.WritePropertyName('transportation_mode');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WritePropertyName('transportation_distance');
         JsonTextWriter.WriteValue(Distance);
         JsonTextWriter.WritePropertyName('vehicle_number');
         JsonTextWriter.WriteValue(VehNo);
         JsonTextWriter.WritePropertyName('vehicle_type');
         JsonTextWriter.WriteValue(VehType);
         JsonTextWriter.WritePropertyName('generate_status');
         JsonTextWriter.WriteValue('1');
         JsonTextWriter.WritePropertyName('data_source');
         JsonTextWriter.WriteValue('erp');
         JsonTextWriter.WritePropertyName('user_ref');
         JsonTextWriter.WriteValue(TransferShipmentHeader."No.");
         JsonTextWriter.WritePropertyName('location_code');
         JsonTextWriter.WriteValue(TransferShipmentHeader."Transfer-from Code");
         JsonTextWriter.WritePropertyName('eway_bill_status');
         JsonTextWriter.WriteValue('ABC');
         JsonTextWriter.WritePropertyName('auto_print');
         JsonTextWriter.WriteValue('Y');
         //JsonTextWriter.WritePropertyName('EWB_print_type');
         //JsonTextWriter.WriteValue('d');
         JsonTextWriter.WritePropertyName('email');
         JsonTextWriter.WriteValue(CompanyInfo."E-Mail");*/
        JOsupplyTypeG.Add('transporterId', TransId);
        JOsupplyTypeG.Add('transporterName', TransName);
        JOsupplyTypeG.Add('transDocNo', TransDocNo);
        JOsupplyTypeG.Add('transMode', TransMode);
        JOsupplyTypeG.Add('transDistance', Distance);
        JOsupplyTypeG.Add('transDocDate', TransDocDt);
        JOsupplyTypeG.Add('vehicleNo', VehNo);
        JOsupplyTypeG.Add('vehicleType', VehType);
        JOsupplyTypeG.Add('generate_status', '1');
        JOsupplyTypeG.Add('data_source', 'erp');
        JOsupplyTypeG.Add('user_ref', SalesInvoiceHeader."No.");
        JOsupplyTypeG.Add('location_code', SalesInvoiceHeader."Location Code");
        JOsupplyTypeG.Add('eway_bill_status', 'ABC');
        JOsupplyTypeG.Add('auto_print', 'Y');
        JOsupplyTypeG.Add('EWB_print_type', 'd');
        JOsupplyTypeG.Add('email', CompanyInfo."E-Mail");
    end;

    local procedure TransOrderReadItemList()
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
        SalesLinesErr: Label 'E-Invoice allowes only 1000 lines per Invoice. Curent transaction is having %1 lines.', Comment = '%1 = Sales Lines count';
        HSNInt: Integer;
        Uom: Record "Unit of Measure";
    begin
        TransferShipmentLine.RESET;
        TransferShipmentLine.SETRANGE("Document No.", TransferShipmentHeader."No.");
        TransferShipmentLine.SETFILTER("Item No.", '<>%1', '');
        TransferShipmentLine.SETFILTER(Quantity, '>%1', 0);
        IF TransferShipmentLine.FINDSET THEN BEGIN
            IF TransferShipmentLine.COUNT > 1000 THEN
                ERROR(SalesLinesErr, TransferShipmentLine.COUNT);
            // JsonTextWriter.WritePropertyName('itemList');
            //  JsonTextWriter.WriteStartArray;
            REPEAT
                EVALUATE(HSNInt, TransferShipmentLine."HSN/SAC Code");
                /*   JsonTextWriter.WriteStartObject;
                   JsonTextWriter.WritePropertyName('product_name');
                   JsonTextWriter.WriteValue(TransferShipmentLine."Item No.");
                   JsonTextWriter.WritePropertyName('product_description');
                   JsonTextWriter.WriteValue(TransferShipmentLine.Description);
                   JsonTextWriter.WritePropertyName('hsn_code');
                   JsonTextWriter.WriteValue(HSNInt);
                   Uom.GET(TransferShipmentLine."Unit of Measure Code");
                   JsonTextWriter.WritePropertyName('unit_of_product');
                   JsonTextWriter.WriteValue(Uom."International Standard Code");


                   TransOrderGetGSTCompRate(TransferShipmentHeader."No.", TransferShipmentLine."Line No.");

                   JsonTextWriter.WritePropertyName('taxableAmount');
                   JsonTextWriter.WriteValue(TransferShipmentLine.Amount);
                   JsonTextWriter.WriteEndObject;*/
                Uom.GET(TransferShipmentLine."Unit of Measure Code");
                JOItemsG.Add('product_name', TransferShipmentLine."Item No.");
                JOItemsG.Add('product_description', TransferShipmentLine.Description);
                JOItemsG.Add('hsn_code', HSNInt);
                JOItemsG.Add('unit_of_product', Uom."International Standard Code");
                //JOItemsG.Add('quantity', TransferShipmentLine.Quantity);

                InvGetGSTCompRate(SalesInvoiceHeader."No.", TransferShipmentLine."Line No.", JOItemsG);

                JOItemsG.Add('taxableAmount', TransferShipmentLine.Amount);
                JArrayItemsG.Add(JOItemsG);
            UNTIL TransferShipmentLine.NEXT = 0;
            JOsupplyTypeG.Add('itemList', JArrayItemsG);
            //JsonTextWriter.WriteEndArray;
        END;
    end;

    procedure TransOrderVechileJson()
    var
        LocationBuff: Record Location;
        StateBuff: Record State;
        Reason: Text;
        ReasonRemarks: Text;
        TransDocNo: Text;
        TransDocDate: Date;
        HeaderTitle: Label 'Enter Details';
        Title3: Label 'Vehicle No :';
        VehicleNo: Text;
        TransMode: Text;
        TransportMethod: Record "Transport Method";
        Title1: Text;
        Title2: Text;

        VehType: Text;
    begin
        LocationBuff.GET(TransferShipmentHeader."Transfer-from Code");
        StateBuff.GET(LocationBuff."State Code");
        IF IsPosting THEN BEGIN
            Reason := 'Others';//EWayBillingSetup."Vehicle Reason";
            ReasonRemarks := EWayBillingSetup."Vehicle Remarks";
            VehicleNo := TransferShipmentHeader."Vehicle No.";
        END ELSE BEGIN
            Reason := 'Others';//EWayBillingSetup."Vehicle Reason";
            ReasonRemarks := EWayBillingSetup."Vehicle Remarks";
            //B2BUPG1.0>>
            // VehicleNo := Windows.InputBox(Title3, '', '', 10, 10);
            Clear(EWayUpdate);
            Commit();
            EWayUpdate.SetData(0);
            if EWayUpdate.RunModal() = Action::Yes then
                EWayUpdate.GetData(0, VehicleNo);
            //B2BUPG1.0<<
            IF VehicleNo = ' ' THEN
                EXIT;
            //"Old Vehicle No" := "Vehicle No.";
            TransferShipmentHeader."Vehicle No." := VehicleNo;
            TransferShipmentHeader.MODIFY;
        END;
        CASE TransferShipmentHeader."Vehicle Type" OF
            TransferShipmentHeader."Vehicle Type"::" ":
                VehType := '';
            TransferShipmentHeader."Vehicle Type"::ODC:
                VehType := 'odc';
            TransferShipmentHeader."Vehicle Type"::Regular:
                VehType := 'Regular';
        END;
        IF TransportMethod.GET(TransferShipmentHeader."Transport Method") THEN BEGIN
            CASE TransportMethod."Transportation Mode" OF
                TransportMethod."Transportation Mode"::Road:
                    TransMode := 'road';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := 'rail';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := 'air';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := 'ship';
            END;
        END;
        TransDocNo := '';
        TransDocDate := 0D;
        TransOrderWriteVechileJson(GetEwayBillIngNo(TransType::"Transfer Order", TransferShipmentHeader."No."), LocationBuff."GST Registration No.", VehicleNo, LocationBuff.City, StateBuff.Description, Reason, ReasonRemarks,
                        TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode, VehType);
    end;

    local procedure TransOrderWriteVechileJson(EwbNo: Text; GSTIN: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; ReasonCode: Text; ReasonRem: Text; TransDocNo: Text; TransDocDate: Text; TransMode: Text; VehType: Text)
    var
        EwbBigInt: BigInteger;
    begin
        /*  JsonTextWriter.WriteStartObject();
          JsonTextWriter.WritePropertyName('access_token');
          JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
          JsonTextWriter.WritePropertyName('userGstin');
          JsonTextWriter.WriteValue(GSTIN);
          JsonTextWriter.WritePropertyName('eway_bill_number');
          JsonTextWriter.WriteValue(EwbNo);
          JsonTextWriter.WritePropertyName('vehicle_number');
          JsonTextWriter.WriteValue(VehicleNo);
          JsonTextWriter.WritePropertyName('vehicle_type');
          JsonTextWriter.WriteValue(VehType);
          JsonTextWriter.WritePropertyName('place_of_consignor');
          JsonTextWriter.WriteValue(FromPlace);
          JsonTextWriter.WritePropertyName('state_of_consignor');
          JsonTextWriter.WriteValue(FromState);
          JsonTextWriter.WritePropertyName('reason_code_for_vehicle_updation');
          JsonTextWriter.WriteValue(ReasonCode);
          JsonTextWriter.WritePropertyName('reason_for_vehicle_updation');
          JsonTextWriter.WriteValue(ReasonRem);
          JsonTextWriter.WritePropertyName('transporter_document_number');
          JsonTextWriter.WriteValue(TransDocNo);
          JsonTextWriter.WritePropertyName('transporter_document_date');
          JsonTextWriter.WriteValue(TransDocDate);
          JsonTextWriter.WritePropertyName('mode_of_transport');
          JsonTextWriter.WriteValue(TransMode);
          JsonTextWriter.WritePropertyName('data_source');
          JsonTextWriter.WriteValue('erp');
          JsonTextWriter.WriteEndObject();*/
        JOVehicleG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOVehicleG.Add('userGstin', GSTIN);
        JOVehicleG.Add('eway_bill_number', EwbNo);
        JOVehicleG.Add('vehicle_number', VehicleNo);
        JOVehicleG.Add('vehicle_type', VehType);
        JOVehicleG.Add('place_of_consignor', FromPlace);
        JOVehicleG.Add('state_of_consignor', FromState);
        JOVehicleG.Add('reason_code_for_vehicle_updation', ReasonCode);
        JOVehicleG.Add('reason_for_vehicle_updation', ReasonRem);
        JOVehicleG.Add('transporter_document_number', TransDocNo);
        JOVehicleG.Add('transporter_document_date', '');
        JOVehicleG.add('mode_of_transport', TransMode);
        JOVehicleG.Add('data_source', 'erp');
    end;

    local procedure TransOrderCancelEwayJson()
    var
        HeaderTitle: Label 'Enter Cancel Details';
        Title1: Label 'Cancel Reason :';
        Title2: Label 'Cancel Remarks :';
        LocationBuff: Record Location;
        StateBuff: Record State;
        Reason: Text;
        ReasonRemarks: Text;
        TransDocNo: Text;
        TransDocDate: Date;
        Title3: Text;
        RemainingDist: Text;
    begin
        //B2BUPG1.0>>
        //IF NOT OpenWindow(HeaderTitle, Title1, Title2, Title3, Reason, ReasonRemarks, RemainingDist) THEN
        //    EXIT;
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(3);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetCancelTransportData(3, Reason, ReasonRemarks, RemainingDist);
        IF (Reason = '') or (ReasonRemarks = '') THEN
            EXIT;
        //B2BUPG1.0<<
        LocationBuff.GET(TransferShipmentHeader."Transfer-from Code");
        TransOrderWriteCancelJson(GetEwayBillIngNo(TransType::"Transfer Order", TransferShipmentHeader."No."), LocationBuff."GST Registration No.", Reason, ReasonRemarks);
    end;

    local procedure TransOrderWriteCancelJson(EWBNo: Text; GSTIN: Text; CancelReason: Text; CancelRemarks: Text)
    begin
        /*JsonTextWriter.WriteStartObject();
        JsonTextWriter.WritePropertyName('access_token');
        JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JsonTextWriter.WritePropertyName('userGstin');
        JsonTextWriter.WriteValue(GSTIN);
        JsonTextWriter.WritePropertyName('eway_bill_number');
        JsonTextWriter.WriteValue(EWBNo);
        JsonTextWriter.WritePropertyName('reason_of_cancel');
        JsonTextWriter.WriteValue(CancelReason);
        JsonTextWriter.WritePropertyName('cancel_remark');
        JsonTextWriter.WriteValue(CancelRemarks);
        JsonTextWriter.WritePropertyName('data_source');
        JsonTextWriter.WriteValue('erp');
        JsonTextWriter.WriteEndObject();*/
        JOCancelG.add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOCancelG.Add('userGstin', GSTIN);
        JOCancelG.Add('eway_bill_number', EWBNo);
        JOCancelG.Add('reason_of_cancel', CancelReason);
        JOCancelG.Add('cancel_remark', CancelRemarks);
        JOCancelG.Add('data_source', 'erp');
    end;

    procedure TransOrderRejectEwayJson(RejDocumentNo: Code[20]; var RejEwayBillNo: BigInteger)
    var
        HeaderTitle: Label 'Enter Cancel Details';
        Title1: Label 'Cancel Reason :';
        Title2: Label 'Cancel Remarks :';
        RejectEwayBillNo: Text;

        EWayValidator: Codeunit "E-Way Validator";
        RejectErr: Label 'E-Way bill no must be provided to Reject.';
    begin
        EWayBillingSetup.GET;
        RequestType := RequestType::RejectEway;


        //B2BUPG1.0<<
        //RejectEwayBillNo := Windows.InputBox('Rejecting E-Way Bill No :', '', '', 10, 10);
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(1);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetData(1, RejectEwayBillNo);
        //B2BUPG1.0<<
        IF RejectEwayBillNo = '' THEN
            ERROR(RejectErr);
        EWayValidator.CheckValidations(RejectEwayBillNo, RequestType);//Check Validations

        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('access_token');
         JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
         JsonTextWriter.WritePropertyName('userGstin');
         JsonTextWriter.WriteValue(CompanyInfo."GST Registration No.");
         JsonTextWriter.WritePropertyName('eway_bill_number');
         JsonTextWriter.WriteValue(RejectEwayBillNo);
         JsonTextWriter.WritePropertyName('data_source');
         JsonTextWriter.WriteValue('erp');
         JsonTextWriter.WriteEndObject();
         EVALUATE(RejEwayBillNo, RejectEwayBillNo);
         ExportAsJson(RejDocumentNo, PathSaved);*/
        JORejEWayNoG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JORejEWayNoG.Add('userGstin', CompanyInfo."GST Registration No.");
        EVALUATE(RejEwayBillNo, RejectEwayBillNo);
        JORejEWayNoG.Add('eway_bill_number', RejectEwayBillNo);
        JORejEWayNoG.Add('data_source', 'erp');
    end;

    local procedure TransOrderUpdateTransportJson()
    var
        TransportID: Text;

        TransportIDError: Label 'Transport Id must have value';
        TransporterName: Text;
        Blank: Text;
        Title1: Label 'Transport ID';
        Title2: Label 'Transport Name';
        Title3: Text;
        HeaderTitle: Label 'Transporter Details';
        Location: Record Location;
    begin
        //B2BUPG1.0>>
        //IF NOT OpenWindow(HeaderTitle, Title1, Title2, Title3, TransportID, TransporterName, Blank) THEN
        //    EXIT;
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(3);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetCancelTransportData(3, TransportID, TransporterName, Blank);
        IF (TransportID = '') or (TransporterName = '') THEN
            EXIT;
        //B2BUPG1.0<<
        Location.GET(TransferShipmentHeader."Transfer-from Code");
        /*  JsonTextWriter.WriteStartObject();
          JsonTextWriter.WritePropertyName('access_token');
          JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
          JsonTextWriter.WritePropertyName('userGstin');
          JsonTextWriter.WriteValue(Location."GST Registration No.");
          JsonTextWriter.WritePropertyName('eway_bill_number');
          JsonTextWriter.WriteValue(GetEwayBillIngNo(TransType::"Transfer Order", TransferShipmentHeader."No."));
          JsonTextWriter.WritePropertyName('transporter_id');
          JsonTextWriter.WriteValue(TransportID);
          JsonTextWriter.WritePropertyName('transporter_name');
          JsonTextWriter.WriteValue(TransporterName);
          JsonTextWriter.WriteEndObject();*/
        JOUpdatetransportIDG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOUpdatetransportIDG.Add('userGstin', SalesInvoiceHeader."Location GST Reg. No.");
        JOUpdatetransportIDG.Add('eway_bill_number', GetEwayBillIngNo(TransType::"Sales Invoice", SalesInvoiceHeader."No."));
        JOUpdatetransportIDG.Add('transporter_id', TransportID);
        JOUpdatetransportIDG.Add('transporter_name', TransporterName);
    end;

    local procedure TransOrderExtendValidityJson()
    var
        LocationBuff: Record Location;
        StateBuff: Record State;
        HeaderTitle: Label 'Enter Details';
        Title1: Label 'Reason :';
        Title2: Label 'Remarks :';
        Title3: Label 'Rem. Dist :';
        Reason: Text;
        ReasonRemarks: Text;
        TransDocNo: Text;
        TransDocDate: Date;
        RemainingDist: Integer;
        RemainingDistText: Text;
        Pin: Integer;
        ExtendErr: Label 'Reason,Remarks and Remaining Distance has to be given to Extend E-Way validity.';
        TransportMethod: Record "Transport Method";
        TransMode: Text;
    begin
        LocationBuff.GET(TransferShipmentHeader."Transfer-from Code");
        StateBuff.GET(LocationBuff."State Code");
        //B2BUPG1.0>>
        //IF NOT OpenWindow(HeaderTitle, Title1, Title2, Title3, Reason, ReasonRemarks, RemainingDistText) THEN
        //    ERROR(ExtendErr);
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(3);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetCancelTransportData(3, Reason, ReasonRemarks, RemainingDistText);
        IF (Reason = '') or (ReasonRemarks = '') THEN
            ERROR(ExtendErr);
        //B2BUPG1.0<<
        EVALUATE(RemainingDist, RemainingDistText);
        EVALUATE(Pin, COPYSTR(TransferShipmentHeader."Transfer-from Post Code", 1, 6));

        IF TransportMethod.GET(TransferShipmentHeader."Transport Method") THEN BEGIN
            CASE TransportMethod."Transportation Mode" OF
                TransportMethod."Transportation Mode"::Road:
                    TransMode := 'road';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := 'rail';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := 'air';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := 'ship';
            END;
        END;

        TransDocNo := '';
        TransDocDate := 0D;
        TransOrderWriteExtendValidityJson(GetEwayBillIngNo(TransType::"Transfer Order", TransferShipmentHeader."No."), LocationBuff."GST Registration No.", TransferShipmentHeader."Vehicle No.", LocationBuff.City, StateBuff.Description,
        RemainingDist, TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode, Reason, ReasonRemarks, Pin, 'T', TransferShipmentHeader."Transaction Type",
                      TransferShipmentHeader."Transfer-from Address", TransferShipmentHeader."Transfer-from Address", TransferShipmentHeader."Transfer-from Address");
    end;

    local procedure TransOrderWriteExtendValidityJson(EwbNo: Text; GSTIN: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; RemainingDist: Integer; TransDocNo: Text; TransDocDate: Text; TransMode: Text; ReasonCode: Text; ReasonRem: Text; FromPincode: Integer; ConsignmentStatus: Text; TransitType: Text; AddressLine1: Text; AddressLine2: Text; AddressLine3: Text)
    begin
        /*  JsonTextWriter.WriteStartObject();
          JsonTextWriter.WritePropertyName('access_token');
          JsonTextWriter.WriteValue(EWayBillingSetup."MI Access Token" + EWayBillingSetup."Access Token 2");
          JsonTextWriter.WritePropertyName('userGstin');
          JsonTextWriter.WriteValue(GSTIN);
          JsonTextWriter.WritePropertyName('eway_bill_number');
          JsonTextWriter.WriteValue(EwbNo);
          JsonTextWriter.WritePropertyName('vehicle_number');
          JsonTextWriter.WriteValue(VehicleNo);
          JsonTextWriter.WritePropertyName('place_of_consignor');
          JsonTextWriter.WriteValue(FromPlace);
          JsonTextWriter.WritePropertyName('state_of_consignor');
          JsonTextWriter.WriteValue(FromState);
          JsonTextWriter.WritePropertyName('remaining_distance');
          JsonTextWriter.WriteValue(RemainingDist);
          JsonTextWriter.WritePropertyName('transporter_document_number');
          JsonTextWriter.WriteValue(TransDocNo);
          JsonTextWriter.WritePropertyName('transporter_document_date');
          JsonTextWriter.WriteValue(TransDocDate);
          JsonTextWriter.WritePropertyName('mode_of_transport');
          JsonTextWriter.WriteValue(TransMode);
          JsonTextWriter.WritePropertyName('extend_validity_reason');
          JsonTextWriter.WriteValue(ReasonCode);
          JsonTextWriter.WritePropertyName('extend_remarks');
          JsonTextWriter.WriteValue(ReasonRem);
          JsonTextWriter.WritePropertyName('from_pincode');
          JsonTextWriter.WriteValue(FromPincode);
          JsonTextWriter.WritePropertyName('consignment_status');
          JsonTextWriter.WriteValue(ConsignmentStatus);
          JsonTextWriter.WritePropertyName('transit_type');
          JsonTextWriter.WriteValue(TransMode);
          JsonTextWriter.WritePropertyName('address_line1');
          JsonTextWriter.WriteValue(AddressLine1);
          JsonTextWriter.WritePropertyName('address_line2');
          JsonTextWriter.WriteValue(AddressLine2);
          JsonTextWriter.WritePropertyName('address_line3');
          JsonTextWriter.WriteValue(AddressLine3);
          JsonTextWriter.WriteEndObject();*/
        JOExtendValidityJsonG.Add('access_token', EWayBillingSetup."MI Access Token" + EWayBillingSetup."MI Access Token 2");
        JOExtendValidityJsonG.Add('userGstin', GSTIN);
        JOExtendValidityJsonG.Add('eway_bill_number', EwbNo);
        JOExtendValidityJsonG.Add('vehicle_number', VehicleNo);
        JOExtendValidityJsonG.Add('place_of_consignor', FromPlace);
        JOExtendValidityJsonG.Add('state_of_consignor', FromState);
        JOExtendValidityJsonG.Add('remaining_distance', RemainingDist);
        JOExtendValidityJsonG.Add('transporter_document_number', TransDocNo);
        JOExtendValidityJsonG.Add('transporter_document_date', TransDocDate);
        JOExtendValidityJsonG.Add('mode_of_transport', '5');
        JOExtendValidityJsonG.Add('extend_validity_reason', ReasonCode);
        JOExtendValidityJsonG.Add('extend_remarks', ReasonRem);
        JOExtendValidityJsonG.add('from_pincode', FromPincode);
        JOExtendValidityJsonG.add('consignment_status', ConsignmentStatus);
        JOExtendValidityJsonG.add('transit_type', 'R');
        JOExtendValidityJsonG.Add('address_line1', AddressLine1);
        JOExtendValidityJsonG.Add('address_line2', AddressLine2);
        JOExtendValidityJsonG.Add('address_line3', AddressLine3);
    end;


    //B2BUPG1.0>>
    local procedure GetGSTAmountsPurchase(PurchaseLine: Record "Purchase Line")
    var
        ComponentName: Code[30];
        TaxTransactionValue: Record "Tax Transaction Value";
        GSTSetup: Record "GST Setup";
    begin
        GSTSetup.Get();
        //ComponentName := GetComponentName(PurchaseLine, GSTSetup);

        if (PurchaseLine.Type <> PurchaseLine.Type::" ") then begin
            TaxTransactionValue.Reset();
            TaxTransactionValue.SetRange("Tax Record ID", PurchaseLine.RecordId);
            TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
            TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
            TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
            if TaxTransactionValue.FindSet() then
                repeat
                    case TaxTransactionValue."Value ID" of
                        6:
                            PurchInitGSTCalculationBuffer(PurchaseLine."Line No.", TaxTransactionValue.Amount, TaxTransactionValue.Percent, PurchaseLine."GST Group Code", 'SGST', PurchaseLine."Qty. to Receive", PurchaseLine.Quantity);
                        2:
                            PurchInitGSTCalculationBuffer(PurchaseLine."Line No.", TaxTransactionValue.Amount, TaxTransactionValue.Percent, PurchaseLine."GST Group Code", 'CGST', PurchaseLine."Qty. to Receive", PurchaseLine.Quantity);
                        3:
                            PurchInitGSTCalculationBuffer(PurchaseLine."Line No.", TaxTransactionValue.Amount, TaxTransactionValue.Percent, PurchaseLine."GST Group Code", 'IGST', PurchaseLine."Qty. to Receive", PurchaseLine.Quantity);
                    end;
                until TaxTransactionValue.Next() = 0;
        end;
    end;

    local procedure GetGSTAmountsSales(SaleshipLine: Record "Sales Shipment Line")
    var
        ComponentName: Code[30];
        TaxTransactionValue: Record "Tax Transaction Value";
        GSTSetup: Record "GST Setup";
    begin
        GSTSetup.Get();
        //ComponentName := GetComponentName(PurchaseLine, GSTSetup);

        if (SaleshipLine.Type <> SaleshipLine.Type::" ") then begin
            TaxTransactionValue.Reset();
            TaxTransactionValue.SetRange("Tax Record ID", SaleshipLine.RecordId);
            TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
            TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
            TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
            if TaxTransactionValue.FindSet() then
                repeat
                    case TaxTransactionValue."Value ID" of
                        6:
                            ShipInitGSTCalculationBuffer(SaleshipLine."Line No.", SaleshipLine."GST Group Code", 'SGST', TaxTransactionValue.Amount, TaxTransactionValue.Percent);
                        2:
                            ShipInitGSTCalculationBuffer(SaleshipLine."Line No.", SaleshipLine."GST Group Code", 'CGST', TaxTransactionValue.Amount, TaxTransactionValue.Percent);
                        3:
                            ShipInitGSTCalculationBuffer(SaleshipLine."Line No.", SaleshipLine."GST Group Code", 'IGST', TaxTransactionValue.Amount, TaxTransactionValue.Percent);
                    end;
                until TaxTransactionValue.Next() = 0;
        end;
    end;
    //B2BUPG1.0<<

    procedure InitJSONRequest(var JsonFile: Text)
    begin
        CASE RequestType OF
            RequestType::Eway:
                BEGIN
                    JOsupplyTypeG.WriteTo(JsonFile);
                END;
            RequestType::Vehicle:
                BEGIN
                    JOVehicleG.WriteTo(JsonFile);
                END;
            RequestType::EWayCancel:
                BEGIN
                    JOCancelG.WriteTo(JsonFile);
                END;
            RequestType::RejectEway:
                BEGIN
                    JORejEWayNoG.WriteTo(JSONFile);
                END;
            RequestType::UpdateTrasporter:
                BEGIN
                    JOUpdatetransportIDG.WriteTo(JSONFile);
                END;
            RequestType::ExtendValidity:
                BEGIN
                    JOExtendValidityJsonG.WriteTo(JSONFile);
                END;
        END;

    end;


}

