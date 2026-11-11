codeunit 50012 "E-Way Adequre Json Generator"
{
    Permissions = TableData "Sales Shipment Header" = rm,
                  TableData "Sales Invoice Header" = rm,
                  TableData "Sales Cr.Memo Header" = rm,
                  TableData "Purch. Rcpt. Header" = rm,
                  TableData "Purch. Inv. Header" = rm,
                  TableData "Purch. Cr. Memo Hdr." = rm,
                  TableData "Transfer Shipment Header" = rm;

    trigger OnRun()
    begin
        CompanyInfo.GET;
        EWayBillingSetup.GET;


        ProcessJSONFormat();

        // ExportAsJson(DocumentNo, PathSaved);
    end;

    var

        GlobalNULL: Variant;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CompanyInfo: Record "Company Information";
        RequestType: Option Eway,Vehicle,EWayCancel,RejectEway,ExtendValidity,UpdateTrasporter,AccessToken;
        DocumentNo: Code[20];
        PathSaved: Text;
        EWayBillingSetup: Record "E-Way Billing Setup";
        IsPosting: Boolean;
        SalesShipHeader: Record "Sales Shipment Header";
        DocType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order",Shipment;
        PurchHeader: Record "Purchase Header";
        WareHouseRectHead: Record "Warehouse Receipt Header";
        TransType: Option " ","Sales Invoice","Sales Shpt","Purch. Order","Whse. Shipment","Whse. Rect","Transfer Order","Sales Crd Memo","Purch. Crd Memo","Sales R.O","Purchase R.O",Subcontracting;
        SalesCreditHeader: Record "Sales Cr.Memo Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        DeliveryChallanHeader: Record "Delivery Challan Header";
        //B2BUPG1.0>>
        GSTLbl: Label 'GST';
        IGSTLbl: Label 'IGST';
        CGSTLbl: Label 'CGST';
        GSTCESSLbl: Label 'GST CESS';
        CESSLbl: Label 'CESS';
        SGSTAmt: Decimal;
        CGSTAmt: Decimal;
        IGSTAmt: Decimal;
        EWayUpdate: Page "E-Way Bill Update Window";
        //B2BUPG1.0<<
        //B2BSaaS>>
        JOsupplyTypeG: JsonObject;
        JOItemsG: JsonObject;
        JArrayItemsG: JsonArray;

        JOCancelG: JsonObject;
        JOVehicleG: JsonObject;
        JORejEWayNoG: JsonObject;

        JOUpdatetransportIDG: JsonObject;

        JOExtendValidityJsonG: JsonObject;

    //B2BSaaS<<



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

    /*local procedure ExportAsJson(FileName: Text[20]; var PathSaved: Text)
    var
        TempFile: File;
        ToFile: Variant;
        NewStream: InStream;
        TempBlob: Codeunit "Temp Blob";
        LogRecord: Record "E-Way Integration Log";
        DocExt: Text;
        FileManagement: Codeunit "File Management"; //B2BUPG1.0
        OutstreamL: outstream;
    begin
        LogRecord.RESET;
        LogRecord.SETRANGE("Document No.", DocumentNo);
        LogRecord.SETRANGE("Request Type", RequestType);
        IF LogRecord.FINDSET THEN
            DocExt := FORMAT(LogRecord.COUNT + 1);
        FileName := FileName + DocExt;
        FileName := DELCHR(FileName, '=', '/\-_*^@');
        ToFile := FileName + '.json';

        //PathSaved := EWayBillingSetup."E-Way File Storage Path" + FORMAT(RequestType) + '\Request\' + FileName + '.json';

        CLEAR(TempBlob);
        //B2BUPG1.0>>

        //TempBlob.WriteAsText(StringBuilder.ToString, TEXTENCODING::UTF8);
        TempBlob.CreateOutStream(outstreamL, TEXTENCODING::UTF8);
        //outstreamL.WriteText(StringBuilder.ToString);
        //TempBlob.EXPORT(PathSaved);
        //FileManagement.BLOBExportToServerFile(TempBlob, PathSaved);
        //B2BUPG1.0<<
    end;*/


    local procedure GetEwayBillIngNo(TransType: Option " ","Sales Invoice","Sales Shpt","Purch. Order","Whse. Shipment","Whse. Rect","Transfer Order","Sales Crd Memo","Purch. Crd Memo","Sales R.O","Purchase R.O",Subcontracting; DocNo: Code[20]): Text
    var
        EWayBillingEntry: Record "E-Way Billing Entry";
    begin
        EWayBillingEntry.GET(TransType, DocNo);
        EXIT(FORMAT(EWayBillingEntry."E-Way Bill No."));
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
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        IF SalesInvoiceHeader."GST Customer Type" = SalesInvoiceHeader."GST Customer Type"::Export THEN BEGIN
            Gstin := 'URP';
            Pin := '999999';
            SubSupplyType := '3';
            SubType := 'O';
        END ELSE BEGIN
            Gstin := SalesInvoiceHeader."Customer GST Reg. No.";//"Customer GST Reg. No.";
            Pin := COPYSTR(SalesInvoiceHeader."Bill-to Post Code", 1, 6);
            SubSupplyType := '1';
            SubType := 'O';
        END;
        //EWB1.2 >>
        IF SalesInvoiceHeader."GST Customer Type" = SalesInvoiceHeader."GST Customer Type"::Unregistered THEN
            Gstin := 'URP';
        //EWB1.2 <<
        InvEWayHeadDetails(SubType, SubSupplyType, 'INV', SalesInvoiceHeader."No.", FORMAT(SalesInvoiceHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>')); //Header

        //From Details >>
        LocationBuff.GET(SalesInvoiceHeader."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        InvEwayFromDetails(LocationBuff."GST Registration No.", CompanyInfo.Name, LocationBuff.Address, LocationBuff."Address 2", LocationBuff.City
                        , LocationBuff."Post Code", StateBuff."State Code (GST Reg. No.)", StateBuff."State Code (GST Reg. No.)");
        //From Details <<

        //To Details >>

        Pos := InvGetEwayPos(SalesInvoiceHeader."No.");
        SalesInvoiceLine.RESET;
        SalesInvoiceLine.SETRANGE("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SETFILTER("No.", '<>%1', '');//BugFix
        SalesInvoiceLine.SETRANGE(Exempted, FALSE);
        IF SalesInvoiceLine.FINDFIRST THEN BEGIN
            IF SalesInvoiceLine."GST Place of Supply" = SalesInvoiceLine."GST Place of Supply"::"Bill-to Address" THEN
                InvEwayToDetails(Gstin, SalesInvoiceHeader."Bill-to Name", SalesInvoiceHeader."Bill-to Address", SalesInvoiceHeader."Bill-to Address 2", SalesInvoiceHeader."Bill-to City", Pin, Pos, Pos);
            IF SalesInvoiceLine."GST Place of Supply" = SalesInvoiceLine."GST Place of Supply"::"Ship-to Address" THEN
                InvEwayToDetails(Gstin, SalesInvoiceHeader."Ship-to Name", SalesInvoiceHeader."Ship-to Address", SalesInvoiceHeader."Ship-to Address 2", SalesInvoiceHeader."Ship-to City", COPYSTR(SalesInvoiceHeader."Ship-to Post Code", 1, 6), Pos, Pos);
        END;
        //To Details <<
        InvGetGSTCompRate(SalesInvoiceHeader."No.", 0, JOItemsG);//Update GST calculations
        InvReadEwbDtls();//Update Transport Details

        InvReadItemList();
        // JsonTextWriter.WriteEndObject;
        //ExportAsJson(SalesInvoiceHeader."No.",Path);

    end;

    local procedure InvEWayHeadDetails(SupplyType: Text; SupplySubType: Text; Doctype: Text; DocNo: Text; DocDate: Text)
    begin
        /* JsonTextWriter.WriteStartObject;
         JsonTextWriter.WritePropertyName('supplyType');
         JsonTextWriter.WriteValue(SupplyType);
         JsonTextWriter.WritePropertyName('subSupplyType');
         JsonTextWriter.WriteValue(SupplySubType);
         //Export >>
         IF SupplySubType = '3' THEN BEGIN
             JsonTextWriter.WritePropertyName('subSupplyDesc');
             JsonTextWriter.WriteValue('');
         END;
         //Export <<
         JsonTextWriter.WritePropertyName('docType');
         JsonTextWriter.WriteValue(Doctype);
         JsonTextWriter.WritePropertyName('docNo');
         JsonTextWriter.WriteValue(DocNo);
         JsonTextWriter.WritePropertyName('docDate');
         JsonTextWriter.WriteValue(DocDate);
         */
        JOsupplyTypeG.Add('supplyType', SupplyType);
        JOsupplyTypeG.Add('subSupplyType', SupplySubType);
        if SupplySubType = '3' then begin
            JOsupplyTypeG.Add('subSupplyDesc', '');
        end;
        JOsupplyTypeG.Add('docType', Doctype);
        JOsupplyTypeG.Add('docNo', DocNo);
        JOsupplyTypeG.Add('docDate', DocDate);

    end;

    procedure InvEwayFromDetails(FromGstin: Text; FromTrdName: Text; FromAdd1: Text; FromAdd2: Text; FromPlace: Text; FromPinCode: Text; ActFromStateCode: Text; FromStateCode: Text): Boolean
    var
        FromPinCodeInt: Integer;
        ActFromStateCodeInt: Integer;
        FromStateCodeInt: Integer;
    begin
        IF FromPinCode <> '' THEN
            EVALUATE(FromPinCodeInt, FromPinCode);
        IF ActFromStateCode <> '' THEN
            EVALUATE(ActFromStateCodeInt, ActFromStateCode);
        IF FromStateCode <> '' THEN
            EVALUATE(FromStateCodeInt, FromStateCode);
        /*JsonTextWriter.WritePropertyName('fromGstin');
        JsonTextWriter.WriteValue(FromGstin);
        JsonTextWriter.WritePropertyName('fromTrdName');
        JsonTextWriter.WriteValue(FromTrdName);
        JsonTextWriter.WritePropertyName('fromAddr1');
        JsonTextWriter.WriteValue(FromAdd1);
        JsonTextWriter.WritePropertyName('fromAddr2');
        JsonTextWriter.WriteValue(FromAdd2);
        JsonTextWriter.WritePropertyName('fromPlace');
        JsonTextWriter.WriteValue(FromPlace);
        JsonTextWriter.WritePropertyName('fromPincode');
        JsonTextWriter.WriteValue(FromPinCodeInt);
        JsonTextWriter.WritePropertyName('actFromStateCode');
        JsonTextWriter.WriteValue(ActFromStateCodeInt);
        JsonTextWriter.WritePropertyName('fromStateCode');
        JsonTextWriter.WriteValue(FromStateCodeInt);*/
        JOsupplyTypeG.Add('fromGstin', FromGstin);
        JOsupplyTypeG.Add('fromTrdName', FromTrdName);
        JOsupplyTypeG.Add('fromAddr1', FromAdd1);
        JOsupplyTypeG.Add('fromAddr2', FromAdd2);
        JOsupplyTypeG.Add('fromPlace', FromPlace);
        JOsupplyTypeG.Add('fromPincode', FromPinCodeInt);
        JOsupplyTypeG.Add('actFromStateCode', ActFromStateCodeInt);
        JOsupplyTypeG.Add('fromStateCode', FromStateCodeInt);

    end;

    procedure InvEwayToDetails(ToGstin: Text; ToTrdName: Text; ToAdd1: Text; ToAdd2: Text; ToPlace: Text; ToPinCode: Text; ActFromStateCode: Text; ToStateCode: Text): Boolean
    var
        ToPinCodeInt: Integer;
        ActToStateCodeInt: Integer;
        ToStateCodeInt: Integer;
    begin
        IF ToPinCode <> '' THEN
            EVALUATE(ToPinCodeInt, ToPinCode);
        IF ActFromStateCode <> '' THEN
            EVALUATE(ActToStateCodeInt, ActFromStateCode);
        IF ToStateCode <> '' THEN
            EVALUATE(ToStateCodeInt, ToStateCode);
        /* JsonTextWriter.WritePropertyName('toGstin');
         JsonTextWriter.WriteValue(ToGstin);
         JsonTextWriter.WritePropertyName('toTrdName');
         JsonTextWriter.WriteValue(ToTrdName);
         JsonTextWriter.WritePropertyName('toAddr1');
         JsonTextWriter.WriteValue(ToAdd1);
         JsonTextWriter.WritePropertyName('toAddr2');
         JsonTextWriter.WriteValue(ToAdd2);
         JsonTextWriter.WritePropertyName('toPlace');
         JsonTextWriter.WriteValue(ToPlace);
         JsonTextWriter.WritePropertyName('toPincode');
         JsonTextWriter.WriteValue(ToPinCodeInt);
         JsonTextWriter.WritePropertyName('actToStateCode');
         */
        JOsupplyTypeG.Add('toGstin', ToGstin);
        JOsupplyTypeG.Add('toTrdName', ToTrdName);
        JOsupplyTypeG.Add('toAddr1', ToAdd1);
        JOsupplyTypeG.Add('toAddr2', ToAdd2);
        JOsupplyTypeG.Add('toPlace', ToPlace);
        JOsupplyTypeG.Add('toPincode', ToPinCodeInt);
        // JOsupplyTypeG.Add()
        //Export >>
        IF (SalesInvoiceHeader."GST Customer Type" IN [SalesInvoiceHeader."GST Customer Type"::Export, SalesInvoiceHeader."GST Customer Type"::"SEZ Development",
                                                  SalesInvoiceHeader."GST Customer Type"::"SEZ Unit"]) THEN
            /// JsonTextWriter.WriteValue('97')
            JOsupplyTypeG.Add('actToStateCode', '97')
        ELSE
            //JsonTextWriter.WriteValue(ActToStateCodeInt);
            JOsupplyTypeG.Add('actToStateCode', ActToStateCodeInt);

        //JsonTextWriter.WritePropertyName('toStateCode');
        //JsonTextWriter.WriteValue(ToStateCodeInt);
        JOsupplyTypeG.Add('toStateCode', ToStateCodeInt);

        IF SalesInvoiceHeader."GST Customer Type" = SalesInvoiceHeader."GST Customer Type"::Export THEN BEGIN
            /* JsonTextWriter.WritePropertyName('transactionType');
             JsonTextWriter.WriteValue(FORMAT(SalesInvoiceHeader."Transaction Type"));
             JsonTextWriter.WritePropertyName('dispatchFromGSTIN');
             JsonTextWriter.WriteValue('');
             JsonTextWriter.WritePropertyName('dispatchFromTradeName');
             JsonTextWriter.WriteValue(FORMAT(SalesInvoiceHeader."Sell-to Customer Name"));
             JsonTextWriter.WritePropertyName('ShipToGSTIN');
             JsonTextWriter.WriteValue('');
             JsonTextWriter.WritePropertyName('shipToTradeName');
             JsonTextWriter.WriteValue(ToAdd1);
             JsonTextWriter.WritePropertyName('otherValue');
             JsonTextWriter.WriteValue('');*/
            JOsupplyTypeG.Add('transactionType', format(SalesInvoiceHeader."Transaction Type"));
            JOsupplyTypeG.Add('dispatchFromGSTIN', '');
            JOsupplyTypeG.Add('dispatchFromTradeName', format(SalesInvoiceHeader."Sell-to Customer Name"));
            JOsupplyTypeG.Add('ShipToGSTIN', '');
            JOsupplyTypeG.Add('shipToTradeName', ToAdd1);
            JOsupplyTypeG.Add('otherValue', '');
        END;
        //Export <<
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
                    EXIT(StateBuff."State Code (GST Reg. No.)");
                END ELSE
                    EXIT('99');
            END ELSE
                IF SalesInvoiceLine."GST Place of Supply" = SalesInvoiceLine."GST Place of Supply"::"Ship-to Address" THEN BEGIN
                    IF NOT (SalesInvoiceHeader."GST Customer Type" = SalesInvoiceHeader."GST Customer Type"::Export) THEN BEGIN
                        StateBuff.GET(SalesInvoiceHeader."GST Ship-to State Code");
                        EXIT(StateBuff."State Code (GST Reg. No.)");
                    END ELSE
                        EXIT('99');
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
                                 ((SalesInvoiceLine.Quantity * SalesInvoiceLine."Unit Price") * SalesInvoiceLine."Line Discount %" / 100) -
                                 SalesInvoiceLine."Inv. Discount Amount";
            UNTIL SalesInvoiceLine.NEXT = 0;
        END;

        IF SalesInvoiceHeader."Currency Code" <> '' THEN BEGIN
            TotalInvValue := (1 / SalesInvoiceHeader."Currency Factor") * TotalInvValue;
        END;
        // Tcs>>
        Clear(OtherCharges);
        TCSEntry.Reset();
        TCSEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        if TCSEntry.FindSet() then begin
            TCSEntry.CalcSums("Total TCS Including SHE CESS");
            OtherCharges := TCSEntry."Total TCS Including SHE CESS";
        end;
        TotalValue := CgstValue + SgstValue + IgstValue + CessValue + OtherCharges;
        /* JsonTextWriter.WritePropertyName('otherValue');
         JsonTextWriter.WriteValue(OtherCharges);
         //TCS<<
         JsonTextWriter.WritePropertyName('totalValue');
         JsonTextWriter.WriteValue(ABS(TotalInvValue));
         JsonTextWriter.WritePropertyName('cgstValue');
         JsonTextWriter.WriteValue(CgstValue);
         JsonTextWriter.WritePropertyName('sgstValue');
         JsonTextWriter.WriteValue(SgstValue);
         JsonTextWriter.WritePropertyName('igstValue');
         JsonTextWriter.WriteValue(IgstValue);
         JsonTextWriter.WritePropertyName('cessValue');
         JsonTextWriter.WriteValue(CessValue);
         */
        //Export >>
        JOsupplyTypeG.Add('otherValue', OtherCharges);
        JOsupplyTypeG.Add('totalValue', ABS(TotalInvValue));
        JOsupplyTypeG.Add('cgstValue', CgstValue);
        JOsupplyTypeG.Add('sgstValue', SgstValue);
        JOsupplyTypeG.Add('igstValue', IgstValue);
        JOsupplyTypeG.Add('cessValue', CessValue);
        IF SalesInvoiceHeader."GST Customer Type" = SalesInvoiceHeader."GST Customer Type"::Export THEN BEGIN
            //JsonTextWriter.WritePropertyName('cessNonAdvolValue');
            //JsonTextWriter.WriteValue('');
            JOsupplyTypeG.Add('cessNonAdvolValue', '')
        END;
        //Export <<
        // JsonTextWriter.WritePropertyName('totInvValue');


        //JsonTextWriter.WriteValue(TotalInvValue + TotalValue);
        JOsupplyTypeG.Add('totInvValue', TotalInvValue + TotalValue);
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

        IF SalesInvoiceHeader."Currency Code" <> '' THEN BEGIN
            CurrencyCode := SalesInvoiceHeader."Currency Code";
            CurrencyFactor := SalesInvoiceHeader."Currency Factor";
            /*
            IF IgstAmt <> 0 THEN
              IgstAmt := ROUND((1/SalesInvoiceHeader."Currency Factor")*IgstAmt,0.01,'=');
            IF CgstAmt <> 0 THEN
              CgstAmt := ROUND((1/SalesInvoiceHeader."Currency Factor")*CgstAmt,0.01,'=');
            IF SgstAmt <> 0 THEN
              SgstAmt := ROUND((1/SalesInvoiceHeader."Currency Factor")*SgstAmt,0.01,'=');
            IF CessAmt <> 0 THEN
              CessAmt := ROUND((1/SalesInvoiceHeader."Currency Factor")*CessAmt,0.01,'=');
            IF CesNonAdvlAmt <> 0 THEN
              CesNonAdvlAmt := ROUND((1/SalesInvoiceHeader."Currency Factor")*CesNonAdvlAmt,0.01,'=');
            IF StateCesAmt <> 0 THEN
              StateCesAmt := ROUND((1/SalesInvoiceHeader."Currency Factor")*StateCesAmt,0.01,'=');
            IF StateCesNonAdvlAmt <> 0 THEN
              StateCesNonAdvlAmt := ROUND((1/SalesInvoiceHeader."Currency Factor")*StateCesNonAdvlAmt,0.01,'=');*/
            IF TotalValue <> 0 THEN
                TotalValue := ROUND((1 / SalesInvoiceHeader."Currency Factor") * TotalValue, 0.01, '=');
        END;
        IF LineNo = 0 THEN
            InvUpdateEwayCalculations(TotalValue, CgstAmt, SgstAmt, IgstAmt, CessAmt)//Header Json
        ELSE BEGIN
            /*  JsonTextWriter.WritePropertyName('cgstRate');
              JsonTextWriter.WriteValue(CgstRt);
              JsonTextWriter.WritePropertyName('sgstRate');
              JsonTextWriter.WriteValue(SgstRt);
              JsonTextWriter.WritePropertyName('igstRate');
              JsonTextWriter.WriteValue(IgstRt);
              JsonTextWriter.WritePropertyName('cessRate');
              JsonTextWriter.WriteValue(CesRt);
              */
            JSONItemL.Add('cgstRate', CgstRt);
            JSONItemL.Add('sgstRate', SgstRt);
            JSONItemL.Add('igstRate', IgstRt);
            JSONItemL.Add('cessRate', CesRt);
            //Export >>
            IF SalesInvoiceHeader."GST Customer Type" = SalesInvoiceHeader."GST Customer Type"::Export THEN BEGIN
                // JsonTextWriter.WritePropertyName('cessNonAdvolValue');
                //JsonTextWriter.WriteValue(CesNonAdvlAmt);
                JSONItemL.Add('cessNonAdvolValue', CesNonAdvlAmt);
            END ELSE BEGIN
                //JsonTextWriter.WritePropertyName('cessAdvol');
                //JsonTextWriter.WriteValue(CesAdvlAmt);
                JSONItemL.Add('cessAdvol', CesAdvlAmt);
            END;
            //Export <<
        END;

    end;

    local procedure InvReadEwbDtls()
    var
        TransId: Text[15];
        TransName: Text[100];
        TransMode: Text[1];
        Distance: Text[4];
        TransDocNo: Text[15];
        TransDocDt: Text[10];
        VehNo: Text[20];
        VehType: Text[1];
        TransportMethod: Record "Transport Method";
        DistanceTxt: Text;
        TransactionType: Text;
    begin
        TransId := '';//Transit/GSTIN
        TransactionType := SalesInvoiceHeader."Transaction Type";
        IF TransportMethod.GET(SalesInvoiceHeader."Transport Method") THEN BEGIN
            TransName := '';
            /*
            CASE TransportMethod."Transportation Mode" OF
                TransportMethod."Transportation Mode"::Road:
                    TransMode := '1';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := '2';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := '3';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := '4';
            END;
            */
            TransMode := SalesInvoiceHeader."Transport Method";
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
                VehType := 'O';
            SalesInvoiceHeader."Vehicle Type"::Regular:
                VehType := 'R';
        END;


        InvWriteEwbDtls(TransId, TransName, TransMode, Distance, TransDocNo, TransDocDt, VehNo, VehType, TransactionType);
    end;

    local procedure InvWriteEwbDtls(TransId: Text[15]; TransName: Text[100]; TransMode: Text[1]; Distance: Text[4]; TransDocNo: Text[15]; TransDocDt: Text[10]; VehNo: Text[20]; VehType: Text[1]; TransactionType: Text)
    begin
        /* JsonTextWriter.WritePropertyName('transporterId');
         JsonTextWriter.WriteValue(TransId);
         JsonTextWriter.WritePropertyName('transporterName');
         JsonTextWriter.WriteValue(TransName);
         JsonTextWriter.WritePropertyName('transDocNo');
         JsonTextWriter.WriteValue(TransDocNo);
         JsonTextWriter.WritePropertyName('transMode');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WritePropertyName('transDistance');
         JsonTextWriter.WriteValue(Distance);
         JsonTextWriter.WritePropertyName('transDocDate');
         JsonTextWriter.WriteValue(TransDocDt);
         JsonTextWriter.WritePropertyName('vehicleNo');
         JsonTextWriter.WriteValue(VehNo);
         JsonTextWriter.WritePropertyName('vehicleType');
         JsonTextWriter.WriteValue(VehType);
         IF NOT (SalesInvoiceHeader."GST Customer Type" = SalesInvoiceHeader."GST Customer Type"::Export) THEN BEGIN
             JsonTextWriter.WritePropertyName('TransactionType');
             JsonTextWriter.WriteValue(TransactionType);
         END;*/
        JOsupplyTypeG.Add('transporterId', TransId);
        JOsupplyTypeG.Add('transporterName', TransName);
        JOsupplyTypeG.Add('transDocNo', TransDocNo);
        JOsupplyTypeG.Add('transMode', TransMode);
        JOsupplyTypeG.Add('transDistance', Distance);
        JOsupplyTypeG.Add('transDocDate', TransDocDt);
        JOsupplyTypeG.Add('vehicleNo', VehNo);
        JOsupplyTypeG.Add('vehicleType', VehType);
        IF NOT (SalesInvoiceHeader."GST Customer Type" = SalesInvoiceHeader."GST Customer Type"::Export) THEN
            JOsupplyTypeG.Add('transactionType', TransactionType);

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
                /*
                JsonTextWriter.WriteStartObject;
                JsonTextWriter.WritePropertyName('productName');
                JsonTextWriter.WriteValue(SalesInvoiceLine."No.");
                JsonTextWriter.WritePropertyName('productDesc');
                JsonTextWriter.WriteValue(SalesInvoiceLine.Description);
                JsonTextWriter.WritePropertyName('hsnCode');
                JsonTextWriter.WriteValue(HSNInt);
                JsonTextWriter.WritePropertyName('quantity');
                JsonTextWriter.WriteValue(SalesInvoiceLine.Quantity);
                
                JsonTextWriter.WritePropertyName('qtyUnit');
                JsonTextWriter.WriteValue(Uom.Code);

              

                JsonTextWriter.WritePropertyName('taxableAmount');
                IF SalesInvoiceHeader."Currency Code" <> '' THEN
                    JsonTextWriter.WriteValue((1 / SalesInvoiceHeader."Currency Factor") * SalesInvoiceLine."Line Amount")
                ELSE
                    JsonTextWriter.WriteValue(SalesInvoiceLine."Line Amount");
                JsonTextWriter.WriteEndObject;
                */
                Clear(JOItemsG);
                Uom.GET(SalesInvoiceLine."Unit of Measure Code");
                JOItemsG.Add('productName', SalesInvoiceLine."No.");
                JOItemsG.Add('productDesc', SalesInvoiceLine.Description);
                JOItemsG.Add('hsnCode', HSNInt);
                JOItemsG.Add('quantity', SalesInvoiceLine.Quantity);
                JOItemsG.Add('qtyUnit', Uom.Code);
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
    begin
        LocationBuff.GET(SalesInvoiceHeader."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        IF IsPosting THEN BEGIN
            Reason := EWayBillingSetup."Vehicle Reason";
            ReasonRemarks := EWayBillingSetup."Vehicle Remarks";
            VehicleNo := SalesInvoiceHeader."Vehicle No.";
        END ELSE BEGIN
            Reason := EWayBillingSetup."Vehicle Reason";
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
            UpdateOldVechileNoInEWayEntry(1, SalesInvoiceHeader."No.", SalesInvoiceHeader."Vehicle No.");

            SalesInvoiceHeader."Vehicle No." := VehicleNo;
            SalesInvoiceHeader.MODIFY();
        END;

        IF TransportMethod.GET(SalesInvoiceHeader."Transport Method") THEN BEGIN
            /*
            CASE TransportMethod."Transportation Mode" OF
                TransportMethod."Transportation Mode"::Road:
                    TransMode := '1';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := '2';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := '3';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := '4';
            END;
            */
            TransMode := SalesInvoiceHeader."Transport Method";
        END;
        TransDocNo := '';
        TransDocDate := 0D;
        InvWriteVechileJson(GetEwayBillIngNo(TransType::"Sales Invoice", SalesInvoiceHeader."No."), VehicleNo, LocationBuff.City, StateBuff."State Code for eTDS/TCS", Reason, ReasonRemarks,
                        TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode);
    end;

    local procedure InvWriteVechileJson(EwbNo: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; ReasonCode: Text; ReasonRem: Text; TransDocNo: Text; TransDocDate: Text; TransMode: Text)
    var
        EwbBigInt: BigInteger;
    begin
        /*
        JsonTextWriter.WriteStartObject();
        JsonTextWriter.WritePropertyName('EwbNo');
        JsonTextWriter.WriteValue(EwbNo);
        JsonTextWriter.WritePropertyName('VehicleNo');
        JsonTextWriter.WriteValue(VehicleNo);
        JsonTextWriter.WritePropertyName('FromPlace');
        JsonTextWriter.WriteValue(FromPlace);
        JsonTextWriter.WritePropertyName('FromState');
        JsonTextWriter.WriteValue(FromState);
        JsonTextWriter.WritePropertyName('ReasonCode');
        JsonTextWriter.WriteValue(ReasonCode);
        JsonTextWriter.WritePropertyName('ReasonRem');
        JsonTextWriter.WriteValue(ReasonRem);
        JsonTextWriter.WritePropertyName('TransDocNo');
        JsonTextWriter.WriteValue(TransDocNo);
        JsonTextWriter.WritePropertyName('TransDocDate');
        JsonTextWriter.WriteValue(TransDocDate);
        JsonTextWriter.WritePropertyName('TransMode');
        JsonTextWriter.WriteValue(TransMode);
        JsonTextWriter.WriteEndObject();
        */
        JOVehicleG.Add('EwbNo', EwbNo);
        JOVehicleG.Add('VehicleNo', VehicleNo);
        JOVehicleG.Add('FromPlace', FromPlace);
        JOVehicleG.Add('FromState', FromState);
        JOVehicleG.Add('ReasonCode', ReasonCode);
        JOVehicleG.Add('ReasonRem', ReasonRem);
        JOVehicleG.Add('TransDocNo', TransDocNo);
        JOVehicleG.Add('TransDocDate', '');
        JOVehicleG.add('TransMode', TransMode);


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
            exit;
        //B2BUPG1.0<<
        InvWriteCancelJson(GetEwayBillIngNo(TransType::"Sales Invoice", SalesInvoiceHeader."No."), Reason, ReasonRemarks);
    end;

    local procedure InvWriteCancelJson(EWBNo: Text; CancelReason: Text; CancelRemarks: Text)
    begin
        /*JsonTextWriter.WriteStartObject();
        JsonTextWriter.WritePropertyName('ewbNo');
        JsonTextWriter.WriteValue(EWBNo);
        JsonTextWriter.WritePropertyName('cancelRsnCode');
        JsonTextWriter.WriteValue(CancelReason);
        JsonTextWriter.WritePropertyName('cancelRmrk');
        JsonTextWriter.WriteValue(CancelRemarks);
        JsonTextWriter.WriteEndObject();*/
        JOCancelG.Add('ewbNo', EWBNo);
        JOCancelG.Add('cancelRsnCode', CancelReason);
        JOCancelG.Add('cancelRmrk', CancelRemarks);

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

        // JsonTextWriter.WriteStartObject();
        // JsonTextWriter.WritePropertyName('ewbNo');
        // JsonTextWriter.WriteValue(RejectEwayBillNo);
        // JsonTextWriter.WriteEndObject();
        EVALUATE(RejEwayBillNo, RejectEwayBillNo);
        JORejEWayNoG.Add('ewbNo', RejectEwayBillNo);

        // ExportAsJson(RejDocumentNo, PathSaved);
    end;

    local procedure InvUpdateTransportJson()
    var
        TransportID: Text;

        TransportIDError: Label 'Transport Id must have value';
    begin
        //B2BUPG1.0<<
        //TransportID := Windows.InputBox('Transporter ID :', '', '', 10, 10);
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(2);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetData(2, TransportID);
        //B2BUPG1.0<<
        IF TransportID = '' THEN
            ERROR(TransportIDError);
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('ewbNo');
         JsonTextWriter.WriteValue(GetEwayBillIngNo(TransType::"Sales Invoice", SalesInvoiceHeader."No."));
         JsonTextWriter.WritePropertyName('transporterId');
         JsonTextWriter.WriteValue(TransportID);
         JsonTextWriter.WriteEndObject();*/
        JOUpdatetransportIDG.Add('ewbNo', GetEwayBillIngNo(TransType::"Sales Invoice", SalesInvoiceHeader."No."));
        JOUpdatetransportIDG.Add('transporterId', TransportID);

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
            /*
            CASE TransportMethod."Transportation Mode" OF
                TransportMethod."Transportation Mode"::Road:
                    TransMode := '1';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := '2';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := '3';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := '4';
            END;
            */
            TransMode := SalesInvoiceHeader."Transport Method";
        END;

        TransDocNo := '';
        TransDocDate := 0D;
        InvWriteExtendValidityJson(GetEwayBillIngNo(TransType::"Sales Invoice", SalesInvoiceHeader."No."), SalesInvoiceHeader."Vehicle No.", LocationBuff.City, StateBuff."State Code (GST Reg. No.)",
        RemainingDist, TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode, Reason, ReasonRemarks, Pin, 'T', SalesInvoiceHeader."Transaction Type",
                      SalesInvoiceHeader."Sell-to Address", SalesInvoiceHeader."Sell-to Address", SalesInvoiceHeader."Sell-to Address");
    end;

    local procedure InvWriteExtendValidityJson(EwbNo: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; RemainingDist: Integer; TransDocNo: Text; TransDocDate: Text; TransMode: Text; ReasonCode: Text; ReasonRem: Text; FromPincode: Integer; ConsignmentStatus: Text; TransitType: Text; AddressLine1: Text; AddressLine2: Text; AddressLine3: Text)
    begin
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('EwbNo');
         JsonTextWriter.WriteValue(EwbNo);
         JsonTextWriter.WritePropertyName('vehicleNo');
         JsonTextWriter.WriteValue(VehicleNo);
         JsonTextWriter.WritePropertyName('fromPlace');
         JsonTextWriter.WriteValue(FromPlace);
         JsonTextWriter.WritePropertyName('fromState');
         JsonTextWriter.WriteValue(FromState);
         JsonTextWriter.WritePropertyName('remainingDistance');
         JsonTextWriter.WriteValue(RemainingDist);
         JsonTextWriter.WritePropertyName('TransDocNo');
         JsonTextWriter.WriteValue(TransDocNo);
         JsonTextWriter.WritePropertyName('TransDocDate');
         JsonTextWriter.WriteValue(TransDocDate);
         JsonTextWriter.WritePropertyName('TransMode');
         JsonTextWriter.WriteValue('5');
         JsonTextWriter.WritePropertyName('extnRsnCode');
         JsonTextWriter.WriteValue(ReasonCode);
         JsonTextWriter.WritePropertyName('extnRemarks');
         JsonTextWriter.WriteValue(ReasonRem);
         JsonTextWriter.WritePropertyName('fromPincode');
         JsonTextWriter.WriteValue(FromPincode);
         JsonTextWriter.WritePropertyName('consignmentStatus');
         JsonTextWriter.WriteValue(ConsignmentStatus);
         JsonTextWriter.WritePropertyName('transitType');
         JsonTextWriter.WriteValue('R');
         JsonTextWriter.WritePropertyName('addressLine1');
         JsonTextWriter.WriteValue(AddressLine1);
         JsonTextWriter.WritePropertyName('addressLine2');
         JsonTextWriter.WriteValue(AddressLine2);
         JsonTextWriter.WritePropertyName('addressLine3');
         JsonTextWriter.WriteValue(AddressLine3);
         JsonTextWriter.WriteEndObject();*/
        JOExtendValidityJsonG.Add('EwbNo', EwbNo);
        JOExtendValidityJsonG.Add('vehicleNo', VehicleNo);
        JOExtendValidityJsonG.Add('fromPlace', FromPlace);
        JOExtendValidityJsonG.Add('fromState', FromState);
        JOExtendValidityJsonG.Add('remainingDistance', RemainingDist);
        JOExtendValidityJsonG.Add('TransDocNo', TransDocNo);
        JOExtendValidityJsonG.Add('TransDocDate', TransDocDate);
        JOExtendValidityJsonG.Add('TransMode', '5');
        JOExtendValidityJsonG.Add('extnRsnCode', ReasonCode);
        JOExtendValidityJsonG.Add('extnRemarks', ReasonRem);
        JOExtendValidityJsonG.add('fromPincode', FromPincode);
        JOExtendValidityJsonG.add('consignmentStatus', ConsignmentStatus);
        JOExtendValidityJsonG.add('transitType', 'R');
        JOExtendValidityJsonG.Add('addressLine1', AddressLine1);
        JOExtendValidityJsonG.Add('addressLine2', AddressLine2);
        JOExtendValidityJsonG.Add('addressLine3', AddressLine3);

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
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        IF SalesShipHeader."GST Customer Type" = SalesShipHeader."GST Customer Type"::Export THEN BEGIN
            Gstin := 'URP';
            Pin := '999999';
            SubSupplyType := '3';
        END ELSE BEGIN
            Gstin := SalesShipHeader."Customer GST Reg. No.";//"Customer GST Reg. No.";//
            Pin := COPYSTR(SalesShipHeader."Bill-to Post Code", 1, 6);
            SubSupplyType := '1';
        END;
        ShipEWayHeadDetails('O', SubSupplyType, 'INV', SalesShipHeader."No.", FORMAT(SalesShipHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>')); //Header

        //From Details >>
        LocationBuff.GET(SalesShipHeader."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        ShipEwayFromDetails(LocationBuff."GST Registration No.", CompanyInfo.Name, LocationBuff.Address, LocationBuff."Address 2", LocationBuff.City
                        , LocationBuff."Post Code", StateBuff."State Code (GST Reg. No.)", StateBuff."State Code (GST Reg. No.)");
        //From Details <<

        //To Details >>

        Pos := ShipGetEwayPos(SalesShipHeader."No.");
        SalesShipmentLine.RESET;
        SalesShipmentLine.SETRANGE("Document No.", SalesShipHeader."No.");
        SalesShipmentLine.SETFILTER("No.", '<>%1', '');//BugFix
        SalesShipmentLine.SETRANGE(Exempted, FALSE);
        IF SalesShipmentLine.FINDFIRST THEN BEGIN
            IF SalesShipmentLine."GST Place of Supply" = SalesShipmentLine."GST Place of Supply"::"Bill-to Address" THEN
                ShipEwayToDetails(Gstin, SalesShipHeader."Bill-to Name", SalesShipHeader."Bill-to Address", SalesShipHeader."Bill-to Address 2", SalesShipHeader."Bill-to City", Pin, Pos, Pos);
            IF SalesShipmentLine."GST Place of Supply" = SalesShipmentLine."GST Place of Supply"::"Ship-to Address" THEN
                ShipEwayToDetails(Gstin, SalesShipHeader."Ship-to Name", SalesShipHeader."Ship-to Address", SalesShipHeader."Ship-to Address 2", SalesShipHeader."Ship-to City", COPYSTR(SalesShipHeader."Ship-to Post Code", 1, 6), Pos, Pos);
        END;
        //To Details <<
        ShipGetGSTCompRate(SalesShipHeader."No.", 0, JOItemsG);//Update GST calculations
        ShipReadEwbDtls();//Update Transport Details

        ShipReadItemList();
        //JsonTextWriter.WriteEndObject;
        //ExportAsJson(SalesShipHeader."No.",Path);
    end;

    local procedure ShipEWayHeadDetails(SupplyType: Text; SupplySubType: Text; Doctype: Text; DocNo: Text; DocDate: Text)
    begin
        /*
        JsonTextWriter.WriteStartObject;
        JsonTextWriter.WritePropertyName('supplyType');
        JsonTextWriter.WriteValue(SupplyType);
        JsonTextWriter.WritePropertyName('subSupplyType');
        JsonTextWriter.WriteValue(SupplySubType);
        //Export >>
        IF SupplySubType = '3' THEN BEGIN
            JsonTextWriter.WritePropertyName('subSupplyDesc');
            JsonTextWriter.WriteValue('');
        END;
        //Export <<
        JsonTextWriter.WritePropertyName('docType');
        JsonTextWriter.WriteValue(Doctype);
        JsonTextWriter.WritePropertyName('docNo');
        JsonTextWriter.WriteValue(DocNo);
        JsonTextWriter.WritePropertyName('docDate');
        JsonTextWriter.WriteValue(DocDate);
        */
        JOsupplyTypeG.Add('supplyType', SupplyType);
        JOsupplyTypeG.Add('subSupplyType', SupplySubType);
        if SupplySubType = '3' then begin
            JOsupplyTypeG.Add('subSupplyDesc', '');
        end;
        JOsupplyTypeG.Add('docType', Doctype);
        JOsupplyTypeG.Add('docNo', DocNo);
        JOsupplyTypeG.Add('DocDate', DocDate);
    end;

    procedure ShipEwayFromDetails(FromGstin: Text; FromTrdName: Text; FromAdd1: Text; FromAdd2: Text; FromPlace: Text; FromPinCode: Text; ActFromStateCode: Text; FromStateCode: Text): Boolean
    var
        FromPinCodeInt: Integer;
        ActFromStateCodeInt: Integer;
        FromStateCodeInt: Integer;
    begin
        IF FromPinCode <> '' THEN
            EVALUATE(FromPinCodeInt, FromPinCode);
        IF ActFromStateCode <> '' THEN
            EVALUATE(ActFromStateCodeInt, ActFromStateCode);
        IF FromStateCode <> '' THEN
            EVALUATE(FromStateCodeInt, FromStateCode);
        /*
        JsonTextWriter.WritePropertyName('fromGstin');
        JsonTextWriter.WriteValue(FromGstin);
        JsonTextWriter.WritePropertyName('fromTrdName');
        JsonTextWriter.WriteValue(FromTrdName);
        JsonTextWriter.WritePropertyName('fromAddr1');
        JsonTextWriter.WriteValue(FromAdd1);
        JsonTextWriter.WritePropertyName('fromAddr2');
        JsonTextWriter.WriteValue(FromAdd2);
        JsonTextWriter.WritePropertyName('fromPlace');
        JsonTextWriter.WriteValue(FromPlace);
        JsonTextWriter.WritePropertyName('fromPincode');
        JsonTextWriter.WriteValue(FromPinCodeInt);
        JsonTextWriter.WritePropertyName('actFromStateCode');
        JsonTextWriter.WriteValue(ActFromStateCodeInt);
        JsonTextWriter.WritePropertyName('fromStateCode');
        JsonTextWriter.WriteValue(FromStateCodeInt);
        */
        JOsupplyTypeG.Add('fromGstin', FromGstin);
        JOsupplyTypeG.Add('fromTrdName', FromTrdName);
        JOsupplyTypeG.Add('fromAddr1', FromAdd1);
        JOsupplyTypeG.Add('fromAddr2', FromAdd2);
        JOsupplyTypeG.Add('fromPlace', FromPlace);
        JOsupplyTypeG.Add('fromPincode', FromPinCodeInt);
        JOsupplyTypeG.Add('actFromStateCode', ActFromStateCodeInt);
        JOsupplyTypeG.Add('fromStateCode', FromStateCodeInt);
    end;

    procedure ShipEwayToDetails(ToGstin: Text; ToTrdName: Text; ToAdd1: Text; ToAdd2: Text; ToPlace: Text; ToPinCode: Text; ActFromStateCode: Text; ToStateCode: Text): Boolean
    var
        ToPinCodeInt: Integer;
        ActToStateCodeInt: Integer;
        ToStateCodeInt: Integer;
    begin
        IF ToPinCode <> '' THEN
            EVALUATE(ToPinCodeInt, ToPinCode);
        IF ActFromStateCode <> '' THEN
            EVALUATE(ActToStateCodeInt, ActFromStateCode);
        IF ToStateCode <> '' THEN
            EVALUATE(ToStateCodeInt, ToStateCode);
        /*JsonTextWriter.WritePropertyName('toGstin');
        JsonTextWriter.WriteValue(ToGstin);
        JsonTextWriter.WritePropertyName('toTrdName');
        JsonTextWriter.WriteValue(ToTrdName);
        JsonTextWriter.WritePropertyName('toAddr1');
        JsonTextWriter.WriteValue(ToAdd1);
        JsonTextWriter.WritePropertyName('toAddr2');
        JsonTextWriter.WriteValue(ToAdd2);
        JsonTextWriter.WritePropertyName('toPlace');
        JsonTextWriter.WriteValue(ToPlace);
        JsonTextWriter.WritePropertyName('toPincode');
        JsonTextWriter.WriteValue(ToPinCodeInt);
        */
        JOsupplyTypeG.Add('toGstin', ToGstin);
        JOsupplyTypeG.Add('toTrdName', ToTrdName);
        JOsupplyTypeG.Add('toAddr1', ToAdd1);
        JOsupplyTypeG.Add('toAddr2', ToAdd2);
        JOsupplyTypeG.Add('toPlace', ToPlace);
        JOsupplyTypeG.Add('toPincode', ToPinCodeInt);
        //JsonTextWriter.WritePropertyName('actToStateCode');
        IF SalesShipHeader."GST Customer Type" = SalesShipHeader."GST Customer Type"::Export THEN
            // JsonTextWriter.WriteValue('97')
            JOsupplyTypeG.Add('actToStateCode', '97')
        ELSE
            // JsonTextWriter.WriteValue(ActToStateCodeInt);
            JOsupplyTypeG.Add('actToStateCode', ActToStateCodeInt);

        //JsonTextWriter.WritePropertyName('toStateCode');
        //JsonTextWriter.WriteValue(ToStateCodeInt);
        JOsupplyTypeG.Add('toStateCode', ToStateCodeInt);
        //Export >>
        IF SalesShipHeader."GST Customer Type" = SalesShipHeader."GST Customer Type"::Export THEN BEGIN
            /* JsonTextWriter.WritePropertyName('transactionType');
             JsonTextWriter.WriteValue(FORMAT(SalesShipHeader."Transaction Type"));
             JsonTextWriter.WritePropertyName('dispatchFromGSTIN');
             JsonTextWriter.WriteValue('');
             JsonTextWriter.WritePropertyName('dispatchFromTradeName');
             JsonTextWriter.WriteValue(FORMAT(SalesShipHeader."Sell-to Customer Name"));
             JsonTextWriter.WritePropertyName('shipToGSTIN');
             JsonTextWriter.WriteValue('');
             JsonTextWriter.WritePropertyName('shipToTradeName');
             JsonTextWriter.WriteValue(ToAdd1);
             JsonTextWriter.WritePropertyName('otherValue');
             JsonTextWriter.WriteValue('');*/
            JOsupplyTypeG.Add('transactionType', SalesInvoiceHeader."Transaction Type");
            JOsupplyTypeG.Add('dispatchFromGSTIN', '');
            JOsupplyTypeG.Add('dispatchFromTradeName', SalesInvoiceHeader."Sell-to Customer Name");
            JOsupplyTypeG.Add('ShipToGSTIN', '');
            JOsupplyTypeG.Add('shipToTradeName', ToAdd1);
            JOsupplyTypeG.Add('otherValue', '');
        END;
        //Export <<
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
                    EXIT(StateBuff."State Code (GST Reg. No.)");
                END ELSE
                    EXIT('99');
            END ELSE
                IF SalesShipLine."GST Place of Supply" = SalesShipLine."GST Place of Supply"::"Ship-to Address" THEN BEGIN
                    IF NOT (SalesShipHeader."GST Customer Type" = SalesShipHeader."GST Customer Type"::Export) THEN BEGIN
                        StateBuff.GET(SalesShipHeader."GST Ship-to State Code");
                        EXIT(StateBuff."State Code (GST Reg. No.)");
                    END ELSE
                        EXIT('99');
                END;
    end;

    local procedure ShipUpdateEwayCalculations(CgstValue: Decimal; SgstValue: Decimal; IgstValue: Decimal; CessValue: Decimal; Var JOItemsL: JsonObject)
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
        /* JsonTextWriter.WritePropertyName('totalValue');
         JsonTextWriter.WriteValue(ABS(TotalInvValue));
         JsonTextWriter.WritePropertyName('cgstValue');
         JsonTextWriter.WriteValue(CgstValue);
         JsonTextWriter.WritePropertyName('sgstValue');
         JsonTextWriter.WriteValue(SgstValue);
         JsonTextWriter.WritePropertyName('igstValue');
         JsonTextWriter.WriteValue(IgstValue);
         JsonTextWriter.WritePropertyName('cessValue');
         JsonTextWriter.WriteValue(CessValue);
         */
        JOsupplyTypeG.Add('totalValue', Abs(TotalInvValue));
        JOsupplyTypeG.Add('totalValue', ABS(TotalInvValue));
        JOsupplyTypeG.Add('cgstValue', CgstValue);
        JOsupplyTypeG.Add('sgstValue', SgstValue);
        JOsupplyTypeG.Add('igstValue', IgstValue);
        JOsupplyTypeG.Add('cessValue', CessValue);
        //Export >>
        IF SalesShipHeader."GST Customer Type" = SalesShipHeader."GST Customer Type"::Export THEN BEGIN
            // JsonTextWriter.WritePropertyName('cessNonAdvolValue');
            // JsonTextWriter.WriteValue('');
            JOsupplyTypeG.Add('cessNonAdvolValue', '');
        END;
        //Export <<
        //JsonTextWriter.WritePropertyName('totInvValue');


        //JsonTextWriter.WriteValue(TotalInvValue + TotalValue);
        JOsupplyTypeG.Add('totInvValue', TotalInvValue + TotalValue);
    end;

    local procedure ShipGetGSTCompRate(DocNo: Code[20]; LineNo: Integer; Var JOItemsL: JsonObject)
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
            ShipUpdateEwayCalculations(CgstAmt, SgstAmt, IgstAmt, CessAmt, JOItemsL)//Header Json
        ELSE BEGIN
            /* JsonTextWriter.WritePropertyName('cgstRate');
             JsonTextWriter.WriteValue(CgstRt);
             JsonTextWriter.WritePropertyName('sgstRate');
             JsonTextWriter.WriteValue(SgstRt);
             JsonTextWriter.WritePropertyName('igstRate');
             JsonTextWriter.WriteValue(IgstRt);
             JsonTextWriter.WritePropertyName('cessRate');
             JsonTextWriter.WriteValue(CesRt);*/
            JOItemsL.Add('cgstRate', CgstRt);
            JOItemsL.Add('sgstRate', SgstRt);
            JOItemsL.Add('igstRate', IgstRt);
            JOItemsL.Add('cessRate', CesRt);
            //Export >>
            IF SalesShipHeader."GST Customer Type" = SalesShipHeader."GST Customer Type"::Export THEN BEGIN
                //JsonTextWriter.WritePropertyName('cessNonAdvolValue');
                // JsonTextWriter.WriteValue(CesNonAdvlAmt);
                JOItemsL.Add('cessNonAdvolValue', CesNonAdvlAmt);
            END ELSE BEGIN
                //JsonTextWriter.WritePropertyName('cessAdvol');
                //JsonTextWriter.WriteValue(CesAdvlAmt);
                JOItemsL.Add('cessAdvol', CesAdvlAmt);
            END;
            //Export <<
        END;
    end;

    local procedure ShipEWayTransportDetails()
    begin
    end;

    local procedure ShipReadEwbDtls()
    var
        TransId: Text[15];
        TransName: Text[100];
        TransMode: Text[1];
        Distance: Text[4];
        TransDocNo: Text[15];
        TransDocDt: Text[10];
        VehNo: Text[20];
        VehType: Text[1];
        TransportMethod: Record "Transport Method";
        DistanceTxt: Text;
        TransactionType: Text;
    begin
        TransId := '';//Transit/GSTIN
        TransactionType := SalesShipHeader."Transaction Type";
        IF TransportMethod.GET(SalesShipHeader."Transport Method") THEN BEGIN
            TransName := '';
            /*
            CASE TransportMethod."Transportation Mode" OF
                TransportMethod."Transportation Mode"::Road:
                    TransMode := '1';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := '2';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := '3';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := '4';
            END;
            */
            TransMode := SalesShipHeader."Transport Method";
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
                VehType := 'O';
            SalesShipHeader."Vehicle Type"::Regular:
                VehType := 'R';
        END;


        ShipWriteEwbDtls(TransId, TransName, TransMode, Distance, TransDocNo, TransDocDt, VehNo, VehType, TransactionType);
    end;

    local procedure ShipWriteEwbDtls(TransId: Text[15]; TransName: Text[100]; TransMode: Text[1]; Distance: Text[4]; TransDocNo: Text[15]; TransDocDt: Text[10]; VehNo: Text[20]; VehType: Text[1]; TransactionType: Text)
    begin
        /*JsonTextWriter.WritePropertyName('transporterId');
        JsonTextWriter.WriteValue(TransId);
        JsonTextWriter.WritePropertyName('transporterName');
        JsonTextWriter.WriteValue(TransName);
        JsonTextWriter.WritePropertyName('transDocNo');
        JsonTextWriter.WriteValue(TransDocNo);
        JsonTextWriter.WritePropertyName('transMode');
        JsonTextWriter.WriteValue(TransMode);
        JsonTextWriter.WritePropertyName('transDistance');
        JsonTextWriter.WriteValue(Distance);
        JsonTextWriter.WritePropertyName('transDocDate');
        JsonTextWriter.WriteValue(TransDocDt);
        JsonTextWriter.WritePropertyName('vehicleNo');
        JsonTextWriter.WriteValue(VehNo);
        JsonTextWriter.WritePropertyName('vehicleType');
        JsonTextWriter.WriteValue(VehType);
        JsonTextWriter.WritePropertyName('TransactionType');
        JsonTextWriter.WriteValue(TransactionType);*/
        JOsupplyTypeG.Add('transporterId', TransId);
        JOsupplyTypeG.Add('transporterName', TransName);
        JOsupplyTypeG.Add('transDocNo', TransDocNo);
        JOsupplyTypeG.Add('transMode', TransMode);
        JOsupplyTypeG.Add('transDistance', Distance);
        JOsupplyTypeG.Add('transDocDate', TransDocDt);
        JOsupplyTypeG.Add('vehicleNo', VehNo);
        JOsupplyTypeG.Add('vehicleType', VehType);
        JOsupplyTypeG.Add('TransactionType', TransactionType);
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
            // JsonTextWriter.WritePropertyName('itemList');
            // JsonTextWriter.WriteStartArray;
            REPEAT
                EVALUATE(HSNInt, SalesShipLine."HSN/SAC Code");
                /* JsonTextWriter.WriteStartObject;
                 JsonTextWriter.WritePropertyName('productName');
                 JsonTextWriter.WriteValue(SalesShipLine."No.");
                 JsonTextWriter.WritePropertyName('productDesc');
                 JsonTextWriter.WriteValue(SalesShipLine.Description);
                 JsonTextWriter.WritePropertyName('hsnCode');
                 JsonTextWriter.WriteValue(HSNInt);
                 JsonTextWriter.WritePropertyName('quantity');
                 JsonTextWriter.WriteValue(SalesShipLine.Quantity);
                 Uom.GET(SalesShipLine."Unit of Measure Code");
                 JsonTextWriter.WritePropertyName('qtyUnit');
                 JsonTextWriter.WriteValue(Uom.Code);

                 ShipGetGSTCompRate(SalesShipHeader."No.", SalesShipLine."Line No.");
                 TaxableValue := (SalesShipLine.Quantity * SalesShipLine."Unit Price") -
                                  ((SalesShipLine.Quantity * SalesShipLine."Unit Price") * SalesShipLine."Line Discount %" / 100);
                 IF SalesShipHeader."Currency Code" <> '' THEN
                     TaxableValue := (1 / SalesShipHeader."Currency Factor") * TaxableValue;
                 JsonTextWriter.WritePropertyName('taxableAmount');
                 JsonTextWriter.WriteValue(TaxableValue);
                 JsonTextWriter.WriteEndObject;*/
                Clear(JOItemsG);
                Uom.GET(SalesShipLine."Unit of Measure Code");
                JOItemsG.Add('productName', SalesShipLine."No.");
                JOItemsG.Add('productDesc', SalesShipLine.Description);
                JOItemsG.Add('hsnCode', HSNInt);
                JOItemsG.Add('quantity', SalesShipLine.Quantity);
                JOItemsG.Add('qtyUnit', Uom.Code);
                ShipGetGSTCompRate(SalesInvoiceHeader."No.", SalesShipLine."Line No.", JOItemsG);
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
    begin
        LocationBuff.GET(SalesShipHeader."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        IF IsPosting THEN BEGIN
            Reason := EWayBillingSetup."Vehicle Reason";
            ReasonRemarks := EWayBillingSetup."Vehicle Remarks";
            VechileNo := SalesShipHeader."Vehicle No.";
        END ELSE BEGIN
            Reason := EWayBillingSetup."Vehicle Reason";
            ReasonRemarks := EWayBillingSetup."Vehicle Remarks";
            //B2BUPG1.0<<
            //VechileNo := Windows.InputBox(Title3, '', '', 10, 10);
            Clear(EWayUpdate);
            Commit();
            EWayUpdate.SetData(0);
            if EWayUpdate.RunModal() = Action::Yes then
                EWayUpdate.GetData(0, VechileNo);
            //B2BUPG1.0<<
            IF VechileNo = ' ' THEN
                EXIT;
            UpdateOldVechileNoInEWayEntry(2, SalesShipHeader."No.", SalesShipHeader."Vehicle No.");
            SalesShipHeader."Vehicle No." := VechileNo;
            SalesShipHeader.MODIFY;
        END;

        IF TransportMethod.GET(SalesShipHeader."Transport Method") THEN BEGIN
            TransMode := SalesShipHeader."Transport Method";
        END;

        TransDocNo := '';
        TransDocDate := 0D;
        ShipWriteVechileJson(GetEwayBillIngNo(TransType::"Sales Shpt", SalesShipHeader."No."), VechileNo, LocationBuff.City, StateBuff."State Code for eTDS/TCS", Reason, ReasonRemarks,
                        TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode);
    end;

    local procedure ShipWriteVechileJson(EwbNo: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; ReasonCode: Text; ReasonRem: Text; TransDocNo: Text; TransDocDate: Text; TransMode: Text)
    var
        EwbBigInt: BigInteger;
    begin
        /*JsonTextWriter.WriteStartObject();
        JsonTextWriter.WritePropertyName('EwbNo');
        JsonTextWriter.WriteValue(EwbNo);
        JsonTextWriter.WritePropertyName('VehicleNo');
        JsonTextWriter.WriteValue(VehicleNo);
        JsonTextWriter.WritePropertyName('FromPlace');
        JsonTextWriter.WriteValue(FromPlace);
        JsonTextWriter.WritePropertyName('FromState');
        JsonTextWriter.WriteValue(FromState);
        JsonTextWriter.WritePropertyName('ReasonCode');
        JsonTextWriter.WriteValue(ReasonCode);
        JsonTextWriter.WritePropertyName('ReasonRem');
        JsonTextWriter.WriteValue(ReasonRem);
        JsonTextWriter.WritePropertyName('TransDocNo');
        JsonTextWriter.WriteValue(TransDocNo);
        JsonTextWriter.WritePropertyName('TransDocDate');
        JsonTextWriter.WriteValue(TransDocDate);
        JsonTextWriter.WritePropertyName('TransMode');
        JsonTextWriter.WriteValue(TransMode);
        JsonTextWriter.WriteEndObject();*/
        JOVehicleG.Add('EwbNo', EwbNo);
        JOVehicleG.Add('VehicleNo', VehicleNo);
        JOVehicleG.Add('FromPlace', FromPlace);
        JOVehicleG.Add('FromState', FromState);
        JOVehicleG.Add('ReasonCode', ReasonCode);
        JOVehicleG.Add('ReasonRem', ReasonRem);
        JOVehicleG.Add('TransDocNo', TransDocNo);
        JOVehicleG.Add('TransDocDate', '');
        JOVehicleG.add('TransMode', TransMode);

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
        ShipWriteCancelJson(GetEwayBillIngNo(TransType::"Sales Shpt", SalesShipHeader."No."), Reason, ReasonRemarks);
    end;

    local procedure ShipWriteCancelJson(EWBNo: Text; CancelReason: Text; CancelRemarks: Text)
    begin
        /*JsonTextWriter.WriteStartObject();
        JsonTextWriter.WritePropertyName('ewbNo');
        JsonTextWriter.WriteValue(EWBNo);
        JsonTextWriter.WritePropertyName('cancelRsnCode');
        JsonTextWriter.WriteValue(CancelReason);
        JsonTextWriter.WritePropertyName('cancelRmrk');
        JsonTextWriter.WriteValue(CancelRemarks);
        JsonTextWriter.WriteEndObject();*/
        JOCancelG.Add('ewbNo', EWBNo);
        JOCancelG.Add('cancelRsnCode', CancelReason);
        JOCancelG.Add('cancelRmrk', CancelRemarks);
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

        ////B2BUPG1.0<<
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

        // JsonTextWriter.WriteStartObject();
        // JsonTextWriter.WritePropertyName('ewbNo');
        // JsonTextWriter.WriteValue(RejectEwayBillNo);
        // JsonTextWriter.WriteEndObject();
        JORejEWayNoG.Add('ewbNo', RejectEwayBillNo);

        EVALUATE(RejEwayBillNo, RejectEwayBillNo);
        // ExportAsJson(RejDocumentNo, PathSaved);
    end;

    local procedure ShipUpdateTransportJson()
    var
        TransportID: Text;
        TransportIDError: Label 'Transport Id must have value';
    begin
        //B2BUPG1.0>>
        //TransportID := Windows.InputBox('Transporter ID :', '', '', 10, 10);
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(2);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetData(2, TransportID);
        //B2BUPG1.0<<
        IF TransportID = '' THEN
            ERROR(TransportIDError);
        // JsonTextWriter.WriteStartObject();
        // JsonTextWriter.WritePropertyName('ewbNo');
        // JsonTextWriter.WriteValue(GetEwayBillIngNo(TransType::"Sales Shpt", SalesShipHeader."No."));
        // JsonTextWriter.WritePropertyName('transporterId');
        // JsonTextWriter.WriteValue(TransportID);
        // JsonTextWriter.WriteEndObject();
        JOUpdatetransportIDG.Add('ewbNo', GetEwayBillIngNo(TransType::"Sales Invoice", SalesInvoiceHeader."No."));
        JOUpdatetransportIDG.Add('transporterId', TransportID);
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
            TransMode := SalesShipHeader."Transport Method";
        END;
        TransDocNo := '';
        TransDocDate := 0D;
        ShipWriteExtendValidityJson(GetEwayBillIngNo(TransType::"Sales Shpt", SalesShipHeader."No."), SalesShipHeader."Vehicle No.", LocationBuff.City, StateBuff."State Code (GST Reg. No.)", RemainingDist, TransDocNo,
                      FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode, Reason, ReasonRemarks, Pin, 'T', SalesShipHeader."Transaction Type",
                      '', '', '');
    end;

    local procedure ShipWriteExtendValidityJson(EwbNo: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; RemainingDist: Integer; TransDocNo: Text; TransDocDate: Text; TransMode: Text; ReasonCode: Text; ReasonRem: Text; FromPincode: Integer; ConsignmentStatus: Text; TransitType: Text; AddressLine1: Text; AddressLine2: Text; AddressLine3: Text)
    begin
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('EwbNo');
         JsonTextWriter.WriteValue(EwbNo);
         JsonTextWriter.WritePropertyName('vehicleNo');
         JsonTextWriter.WriteValue(VehicleNo);
         JsonTextWriter.WritePropertyName('fromPlace');
         JsonTextWriter.WriteValue(FromPlace);
         JsonTextWriter.WritePropertyName('fromState');
         JsonTextWriter.WriteValue(FromState);
         JsonTextWriter.WritePropertyName('remainingDistance');
         JsonTextWriter.WriteValue(RemainingDist);
         JsonTextWriter.WritePropertyName('TransDocNo');
         JsonTextWriter.WriteValue(TransDocNo);
         JsonTextWriter.WritePropertyName('TransDocDate');
         JsonTextWriter.WriteValue(TransDocDate);
         JsonTextWriter.WritePropertyName('TransMode');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WritePropertyName('extnRsnCode');
         JsonTextWriter.WriteValue(ReasonCode);
         JsonTextWriter.WritePropertyName('extnRemarks');
         JsonTextWriter.WriteValue(ReasonRem);
         JsonTextWriter.WritePropertyName('fromPincode');
         JsonTextWriter.WriteValue(FromPincode);
         JsonTextWriter.WritePropertyName('consignmentStatus');
         JsonTextWriter.WriteValue(ConsignmentStatus);
         JsonTextWriter.WritePropertyName('transitType');
         JsonTextWriter.WriteValue(TransitType);
         JsonTextWriter.WritePropertyName('addressLine1');
         JsonTextWriter.WriteValue(AddressLine1);
         JsonTextWriter.WritePropertyName('addressLine2');
         JsonTextWriter.WriteValue(AddressLine2);
         JsonTextWriter.WritePropertyName('addressLine3');
         JsonTextWriter.WriteValue(AddressLine3);
         JsonTextWriter.WriteEndObject();
         */
        JOExtendValidityJsonG.Add('EwbNo', EwbNo);
        JOExtendValidityJsonG.Add('vehicleNo', VehicleNo);
        JOExtendValidityJsonG.Add('fromPlace', FromPlace);
        JOExtendValidityJsonG.Add('fromState', FromState);
        JOExtendValidityJsonG.Add('remainingDistance', RemainingDist);
        JOExtendValidityJsonG.Add('TransDocNo', TransDocNo);
        JOExtendValidityJsonG.Add('TransDocDate', TransDocDate);
        JOExtendValidityJsonG.Add('TransMode', '5');
        JOExtendValidityJsonG.Add('extnRsnCode', ReasonCode);
        JOExtendValidityJsonG.Add('extnRemarks', ReasonRem);
        JOExtendValidityJsonG.add('fromPincode', FromPincode);
        JOExtendValidityJsonG.add('consignmentStatus', ConsignmentStatus);
        JOExtendValidityJsonG.add('transitType', 'R');
        JOExtendValidityJsonG.Add('addressLine1', AddressLine1);
        JOExtendValidityJsonG.Add('addressLine2', AddressLine2);
        JOExtendValidityJsonG.Add('addressLine3', AddressLine3);
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

    //B2BUPG1.0>>
    /*local procedure ShipCalculateGSTAmounts(DocumentNo: Code[20]; LineNo: Integer; GSTJurisdiction: Option; GSTStateCode: Code[10]; GSTGroupCode: Code[20]; EffectiveDate: Date; Amount: Decimal; CurrencyCode: Code[10]; CurrencyFactor: Decimal; UnitCost: Decimal; LineQty: Decimal; UOM: Code[10]; ItemNo: Code[20]; Discount: Decimal)
    var
        GSTComponent: Record "Tax Component";
        GSTSetup: Record "GST Setup";
        //GSTCalculationBuffer: Record Table16421;
        TotalGSTAmount: Decimal;
        Test: Page "Sales Order";
        SalePost: Codeunit "GST Posting Management";
    begin
        GSTComponent.SETCURRENTKEY("Calculation Order");
        GSTComponent.SETRANGE("GST Jurisdiction Type", GSTJurisdiction);
        IF GSTComponent.FINDSET THEN
            REPEAT
                IF ShipGetGSTSetup(GSTSetup, GSTStateCode, GSTGroupCode, GSTComponent.Code, EffectiveDate) <> '' THEN BEGIN
                    ShipInitGSTCalculationBuffer(
                              GSTSetup, DocumentNo, LineNo, UnitCost,
                              EffectiveDate, CurrencyCode, CurrencyFactor, Amount, Discount)
                END;
            UNTIL GSTComponent.NEXT = 0;
    end;

    procedure ShipGetGSTSetup(var GSTSetup: Record "GST Setup"; GSTStateCode: Code[10]; GSTGroupCode: Code[20]; GSTComponentCode: Code[10]; EffectiveDate: Date): Code[20]
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

    local procedure ShipDeleteGSTEntry()
    var
        GSTEntry: Record "GST Entry";
    begin
        GSTEntry.RESET;
        GSTEntry.SETRANGE("Document No.", SalesShipHeader."No.");
        IF GSTEntry.FINDSET THEN
            GSTEntry.DELETEALL;
    end;
    //B2BUPG1.0>>
    local procedure GetComponentName(PurchaseLine: Record "Purchase Line";
        GSTSetup: Record "GST Setup"): Code[30]
    var
        ComponentName: Code[30];
    begin
        if GSTSetup."GST Tax Type" = GSTLbl then
            if PurchaseLine."GST Jurisdiction Type" = PurchaseLine."GST Jurisdiction Type"::Interstate then
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
    begin
        IF PurchHeader."GST Vendor Type" = PurchHeader."GST Vendor Type"::Import THEN BEGIN
            Gstin := 'URP';
            Pin := '999999';
            SubSupplyType := '3';
            SubType := 'I';
        END ELSE BEGIN
            Gstin := PurchHeader."Vendor GST Reg. No.";// "Vendor GST Reg. No.";
            Pin := COPYSTR(PurchHeader."Pay-to Post Code", 1, 6);
            SubSupplyType := '1';
            SubType := 'I';
        END;
        //EWB1.2 >>
        IF PurchHeader."GST Vendor Type" = PurchHeader."GST Vendor Type"::Unregistered THEN
            Gstin := 'URP';
        //EWB1.2 <<
        IF WareHouseRectHead."No." = '' THEN
            PurchEWayHeadDetails(SubType, SubSupplyType, 'INV', PurchHeader."Vendor Shipment No.", FORMAT(PurchHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>'))
        ELSE
            PurchEWayHeadDetails(SubType, SubSupplyType, 'INV', WareHouseRectHead."No.", FORMAT(WareHouseRectHead."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>')); //Header

        //From Details >>

        Pos := PurchGetEwayPos(PurchHeader."No.");
        PurchEwayFromDetails(Gstin, PurchHeader."Pay-to Name", PurchHeader."Pay-to Address", PurchHeader."Pay-to Address 2", PurchHeader."Pay-to City", Pin, Pos, Pos);
        //From Details <<

        //To Details >>
        LocationBuff.GET(PurchHeader."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        //LocationBuff."GST Registration No."
        PurchEwayToDetails(LocationBuff."GST Registration No.", CompanyInfo.Name, LocationBuff.Address, LocationBuff."Address 2", LocationBuff.City
                        , LocationBuff."Post Code", StateBuff."State Code (GST Reg. No.)", StateBuff."State Code (GST Reg. No.)");
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
        // JsonTextWriter.WriteEndObject;
        //ExportAsJson(PurchHeader."No.",Path);
    end;

    local procedure PurchEWayHeadDetails(SupplyType: Text; SupplySubType: Text; Doctype: Text; DocNo: Text; DocDate: Text)
    begin
        /*JsonTextWriter.WriteStartObject;
        JsonTextWriter.WritePropertyName('supplyType');
        JsonTextWriter.WriteValue(SupplyType);
        JsonTextWriter.WritePropertyName('subSupplyType');
        JsonTextWriter.WriteValue(SupplySubType);

        JsonTextWriter.WritePropertyName('docType');
        JsonTextWriter.WriteValue(Doctype);
        JsonTextWriter.WritePropertyName('docNo');
        JsonTextWriter.WriteValue(DocNo);
        JsonTextWriter.WritePropertyName('docDate');
        JsonTextWriter.WriteValue(DocDate);*/
        JOsupplyTypeG.Add('supplyType', SupplyType);
        JOsupplyTypeG.Add('subSupplyType', SupplySubType);
        if SupplySubType = '3' then begin
            JOsupplyTypeG.Add('subSupplyDesc', '');
        end;
        JOsupplyTypeG.Add('docType', Doctype);
        JOsupplyTypeG.Add('docNo', DocNo);
        JOsupplyTypeG.Add('DocDate', DocDate);
    end;

    procedure PurchEwayFromDetails(FromGstin: Text; FromTrdName: Text; FromAdd1: Text; FromAdd2: Text; FromPlace: Text; FromPinCode: Text; ActFromStateCode: Text; FromStateCode: Text): Boolean
    var
        FromPinCodeInt: Integer;
        ActFromStateCodeInt: Integer;
        FromStateCodeInt: Integer;
    begin
        IF FromPinCode <> '' THEN
            EVALUATE(FromPinCodeInt, FromPinCode);
        IF ActFromStateCode <> '' THEN
            EVALUATE(ActFromStateCodeInt, ActFromStateCode);
        IF FromStateCode <> '' THEN
            EVALUATE(FromStateCodeInt, FromStateCode);
        /* JsonTextWriter.WritePropertyName('fromGstin');
         JsonTextWriter.WriteValue(FromGstin);
         JsonTextWriter.WritePropertyName('fromTrdName');
         JsonTextWriter.WriteValue(FromTrdName);
         JsonTextWriter.WritePropertyName('fromAddr1');
         JsonTextWriter.WriteValue(FromAdd1);
         JsonTextWriter.WritePropertyName('fromAddr2');
         JsonTextWriter.WriteValue(FromAdd2);
         JsonTextWriter.WritePropertyName('fromPlace');
         JsonTextWriter.WriteValue(FromPlace);
         JsonTextWriter.WritePropertyName('fromPincode');
         JsonTextWriter.WriteValue(FromPinCodeInt);
         JsonTextWriter.WritePropertyName('actFromStateCode');
         JsonTextWriter.WriteValue(ActFromStateCodeInt);
         JsonTextWriter.WritePropertyName('fromStateCode');
         JsonTextWriter.WriteValue(FromStateCodeInt);*/
        JOsupplyTypeG.Add('fromGstin', FromGstin);
        JOsupplyTypeG.Add('fromTrdName', FromTrdName);
        JOsupplyTypeG.Add('fromAddr1', FromAdd1);
        JOsupplyTypeG.Add('fromAddr2', FromAdd2);
        JOsupplyTypeG.Add('fromPlace', FromPlace);
        JOsupplyTypeG.Add('fromPincode', FromPinCodeInt);
        JOsupplyTypeG.Add('actFromStateCode', ActFromStateCodeInt);
        JOsupplyTypeG.Add('fromStateCode', FromStateCodeInt);
    end;

    procedure PurchEwayToDetails(ToGstin: Text; ToTrdName: Text; ToAdd1: Text; ToAdd2: Text; ToPlace: Text; ToPinCode: Text; ActFromStateCode: Text; ToStateCode: Text): Boolean
    var
        ToPinCodeInt: Integer;
        ActToStateCodeInt: Integer;
        ToStateCodeInt: Integer;
    begin
        IF ToPinCode <> '' THEN
            EVALUATE(ToPinCodeInt, ToPinCode);
        IF ActFromStateCode <> '' THEN
            EVALUATE(ActToStateCodeInt, ActFromStateCode);
        IF ToStateCode <> '' THEN
            EVALUATE(ToStateCodeInt, ToStateCode);
        /*JsonTextWriter.WritePropertyName('toGstin');
        JsonTextWriter.WriteValue(ToGstin);
        JsonTextWriter.WritePropertyName('toTrdName');
        JsonTextWriter.WriteValue(ToTrdName);
        JsonTextWriter.WritePropertyName('toAddr1');
        JsonTextWriter.WriteValue(ToAdd1);
        JsonTextWriter.WritePropertyName('toAddr2');
        JsonTextWriter.WriteValue(ToAdd2);
        JsonTextWriter.WritePropertyName('toPlace');
        JsonTextWriter.WriteValue(ToPlace);
        JsonTextWriter.WritePropertyName('toPincode');
        JsonTextWriter.WriteValue(ToPinCodeInt);
        JsonTextWriter.WritePropertyName('actToStateCode');
        JsonTextWriter.WriteValue(ActToStateCodeInt);
        JsonTextWriter.WritePropertyName('toStateCode');
        JsonTextWriter.WriteValue(ToStateCodeInt);*/
        JOsupplyTypeG.Add('toGstin', ToGstin);
        JOsupplyTypeG.Add('toTrdName', ToTrdName);
        JOsupplyTypeG.Add('toAddr1', ToAdd1);
        JOsupplyTypeG.Add('toAddr2', ToAdd2);
        JOsupplyTypeG.Add('toPlace', ToPlace);
        JOsupplyTypeG.Add('toPincode', ToPinCodeInt);
        JOsupplyTypeG.Add('actToStateCode', ActToStateCodeInt);
        JOsupplyTypeG.Add('toStateCode', ToStateCodeInt);
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
                EXIT(StateBuff."State Code (GST Reg. No.)");
            END ELSE BEGIN
                StateBuff.GET(PurchHeader.State);
                EXIT(StateBuff."State Code (GST Reg. No.)");
            END;
    end;

    local procedure PurchUpdateEwayCalculations(CgstValue: Decimal; SgstValue: Decimal; IgstValue: Decimal; CessValue: Decimal; Var JOItemsL: JsonObject)
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
        /*  JsonTextWriter.WritePropertyName('totalValue');
          JsonTextWriter.WriteValue(ABS(TotalInvValue));
          JsonTextWriter.WritePropertyName('cgstValue');
          JsonTextWriter.WriteValue(CgstValue);
          JsonTextWriter.WritePropertyName('sgstValue');
          JsonTextWriter.WriteValue(SgstValue);
          JsonTextWriter.WritePropertyName('igstValue');
          JsonTextWriter.WriteValue(IgstValue);
          JsonTextWriter.WritePropertyName('cessValue');
          JsonTextWriter.WriteValue(CessValue);
          JsonTextWriter.WritePropertyName('totInvValue');

          JsonTextWriter.WriteValue(TotalInvValue + TotalValue);
          */
        JOItemsL.Add('totalValue', Abs(TotalInvValue));
        JOItemsL.Add('totalValue', ABS(TotalInvValue));
        JOItemsL.Add('cgstValue', CgstValue);
        JOItemsL.Add('sgstValue', SgstValue);
        JOItemsL.Add('igstValue', IgstValue);
        JOItemsL.Add('cessValue', CessValue);
        JOItemsL.Add('totInvValue', TotalInvValue + TotalValue);
    end;

    local procedure PurchGetGSTCompRate(DocNo: Code[20]; LineNo: Integer; Var JOItemL: JsonObject)
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
            PurchUpdateEwayCalculations(CgstAmt, SgstAmt, IgstAmt, CessAmt, JOItemL)//Header Json
        ELSE BEGIN
            /*JsonTextWriter.WritePropertyName('cgstRate');
            JsonTextWriter.WriteValue(CgstRt);
            JsonTextWriter.WritePropertyName('sgstRate');
            JsonTextWriter.WriteValue(SgstRt);
            JsonTextWriter.WritePropertyName('igstRate');
            JsonTextWriter.WriteValue(IgstRt);
            JsonTextWriter.WritePropertyName('cessRate');
            JsonTextWriter.WriteValue(CesRt);
            JsonTextWriter.WritePropertyName('cessAdvol');
            JsonTextWriter.WriteValue(CesAdvlAmt);*/
            JOItemL.Add('cgstRate', CgstRt);
            JOItemL.Add('sgstRate', SgstRt);
            JOItemL.Add('igstRate', IgstRt);
            JOItemL.Add('cessRate', CesRt);
            JOItemL.Add('cessAdvol', CesAdvlAmt);
        END;
    end;

    local procedure PurchReadEwbDtls()
    var
        TransId: Text[15];
        TransName: Text[100];
        TransMode: Text[1];
        Distance: Text[4];
        TransDocNo: Text[15];
        TransDocDt: Text[10];
        VehNo: Text[20];
        VehType: Text[1];
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
                    TransMode := '1';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := '2';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := '3';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := '4';
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
                VehType := 'O';
            PurchHeader."Vehicle Type"::Regular:
                VehType := 'R';
        END;


        PurchWriteEwbDtls(TransId, TransName, TransMode, Distance, TransDocNo, TransDocDt, VehNo, VehType, TransactionType);
    end;

    local procedure PurchWriteEwbDtls(TransId: Text[15]; TransName: Text[100]; TransMode: Text[1]; Distance: Text[4]; TransDocNo: Text[15]; TransDocDt: Text[10]; VehNo: Text[20]; VehType: Text[1]; TransactionType: Text)
    begin
        /* JsonTextWriter.WritePropertyName('transporterId');
         JsonTextWriter.WriteValue(TransId);
         JsonTextWriter.WritePropertyName('transporterName');
         JsonTextWriter.WriteValue(TransName);
         JsonTextWriter.WritePropertyName('transDocNo');
         JsonTextWriter.WriteValue(TransDocNo);
         JsonTextWriter.WritePropertyName('transMode');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WritePropertyName('transDistance');
         JsonTextWriter.WriteValue(Distance);
         JsonTextWriter.WritePropertyName('transDocDate');
         JsonTextWriter.WriteValue(TransDocDt);
         JsonTextWriter.WritePropertyName('vehicleNo');
         JsonTextWriter.WriteValue(VehNo);
         JsonTextWriter.WritePropertyName('vehicleType');
         JsonTextWriter.WriteValue(VehType);
         JsonTextWriter.WritePropertyName('TransactionType');
         JsonTextWriter.WriteValue(TransactionType);
         */
        JOsupplyTypeG.Add('transporterId', TransId);
        JOsupplyTypeG.Add('transporterName', TransName);
        JOsupplyTypeG.Add('transDocNo', TransDocNo);
        JOsupplyTypeG.Add('transMode', TransMode);
        JOsupplyTypeG.Add('transDistance', Distance);
        JOsupplyTypeG.Add('transDocDate', TransDocDt);
        JOsupplyTypeG.Add('vehicleNo', VehNo);
        JOsupplyTypeG.Add('vehicleType', VehType);
        JOsupplyTypeG.Add('TransactionType', TransactionType);
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
            //  JsonTextWriter.WritePropertyName('itemList');
            //JsonTextWriter.WriteStartArray;
            REPEAT
                EVALUATE(HSNInt, PurchLine."HSN/SAC Code");
                /* JsonTextWriter.WriteStartObject;
                 JsonTextWriter.WritePropertyName('productName');
                 JsonTextWriter.WriteValue(PurchLine."No.");
                 JsonTextWriter.WritePropertyName('productDesc');
                 JsonTextWriter.WriteValue(PurchLine.Description);
                 JsonTextWriter.WritePropertyName('hsnCode');
                 JsonTextWriter.WriteValue(HSNInt);
                 JsonTextWriter.WritePropertyName('quantity');
                 JsonTextWriter.WriteValue(PurchLine.Quantity);
                 Uom.GET(PurchLine."Unit of Measure Code");
                 JsonTextWriter.WritePropertyName('qtyUnit');
                 JsonTextWriter.WriteValue(Uom."International Standard Code");

                 PurchGetGSTCompRate(PurchHeader."No.", PurchLine."Line No.");

                 JsonTextWriter.WritePropertyName('taxableAmount');
                 IF PurchHeader."Currency Code" <> '' THEN
                     JsonTextWriter.WriteValue((1 / PurchHeader."Currency Factor") * PurchLine."Line Amount")
                 ELSE
                     JsonTextWriter.WriteValue(PurchLine."Line Amount");
                 JsonTextWriter.WriteEndObject;*/
                Clear(JOItemsG);
                Uom.GET(PurchLine."Unit of Measure Code");
                JOItemsG.Add('productName', PurchLine."No.");
                JOItemsG.Add('productDesc', PurchLine.Description);
                JOItemsG.Add('hsnCode', HSNInt);
                JOItemsG.Add('quantity', PurchLine.Quantity);
                JOItemsG.Add('qtyUnit', Uom.Code);
                PurchGetGSTCompRate(PurchHeader."No.", PurchLine."Line No.", JOItemsG);
                JOItemsG.Add('taxableAmount', ((1 / SalesInvoiceHeader."Currency Factor") * PurchLine."Line Amount"));
                JArrayItemsG.Add(JOItemsG);
            UNTIL PurchLine.NEXT = 0;
            JOsupplyTypeG.Add('itemList', JArrayItemsG);
            // JsonTextWriter.WriteEndArray;
        END;
    end;

    local procedure WhseReadItemList()
    var
        WhseRectLine: Record "Warehouse Receipt Line";
        SalesLinesErr: Label 'E-Way allowes only 1000 lines per Invoice. Curent transaction is having %1 lines.', Comment = '%1 = Sales Lines count';
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
            //  JsonTextWriter.WritePropertyName('itemList');
            //  JsonTextWriter.WriteStartArray;
            REPEAT
                PurchLine.RESET;
                PurchLine.SETRANGE("Document Type", PurchLine."Document Type"::Order);
                PurchLine.SETRANGE("Document No.", WhseRectLine."Source No.");
                PurchLine.SETRANGE("Line No.", WhseRectLine."Source Line No.");
                IF PurchLine.FINDFIRST THEN;

                EVALUATE(HSNInt, PurchLine."HSN/SAC Code");
                /* JsonTextWriter.WriteStartObject;
                 JsonTextWriter.WritePropertyName('productName');
                 JsonTextWriter.WriteValue(PurchLine."No.");
                 JsonTextWriter.WritePropertyName('productDesc');
                 JsonTextWriter.WriteValue(PurchLine.Description);
                 JsonTextWriter.WritePropertyName('hsnCode');
                 JsonTextWriter.WriteValue(HSNInt);
                 JsonTextWriter.WritePropertyName('quantity');
                 JsonTextWriter.WriteValue(WhseRectLine."Qty. to Receive");
                 Uom.GET(PurchLine."Unit of Measure Code");
                 JsonTextWriter.WritePropertyName('qtyUnit');
                 JsonTextWriter.WriteValue(Uom."International Standard Code");

                 PurchGetGSTCompRate(WhseRectLine."No.", WhseRectLine."Line No.");

                 JsonTextWriter.WritePropertyName('taxableAmount');
                 IF PurchHeader."Currency Code" <> '' THEN
                     JsonTextWriter.WriteValue((1 / PurchHeader."Currency Factor") * (PurchLine."Direct Unit Cost" * WhseRectLine."Qty. to Receive"))
                 ELSE
                     JsonTextWriter.WriteValue(PurchLine."Direct Unit Cost" * WhseRectLine."Qty. to Receive");
                 JsonTextWriter.WriteEndObject;*/
                Clear(JOItemsG);
                Uom.GET(PurchLine."Unit of Measure Code");
                JOItemsG.Add('productName', PurchLine."No.");
                JOItemsG.Add('productDesc', PurchLine.Description);
                JOItemsG.Add('hsnCode', HSNInt);
                JOItemsG.Add('quantity', PurchLine.Quantity);
                JOItemsG.Add('qtyUnit', Uom.Code);
                PurchGetGSTCompRate(PurchHeader."No.", PurchLine."Line No.", JOItemsG);
                JOItemsG.Add('taxableAmount', ((1 / SalesInvoiceHeader."Currency Factor") * PurchLine."Line Amount"));
                JArrayItemsG.Add(JOItemsG);
            UNTIL WhseRectLine.NEXT = 0;
            JOsupplyTypeG.Add('itemList', JArrayItemsG);
            //JsonTextWriter.WriteEndArray;
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
    begin
        LocationBuff.GET(PurchHeader."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        IF IsPosting THEN BEGIN
            Reason := EWayBillingSetup."Vehicle Reason";
            ReasonRemarks := EWayBillingSetup."Vehicle Remarks";
            VehicleNo := PurchHeader."Vehicle No.";
        END ELSE BEGIN
            Reason := EWayBillingSetup."Vehicle Reason";
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
            UpdateOldVechileNoInEWayEntry(3, PurchHeader."No.", PurchHeader."Vehicle No.");
            PurchHeader."Vehicle No." := VehicleNo;
            PurchHeader.MODIFY();
        END;

        IF TransportMethod.GET(PurchHeader."Transport Method") THEN BEGIN
            TransMode := PurchHeader."Transport Method";
        END;
        TransDocNo := '';
        TransDocDate := 0D;
        IF WareHouseRectHead."No." = '' THEN
            PurchWriteVechileJson(GetEwayBillIngNo(TransType::"Purch. Order", PurchHeader."No."), VehicleNo, LocationBuff.City, StateBuff."State Code for eTDS/TCS", Reason, ReasonRemarks,
                          TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode)
        ELSE
            PurchWriteVechileJson(GetEwayBillIngNo(TransType::"Whse. Rect", WareHouseRectHead."No."), VehicleNo, LocationBuff.City, StateBuff."State Code for eTDS/TCS", Reason, ReasonRemarks,
                      TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode)
    end;

    local procedure PurchWriteVechileJson(EwbNo: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; ReasonCode: Text; ReasonRem: Text; TransDocNo: Text; TransDocDate: Text; TransMode: Text)
    var
        EwbBigInt: BigInteger;
    begin
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('EwbNo');
         JsonTextWriter.WriteValue(EwbNo);
         JsonTextWriter.WritePropertyName('VehicleNo');
         JsonTextWriter.WriteValue(VehicleNo);
         JsonTextWriter.WritePropertyName('FromPlace');
         JsonTextWriter.WriteValue(FromPlace);
         JsonTextWriter.WritePropertyName('FromState');
         JsonTextWriter.WriteValue(FromState);
         JsonTextWriter.WritePropertyName('ReasonCode');
         JsonTextWriter.WriteValue(ReasonCode);
         JsonTextWriter.WritePropertyName('ReasonRem');
         JsonTextWriter.WriteValue(ReasonRem);
         JsonTextWriter.WritePropertyName('TransDocNo');
         JsonTextWriter.WriteValue(TransDocNo);
         JsonTextWriter.WritePropertyName('TransDocDate');
         JsonTextWriter.WriteValue(TransDocDate);
         JsonTextWriter.WritePropertyName('TransMode');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WriteEndObject();*/
        JOVehicleG.Add('EwbNo', EwbNo);
        JOVehicleG.Add('VehicleNo', VehicleNo);
        JOVehicleG.Add('FromPlace', FromPlace);
        JOVehicleG.Add('FromState', FromState);
        JOVehicleG.Add('ReasonCode', ReasonCode);
        JOVehicleG.Add('ReasonRem', ReasonRem);
        JOVehicleG.Add('TransDocNo', TransDocNo);
        JOVehicleG.Add('TransDocDate', '');
        JOVehicleG.add('TransMode', TransMode);
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
            exit;
        //B2BUPG1.0<<
        IF WareHouseRectHead."No." = '' THEN
            PurchWriteCancelJson(GetEwayBillIngNo(TransType::"Purch. Order", PurchHeader."No."), Reason, ReasonRemarks)
        ELSE
            PurchWriteCancelJson(GetEwayBillIngNo(TransType::"Whse. Rect", WareHouseRectHead."No."), Reason, ReasonRemarks);
    end;

    local procedure PurchWriteCancelJson(EWBNo: Text; CancelReason: Text; CancelRemarks: Text)
    begin
        // JsonTextWriter.WriteStartObject();
        // JsonTextWriter.WritePropertyName('ewbNo');
        // JsonTextWriter.WriteValue(EWBNo);
        // JsonTextWriter.WritePropertyName('cancelRsnCode');
        // JsonTextWriter.WriteValue(CancelReason);
        // JsonTextWriter.WritePropertyName('cancelRmrk');
        // JsonTextWriter.WriteValue(CancelRemarks);
        // JsonTextWriter.WriteEndObject();
        JOCancelG.Add('ewbNo', EWBNo);
        JOCancelG.Add('cancelRsnCode', CancelReason);
        JOCancelG.Add('cancelRmrk', CancelRemarks);
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

        // JsonTextWriter.WriteStartObject();
        // JsonTextWriter.WritePropertyName('ewbNo');
        // JsonTextWriter.WriteValue(RejectEwayBillNo);
        // JsonTextWriter.WriteEndObject();
        JORejEWayNoG.Add('ewbNo', RejectEwayBillNo);
        EVALUATE(RejEwayBillNo, RejectEwayBillNo);
        // ExportAsJson(RejDocumentNo, PathSaved);
    end;

    local procedure PurchUpdateTransportJson()
    var
        TransportID: Text;
        TransportIDError: Label 'Transport Id must have value';
    begin
        //B2BUPG1.0<<
        //TransportID := Windows.InputBox('Transporter ID :', '', '', 10, 10);
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(2);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetData(2, TransportID);
        //B2BUPG1.0<<
        IF TransportID = '' THEN
            ERROR(TransportIDError);
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('ewbNo');
         IF WareHouseRectHead."No." = '' THEN
             JsonTextWriter.WriteValue(GetEwayBillIngNo(TransType::"Purch. Order", PurchHeader."No."))
         ELSE
             JsonTextWriter.WriteValue(GetEwayBillIngNo(TransType::"Whse. Rect", WareHouseRectHead."No."));
         JsonTextWriter.WritePropertyName('transporterId');
         JsonTextWriter.WriteValue(TransportID);
         JsonTextWriter.WriteEndObject();
         */
        IF WareHouseRectHead."No." = '' THEN
            JOUpdatetransportIDG.Add('ewbNo', GetEwayBillIngNo(TransType::"Purch. Order", PurchHeader."No."))
        else
            JOUpdatetransportIDG.Add('ewbNo', GetEwayBillIngNo(TransType::"Whse. Rect", WareHouseRectHead."No."));
        JOUpdatetransportIDG.Add('transporterId', TransportID);
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
            TransMode := PurchHeader."Transport Method";
        END;

        TransDocNo := '';
        TransDocDate := 0D;
        IF WareHouseRectHead."No." = '' THEN
            PurchWriteExtendValidityJson(GetEwayBillIngNo(TransType::"Purch. Order", PurchHeader."No."), PurchHeader."Vehicle No.", LocationBuff.City, StateBuff."State Code (GST Reg. No.)", RemainingDist, TransDocNo,
                        FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode, Reason, ReasonRemarks, Pin, 'T', PurchHeader."Transaction Type",
                        '', '', '')
        ELSE
            PurchWriteExtendValidityJson(GetEwayBillIngNo(TransType::"Whse. Rect", WareHouseRectHead."No."), PurchHeader."Vehicle No.", LocationBuff.City, StateBuff."State Code (GST Reg. No.)", RemainingDist, TransDocNo,
                        FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode, Reason, ReasonRemarks, Pin, 'T', PurchHeader."Transaction Type",
                        '', '', '');
    end;

    local procedure PurchWriteExtendValidityJson(EwbNo: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; RemainingDist: Integer; TransDocNo: Text; TransDocDate: Text; TransMode: Text; ReasonCode: Text; ReasonRem: Text; FromPincode: Integer; ConsignmentStatus: Text; TransitType: Text; AddressLine1: Text; AddressLine2: Text; AddressLine3: Text)
    begin
        /*JsonTextWriter.WriteStartObject();
        JsonTextWriter.WritePropertyName('EwbNo');
        JsonTextWriter.WriteValue(EwbNo);
        JsonTextWriter.WritePropertyName('vehicleNo');
        JsonTextWriter.WriteValue(VehicleNo);
        JsonTextWriter.WritePropertyName('fromPlace');
        JsonTextWriter.WriteValue(FromPlace);
        JsonTextWriter.WritePropertyName('fromState');
        JsonTextWriter.WriteValue(FromState);
        JsonTextWriter.WritePropertyName('remainingDistance');
        JsonTextWriter.WriteValue(RemainingDist);
        JsonTextWriter.WritePropertyName('TransDocNo');
        JsonTextWriter.WriteValue(TransDocNo);
        JsonTextWriter.WritePropertyName('TransDocDate');
        JsonTextWriter.WriteValue(TransDocDate);
        JsonTextWriter.WritePropertyName('TransMode');
        JsonTextWriter.WriteValue(TransMode);
        JsonTextWriter.WritePropertyName('extnRsnCode');
        JsonTextWriter.WriteValue(ReasonCode);
        JsonTextWriter.WritePropertyName('extnRemarks');
        JsonTextWriter.WriteValue(ReasonRem);
        JsonTextWriter.WritePropertyName('fromPincode');
        JsonTextWriter.WriteValue(FromPincode);
        JsonTextWriter.WritePropertyName('consignmentStatus');
        JsonTextWriter.WriteValue(ConsignmentStatus);
        JsonTextWriter.WritePropertyName('transitType');
        JsonTextWriter.WriteValue(TransitType);
        JsonTextWriter.WritePropertyName('addressLine1');
        JsonTextWriter.WriteValue(AddressLine1);
        JsonTextWriter.WritePropertyName('addressLine2');
        JsonTextWriter.WriteValue(AddressLine2);
        JsonTextWriter.WritePropertyName('addressLine3');
        JsonTextWriter.WriteValue(AddressLine3);
        JsonTextWriter.WriteEndObject();*/
        JOExtendValidityJsonG.Add('EwbNo', EwbNo);
        JOExtendValidityJsonG.Add('vehicleNo', VehicleNo);
        JOExtendValidityJsonG.Add('fromPlace', FromPlace);
        JOExtendValidityJsonG.Add('fromState', FromState);
        JOExtendValidityJsonG.Add('remainingDistance', RemainingDist);
        JOExtendValidityJsonG.Add('TransDocNo', TransDocNo);
        JOExtendValidityJsonG.Add('TransDocDate', TransDocDate);
        JOExtendValidityJsonG.Add('TransMode', TransMode);
        JOExtendValidityJsonG.Add('extnRsnCode', ReasonCode);
        JOExtendValidityJsonG.Add('extnRemarks', ReasonRem);
        JOExtendValidityJsonG.add('fromPincode', FromPincode);
        JOExtendValidityJsonG.add('consignmentStatus', ConsignmentStatus);
        JOExtendValidityJsonG.add('transitType', 'R');
        JOExtendValidityJsonG.Add('addressLine1', AddressLine1);
        JOExtendValidityJsonG.Add('addressLine2', AddressLine2);
        JOExtendValidityJsonG.Add('addressLine3', AddressLine3);
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

                //B2BUPG1.0>>
                /*
                PurchCalculateGSTAmounts(PurchHead."No.", PurchLine."Line No.", PurchLine."GST Jurisdiction Type".AsInteger, StateBuff."State Code (GST Reg. No.)",
                  PurchLine."GST Group Code", PurchHead."Posting Date", PurchLine."Qty. to Receive" * PurchLine."Direct Unit Cost",
                  PurchHead."Currency Code", PurchHead."Currency Factor", PurchLine."Direct Unit Cost", PurchLine.Quantity,
                  PurchLine."Unit of Measure Code", PurchLine."No.", PurchLine."Line Discount %");
                */
                GetGSTAmountsPurchase(PurchLine);
            //B2BUPG1.0<<
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
                // PurchCalculateGSTAmounts(WhseRectHead."No.", WhseRectLine."Line No.", PurchLine."GST Jurisdiction Type".AsInteger, StateBuff."State Code (GST Reg. No.)",
                //   PurchLine."GST Group Code", WhseRectHead."Posting Date", WhseRectLine."Qty. to Receive" * PurchLine."Direct Unit Cost",
                //   PurchHeader."Currency Code", PurchHeader."Currency Factor", PurchLine."Direct Unit Cost", PurchLine.Quantity,
                //   PurchLine."Unit of Measure Code", PurchLine."No.", PurchLine."Line Discount %");
                GetGSTAmountsPurchase(PurchLine);
            //B2BUPG1.0<<

            UNTIL WhseRectLine.NEXT = 0;
        END;
    end;

    //B2BUPG1.0>>
    /*local procedure PurchCalculateGSTAmounts(DocumentNo: Code[20]; LineNo: Integer; GSTJurisdiction: Option; GSTStateCode: Code[10]; GSTGroupCode: Code[20]; EffectiveDate: Date; Amount: Decimal; CurrencyCode: Code[10]; CurrencyFactor: Decimal; UnitCost: Decimal; LineQty: Decimal; UOM: Code[10]; ItemNo: Code[20]; Discount: Decimal)
    var
        GSTComponent: Record Table16405;
        GSTSetup: Record "GST Setup";
        //GSTCalculationBuffer: Record Table16421;
        TotalGSTAmount: Decimal;
    begin
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
    end;


    procedure PurchGetGSTSetup(var GSTSetup: Record "GST Setup"; GSTStateCode: Code[10]; GSTGroupCode: Code[20]; GSTComponentCode: Code[10]; EffectiveDate: Date): Code[20]
    begin
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
    end;*/
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
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        IF SalesCreditHeader."GST Customer Type" = SalesCreditHeader."GST Customer Type"::Export THEN BEGIN
            Gstin := 'URP';
            Pin := '999999';
            SubSupplyType := '3';
            SubType := 'I';
        END ELSE BEGIN
            Gstin := SalesCreditHeader."Customer GST Reg. No.";//"Customer GST Reg. No.";
            Pin := COPYSTR(SalesCreditHeader."Bill-to Post Code", 1, 6);
            SubSupplyType := '1';
            SubType := 'I';
        END;
        IF SalesCreditHeader."GST Customer Type" = SalesCreditHeader."GST Customer Type"::Unregistered THEN
            Gstin := 'URP';
        CreditEWayHeadDetails(SubType, SubSupplyType, 'INV', SalesCreditHeader."No.", FORMAT(SalesCreditHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>')); //Header

        //From Details >>
        Pos := CreditGetEwayPos(SalesCreditHeader."No.");
        LocationBuff.GET(SalesCreditHeader."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        SalesCrMemoLine.RESET;
        SalesCrMemoLine.SETRANGE("Document No.", SalesCreditHeader."No.");
        SalesCrMemoLine.SETFILTER("No.", '<>%1', '');//BugFix
        SalesCrMemoLine.SETRANGE(Exempted, FALSE);
        IF SalesCrMemoLine.FINDFIRST THEN BEGIN
            IF SalesCrMemoLine."GST Place of Supply" = SalesCrMemoLine."GST Place of Supply"::"Bill-to Address" THEN
                CreditEwayFromDetails(Gstin, SalesCreditHeader."Bill-to Name", SalesCreditHeader."Bill-to Address", SalesCreditHeader."Bill-to Address 2", SalesCreditHeader."Bill-to City", Pin, Pos, Pos);
            IF SalesCrMemoLine."GST Place of Supply" = SalesCrMemoLine."GST Place of Supply"::"Ship-to Address" THEN
                CreditEwayFromDetails(Gstin, SalesCreditHeader."Ship-to Name", SalesCreditHeader."Ship-to Address", SalesCreditHeader."Ship-to Address 2", SalesCreditHeader."Ship-to City", COPYSTR(SalesCreditHeader."Ship-to Post Code", 1, 6), Pos, Pos);
        END;
        //From Details <<

        //To Details >>
        CreditEwayToDetails(LocationBuff."GST Registration No.", CompanyInfo.Name, LocationBuff.Address, LocationBuff."Address 2", LocationBuff.City
                        , LocationBuff."Post Code", StateBuff."State Code (GST Reg. No.)", StateBuff."State Code (GST Reg. No.)");
        //To Details <<


        CreditGetGSTCompRate(SalesCreditHeader."No.", 0, JOItemsG);//Update GST calculations
        CreditReadEwbDtls();//Update Transport Details

        CreditReadItemList();
        //JsonTextWriter.WriteEndObject;
    end;

    local procedure CreditEWayHeadDetails(SupplyType: Text; SupplySubType: Text; Doctype: Text; DocNo: Text; DocDate: Text)
    begin
        /* JsonTextWriter.WriteStartObject;
         JsonTextWriter.WritePropertyName('supplyType');
         JsonTextWriter.WriteValue(SupplyType);
         JsonTextWriter.WritePropertyName('subSupplyType');
         JsonTextWriter.WriteValue(SupplySubType);
         //Export >>
         IF SupplySubType = '3' THEN BEGIN
             JsonTextWriter.WritePropertyName('subSupplyDesc');
             JsonTextWriter.WriteValue('');
         END;
         //Export <<
         JsonTextWriter.WritePropertyName('docType');
         JsonTextWriter.WriteValue(Doctype);
         JsonTextWriter.WritePropertyName('docNo');
         JsonTextWriter.WriteValue(DocNo);
         JsonTextWriter.WritePropertyName('docDate');
         JsonTextWriter.WriteValue(DocDate);*/
        JOsupplyTypeG.Add('supplyType', SupplyType);
        JOsupplyTypeG.Add('subSupplyType', SupplySubType);
        if SupplySubType = '3' then begin
            JOsupplyTypeG.Add('subSupplyDesc', '');
        end;
        JOsupplyTypeG.Add('docType', Doctype);
        JOsupplyTypeG.Add('docNo', DocNo);
        JOsupplyTypeG.Add('DocDate', DocDate);
    end;

    procedure CreditEwayFromDetails(FromGstin: Text; FromTrdName: Text; FromAdd1: Text; FromAdd2: Text; FromPlace: Text; FromPinCode: Text; ActFromStateCode: Text; FromStateCode: Text): Boolean
    var
        FromPinCodeInt: Integer;
        ActFromStateCodeInt: Integer;
        FromStateCodeInt: Integer;
    begin
        IF FromPinCode <> '' THEN
            EVALUATE(FromPinCodeInt, FromPinCode);
        IF ActFromStateCode <> '' THEN
            EVALUATE(ActFromStateCodeInt, ActFromStateCode);
        IF FromStateCode <> '' THEN
            EVALUATE(FromStateCodeInt, FromStateCode);
        /* JsonTextWriter.WritePropertyName('fromGstin');
         JsonTextWriter.WriteValue(FromGstin);
         JsonTextWriter.WritePropertyName('fromTrdName');
         JsonTextWriter.WriteValue(FromTrdName);
         JsonTextWriter.WritePropertyName('fromAddr1');
         JsonTextWriter.WriteValue(FromAdd1);
         JsonTextWriter.WritePropertyName('fromAddr2');
         JsonTextWriter.WriteValue(FromAdd2);
         JsonTextWriter.WritePropertyName('fromPlace');
         JsonTextWriter.WriteValue(FromPlace);
         JsonTextWriter.WritePropertyName('fromPincode');
         JsonTextWriter.WriteValue(FromPinCodeInt);
         JsonTextWriter.WritePropertyName('actFromStateCode');
         JsonTextWriter.WriteValue(ActFromStateCodeInt);
         JsonTextWriter.WritePropertyName('fromStateCode');
         JsonTextWriter.WriteValue(FromStateCodeInt);*/
        JOsupplyTypeG.Add('fromGstin', FromGstin);
        JOsupplyTypeG.Add('fromTrdName', FromTrdName);
        JOsupplyTypeG.Add('fromAddr1', FromAdd1);
        JOsupplyTypeG.Add('fromAddr2', FromAdd2);
        JOsupplyTypeG.Add('fromPlace', FromPlace);
        JOsupplyTypeG.Add('fromPincode', FromPinCodeInt);
        JOsupplyTypeG.Add('actFromStateCode', ActFromStateCodeInt);
        JOsupplyTypeG.Add('fromStateCode', FromStateCodeInt);
    end;

    procedure CreditEwayToDetails(ToGstin: Text; ToTrdName: Text; ToAdd1: Text; ToAdd2: Text; ToPlace: Text; ToPinCode: Text; ActFromStateCode: Text; ToStateCode: Text): Boolean
    var
        ToPinCodeInt: Integer;
        ActToStateCodeInt: Integer;
        ToStateCodeInt: Integer;
    begin
        IF ToPinCode <> '' THEN
            EVALUATE(ToPinCodeInt, ToPinCode);
        IF ActFromStateCode <> '' THEN
            EVALUATE(ActToStateCodeInt, ActFromStateCode);
        IF ToStateCode <> '' THEN
            EVALUATE(ToStateCodeInt, ToStateCode);
        /*JsonTextWriter.WritePropertyName('toGstin');
        JsonTextWriter.WriteValue(ToGstin);
        JsonTextWriter.WritePropertyName('toTrdName');
        JsonTextWriter.WriteValue(ToTrdName);
        JsonTextWriter.WritePropertyName('toAddr1');
        JsonTextWriter.WriteValue(ToAdd1);
        JsonTextWriter.WritePropertyName('toAddr2');
        JsonTextWriter.WriteValue(ToAdd2);
        JsonTextWriter.WritePropertyName('toPlace');
        JsonTextWriter.WriteValue(ToPlace);
        JsonTextWriter.WritePropertyName('toPincode');
        JsonTextWriter.WriteValue(ToPinCodeInt);
        JsonTextWriter.WritePropertyName('actToStateCode');
        //Export >>
        IF (SalesCreditHeader."GST Customer Type" IN [SalesCreditHeader."GST Customer Type"::Export, SalesCreditHeader."GST Customer Type"::"SEZ Development",
                                                  SalesCreditHeader."GST Customer Type"::"SEZ Unit"]) THEN
            JsonTextWriter.WriteValue('97')
        ELSE
            JsonTextWriter.WriteValue(ActToStateCodeInt);

        JsonTextWriter.WritePropertyName('toStateCode');
        JsonTextWriter.WriteValue(ToStateCodeInt);
*/
        JOsupplyTypeG.Add('toGstin', ToGstin);
        JOsupplyTypeG.Add('toTrdName', ToTrdName);
        JOsupplyTypeG.Add('toAddr1', ToAdd1);
        JOsupplyTypeG.Add('toAddr2', ToAdd2);
        JOsupplyTypeG.Add('toPlace', ToPlace);
        JOsupplyTypeG.Add('toPincode', ToPinCodeInt);
        //JsonTextWriter.WritePropertyName('actToStateCode');
        IF SalesCreditHeader."GST Customer Type" = SalesCreditHeader."GST Customer Type"::Export THEN
            // JsonTextWriter.WriteValue('97')
            JOsupplyTypeG.Add('actToStateCode', '97')
        ELSE
            // JsonTextWriter.WriteValue(ActToStateCodeInt);
            JOsupplyTypeG.Add('actToStateCode', ActToStateCodeInt);

        //JsonTextWriter.WritePropertyName('toStateCode');
        //JsonTextWriter.WriteValue(ToStateCodeInt);
        JOsupplyTypeG.Add('toStateCode', ToStateCodeInt);
        IF SalesCreditHeader."GST Customer Type" = SalesCreditHeader."GST Customer Type"::Export THEN BEGIN
            /*JsonTextWriter.WritePropertyName('transactionType');
            JsonTextWriter.WriteValue(FORMAT(SalesCreditHeader."Transaction Type"));
            JsonTextWriter.WritePropertyName('dispatchFromGSTIN');
            JsonTextWriter.WriteValue('');
            JsonTextWriter.WritePropertyName('dispatchFromTradeName');
            JsonTextWriter.WriteValue(FORMAT(SalesCreditHeader."Sell-to Customer Name"));
            JsonTextWriter.WritePropertyName('ShipToGSTIN');
            JsonTextWriter.WriteValue('');
            JsonTextWriter.WritePropertyName('shipToTradeName');
            JsonTextWriter.WriteValue(ToAdd1);
            JsonTextWriter.WritePropertyName('otherValue');
            JsonTextWriter.WriteValue('');*/
            JOsupplyTypeG.Add('transactionType', SalesInvoiceHeader."Transaction Type");
            JOsupplyTypeG.Add('dispatchFromGSTIN', '');
            JOsupplyTypeG.Add('dispatchFromTradeName', SalesInvoiceHeader."Sell-to Customer Name");
            JOsupplyTypeG.Add('ShipToGSTIN', '');
            JOsupplyTypeG.Add('shipToTradeName', ToAdd1);
            JOsupplyTypeG.Add('otherValue', '');
        END;
        //Export <<
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
                    EXIT(StateBuff."State Code (GST Reg. No.)");
                END ELSE
                    EXIT('99');
            END ELSE
                IF SalesCredLine."GST Place of Supply" = SalesCredLine."GST Place of Supply"::"Ship-to Address" THEN BEGIN
                    IF NOT (SalesCreditHeader."GST Customer Type" = SalesCreditHeader."GST Customer Type"::Export) THEN BEGIN
                        StateBuff.GET(SalesCreditHeader."GST Ship-to State Code");
                        EXIT(StateBuff."State Code (GST Reg. No.)");
                    END ELSE
                        EXIT('99');
                END;
    end;

    local procedure CreditUpdateEwayCalculations(TotalValue: Decimal; CgstValue: Decimal; SgstValue: Decimal; IgstValue: Decimal; CessValue: Decimal; Var JOItemsL: JsonObject)
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
        /*JsonTextWriter.WritePropertyName('totalValue');
        JsonTextWriter.WriteValue(ABS(TotalInvValue));
        JsonTextWriter.WritePropertyName('cgstValue');
        JsonTextWriter.WriteValue(CgstValue);
        JsonTextWriter.WritePropertyName('sgstValue');
        JsonTextWriter.WriteValue(SgstValue);
        JsonTextWriter.WritePropertyName('igstValue');
        JsonTextWriter.WriteValue(IgstValue);
        JsonTextWriter.WritePropertyName('cessValue');
        JsonTextWriter.WriteValue(CessValue);
        //Export >>
        IF SalesCreditHeader."GST Customer Type" = SalesCreditHeader."GST Customer Type"::Export THEN BEGIN
            JsonTextWriter.WritePropertyName('cessNonAdvolValue');
            JsonTextWriter.WriteValue('');
        END;
        //Export <<
        JsonTextWriter.WritePropertyName('totInvValue');


        JsonTextWriter.WriteValue(TotalInvValue + TotalValue);
        */
        JOItemsL.Add('totalValue', Abs(TotalInvValue));
        JOItemsL.Add('totalValue', ABS(TotalInvValue));
        JOItemsL.Add('cgstValue', CgstValue);
        JOItemsL.Add('sgstValue', SgstValue);
        JOItemsL.Add('igstValue', IgstValue);
        JOItemsL.Add('cessValue', CessValue);
        //Export >>
        IF SalesCreditHeader."GST Customer Type" = SalesCreditHeader."GST Customer Type"::Export THEN BEGIN
            // JsonTextWriter.WritePropertyName('cessNonAdvolValue');
            // JsonTextWriter.WriteValue('');
            JOItemsL.Add('cessNonAdvolValue', '');
        END;
        //Export <<
        //JsonTextWriter.WritePropertyName('totInvValue');


        //JsonTextWriter.WriteValue(TotalInvValue + TotalValue);
        JOItemsL.Add('totInvValue', TotalInvValue + TotalValue);
    end;

    local procedure CreditGetGSTCompRate(DocNo: Code[20]; LineNo: Integer; Var JOItemL: JsonObject)
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
            CreditUpdateEwayCalculations(TotalValue, CgstAmt, SgstAmt, IgstAmt, CessAmt, JOItemL)//Header Json
        ELSE BEGIN
            /* JsonTextWriter.WritePropertyName('cgstRate');
             JsonTextWriter.WriteValue(CgstRt);
             JsonTextWriter.WritePropertyName('sgstRate');
             JsonTextWriter.WriteValue(SgstRt);
             JsonTextWriter.WritePropertyName('igstRate');
             JsonTextWriter.WriteValue(IgstRt);
             JsonTextWriter.WritePropertyName('cessRate');
             JsonTextWriter.WriteValue(CesRt);*/
            //Export >>
            JOItemL.Add('cgstRate', CgstRt);
            JOItemL.Add('sgstRate', SgstRt);
            JOItemL.Add('igstRate', IgstRt);
            JOItemL.Add('cessRate', CesRt);
            //Export >>
            IF SalesCreditHeader."GST Customer Type" = SalesCreditHeader."GST Customer Type"::Export THEN BEGIN
                //JsonTextWriter.WritePropertyName('cessNonAdvolValue');
                // JsonTextWriter.WriteValue(CesNonAdvlAmt);
                JOItemL.Add('cessNonAdvolValue', CesNonAdvlAmt);
            END ELSE BEGIN
                //JsonTextWriter.WritePropertyName('cessAdvol');
                //JsonTextWriter.WriteValue(CesAdvlAmt);
                JOItemL.Add('cessAdvol', CesAdvlAmt);
            END;
            //Export <<
        END;

    end;

    local procedure CreditReadEwbDtls()
    var
        TransId: Text[15];
        TransName: Text[100];
        TransMode: Text[1];
        Distance: Text[4];
        TransDocNo: Text[15];
        TransDocDt: Text[10];
        VehNo: Text[20];
        VehType: Text[1];
        TransportMethod: Record "Transport Method";
        DistanceTxt: Text;
        TransactionType: Text;
    begin
        TransId := '';//Transit/GSTIN
        TransactionType := SalesCreditHeader."Transaction Type";
        IF TransportMethod.GET(SalesCreditHeader."Transport Method") THEN BEGIN
            TransName := '';
            CASE TransportMethod."Transportation Mode" OF
                TransportMethod."Transportation Mode"::Road:
                    TransMode := '1';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := '2';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := '3';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := '4';
            END;
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
                VehType := 'O';
            SalesCreditHeader."Vehicle Type"::Regular:
                VehType := 'R';
        END;


        CreditWriteEwbDtls(TransId, TransName, TransMode, Distance, TransDocNo, TransDocDt, VehNo, VehType, TransactionType);
    end;

    local procedure CreditWriteEwbDtls(TransId: Text[15]; TransName: Text[100]; TransMode: Text[1]; Distance: Text[4]; TransDocNo: Text[15]; TransDocDt: Text[10]; VehNo: Text[20]; VehType: Text[1]; TransactionType: Text)
    begin
        /* JsonTextWriter.WritePropertyName('transporterId');
         JsonTextWriter.WriteValue(TransId);
         JsonTextWriter.WritePropertyName('transporterName');
         JsonTextWriter.WriteValue(TransName);
         JsonTextWriter.WritePropertyName('transDocNo');
         JsonTextWriter.WriteValue(TransDocNo);
         JsonTextWriter.WritePropertyName('transMode');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WritePropertyName('transDistance');
         JsonTextWriter.WriteValue(Distance);
         JsonTextWriter.WritePropertyName('transDocDate');
         JsonTextWriter.WriteValue(TransDocDt);
         JsonTextWriter.WritePropertyName('vehicleNo');
         JsonTextWriter.WriteValue(VehNo);
         JsonTextWriter.WritePropertyName('vehicleType');
         JsonTextWriter.WriteValue(VehType);
         IF NOT (SalesCreditHeader."GST Customer Type" = SalesCreditHeader."GST Customer Type"::Export) THEN BEGIN
             JsonTextWriter.WritePropertyName('TransactionType');
             JsonTextWriter.WriteValue(TransactionType);
         END;*/
        JOsupplyTypeG.Add('transporterId', TransId);
        JOsupplyTypeG.Add('transporterName', TransName);
        JOsupplyTypeG.Add('transDocNo', TransDocNo);
        JOsupplyTypeG.Add('transMode', TransMode);
        JOsupplyTypeG.Add('transDistance', Distance);
        JOsupplyTypeG.Add('transDocDate', TransDocDt);
        JOsupplyTypeG.Add('vehicleNo', VehNo);
        JOsupplyTypeG.Add('vehicleType', VehType);
        JOsupplyTypeG.Add('TransactionType', TransactionType);
    end;

    local procedure CreditReadItemList()
    var
        SalesCreditLine: Record "Sales Cr.Memo Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
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
            //JsonTextWriter.WritePropertyName('itemList');
            // JsonTextWriter.WriteStartArray;
            REPEAT
                EVALUATE(HSNInt, SalesCreditLine."HSN/SAC Code");
                /* JsonTextWriter.WriteStartObject;
                 JsonTextWriter.WritePropertyName('productName');
                 JsonTextWriter.WriteValue(SalesCreditLine."No.");
                 JsonTextWriter.WritePropertyName('productDesc');
                 JsonTextWriter.WriteValue(SalesCreditLine.Description);
                 JsonTextWriter.WritePropertyName('hsnCode');
                 JsonTextWriter.WriteValue(HSNInt);
                 JsonTextWriter.WritePropertyName('quantity');
                 JsonTextWriter.WriteValue(SalesCreditLine.Quantity);
                 Uom.GET(SalesCreditLine."Unit of Measure Code");
                 JsonTextWriter.WritePropertyName('qtyUnit');
                 JsonTextWriter.WriteValue(Uom."International Standard Code");

                 CreditGetGSTCompRate(SalesCreditHeader."No.", SalesCreditLine."Line No.");

                 JsonTextWriter.WritePropertyName('taxableAmount');
                 IF SalesCreditHeader."Currency Code" <> '' THEN
                     JsonTextWriter.WriteValue((1 / SalesCreditHeader."Currency Factor") * SalesCreditLine."Line Amount")
                 ELSE
                     JsonTextWriter.WriteValue(SalesCreditLine."Line Amount");
                 JsonTextWriter.WriteEndObject;*/
                Clear(JOItemsG);
                Uom.GET(SalesCreditLine."Unit of Measure Code");
                JOItemsG.Add('productName', SalesCreditLine."No.");
                JOItemsG.Add('productDesc', SalesCreditLine.Description);
                JOItemsG.Add('hsnCode', HSNInt);
                JOItemsG.Add('quantity', SalesCreditLine.Quantity);
                JOItemsG.Add('qtyUnit', Uom.Code);
                CreditGetGSTCompRate(SalesCreditHeader."No.", SalesCreditLine."Line No.", JOItemsG);
                JOItemsG.Add('taxableAmount', ((1 / SalesInvoiceHeader."Currency Factor") * SalesCreditLine."Line Amount"));
                JArrayItemsG.Add(JOItemsG);
            UNTIL SalesCreditLine.NEXT = 0;
            JOsupplyTypeG.Add('itemList', JArrayItemsG);
            //JsonTextWriter.WriteEndArray;
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
        Title1: Label '';
        Title2: Label '';

    begin
        LocationBuff.GET(SalesCreditHeader."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        IF IsPosting THEN BEGIN
            Reason := EWayBillingSetup."Vehicle Reason";
            ReasonRemarks := EWayBillingSetup."Vehicle Remarks";
            VehicleNo := SalesCreditHeader."Vehicle No.";
        END ELSE BEGIN
            Reason := EWayBillingSetup."Vehicle Reason";
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
            UpdateOldVechileNoInEWayEntry(7, SalesCreditHeader."No.", SalesCreditHeader."Vehicle No.");
            SalesCreditHeader."Vehicle No." := VehicleNo;
            SalesCreditHeader.MODIFY();
        END;

        IF TransportMethod.GET(SalesCreditHeader."Transport Method") THEN BEGIN
            CASE TransportMethod."Transportation Mode" OF
                TransportMethod."Transportation Mode"::Road:
                    TransMode := '1';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := '2';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := '3';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := '4';
            END;
        END;
        TransDocNo := '';
        TransDocDate := 0D;
        CreditWriteVechileJson(GetEwayBillIngNo(TransType::"Sales Crd Memo", SalesCreditHeader."No."), VehicleNo, LocationBuff.City, StateBuff."State Code for eTDS/TCS", Reason, ReasonRemarks,
                        TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode);
    end;

    local procedure CreditWriteVechileJson(EwbNo: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; ReasonCode: Text; ReasonRem: Text; TransDocNo: Text; TransDocDate: Text; TransMode: Text)
    var
        EwbBigInt: BigInteger;
    begin
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('EwbNo');
         JsonTextWriter.WriteValue(EwbNo);
         JsonTextWriter.WritePropertyName('VehicleNo');
         JsonTextWriter.WriteValue(VehicleNo);
         JsonTextWriter.WritePropertyName('FromPlace');
         JsonTextWriter.WriteValue(FromPlace);
         JsonTextWriter.WritePropertyName('FromState');
         JsonTextWriter.WriteValue(FromState);
         JsonTextWriter.WritePropertyName('ReasonCode');
         JsonTextWriter.WriteValue(ReasonCode);
         JsonTextWriter.WritePropertyName('ReasonRem');
         JsonTextWriter.WriteValue(ReasonRem);
         JsonTextWriter.WritePropertyName('TransDocNo');
         JsonTextWriter.WriteValue(TransDocNo);
         JsonTextWriter.WritePropertyName('TransDocDate');
         JsonTextWriter.WriteValue(TransDocDate);
         JsonTextWriter.WritePropertyName('TransMode');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WriteEndObject();
         */
        JOVehicleG.Add('EwbNo', EwbNo);
        JOVehicleG.Add('VehicleNo', VehicleNo);
        JOVehicleG.Add('FromPlace', FromPlace);
        JOVehicleG.Add('FromState', FromState);
        JOVehicleG.Add('ReasonCode', ReasonCode);
        JOVehicleG.Add('ReasonRem', ReasonRem);
        JOVehicleG.Add('TransDocNo', TransDocNo);
        JOVehicleG.Add('TransDocDate', '');
        JOVehicleG.add('TransMode', TransMode);
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
        CreditWriteCancelJson(GetEwayBillIngNo(TransType::"Sales Crd Memo", SalesCreditHeader."No."), Reason, ReasonRemarks);
    end;

    local procedure CreditWriteCancelJson(EWBNo: Text; CancelReason: Text; CancelRemarks: Text)
    begin
        // JsonTextWriter.WriteStartObject();
        // JsonTextWriter.WritePropertyName('ewbNo');
        // JsonTextWriter.WriteValue(EWBNo);
        // JsonTextWriter.WritePropertyName('cancelRsnCode');
        // JsonTextWriter.WriteValue(CancelReason);
        // JsonTextWriter.WritePropertyName('cancelRmrk');
        // JsonTextWriter.WriteValue(CancelRemarks);
        // JsonTextWriter.WriteEndObject();
        JOCancelG.Add('ewbNo', EWBNo);
        JOCancelG.Add('cancelRsnCode', CancelReason);
        JOCancelG.Add('cancelRmrk', CancelRemarks);
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

        // JsonTextWriter.WriteStartObject();
        // JsonTextWriter.WritePropertyName('ewbNo');
        // JsonTextWriter.WriteValue(RejectEwayBillNo);
        // JsonTextWriter.WriteEndObject();
        JORejEWayNoG.Add('ewbNo', RejectEwayBillNo);
        EVALUATE(RejEwayBillNo, RejectEwayBillNo);
        //ExportAsJson(RejDocumentNo, PathSaved);
    end;

    local procedure CreditUpdateTransportJson()
    var
        TransportID: Text;

        TransportIDError: Label 'Transport Id must have value';
    begin
        //B2BUPG1.0>>
        //TransportID := Windows.InputBox('Transporter ID :', '', '', 10, 10);
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(2);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetData(2, TransportID);
        //B2BUPG1.0<<
        IF TransportID = '' THEN
            ERROR(TransportIDError);
        // JsonTextWriter.WriteStartObject();
        // JsonTextWriter.WritePropertyName('ewbNo');
        // JsonTextWriter.WriteValue(GetEwayBillIngNo(TransType::"Sales Crd Memo", SalesCreditHeader."No."));
        // JsonTextWriter.WritePropertyName('transporterId');
        // JsonTextWriter.WriteValue(TransportID);
        // JsonTextWriter.WriteEndObject();

        JOUpdatetransportIDG.Add('ewbNo', GetEwayBillIngNo(TransType::"Sales Crd Memo", SalesCreditHeader."No."));
        JOUpdatetransportIDG.Add('transporterId', TransportID);
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
                    TransMode := '1';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := '2';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := '3';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := '4';
            END;
        END;

        TransDocNo := '';
        TransDocDate := 0D;
        CreditWriteExtendValidityJson(GetEwayBillIngNo(TransType::"Sales Crd Memo", SalesCreditHeader."No."), SalesCreditHeader."Vehicle No.", LocationBuff.City, StateBuff."State Code (GST Reg. No.)",
        RemainingDist, TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode, Reason, ReasonRemarks, Pin, 'T', SalesCreditHeader."Transaction Type",
                      SalesCreditHeader."Sell-to Address", SalesCreditHeader."Sell-to Address", SalesCreditHeader."Sell-to Address");
    end;

    local procedure CreditWriteExtendValidityJson(EwbNo: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; RemainingDist: Integer; TransDocNo: Text; TransDocDate: Text; TransMode: Text; ReasonCode: Text; ReasonRem: Text; FromPincode: Integer; ConsignmentStatus: Text; TransitType: Text; AddressLine1: Text; AddressLine2: Text; AddressLine3: Text)
    begin
        /*JsonTextWriter.WriteStartObject();
        JsonTextWriter.WritePropertyName('EwbNo');
        JsonTextWriter.WriteValue(EwbNo);
        JsonTextWriter.WritePropertyName('vehicleNo');
        JsonTextWriter.WriteValue(VehicleNo);
        JsonTextWriter.WritePropertyName('fromPlace');
        JsonTextWriter.WriteValue(FromPlace);
        JsonTextWriter.WritePropertyName('fromState');
        JsonTextWriter.WriteValue(FromState);
        JsonTextWriter.WritePropertyName('remainingDistance');
        JsonTextWriter.WriteValue(RemainingDist);
        JsonTextWriter.WritePropertyName('TransDocNo');
        JsonTextWriter.WriteValue(TransDocNo);
        JsonTextWriter.WritePropertyName('TransDocDate');
        JsonTextWriter.WriteValue(TransDocDate);
        JsonTextWriter.WritePropertyName('TransMode');
        JsonTextWriter.WriteValue('5');
        JsonTextWriter.WritePropertyName('extnRsnCode');
        JsonTextWriter.WriteValue(ReasonCode);
        JsonTextWriter.WritePropertyName('extnRemarks');
        JsonTextWriter.WriteValue(ReasonRem);
        JsonTextWriter.WritePropertyName('fromPincode');
        JsonTextWriter.WriteValue(FromPincode);
        JsonTextWriter.WritePropertyName('consignmentStatus');
        JsonTextWriter.WriteValue(ConsignmentStatus);
        JsonTextWriter.WritePropertyName('transitType');
        JsonTextWriter.WriteValue('R');
        JsonTextWriter.WritePropertyName('addressLine1');
        JsonTextWriter.WriteValue(AddressLine1);
        JsonTextWriter.WritePropertyName('addressLine2');
        JsonTextWriter.WriteValue(AddressLine2);
        JsonTextWriter.WritePropertyName('addressLine3');
        JsonTextWriter.WriteValue(AddressLine3);
        JsonTextWriter.WriteEndObject();*/
        JOExtendValidityJsonG.Add('EwbNo', EwbNo);
        JOExtendValidityJsonG.Add('vehicleNo', VehicleNo);
        JOExtendValidityJsonG.Add('fromPlace', FromPlace);
        JOExtendValidityJsonG.Add('fromState', FromState);
        JOExtendValidityJsonG.Add('remainingDistance', RemainingDist);
        JOExtendValidityJsonG.Add('TransDocNo', TransDocNo);
        JOExtendValidityJsonG.Add('TransDocDate', TransDocDate);
        JOExtendValidityJsonG.Add('TransMode', '5');
        JOExtendValidityJsonG.Add('extnRsnCode', ReasonCode);
        JOExtendValidityJsonG.Add('extnRemarks', ReasonRem);
        JOExtendValidityJsonG.add('fromPincode', FromPincode);
        JOExtendValidityJsonG.add('consignmentStatus', ConsignmentStatus);
        JOExtendValidityJsonG.add('transitType', 'R');
        JOExtendValidityJsonG.Add('addressLine1', AddressLine1);
        JOExtendValidityJsonG.Add('addressLine2', AddressLine2);
        JOExtendValidityJsonG.Add('addressLine3', AddressLine3);
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
            SubSupplyType := '3';
            SubType := 'O';
        END ELSE BEGIN
            Gstin := PurchCrMemoHdr."Vendor GST Reg. No.";//"Customer GST Reg. No.";
            Pin := COPYSTR(PurchCrMemoHdr."Pay-to Post Code", 1, 6);
            SubSupplyType := '1';
            SubType := 'O';
        END;
        IF PurchCrMemoHdr."GST Vendor Type" = PurchCrMemoHdr."GST Vendor Type"::Unregistered THEN
            Gstin := 'URP';
        PurchCreditEWayHeadDetails(SubType, SubSupplyType, 'INV', PurchCrMemoHdr."No.", FORMAT(PurchCrMemoHdr."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>')); //Header

        //From Details >>
        LocationBuff.GET(PurchCrMemoHdr."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        PurchCreditEwayFromDetails(LocationBuff."GST Registration No.", CompanyInfo.Name, LocationBuff.Address, LocationBuff."Address 2", LocationBuff.City
                        , LocationBuff."Post Code", StateBuff."State Code (GST Reg. No.)", StateBuff."State Code (GST Reg. No.)");
        //From Details <<

        //To Details >>
        Pos := PurchCreditGetEwayPos(PurchCrMemoHdr."No.");
        PurchCreditEwayToDetails(Gstin, PurchCrMemoHdr."Pay-to Name", PurchCrMemoHdr."Pay-to Address", PurchCrMemoHdr."Pay-to Address 2", PurchCrMemoHdr."Pay-to City", Pin, Pos, Pos);
        //To Details <<


        PurchCreditGetGSTCompRate(PurchCrMemoHdr."No.", 0, JOItemsG);//Update GST calculations
        PurchCreditReadEwbDtls();//Update Transport Details

        PurchCreditReadItemList();
        // JsonTextWriter.WriteEndObject;
    end;

    local procedure PurchCreditEWayHeadDetails(SupplyType: Text; SupplySubType: Text; Doctype: Text; DocNo: Text; DocDate: Text)
    begin
        /* JsonTextWriter.WriteStartObject;
         JsonTextWriter.WritePropertyName('supplyType');
         JsonTextWriter.WriteValue(SupplyType);
         JsonTextWriter.WritePropertyName('subSupplyType');
         JsonTextWriter.WriteValue(SupplySubType);
         //Export >>
         IF SupplySubType = '3' THEN BEGIN
             JsonTextWriter.WritePropertyName('subSupplyDesc');
             JsonTextWriter.WriteValue('');
         END;
         //Export <<
         JsonTextWriter.WritePropertyName('docType');
         JsonTextWriter.WriteValue(Doctype);
         JsonTextWriter.WritePropertyName('docNo');
         JsonTextWriter.WriteValue(DocNo);
         JsonTextWriter.WritePropertyName('docDate');
         JsonTextWriter.WriteValue(DocDate);*/
        JOsupplyTypeG.Add('supplyType', SupplyType);
        JOsupplyTypeG.Add('subSupplyType', SupplySubType);
        if SupplySubType = '3' then begin
            JOsupplyTypeG.Add('subSupplyDesc', '');
        end;
        JOsupplyTypeG.Add('docType', Doctype);
        JOsupplyTypeG.Add('docNo', DocNo);
        JOsupplyTypeG.Add('DocDate', DocDate);

    end;

    procedure PurchCreditEwayFromDetails(FromGstin: Text; FromTrdName: Text; FromAdd1: Text; FromAdd2: Text; FromPlace: Text; FromPinCode: Text; ActFromStateCode: Text; FromStateCode: Text): Boolean
    var
        FromPinCodeInt: Integer;
        ActFromStateCodeInt: Integer;
        FromStateCodeInt: Integer;
    begin
        IF FromPinCode <> '' THEN
            EVALUATE(FromPinCodeInt, FromPinCode);
        IF ActFromStateCode <> '' THEN
            EVALUATE(ActFromStateCodeInt, ActFromStateCode);
        IF FromStateCode <> '' THEN
            EVALUATE(FromStateCodeInt, FromStateCode);
        /*  JsonTextWriter.WritePropertyName('fromGstin');
          JsonTextWriter.WriteValue(FromGstin);
          JsonTextWriter.WritePropertyName('fromTrdName');
          JsonTextWriter.WriteValue(FromTrdName);
          JsonTextWriter.WritePropertyName('fromAddr1');
          JsonTextWriter.WriteValue(FromAdd1);
          JsonTextWriter.WritePropertyName('fromAddr2');
          JsonTextWriter.WriteValue(FromAdd2);
          JsonTextWriter.WritePropertyName('fromPlace');
          JsonTextWriter.WriteValue(FromPlace);
          JsonTextWriter.WritePropertyName('fromPincode');
          JsonTextWriter.WriteValue(FromPinCodeInt);
          JsonTextWriter.WritePropertyName('actFromStateCode');
          JsonTextWriter.WriteValue(ActFromStateCodeInt);
          JsonTextWriter.WritePropertyName('fromStateCode');
          JsonTextWriter.WriteValue(FromStateCodeInt);*/
        JOsupplyTypeG.Add('fromGstin', FromGstin);
        JOsupplyTypeG.Add('fromTrdName', FromTrdName);
        JOsupplyTypeG.Add('fromAddr1', FromAdd1);
        JOsupplyTypeG.Add('fromAddr2', FromAdd2);
        JOsupplyTypeG.Add('fromPlace', FromPlace);
        JOsupplyTypeG.Add('fromPincode', FromPinCodeInt);
        JOsupplyTypeG.Add('actFromStateCode', ActFromStateCodeInt);
        JOsupplyTypeG.Add('fromStateCode', FromStateCodeInt);

    end;

    procedure PurchCreditEwayToDetails(ToGstin: Text; ToTrdName: Text; ToAdd1: Text; ToAdd2: Text; ToPlace: Text; ToPinCode: Text; ActFromStateCode: Text; ToStateCode: Text): Boolean
    var
        ToPinCodeInt: Integer;
        ActToStateCodeInt: Integer;
        ToStateCodeInt: Integer;
    begin
        IF ToPinCode <> '' THEN
            EVALUATE(ToPinCodeInt, ToPinCode);
        IF ActFromStateCode <> '' THEN
            EVALUATE(ActToStateCodeInt, ActFromStateCode);
        IF ToStateCode <> '' THEN
            EVALUATE(ToStateCodeInt, ToStateCode);
        /* JsonTextWriter.WritePropertyName('toGstin');
         JsonTextWriter.WriteValue(ToGstin);
         JsonTextWriter.WritePropertyName('toTrdName');
         JsonTextWriter.WriteValue(ToTrdName);
         JsonTextWriter.WritePropertyName('toAddr1');
         JsonTextWriter.WriteValue(ToAdd1);
         JsonTextWriter.WritePropertyName('toAddr2');
         JsonTextWriter.WriteValue(ToAdd2);
         JsonTextWriter.WritePropertyName('toPlace');
         JsonTextWriter.WriteValue(ToPlace);
         JsonTextWriter.WritePropertyName('toPincode');
         JsonTextWriter.WriteValue(ToPinCodeInt);
         JsonTextWriter.WritePropertyName('actToStateCode');
         //Export >>
         IF (PurchCrMemoHdr."GST Vendor Type" IN [PurchCrMemoHdr."GST Vendor Type"::Import, PurchCrMemoHdr."GST Vendor Type"::Exempted,
                                                   PurchCrMemoHdr."GST Vendor Type"::SEZ]) THEN
             JsonTextWriter.WriteValue('97')
         ELSE
             JsonTextWriter.WriteValue(ActToStateCodeInt);

         JsonTextWriter.WritePropertyName('toStateCode');
         JsonTextWriter.WriteValue(ToStateCodeInt);*/
        JOsupplyTypeG.Add('toGstin', ToGstin);
        JOsupplyTypeG.Add('toTrdName', ToTrdName);
        JOsupplyTypeG.Add('toAddr1', ToAdd1);
        JOsupplyTypeG.Add('toAddr2', ToAdd2);
        JOsupplyTypeG.Add('toPlace', ToPlace);
        JOsupplyTypeG.Add('toPincode', ToPinCodeInt);
        // JOsupplyTypeG.Add()
        //Export >>
        IF (PurchCrMemoHdr."GST Vendor Type" IN [PurchCrMemoHdr."GST Vendor Type"::Import, PurchCrMemoHdr."GST Vendor Type"::Exempted,
                                                   PurchCrMemoHdr."GST Vendor Type"::SEZ]) THEN
            /// JsonTextWriter.WriteValue('97')
            JOsupplyTypeG.Add('actToStateCode', '97')
        ELSE
            //JsonTextWriter.WriteValue(ActToStateCodeInt);
            JOsupplyTypeG.Add('actToStateCode', ActToStateCodeInt);

        //JsonTextWriter.WritePropertyName('toStateCode');
        //JsonTextWriter.WriteValue(ToStateCodeInt);
        JOsupplyTypeG.Add('toStateCode', ToStateCodeInt);

        IF PurchCrMemoHdr."GST Vendor Type" = PurchCrMemoHdr."GST Vendor Type"::Import THEN BEGIN
            /* JsonTextWriter.WritePropertyName('transactionType');
             JsonTextWriter.WriteValue(FORMAT(PurchCrMemoHdr."Transaction Type"));
             JsonTextWriter.WritePropertyName('dispatchFromGSTIN');
             JsonTextWriter.WriteValue('');
             JsonTextWriter.WritePropertyName('dispatchFromTradeName');
             JsonTextWriter.WriteValue(FORMAT(PurchCrMemoHdr."Buy-from Vendor Name"));
             JsonTextWriter.WritePropertyName('ShipToGSTIN');
             JsonTextWriter.WriteValue('');
             JsonTextWriter.WritePropertyName('shipToTradeName');
             JsonTextWriter.WriteValue(ToAdd1);
             JsonTextWriter.WritePropertyName('otherValue');
             JsonTextWriter.WriteValue('');*/
            JOsupplyTypeG.Add('transactionType', SalesInvoiceHeader."Transaction Type");
            JOsupplyTypeG.Add('dispatchFromGSTIN', '');
            JOsupplyTypeG.Add('dispatchFromTradeName', SalesInvoiceHeader."Sell-to Customer Name");
            JOsupplyTypeG.Add('ShipToGSTIN', '');
            JOsupplyTypeG.Add('shipToTradeName', ToAdd1);
            JOsupplyTypeG.Add('otherValue', '');

        END;
        //Export <<
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
                EXIT(StateBuff."State Code (GST Reg. No.)");
            END ELSE BEGIN
                StateBuff.GET(PurchCrMemoHdr."Location State Code");
                EXIT(StateBuff."State Code (GST Reg. No.)");
            END;
    end;

    local procedure PurchCreditUpdateEwayCalculations(TotalValue: Decimal; CgstValue: Decimal; SgstValue: Decimal; IgstValue: Decimal; CessValue: Decimal; Var JOItemsL: JsonObject)
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
        /* JsonTextWriter.WritePropertyName('totalValue');
         JsonTextWriter.WriteValue(ABS(TotalInvValue));
         JsonTextWriter.WritePropertyName('cgstValue');
         JsonTextWriter.WriteValue(CgstValue);
         JsonTextWriter.WritePropertyName('sgstValue');
         JsonTextWriter.WriteValue(SgstValue);
         JsonTextWriter.WritePropertyName('igstValue');
         JsonTextWriter.WriteValue(IgstValue);
         JsonTextWriter.WritePropertyName('cessValue');
         JsonTextWriter.WriteValue(CessValue);*/
        JOItemsL.Add('totalValue', Abs(TotalInvValue));
        JOItemsL.Add('totalValue', ABS(TotalInvValue));
        JOItemsL.Add('cgstValue', CgstValue);
        JOItemsL.Add('sgstValue', SgstValue);
        JOItemsL.Add('igstValue', IgstValue);
        JOItemsL.Add('cessValue', CessValue);

        //Export >>
        IF PurchCrMemoHdr."GST Vendor Type" = PurchCrMemoHdr."GST Vendor Type"::Import THEN BEGIN
            // JsonTextWriter.WritePropertyName('cessNonAdvolValue');
            //  JsonTextWriter.WriteValue('');
            JOItemsL.Add('cessNonAdvolValue', '');
        END;
        //Export <<
        //  JsonTextWriter.WritePropertyName('totInvValue');


        // JsonTextWriter.WriteValue(TotalInvValue + TotalValue);
        JOItemsL.Add('totInvValue', TotalInvValue + TotalValue);
    end;

    local procedure PurchCreditGetGSTCompRate(DocNo: Code[20]; LineNo: Integer; Var JOItemL: JsonObject)
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
            IF TotalValue <> 0 THEN
                TotalValue := ROUND((1 / PurchCrMemoHdr."Currency Factor") * TotalValue, 0.01, '=');
        END;
        IF LineNo = 0 THEN
            PurchCreditUpdateEwayCalculations(TotalValue, CgstAmt, SgstAmt, IgstAmt, CessAmt, JOItemL)//Header Json
        ELSE BEGIN
            /* JsonTextWriter.WritePropertyName('cgstRate');
             JsonTextWriter.WriteValue(CgstRt);
             JsonTextWriter.WritePropertyName('sgstRate');
             JsonTextWriter.WriteValue(SgstRt);
             JsonTextWriter.WritePropertyName('igstRate');
             JsonTextWriter.WriteValue(IgstRt);
             JsonTextWriter.WritePropertyName('cessRate');
             JsonTextWriter.WriteValue(CesRt);
             //Export >>
             IF PurchCrMemoHdr."GST Vendor Type" = PurchCrMemoHdr."GST Vendor Type"::Import THEN BEGIN
                 JsonTextWriter.WritePropertyName('cessNonAdvolValue');
                 JsonTextWriter.WriteValue(CesNonAdvlAmt);
             END ELSE BEGIN
                 JsonTextWriter.WritePropertyName('cessAdvol');
                 JsonTextWriter.WriteValue(CesAdvlAmt);
             END;*/
            JOItemL.Add('cgstRate', CgstRt);
            JOItemL.Add('sgstRate', SgstRt);
            JOItemL.Add('igstRate', IgstRt);
            JOItemL.Add('cessRate', CesRt);
            //Export >>
            IF PurchCrMemoHdr."GST Vendor Type" = PurchCrMemoHdr."GST Vendor Type"::Import THEN BEGIN
                //JsonTextWriter.WritePropertyName('cessNonAdvolValue');
                // JsonTextWriter.WriteValue(CesNonAdvlAmt);
                JOItemL.Add('cessNonAdvolValue', CesNonAdvlAmt);
            END ELSE BEGIN
                //JsonTextWriter.WritePropertyName('cessAdvol');
                //JsonTextWriter.WriteValue(CesAdvlAmt);
                JOItemL.Add('cessAdvol', CesAdvlAmt);
            END;
            //Export <<
        END;
    end;

    local procedure PurchCreditReadEwbDtls()
    var
        TransId: Text[15];
        TransName: Text[100];
        TransMode: Text[1];
        Distance: Text[4];
        TransDocNo: Text[15];
        TransDocDt: Text[10];
        VehNo: Text[20];
        VehType: Text[1];
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
                    TransMode := '1';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := '2';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := '3';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := '4';
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
                VehType := 'O';
            PurchCrMemoHdr."Vehicle Type"::Regular:
                VehType := 'R';
        END;


        PurchCreditWriteEwbDtls(TransId, TransName, TransMode, Distance, TransDocNo, TransDocDt, VehNo, VehType, TransactionType);
    end;

    local procedure PurchCreditWriteEwbDtls(TransId: Text[15]; TransName: Text[100]; TransMode: Text[1]; Distance: Text[4]; TransDocNo: Text[15]; TransDocDt: Text[10]; VehNo: Text[20]; VehType: Text[1]; TransactionType: Text)
    begin
        /* JsonTextWriter.WritePropertyName('transporterId');
         JsonTextWriter.WriteValue(TransId);
         JsonTextWriter.WritePropertyName('transporterName');
         JsonTextWriter.WriteValue(TransName);
         JsonTextWriter.WritePropertyName('transDocNo');
         JsonTextWriter.WriteValue(TransDocNo);
         JsonTextWriter.WritePropertyName('transMode');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WritePropertyName('transDistance');
         JsonTextWriter.WriteValue(Distance);
         JsonTextWriter.WritePropertyName('transDocDate');
         JsonTextWriter.WriteValue(TransDocDt);
         JsonTextWriter.WritePropertyName('vehicleNo');
         JsonTextWriter.WriteValue(VehNo);
         JsonTextWriter.WritePropertyName('vehicleType');
         JsonTextWriter.WriteValue(VehType);
         IF NOT (PurchCrMemoHdr."GST Vendor Type" = PurchCrMemoHdr."GST Vendor Type"::Import) THEN BEGIN
             JsonTextWriter.WritePropertyName('TransactionType');
             JsonTextWriter.WriteValue(TransactionType);
         END;*/
        JOsupplyTypeG.Add('transporterId', TransId);
        JOsupplyTypeG.Add('transporterName', TransName);
        JOsupplyTypeG.Add('transDocNo', TransDocNo);
        JOsupplyTypeG.Add('transMode', TransMode);
        JOsupplyTypeG.Add('transDistance', Distance);
        JOsupplyTypeG.Add('transDocDate', TransDocDt);
        JOsupplyTypeG.Add('vehicleNo', VehNo);
        JOsupplyTypeG.Add('vehicleType', VehType);
        IF NOT (PurchCrMemoHdr."GST Vendor Type" = PurchCrMemoHdr."GST Vendor Type"::Import) THEN
            JOsupplyTypeG.Add('TransactionType', TransactionType);

    end;

    local procedure PurchCreditReadItemList()
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
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
            //JsonTextWriter.WritePropertyName('itemList');
            //  JsonTextWriter.WriteStartArray;
            REPEAT
                EVALUATE(HSNInt, PurchCrMemoLine."HSN/SAC Code");
                /*JsonTextWriter.WriteStartObject;
                JsonTextWriter.WritePropertyName('productName');
                JsonTextWriter.WriteValue(PurchCrMemoLine."No.");
                JsonTextWriter.WritePropertyName('productDesc');
                JsonTextWriter.WriteValue(PurchCrMemoLine.Description);
                JsonTextWriter.WritePropertyName('hsnCode');
                JsonTextWriter.WriteValue(HSNInt);
                JsonTextWriter.WritePropertyName('quantity');
                JsonTextWriter.WriteValue(PurchCrMemoLine.Quantity);
                Uom.GET(PurchCrMemoLine."Unit of Measure Code");
                JsonTextWriter.WritePropertyName('qtyUnit');
                JsonTextWriter.WriteValue(Uom."International Standard Code");

                PurchCreditGetGSTCompRate(PurchCrMemoHdr."No.", PurchCrMemoLine."Line No.");

                JsonTextWriter.WritePropertyName('taxableAmount');
                IF SalesCreditHeader."Currency Code" <> '' THEN
                    JsonTextWriter.WriteValue((1 / PurchCrMemoHdr."Currency Factor") * PurchCrMemoLine."Line Amount")
                ELSE
                    JsonTextWriter.WriteValue(PurchCrMemoLine."Line Amount");
                JsonTextWriter.WriteEndObject;*/
                Clear(JOItemsG);
                Uom.GET(PurchCrMemoLine."Unit of Measure Code");
                JOItemsG.Add('productName', PurchCrMemoLine."No.");
                JOItemsG.Add('productDesc', PurchCrMemoLine.Description);
                JOItemsG.Add('hsnCode', HSNInt);
                JOItemsG.Add('quantity', PurchCrMemoLine.Quantity);
                JOItemsG.Add('qtyUnit', Uom.Code);
                PurchCreditGetGSTCompRate(PurchCrMemoHdr."No.", PurchCrMemoLine."Line No.", JOItemsG);
                JOItemsG.Add('taxableAmount', ((1 / PurchCrMemoHdr."Currency Factor") * PurchCrMemoLine."Line Amount"));
                JArrayItemsG.Add(JOItemsG);
            UNTIL PurchCrMemoLine.NEXT = 0;
            JOsupplyTypeG.Add('itemList', JArrayItemsG);
            // JsonTextWriter.WriteEndArray;
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


    begin
        LocationBuff.GET(PurchCrMemoHdr."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        IF IsPosting THEN BEGIN
            Reason := EWayBillingSetup."Vehicle Reason";
            ReasonRemarks := EWayBillingSetup."Vehicle Remarks";
            VehicleNo := PurchCrMemoHdr."Vehicle No.";
        END ELSE BEGIN
            Reason := EWayBillingSetup."Vehicle Reason";
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
            UpdateOldVechileNoInEWayEntry(TransType::"Purch. Crd Memo", PurchCrMemoHdr."No.", PurchCrMemoHdr."Vehicle No.");
            PurchCrMemoHdr."Vehicle No." := VehicleNo;
            PurchCrMemoHdr.MODIFY();
        END;

        IF TransportMethod.GET(PurchCrMemoHdr."Transport Method") THEN BEGIN
            CASE TransportMethod."Transportation Mode" OF
                TransportMethod."Transportation Mode"::Road:
                    TransMode := '1';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := '2';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := '3';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := '4';
            END;
        END;
        TransDocNo := '';
        TransDocDate := 0D;
        PurchCreditWriteVechileJson(GetEwayBillIngNo(TransType::"Purch. Crd Memo", PurchCrMemoHdr."No."), VehicleNo, LocationBuff.City, StateBuff."State Code for eTDS/TCS", Reason, ReasonRemarks,
                       TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode);
    end;

    local procedure PurchCreditWriteVechileJson(EwbNo: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; ReasonCode: Text; ReasonRem: Text; TransDocNo: Text; TransDocDate: Text; TransMode: Text)
    var
        EwbBigInt: BigInteger;
    begin
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('EwbNo');
         JsonTextWriter.WriteValue(EwbNo);
         JsonTextWriter.WritePropertyName('VehicleNo');
         JsonTextWriter.WriteValue(VehicleNo);
         JsonTextWriter.WritePropertyName('FromPlace');
         JsonTextWriter.WriteValue(FromPlace);
         JsonTextWriter.WritePropertyName('FromState');
         JsonTextWriter.WriteValue(FromState);
         JsonTextWriter.WritePropertyName('ReasonCode');
         JsonTextWriter.WriteValue(ReasonCode);
         JsonTextWriter.WritePropertyName('ReasonRem');
         JsonTextWriter.WriteValue(ReasonRem);
         JsonTextWriter.WritePropertyName('TransDocNo');
         JsonTextWriter.WriteValue(TransDocNo);
         JsonTextWriter.WritePropertyName('TransDocDate');
         JsonTextWriter.WriteValue(TransDocDate);
         JsonTextWriter.WritePropertyName('TransMode');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WriteEndObject();*/
        JOVehicleG.Add('EwbNo', EwbNo);
        JOVehicleG.Add('VehicleNo', VehicleNo);
        JOVehicleG.Add('FromPlace', FromPlace);
        JOVehicleG.Add('FromState', FromState);
        JOVehicleG.Add('ReasonCode', ReasonCode);
        JOVehicleG.Add('ReasonRem', ReasonRem);
        JOVehicleG.Add('TransDocNo', TransDocNo);
        JOVehicleG.Add('TransDocDate', '');
        JOVehicleG.add('TransMode', TransMode);

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
        PurchCreditWriteCancelJson(GetEwayBillIngNo(TransType::"Purch. Crd Memo", PurchCrMemoHdr."No."), Reason, ReasonRemarks);
    end;

    local procedure PurchCreditWriteCancelJson(EWBNo: Text; CancelReason: Text; CancelRemarks: Text)
    begin
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('ewbNo');
         JsonTextWriter.WriteValue(EWBNo);
         JsonTextWriter.WritePropertyName('cancelRsnCode');
         JsonTextWriter.WriteValue(CancelReason);
         JsonTextWriter.WritePropertyName('cancelRmrk');
         JsonTextWriter.WriteValue(CancelRemarks);
         JsonTextWriter.WriteEndObject();*/
        JOCancelG.Add('ewbNo', EWBNo);
        JOCancelG.Add('cancelRsnCode', CancelReason);
        JOCancelG.Add('cancelRmrk', CancelRemarks);
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
        JsonTextWriter.WritePropertyName('ewbNo');
        JsonTextWriter.WriteValue(RejectEwayBillNo);
        JsonTextWriter.WriteEndObject();*/
        JORejEWayNoG.Add('ewbNo', RejectEwayBillNo);
        EVALUATE(RejEwayBillNo, RejectEwayBillNo);
        // ExportAsJson(RejDocumentNo, PathSaved);
    end;

    local procedure PurchCreditUpdateTransportJson()
    var
        TransportID: Text;
        TransportIDError: Label 'Transport Id must have value';
    begin
        //B2BUPG1.0>>
        //TransportID := Windows.InputBox('Transporter ID :', '', '', 10, 10);
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(2);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetData(2, TransportID);
        //B2BUPG1.0<<
        IF TransportID = '' THEN
            ERROR(TransportIDError);
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('ewbNo');
         JsonTextWriter.WriteValue(GetEwayBillIngNo(TransType::"Purch. Crd Memo", PurchCrMemoHdr."No."));
         JsonTextWriter.WritePropertyName('transporterId');
         JsonTextWriter.WriteValue(TransportID);
         JsonTextWriter.WriteEndObject();*/
        JOUpdatetransportIDG.Add('ewbNo', GetEwayBillIngNo(TransType::"Sales Crd Memo", SalesCreditHeader."No."));
        JOUpdatetransportIDG.Add('transporterId', TransportID);

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
                    TransMode := '1';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := '2';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := '3';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := '4';
            END;
        END;

        TransDocNo := '';
        TransDocDate := 0D;
        PurchCreditWriteExtendValidityJson(GetEwayBillIngNo(TransType::"Purch. Crd Memo", PurchCrMemoHdr."No."), PurchCrMemoHdr."Vehicle No.", LocationBuff.City, StateBuff."State Code (GST Reg. No.)",
         RemainingDist, TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode, Reason, ReasonRemarks, Pin, 'T', PurchCrMemoHdr."Transaction Type",
                       PurchCrMemoHdr."Buy-from Address", PurchCrMemoHdr."Buy-from Address", PurchCrMemoHdr."Buy-from Address");
    end;

    local procedure PurchCreditWriteExtendValidityJson(EwbNo: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; RemainingDist: Integer; TransDocNo: Text; TransDocDate: Text; TransMode: Text; ReasonCode: Text; ReasonRem: Text; FromPincode: Integer; ConsignmentStatus: Text; TransitType: Text; AddressLine1: Text; AddressLine2: Text; AddressLine3: Text)
    begin
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('EwbNo');
         JsonTextWriter.WriteValue(EwbNo);
         JsonTextWriter.WritePropertyName('vehicleNo');
         JsonTextWriter.WriteValue(VehicleNo);
         JsonTextWriter.WritePropertyName('fromPlace');
         JsonTextWriter.WriteValue(FromPlace);
         JsonTextWriter.WritePropertyName('fromState');
         JsonTextWriter.WriteValue(FromState);
         JsonTextWriter.WritePropertyName('remainingDistance');
         JsonTextWriter.WriteValue(RemainingDist);
         JsonTextWriter.WritePropertyName('TransDocNo');
         JsonTextWriter.WriteValue(TransDocNo);
         JsonTextWriter.WritePropertyName('TransDocDate');
         JsonTextWriter.WriteValue(TransDocDate);
         JsonTextWriter.WritePropertyName('TransMode');
         JsonTextWriter.WriteValue('5');
         JsonTextWriter.WritePropertyName('extnRsnCode');
         JsonTextWriter.WriteValue(ReasonCode);
         JsonTextWriter.WritePropertyName('extnRemarks');
         JsonTextWriter.WriteValue(ReasonRem);
         JsonTextWriter.WritePropertyName('fromPincode');
         JsonTextWriter.WriteValue(FromPincode);
         JsonTextWriter.WritePropertyName('consignmentStatus');
         JsonTextWriter.WriteValue(ConsignmentStatus);
         JsonTextWriter.WritePropertyName('transitType');
         JsonTextWriter.WriteValue('R');
         JsonTextWriter.WritePropertyName('addressLine1');
         JsonTextWriter.WriteValue(AddressLine1);
         JsonTextWriter.WritePropertyName('addressLine2');
         JsonTextWriter.WriteValue(AddressLine2);
         JsonTextWriter.WritePropertyName('addressLine3');
         JsonTextWriter.WriteValue(AddressLine3);
         JsonTextWriter.WriteEndObject();*/
        JOExtendValidityJsonG.Add('EwbNo', EwbNo);
        JOExtendValidityJsonG.Add('vehicleNo', VehicleNo);
        JOExtendValidityJsonG.Add('fromPlace', FromPlace);
        JOExtendValidityJsonG.Add('fromState', FromState);
        JOExtendValidityJsonG.Add('remainingDistance', RemainingDist);
        JOExtendValidityJsonG.Add('TransDocNo', TransDocNo);
        JOExtendValidityJsonG.Add('TransDocDate', TransDocDate);
        JOExtendValidityJsonG.Add('TransMode', '5');
        JOExtendValidityJsonG.Add('extnRsnCode', ReasonCode);
        JOExtendValidityJsonG.Add('extnRemarks', ReasonRem);
        JOExtendValidityJsonG.add('fromPincode', FromPincode);
        JOExtendValidityJsonG.add('consignmentStatus', ConsignmentStatus);
        JOExtendValidityJsonG.add('transitType', 'R');
        JOExtendValidityJsonG.Add('addressLine1', AddressLine1);
        JOExtendValidityJsonG.Add('addressLine2', AddressLine2);
        JOExtendValidityJsonG.Add('addressLine3', AddressLine3);
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
        LocationBuff.GET(TransferShipmentHeader."Transfer-from Code");
        Gstin := LocationBuff."GST Registration No.";//"Customer GST Reg. No.";
        SubSupplyType := '1';
        SubType := 'O';

        TransOrderEWayHeadDetails(SubType, SubSupplyType, 'INV', TransferShipmentHeader."No.", FORMAT(TransferShipmentHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>')); //Header

        //From Details >>

        StateBuff.GET(LocationBuff."State Code");
        TransOrderEwayFromDetails(LocationBuff."GST Registration No.", CompanyInfo.Name, LocationBuff.Address, LocationBuff."Address 2", LocationBuff.City
                        , LocationBuff."Post Code", StateBuff."State Code (GST Reg. No.)", StateBuff."State Code (GST Reg. No.)");
        //From Details <<

        //To Details >>
        LocationBuff.GET(TransferShipmentHeader."Transfer-to Code");
        StateBuff.GET(LocationBuff."State Code");
        TransOrderEwayToDetails(LocationBuff."GST Registration No.", LocationBuff.Name, LocationBuff.Address, LocationBuff."Address 2", LocationBuff.City
                        , LocationBuff."Post Code", StateBuff."State Code (GST Reg. No.)", StateBuff."State Code (GST Reg. No.)");
        //To Details <<


        TransOrderGetGSTCompRate(TransferShipmentHeader."No.", 0, JOItemsG);//Update GST calculations
        TransOrderReadEwbDtls();//Update Transport Details

        TransOrderReadItemList();
        //JsonTextWriter.WriteEndObject;
    end;

    local procedure TransOrderEWayHeadDetails(SupplyType: Text; SupplySubType: Text; Doctype: Text; DocNo: Text; DocDate: Text)
    begin
        /*JsonTextWriter.WriteStartObject;
        JsonTextWriter.WritePropertyName('supplyType');
        JsonTextWriter.WriteValue(SupplyType);
        JsonTextWriter.WritePropertyName('subSupplyType');
        JsonTextWriter.WriteValue(SupplySubType);
        JsonTextWriter.WritePropertyName('docType');
        JsonTextWriter.WriteValue(Doctype);
        JsonTextWriter.WritePropertyName('docNo');
        JsonTextWriter.WriteValue(DocNo);
        JsonTextWriter.WritePropertyName('docDate');
        JsonTextWriter.WriteValue(DocDate);*/
        JOsupplyTypeG.Add('supplyType', SupplyType);
        JOsupplyTypeG.Add('subSupplyType', SupplySubType);
        if SupplySubType = '3' then begin
            JOsupplyTypeG.Add('subSupplyDesc', '');
        end;
        JOsupplyTypeG.Add('docType', Doctype);
        JOsupplyTypeG.Add('docNo', DocNo);
        JOsupplyTypeG.Add('DocDate', DocDate);
    end;

    procedure TransOrderEwayFromDetails(FromGstin: Text; FromTrdName: Text; FromAdd1: Text; FromAdd2: Text; FromPlace: Text; FromPinCode: Text; ActFromStateCode: Text; FromStateCode: Text): Boolean
    var
        FromPinCodeInt: Integer;
        ActFromStateCodeInt: Integer;
        FromStateCodeInt: Integer;
    begin
        IF FromPinCode <> '' THEN
            EVALUATE(FromPinCodeInt, FromPinCode);
        IF ActFromStateCode <> '' THEN
            EVALUATE(ActFromStateCodeInt, ActFromStateCode);
        IF FromStateCode <> '' THEN
            EVALUATE(FromStateCodeInt, FromStateCode);
        /*JsonTextWriter.WritePropertyName('fromGstin');
        JsonTextWriter.WriteValue(FromGstin);
        JsonTextWriter.WritePropertyName('fromTrdName');
        JsonTextWriter.WriteValue(FromTrdName);
        JsonTextWriter.WritePropertyName('fromAddr1');
        JsonTextWriter.WriteValue(FromAdd1);
        JsonTextWriter.WritePropertyName('fromAddr2');
        JsonTextWriter.WriteValue(FromAdd2);
        JsonTextWriter.WritePropertyName('fromPlace');
        JsonTextWriter.WriteValue(FromPlace);
        JsonTextWriter.WritePropertyName('fromPincode');
        JsonTextWriter.WriteValue(FromPinCodeInt);
        JsonTextWriter.WritePropertyName('actFromStateCode');
        JsonTextWriter.WriteValue(ActFromStateCodeInt);
        JsonTextWriter.WritePropertyName('fromStateCode');
        JsonTextWriter.WriteValue(FromStateCodeInt);*/
        JOsupplyTypeG.Add('fromGstin', FromGstin);
        JOsupplyTypeG.Add('fromTrdName', FromTrdName);
        JOsupplyTypeG.Add('fromAddr1', FromAdd1);
        JOsupplyTypeG.Add('fromAddr2', FromAdd2);
        JOsupplyTypeG.Add('fromPlace', FromPlace);
        JOsupplyTypeG.Add('fromPincode', FromPinCodeInt);
        JOsupplyTypeG.Add('actFromStateCode', ActFromStateCodeInt);
        JOsupplyTypeG.Add('fromStateCode', FromStateCodeInt);
    end;

    procedure TransOrderEwayToDetails(ToGstin: Text; ToTrdName: Text; ToAdd1: Text; ToAdd2: Text; ToPlace: Text; ToPinCode: Text; ActFromStateCode: Text; ToStateCode: Text): Boolean
    var
        ToPinCodeInt: Integer;
        ActToStateCodeInt: Integer;
        ToStateCodeInt: Integer;
    begin
        IF ToPinCode <> '' THEN
            EVALUATE(ToPinCodeInt, ToPinCode);
        IF ActFromStateCode <> '' THEN
            EVALUATE(ActToStateCodeInt, ActFromStateCode);
        IF ToStateCode <> '' THEN
            EVALUATE(ToStateCodeInt, ToStateCode);
        /* JsonTextWriter.WritePropertyName('toGstin');
         JsonTextWriter.WriteValue(ToGstin);
         JsonTextWriter.WritePropertyName('toTrdName');
         JsonTextWriter.WriteValue(ToTrdName);
         JsonTextWriter.WritePropertyName('toAddr1');
         JsonTextWriter.WriteValue(ToAdd1);
         JsonTextWriter.WritePropertyName('toAddr2');
         JsonTextWriter.WriteValue(ToAdd2);
         JsonTextWriter.WritePropertyName('toPlace');
         JsonTextWriter.WriteValue(ToPlace);
         JsonTextWriter.WritePropertyName('toPincode');
         JsonTextWriter.WriteValue(ToPinCodeInt);
         JsonTextWriter.WritePropertyName('actToStateCode');
         JsonTextWriter.WriteValue(ActToStateCodeInt);

         JsonTextWriter.WritePropertyName('toStateCode');
         JsonTextWriter.WriteValue(ToStateCodeInt);*/
        JOsupplyTypeG.Add('toGstin', ToGstin);
        JOsupplyTypeG.Add('toTrdName', ToTrdName);
        JOsupplyTypeG.Add('toAddr1', ToAdd1);
        JOsupplyTypeG.Add('toAddr2', ToAdd2);
        JOsupplyTypeG.Add('toPlace', ToPlace);
        JOsupplyTypeG.Add('toPincode', ToPinCodeInt);
        JOsupplyTypeG.Add('actToStateCode', ActToStateCodeInt);
        JOsupplyTypeG.Add('toStateCode', ToStateCodeInt);
    end;

    local procedure TransOrderUpdateEwayCalculations(TotalValue: Decimal; CgstValue: Decimal; SgstValue: Decimal; IgstValue: Decimal; CessValue: Decimal; Var JOItemsL: JsonObject)
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
        TotalInvValue: Decimal;
    begin
        TransferShipmentLine.RESET;
        TransferShipmentLine.SETRANGE("Document No.", TransferShipmentHeader."No.");
        TransferShipmentLine.SETRANGE(Exempted, FALSE);
        IF TransferShipmentLine.FINDSET THEN BEGIN
            REPEAT
                TotalInvValue += (TransferShipmentLine.Quantity * TransferShipmentLine."Unit Price");
            UNTIL TransferShipmentLine.NEXT = 0;
        END;

        TotalValue := CgstValue + SgstValue + IgstValue + CessValue;
        /* JsonTextWriter.WritePropertyName('totalValue');
         JsonTextWriter.WriteValue(ABS(TotalInvValue));
         JsonTextWriter.WritePropertyName('cgstValue');
         JsonTextWriter.WriteValue(CgstValue);
         JsonTextWriter.WritePropertyName('sgstValue');
         JsonTextWriter.WriteValue(SgstValue);
         JsonTextWriter.WritePropertyName('igstValue');
         JsonTextWriter.WriteValue(IgstValue);
         JsonTextWriter.WritePropertyName('cessValue');
         JsonTextWriter.WriteValue(CessValue);
         JsonTextWriter.WritePropertyName('totInvValue');
         JsonTextWriter.WriteValue(TotalInvValue + TotalValue);*/
        JOItemsL.Add('totalValue', Abs(TotalInvValue));
        JOItemsL.Add('totalValue', ABS(TotalInvValue));
        JOItemsL.Add('cgstValue', CgstValue);
        JOItemsL.Add('sgstValue', SgstValue);
        JOItemsL.Add('igstValue', IgstValue);
        JOItemsL.Add('cessValue', CessValue);
        JOItemsL.Add('totInvValue', TotalInvValue + TotalValue);

    end;

    local procedure TransOrderGetGSTCompRate(DocNo: Code[20]; LineNo: Integer; Var JOItemsL: JsonObject)
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
            TransOrderUpdateEwayCalculations(TotalValue, CgstAmt, SgstAmt, IgstAmt, CessAmt, JOItemsL)//Header Json
        ELSE BEGIN
            /* JsonTextWriter.WritePropertyName('cgstRate');
             JsonTextWriter.WriteValue(CgstRt);
             JsonTextWriter.WritePropertyName('sgstRate');
             JsonTextWriter.WriteValue(SgstRt);
             JsonTextWriter.WritePropertyName('igstRate');
             JsonTextWriter.WriteValue(IgstRt);
             JsonTextWriter.WritePropertyName('cessRate');
             JsonTextWriter.WriteValue(CesRt);
             JsonTextWriter.WritePropertyName('cessAdvol');
             JsonTextWriter.WriteValue(CesAdvlAmt);*/
            JOItemsL.Add('cgstRate', CgstRt);
            JOItemsL.Add('sgstRate', SgstRt);
            JOItemsL.Add('igstRate', IgstRt);
            JOItemsL.Add('cessRate', CesRt);
            JOItemsL.Add('cessNonAdvolValue', CesNonAdvlAmt);
            JOItemsL.Add('cessAdvol', CesAdvlAmt);

        END;
    end;

    local procedure TransOrderReadEwbDtls()
    var
        TransId: Text[15];
        TransName: Text[100];
        TransMode: Text[1];
        Distance: Text[4];
        TransDocNo: Text[15];
        TransDocDt: Text[10];
        VehNo: Text[20];
        VehType: Text[1];
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
                    TransMode := '1';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := '2';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := '3';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := '4';
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
                VehType := 'O';
            TransferShipmentHeader."Vehicle Type"::Regular:
                VehType := 'R';
        END;


        TransOrderWriteEwbDtls(TransId, TransName, TransMode, Distance, TransDocNo, TransDocDt, VehNo, VehType, TransactionType);
    end;

    local procedure TransOrderWriteEwbDtls(TransId: Text[15]; TransName: Text[100]; TransMode: Text[1]; Distance: Text[4]; TransDocNo: Text[15]; TransDocDt: Text[10]; VehNo: Text[20]; VehType: Text[1]; TransactionType: Text)
    begin
        /*  JsonTextWriter.WritePropertyName('transporterId');
          JsonTextWriter.WriteValue(TransId);
          JsonTextWriter.WritePropertyName('transporterName');
          JsonTextWriter.WriteValue(TransName);
          JsonTextWriter.WritePropertyName('transDocNo');
          JsonTextWriter.WriteValue(TransDocNo);
          JsonTextWriter.WritePropertyName('transMode');
          JsonTextWriter.WriteValue(TransMode);
          JsonTextWriter.WritePropertyName('transDistance');
          JsonTextWriter.WriteValue(Distance);
          JsonTextWriter.WritePropertyName('transDocDate');
          JsonTextWriter.WriteValue(TransDocDt);
          JsonTextWriter.WritePropertyName('vehicleNo');
          JsonTextWriter.WriteValue(VehNo);
          JsonTextWriter.WritePropertyName('vehicleType');
          JsonTextWriter.WriteValue(VehType);
          JsonTextWriter.WritePropertyName('TransactionType');
          JsonTextWriter.WriteValue(TransactionType);*/
        JOsupplyTypeG.Add('transporterId', TransId);
        JOsupplyTypeG.Add('transporterName', TransName);
        JOsupplyTypeG.Add('transDocNo', TransDocNo);
        JOsupplyTypeG.Add('transMode', TransMode);
        JOsupplyTypeG.Add('transDistance', Distance);
        JOsupplyTypeG.Add('transDocDate', TransDocDt);
        JOsupplyTypeG.Add('vehicleNo', VehNo);
        JOsupplyTypeG.Add('vehicleType', VehType);
        JOsupplyTypeG.Add('TransactionType', TransactionType);
    end;

    local procedure TransOrderReadItemList()
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesLinesErr: Label 'E-Invoice allowes only 1000 lines per Invoice. Curent transaction is having %1 lines.', Comment = '%1 = Sales Lines count';
        HSNInt: Integer;
        Uom: Record "Unit of Measure";
    begin
        TransferShipmentLine.RESET;
        TransferShipmentLine.SETRANGE("Document No.", TransferShipmentHeader."No.");
        TransferShipmentLine.SETFILTER("Item No.", '<>%1', '');
        TransferShipmentLine.SETFILTER(Quantity, '>%1', 0);
        TransferShipmentLine.SETRANGE(Exempted, FALSE);
        IF TransferShipmentLine.FINDSET THEN BEGIN
            IF TransferShipmentLine.COUNT > 1000 THEN
                ERROR(SalesLinesErr, TransferShipmentLine.COUNT);
            // JsonTextWriter.WritePropertyName('itemList');
            //  JsonTextWriter.WriteStartArray;
            REPEAT
                EVALUATE(HSNInt, TransferShipmentLine."HSN/SAC Code");
                /* JsonTextWriter.WriteStartObject;
                 JsonTextWriter.WritePropertyName('productName');
                 JsonTextWriter.WriteValue(TransferShipmentLine."Item No.");
                 JsonTextWriter.WritePropertyName('productDesc');
                 JsonTextWriter.WriteValue(TransferShipmentLine.Description);
                 JsonTextWriter.WritePropertyName('hsnCode');
                 JsonTextWriter.WriteValue(HSNInt);
                 JsonTextWriter.WritePropertyName('quantity');
                 JsonTextWriter.WriteValue(TransferShipmentLine.Quantity);
                 Uom.GET(TransferShipmentLine."Unit of Measure Code");
                 JsonTextWriter.WritePropertyName('qtyUnit');
                 JsonTextWriter.WriteValue(Uom."International Standard Code");

                 TransOrderGetGSTCompRate(TransferShipmentHeader."No.", TransferShipmentLine."Line No.");

                 JsonTextWriter.WritePropertyName('taxableAmount');
                 JsonTextWriter.WriteValue(TransferShipmentLine.Amount);
                 JsonTextWriter.WriteEndObject;*/
                Clear(JOItemsG);
                Uom.GET(TransferShipmentLine."Unit of Measure Code");
                JOItemsG.Add('productName', TransferShipmentLine."Item No.");
                JOItemsG.Add('productDesc', TransferShipmentLine.Description);
                JOItemsG.Add('hsnCode', HSNInt);
                JOItemsG.Add('quantity', TransferShipmentLine.Quantity);
                JOItemsG.Add('qtyUnit', Uom.Code);
                TransOrderGetGSTCompRate(TransferShipmentHeader."No.", TransferShipmentLine."Line No.", JOItemsG);
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
        Title1: Label '';
        Title2: Label '';
    begin
        LocationBuff.GET(TransferShipmentHeader."Transfer-from Code");
        StateBuff.GET(LocationBuff."State Code");
        IF IsPosting THEN BEGIN
            Reason := EWayBillingSetup."Vehicle Reason";
            ReasonRemarks := EWayBillingSetup."Vehicle Remarks";
            VehicleNo := PurchCrMemoHdr."Vehicle No.";
        END ELSE BEGIN
            Reason := EWayBillingSetup."Vehicle Reason";
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
            UpdateOldVechileNoInEWayEntry(TransType::"Transfer Order", TransferShipmentHeader."No.", TransferShipmentHeader."Vehicle No.");
            TransferShipmentHeader."Vehicle No." := VehicleNo;
            TransferShipmentHeader.MODIFY();
        END;

        IF TransportMethod.GET(TransferShipmentHeader."Transport Method") THEN BEGIN
            CASE TransportMethod."Transportation Mode" OF
                TransportMethod."Transportation Mode"::Road:
                    TransMode := '1';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := '2';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := '3';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := '4';
            END;
        END;
        TransDocNo := '';
        TransDocDate := 0D;
        TransOrderWriteVechileJson(GetEwayBillIngNo(TransType::"Transfer Order", TransferShipmentHeader."No."), VehicleNo, LocationBuff.City, StateBuff."State Code for eTDS/TCS", Reason, ReasonRemarks,
                        TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode);
    end;

    local procedure TransOrderWriteVechileJson(EwbNo: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; ReasonCode: Text; ReasonRem: Text; TransDocNo: Text; TransDocDate: Text; TransMode: Text)
    var
        EwbBigInt: BigInteger;
    begin
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('EwbNo');
         JsonTextWriter.WriteValue(EwbNo);
         JsonTextWriter.WritePropertyName('VehicleNo');
         JsonTextWriter.WriteValue(VehicleNo);
         JsonTextWriter.WritePropertyName('FromPlace');
         JsonTextWriter.WriteValue(FromPlace);
         JsonTextWriter.WritePropertyName('FromState');
         JsonTextWriter.WriteValue(FromState);
         JsonTextWriter.WritePropertyName('ReasonCode');
         JsonTextWriter.WriteValue(ReasonCode);
         JsonTextWriter.WritePropertyName('ReasonRem');
         JsonTextWriter.WriteValue(ReasonRem);
         JsonTextWriter.WritePropertyName('TransDocNo');
         JsonTextWriter.WriteValue(TransDocNo);
         JsonTextWriter.WritePropertyName('TransDocDate');
         JsonTextWriter.WriteValue(TransDocDate);
         JsonTextWriter.WritePropertyName('TransMode');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WriteEndObject();*/
        JOVehicleG.Add('EwbNo', EwbNo);
        JOVehicleG.Add('VehicleNo', VehicleNo);
        JOVehicleG.Add('FromPlace', FromPlace);
        JOVehicleG.Add('FromState', FromState);
        JOVehicleG.Add('ReasonCode', ReasonCode);
        JOVehicleG.Add('ReasonRem', ReasonRem);
        JOVehicleG.Add('TransDocNo', TransDocNo);
        JOVehicleG.Add('TransDocDate', '');
        JOVehicleG.add('TransMode', TransMode);
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
        Title3: Label 'Remaining Districts';
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
        TransOrderWriteCancelJson(GetEwayBillIngNo(TransType::"Transfer Order", TransferShipmentHeader."No."), Reason, ReasonRemarks);
    end;

    local procedure TransOrderWriteCancelJson(EWBNo: Text; CancelReason: Text; CancelRemarks: Text)
    begin
        /*JsonTextWriter.WriteStartObject();
        JsonTextWriter.WritePropertyName('ewbNo');
        JsonTextWriter.WriteValue(EWBNo);
        JsonTextWriter.WritePropertyName('cancelRsnCode');
        JsonTextWriter.WriteValue(CancelReason);
        JsonTextWriter.WritePropertyName('cancelRmrk');
        JsonTextWriter.WriteValue(CancelRemarks);
        JsonTextWriter.WriteEndObject();*/
        JOCancelG.Add('ewbNo', EWBNo);
        JOCancelG.Add('cancelRsnCode', CancelReason);
        JOCancelG.Add('cancelRmrk', CancelRemarks);
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
         JsonTextWriter.WritePropertyName('ewbNo');
         JsonTextWriter.WriteValue(RejectEwayBillNo);
         JsonTextWriter.WriteEndObject();*/
        JORejEWayNoG.Add('ewbNo', RejectEwayBillNo);
        EVALUATE(RejEwayBillNo, RejectEwayBillNo);
        //ExportAsJson(RejDocumentNo, PathSaved);
    end;

    local procedure TransOrderUpdateTransportJson()
    var
        TransportID: Text;
        TransportIDError: Label 'Transport Id must have value';
    begin
        //B2BUPG1.0>>
        //TransportID := Windows.InputBox('Transporter ID :', '', '', 10, 10);
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(2);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetData(2, TransportID);
        //B2BUPG1.0<<
        IF TransportID = '' THEN
            ERROR(TransportIDError);
        /*JsonTextWriter.WriteStartObject();
        JsonTextWriter.WritePropertyName('ewbNo');
        JsonTextWriter.WriteValue(GetEwayBillIngNo(TransType::"Transfer Order", TransferShipmentHeader."No."));
        JsonTextWriter.WritePropertyName('transporterId');
        JsonTextWriter.WriteValue(TransportID);
        JsonTextWriter.WriteEndObject();*/
        JOUpdatetransportIDG.Add('ewbNo', GetEwayBillIngNo(TransType::"Transfer Order", TransferShipmentHeader."No."));
        JOUpdatetransportIDG.Add('transporterId', TransportID);
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
                    TransMode := '1';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := '2';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := '3';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := '4';
            END;
        END;

        TransDocNo := '';
        TransDocDate := 0D;
        CreditWriteExtendValidityJson(GetEwayBillIngNo(TransType::"Transfer Order", TransferShipmentHeader."No."), TransferShipmentHeader."Vehicle No.", LocationBuff.City, StateBuff."State Code (GST Reg. No.)",
        RemainingDist, TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode, Reason, ReasonRemarks, Pin, 'T', TransferShipmentHeader."Transaction Type",
                      TransferShipmentHeader."Transfer-from Address", TransferShipmentHeader."Transfer-from Address", TransferShipmentHeader."Transfer-from Address");
    end;

    local procedure TransOrderWriteExtendValidityJson(EwbNo: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; RemainingDist: Integer; TransDocNo: Text; TransDocDate: Text; TransMode: Text; ReasonCode: Text; ReasonRem: Text; FromPincode: Integer; ConsignmentStatus: Text; TransitType: Text; AddressLine1: Text; AddressLine2: Text; AddressLine3: Text)
    begin
        /*JsonTextWriter.WriteStartObject();
        JsonTextWriter.WritePropertyName('EwbNo');
        JsonTextWriter.WriteValue(EwbNo);
        JsonTextWriter.WritePropertyName('vehicleNo');
        JsonTextWriter.WriteValue(VehicleNo);
        JsonTextWriter.WritePropertyName('fromPlace');
        JsonTextWriter.WriteValue(FromPlace);
        JsonTextWriter.WritePropertyName('fromState');
        JsonTextWriter.WriteValue(FromState);
        JsonTextWriter.WritePropertyName('remainingDistance');
        JsonTextWriter.WriteValue(RemainingDist);
        JsonTextWriter.WritePropertyName('TransDocNo');
        JsonTextWriter.WriteValue(TransDocNo);
        JsonTextWriter.WritePropertyName('TransDocDate');
        JsonTextWriter.WriteValue(TransDocDate);
        JsonTextWriter.WritePropertyName('TransMode');
        JsonTextWriter.WriteValue('5');
        JsonTextWriter.WritePropertyName('extnRsnCode');
        JsonTextWriter.WriteValue(ReasonCode);
        JsonTextWriter.WritePropertyName('extnRemarks');
        JsonTextWriter.WriteValue(ReasonRem);
        JsonTextWriter.WritePropertyName('fromPincode');
        JsonTextWriter.WriteValue(FromPincode);
        JsonTextWriter.WritePropertyName('consignmentStatus');
        JsonTextWriter.WriteValue(ConsignmentStatus);
        JsonTextWriter.WritePropertyName('transitType');
        JsonTextWriter.WriteValue('R');
        JsonTextWriter.WritePropertyName('addressLine1');
        JsonTextWriter.WriteValue(AddressLine1);
        JsonTextWriter.WritePropertyName('addressLine2');
        JsonTextWriter.WriteValue(AddressLine2);
        JsonTextWriter.WritePropertyName('addressLine3');
        JsonTextWriter.WriteValue(AddressLine3);
        JsonTextWriter.WriteEndObject();*/
        JOExtendValidityJsonG.Add('EwbNo', EwbNo);
        JOExtendValidityJsonG.Add('vehicleNo', VehicleNo);
        JOExtendValidityJsonG.Add('fromPlace', FromPlace);
        JOExtendValidityJsonG.Add('fromState', FromState);
        JOExtendValidityJsonG.Add('remainingDistance', RemainingDist);
        JOExtendValidityJsonG.Add('TransDocNo', TransDocNo);
        JOExtendValidityJsonG.Add('TransDocDate', TransDocDate);
        JOExtendValidityJsonG.Add('TransMode', '5');
        JOExtendValidityJsonG.Add('extnRsnCode', ReasonCode);
        JOExtendValidityJsonG.Add('extnRemarks', ReasonRem);
        JOExtendValidityJsonG.add('fromPincode', FromPincode);
        JOExtendValidityJsonG.add('consignmentStatus', ConsignmentStatus);
        JOExtendValidityJsonG.add('transitType', 'R');
        JOExtendValidityJsonG.Add('addressLine1', AddressLine1);
        JOExtendValidityJsonG.Add('addressLine2', AddressLine2);
        JOExtendValidityJsonG.Add('addressLine3', AddressLine3);
    end;

    local procedure "-----------------------------------SubCon START------------------------"()
    begin
    end;

    procedure SetSubConHeader(var DeliveryChallanHeadertemp: Record "Delivery Challan Header"; RequestTypePar: Option Eway,Vehicle,EWayCancel,RejectEway,ExtendValidity,UpdateTrasporter,AccessToken; IsPostingPar: Boolean)
    begin
        DeliveryChallanHeader := DeliveryChallanHeadertemp;
        RequestType := RequestTypePar;
        IsPosting := IsPostingPar;
    end;

    procedure SubConEWayJson()
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
        PurchHeader.GET(PurchHeader."Document Type"::Order, DeliveryChallanHeader."Sub. order No.");
        IF PurchHeader."GST Vendor Type" = PurchHeader."GST Vendor Type"::Import THEN BEGIN
            Gstin := 'URP';
            Pin := '999999';
            SubSupplyType := '3';
            SubType := 'I';
        END ELSE BEGIN
            Gstin := PurchHeader."Vendor GST Reg. No.";// "Vendor GST Reg. No.";
            Pin := COPYSTR(PurchHeader."Pay-to Post Code", 1, 6);
            SubSupplyType := '1';
            SubType := 'I';
        END;
        //EWB1.2 >>
        IF PurchHeader."GST Vendor Type" = PurchHeader."GST Vendor Type"::Unregistered THEN
            Gstin := 'URP';
        //EWB1.2 <<
        SubConEWayHeadDetails(SubType, SubSupplyType, 'INV', DeliveryChallanHeader."No.", FORMAT(DeliveryChallanHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>'));
        //From Details >>
        LocationBuff.GET(PurchHeader."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        //LocationBuff."GST Registration No."
        SubConEwayFromDetails(LocationBuff."GST Registration No.", CompanyInfo.Name, LocationBuff.Address, LocationBuff."Address 2", LocationBuff.City
                        , LocationBuff."Post Code", StateBuff."State Code (GST Reg. No.)", StateBuff."State Code (GST Reg. No.)");


        //From Details <<

        //To Details >>
        Pos := SubConGetEwayPos(PurchHeader."No.");
        SubConEwayToDetails(Gstin, PurchHeader."Pay-to Name", PurchHeader."Pay-to Address", PurchHeader."Pay-to Address 2", PurchHeader."Pay-to City", Pin, Pos, Pos);
        //To Details <<
        SubConGetGSTCompRate(PurchHeader."No.", 0, JOItemsG);

        SubConReadEwbDtls();//Update Transport Details
        SubConReadItemList();
        //  JsonTextWriter.WriteEndObject;
        //ExportAsJson(PurchHeader."No.",Path);
    end;

    local procedure SubConEWayHeadDetails(SupplyType: Text; SupplySubType: Text; Doctype: Text; DocNo: Text; DocDate: Text)
    begin
        /* JsonTextWriter.WriteStartObject;
         JsonTextWriter.WritePropertyName('supplyType');
         JsonTextWriter.WriteValue(SupplyType);
         JsonTextWriter.WritePropertyName('subSupplyType');
         JsonTextWriter.WriteValue(SupplySubType);

         JsonTextWriter.WritePropertyName('docType');
         JsonTextWriter.WriteValue(Doctype);
         JsonTextWriter.WritePropertyName('docNo');
         JsonTextWriter.WriteValue(DocNo);
         JsonTextWriter.WritePropertyName('docDate');
         JsonTextWriter.WriteValue(DocDate);*/
        JOsupplyTypeG.Add('supplyType', SupplyType);
        JOsupplyTypeG.Add('subSupplyType', SupplySubType);
        if SupplySubType = '3' then begin
            JOsupplyTypeG.Add('subSupplyDesc', '');
        end;
        JOsupplyTypeG.Add('docType', Doctype);
        JOsupplyTypeG.Add('docNo', DocNo);
        JOsupplyTypeG.Add('docDate', DocDate);
    end;

    procedure SubConEwayFromDetails(FromGstin: Text; FromTrdName: Text; FromAdd1: Text; FromAdd2: Text; FromPlace: Text; FromPinCode: Text; ActFromStateCode: Text; FromStateCode: Text): Boolean
    var
        FromPinCodeInt: Integer;
        ActFromStateCodeInt: Integer;
        FromStateCodeInt: Integer;
    begin
        IF FromPinCode <> '' THEN
            EVALUATE(FromPinCodeInt, FromPinCode);
        IF ActFromStateCode <> '' THEN
            EVALUATE(ActFromStateCodeInt, ActFromStateCode);
        IF FromStateCode <> '' THEN
            EVALUATE(FromStateCodeInt, FromStateCode);
        /*JsonTextWriter.WritePropertyName('fromGstin');
        JsonTextWriter.WriteValue(FromGstin);
        JsonTextWriter.WritePropertyName('fromTrdName');
        JsonTextWriter.WriteValue(FromTrdName);
        JsonTextWriter.WritePropertyName('fromAddr1');
        JsonTextWriter.WriteValue(FromAdd1);
        JsonTextWriter.WritePropertyName('fromAddr2');
        JsonTextWriter.WriteValue(FromAdd2);
        JsonTextWriter.WritePropertyName('fromPlace');
        JsonTextWriter.WriteValue(FromPlace);
        JsonTextWriter.WritePropertyName('fromPincode');
        JsonTextWriter.WriteValue(FromPinCodeInt);
        JsonTextWriter.WritePropertyName('actFromStateCode');
        JsonTextWriter.WriteValue(ActFromStateCodeInt);
        JsonTextWriter.WritePropertyName('fromStateCode');
        JsonTextWriter.WriteValue(FromStateCodeInt);*/
        JOsupplyTypeG.Add('fromGstin', FromGstin);
        JOsupplyTypeG.Add('fromTrdName', FromTrdName);
        JOsupplyTypeG.Add('fromAddr1', FromAdd1);
        JOsupplyTypeG.Add('fromAddr2', FromAdd2);
        JOsupplyTypeG.Add('fromPlace', FromPlace);
        JOsupplyTypeG.Add('fromPincode', FromPinCodeInt);
        JOsupplyTypeG.Add('actFromStateCode', ActFromStateCodeInt);
        JOsupplyTypeG.Add('fromStateCode', FromStateCodeInt);
    end;

    procedure SubConEwayToDetails(ToGstin: Text; ToTrdName: Text; ToAdd1: Text; ToAdd2: Text; ToPlace: Text; ToPinCode: Text; ActFromStateCode: Text; ToStateCode: Text): Boolean
    var
        ToPinCodeInt: Integer;
        ActToStateCodeInt: Integer;
        ToStateCodeInt: Integer;
    begin
        IF ToPinCode <> '' THEN
            EVALUATE(ToPinCodeInt, ToPinCode);
        IF ActFromStateCode <> '' THEN
            EVALUATE(ActToStateCodeInt, ActFromStateCode);
        IF ToStateCode <> '' THEN
            EVALUATE(ToStateCodeInt, ToStateCode);
        /* JsonTextWriter.WritePropertyName('toGstin');
         JsonTextWriter.WriteValue(ToGstin);
         JsonTextWriter.WritePropertyName('toTrdName');
         JsonTextWriter.WriteValue(ToTrdName);
         JsonTextWriter.WritePropertyName('toAddr1');
         JsonTextWriter.WriteValue(ToAdd1);
         JsonTextWriter.WritePropertyName('toAddr2');
         JsonTextWriter.WriteValue(ToAdd2);
         JsonTextWriter.WritePropertyName('toPlace');
         JsonTextWriter.WriteValue(ToPlace);
         JsonTextWriter.WritePropertyName('toPincode');
         JsonTextWriter.WriteValue(ToPinCodeInt);
         JsonTextWriter.WritePropertyName('actToStateCode');
         JsonTextWriter.WriteValue(ActToStateCodeInt);
         JsonTextWriter.WritePropertyName('toStateCode');
         JsonTextWriter.WriteValue(ToStateCodeInt);*/
        JOsupplyTypeG.Add('toGstin', ToGstin);
        JOsupplyTypeG.Add('toTrdName', ToTrdName);
        JOsupplyTypeG.Add('toAddr1', ToAdd1);
        JOsupplyTypeG.Add('toAddr2', ToAdd2);
        JOsupplyTypeG.Add('toPlace', ToPlace);
        JOsupplyTypeG.Add('toPincode', ToPinCodeInt);
        JOsupplyTypeG.Add('actToStateCode', ActToStateCodeInt);
        JOsupplyTypeG.Add('toStateCode', ToStateCodeInt);
    end;

    local procedure SubConGetEwayPos(No: Code[20]): Text
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
                EXIT(StateBuff."State Code (GST Reg. No.)");
            END ELSE BEGIN
                StateBuff.GET(PurchHeader.State);
                EXIT(StateBuff."State Code (GST Reg. No.)");
            END;
    end;

    local procedure SubConUpdateEwayCalculations(CgstValue: Decimal; SgstValue: Decimal; IgstValue: Decimal; CessValue: Decimal; Var JOItemsL: JsonObject)
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
                                 ((PurchLine.Quantity * PurchLine."Direct Unit Cost") * PurchLine."Line Discount %" / 100);
            UNTIL PurchLine.NEXT = 0;
        END;
        IF PurchHeader."Currency Code" <> '' THEN
            TotalInvValue := (1 / PurchHeader."Currency Factor") * TotalInvValue;
        TotalValue := CgstValue + SgstValue + IgstValue + CessValue;
        /*JsonTextWriter.WritePropertyName('totalValue');
        JsonTextWriter.WriteValue(ABS(TotalInvValue));
        JsonTextWriter.WritePropertyName('cgstValue');
        JsonTextWriter.WriteValue(CgstValue);
        JsonTextWriter.WritePropertyName('sgstValue');
        JsonTextWriter.WriteValue(SgstValue);
        JsonTextWriter.WritePropertyName('igstValue');
        JsonTextWriter.WriteValue(IgstValue);
        JsonTextWriter.WritePropertyName('cessValue');
        JsonTextWriter.WriteValue(CessValue);
        JsonTextWriter.WritePropertyName('totInvValue');

        JsonTextWriter.WriteValue(TotalInvValue + TotalValue);*/
        JOItemsL.Add('totalValue', Abs(TotalInvValue));
        JOItemsL.Add('totalValue', ABS(TotalInvValue));
        JOItemsL.Add('cgstValue', CgstValue);
        JOItemsL.Add('sgstValue', SgstValue);
        JOItemsL.Add('igstValue', IgstValue);
        JOItemsL.Add('cessValue', CessValue);
        JOItemsL.Add('totInvValue', TotalInvValue + TotalValue);
    end;

    local procedure SubConGetGSTCompRate(DocNo: Code[20]; LineNo: Integer; Var JOItemsL: JsonObject)
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
            PurchUpdateEwayCalculations(CgstAmt, SgstAmt, IgstAmt, CessAmt, JOItemsL)//Header Json
        ELSE BEGIN
            /*  JsonTextWriter.WritePropertyName('cgstRate');
              JsonTextWriter.WriteValue(CgstRt);
              JsonTextWriter.WritePropertyName('sgstRate');
              JsonTextWriter.WriteValue(SgstRt);
              JsonTextWriter.WritePropertyName('igstRate');
              JsonTextWriter.WriteValue(IgstRt);
              JsonTextWriter.WritePropertyName('cessRate');
              JsonTextWriter.WriteValue(CesRt);
              JsonTextWriter.WritePropertyName('cessAdvol');
              JsonTextWriter.WriteValue(CesAdvlAmt);*/
            JOItemsL.Add('cgstRate', CgstRt);
            JOItemsL.Add('sgstRate', SgstRt);
            JOItemsL.Add('igstRate', IgstRt);
            JOItemsL.Add('cessRate', CesRt);
            JOItemsL.Add('cessNonAdvolValue', CesNonAdvlAmt);
            JOItemsL.Add('cessAdvol', CesAdvlAmt);
        END;
    end;

    local procedure SubConReadEwbDtls()
    var
        TransId: Text[15];
        TransName: Text[100];
        TransMode: Text[1];
        Distance: Text[4];
        TransDocNo: Text[15];
        TransDocDt: Text[10];
        VehNo: Text[20];
        VehType: Text[1];
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
                    TransMode := '1';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := '2';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := '3';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := '4';
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
                VehType := 'O';
            PurchHeader."Vehicle Type"::Regular:
                VehType := 'R';
        END;


        PurchWriteEwbDtls(TransId, TransName, TransMode, Distance, TransDocNo, TransDocDt, VehNo, VehType, TransactionType);
    end;

    local procedure SubConWriteEwbDtls(TransId: Text[15]; TransName: Text[100]; TransMode: Text[1]; Distance: Text[4]; TransDocNo: Text[15]; TransDocDt: Text[10]; VehNo: Text[20]; VehType: Text[1]; TransactionType: Text)
    begin
        /* JsonTextWriter.WritePropertyName('transporterId');
         JsonTextWriter.WriteValue(TransId);
         JsonTextWriter.WritePropertyName('transporterName');
         JsonTextWriter.WriteValue(TransName);
         JsonTextWriter.WritePropertyName('transDocNo');
         JsonTextWriter.WriteValue(TransDocNo);
         JsonTextWriter.WritePropertyName('transMode');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WritePropertyName('transDistance');
         JsonTextWriter.WriteValue(Distance);
         JsonTextWriter.WritePropertyName('transDocDate');
         JsonTextWriter.WriteValue(TransDocDt);
         JsonTextWriter.WritePropertyName('vehicleNo');
         JsonTextWriter.WriteValue(VehNo);
         JsonTextWriter.WritePropertyName('vehicleType');
         JsonTextWriter.WriteValue(VehType);
         JsonTextWriter.WritePropertyName('TransactionType');
         JsonTextWriter.WriteValue(TransactionType);*/
        JOsupplyTypeG.Add('transporterId', TransId);
        JOsupplyTypeG.Add('transporterName', TransName);
        JOsupplyTypeG.Add('transDocNo', TransDocNo);
        JOsupplyTypeG.Add('transMode', TransMode);
        JOsupplyTypeG.Add('transDistance', Distance);
        JOsupplyTypeG.Add('transDocDate', TransDocDt);
        JOsupplyTypeG.Add('vehicleNo', VehNo);
        JOsupplyTypeG.Add('vehicleType', VehType);
        JOsupplyTypeG.Add('TransactionType', TransactionType);
    end;

    local procedure SubConReadItemList()
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
            //  JsonTextWriter.WritePropertyName('itemList');
            //  JsonTextWriter.WriteStartArray;
            REPEAT
                EVALUATE(HSNInt, PurchLine."HSN/SAC Code");
                /* JsonTextWriter.WriteStartObject;
                 JsonTextWriter.WritePropertyName('productName');
                 JsonTextWriter.WriteValue(PurchLine."No.");
                 JsonTextWriter.WritePropertyName('productDesc');
                 JsonTextWriter.WriteValue(PurchLine.Description);
                 JsonTextWriter.WritePropertyName('hsnCode');
                 JsonTextWriter.WriteValue(HSNInt);
                 JsonTextWriter.WritePropertyName('quantity');
                 JsonTextWriter.WriteValue(PurchLine.Quantity);
                 Uom.GET(PurchLine."Unit of Measure Code");
                 JsonTextWriter.WritePropertyName('qtyUnit');
                 JsonTextWriter.WriteValue(Uom."International Standard Code");

                 PurchGetGSTCompRate(PurchHeader."No.", PurchLine."Line No.");

                 JsonTextWriter.WritePropertyName('taxableAmount');
                 IF PurchHeader."Currency Code" <> '' THEN
                     JsonTextWriter.WriteValue((1 / PurchHeader."Currency Factor") * PurchLine."Line Amount")
                 ELSE
                     JsonTextWriter.WriteValue(PurchLine."Line Amount");
                 JsonTextWriter.WriteEndObject;*/
                Clear(JOItemsG);
                Uom.GET(PurchLine."Unit of Measure Code");
                JOItemsG.Add('productName', PurchLine."No.");
                JOItemsG.Add('productDesc', PurchLine.Description);
                JOItemsG.Add('hsnCode', HSNInt);
                JOItemsG.Add('quantity', PurchLine.Quantity);
                JOItemsG.Add('qtyUnit', Uom.Code);
                PurchGetGSTCompRate(PurchHeader."No.", PurchLine."Line No.", JOItemsG);
                JOItemsG.Add('taxableAmount', PurchLine.Amount);
                JArrayItemsG.Add(JOItemsG);
            UNTIL PurchLine.NEXT = 0;
            JOsupplyTypeG.Add('itemList', JArrayItemsG);
            //JsonTextWriter.WriteEndArray;
        END;
    end;

    procedure SubConVechileJson()
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
    begin
        LocationBuff.GET(PurchHeader."Location Code");
        StateBuff.GET(LocationBuff."State Code");
        IF IsPosting THEN BEGIN
            Reason := EWayBillingSetup."Vehicle Reason";
            ReasonRemarks := EWayBillingSetup."Vehicle Remarks";
            VehicleNo := PurchHeader."Vehicle No.";
        END ELSE BEGIN
            Reason := EWayBillingSetup."Vehicle Reason";
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
            UpdateOldVechileNoInEWayEntry(3, PurchHeader."No.", PurchHeader."Vehicle No.");
            PurchHeader."Vehicle No." := VehicleNo;
            PurchHeader.MODIFY();
        END;

        IF TransportMethod.GET(PurchHeader."Transport Method") THEN BEGIN
            CASE TransportMethod."Transportation Mode" OF
                TransportMethod."Transportation Mode"::Road:
                    TransMode := '1';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := '2';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := '3';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := '4';
            END;
        END;
        TransDocNo := '';
        TransDocDate := 0D;
        IF WareHouseRectHead."No." = '' THEN
            PurchWriteVechileJson(GetEwayBillIngNo(TransType::"Purch. Order", PurchHeader."No."), VehicleNo, LocationBuff.City, StateBuff."State Code for eTDS/TCS", Reason, ReasonRemarks,
                          TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode)
        ELSE
            PurchWriteVechileJson(GetEwayBillIngNo(TransType::"Whse. Rect", WareHouseRectHead."No."), VehicleNo, LocationBuff.City, StateBuff."State Code for eTDS/TCS", Reason, ReasonRemarks,
                      TransDocNo, FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode)
    end;

    local procedure SubConWriteVechileJson(EwbNo: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; ReasonCode: Text; ReasonRem: Text; TransDocNo: Text; TransDocDate: Text; TransMode: Text)
    var
        EwbBigInt: BigInteger;
    begin
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('EwbNo');
         JsonTextWriter.WriteValue(EwbNo);
         JsonTextWriter.WritePropertyName('VehicleNo');
         JsonTextWriter.WriteValue(VehicleNo);
         JsonTextWriter.WritePropertyName('FromPlace');
         JsonTextWriter.WriteValue(FromPlace);
         JsonTextWriter.WritePropertyName('FromState');
         JsonTextWriter.WriteValue(FromState);
         JsonTextWriter.WritePropertyName('ReasonCode');
         JsonTextWriter.WriteValue(ReasonCode);
         JsonTextWriter.WritePropertyName('ReasonRem');
         JsonTextWriter.WriteValue(ReasonRem);
         JsonTextWriter.WritePropertyName('TransDocNo');
         JsonTextWriter.WriteValue(TransDocNo);
         JsonTextWriter.WritePropertyName('TransDocDate');
         JsonTextWriter.WriteValue(TransDocDate);
         JsonTextWriter.WritePropertyName('TransMode');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WriteEndObject();*/
        JOVehicleG.Add('EwbNo', EwbNo);
        JOVehicleG.Add('VehicleNo', VehicleNo);
        JOVehicleG.Add('FromPlace', FromPlace);
        JOVehicleG.Add('FromState', FromState);
        JOVehicleG.Add('ReasonCode', ReasonCode);
        JOVehicleG.Add('ReasonRem', ReasonRem);
        JOVehicleG.Add('TransDocNo', TransDocNo);
        JOVehicleG.Add('TransDocDate', '');
        JOVehicleG.add('TransMode', TransMode);
    end;

    local procedure SubConCancelEwayJson()
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
            PurchWriteCancelJson(GetEwayBillIngNo(TransType::"Purch. Order", PurchHeader."No."), Reason, ReasonRemarks)
        ELSE
            PurchWriteCancelJson(GetEwayBillIngNo(TransType::"Whse. Rect", WareHouseRectHead."No."), Reason, ReasonRemarks);
    end;

    local procedure SubConWriteCancelJson(EWBNo: Text; CancelReason: Text; CancelRemarks: Text)
    begin
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('ewbNo');
         JsonTextWriter.WriteValue(EWBNo);
         JsonTextWriter.WritePropertyName('cancelRsnCode');
         JsonTextWriter.WriteValue(CancelReason);
         JsonTextWriter.WritePropertyName('cancelRmrk');
         JsonTextWriter.WriteValue(CancelRemarks);
         JsonTextWriter.WriteEndObject();*/
        JOCancelG.Add('ewbNo', EWBNo);
        JOCancelG.Add('cancelRsnCode', CancelReason);
        JOCancelG.Add('cancelRmrk', CancelRemarks);
    end;

    procedure SubConRejectEwayJson(RejDocumentNo: Code[20]; var RejEwayBillNo: BigInteger)
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
        JsonTextWriter.WritePropertyName('ewbNo');
        JsonTextWriter.WriteValue(RejectEwayBillNo);
        JsonTextWriter.WriteEndObject();*/
        JORejEWayNoG.Add('ewbNo', RejectEwayBillNo);
        EVALUATE(RejEwayBillNo, RejectEwayBillNo);
        //ExportAsJson(RejDocumentNo, PathSaved);
    end;

    local procedure SubConUpdateTransportJson()
    var
        TransportID: Text;
        TransportIDError: Label 'Transport Id must have value';
    begin
        //B2BUPG1.0>>
        //TransportID := Windows.InputBox('Transporter ID :', '', '', 10, 10);
        Clear(EWayUpdate);
        Commit();
        EWayUpdate.SetData(2);
        if EWayUpdate.RunModal() = Action::Yes then
            EWayUpdate.GetData(2, TransportID);
        //B2BUPG1.0<<
        IF TransportID = '' THEN
            ERROR(TransportIDError);
        /*  JsonTextWriter.WriteStartObject();
          JsonTextWriter.WritePropertyName('ewbNo');
          IF WareHouseRectHead."No." = '' THEN
              JsonTextWriter.WriteValue(GetEwayBillIngNo(TransType::"Purch. Order", PurchHeader."No."))
          ELSE
              JsonTextWriter.WriteValue(GetEwayBillIngNo(TransType::"Whse. Rect", WareHouseRectHead."No."));
          JsonTextWriter.WritePropertyName('transporterId');
          JsonTextWriter.WriteValue(TransportID);
          JsonTextWriter.WriteEndObject();*/
        JOUpdatetransportIDG.Add('ewbNo', GetEwayBillIngNo(TransType::"Transfer Order", TransferShipmentHeader."No."));
        JOUpdatetransportIDG.Add('transporterId', TransportID);
    end;

    local procedure SubConExtendValidityJson()
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
                    TransMode := '1';
                TransportMethod."Transportation Mode"::Rail:
                    TransMode := '2';
                TransportMethod."Transportation Mode"::Air:
                    TransMode := '3';
                TransportMethod."Transportation Mode"::Ship:
                    TransMode := '4';
            END;
        END;

        TransDocNo := '';
        TransDocDate := 0D;
        IF WareHouseRectHead."No." = '' THEN
            PurchWriteExtendValidityJson(GetEwayBillIngNo(TransType::"Purch. Order", PurchHeader."No."), PurchHeader."Vehicle No.", LocationBuff.City, StateBuff."State Code (GST Reg. No.)", RemainingDist, TransDocNo,
                        FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode, Reason, ReasonRemarks, Pin, 'T', PurchHeader."Transaction Type",
                        '', '', '')
        ELSE
            PurchWriteExtendValidityJson(GetEwayBillIngNo(TransType::"Whse. Rect", WareHouseRectHead."No."), PurchHeader."Vehicle No.", LocationBuff.City, StateBuff."State Code (GST Reg. No.)", RemainingDist, TransDocNo,
                        FORMAT(TransDocDate, 0, '<Day,2>/<Month,2>/<Year4>'), TransMode, Reason, ReasonRemarks, Pin, 'T', PurchHeader."Transaction Type",
                        '', '', '');
    end;

    local procedure SubConWriteExtendValidityJson(EwbNo: Text; VehicleNo: Text; FromPlace: Text; FromState: Text; RemainingDist: Integer; TransDocNo: Text; TransDocDate: Text; TransMode: Text; ReasonCode: Text; ReasonRem: Text; FromPincode: Integer; ConsignmentStatus: Text; TransitType: Text; AddressLine1: Text; AddressLine2: Text; AddressLine3: Text)
    begin
        /* JsonTextWriter.WriteStartObject();
         JsonTextWriter.WritePropertyName('EwbNo');
         JsonTextWriter.WriteValue(EwbNo);
         JsonTextWriter.WritePropertyName('vehicleNo');
         JsonTextWriter.WriteValue(VehicleNo);
         JsonTextWriter.WritePropertyName('fromPlace');
         JsonTextWriter.WriteValue(FromPlace);
         JsonTextWriter.WritePropertyName('fromState');
         JsonTextWriter.WriteValue(FromState);
         JsonTextWriter.WritePropertyName('remainingDistance');
         JsonTextWriter.WriteValue(RemainingDist);
         JsonTextWriter.WritePropertyName('TransDocNo');
         JsonTextWriter.WriteValue(TransDocNo);
         JsonTextWriter.WritePropertyName('TransDocDate');
         JsonTextWriter.WriteValue(TransDocDate);
         JsonTextWriter.WritePropertyName('TransMode');
         JsonTextWriter.WriteValue(TransMode);
         JsonTextWriter.WritePropertyName('extnRsnCode');
         JsonTextWriter.WriteValue(ReasonCode);
         JsonTextWriter.WritePropertyName('extnRemarks');
         JsonTextWriter.WriteValue(ReasonRem);
         JsonTextWriter.WritePropertyName('fromPincode');
         JsonTextWriter.WriteValue(FromPincode);
         JsonTextWriter.WritePropertyName('consignmentStatus');
         JsonTextWriter.WriteValue(ConsignmentStatus);
         JsonTextWriter.WritePropertyName('transitType');
         JsonTextWriter.WriteValue(TransitType);
         JsonTextWriter.WritePropertyName('addressLine1');
         JsonTextWriter.WriteValue(AddressLine1);
         JsonTextWriter.WritePropertyName('addressLine2');
         JsonTextWriter.WriteValue(AddressLine2);
         JsonTextWriter.WritePropertyName('addressLine3');
         JsonTextWriter.WriteValue(AddressLine3);
         JsonTextWriter.WriteEndObject();*/
        JOExtendValidityJsonG.Add('EwbNo', EwbNo);
        JOExtendValidityJsonG.Add('vehicleNo', VehicleNo);
        JOExtendValidityJsonG.Add('fromPlace', FromPlace);
        JOExtendValidityJsonG.Add('fromState', FromState);
        JOExtendValidityJsonG.Add('remainingDistance', RemainingDist);
        JOExtendValidityJsonG.Add('TransDocNo', TransDocNo);
        JOExtendValidityJsonG.Add('TransDocDate', TransDocDate);
        JOExtendValidityJsonG.Add('TransMode', '5');
        JOExtendValidityJsonG.Add('extnRsnCode', ReasonCode);
        JOExtendValidityJsonG.Add('extnRemarks', ReasonRem);
        JOExtendValidityJsonG.add('fromPincode', FromPincode);
        JOExtendValidityJsonG.add('consignmentStatus', ConsignmentStatus);
        JOExtendValidityJsonG.add('transitType', 'R');
        JOExtendValidityJsonG.Add('addressLine1', AddressLine1);
        JOExtendValidityJsonG.Add('addressLine2', AddressLine2);
        JOExtendValidityJsonG.Add('addressLine3', AddressLine3);

    end;

    procedure SubConCalCulateShipmentGST(PurchHead: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
        StateBuff: Record State;
    begin
        //B2BUPG1.0>>
        /*PurchDeleteGSTEntry(); //
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
        END;*/
        //B2BUPG1.0<<
    end;

    local procedure SubConCalculateGSTAmounts(DocumentNo: Code[20]; LineNo: Integer; GSTJurisdiction: Option; GSTStateCode: Code[10]; GSTGroupCode: Code[20]; EffectiveDate: Date; Amount: Decimal; CurrencyCode: Code[10]; CurrencyFactor: Decimal; UnitCost: Decimal; LineQty: Decimal; UOM: Code[10]; ItemNo: Code[20]; Discount: Decimal)
    var
        GSTComponent: Record "Tax Component";
        GSTSetup: Record "GST Setup";
        //GSTCalculationBuffer: Record Table16421;
        TotalGSTAmount: Decimal;
    begin
        //B2BUPG1.0>>
        /*GSTComponent.SETCURRENTKEY("Calculation Order");
        GSTComponent.SetRange("Tax Type", 'GST');
        GSTComponent.SETRANGE("GST Jurisdiction Type", GSTJurisdiction);
        IF GSTComponent.FINDSET THEN
            REPEAT
                IF PurchGetGSTSetup(GSTSetup, GSTStateCode, GSTGroupCode, GSTComponent.Code, EffectiveDate) <> '' THEN BEGIN
                    PurchInitGSTCalculationBuffer(
                              GSTSetup, DocumentNo, LineNo, UnitCost,
                              EffectiveDate, CurrencyCode, CurrencyFactor, Amount, Discount)
                END;
            UNTIL GSTComponent.NEXT = 0;*/
        //B2BUPG1.0<<
    end;

    procedure SubConGetGSTSetup(var GSTSetup: Record "GST Setup"; GSTStateCode: Code[10]; GSTGroupCode: Code[20]; GSTComponentCode: Code[10]; EffectiveDate: Date): Code[20]
    begin
        //B2BUPG1.0>>
        /*WITH GSTSetup DO BEGIN
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
        END;*/
        //B2BUPG1.0>>
    end;

    local procedure SubConInitGSTCalculationBuffer(GSTSetup: Record "GST Setup"; DocumentNo: Code[20]; LineNo: Integer; UnitCost: Decimal; PostingDate: Date; CurrencyCode: Code[10]; CurrencyFactor: Decimal; SaleAmount: Decimal; DiscountPer: Decimal)
    var
        Percentage: Decimal;
        Threshold: Decimal;
        GSTEntry: Record "GST Entry";
        TransactionType: Option Purchase,Sales,Transfer,Service,"Service Transfer",Production;
    begin
        //B2BUPG1.0>>
        /*WITH GSTEntry DO BEGIN
            INIT;
            "Transaction Type" := "Transaction Type"::Purchase;
            "Document Type" := DocType;
            "Document No." := DocumentNo;
            "GST Group Code" := GSTSetup."GST Group Code";
            "GST Component Code" := GSTSetup."GST Component Code";
            "Effective Date" := GSTSetup."Effective Date";
            "Document Line No." := LineNo;
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

            "GST Component %" := Percentage;
            Amount := (SaleAmount - (SaleAmount * DiscountPer / 100)) * "GST Component %" / 100;
            INSERT(TRUE);
        END;*/
        //B2BUPG1.0<<
    end;

    local procedure SubConDeleteGSTEntry()
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

    local procedure SubConConvertAmountLCYToFCYRoundSmall(CurrencyCode: Code[10]; Amount: Decimal; CurrencyFactor: Decimal; PostingDate: Date): Decimal
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

    local procedure ReturnGSTBaseAmount(DocumentNo: Code[20]; LineNo: Integer; var GSTBaseAmount: Decimal)
    var
        GSTLedger: Record "Detailed GST Ledger Entry";
    begin
        GSTLedger.Reset();
        GSTLedger.SetRange("Document No.", DocumentNo);
        if LineNo <> 0 then
            GSTLedger.SetRange("Document Line No.", LineNo);
        if GSTLedger.FindLast() then
            GSTBaseAmount := abs(GSTLedger."GST Base Amount");
    end;

    local procedure ReturnGSTAmount(DocumentNo: Code[20]; LineNo: Integer; var GSTAmount: Decimal)
    var
        GSTLedger: Record "Detailed GST Ledger Entry";
    begin
        GSTLedger.Reset();
        GSTLedger.SetRange("Document No.", DocumentNo);
        if LineNo <> 0 then
            GSTLedger.SetRange("Document Line No.", LineNo);
        if GSTLedger.FindSet() then begin
            repeat
                GSTAmount += abs(GSTLedger."GST Amount");
            until GSTLedger.Next() = 0;
        end;

    end;

    //B2BSaas Body<<    
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
    //B2BSaas Body<<
}

