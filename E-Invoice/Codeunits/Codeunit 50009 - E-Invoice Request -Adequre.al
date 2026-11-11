codeunit 50009 "E-Invoice Request -Adequre"
{

    Permissions = tabledata "E-Invoice Entry" = RMDI, tabledata "E-Invoice Log" = RMDI;
    // version E-INV,5002Fix,FreeSupplyFix,EXPFIX,POSShipToGSTINFix,NonGst,BugFixUnitPrc,E-INVB2C

    // 5002Fix
    // FreeSupplyFix
    // EXPFIX    Only for Invoice
    // NonGst
    // BugFixUnitPrc
    trigger OnRun();
    begin
        //EXPFIX >>
        CLEAR(CurrCode);
        CLEAR(CurrFactor);
        //EXPFIX <<
        IF IsInvoice THEN BEGIN
            IF SalesInvoiceHeader."GST Customer Type" IN [SalesInvoiceHeader."GST Customer Type"::Unregistered, SalesInvoiceHeader."GST Customer Type"::" "]
            THEN
                ERROR(UnRegCusrErr);

            //EXPFIX >>
            CurrCode := SalesInvoiceHeader."Currency Code";
            CurrFactor := SalesInvoiceHeader."Currency Factor";
            //EXPFIX <<

            DocumentNo := SalesInvoiceHeader."No.";
            WriteFileHeader;
            WriteTransDtls;
            ReadDocDtls;
            ReadSellerDtls;
            ReadBuyerDtls;
            ReadDispDtls;
            ReadShipDtls;
            ReadItemList;
            ReadPayDtls;
            ReadRefDtls;
            ReadAddlDocDtls;
            ReadExpDtls;
            ReadEwbDtls;
            ReadValDtls;
        END
        ELSE
            IF CreditMemo THEN BEGIN
                IF SalesCrMemoHeader."GST Customer Type" IN [SalesCrMemoHeader."GST Customer Type"::Unregistered, SalesCrMemoHeader."GST Customer Type"::" "]
                THEN
                    ERROR(UnRegCusrErr);

                //EXPFIX >>
                CurrCode := SalesCrMemoHeader."Currency Code";
                CurrFactor := SalesCrMemoHeader."Currency Factor";
                //EXPFIX <<

                DocumentNo := SalesCrMemoHeader."No.";
                if StrLen(DocumentNo) > 18 then begin
                    DocumentNo := CopyStr(DocumentNo, 3, 18);
                end;
                WriteFileHeader;
                WriteTransDtls;
                ReadDocDtls;
                ReadSellerDtls;
                ReadBuyerDtls;
                ReadDispDtls;
                ReadShipDtls;
                ReadItemList;
                ReadPayDtls;
                ReadRefDtls;
                ReadAddlDocDtls;
                ReadExpDtls;
                ReadEwbDtls;
                ReadValDtls;
            END
            //EInvTrans>>
            ELSE
                IF TransferShipment THEN BEGIN
                    //        IF "GST Customer Type" IN ["GST Customer Type"::Unregistered,"GST Customer Type"::" "]
                    //        THEN
                    //          ERROR(UnRegCusrErr);

                    DocumentNo := TransferShipmentHeader."No.";
                    WriteFileHeader;
                    WriteTransDtls;
                    ReadDocDtls;
                    ReadSellerDtls;
                    ReadBuyerDtls;
                    ReadDispDtls;
                    ReadShipDtls;
                    ReadItemList;
                    ReadPayDtls;
                    ReadRefDtls;
                    ReadAddlDocDtls;
                    ReadExpDtls;
                    ReadEwbDtls;
                    ReadValDtls;
                END;
        //EInvTrans<<


        // GST Integration Log Start
        EInvoiceLog.INIT;
        IF IsInvoice THEN BEGIN
            EInvoiceLog."Document Type" := EInvoiceLog."Document Type"::Invoice;
            EInvoiceLog."Document No." := SalesInvoiceHeader."No.";
        END ELSE
            IF CreditMemo THEN BEGIN
                EInvoiceLog."Document Type" := EInvoiceLog."Document Type"::"Credit Memo";
                EInvoiceLog."Document No." := SalesCrMemoHeader."No.";
                //EInvTrans>>
            END ELSE
                IF TransferShipment THEN BEGIN
                    EInvoiceLog."Document Type" := EInvoiceLog."Document Type"::"Transfer Shipment";
                    EInvoiceLog."Document No." := TransferShipmentHeader."No.";
                END;
        //EInvTrans<<
        EInvoiceLog."Request Path" := JsonRequestPath;
        EInvoiceLog.INSERT(true);
        // GST Integration Log End
    end;

    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        //B2BJSONVar>>
        JObjVerG: JsonObject;
        JSODcoDtlsG: JsonObject;
        JSArryDocDtlsG: JsonArray;
        JSOBJValG: JsonObject;
        JObjtrnsG: JsonObject;
        JObjDtlsG: JsonObject;
        JObjSellerDtlsG: JsonObject;
        JObjBuyerDtlsG: JsonObject;
        JObjDispDtlsG: JsonObject;

        JObJCancelG: JsonObject;
        JObjBactchLineG: JsonObject;
        JObjItemArrayG: JsonArray;
        JObjShipDtlsG: JsonObject;
        JObjPayDtlsG: JsonObject;
        JObjRefDtlsG: JsonObject;
        JObjAddlDocDtlsG: JsonObject;
        JObjExpDtlsG: JsonObject;
        JObjEwbDtlsG: JsonObject;
        JObjValDtlsG: JsonObject;
        JVOBJG: JsonValue;
        JObjContrlDtlsG: JsonObject;
        JArryContrlDtlsG: JsonArray;
        JObjPreDtlsG: JsonObject;
        JSArrayPreDtlsG: JsonArray;
        //B2BJSONVar<<
        GlobalNULL: Variant;
        UnRegCusrErr: TextConst ENU = 'E-Invoicing is not applicable for Unregistered Customer.', ENN = 'E-Invoicing is not applicable for Unregistered Customer.';
        RecIsEmptyErr: TextConst ENU = 'Record variable uninitialized.', ENN = 'Record variable uninitialized.';
        IsInvoice: Boolean;
        SalesLinesErr: TextConst Comment = '%1 = Sales Lines count', ENU = 'E-Invoice allowes only 1000 lines per Invoice. Curent transaction is having %1 lines.', ENN = 'E-Invoice allowes only 100 lines per Invoice. Curent transaction is having %1 lines.';
        DocumentNo: Text[20];
        EInvoiceLog: Record "E-Invoice Log";
        JsonRequestPath: Text;
        CurrCode: Code[20];
        CurrFactor: Decimal;
        CreditMemo: Boolean;
        TransferShipment: Boolean;
        TransferShipmentHeader: Record "Transfer Shipment Header";
        //B2BUPGSERVICE1.0>> Service Orders
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        IsServiceInvoice: Boolean;
    //B2BUPGSERVICE1.0<< Service Orders

    local procedure WriteFileHeader()
    begin
        JObjVerG.Add('Version', '1.1');
        JVOBJG.SetValueToNull();
    end;

    local procedure WriteTransDtls()
    var
        SupTyp: Text[10];
        RegRev: Text[1];
        EcmGstin: Code[15];
        Location: Record Location;

    begin
        IF IsInvoice THEN BEGIN
            CASE SalesInvoiceHeader."GST Customer Type" OF
                SalesInvoiceHeader."GST Customer Type"::Registered, SalesInvoiceHeader."GST Customer Type"::Exempted:
                    SupTyp := 'B2B';
                SalesInvoiceHeader."GST Customer Type"::Export:
                    BEGIN
                        IF SalesInvoiceHeader."GST Without Payment of Duty" THEN
                            SupTyp := 'EXPWOP'
                        ELSE
                            SupTyp := 'EXPWP';
                    END;
                SalesInvoiceHeader."GST Customer Type"::"Deemed Export":
                    SupTyp := 'DEXP';
                SalesInvoiceHeader."GST Customer Type"::"SEZ Unit", SalesInvoiceHeader."GST Customer Type"::"SEZ Development":
                    BEGIN
                        IF SalesInvoiceHeader."GST Without Payment of Duty" THEN
                            SupTyp := 'SEZWOP'
                        ELSE
                            SupTyp := 'SEZWP';
                    END;
            END;
        END ELSE
            IF CreditMemo THEN BEGIN
                CASE SalesCrMemoHeader."GST Customer Type" OF
                    SalesCrMemoHeader."GST Customer Type"::Registered, SalesCrMemoHeader."GST Customer Type"::Exempted:
                        SupTyp := 'B2B';
                    SalesCrMemoHeader."GST Customer Type"::Export:
                        BEGIN
                            IF SalesCrMemoHeader."GST Without Payment of Duty" THEN
                                SupTyp := 'EXPWOP'
                            ELSE
                                SupTyp := 'EXPWP';
                        END;
                    SalesCrMemoHeader."GST Customer Type"::"Deemed Export":
                        SupTyp := 'DEXP';
                    SalesCrMemoHeader."GST Customer Type"::"SEZ Unit", SalesCrMemoHeader."GST Customer Type"::"SEZ Development":
                        BEGIN
                            IF SalesCrMemoHeader."GST Without Payment of Duty" THEN
                                SupTyp := 'SEZWOP'
                            ELSE
                                SupTyp := 'SEZWP';
                        END;
                END;
                //EInvTrans>>
            END ELSE
                IF TransferShipment THEN BEGIN
                    SupTyp := 'B2B'
                END;
        //EInvTrans<<
        //>>v1.03
        RegRev := 'N';
        EcmGstin := '';
        //<<v1.03
        //B2B>>
        JObjtrnsG.Add('TaxSch', 'GST');
        JObjtrnsG.Add('SupTyp', SupTyp);
        JObjtrnsG.Add('RegRev', RegRev);
        IF EcmGstin <> '' THEN
            JObjtrnsG.Add('EcmGstin', EcmGstin)
        else
            JObjtrnsG.Add('EcmGstin', JVOBJG.AsToken());
        JObjtrnsG.Add('IgstOnIntra', 'N');
        JObjVerG.Add('TranDtls', JObjtrnsG);
        //B2B<<


    end;

    local procedure ReadDocDtls();
    var
        Typ: Text[3];
        Dt: Text[10];
    begin
        IF IsInvoice THEN BEGIN
            IF SalesInvoiceHeader."Invoice Type" = SalesInvoiceHeader."Invoice Type"::Taxable THEN
                Typ := 'INV'
            ELSE
                IF (SalesInvoiceHeader."Invoice Type" = SalesInvoiceHeader."Invoice Type"::"Debit Note") OR
                   (SalesInvoiceHeader."Invoice Type" = SalesInvoiceHeader."Invoice Type"::Supplementary)
                THEN
                    Typ := 'DBN'
                ELSE
                    Typ := 'INV';
            Dt := FORMAT(SalesInvoiceHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>');
        END ELSE
            IF CreditMemo THEN BEGIN
                Typ := 'CRN';
                Dt := FORMAT(SalesCrMemoHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>');
                //EInvTrans>>
            END ELSE
                IF TransferShipment THEN BEGIN
                    Typ := 'INV';
                    Dt := FORMAT(TransferShipmentHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>');
                END;
        //EInvTrans<<
        WriteDocDtls(Typ, COPYSTR(DocumentNo, 1, 16), Dt); //NB
    end;

    local procedure WriteDocDtls(Typ: Text[3]; No: Text[16]; Dt: Text[10]);
    begin

        JObjDtlsG.Add('Typ', Typ);
        JObjDtlsG.Add('No', No);
        JObjDtlsG.Add('Dt', Dt);
        JObjVerG.Add('DocDtls', JObjDtlsG);

    end;

    local procedure ReadExpDtls();
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        //GSTManagement: Codeunit 16401;
        ExpCat: Text[3];
        WithPay: Text[1];
        ShipBNo: Text[16];
        ShipBDt: Text[10];
        Port: Text[10];
        RefClm: Text[1];
        InvForCur: Decimal;
        ForCur: Text[3];
        CntCode: Text[2];
    begin
        IF IsInvoice THEN BEGIN
            IF SalesInvoiceHeader."GST Customer Type" IN
               [SalesInvoiceHeader."GST Customer Type"::Export,
                SalesInvoiceHeader."GST Customer Type"::"Deemed Export",
                SalesInvoiceHeader."GST Customer Type"::"SEZ Unit",
                SalesInvoiceHeader."GST Customer Type"::"SEZ Development"]
            THEN BEGIN
                ShipBNo := COPYSTR(SalesInvoiceHeader."Bill Of Export No.", 1, 16);
                ShipBDt := FORMAT(SalesInvoiceHeader."Bill Of Export Date", 0, '<Day,2>/<Month,2>/<Year4>');
                Port := SalesInvoiceHeader."Exit Point";
                RefClm := 'N';//
                ForCur := COPYSTR(SalesInvoiceHeader."Currency Code", 1, 3);
                CntCode := COPYSTR(SalesInvoiceHeader."Bill-to Country/Region Code", 1, 2);
            END;
        END
        ELSE
            IF CreditMemo THEN BEGIN
                IF SalesCrMemoHeader."GST Customer Type" IN
                   [SalesCrMemoHeader."GST Customer Type"::Export,
                    SalesCrMemoHeader."GST Customer Type"::"Deemed Export",
                    SalesCrMemoHeader."GST Customer Type"::"SEZ Unit",
                    SalesCrMemoHeader."GST Customer Type"::"SEZ Development"]
                THEN BEGIN
                    ShipBNo := COPYSTR(SalesCrMemoHeader."Bill Of Export No.", 1, 16);
                    ShipBDt := FORMAT(SalesCrMemoHeader."Bill Of Export Date", 0, '<Year4>-<Month,2>-<Day,2>');
                    Port := SalesCrMemoHeader."Exit Point";
                    RefClm := 'N';//
                    ForCur := COPYSTR(SalesCrMemoHeader."Currency Code", 1, 3);
                    CntCode := COPYSTR(SalesCrMemoHeader."Bill-to Country/Region Code", 1, 2);
                END;
            END
            //EInvTrans>>
            ELSE
                IF TransferShipment THEN BEGIN
                    ShipBNo := '';
                    ShipBDt := '';
                    Port := '';
                    RefClm := 'N'; ///Need to check
                    ForCur := '';
                    CntCode := '';
                END;
        //EInvTrans<<
        IF (ShipBNo = '') AND (ShipBDt = '') AND (Port = '') AND (ForCur = '') AND (CntCode = '') THEN BEGIN
            JObjVerG.Add('ExpDtls', JVOBJG.AsToken());
        END ELSE
            WriteExpDtls(ShipBNo, ShipBDt, Port, RefClm, ForCur, CntCode);
    end;

    local procedure WriteExpDtls(ShipBNo: Text[16]; ShipBDt: Text[10]; Port: Text[10]; RefClm: Text[1]; ForCur: Text[3]; CntCode: Text[2]);
    begin
        //B2B>>
        if ShipBNo <> '' then
            JObjExpDtlsG.Add('ShipBNo', ShipBNo)
        else
            JObjExpDtlsG.Add('ShipBNo', JVOBJG.AsToken());
        if ShipBDt <> '' then
            JObjExpDtlsG.Add('ShipBDt', ShipBDt)
        else
            JObjExpDtlsG.Add('ShipBDt', JVOBJG.AsToken());
        if Port <> '' then
            JObjExpDtlsG.Add('Port', Port)
        else
            JObjExpDtlsG.Add('Port', JVOBJG.AsToken());
        if RefClm <> '' then
            JObjExpDtlsG.Add('RefClm', RefClm)
        else
            JObjExpDtlsG.Add('RefClm', JVOBJG.AsToken());
        if ForCur <> '' then
            JObjExpDtlsG.Add('ForCur', ForCur)
        else
            JObjExpDtlsG.Add('ForCur', JVOBJG.AsToken());
        if CntCode <> '' then
            JObjExpDtlsG.Add('CntCode', CntCode)
        else
            JObjExpDtlsG.Add('CntCode', JVOBJG.AsToken());
        JObjVerG.Add('ExpDtls', JObjExpDtlsG);
        //B2B<<
    end;

    local procedure ReadEwbDtls();
    var
        TransId: Text[15];
        TransName: Text[100];
        TransMode: Text[1];
        Distance: Integer;
        TransDocNo: Text[15];
        TransDocDt: Text[10];
        VehNo: Text[20];
        VehType: Text[1];
        TransportMethod: Record 259;
    begin
        IF IsInvoice THEN begin
            TransId := '';//Transit/GSTIN
            IF TransportMethod.GET(SalesInvoiceHeader."Transport Method") THEN BEGIN
                //TransName := TransportMethod.Description;

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
            Distance := ROUND(SalesInvoiceHeader."Distance (Km)", 1, '=');
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
        end ELSE
            IF CreditMemo THEN begin
                TransId := '';//Transit/GSTIN
                IF TransportMethod.GET(SalesCrMemoHeader."Transport Method") THEN BEGIN
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
                    //B2BSaas
                END;
                Distance := ROUND(SalesCrMemoHeader."Distance (Km)", 1, '=');
                TransDocNo := '';//Trnasport Document No.
                TransDocDt := '';//Transport Doc Date
                VehNo := SalesCrMemoHeader."Vehicle No.";
                CASE SalesCrMemoHeader."Vehicle Type" OF
                    SalesCrMemoHeader."Vehicle Type"::" ":
                        VehType := '';
                    SalesCrMemoHeader."Vehicle Type"::ODC:
                        VehType := 'O';
                    SalesCrMemoHeader."Vehicle Type"::Regular:
                        VehType := 'R';
                END;
                //EInvTrans>>
            end ELSE
                IF TransferShipment THEN BEGIN
                    TransId := '';
                    Distance := ROUND(TransferShipmentHeader."Distance (Km)", 1, '=');
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
                END;
        //EInvTrans<<

        IF (TransId = '') AND (TransName = '') AND (TransMode = '') AND (Distance = 0) AND (TransDocNo = '') AND (TransDocDt = '') AND
          (VehNo = '') AND (VehType = '')
        THEN BEGIN
            JObjVerG.Add('EwbDtls', JVOBJG.AsToken());
        END ELSE
            WriteEwbDtls(TransId, TransName, TransMode, Distance, TransDocNo, TransDocDt, VehNo, VehType);
    end;

    local procedure WriteEwbDtls(TransId: Text[15]; TransName: Text[100]; TransMode: Text[1]; Distance: Integer; TransDocNo: Text[15]; TransDocDt: Text[10]; VehNo: Text[20]; VehType: Text[1]);
    begin

        //B2B>>
        if TransId <> '' then
            JObjEwbDtlsG.Add('TransId', TransId)
        else
            JObjEwbDtlsG.Add('TransId', JVOBJG.AsToken());
        if TransName <> '' then
            JObjEwbDtlsG.Add('TransName', TransName)
        else
            JObjEwbDtlsG.Add('TransName', JVOBJG.AsToken());
        if TransMode <> '' then
            JObjEwbDtlsG.Add('TransMode', TransMode)
        else
            JObjEwbDtlsG.Add('TransMode', JVOBJG.AsToken());
        JObjEwbDtlsG.Add('Distance', Distance);
        if TransDocNo <> '' then
            JObjEwbDtlsG.Add('TransDocNo', TransDocNo)
        else
            JObjEwbDtlsG.Add('TransDocNo', JVOBJG.AsToken());
        if TransDocDt <> '' then
            JObjEwbDtlsG.Add('TransDocDt', TransDocDt)
        else
            JObjEwbDtlsG.Add('TransDocDt', JVOBJG.AsToken());
        if VehNo <> '' then
            JObjEwbDtlsG.Add('VehNo', VehNo)
        else
            JObjEwbDtlsG.Add('VehNo', JVOBJG.AsToken());
        if VehType <> '' then
            JObjEwbDtlsG.Add('VehType', VehType)
        else
            JObjEwbDtlsG.Add('VehType', JVOBJG.AsToken());
        JObjVerG.Add('EwbDtls', JObjEwbDtlsG);
        //B2B<<
    end;

    local procedure ReadSellerDtls()
    var
        CompanyInformationBuff: Record 79;
        LocationBuff: Record Location;
        StateBuff: Record State;
        Gstin: Text[15];
        LglNm: Text[100];
        TrdNm: Text[100];
        Add1: Text[100];
        Add2: Text[60];
        Loc: Text[60];
        Pin: Text[6];
        Stcd: Code[2];
        Ph: Text[10];
        Em: Text[50];
    begin
        IF IsInvoice THEN BEGIN
            LocationBuff.GET(SalesInvoiceHeader."Location Code");
            //Gstin := LocationBuff."GST Registration No.";//2016CU19
            Gstin := SalesInvoiceHeader."Location GST Reg. No.";
            CompanyInformationBuff.GET;
            LglNm := CompanyInformationBuff.Name;
            TrdNm := CompanyInformationBuff.Name;
            Add1 := LocationBuff.Address;
            Add2 := LocationBuff."Address 2";
            Loc := LocationBuff.Name;
            Pin := COPYSTR(LocationBuff."Post Code", 1, 6);
            StateBuff.GET(LocationBuff."State Code");
            Stcd := StateBuff."State Code (GST Reg. No.)";//v1.03
            Ph := COPYSTR(LocationBuff."Phone No.", 1, 10);
            Em := GetMailId(LocationBuff."E-Mail");//5002Fix
        END
        ELSE
            IF CreditMemo THEN BEGIN
                LocationBuff.GET(SalesCrMemoHeader."Location Code");
                //Gstin := LocationBuff."GST Registration No.";//2016CU19
                Gstin := SalesCrMemoHeader."Location GST Reg. No.";
                CompanyInformationBuff.GET;
                LglNm := CompanyInformationBuff.Name;
                TrdNm := CompanyInformationBuff.Name;
                Add1 := LocationBuff.Address;
                Add2 := LocationBuff."Address 2";
                Loc := LocationBuff.Name;
                Pin := COPYSTR(LocationBuff."Post Code", 1, 6);
                StateBuff.GET(LocationBuff."State Code");
                Stcd := StateBuff."State Code (GST Reg. No.)";//v1.03
                Ph := COPYSTR(LocationBuff."Phone No.", 1, 10);
                Em := GetMailId(LocationBuff."E-Mail");//5002Fix
            END
            //EInvTrans>>
            ELSE
                IF TransferShipment THEN BEGIN
                    LocationBuff.GET(TransferShipmentHeader."Transfer-from Code");
                    Gstin := LocationBuff."GST Registration No.";
                    CompanyInformationBuff.GET;
                    LglNm := CompanyInformationBuff.Name;
                    TrdNm := CompanyInformationBuff.Name;
                    Add1 := LocationBuff.Address;
                    Add2 := LocationBuff."Address 2";
                    Loc := LocationBuff.Name;
                    Pin := COPYSTR(LocationBuff."Post Code", 1, 6);
                    StateBuff.GET(LocationBuff."State Code");
                    Stcd := StateBuff."State Code (GST Reg. No.)";//v1.03
                    Ph := COPYSTR(LocationBuff."Phone No.", 1, 10);
                    Em := GetMailId(LocationBuff."E-Mail");//5002Fix
                END;
        //EInvTrans<<
        WriteSellerDtls(Gstin, LglNm, TrdNm, Add1, Add2, Loc, Pin, Stcd, Ph, Em);
    end;

    local procedure WriteSellerDtls(Gstin: Text[15]; LglNm: Text[100]; TrdNm: Text[100]; Add1: Text[100]; Add2: Text[60]; Loc: Text[60]; Pin: Text[6]; Stcd: Code[2]; Ph: Text[10]; Em: Text[50]);
    var
        PinInt: Integer;
    begin
        //v1.03 parameter change StateNm to Stcd and related code

        //B2B>>
        Evaluate(PinInt, Pin);
        IF Gstin <> '' then
            JObjSellerDtlsG.Add('Gstin', Gstin)
        else
            JObjSellerDtlsG.Add('Gstin', JVOBJG.AsToken());
        IF LglNm <> '' then
            JObjSellerDtlsG.Add('LglNm', LglNm)
        else
            JObjSellerDtlsG.Add('Lglm', JVOBJG.AsToken());
        IF TrdNm <> '' then
            JObjSellerDtlsG.Add('TrdNm', TrdNm)
        else
            JObjSellerDtlsG.Add('TrdNm', JVOBJG.AsToken());
        IF Add1 <> '' then
            JObjSellerDtlsG.Add('Addr1', Add1)
        else
            JObjSellerDtlsG.Add('Addr1', JVOBJG.AsToken());
        IF Add2 <> '' then
            JObjSellerDtlsG.Add('Addr2', Add2)
        else
            JObjSellerDtlsG.Add('Addr2', JVOBJG.AsToken());
        if Loc <> '' then
            JObjSellerDtlsG.Add('Loc', Loc)
        else
            JObjSellerDtlsG.Add('Loc', Loc);
        if Pin <> '' then
            JObjSellerDtlsG.Add('Pin', PinInt)
        else
            JObjSellerDtlsG.Add('Pin', JVOBJG.AsToken());
        If Stcd <> '' then
            JObjSellerDtlsG.Add('Stcd', Stcd)
        else
            JObjSellerDtlsG.Add('Stcd', Stcd);
        if Ph <> '' then
            JObjSellerDtlsG.Add('Ph', Ph)
        else
            JObjSellerDtlsG.Add('Ph', JVOBJG.AsToken());
        if Em <> '' then
            JObjSellerDtlsG.Add('Em', Em)
        else
            JObjSellerDtlsG.Add('Em', JVOBJG.AsToken());
        JObjVerG.Add('SellerDtls', JObjSellerDtlsG);
        //B2B<<

    end;

    local procedure ReadBuyerDtls();
    var
        Contact: Record 5050;
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        ShipToAddr: Record "Ship-to Address";
        StateBuff: Record State;
        Gstin: Text[15];
        LglNm: Text[100];
        TrdNm: Text[100];
        Pos: Text[2];
        Addr1: Text[100];
        Addr2: Text[60];
        Loc: Text[60];
        Pin: Text[6];
        Stcd: Code[2];
        Ph: Text[10];
        Em: Text[50];
        Customer: Record Customer;
        LocationBuff: Record 14;
    begin
        //>> POSShipToGSTINFix
        IF IsInvoice THEN BEGIN
            IF SalesInvoiceHeader."GST Customer Type" = SalesInvoiceHeader."GST Customer Type"::Export THEN BEGIN
                Gstin := 'URP';
                Pin := '999999';
                Stcd := '96';//v1.03
                LglNm := SalesInvoiceHeader."Bill-to Name";
                TrdNm := SalesInvoiceHeader."Bill-to Name";
                Addr1 := SalesInvoiceHeader."Bill-to Address";
                Addr2 := SalesInvoiceHeader."Bill-to Address 2";
                Loc := SalesInvoiceHeader."Bill-to City";
                Pos := '96';
                IF Contact.GET(SalesInvoiceHeader."Bill-to Contact No.") THEN BEGIN
                    Ph := COPYSTR(Contact."Phone No.", 1, 10);
                    Em := GetMailId(Contact."E-Mail");//5002Fix
                END;
            END ELSE BEGIN
                SalesInvoiceLine.SETRANGE("Document No.", SalesInvoiceHeader."No.");
                SalesInvoiceLine.SETFILTER("No.", '<>%1', '');//BugFix
                IF SalesInvoiceLine.FINDFIRST THEN
                    IF (SalesInvoiceLine."GST Place of Supply" = SalesInvoiceLine."GST Place of Supply"::"Ship-to Address") AND
                       (ShipToAddr.GET(SalesInvoiceHeader."Sell-to Customer No.", SalesInvoiceHeader."Ship-to Code"))
                    THEN BEGIN
                        Gstin := ShipToAddr."GST Registration No.";
                        LglNm := SalesInvoiceHeader."Ship-to Name";
                        TrdNm := SalesInvoiceHeader."Ship-to Name";
                        Addr1 := SalesInvoiceHeader."Ship-to Address";
                        Addr2 := SalesInvoiceHeader."Ship-to Address 2";
                        Loc := SalesInvoiceHeader."Ship-to City";
                        StateBuff.GET(SalesInvoiceHeader."GST Ship-to State Code");
                        Pos := StateBuff."State Code (GST Reg. No.)";
                        Stcd := StateBuff."State Code (GST Reg. No.)";
                        Pin := COPYSTR(SalesInvoiceHeader."Ship-to Post Code", 1, 6);
                        Ph := COPYSTR(ShipToAddr."Phone No.", 1, 10);
                        Em := GetMailId(ShipToAddr."E-Mail");//5002Fix
                    END ELSE BEGIN
                        //Customer.GET("Bill-to Customer No.");
                        //Gstin := Customer."GST Registration No.";//2019CU19
                        Gstin := SalesInvoiceHeader."Customer GST Reg. No.";
                        LglNm := SalesInvoiceHeader."Bill-to Name";
                        TrdNm := SalesInvoiceHeader."Bill-to Name";
                        Addr1 := SalesInvoiceHeader."Bill-to Address";
                        Addr2 := SalesInvoiceHeader."Bill-to Address 2";
                        Loc := SalesInvoiceHeader."Bill-to City";
                        //StateBuff.GET(Customer."State Code");
                        StateBuff.GET(SalesInvoiceHeader."GST Bill-to State Code");
                        Stcd := StateBuff."State Code (GST Reg. No.)";
                        Pos := StateBuff."State Code (GST Reg. No.)";
                        Pin := COPYSTR(SalesInvoiceHeader."Bill-to Post Code", 1, 6);
                        IF Contact.GET(SalesInvoiceHeader."Bill-to Contact No.") THEN BEGIN
                            Ph := COPYSTR(Contact."Phone No.", 1, 10);
                            Em := GetMailId(Contact."E-Mail");//5002Fix
                        END;
                    END;
            END;
        END
        ELSE
            IF CreditMemo THEN BEGIN
                IF SalesCrMemoHeader."GST Customer Type" = SalesCrMemoHeader."GST Customer Type"::Export THEN BEGIN
                    Gstin := 'URP';
                    Pin := '999999';
                    Stcd := '96';//v1.03
                    LglNm := SalesCrMemoHeader."Bill-to Name";
                    TrdNm := SalesCrMemoHeader."Bill-to Name";
                    Addr1 := SalesCrMemoHeader."Bill-to Address";
                    Addr2 := SalesCrMemoHeader."Bill-to Address 2";
                    Loc := SalesCrMemoHeader."Bill-to City";
                    Pos := '96';
                    IF Contact.GET(SalesCrMemoHeader."Bill-to Contact No.") THEN BEGIN
                        Ph := COPYSTR(Contact."Phone No.", 1, 10);
                        Em := GetMailId(Contact."E-Mail");//5002Fix
                    END;
                END ELSE BEGIN
                    SalesCrMemoLine.SETRANGE("Document No.", SalesCrMemoHeader."No.");
                    SalesCrMemoLine.SETFILTER("No.", '<>%1', '');//BugFix
                    IF SalesCrMemoLine.FINDFIRST THEN
                        IF (SalesCrMemoLine."GST Place of Supply" = SalesCrMemoLine."GST Place of Supply"::"Ship-to Address") AND
                           (ShipToAddr.GET(SalesCrMemoHeader."Sell-to Customer No.", SalesCrMemoHeader."Ship-to Code"))
                        THEN BEGIN
                            Gstin := ShipToAddr."GST Registration No.";
                            LglNm := SalesCrMemoHeader."Ship-to Name";
                            TrdNm := SalesCrMemoHeader."Ship-to Name";
                            Addr1 := SalesCrMemoHeader."Ship-to Address";
                            Addr2 := SalesCrMemoHeader."Ship-to Address 2";
                            Loc := SalesCrMemoHeader."Ship-to City";
                            StateBuff.GET(SalesCrMemoHeader."GST Ship-to State Code");
                            Pos := StateBuff."State Code (GST Reg. No.)";
                            Stcd := StateBuff."State Code (GST Reg. No.)";
                            Pin := COPYSTR(SalesCrMemoHeader."Ship-to Post Code", 1, 6);
                            Ph := COPYSTR(ShipToAddr."Phone No.", 1, 10);
                            Em := GetMailId(ShipToAddr."E-Mail");//5002Fix
                        END ELSE BEGIN
                            //Customer.GET("Bill-to Customer No.");
                            //Gstin := Customer."GST Registration No.";//2019CU19
                            Gstin := SalesCrMemoHeader."Customer GST Reg. No.";
                            LglNm := SalesCrMemoHeader."Bill-to Name";
                            TrdNm := SalesCrMemoHeader."Bill-to Name";
                            Addr1 := SalesCrMemoHeader."Bill-to Address";
                            Addr2 := SalesCrMemoHeader."Bill-to Address 2";
                            Loc := SalesCrMemoHeader."Bill-to City";
                            //StateBuff.GET(Customer."State Code");
                            StateBuff.GET(SalesCrMemoHeader."GST Bill-to State Code");
                            Stcd := StateBuff."State Code (GST Reg. No.)";
                            Pos := StateBuff."State Code (GST Reg. No.)";
                            Pin := COPYSTR(SalesCrMemoHeader."Bill-to Post Code", 1, 6);
                            IF Contact.GET(SalesCrMemoHeader."Bill-to Contact No.") THEN BEGIN
                                Ph := COPYSTR(Contact."Phone No.", 1, 10);
                                Em := GetMailId(Contact."E-Mail");//5002Fix
                            END;
                        END;
                END;
            END
            //EInvTrans>>
            ELSE
                IF TransferShipment THEN BEGIN
                    LocationBuff.GET(TransferShipmentHeader."Transfer-to Code");
                    Gstin := LocationBuff."GST Registration No.";
                    LglNm := TransferShipmentHeader."Transfer-to Name";
                    TrdNm := TransferShipmentHeader."Transfer-to Name";
                    Addr1 := TransferShipmentHeader."Transfer-to Address";
                    Addr2 := TransferShipmentHeader."Transfer-to Address 2";
                    Loc := TransferShipmentHeader."Transfer-to City";
                    //StateBuff.GET(Customer."State Code");
                    StateBuff.GET(LocationBuff."State Code");
                    Stcd := StateBuff."State Code (GST Reg. No.)";
                    Pos := StateBuff."State Code (GST Reg. No.)";
                    Pin := COPYSTR(TransferShipmentHeader."Transfer-to Post Code", 1, 6);
                    IF Contact.GET(TransferShipmentHeader."Transfer-to Contact") THEN BEGIN
                        Ph := COPYSTR(Contact."Phone No.", 1, 10);
                        Em := GetMailId(Contact."E-Mail");//5002Fix
                    END;
                END;
        //EInvTrans<<
        //<< POSShipToGSTINFix
        WriteBuyerDtls(Gstin, LglNm, TrdNm, Pos, Addr1, Addr2, Loc, Pin, Stcd, Ph, Em);
    end;

    local procedure WriteBuyerDtls(Gstin: Text[15]; LglNm: Text[100]; TrdNm: Text[100]; Pos: Text[2]; Addr1: Text[100]; Addr2: Text[60]; Loc: Text[60]; Pin: Text[6]; Stcd: Code[2]; Ph: Text[10]; Em: Text[50]);
    var
        PinInt: Integer;
    begin
        //v1.03 //Parameter changed from State to Stcd and related code

        //B2B>>
        Evaluate(PinInt, Pin);
        IF Gstin <> '' then
            JObjBuyerDtlsG.Add('Gstin', Gstin)
        else
            JObjBuyerDtlsG.Add('Gstin', JVOBJG.AsToken());
        IF LglNm <> '' then
            JObjBuyerDtlsG.Add('LglNm', LglNm)
        else
            JObjBuyerDtlsG.Add('Lglm', JVOBJG.AsToken());
        IF TrdNm <> '' then
            JObjBuyerDtlsG.Add('TrdNm', TrdNm)
        else
            JObjBuyerDtlsG.Add('TrdNm', JVOBJG.AsToken());
        if Pos <> '' then
            JObjBuyerDtlsG.Add('Pos', Pos)
        else
            JObjBuyerDtlsG.Add('Pos', JVOBJG.AsToken());
        IF Addr1 <> '' then
            JObjBuyerDtlsG.Add('Addr1', Addr1)
        else
            JObjBuyerDtlsG.Add('Addr1', JVOBJG.AsToken());
        IF Addr2 <> '' then
            JObjBuyerDtlsG.Add('Addr2', Addr2)
        else
            JObjBuyerDtlsG.Add('Addr2', JVOBJG.AsToken());
        if Loc <> '' then
            JObjBuyerDtlsG.Add('Loc', Loc)
        else
            JObjBuyerDtlsG.Add('Loc', JVOBJG.AsToken());
        if Pin <> '' then
            JObjBuyerDtlsG.Add('Pin', PinInt)
        else
            JObjBuyerDtlsG.Add('Pin', JVOBJG.AsToken());
        If Stcd <> '' then
            JObjBuyerDtlsG.Add('Stcd', Stcd)
        else
            JObjBuyerDtlsG.Add('Stcd', JVOBJG.AsToken());
        if Ph <> '' then
            JObjBuyerDtlsG.Add('Ph', Ph)
        else
            JObjBuyerDtlsG.Add('Ph', JVOBJG.AsToken());
        if Em <> '' then
            JObjBuyerDtlsG.Add('Em', Em)
        else
            JObjBuyerDtlsG.Add('Em', JVOBJG.AsToken());
        JObjVerG.Add('BuyerDtls', JObjBuyerDtlsG);
        //B2B<<
    end;

    local procedure ReadDispDtls();
    var
        CompanyInformationBuff: Record 79;
        LocationBuff: Record Location;
        StateBuff: Record State;
        Nm: Text[100];
        Add1: Text[100];
        Add2: Text[60];
        Loc: Text[60];
        Pin: Text[6];
        Stcd: Text[2];
    begin
        IF IsInvoice THEN BEGIN
            CompanyInformationBuff.GET;
            Nm := CompanyInformationBuff.Name;
            LocationBuff.GET(SalesInvoiceHeader."Location Code");
            Add1 := LocationBuff.Address;
            Add2 := LocationBuff."Address 2";
            Loc := LocationBuff.Name;
            Pin := COPYSTR(LocationBuff."Post Code", 1, 6);
            StateBuff.GET(LocationBuff."State Code");
            Stcd := StateBuff."State Code (GST Reg. No.)";
        END
        ELSE
            IF CreditMemo THEN BEGIN
                CompanyInformationBuff.GET;
                Nm := CompanyInformationBuff.Name;
                LocationBuff.GET(SalesCrMemoHeader."Location Code");
                Add1 := LocationBuff.Address;
                Add2 := LocationBuff."Address 2";
                Loc := LocationBuff.Name;
                Pin := COPYSTR(LocationBuff."Post Code", 1, 6);
                StateBuff.GET(LocationBuff."State Code");
                Stcd := StateBuff."State Code (GST Reg. No.)";
            END
            //EInvTrans>>
            ELSE
                IF TransferShipment THEN BEGIN
                    /*WITH TransferShipmentHeader DO BEGIN
                      CompanyInformationBuff.GET;
                      Nm := CompanyInformationBuff.Name;
                      LocationBuff.GET("Transfer-from Code");
                      Add1 := LocationBuff.Address;
                      Add2 := LocationBuff."Address 2";
                      Loc := LocationBuff.Name;
                      Pin := COPYSTR(LocationBuff."Post Code",1,6);
                      StateBuff.GET(LocationBuff."State Code");
                      Stcd := StateBuff."State Code (GST Reg. No.)";
                      END;*/
                    JObjVerG.Add('DispDtls', JVOBJG.AsToken());

                END;
        //EInvTrans<<
        IF NOT TransferShipment THEN
            WriteDispDtls(Nm, Add1, Add2, Loc, Pin, Stcd);
    end;

    local procedure WriteDispDtls(Nm: Text[100]; Add1: Text[100]; Add2: Text[60]; Loc: Text[60]; Pin: Text[6]; Stcd: Text[2]);
    var
        PinInt: Integer;
    begin
        EVALUATE(PinInt, Pin);
        if Nm <> '' then
            JObjDispDtlsG.Add('Nm', Nm)
        else
            JObjDispDtlsG.Add('Nm', JVOBJG.AsToken());
        if Add1 <> '' then
            JObjDispDtlsG.Add('Addr1', Add1)
        else
            JObjDispDtlsG.Add('Addr1', JVOBJG.AsToken());
        if Add2 <> '' then
            JObjDispDtlsG.Add('Addr2', Add2)
        else
            JObjDispDtlsG.Add('Addr2', JVOBJG.AsToken());
        if Loc <> '' then
            JObjDispDtlsG.Add('Loc', Loc)
        else
            JObjDispDtlsG.Add('Loc', JVOBJG.AsToken());
        if Pin <> '' then
            JObjDispDtlsG.Add('Pin', PinInt)
        else
            JObjDispDtlsG.Add('Pin', JVOBJG.AsToken());
        if Stcd <> '' then
            JObjDispDtlsG.Add('Stcd', Stcd)
        else
            JObjDispDtlsG.Add('Stcd', JVOBJG.AsToken());
        JObjVerG.Add('DispDtls', JObjDispDtlsG);

    end;

    local procedure ReadShipDtls();
    var
        ShipToAddr: Record "Ship-to Address";
        StateBuff: Record State;
        Gstin: Text[15];
        LglNm: Text[100];
        TrdNm: Text[100];
        Addr1: Text[100];
        Addr2: Text[60];
        Loc: Text[60];
        Pin: Text[6];
        Stcd: Text[2];
        Ph: Text[10];
        Em: Text[50];
        Customer: Record Customer;
        LocationBuff: Record Location;
    begin
        IF IsInvoice THEN BEGIN
            IF ShipToAddr.GET(SalesInvoiceHeader."Sell-to Customer No.", SalesInvoiceHeader."Ship-to Code") THEN BEGIN
                LglNm := SalesInvoiceHeader."Ship-to Name";
                TrdNm := SalesInvoiceHeader."Ship-to Name";
                Addr1 := SalesInvoiceHeader."Ship-to Address";
                Addr2 := SalesInvoiceHeader."Ship-to Address 2";
                Loc := SalesInvoiceHeader."Ship-to City";
                //v1.03  >>
                IF SalesInvoiceHeader."GST Customer Type" <> SalesInvoiceHeader."GST Customer Type"::Export THEN BEGIN
                    Gstin := ShipToAddr."GST Registration No.";
                    StateBuff.GET(SalesInvoiceHeader."GST Ship-to State Code");
                    //StateBuff.GET(ShipToAddr.State);
                    Stcd := StateBuff."State Code (GST Reg. No.)";
                    Pin := COPYSTR(SalesInvoiceHeader."Ship-to Post Code", 1, 6);
                END ELSE BEGIN
                    Gstin := '';
                    Stcd := '97';//v1.03 //Other Territory
                    Pin := '999999';
                END;
                //v1.03 <<
            END ELSE BEGIN
                LglNm := SalesInvoiceHeader."Bill-to Name";
                TrdNm := SalesInvoiceHeader."Bill-to Name";
                Addr1 := SalesInvoiceHeader."Bill-to Address";
                Addr2 := SalesInvoiceHeader."Bill-to Address 2";
                Loc := SalesInvoiceHeader."Bill-to City";

                IF SalesInvoiceHeader."GST Customer Type" <> SalesInvoiceHeader."GST Customer Type"::Export THEN BEGIN
                    /*
                    Customer.GET("Bill-to Customer No.");
                    Gstin := Customer."GST Registration No.";
                    *///2019CU19
                    Gstin := SalesInvoiceHeader."Customer GST Reg. No.";
                    //>>v1.03
                    StateBuff.GET(SalesInvoiceHeader."GST Bill-to State Code");
                    //StateBuff.GET(Customer."State Code");
                    //<<v1.03
                    Stcd := StateBuff."State Code (GST Reg. No.)";
                    Pin := COPYSTR(SalesInvoiceHeader."Bill-to Post Code", 1, 6);
                END ELSE BEGIN
                    Gstin := '';
                    Stcd := '97';//v1.03 //Other Territory
                    Pin := '999999';
                END;
            END;
            WriteShipDtls(Gstin, LglNm, TrdNm, Addr1, Addr2, Loc, Pin, Stcd);
        END ELSE
            IF CreditMemo THEN BEGIN
                IF ShipToAddr.GET(SalesCrMemoHeader."Sell-to Customer No.", SalesCrMemoHeader."Ship-to Code") THEN BEGIN
                    LglNm := SalesCrMemoHeader."Ship-to Name";
                    TrdNm := SalesCrMemoHeader."Ship-to Name";
                    Addr1 := SalesCrMemoHeader."Ship-to Address";
                    Addr2 := SalesCrMemoHeader."Ship-to Address 2";
                    Loc := SalesCrMemoHeader."Ship-to City";
                    //v1.03  >>
                    IF SalesCrMemoHeader."GST Customer Type" <> SalesCrMemoHeader."GST Customer Type"::Export THEN BEGIN
                        Gstin := ShipToAddr."GST Registration No.";
                        StateBuff.GET(SalesCrMemoHeader."GST Ship-to State Code");
                        //StateBuff.GET(ShipToAddr.State);
                        Stcd := StateBuff."State Code (GST Reg. No.)";
                        Pin := COPYSTR(SalesCrMemoHeader."Ship-to Post Code", 1, 6);
                    END ELSE BEGIN
                        Gstin := '';
                        Stcd := '97';//v1.03 //Other Territory
                        Pin := '999999';
                    END;
                    //v1.03 <<
                END ELSE BEGIN
                    LglNm := SalesCrMemoHeader."Bill-to Name";
                    TrdNm := SalesCrMemoHeader."Bill-to Name";
                    Addr1 := SalesCrMemoHeader."Bill-to Address";
                    Addr2 := SalesCrMemoHeader."Bill-to Address 2";
                    Loc := SalesCrMemoHeader."Bill-to City";

                    IF SalesCrMemoHeader."GST Customer Type" <> SalesCrMemoHeader."GST Customer Type"::Export THEN BEGIN
                        /*
                        Customer.GET("Bill-to Customer No.");
                        Gstin := Customer."GST Registration No.";
                        *///2019CU19
                        Gstin := SalesCrMemoHeader."Customer GST Reg. No.";
                        StateBuff.GET(SalesCrMemoHeader."GST Bill-to State Code");
                        //StateBuff.GET(Customer."State Code");
                        Stcd := StateBuff."State Code (GST Reg. No.)";
                        Pin := COPYSTR(SalesCrMemoHeader."Bill-to Post Code", 1, 6);
                    END ELSE BEGIN
                        Gstin := '';
                        Stcd := '97';//v1.03 //Other Territory
                        Pin := '999999';
                    END;
                END;
                WriteShipDtls(Gstin, LglNm, TrdNm, Addr1, Addr2, Loc, Pin, Stcd);
                //EInvTrans>>
            END ELSE
                IF TransferShipment THEN BEGIN

                    // JsonTextWriter.WritePropertyName('ShipDtls');
                    //JsonTextWriter.WriteValue(GlobalNULL);
                    WriteShipDtls(Gstin, LglNm, TrdNm, Addr1, Addr2, Loc, Pin, Stcd);
                END;
        //EInvTrans<<

    end;

    local procedure WriteShipDtls(Gstin: Text[15]; LglNm: Text[100]; TrdNm: Text[100]; Addr1: Text[100]; Addr2: Text[60]; Loc: Text[60]; Pin: Text[6]; Stcd: Text[2]);
    var
        PinInt: Integer;
    begin

        //B2BSaas>>
        Evaluate(PinInt, Pin);
        IF Gstin <> '' then
            JObjShipDtlsG.Add('Gstin', Gstin)
        else
            JObjShipDtlsG.Add('Gstin', JVOBJG.AsToken());
        IF LglNm <> '' then
            JObjShipDtlsG.Add('LglNm', LglNm)
        else
            JObjShipDtlsG.Add('Lglm', JVOBJG.AsToken());
        IF TrdNm <> '' then
            JObjShipDtlsG.Add('TrdNm', TrdNm)
        else
            JObjShipDtlsG.Add('TrdNm', JVOBJG.AsToken());
        IF Addr1 <> '' then
            JObjShipDtlsG.Add('Addr1', Addr1)
        else
            JObjShipDtlsG.Add('Addr1', JVOBJG.AsToken());
        IF Addr2 <> '' then
            JObjShipDtlsG.Add('Addr2', Addr2)
        else
            JObjShipDtlsG.Add('Addr2', JVOBJG.AsToken());
        if Loc <> '' then
            JObjShipDtlsG.Add('Loc', Loc)
        else
            JObjShipDtlsG.Add('Loc', JVOBJG.AsToken());
        if Pin <> '' then
            JObjShipDtlsG.Add('Pin', PinInt)
        else
            JObjShipDtlsG.Add('Pin', JVOBJG.AsToken());
        If Stcd <> '' then
            JObjShipDtlsG.Add('Stcd', Stcd)
        else
            JObjShipDtlsG.Add('Stcd', JVOBJG.AsToken());
        JObjVerG.Add('ShipDtls', JObjShipDtlsG);
        //B2BSaas<<
    end;

    local procedure ReadItemList();
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SlNo: Integer;
        TransferShipmentLine: Record "Transfer Shipment Line";
    begin
        IF IsInvoice THEN BEGIN
            SalesInvoiceLine.SETRANGE("Document No.", DocumentNo);
            //B2BUPG1.0>>
            //SalesInvoiceLine.SETFILTER("No.", '<>%1&<>%2&<>%3', '', GetInvRoundingAcc, GetGSTRoundingAcc);
            SalesInvoiceLine.SETFILTER("No.", '<>%1&<>%2', '', GetInvRoundingAcc);
            //B2BUPG1.0<<
            SalesInvoiceLine.SETFILTER(Quantity, '<>%1', 0);
            IF SalesInvoiceLine.FINDSET THEN BEGIN
                IF SalesInvoiceLine.COUNT > 1000 THEN
                    ERROR(SalesLinesErr, SalesInvoiceLine.COUNT);

                repeat
                    SlNo += 1;
                    //B2BSaas>>
                    WriteItem(SalesInvoiceLine, SlNo);
                until SalesInvoiceLine.Next() = 0;
                JObjVerG.Add('ItemList', JObjItemArrayG);
                //B2BSaas<<
            end;
        END ELSE
            IF CreditMemo THEN BEGIN
                SalesCrMemoLine.SETRANGE("Document No.", DocumentNo);
                //B2BUPG1.0>>
                //SalesCrMemoLine.SETFILTER("No.", '<>%1&<>%2&<>%3', '', GetInvRoundingAcc, GetGSTRoundingAcc);
                SalesCrMemoLine.SETFILTER("No.", '<>%1&<>%2', '', GetInvRoundingAcc);
                //B2BUPG1.0<<
                SalesCrMemoLine.SETFILTER(Quantity, '<>%1', 0);
                IF SalesCrMemoLine.FINDSET THEN BEGIN
                    IF SalesCrMemoLine.COUNT > 1000 THEN
                        ERROR(SalesLinesErr, SalesCrMemoLine.COUNT);
                    repeat
                        SlNo += 1;
                        //B2B>>
                        WriteItem(SalesCrMemoLine, SlNo);
                    until SalesCrMemoLine.Next() = 0;
                    JObjVerG.Add('ItemList', JObjItemArrayG);
                    //B2B<<
                END;
                //EInvTrans>>
            END ELSE
                IF TransferShipment THEN BEGIN
                    TransferShipmentLine.SETRANGE("Document No.", DocumentNo);
                    TransferShipmentLine.SETFILTER("Item No.", '<>%1', '');
                    TransferShipmentLine.SETFILTER(Quantity, '<>%1', 0);
                    IF TransferShipmentLine.FINDSET THEN BEGIN
                        IF TransferShipmentLine.COUNT > 1000 THEN
                            ERROR(SalesLinesErr, TransferShipmentLine.COUNT);
                        repeat
                            SlNo += 1;
                            //B2BSaas>>
                            WriteItem(TransferShipmentLine, SlNo);
                        until TransferShipmentLine.Next() = 0;
                        JObjVerG.Add('ItemList', JObjItemArrayG);
                        //B2BSaas<<
                    END;
                END;
        //EInvTrans>>
    end;

    local procedure WriteItem(Variant: Variant; SlNo: Integer);
    var
        RecRef: RecordRef;
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        ValueEntry: Record 5802;
        ItemLedgerEntry: Record 32;
        ValueEntryRelation: Record 6508;
        ItemTrackingManagement: Codeunit 6500;
        InvoiceRowID: Text[250];
        IsServc: Text[1];
        PrdDesc: Text[100];
        HsnCd: Text[8];
        Qty: Decimal;
        Unit: Text[3];
        UnitPrice: Decimal;
        TotAmt: Decimal;
        Discount: Decimal;
        AssAmt: Decimal;
        GstRt: Decimal;
        CgstAmt: Decimal;
        SgstAmt: Decimal;
        IgstAmt: Decimal;
        CesRt: Decimal;
        CesAmt: Decimal;
        CesNonAdvlAmt: Decimal;
        StateCesRt: Decimal;
        StateCesAmt: Decimal;
        StateCesNonAdvlAmt: Decimal;
        OthChrg: Decimal;
        TotItemVal: Decimal;
        Item: Record 27;
        LotExist: Boolean;
        LineNo: Integer;
        Barcde: Text[30];
        FreeQty: Decimal;
        PreTaxVal: Decimal;
        OrdLineRef: Integer;
        OrgCntry: Code[2];
        PrdSlNo: Code[20];
        UOM: Record "Unit of Measure";
        CurrExchRate: Record 330;
        TotGSTAmt: Decimal;
        TransferShipmentLine: Record "Transfer Shipment Line";
        JObjectItems: JsonObject;
        SlNoL: Text;
        OrderLineNolT: Text;
        Jvalue: JsonValue;
    begin
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            113:
                SalesInvoiceLine := Variant;
            115:
                SalesCrMemoLine := Variant;
            5745:
                TransferShipmentLine := Variant;//EInvTrans
        END;

        IF IsInvoice THEN BEGIN
            IF SalesInvoiceLine."GST Group Type" = SalesInvoiceLine."GST Group Type"::Service THEN
                IsServc := 'Y'
            ELSE
                IsServc := 'N';
            PrdDesc := SalesInvoiceLine.Description + SalesInvoiceLine."Description 2";
            HsnCd := SalesInvoiceLine."HSN/SAC Code";
            //>>v1.03
            Barcde := '';
            PreTaxVal := ROUND(SalesInvoiceLine.Quantity * SalesInvoiceLine."Unit Price", 0.01, '=');//5002Fix
            OrdLineRef := SalesInvoiceLine."Line No.";
            OrgCntry := 'IN';
            PrdSlNo := '';
            //<<v1.03
            //>>FreeSupplyFix
            //B2BUPG1.0>> - commented due to missing of fields.
            /*IF SalesInvoiceLine."Free Supply" THEN BEGIN
                Qty := 0;
                FreeQty := SalesInvoiceLine.Quantity;
                AssAmt := 0;
            END ELSE BEGIN*/
            //B2BUPG1.0<<
            Qty := ROUND(SalesInvoiceLine.Quantity, 0.001, '='); //BugFixUnitPrc
            FreeQty := 0;
            IF SalesInvoiceLine."GST Assessable Value (LCY)" <> 0 THEN
                AssAmt := SalesInvoiceLine."GST Assessable Value (LCY)"
            //NonGst >>
            ELSE
                //B2BUPG1.0>>
                /*IF SalesInvoiceLine."GST Base Amount" <> 0 THEN
                    AssAmt := SalesInvoiceLine."GST Base Amount"
                ELSE
                    AssAmt := SalesInvoiceLine."Line Amount" + SalesInvoiceLine."Inv. Discount Amount";*/
                    AssAmt := SalesInvoiceLine.Amount;
            //B2BUPG1.0<<
            //NonGst <<
            //END; //B2BUPG1.0
            //<<FreeSupplyFix
            IF UOM.GET(SalesInvoiceLine."Unit of Measure Code") THEN
                //Unit := COPYSTR(UOM.Code, 1, 3);
                Unit := COPYSTR(UOM."GST UQC Code B2B", 1, 3);
            UnitPrice := ROUND(SalesInvoiceLine."Unit Price", 0.01, '=');//5002Fix
            TotAmt := SalesInvoiceLine."Line Amount" + SalesInvoiceLine."Line Discount Amount";
            Discount := SalesInvoiceLine."Line Discount Amount" + SalesInvoiceLine."Inv. Discount Amount";//v1.03

            GetGSTCompRate(SalesInvoiceLine."Document No.", SalesInvoiceLine."Line No.",
              GstRt, CgstAmt, SgstAmt, IgstAmt, CesRt, CesAmt, CesNonAdvlAmt, StateCesRt, StateCesAmt, StateCesNonAdvlAmt, TotGSTAmt);
            OthChrg := 0;
            //B2BUPG1.0>>
            //TotItemVal := SalesInvoiceLine."Amount Including Tax" + SalesInvoiceLine."Total GST Amount";
            //NB>>
            //  TotItemVal := SalesInvoiceLine."Line Amount" + TotGSTAmt - Discount;
            //NB<<
            //B2BUPG1.0

            IF SalesInvoiceLine.Type = SalesInvoiceLine.Type::Item THEN BEGIN
                Item.GET(SalesInvoiceLine."No.");
                LotExist := Item."Item Tracking Code" <> '';
                //>>v1.03
                OrgCntry := 'IN';
                IF Item."Country/Region of Origin Code" <> '' THEN
                    OrgCntry := COPYSTR(Item."Country/Region of Origin Code", 1, 2);
                //<<v1.03
            END;
            LineNo := SalesInvoiceLine."Line No.";
        END ELSE
            IF CreditMemo THEN BEGIN
                IF SalesCrMemoLine."GST Group Type" = SalesCrMemoLine."GST Group Type"::Service THEN
                    IsServc := 'Y'
                ELSE
                    IsServc := 'N';
                PrdDesc := SalesCrMemoLine.Description + SalesCrMemoLine."Description 2";
                HsnCd := SalesCrMemoLine."HSN/SAC Code";
                //>>v1.03
                Barcde := '';
                PreTaxVal := ROUND(SalesCrMemoLine.Quantity * SalesCrMemoLine."Unit Price", 0.01, '=');//5002Fix
                OrdLineRef := SalesCrMemoLine."Line No.";
                OrgCntry := 'IN';
                PrdSlNo := '';
                //<<v1.03
                //>>FreeSupplyFix
                //B2BUPG1.0>> - Comented due to free supply has no solution.
                /*IF SalesCrMemoLine."Free Supply" THEN BEGIN
                    Qty := 0;
                    FreeQty := SalesCrMemoLine.Quantity;
                    AssAmt := 0;
                END ELSE BEGIN*/
                //B2BUPG1.0<<
                Qty := ROUND(SalesCrMemoLine.Quantity, 0.001, '='); //BugFixUnitPrc
                FreeQty := 0;
                IF SalesCrMemoLine."GST Assessable Value (LCY)" <> 0 THEN
                    AssAmt := SalesCrMemoLine."GST Assessable Value (LCY)"
                //NonGst >>
                ELSE
                    //B2BUPG1.0>>
                    /*IF SalesCrMemoLine."GST Base Amount" <> 0 THEN
                        AssAmt := SalesCrMemoLine."GST Base Amount"
                    ELSE
                        AssAmt := SalesCrMemoLine."Line Amount" + SalesCrMemoLine."Line Discount Amount";*/
                    AssAmt := SalesCrMemoLine.Amount;
                //B2BUPG1.0<<
                //NonGst <<
                //END; //B2BUPG1.0
                //<<FreeSupplyFix
                IF UOM.GET(SalesCrMemoLine."Unit of Measure Code") THEN
                    //Unit := COPYSTR(UOM.Code, 1, 3);
                    Unit := COPYSTR(UOM."GST UQC Code B2B", 1, 3);
                UnitPrice := SalesCrMemoLine."Unit Price";
                TotAmt := SalesCrMemoLine."Line Amount" + SalesCrMemoLine."Line Discount Amount";
                Discount := SalesCrMemoLine."Line Discount Amount" + SalesCrMemoLine."Inv. Discount Amount";//v1.03

                GetGSTCompRate(SalesCrMemoLine."Document No.", SalesCrMemoLine."Line No.",
                  GstRt, CgstAmt, SgstAmt, IgstAmt, CesRt, CesAmt, CesNonAdvlAmt, StateCesRt, StateCesAmt, StateCesNonAdvlAmt, TotGSTAmt);
                OthChrg := 0;
                //B2BUPG1.0>>
                //TotItemVal := SalesCrMemoLine."Amount Including Tax" + SalesCrMemoLine."Total GST Amount";
                TotItemVal := SalesCrMemoLine."Line Amount" + TotGSTAmt;
                //B2BUPG1.0<<

                IF SalesCrMemoLine.Type = SalesCrMemoLine.Type::Item THEN BEGIN
                    Item.GET(SalesCrMemoLine."No.");
                    LotExist := Item."Item Tracking Code" <> '';
                    //>>v1.03
                    IF Item."Country/Region of Origin Code" <> '' THEN
                        OrgCntry := COPYSTR(Item."Country/Region of Origin Code", 1, 2);
                    //<<v1.03
                END;
                LineNo := SalesCrMemoLine."Line No.";
                //EInvTrans>>
            END ELSE
                IF TransferShipment THEN BEGIN
                    IsServc := 'N';
                    PrdDesc := TransferShipmentLine.Description + TransferShipmentLine."Description 2";
                    HsnCd := TransferShipmentLine."HSN/SAC Code";
                    //>>v1.03
                    Barcde := '';
                    PreTaxVal := ROUND(TransferShipmentLine.Quantity * TransferShipmentLine."Unit Price", 0.01, '=');//5002Fix
                    OrdLineRef := TransferShipmentLine."Line No.";
                    OrgCntry := 'IN';
                    PrdSlNo := '';
                    //<<v1.03
                    Qty := TransferShipmentLine.Quantity;
                    FreeQty := 0;
                    IF TransferShipmentLine."GST Assessable Value" <> 0 THEN
                        AssAmt := TransferShipmentLine."GST Assessable Value"
                    ELSE
                        AssAmt := TransferShipmentLine.Amount;
                    IF UOM.GET(TransferShipmentLine."Unit of Measure Code") THEN
                        //Unit := COPYSTR(UOM.Code, 1, 3);
                        Unit := COPYSTR(UOM."GST UQC Code B2B", 1, 3);
                    UnitPrice := TransferShipmentLine."Unit Price";
                    TotAmt := TransferShipmentLine.Amount;
                    Discount := 0;//v1.03

                    GetGSTCompRate(TransferShipmentLine."Document No.", TransferShipmentLine."Line No.",
                      GstRt, CgstAmt, SgstAmt, IgstAmt, CesRt, CesAmt, CesNonAdvlAmt, StateCesRt, StateCesAmt, StateCesNonAdvlAmt, TotGSTAmt);

                    OthChrg := 0;
                    TotItemVal := TransferShipmentLine.Amount + TotGSTAmt;  //Need to check

                    Item.GET(TransferShipmentLine."Item No.");
                    LotExist := Item."Item Tracking Code" <> '';
                    //>>v1.03
                    IF Item."Country/Region of Origin Code" <> '' THEN
                        OrgCntry := COPYSTR(Item."Country/Region of Origin Code", 1, 2);
                    //<<v1.03
                    LineNo := TransferShipmentLine."Line No.";
                END;
        //EInvTrans<<
        //EXPFIX >>

        IF PreTaxVal <> 0 THEN
            PreTaxVal := ROUND(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                        WORKDATE, CurrCode, PreTaxVal, CurrFactor), 0.01, '=');

        IF AssAmt <> 0 THEN
            AssAmt := ROUND(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                        WORKDATE, CurrCode, AssAmt, CurrFactor), 0.01, '=');

        IF UnitPrice <> 0 THEN
            UnitPrice := ROUND(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                        WORKDATE, CurrCode, UnitPrice, CurrFactor), 0.01, '=');

        IF TotAmt <> 0 THEN
            TotAmt := ROUND(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                        WORKDATE, CurrCode, TotAmt, CurrFactor), 0.01, '=');

        IF Discount <> 0 THEN
            Discount := ROUND(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                        WORKDATE, CurrCode, Discount, CurrFactor), 0.01, '=');

        IF OthChrg <> 0 THEN
            OthChrg := ROUND(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                        WORKDATE, CurrCode, OthChrg, CurrFactor), 0.01, '=');
        //NB>>
        // IF TotItemVal <> 0 THEN
        //     TotItemVal := ROUND(
        //                 CurrExchRate.ExchangeAmtFCYToLCY(
        //                 WORKDATE, CurrCode, TotItemVal, CurrFactor), 0.01, '=');
        //EXPFIX <<
        //B2B>>
        TotItemVal := AssAmt + TotGSTAmt - Discount;
        //NB<<

        IF SlNo <> 0 then begin
            SlNoL := FORMAT(Slno);
            JObjectItems.Add('SlNo', SlNoL)
        end else
            JObjectItems.Add('SlNo', JVOBJG.AsToken());
        if IsServc <> '' then
            JObjectItems.Add('IsServc', IsServc)
        else
            JObjectItems.Add('IsServc', JVOBJG.AsToken());
        if PrdDesc <> '' then
            JObjectItems.Add('PrdDesc', PrdDesc)
        else
            JObjectItems.Add('PrdDesc', JVOBJG.AsToken());
        if HsnCd <> '' then
            JObjectItems.Add('HsnCd', HsnCd)
        else
            JObjectItems.Add('HsnCd', JVOBJG.AsToken());
        if Barcde <> '' then
            JObjectItems.Add('Barcde', Barcde)
        else
            JObjectItems.Add('Barcde', JVOBJG.AsToken());

        JObjectItems.Add('Qty', Qty);
        JObjectItems.Add('FreeQty', FreeQty);
        if Unit <> '' then
            JObjectItems.Add('Unit', Unit)
        else
            JObjectItems.Add('Unit', JVOBJG.AsToken());
        JObjectItems.Add('UnitPrice', UnitPrice);
        JObjectItems.Add('TotAmt', TotAmt);
        JObjectItems.Add('Discount', Discount);
        JObjectItems.Add('PreTaxVal', PreTaxVal);
        JObjectItems.Add('AssAmt', AssAmt);
        JObjectItems.Add('GstRt', GstRt);
        JObjectItems.Add('SgstAmt', SgstAmt);
        JObjectItems.Add('IgstAmt', IgstAmt);
        JObjectItems.Add('CgstAmt', CgstAmt);
        JObjectItems.Add('CesRt', CesRt);
        JObjectItems.Add('CesAmt', CesAmt);
        JObjectItems.Add('CesNonAdvlAmt', CesNonAdvlAmt);
        JObjectItems.Add('StateCesRt', StateCesRt);
        JObjectItems.Add('StateCesAmt', StateCesAmt);
        JObjectItems.Add('StateCesNonAdvlAmt', StateCesNonAdvlAmt);
        JObjectItems.Add('OthChrg', OthChrg);
        JObjectItems.Add('TotItemVal', TotItemVal);
        OrderLineNolT := Format(OrdLineRef);
        JObjectItems.Add('OrdLineRef', OrderLineNolT);
        JObjectItems.Add('OrgCntry', OrgCntry);
        if PrdSlNo <> '' then
            JObjectItems.Add('PrdSlNo', PrdSlNo)
        else
            JObjectItems.Add('PrdSlNo', JVOBJG.AsToken());
        // if LotExist then
        //     ReadBchDtls(LineNo, JObjectItems)
        // else
        Jvalue.SetValueToNull();
        JObjectItems.Add('BchDtls', Jvalue.AsToken());
        JObjectItems.Add('AttribDtls', JVOBJG.AsToken());
        JObjItemArrayG.Add(JObjectItems);
        //B2B<<

    end;

    local procedure ReadBchDtls(LineNo: Integer; var JObjectItems: JsonObject);
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        ValueEntry: Record 5802;
        ItemLedgerEntry: Record 32;
        ValueEntryRelation: Record 6508;
        ItemTrackingManagement: Codeunit 6500;
        InvoiceRowID: Text[250];
    begin
        IF IsInvoice THEN
            InvoiceRowID := ItemTrackingManagement.ComposeRowID(DATABASE::"Sales Invoice Line", 0, DocumentNo, '', 0, LineNo)
        ELSE
            IF CreditMemo THEN
                InvoiceRowID := ItemTrackingManagement.ComposeRowID(DATABASE::"Sales Cr.Memo Line", 0, DocumentNo, '', 0, LineNo)
            //EInvTrans>>
            ELSE
                IF TransferShipment THEN
                    InvoiceRowID := ItemTrackingManagement.ComposeRowID(DATABASE::"Transfer Shipment Line", 0, DocumentNo, '', 0, LineNo);
        //EInvTrans<<
        Clear(JObjBactchLineG);
        ValueEntryRelation.SETCURRENTKEY("Source RowId");
        ValueEntryRelation.SETRANGE("Source RowId", InvoiceRowID);
        IF ValueEntryRelation.FINDSET THEN BEGIN
            REPEAT
                Clear(JObjBactchLineG);
                ValueEntry.GET(ValueEntryRelation."Value Entry No.");
                ItemLedgerEntry.GET(ValueEntry."Item Ledger Entry No.");
                IF ItemLedgerEntry."Invoiced Quantity" <> 0 THEN
                    WriteBchDtls(
                      COPYSTR(ItemLedgerEntry."Lot No." + ItemLedgerEntry."Serial No.", 1, 20),
                      FORMAT(ItemLedgerEntry."Expiration Date", 0, '<Year4>-<Month,2>-<Day,2>'),
                      FORMAT(ItemLedgerEntry."Warranty Date", 0, '<Year4>-<Month,2>-<Day,2>'), JObjBactchLineG);
            UNTIL ValueEntryRelation.NEXT = 0;
            JObjVerG.Add('BchDtls', JObjBactchLineG);
        END;
    end;

    local procedure WriteBchDtls(Nm: Text[20]; ExpDt: Text[10]; WrDt: Text[10]; var JObjBchDtlsL: JsonObject);
    begin
        //B2B>>
        if Nm <> '' then
            JObjBchDtlsL.Add('Nm', Nm)
        else
            JObjBchDtlsL.Add('Nm', JVOBJG.AsToken());
        if ExpDt <> '' then
            JObjBchDtlsL.Add('ExpDt', ExpDt)
        else
            JObjBchDtlsL.Add('ExpDt', JVOBJG.AsToken());
        if WrDt <> '' then
            JObjBchDtlsL.Add('WrDt', WrDt)
        else
            JObjBchDtlsL.Add('WrDt', JVOBJG.AsToken());
        //B2B<<
    end;

    local procedure ReadPayDtls();
    var
        Nm: Text[100];
        AccDet: Text[18];
        Mode: Text[18];
        FinInsBr: Text[11];
        PayTerm: Text[100];
        PayInstr: Text[100];
        CrTrn: Text[100];
        DirDr: Text[100];
        CrDay: Integer;
        PaidAmt: Decimal;
        PaymtDue: Decimal;
    begin
        IF IsInvoice THEN BEGIN
            Nm := '';//Payee Name
            AccDet := '';//Bank Account No.
            Mode := '';//Mode of Payment: Cash, Credit, Direct Transfer
            FinInsBr := '';//Branch or IFSC code
            PayTerm := '';//Term of Payment
            PayInstr := '';//Pay Instruction
            CrTrn := '';//Credit Transfer
            DirDr := '';//Direct Debit
            CrDay := 0;//Credit Days
            PaidAmt := 0;//The sum of amount paid in advance
            PaymtDue := 0;//Outstanding amount
        END ELSE
            IF CreditMemo THEN BEGIN
                Nm := '';//Payee Name
                AccDet := '';//Bank Account No.
                Mode := '';//Mode of Payment: Cash, Credit, Direct Transfer
                FinInsBr := '';//Branch or IFSC code
                PayTerm := '';//Term of Payment
                PayInstr := '';//Pay Instruction
                CrTrn := '';//Credit Transfer
                DirDr := '';//Direct Debit
                CrDay := 0;//Credit Days
                PaidAmt := 0;//The sum of amount paid in advance
                PaymtDue := 0;//Outstanding amount
                              //EInvTrans>>
            END ELSE
                IF TransferShipment THEN BEGIN
                    Nm := '';//Payee Name
                    AccDet := '';//Bank Account No.
                    Mode := '';//Mode of Payment: Cash, Credit, Direct Transfer
                    FinInsBr := '';//Branch or IFSC code
                    PayTerm := '';//Term of Payment
                    PayInstr := '';//Pay Instruction
                    CrTrn := '';//Credit Transfer
                    DirDr := '';//Direct Debit
                    CrDay := 0;//Credit Days
                    PaidAmt := 0;//The sum of amount paid in advance
                    PaymtDue := 0;//Outstanding amount
                END;
        //EInvTrans<<
        IF (Nm = '') AND (AccDet = '') AND (Mode = '') AND (FinInsBr = '') AND (PayTerm = '') AND (PayInstr = '') AND
          (CrTrn = '') AND (DirDr = '') AND (CrDay = 0) AND (PaidAmt = 0) AND (PaymtDue = 0)
        THEN BEGIN
            JObjVerG.Add('PayDtls', JVOBJG.AsToken());
        END ELSE
            WritePayDtls(Nm, AccDet, Mode, FinInsBr, PayTerm, PayInstr, CrTrn, DirDr, CrDay, PaidAmt, PaymtDue);
    end;

    local procedure WritePayDtls(Nm: Text[100]; AccDet: Text[18]; Mode: Text[18]; FinInsBr: Text[11]; PayTerm: Text[100]; PayInstr: Text[100]; CrTrn: Text[100]; DirDr: Text[100]; CrDay: Integer; PaidAmt: Decimal; PaymtDue: Decimal);
    begin
        //B2B>>
        if Nm <> '' then
            JObjPayDtlsG.Add('Nm', Nm)
        else
            JObjPayDtlsG.Add('Nm', JVOBJG.AsToken());
        if AccDet <> '' then
            JObjPayDtlsG.Add('AccDet', AccDet)
        else
            JObjPayDtlsG.Add('AccDet', JVOBJG.AsToken());
        if Mode <> '' then
            JObjPayDtlsG.Add('Mode', Mode)
        else
            JObjPayDtlsG.Add('Mode', JVOBJG.AsToken());

        if FinInsBr <> '' then
            JObjPayDtlsG.Add('FinInsBr', FinInsBr)
        else
            JObjPayDtlsG.Add('FinInsBr', JVOBJG.AsToken());
        if PayTerm <> '' then
            JObjPayDtlsG.Add('PayTerm', PayTerm)
        else
            JObjPayDtlsG.Add('PayTerm', JVOBJG.AsToken());
        if PayInstr <> '' then
            JObjPayDtlsG.Add('PayInstr', PayInstr)
        else
            JObjPayDtlsG.Add('PayInstr', JVOBJG.AsToken());
        if CrTrn <> '' then
            JObjPayDtlsG.Add('CrTrn', CrTrn)
        else
            JObjPayDtlsG.Add('CrTrn', JVOBJG.AsToken());
        if DirDr <> '' then
            JObjPayDtlsG.Add('DirDr', DirDr)
        else
            JObjPayDtlsG.Add('DirDr', JVOBJG.AsToken());
        if CrDay <> 0 then
            JObjPayDtlsG.Add('CrDay', CrDay)
        else
            JObjPayDtlsG.Add('CrDay', JVOBJG.AsToken());
        if PaidAmt <> 0 then
            JObjPayDtlsG.Add('PaidAmt', PaidAmt)
        else
            JObjPayDtlsG.Add('PaidAmt', JVOBJG.AsToken());
        if PaymtDue <> 0 then
            JObjPayDtlsG.Add('PaymtDue', PaymtDue)
        else
            JObjPayDtlsG.Add('PaymtDue', JVOBJG.AsToken());
        JObjVerG.Add('PayDtls', JObjPayDtlsG);
        //B2B<<
    end;

    local procedure ReadRefDtls();
    var
        InvRm: Text[100];
        InvStDt: Text[10];
        InvEndDt: Text[10];
        InvNo: Text[16];
        InvDt: Text[10];
        OthRefNo: Text[20];
        RecAdvRefr: Text[20];
        RecAdvDt: Text[10];
        TendRefr: Text[20];
        ContrRefr: Text[20];
        ExtRefr: Text[20];
        ProjRefr: Text[20];
        PORefr: Text[16];
        PORefDt: Text[10];
    begin
        IF IsInvoice THEN BEGIN
            InvRm := '';//Remarks/Note
            InvStDt := '';//Invoice Start Date
            InvEndDt := '';//Invoice End Date

            InvNo := '';//Reference of Original Invoice if any
            InvDt := '';//Date of preceding invoice
            OthRefNo := '';//Other Reference

            RecAdvRefr := '';//Receipt Advice No.
            RecAdvDt := '';//Date of Receipt Advice
            TendRefr := '';//Lot/Batch Reference No.
            ContrRefr := '';//Contract Reference No.
            ExtRefr := '';//Any other Reference
            ProjRefr := '';//Project Reference No.
            PORefr := '';//Vendor PO Reference No.
            PORefDt := '';//Vendor PO Reference Date
        END ELSE
            IF CreditMemo THEN BEGIN
                InvRm := '';//Remarks/Note
                InvStDt := '';//Invoice Start Date
                InvEndDt := '';//Invoice End Date

                InvNo := '';//Reference of Original Invoice if any
                InvDt := '';//Date of preceding invoice
                OthRefNo := '';//Other Reference

                RecAdvRefr := '';//Receipt Advice No.
                RecAdvDt := '';//Date of Receipt Advice
                TendRefr := '';//Lot/Batch Reference No.
                ContrRefr := '';//Contract Reference No.
                ExtRefr := '';//Any other Reference
                ProjRefr := '';//Project Reference No.
                PORefr := '';//Vendor PO Reference No.
                PORefDt := '';//Vendor PO Reference Date
                              //EInvTrans>>
            END ELSE
                IF TransferShipment THEN BEGIN
                    InvRm := '';//Remarks/Note
                    InvStDt := '';//Invoice Start Date
                    InvEndDt := '';//Invoice End Date

                    InvNo := '';//Reference of Original Invoice if any
                    InvDt := '';//Date of preceding invoice
                    OthRefNo := '';//Other Reference

                    RecAdvRefr := '';//Receipt Advice No.
                    RecAdvDt := '';//Date of Receipt Advice
                    TendRefr := '';//Lot/Batch Reference No.
                    ContrRefr := '';//Contract Reference No.
                    ExtRefr := '';//Any other Reference
                    ProjRefr := '';//Project Reference No.
                    PORefr := '';//Vendor PO Reference No.
                    PORefDt := '';//Vendor PO Reference Date
                END;
        //EInvTrans<<
        IF (InvRm = '') AND (InvStDt = '') AND (InvEndDt = '') AND
          (InvNo = '') AND (InvDt = '') AND (OthRefNo = '') AND
          (RecAdvRefr = '') AND (RecAdvDt = '') AND (TendRefr = '') AND (ContrRefr = '') AND
          (ExtRefr = '') AND (ProjRefr = '') AND (PORefr = '') AND (PORefDt = '')
        THEN BEGIN
            JObjVerG.Add('RefDtls', JVOBJG.AsToken());

        END ELSE
            WriteRefDtls(InvRm, InvStDt, InvEndDt, InvNo, InvDt, OthRefNo, RecAdvRefr, RecAdvDt, TendRefr, ContrRefr, ExtRefr, ProjRefr, PORefr, PORefDt);
    end;

    local procedure WriteRefDtls(InvRm: Text[100]; InvStDt: Text[10]; InvEndDt: Text[10]; InvNo: Text[16]; InvDt: Text[10]; OthRefNo: Text[20]; RecAdvRefr: Text[20]; RecAdvDt: Text[10]; TendRefr: Text[20]; ContrRefr: Text[20]; ExtRefr: Text[20]; ProjRefr: Text[20]; PORefr: Text[16]; PORefDt: Text[10]);
    begin

        //B2B>>
        if InvRm <> '' then
            JObjRefDtlsG.Add('InvRm', InvRm)
        else
            JObjRefDtlsG.Add('InvRm', JVOBJG.AsToken());
        if InvStDt <> '' then
            JObjRefDtlsG.Add('InvStDt', InvStDt)
        else
            JObjRefDtlsG.Add('InvStDt', JVOBJG.AsToken());
        if InvEndDt <> '' then
            JObjRefDtlsG.Add('InvEndDt', InvEndDt)
        else
            JObjRefDtlsG.Add('InvEndDt', JVOBJG.AsToken());
        JObjVerG.Add('RefDtls', JObjRefDtlsG);

        //B2B<<
        WritePrecDocDtls(InvNo, InvDt, OthRefNo);

        WriteContrDtls(RecAdvRefr, RecAdvDt, TendRefr, ContrRefr, ExtRefr, ProjRefr, PORefr, PORefDt);
    end;

    local procedure WritePrecDocDtls(InvNo: Text[16]; InvDt: Text[10]; OthRefNo: Text[20]);
    begin

        //B2B>>
        JObjVerG.Add('PrecDocDtls', '');
        JObjPreDtlsG.Add('InvNo', '');
        JObjPreDtlsG.Add('InvDt', '');
        JObjPreDtlsG.Add('OthRefNo', '');
        repeat
            if InvNo <> '' then
                JObjPreDtlsG.Add('InvNo', InvNo)
            else
                JObjPreDtlsG.Add('InvNo', JVOBJG.AsToken());
            if InvDt <> '' then
                JObjPreDtlsG.Add('InvDt', '')
            else
                JObjPreDtlsG.Add('InvDt', JVOBJG.AsToken());
            if OthRefNo <> '' then
                JObjPreDtlsG.Add('OthRefNo', '')
            else
                JObjPreDtlsG.Add('OthRefNo', JVOBJG.AsToken());
            JSArrayPreDtlsG.Add(JObjPreDtlsG);
        until true;
        JObjVerG.Add('PrecDocument', JSArrayPreDtlsG);
        //B2B<<
    end;

    local procedure WriteContrDtls(RecAdvRefr: Text[20]; RecAdvDt: Text[10]; TendRefr: Text[20]; ContrRefr: Text[20]; ExtRefr: Text[20]; ProjRefr: Text[20]; PORefr: Text[16]; PORefDt: Text[10]);
    begin

        //B2B>>
        JObjVerG.Add('ContrDtls', '');
        JObjContrlDtlsG.Add('RecAdvRefr', '');
        JObjContrlDtlsG.Add('RecAdvDt', '');
        JObjContrlDtlsG.Add('TendRefr', '');
        JObjContrlDtlsG.Add('ContrRefr', '');
        JObjContrlDtlsG.Add('ExtRefr', '');
        JObjContrlDtlsG.Add('ProjRefr', '');
        JObjContrlDtlsG.Add('PORefDt', '');
        repeat
            if RecAdvRefr <> '' then
                JObjContrlDtlsG.Add('RecAdvRefr', RecAdvRefr)
            else
                JObjContrlDtlsG.Add('RecAdvRefr', JVOBJG.AsToken());
            if RecAdvDt <> '' then
                JObjContrlDtlsG.Add('RecAdvDt', RecAdvDt)
            else
                JObjContrlDtlsG.Add('RecAdvDt', JVOBJG.AsToken());
            if TendRefr <> '' then
                JObjContrlDtlsG.Add('TendRefr', '')
            else
                JObjContrlDtlsG.Add('TendRefr', JVOBJG.AsToken());
            if ContrRefr <> '' then
                JObjContrlDtlsG.Add('ContrRefr', ContrRefr)
            else
                JObjContrlDtlsG.Add('ContrRefr', JVOBJG.AsToken());
            if ExtRefr <> '' then
                JObjContrlDtlsG.Add('ExtRefr', ExtRefr)
            else
                JObjContrlDtlsG.Add('ExtRefr', JVOBJG.AsToken());
            if ProjRefr <> '' then
                JObjContrlDtlsG.Add('ProjRefr', ProjRefr)
            else
                JObjContrlDtlsG.Add('ProjRefr', JVOBJG.AsToken());
            if PORefDt <> '' then
                JObjContrlDtlsG.Add('PORefDt', PORefDt)
            else
                JObjContrlDtlsG.Add('PORefDt', JVOBJG.AsToken());
            JArryContrlDtlsG.Add(JObjContrlDtlsG);
        until true;
        JObjVerG.Add('Contract', JArryContrlDtlsG);
        //B2B<<
    end;

    local procedure ReadAddlDocDtls();
    var
        Url: Text[100];
        Docs: Text;
        Info: Text;
    begin
        IF IsInvoice THEN BEGIN
            Url := '';//Supporting Document URL
            Docs := '';//Supporting document in Base64 Format
            Info := '';//Any additional info
        END ELSE
            IF CreditMemo THEN BEGIN
                Url := '';//Supporting Document URL
                Docs := '';//Supporting document in Base64 Format
                Info := '';//Any additional info
                           //EInvTrans>>
            END ELSE
                IF TransferShipment THEN BEGIN
                    Url := '';//Supporting Document URL
                    Docs := '';//Supporting document in Base64 Format
                    Info := '';//Any additional info
                END;
        //EInvTrans>>
        IF (Url = '') AND (Docs = '') AND (Info = '') THEN BEGIN
            JObjVerG.Add('AddlDocDtls', JVOBJG.AsToken());
        END ELSE BEGIN
            JObjVerG.Add('AddlDocDtls', '');
            REPEAT
                WriteAddlDocDtls(Url, Docs, Info, JSODcoDtlsG);
                JSArryDocDtlsG.Add(JSODcoDtlsG);
            UNTIL TRUE;
            JObjVerG.Add('AddlDocument', JSArryDocDtlsG);
        END;
    end;

    local procedure WriteAddlDocDtls(Url: Text[100]; Docs: Text; Info: Text; var JSODcoDtlsL: JsonObject);
    begin

        if Url <> '' then
            JSODcoDtlsL.Add('Url', Url)
        else
            JSODcoDtlsL.Add('Url', JVOBJG.AsToken());
        if Docs <> '' then
            JSODcoDtlsL.Add('Docs', Docs)
        else
            JSODcoDtlsL.Add('Docs', JVOBJG.AsToken());
        if Info <> '' then
            JSODcoDtlsL.Add('Info', Info)
        else
            JSODcoDtlsL.Add('Info', JVOBJG.AsToken());

    end;

    local procedure ReadValDtls();
    var
        AssVal: Decimal;
        CgstVal: Decimal;
        SgstVal: Decimal;
        IgstVal: Decimal;
        CesVal: Decimal;
        StCesVal: Decimal;
        CesNonAdval: Decimal;
        Disc: Decimal;
        OthChrg: Decimal;
        TotInvVal: Decimal;
        RndOffAmt: Decimal;
        TotInvValFc: Decimal;
    begin
        GetGSTVal(AssVal, CgstVal, SgstVal, IgstVal, CesVal, StCesVal, CesNonAdval, Disc, OthChrg, TotInvVal, TotInvValFc);
        RndOffAmt := GetRndOffAmt;
        WriteValDtls(AssVal, CgstVal, SgstVal, IgstVal, CesVal, StCesVal, Disc, OthChrg, RndOffAmt, TotInvVal, TotInvValFc);
    end;

    local procedure WriteValDtls(Assval: Decimal; CgstVal: Decimal; SgstVAl: Decimal; IgstVal: Decimal; CesVal: Decimal; StCesVal: Decimal; Disc: Decimal; OthChrg: Decimal; RndOffAmt: Decimal; TotInvVal: Decimal; TotInvValFc: Decimal);
    begin
        //v1.03 Disc, OthChrg and TotInvValFc parameters and related code added

        //B2BSaas>>
        JSOBJValG.Add('AssVal', Assval);
        JSOBJValG.Add('CgstVal', CgstVal);
        JSOBJValG.Add('SgstVal', SgstVAl);
        JSOBJValG.Add('IgstVal', IgstVal);
        JSOBJValG.Add('CesVal', CesVal);
        JSOBJValG.Add('StCesVal', StCesVal);
        JSOBJValG.Add('Disc', Disc);
        JSOBJValG.Add('OthChrg', OthChrg);
        JSOBJValG.Add('RndOffAmt', RndOffAmt);
        JSOBJValG.Add('TotInvVal', TotInvVal);
        JSOBJValG.Add('TotInvValFc', TotInvValFc);
        JObjVerG.Add('ValDtls', JSOBJValG);
        //B2BSaas<<
    end;

    procedure SetSalesInvHeader(SalesInvoiceHeaderBuff: Record "Sales Invoice Header");
    begin
        SalesInvoiceHeader := SalesInvoiceHeaderBuff;
        IsInvoice := TRUE;
    end;

    procedure SetCrMemoHeader(SalesCrMemoHeaderBuff: Record "Sales Cr.Memo Header");
    begin
        SalesCrMemoHeader := SalesCrMemoHeaderBuff;
        CreditMemo := TRUE;
    end;

    local procedure GetRefInvNo(DocNo: Code[20]) RefInvNo: Code[20];
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
    begin
        ReferenceInvoiceNo.SETRANGE("Document No.", DocNo);
        IF ReferenceInvoiceNo.FINDFIRST THEN
            RefInvNo := ReferenceInvoiceNo."Reference Invoice Nos."
        ELSE
            RefInvNo := '';
    end;

    local procedure GetGSTCompRate(DocNo: Code[20]; LineNo: Integer; var GstRt: Decimal; var CgstAmt: Decimal; var SgstAmt: Decimal; var IgstAmt: Decimal; var CesRt: Decimal; var CessAmt: Decimal; var CesNonAdvlAmt: Decimal; var StateCesRt: Decimal; var StateCesAmt: Decimal; var StateCesNonAdvlAmt: Decimal; var TotGSTAmt: Decimal);
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTComponent: Record "Tax Component";
        CurrExchRate: Record 330;
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        TotalGSTAmount: Decimal;
        CurrencyCode: code[10];
        CurrencyFactor: Decimal;
        TransferShipmentLine: Record "Transfer Shipment Line";
    begin
        DetailedGSTLedgerEntry.SETRANGE("Document No.", DocNo);
        DetailedGSTLedgerEntry.SETRANGE("Document Line No.", LineNo);

        CesRt := 0;
        CessAmt := 0;
        CesNonAdvlAmt := 0;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'CESS');
        IF DetailedGSTLedgerEntry.FINDFIRST THEN
            IF DetailedGSTLedgerEntry."GST %" > 0 THEN BEGIN
                CesRt := DetailedGSTLedgerEntry."GST %";
                CessAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            END ELSE
                CesNonAdvlAmt := ABS(DetailedGSTLedgerEntry."GST Amount");

        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'INTERCESS');
        IF DetailedGSTLedgerEntry.FINDFIRST THEN BEGIN
            CesRt += DetailedGSTLedgerEntry."GST %";
            CessAmt += ABS(DetailedGSTLedgerEntry."GST Amount");
        END;

        StateCesRt := 0;
        StateCesAmt := 0;
        StateCesNonAdvlAmt := 0;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code");
        IF DetailedGSTLedgerEntry.FINDSET THEN
            REPEAT
                IF NOT (DetailedGSTLedgerEntry."GST Component Code" IN ['CGST', 'SGST', 'IGST', 'CESS', 'INTERCESS']) THEN
                    IF GSTComponent.GET(DetailedGSTLedgerEntry."GST Component Code") THEN
                        //IF GSTComponent."Exclude from Reports" THEN //B2BUPG1.0
                        IF GSTComponent."Visible On Interface" THEN
                            IF DetailedGSTLedgerEntry."GST %" > 0 THEN BEGIN
                                StateCesRt := DetailedGSTLedgerEntry."GST %";
                                StateCesAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
                            END ELSE
                                StateCesNonAdvlAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            UNTIL DetailedGSTLedgerEntry.NEXT = 0;


        //LCY to FCY conversion
        IF IsInvoice THEN BEGIN
            CurrencyCode := SalesInvoiceHeader."Currency Code";
            CurrencyFactor := SalesInvoiceHeader."Currency Factor";
        END ELSE BEGIN
            CurrencyCode := SalesCrMemoHeader."Currency Code";
            CurrencyFactor := SalesCrMemoHeader."Currency Factor";
        END;

        IF CessAmt <> 0 THEN
            CessAmt := ROUND(CurrExchRate.ExchangeAmtLCYToFCY(WORKDATE, CurrencyCode, CessAmt, CurrencyFactor), 1, '=');
        IF CesNonAdvlAmt <> 0 THEN
            CesNonAdvlAmt := ROUND(CurrExchRate.ExchangeAmtLCYToFCY(WORKDATE, CurrencyCode, CesNonAdvlAmt, CurrencyFactor), 1, '=');
        IF StateCesAmt <> 0 THEN
            StateCesAmt := ROUND(CurrExchRate.ExchangeAmtLCYToFCY(WORKDATE, CurrencyCode, StateCesAmt, CurrencyFactor), 1, '=');
        IF StateCesNonAdvlAmt <> 0 THEN
            StateCesNonAdvlAmt := ROUND(CurrExchRate.ExchangeAmtLCYToFCY(WORKDATE, CurrencyCode, StateCesNonAdvlAmt, CurrencyFactor), 1, '=');
        //EXPFIX

        /*GstRt := 0;
        CgstAmt := 0;
        SgstAmt := 0;
        IgstAmt := 0;*/


        IF IsInvoice THEN BEGIN
            SalesInvoiceLine.GET(DocNo, LineNo);
            //B2BUPG1.0>>
            //TotalGSTAmount := SalesInvoiceLine."Total GST Amount";
            TotalGSTAmount := TotGSTAmt;
            //B2BUPG1.0<<
        END ELSE
            IF CreditMemo THEN BEGIN
                SalesCrMemoLine.GET(DocNo, LineNo);
                //B2BUPG1.0>>
                //TotalGSTAmount := SalesCrMemoLine."Total GST Amount";
                TotalGSTAmount := TotGSTAmt;
                //B2BUPG1.0<<
                //EInvTrans>>
            END ELSE
                IF TransferShipment THEN BEGIN
                    TransferShipmentLine.GET(DocNo, LineNo);
                    TotalGSTAmount := TotGSTAmt;
                END;
        //EInvTrans<<
        //EXPFIX >>
        IF TotalGSTAmount <> 0 THEN
            TotalGSTAmount := ROUND(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                        WORKDATE, CurrCode, TotalGSTAmount, CurrFactor), 0.01, '=');
        //EXPFIX <<
        TotalGSTAmount := TotalGSTAmount - (CessAmt + StateCesAmt + CesNonAdvlAmt + StateCesNonAdvlAmt);//v1.03
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code");
        IF DetailedGSTLedgerEntry.FINDFIRST THEN
            CASE DetailedGSTLedgerEntry."GST Component Code" OF
                'IGST':
                    BEGIN
                        GstRt := DetailedGSTLedgerEntry."GST %";
                        IgstAmt := Abs(DetailedGSTLedgerEntry."GST Amount");
                    END;
                'CGST', 'SGST':
                    BEGIN
                        GstRt := 2 * DetailedGSTLedgerEntry."GST %";
                        CgstAmt := Abs(DetailedGSTLedgerEntry."GST Amount");
                        SgstAmt := Abs(DetailedGSTLedgerEntry."GST Amount");
                    END;
            END;
        TotGSTAmt := CgstAmt + SgstAmt + IgstAmt + CessAmt + StateCesAmt + CesNonAdvlAmt + StateCesNonAdvlAmt;

    end;

    local procedure GetGSTVal(var AssVal: Decimal; var CgstVal: Decimal; var SgstVal: Decimal; var IgstVal: Decimal; var CesVal: Decimal; var StCesVal: Decimal; var CesNonAdval: Decimal; var Disc: Decimal; var OthChrg: Decimal; var TotInvVal: Decimal; var TotInvValFc: Decimal);
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        GSTLedgerEntry: Record "GST Ledger Entry";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        CurrExchRate: Record 330;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GSTComponent: Record "Tax Component";
        TotGSTAmt: Decimal;
        IsSEZorExported: Boolean;
        //B2BUPG1.0>> 
        CGSTValue: Decimal;
        SGSTValue: Decimal;
        IGSTValue: Decimal;
        CESSValue: Decimal;
        TCSEnrty: Record "TCS Entry";
        //B2BUPG1.0<<
        TransferShipmentLine: Record "Transfer Shipment Line";
    begin
        GSTLedgerEntry.SETRANGE("Entry Type", GSTLedgerEntry."Entry Type"::"Initial Entry");//BugFix
        GSTLedgerEntry.SETRANGE("Document No.", DocumentNo);

        IF IsInvoice THEN BEGIN
            SalesInvoiceLine.SETRANGE("Document No.", DocumentNo);
            SalesInvoiceLine.SETFILTER(Quantity, '<>%1', 0);//BugFix
            IF SalesInvoiceLine.FINDSET THEN
                REPEAT
                    AssVal += SalesInvoiceLine.Amount;
                    //B2BUPG1.0>> - Modified due to removing of fields
                    //TotGSTAmt += SalesInvoiceLine."Total GST Amount";
                    GetGSTValueForLine(SalesInvoiceLine."Line No.", CGSTValue, SGSTValue, IGSTValue, CESSValue);
                    TotGSTAmt += CGSTValue + SGSTValue + IGSTValue + CESSValue;
                    //B2BUPG1.0<<
                    Disc += SalesInvoiceLine."Inv. Discount Amount";
                //OthChrg += SalesInvoiceLine."Charges To Customer" + SalesInvoiceLine."TDS/TCS Amount";//v1.03
                //B2BUPG1.0>>
                //OthChrg += SalesInvoiceLine."Charges To Customer" + SalesInvoiceLine."Total TDS/TCS Incl. SHE CESS";//v1.03
                // OthChrg := 0;
                //B2BUPG1.0<<
                UNTIL SalesInvoiceLine.NEXT = 0;
            TCSEnrty.Reset();
            TCSEnrty.SetRange("Document No.", SalesInvoiceLine."Document No.");
            if TCSEnrty.FindSet() then begin
                TCSEnrty.CalcSums(TCSEnrty."TCS Amount");
                OthChrg := TCSEnrty."TCS Amount";
            end;
        END ELSE
            IF CreditMemo THEN BEGIN
                SalesCrMemoLine.SETRANGE("Document No.", DocumentNo);
                SalesCrMemoLine.SETFILTER(Quantity, '<>%1', 0);//BugFix
                IF SalesCrMemoLine.FINDSET THEN
                    REPEAT
                        AssVal += SalesCrMemoLine.Amount;
                        //B2BUPG1.0>> - Modified due to removing of fields
                        //TotGSTAmt += SalesCrMemoLine."Total GST Amount";
                        GetGSTValueForLine(SalesCrMemoLine."Line No.", CGSTValue, SGSTValue, IGSTValue, CESSValue);
                        TotGSTAmt += CGSTValue + SGSTValue + IGSTValue + CESSValue;
                        //B2BUPG1.0<<
                        Disc += SalesCrMemoLine."Inv. Discount Amount";
                        //OthChrg += SalesCrMemoLine."Charges To Customer" + SalesCrMemoLine."TDS/TCS Amount";//v1.03
                        //B2BUPG1.0>>
                        //OthChrg += SalesCrMemoLine."Charges To Customer" + SalesCrMemoLine."Total TDS/TCS Incl SHE CESS";//v1.03
                        OthChrg := 0;
                    //B2BUPG1.0<<
                    UNTIL SalesCrMemoLine.NEXT = 0;
                //EInvTrans>>
            END ELSE
                IF TransferShipment THEN BEGIN
                    TransferShipmentLine.SETRANGE("Document No.", DocumentNo);
                    TransferShipmentLine.SETFILTER(Quantity, '<>%1', 0);//BugFix
                    IF TransferShipmentLine.FINDSET THEN
                        REPEAT
                            AssVal += TransferShipmentLine.Amount;
                            GetGSTValueForLine(SalesCrMemoLine."Line No.", CGSTValue, SGSTValue, IGSTValue, CESSValue);
                            TotGSTAmt += CGSTValue + SGSTValue + IGSTValue + CESSValue;
                            Disc += 0;//TransferShipmentLine."Inv. Discount Amount";
                                      //OthChrg += SalesCrMemoLine."Charges To Customer" + SalesCrMemoLine."TDS/TCS Amount";//v1.03
                            OthChrg += TransferShipmentLine."Custom Duty Amount"; //+} TransferShipmentLine."Total TDS/TCS Incl SHE CESS";//v1.03
                        UNTIL TransferShipmentLine.NEXT = 0;
                END;
        //EInvTrans<<
        CesVal := 0;
        CesNonAdval := 0;
        GSTLedgerEntry.SETRANGE("GST Component Code", 'INTERCESS');
        IF GSTLedgerEntry.FINDSET THEN
            REPEAT
                CesVal += ABS(GSTLedgerEntry."GST Amount")
            UNTIL GSTLedgerEntry.NEXT = 0;

        DetailedGSTLedgerEntry.SETRANGE("Document No.", DocumentNo);
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'CESS');
        IF DetailedGSTLedgerEntry.FINDFIRST THEN
            REPEAT
                IF DetailedGSTLedgerEntry."GST %" > 0 THEN
                    CesVal += ABS(DetailedGSTLedgerEntry."GST Amount")
                ELSE
                    CesNonAdval += ABS(DetailedGSTLedgerEntry."GST Amount");
            UNTIL DetailedGSTLedgerEntry.NEXT = 0; //BugFixCess

        GSTLedgerEntry.SETFILTER("GST Component Code", '<>CGST&<>SGST&<>IGST&<>CESS&<>INTERCESS');//BugFix
        IF GSTLedgerEntry.FINDSET THEN BEGIN
            REPEAT
                IF GSTComponent.GET(GSTLedgerEntry."GST Component Code") THEN
                    //IF GSTComponent."Exclude from Reports" THEN //B2BUPG1.0
                        StCesVal += ABS(GSTLedgerEntry."GST Amount");
            UNTIL GSTLedgerEntry.NEXT = 0;
        END;

        IF IsInvoice THEN BEGIN
            //CurrencyCode := SalesInvoiceHeader."Currency Code";
            //CurrencyFactor := SalesInvoiceHeader."Currency Factor";
            IsSEZorExported := SalesInvoiceHeader."GST Customer Type" IN [SalesInvoiceHeader."GST Customer Type"::"SEZ Development",
                                                                          SalesInvoiceHeader."GST Customer Type"::"SEZ Unit",
                                                                          SalesInvoiceHeader."GST Customer Type"::Export];//v1.03
        END ELSE
            IF CreditMemo THEN BEGIN
                //CurrencyCode := SalesCrMemoHeader."Currency Code";
                //CurrencyFactor := SalesCrMemoHeader."Currency Factor";
                IsSEZorExported := SalesCrMemoHeader."GST Customer Type" IN [SalesCrMemoHeader."GST Customer Type"::"SEZ Development",
                                                                              SalesCrMemoHeader."GST Customer Type"::"SEZ Unit",
                                                                              SalesCrMemoHeader."GST Customer Type"::Export];//v1.03
                                                                                                                             //EInvTrans>>
            END ELSE
                IF TransferShipment THEN BEGIN
                    //CurrencyCode := SalesCrMemoHeader."Currency Code";
                    //CurrencyFactor := SalesCrMemoHeader."Currency Factor";
                    IsSEZorExported := FALSE;/*SalesCrMemoHeader."GST Customer Type" IN [SalesCrMemoHeader."GST Customer Type"::"SEZ Development",  //Need to check
                                                                        SalesCrMemoHeader."GST Customer Type"::"SEZ Unit",
                                                                        SalesCrMemoHeader."GST Customer Type"::Export];//v1.03*/
                END;
        //EInvTrans<<

        /*
        IF CesVal <> 0 THEN
          CesVal := ROUND(CurrExchRate.ExchangeAmtLCYToFCY(WORKDATE,CurrencyCode,CesVal,CurrencyFactor),1,'=');
        IF StCesVal <> 0 THEN
          StCesVal := ROUND(CurrExchRate.ExchangeAmtLCYToFCY(WORKDATE,CurrencyCode,StCesVal,CurrencyFactor),1,'=');
        IF CesNonAdval <> 0 THEN
          CesNonAdval := ROUND(CurrExchRate.ExchangeAmtLCYToFCY(WORKDATE,CurrencyCode,CesNonAdval,CurrencyFactor),1,'=');
        *///EXPFIX

        IgstVal := 0;
        CgstVal := 0;
        SgstVal := 0;
        //NB>>
        // //EXPFIX >>
        // IF TotGSTAmt <> 0 THEN
        //     TotGSTAmt := ROUND(
        //               CurrExchRate.ExchangeAmtFCYToLCY(
        //               WORKDATE, CurrCode, TotGSTAmt, CurrFactor), 0.01, '=');
        // //EXPFIX <<
        //NB<<
        TotGSTAmt := TotGSTAmt - (CesVal + StCesVal + CesNonAdval);//v1.03

        GSTLedgerEntry.SETRANGE("GST Component Code");
        IF GSTLedgerEntry.FINDSET THEN
            CASE GSTLedgerEntry."GST Component Code" OF
                'IGST':
                    IgstVal := TotGSTAmt;
                'CGST', 'SGST':
                    BEGIN
                        CgstVal := TotGSTAmt / 2;
                        SgstVal := TotGSTAmt / 2;
                    END;
            END;

        CustLedgerEntry.SETCURRENTKEY("Document No.");
        CustLedgerEntry.SETRANGE("Document No.", DocumentNo);
        IF IsInvoice THEN BEGIN
            CustLedgerEntry.SETRANGE("Document Type", CustLedgerEntry."Document Type"::Invoice);
            CustLedgerEntry.SETRANGE("Customer No.", SalesInvoiceHeader."Bill-to Customer No.");
        END ELSE
            IF CreditMemo THEN BEGIN
                CustLedgerEntry.SETRANGE("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
                CustLedgerEntry.SETRANGE("Customer No.", SalesCrMemoHeader."Bill-to Customer No.");
            END;
        IF CustLedgerEntry.FINDFIRST THEN BEGIN
            CustLedgerEntry.CALCFIELDS(Amount);
            //>>v1.03
            TotInvVal := ABS(CustLedgerEntry.Amount);
            //EXPFIX >>
            IF TotInvVal <> 0 THEN
                TotInvVal := ROUND(
                           CurrExchRate.ExchangeAmtFCYToLCY(
                           WORKDATE, CurrCode, TotInvVal, CurrFactor), 0.01, '=');

            TotInvValFc := ABS(CustLedgerEntry.Amount);


            IF IsSEZorExported THEN BEGIN
                TotInvVal += TotGSTAmt + (CesVal + StCesVal + CesNonAdval);//v1.03
                TotInvValFc := ABS(CustLedgerEntry.Amount) + ROUND(CurrExchRate.ExchangeAmtLCYToFCY(WORKDATE,
                                                                  CurrCode, TotGSTAmt, CurrFactor), 0.01, '=')
                               + ROUND(CurrExchRate.ExchangeAmtLCYToFCY(WORKDATE,
                                                                  CurrCode, CesVal, CurrFactor), 0.01, '=')
                               + ROUND(CurrExchRate.ExchangeAmtLCYToFCY(WORKDATE,
                                                                  CurrCode, StCesVal, CurrFactor), 0.01, '=')
                               + ROUND(CurrExchRate.ExchangeAmtLCYToFCY(WORKDATE,
                                                                  CurrCode, CesNonAdval, CurrFactor), 0.01, '=');


            END;
            //EXPFIX <<
            //<<v1.03
        END;
        IF TransferShipment THEN
            TotInvVal := IgstVal + CgstVal + SgstVal + AssVal + OthChrg - Disc;
        //EXPFIX >>
        IF AssVal <> 0 THEN
            AssVal := ROUND(
                      CurrExchRate.ExchangeAmtFCYToLCY(
                      WORKDATE, CurrCode, AssVal, CurrFactor), 0.01, '=');

        IF Disc <> 0 THEN
            Disc := ROUND(
                      CurrExchRate.ExchangeAmtFCYToLCY(
                      WORKDATE, CurrCode, Disc, CurrFactor), 0.01, '=');

        IF OthChrg <> 0 THEN
            OthChrg := ROUND(
                      CurrExchRate.ExchangeAmtFCYToLCY(
                      WORKDATE, CurrCode, OthChrg, CurrFactor), 0.01, '=');
        //EXPFIX <<

    end;

    local procedure GetInvRoundingAcc(): Code[20];
    var
        CustomerPostingGroup: Record "Customer Posting Group";
        CustPosGrpCode: Code[20];
    begin
        IF IsInvoice THEN
            CustPosGrpCode := SalesInvoiceHeader."Customer Posting Group"
        ELSE
            IF CreditMemo THEN
                CustPosGrpCode := SalesCrMemoHeader."Customer Posting Group"
            ELSE
                IF TransferShipment THEN
                    CustPosGrpCode := '';// TransferShipmentHeader.
        IF CustPosGrpCode = '' THEN
            EXIT('');
        CustomerPostingGroup.GET(CustPosGrpCode);
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

    local procedure GetRndOffAmt(): Decimal;
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        IF IsInvoice THEN BEGIN
            SalesInvoiceLine.SETRANGE("Document No.", SalesInvoiceHeader."No.");
            //B2BUPG1.0>>
            //SalesInvoiceLine.SETFILTER("No.", '%1|%2', GetInvRoundingAcc, GetGSTRoundingAcc);
            SalesInvoiceLine.SetFilter("No.", '%1', GetInvRoundingAcc);
            //B2BUPG1.0<<
            SalesInvoiceLine.CALCSUMS(Amount);
            EXIT(SalesInvoiceLine.Amount);
        END ELSE
            if CreditMemo then BEGIN
                SalesCrMemoLine.SETRANGE("Document No.", SalesCrMemoHeader."No.");
                //B2BUPG1.0>>
                //SalesCrMemoLine.SETFILTER("No.", '%1|%2', GetInvRoundingAcc, GetGSTRoundingAcc);
                SalesCrMemoLine.SetFilter("No.", '%1', GetInvRoundingAcc);
                //B2BUPG1.0<<
                SalesCrMemoLine.CALCSUMS(Amount);
                EXIT(SalesCrMemoLine.Amount);
                //EInvTrans>>
            END ELSE
                IF TransferShipment THEN BEGIN
                    //  TransferShipmentLine.SETRANGE("Document No.",TransferShipmentHeader."No.");
                    //  TransferShipmentLine.SETFILTER("Item No.",'%1|%2',GetInvRoundingAcc,GetGSTRoundingAcc);
                    //  TransferShipmentLine.CALCSUMS(Amount);  //Need to check
                    EXIT(0);
                END;
        //EInvTrans<<
    end;

    procedure CancelEInvoice(Variant: Variant): Boolean;
    var
        CancelSalesInvHdr: Record "Sales Invoice Header";
        CancelSalesCrMHdr: Record "Sales Cr.Memo Header";
        RecRef: RecordRef;
        // [RUNONCLIENT]
        //Windows: DotNet Interaction;
        CancelReason: Text;
        ReasonRemarks: Text;
        EInvoiceEntry: Record "E-Invoice Entry";
        CancelTransferShipHdr: Record "Transfer Shipment Header";
        EInvCancelUpdate: Page "E-Invoice Update Window";
    begin
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            112:
                CancelSalesInvHdr := Variant;
            114:
                CancelSalesCrMHdr := Variant;
            5744:
                CancelTransferShipHdr := Variant;//EInvTrans
        END;
        //CancelReason := Windows.InputBox('Cancellation Reason :','Reason','',10,10);//Test
        //B2BUPG1.0>>
        //IF NOT OpenWindow(CancelReason, ReasonRemarks) THEN
        //    EXIT(FALSE);
        Clear(EInvCancelUpdate);
        Commit();
        if EInvCancelUpdate.RunModal() = Action::Yes then
            EInvCancelUpdate.GetData(CancelReason, ReasonRemarks);
        //B2BUPG1.0<<

        IF CancelSalesInvHdr."No." <> '' THEN
            EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Invoice", CancelSalesInvHdr."No.")
        ELSE
            IF CancelSalesCrMHdr."No." <> '' THEN
                EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Cr. Memo", CancelSalesCrMHdr."No.")
            //EInvTrans>>
            ELSE
                IF CancelTransferShipHdr."No." <> '' THEN
                    EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Transfer Shipment", CancelTransferShipHdr."No.");
        //EInvTrans<<
        DocumentNo := EInvoiceEntry."Document No.";

        DocumentNo := EInvoiceEntry."Document No.";

        EInvoiceEntry."IRN Cancelled Reason" := CancelReason;
        EInvoiceEntry."IRN Cancelled Remarks" := ReasonRemarks;
        EInvoiceEntry."IRN Cancelled By" := USERID;
        EInvoiceEntry.MODIFY;

        if (CancelReason = '') or (ReasonRemarks = '') then
            exit(false);


        JObJCancelG.Add('Irn', EInvoiceEntry."IRN No.");
        JObJCancelG.Add('CnlRsn', CancelReason);
        JObJCancelG.Add('CnlRem', ReasonRemarks);
        // ExportAsJson('Cancel_' + DocumentNo, JsonRequestPath);

        EInvoiceLog.INIT;
        IF CancelSalesInvHdr."No." <> '' THEN
            EInvoiceLog."Document Type" := EInvoiceLog."Document Type"::Invoice
        ELSE
            IF CancelSalesCrMHdr."No." <> '' THEN
                EInvoiceLog."Document Type" := EInvoiceLog."Document Type"::"Credit Memo"
            //EInvTrans>>
            ELSE
                IF CancelTransferShipHdr."No." <> '' THEN
                    EInvoiceLog."Document Type" := EInvoiceLog."Document Type"::"Transfer Shipment";
        //EInvTrans<<
        EInvoiceLog."Document No." := DocumentNo;
        EInvoiceLog.Cancel := TRUE;
        EInvoiceLog.INSERT(true);
        EXIT(TRUE);
    end;



    local procedure GetMailId(EmailTxt: Text[80]) ReturnTxt: Text;
    begin
        //>>5002Fix 30Dec2020
        IF STRPOS(EmailTxt, ';') <> 0 THEN BEGIN
            ReturnTxt := CONVERTSTR(EmailTxt, ';', ',');
            ReturnTxt := SELECTSTR(1, ReturnTxt);
        END ELSE
            ReturnTxt := COPYSTR(EmailTxt, 1, 50);
        //<<5002Fix 30Dec2020
    end;

    local procedure "---E-INVB2C---"();
    begin
    end;

    procedure GenerateFormatForB2C(Variant: Variant);
    var
        SuppGSTIN: Code[15];
        SuppUPIID: Text;
        InvDate: Text[10];
        CompanyInfo: Record 79;
        PayeeBankAcc: Text[30];
        PayeeIFSCCode: Code[11];
        LocRec: Record Location;
        AssVal: Decimal;
        CgstVal: Decimal;
        SgstVal: Decimal;
        IgstVal: Decimal;
        CesVal: Decimal;
        StCesVal: Decimal;
        CesNonAdval: Decimal;
        Disc: Decimal;
        OthChrg: Decimal;
        TotInvVal: Decimal;
        RndOffAmt: Decimal;
        TotInvValFc: Decimal;
        PayeeBankACTxt: Label 'Payee''s Bank A/C';
        PayeeBankIFSCTxt: Label 'Payee''s Bank IFSC';
    begin
        //>>E-INVB2C >>
        // IF ISNULL(StringBuilder) THEN
        //   Initialize;

        CLEAR(CurrCode);
        CLEAR(CurrFactor);

        CompanyInfo.GET;
        PayeeBankAcc := CompanyInfo."Bank Account No.";
        PayeeIFSCCode := CompanyInfo."Payee Bank IFSC Code";

        IF IsInvoice THEN BEGIN
            DocumentNo := SalesInvoiceHeader."No.";
            CurrCode := SalesInvoiceHeader."Currency Code";
            CurrFactor := SalesInvoiceHeader."Currency Factor";
            SuppGSTIN := SalesInvoiceHeader."Location GST Reg. No.";
            InvDate := FORMAT(SalesInvoiceHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>');
            LocRec.GET(SalesInvoiceHeader."Location Code");
        END ELSE BEGIN
            DocumentNo := SalesCrMemoHeader."No.";
            CurrCode := SalesCrMemoHeader."Currency Code";
            CurrFactor := SalesCrMemoHeader."Currency Factor";
            SuppGSTIN := SalesCrMemoHeader."Location GST Reg. No.";
            InvDate := FORMAT(SalesCrMemoHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>');
            LocRec.GET(SalesCrMemoHeader."Location Code");
        END;
        SuppUPIID := LocRec."Supplier UPI ID";

        GetGSTVal(AssVal, CgstVal, SgstVal, IgstVal, CesVal, StCesVal, CesNonAdval, Disc, OthChrg, TotInvVal, TotInvValFc);

        //B2B>>
        JObjVerG.Add('Supplier GSTIN', SuppGSTIN);
        JObjVerG.Add('Supplier UPI ID', SuppUPIID);
        JObjVerG.Add('PayeeBankACTxt', PayeeBankIFSCTxt);
        JObjVerG.Add('PayeeBankIFSCTxt', PayeeBankIFSCTxt);
        JObjVerG.Add('Invoice number', DocumentNo);
        JObjVerG.Add('Invoice Date', InvDate);
        JObjVerG.Add('Total Invoice Value', TotInvVal);
        if CgstVal <> 0 then
            JObjVerG.Add('CgstVal', CgstVal)
        else
            JObjVerG.Add('CgstVal', JVOBJG.AsToken());
        if SgstVal <> 0 then
            JObjVerG.Add('SgstVal', SgstVal)
        else
            JObjVerG.Add('SgstVal', JVOBJG.AsToken());
        if IgstVal <> 0 then
            JObjVerG.Add('IgstVal', IgstVal)
        else
            JObjVerG.Add('IgstVal', JVOBJG.AsToken());
        if CesVal <> 0 then
            JObjVerG.Add('CesVal', CesVal)
        else
            JObjVerG.Add('CesVal', JVOBJG.AsToken());
        if StCesVal <> 0 then
            JObjVerG.Add('StCesVal', StCesVal)
        else
            JObjVerG.Add('StCesVal', StCesVal);
        if CesNonAdval <> 0 then
            JObjVerG.Add('CesNonAdval', CesNonAdval)
        else
            JObjVerG.Add('CesNonAdval', JVOBJG.AsToken());
        //B2B<<

    end;

    //B2BUPG1.0>> - Added due to missing of GST fields.
    local procedure GetGSTValueForLine(
        DocumentLineNo: Integer;
        var CGSTLineAmount: Decimal;
        var SGSTLineAmount: Decimal;
        var IGSTLineAmount: Decimal;
        var CESSLineAmount: Decimal)
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        CGSTLbl: Label 'CGST', Locked = true;
        SGSTLbl: label 'SGST', Locked = true;
        IGSTLbl: Label 'IGST', Locked = true;
        CESSLbl: Label 'CESS', Locked = true;
    begin
        CGSTLineAmount := 0;
        SGSTLineAmount := 0;
        IGSTLineAmount := 0;

        DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
        DetailedGSTLedgerEntry.SetRange("Document Line No.", DocumentLineNo);
        DetailedGSTLedgerEntry.SetRange("GST Component Code", CGSTLbl);
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                CGSTLineAmount += Abs(DetailedGSTLedgerEntry."GST Amount");
            until DetailedGSTLedgerEntry.Next() = 0;

        DetailedGSTLedgerEntry.SetRange("GST Component Code", SGSTLbl);
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                SGSTLineAmount += Abs(DetailedGSTLedgerEntry."GST Amount")
            until DetailedGSTLedgerEntry.Next() = 0;

        DetailedGSTLedgerEntry.SetRange("GST Component Code", IGSTLbl);
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                IGSTLineAmount += Abs(DetailedGSTLedgerEntry."GST Amount")
            until DetailedGSTLedgerEntry.Next() = 0;

        DetailedGSTLedgerEntry.SetRange("GST Component Code", CESSLbl);
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                CESSLineAmount += Abs(DetailedGSTLedgerEntry."GST Amount")
            until DetailedGSTLedgerEntry.Next() = 0;
    end;
    //B2BUPG1.0<<
    // procedure GetRequestPath(var RequestPathLvar: Text)
    // var
    //     myInt: Integer;
    // begin
    //     RequestPathLvar := JsonRequestPath;
    // end;

    procedure SetTransferShipmentHeader(TransferShipmentHeaderBuff: Record "Transfer Shipment Header");
    begin
        //EInvTrans>>
        TransferShipmentHeader := TransferShipmentHeaderBuff;
        TransferShipment := TRUE;
        //EInvTrans<<
    end;

    //B2BUPGSERVICE1.0>> Service Orders
    local procedure "------Service Order------"();
    begin
    end;

    procedure RunServiceDocument();
    begin

        //EXPFIX >>
        CLEAR(CurrCode);
        CLEAR(CurrFactor);
        //EXPFIX <<
        IF IsServiceInvoice THEN BEGIN
            IF ServiceInvoiceHeader."GST Customer Type" IN [ServiceInvoiceHeader."GST Customer Type"::Unregistered, ServiceInvoiceHeader."GST Customer Type"::" "]
            THEN
                ERROR(UnRegCusrErr);

            //EXPFIX >>
            CurrCode := ServiceInvoiceHeader."Currency Code";
            CurrFactor := ServiceInvoiceHeader."Currency Factor";
            //EXPFIX <<

            DocumentNo := ServiceInvoiceHeader."No.";
            WriteFileHeader;
            WriteTransDtlsService;
            ReadDocDtlsService;
            ReadSellerDtlsService;
            ReadBuyerDtlsService;
            ReadDispDtlsService;
            ReadShipDtlsService;
            ReadItemListService;
            ReadPayDtlsService;
            ReadRefDtlsService;
            ReadAddlDocDtlsService;
            ReadExpDtlsService;
            ReadEwbDtlsService;
            ReadValDtlsService;
        END
        ELSE BEGIN
            IF ServiceCrMemoHeader."GST Customer Type" IN [ServiceCrMemoHeader."GST Customer Type"::Unregistered, ServiceCrMemoHeader."GST Customer Type"::" "]
            THEN
                ERROR(UnRegCusrErr);

            //EXPFIX >>
            CurrCode := ServiceCrMemoHeader."Currency Code";
            CurrFactor := ServiceCrMemoHeader."Currency Factor";
            //EXPFIX <<

            DocumentNo := ServiceCrMemoHeader."No.";
            WriteFileHeader;
            WriteTransDtlsService;
            ReadDocDtlsService;
            ReadSellerDtlsService;
            ReadBuyerDtlsService;
            ReadDispDtlsService;
            ReadShipDtlsService;
            ReadItemListService;
            ReadPayDtlsService;
            ReadRefDtlsService;
            ReadAddlDocDtlsService;
            ReadExpDtlsService;
            ReadEwbDtlsService;
            ReadValDtlsService;
        END;

        // IF DocumentNo <> '' THEN
        //     ExportAsJson(DocumentNo, JsonRequestPath)
        // ELSE
        //     ERROR(RecIsEmptyErr);

        // GST Integration Log Start
        Clear(EInvoiceLog);
        EInvoiceLog.INIT;
        IF IsServiceInvoice THEN BEGIN
            EInvoiceLog."Document Type" := EInvoiceLog."Document Type"::Invoice;
            EInvoiceLog."Document No." := ServiceInvoiceHeader."No.";
        END ELSE BEGIN
            EInvoiceLog."Document Type" := EInvoiceLog."Document Type"::"Credit Memo";
            EInvoiceLog."Document No." := ServiceCrMemoHeader."No.";
        END;
        EInvoiceLog."Request Path" := JsonRequestPath;
        EInvoiceLog.INSERT(true);
        // GST Integration Log End
    end;

    local procedure WriteTransDtlsService();
    var
        SupTyp: Text[10];
        RegRev: Text[1];
        EcmGstin: Code[15];
    begin
        IF IsServiceInvoice THEN BEGIN
            CASE ServiceInvoiceHeader."GST Customer Type" OF
                ServiceInvoiceHeader."GST Customer Type"::Registered, ServiceInvoiceHeader."GST Customer Type"::Exempted:
                    SupTyp := 'B2B';
                ServiceInvoiceHeader."GST Customer Type"::Export:
                    BEGIN
                        IF ServiceInvoiceHeader."GST Without Payment of Duty" THEN
                            SupTyp := 'EXPWOP'
                        ELSE
                            SupTyp := 'EXPWP';
                    END;
                ServiceInvoiceHeader."GST Customer Type"::"Deemed Export":
                    SupTyp := 'DEXP';
                ServiceInvoiceHeader."GST Customer Type"::"SEZ Unit", ServiceInvoiceHeader."GST Customer Type"::"SEZ Development":
                    BEGIN
                        IF ServiceInvoiceHeader."GST Without Payment of Duty" THEN
                            SupTyp := 'SEZWOP'
                        ELSE
                            SupTyp := 'SEZWP';
                    END;
            END;
        END ELSE BEGIN
            CASE ServiceCrMemoHeader."GST Customer Type" OF
                ServiceCrMemoHeader."GST Customer Type"::Registered, ServiceCrMemoHeader."GST Customer Type"::Exempted:
                    SupTyp := 'B2B';
                ServiceCrMemoHeader."GST Customer Type"::Export:
                    BEGIN
                        IF ServiceCrMemoHeader."GST Without Payment of Duty" THEN
                            SupTyp := 'EXPWOP'
                        ELSE
                            SupTyp := 'EXPWP';
                    END;
                ServiceCrMemoHeader."GST Customer Type"::"Deemed Export":
                    SupTyp := 'DEXP';
                ServiceCrMemoHeader."GST Customer Type"::"SEZ Unit", ServiceCrMemoHeader."GST Customer Type"::"SEZ Development":
                    BEGIN
                        IF ServiceCrMemoHeader."GST Without Payment of Duty" THEN
                            SupTyp := 'SEZWOP'
                        ELSE
                            SupTyp := 'SEZWP';
                    END;
            END;
        END;
        //>>v1.03
        RegRev := 'N';
        EcmGstin := '';
        //<<v1.03

        //B2B>>
        JObjtrnsG.Add('TaxSch', 'GST');
        JObjtrnsG.Add('SupTyp', SupTyp);
        JObjtrnsG.Add('RegRev', RegRev);
        if EcmGstin <> '' then
            JObjtrnsG.Add('EcmGstin', EcmGstin)
        else
            JObjtrnsG.Add('EcmGstin', JObjVerG.AsToken());
        JObjtrnsG.Add('IgstOnIntra', 'N');
        //B2B<<

    end;

    local procedure ReadDocDtlsService();
    var
        Typ: Text[3];
        Dt: Text[10];
    begin
        IF IsServiceInvoice THEN BEGIN
            IF ServiceInvoiceHeader."Invoice Type" = ServiceInvoiceHeader."Invoice Type"::Taxable THEN
                Typ := 'INV'
            ELSE
                IF (ServiceInvoiceHeader."Invoice Type" = ServiceInvoiceHeader."Invoice Type"::"Debit Note") OR
                   (ServiceInvoiceHeader."Invoice Type" = ServiceInvoiceHeader."Invoice Type"::Supplementary)
                THEN
                    Typ := 'DBN'
                ELSE
                    Typ := 'INV';
            Dt := FORMAT(ServiceInvoiceHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>');
        END ELSE BEGIN
            Typ := 'CRN';
            Dt := FORMAT(ServiceCrMemoHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>');
        END;

        WriteDocDtlsService(Typ, COPYSTR(DocumentNo, 1, 16), Dt);
    end;

    local procedure WriteDocDtlsService(Typ: Text[3]; No: Text[16]; Dt: Text[10]);
    begin
        JObjDtlsG.Add('Typ', Typ);
        JObjDtlsG.Add('No', No);
        JObjDtlsG.Add('Dt', Dt);
        JObjVerG.Add('DocDtls', JObjDtlsG);
    end;

    local procedure ReadExpDtlsService();
    var
        SalesInvoiceLine: Record 113;
        SalesCrMemoLine: Record 115;
        //GSTManagement : Codeunit 16401;
        ExpCat: Text[3];
        WithPay: Text[1];
        ShipBNo: Text[16];
        ShipBDt: Text[10];
        Port: Text[10];
        RefClm: Text[1];
        InvForCur: Decimal;
        ForCur: Text[3];
        CntCode: Text[2];
    begin
        IF IsServiceInvoice THEN BEGIN
            IF ServiceInvoiceHeader."GST Customer Type" IN
               [ServiceInvoiceHeader."GST Customer Type"::Export,
                ServiceInvoiceHeader."GST Customer Type"::"Deemed Export",
                ServiceInvoiceHeader."GST Customer Type"::"SEZ Unit",
                ServiceInvoiceHeader."GST Customer Type"::"SEZ Development"]
            THEN BEGIN
                ShipBNo := COPYSTR(ServiceInvoiceHeader."Bill Of Export No.", 1, 16);
                ShipBDt := FORMAT(ServiceInvoiceHeader."Bill Of Export Date", 0, '<Day,2>/<Month,2>/<Year4>');
                Port := ServiceInvoiceHeader."Exit Point";
                RefClm := 'N';//
                ForCur := COPYSTR(ServiceInvoiceHeader."Currency Code", 1, 3);
                CntCode := COPYSTR(ServiceInvoiceHeader."Bill-to Country/Region Code", 1, 2);
            END;
        END
        ELSE BEGIN
            IF ServiceCrMemoHeader."GST Customer Type" IN
               [ServiceCrMemoHeader."GST Customer Type"::Export,
                ServiceCrMemoHeader."GST Customer Type"::"Deemed Export",
                ServiceCrMemoHeader."GST Customer Type"::"SEZ Unit",
                ServiceCrMemoHeader."GST Customer Type"::"SEZ Development"]
            THEN BEGIN
                ShipBNo := COPYSTR(ServiceCrMemoHeader."Bill Of Export No.", 1, 16);
                ShipBDt := FORMAT(ServiceCrMemoHeader."Bill Of Export Date", 0, '<Year4>-<Month,2>-<Day,2>');
                Port := ServiceCrMemoHeader."Exit Point";
                RefClm := 'N';//
                ForCur := COPYSTR(ServiceCrMemoHeader."Currency Code", 1, 3);
                CntCode := COPYSTR(ServiceCrMemoHeader."Bill-to Country/Region Code", 1, 2);
            END;
        END;

        IF (ShipBNo = '') AND (ShipBDt = '') AND (Port = '') AND (ForCur = '') AND (CntCode = '') THEN BEGIN
            JObjExpDtlsG.Add('ExpDtls', JVOBJG.AsToken());
        END ELSE
            WriteExpDtlsService(ShipBNo, ShipBDt, Port, RefClm, ForCur, CntCode);
    end;

    local procedure WriteExpDtlsService(ShipBNo: Text[16]; ShipBDt: Text[10]; Port: Text[10]; RefClm: Text[1]; ForCur: Text[3]; CntCode: Text[2]);
    begin
        if ShipBNo <> '' then
            JObjExpDtlsG.Add('ShipBNo', ShipBNo)
        else
            JObjExpDtlsG.Add('ShipBNo', JVOBJG.AsToken());
        if ShipBDt <> '' then
            JObjExpDtlsG.Add('ShipBDt', ShipBDt)
        else
            JObjExpDtlsG.Add('ShipBDt', JVOBJG.AsToken());
        if Port <> '' then
            JObjExpDtlsG.Add('Port', Port)
        else
            JObjExpDtlsG.Add('Port', JVOBJG.AsToken());
        if RefClm <> '' then
            JObjExpDtlsG.Add('RefClm', RefClm)
        else
            JObjExpDtlsG.Add('RefClm', JVOBJG.AsToken());
        if ForCur <> '' then
            JObjExpDtlsG.Add('ForCur', ForCur)
        else
            JObjExpDtlsG.Add('ForCur', JVOBJG.AsToken());
        if CntCode <> '' then
            JObjExpDtlsG.Add('CntCode', CntCode)
        else
            JObjExpDtlsG.Add('CntCode', JVOBJG.AsToken());
        JObjVerG.Add('ExpDtls', JObjExpDtlsG);
    end;

    local procedure ReadEwbDtlsService();
    var
        TransId: Text[15];
        TransName: Text[100];
        TransMode: Text[1];
        Distance: Integer;
        TransDocNo: Text[15];
        TransDocDt: Text[10];
        VehNo: Text[20];
        VehType: Text[1];
        TransportMethod: Record 259;
    begin
        IF IsServiceInvoice THEN BEGIN
            TransId := '';//Transit/GSTIN
            IF TransportMethod.GET(ServiceInvoiceHeader."Transport Method") THEN BEGIN
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
            //Distance := ROUND("Distance (Km)",1,'=');
            TransDocNo := '';//Trnasport Document No.
            TransDocDt := '';//Transport Doc Date
            VehNo := ServiceInvoiceHeader."Vehicle No.";
            /*CASE "Vehicle Type" OF
              "Vehicle Type"::" ": VehType := '';
              "Vehicle Type"::ODC: VehType := 'O';
              "Vehicle Type"::Regular: VehType := 'R';
            END;*/
        END
        ELSE BEGIN
            TransId := '';//Transit/GSTIN
            IF TransportMethod.GET(ServiceCrMemoHeader."Transport Method") THEN BEGIN
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
            //Distance := ROUND("Distance (Km)",1,'=');
            TransDocNo := '';//Trnasport Document No.
            TransDocDt := '';//Transport Doc Date
                             //VehNo := "Vehicle No.";
                             /*CASE "Vehicle Type" OF
                               "Vehicle Type"::" ": VehType := '';
                               "Vehicle Type"::ODC: VehType := 'O';
                               "Vehicle Type"::Regular: VehType := 'R';
                             END;*/
        END;

        IF (TransId = '') AND (TransName = '') AND (TransMode = '') AND (Distance = 0) AND (TransDocNo = '') AND (TransDocDt = '') AND
          (VehNo = '') AND (VehType = '')
        THEN BEGIN
            JObjVerG.Add('EwbDtls', JVOBJG.AsToken());
        END ELSE
            WriteEwbDtlsService(TransId, TransName, TransMode, Distance, TransDocNo, TransDocDt, VehNo, VehType);

    end;

    local procedure WriteEwbDtlsService(TransId: Text[15]; TransName: Text[100]; TransMode: Text[1]; Distance: Integer; TransDocNo: Text[15]; TransDocDt: Text[10]; VehNo: Text[20]; VehType: Text[1]);
    begin
        //B2BSaas>>
        if TransId <> '' then
            JObjEwbDtlsG.Add('TransId', TransId)
        else
            JObjEwbDtlsG.Add('TransId', JVOBJG.AsToken());
        if TransName <> '' then
            JObjEwbDtlsG.Add('TransName', TransName)
        else
            JObjEwbDtlsG.Add('TransName', JVOBJG.AsToken());
        if TransMode <> '' then
            JObjEwbDtlsG.Add('TransMode', TransMode)
        else
            JObjEwbDtlsG.Add('TransMode', JVOBJG.AsToken());
        JObjEwbDtlsG.Add('Distance', Distance);
        if TransDocNo <> '' then
            JObjEwbDtlsG.Add('TransDocNo', TransDocNo)
        else
            JObjEwbDtlsG.Add('TransDocNo', JVOBJG.AsToken());
        if TransDocDt <> '' then
            JObjEwbDtlsG.Add('TransDocDt', TransDocDt)
        else
            JObjEwbDtlsG.Add('TransDocDt', JVOBJG.AsToken());
        if VehNo <> '' then
            JObjEwbDtlsG.Add('VehNo', VehNo)
        else
            JObjEwbDtlsG.Add('VehNo', JVOBJG.AsToken());
        if VehType <> '' then
            JObjEwbDtlsG.Add('VehType', VehType)
        else
            JObjEwbDtlsG.Add('VehType', JVOBJG.AsToken());
        JObjVerG.Add('EwbDtls', JObjEwbDtlsG);
        //B2BSaas<<
    end;

    local procedure ReadSellerDtlsService();
    var
        CompanyInformationBuff: Record 79;
        LocationBuff: Record 14;
        StateBuff: Record State;
        Gstin: Text[15];
        LglNm: Text[100];
        TrdNm: Text[100];
        Add1: Text[100];
        Add2: Text[60];
        Loc: Text[60];
        Pin: Text[6];
        Stcd: Code[2];
        Ph: Text[10];
        Em: Text[50];
    begin
        IF IsServiceInvoice THEN BEGIN
            LocationBuff.GET(ServiceInvoiceHeader."Location Code");
            //Gstin := LocationBuff."GST Registration No.";//2016CU19
            Gstin := ServiceInvoiceHeader."Location GST Reg. No.";
            CompanyInformationBuff.GET;
            LglNm := CompanyInformationBuff.Name;
            TrdNm := CompanyInformationBuff.Name;
            Add1 := LocationBuff.Address;
            Add2 := LocationBuff."Address 2";
            Loc := LocationBuff.Name;
            Pin := COPYSTR(LocationBuff."Post Code", 1, 6);
            StateBuff.GET(LocationBuff."State Code");
            Stcd := StateBuff."State Code (GST Reg. No.)";//v1.03
                                                          //Ph := COPYSTR(LocationBuff."Phone No.",1,10);
            Ph := '';
            Em := GetMailId(LocationBuff."E-Mail");//5002Fix
        END
        ELSE BEGIN
            LocationBuff.GET(ServiceCrMemoHeader."Location Code");
            //Gstin := LocationBuff."GST Registration No.";//2016CU19
            Gstin := ServiceCrMemoHeader."Location GST Reg. No.";
            CompanyInformationBuff.GET;
            LglNm := CompanyInformationBuff.Name;
            TrdNm := CompanyInformationBuff.Name;
            Add1 := LocationBuff.Address;
            Add2 := LocationBuff."Address 2";
            Loc := LocationBuff.Name;
            Pin := COPYSTR(LocationBuff."Post Code", 1, 6);
            StateBuff.GET(LocationBuff."State Code");
            Stcd := StateBuff."State Code (GST Reg. No.)";//v1.03
                                                          //Ph := COPYSTR(LocationBuff."Phone No.",1,10);
            Ph := '';
            Em := GetMailId(LocationBuff."E-Mail");//5002Fix
        END;

        WriteSellerDtlsService(Gstin, LglNm, TrdNm, Add1, Add2, Loc, Pin, Stcd, Ph, Em);
    end;

    local procedure WriteSellerDtlsService(Gstin: Text[15]; LglNm: Text[100]; TrdNm: Text[100]; Add1: Text[100]; Add2: Text[60]; Loc: Text[60]; Pin: Text[6]; Stcd: Code[2]; Ph: Text[10]; Em: Text[50]);
    var
        PinInt: Integer;
    begin
        //v1.03 parameter change StateNm to Stcd and related code

        //B2B>>
        IF Gstin <> '' then
            JObjSellerDtlsG.Add('Gstin', Gstin)
        else
            JObjSellerDtlsG.Add('Gstin', JVOBJG.AsToken());
        IF LglNm <> '' then
            JObjSellerDtlsG.Add('LglNm', LglNm)
        else
            JObjSellerDtlsG.Add('Lglm', JVOBJG.AsToken());
        IF TrdNm <> '' then
            JObjSellerDtlsG.Add('TrdNm', TrdNm)
        else
            JObjSellerDtlsG.Add('TrdNm', JVOBJG.AsToken());
        IF Add1 <> '' then
            JObjSellerDtlsG.Add('Addr1', Add1)
        else
            JObjSellerDtlsG.Add('Addr1', JVOBJG.AsToken());
        IF Add2 <> '' then
            JObjSellerDtlsG.Add('Addr2', Add2)
        else
            JObjSellerDtlsG.Add('Addr2', JVOBJG.AsToken());
        if Loc <> '' then
            JObjSellerDtlsG.Add('Loc', Loc)
        else
            JObjSellerDtlsG.Add('Loc', Loc);
        If Stcd <> '' then
            JObjSellerDtlsG.Add('Stcd', Stcd)
        else
            JObjSellerDtlsG.Add('Stcd', Stcd);
        if Ph <> '' then
            JObjSellerDtlsG.Add('Ph', Ph)
        else
            JObjSellerDtlsG.Add('Ph', JVOBJG.AsToken());
        if Em <> '' then
            JObjSellerDtlsG.Add('Em', Em)
        else
            JObjSellerDtlsG.Add('Em', JVOBJG.AsToken());
        JObjVerG.Add('SellerDtls', JObjSellerDtlsG);
        //B2B<<
    end;

    local procedure ReadBuyerDtlsService();
    var
        Contact: Record 5050;
        ServiceInvoiceLine: Record 5993;
        ServiceCrMemoLine: Record 5995;
        ShipToAddr: Record 222;
        StateBuff: Record State;
        Gstin: Text[15];
        LglNm: Text[100];
        TrdNm: Text[100];
        Pos: Text[2];
        Addr1: Text[100];
        Addr2: Text[60];
        Loc: Text[60];
        Pin: Text[6];
        Stcd: Code[2];
        Ph: Text[10];
        Em: Text[50];
        Customer: Record 18;
    begin
        //>> POSShipToGSTINFix
        IF IsServiceInvoice THEN BEGIN
            IF ServiceInvoiceHeader."GST Customer Type" = ServiceInvoiceHeader."GST Customer Type"::Export THEN BEGIN
                Gstin := 'URP';
                Pin := '999999';
                Stcd := '96';//v1.03
                LglNm := ServiceInvoiceHeader."Bill-to Name";
                TrdNm := ServiceInvoiceHeader."Bill-to Name";
                Addr1 := ServiceInvoiceHeader."Bill-to Address";
                Addr2 := ServiceInvoiceHeader."Bill-to Address 2";
                Loc := ServiceInvoiceHeader."Bill-to City";
                Pos := '96';
                IF Contact.GET(ServiceInvoiceHeader."Bill-to Contact No.") THEN BEGIN
                    //Ph := COPYSTR(Contact."Phone No.",1,10);
                    Ph := '';
                    Em := GetMailId(Contact."E-Mail");//5002Fix
                END;
            END ELSE BEGIN
                ServiceInvoiceLine.SETRANGE("Document No.", ServiceInvoiceHeader."No.");
                ServiceInvoiceLine.SETFILTER("No.", '<>%1', '');//BugFix
                IF ServiceInvoiceLine.FINDFIRST THEN
                    IF (ServiceInvoiceLine."GST Place Of Supply" = ServiceInvoiceLine."GST Place Of Supply"::"Ship-to Address") AND
                       (ShipToAddr.GET(ServiceInvoiceHeader."Customer No.", ServiceInvoiceHeader."Ship-to Code"))
                    THEN BEGIN
                        Gstin := ShipToAddr."GST Registration No.";
                        LglNm := ServiceInvoiceHeader."Ship-to Name";
                        TrdNm := ServiceInvoiceHeader."Ship-to Name";
                        Addr1 := ServiceInvoiceHeader."Ship-to Address";
                        Addr2 := ServiceInvoiceHeader."Ship-to Address 2";
                        Loc := ServiceInvoiceHeader."Ship-to City";
                        StateBuff.GET(ServiceInvoiceHeader."GST Ship-to State Code");
                        Pos := StateBuff."State Code (GST Reg. No.)";
                        Stcd := StateBuff."State Code (GST Reg. No.)";
                        Pin := COPYSTR(ServiceInvoiceHeader."Ship-to Post Code", 1, 6);
                        //Ph := COPYSTR(ShipToAddr."Phone No.",1,10);
                        Ph := '';
                        Em := GetMailId(ShipToAddr."E-Mail");//5002Fix
                    END ELSE BEGIN
                        //Customer.GET("Bill-to Customer No.");
                        //Gstin := Customer."GST Registration No.";//2019CU19
                        Gstin := ServiceInvoiceHeader."Customer GST Reg. No.";
                        LglNm := ServiceInvoiceHeader."Bill-to Name";
                        TrdNm := ServiceInvoiceHeader."Bill-to Name";
                        Addr1 := ServiceInvoiceHeader."Bill-to Address";
                        Addr2 := ServiceInvoiceHeader."Bill-to Address 2";
                        Loc := ServiceInvoiceHeader."Bill-to City";
                        //StateBuff.GET(Customer."State Code");
                        StateBuff.GET(ServiceInvoiceHeader."GST Bill-to State Code");
                        Stcd := StateBuff."State Code (GST Reg. No.)";
                        Pos := StateBuff."State Code (GST Reg. No.)";
                        Pin := COPYSTR(ServiceInvoiceHeader."Bill-to Post Code", 1, 6);
                        IF Contact.GET(ServiceInvoiceHeader."Bill-to Contact No.") THEN BEGIN
                            //Ph := COPYSTR(Contact."Phone No.",1,10);
                            Ph := '';
                            Em := GetMailId(Contact."E-Mail");//5002Fix
                        END;
                    END;
            END;
        END
        ELSE BEGIN
            IF ServiceCrMemoHeader."GST Customer Type" = ServiceCrMemoHeader."GST Customer Type"::Export THEN BEGIN
                Gstin := 'URP';
                Pin := '999999';
                Stcd := '96';//v1.03
                LglNm := ServiceCrMemoHeader."Bill-to Name";
                TrdNm := ServiceCrMemoHeader."Bill-to Name";
                Addr1 := ServiceCrMemoHeader."Bill-to Address";
                Addr2 := ServiceCrMemoHeader."Bill-to Address 2";
                Loc := ServiceCrMemoHeader."Bill-to City";
                Pos := '96';
                IF Contact.GET(ServiceCrMemoHeader."Bill-to Contact No.") THEN BEGIN
                    //Ph := COPYSTR(Contact."Phone No.",1,10);
                    Ph := '';
                    Em := GetMailId(Contact."E-Mail");//5002Fix
                END;
            END ELSE BEGIN
                ServiceCrMemoLine.SETRANGE("Document No.", ServiceCrMemoHeader."No.");
                ServiceCrMemoLine.SETFILTER("No.", '<>%1', '');//BugFix
                IF ServiceCrMemoLine.FINDFIRST THEN
                    IF (ServiceCrMemoLine."GST Place Of Supply" = ServiceCrMemoLine."GST Place Of Supply"::"Ship-to Address") AND
                       (ShipToAddr.GET(ServiceCrMemoHeader."Customer No.", ServiceCrMemoHeader."Ship-to Code"))
                    THEN BEGIN
                        Gstin := ShipToAddr."GST Registration No.";
                        LglNm := ServiceCrMemoHeader."Ship-to Name";
                        TrdNm := ServiceCrMemoHeader."Ship-to Name";
                        Addr1 := ServiceCrMemoHeader."Ship-to Address";
                        Addr2 := ServiceCrMemoHeader."Ship-to Address 2";
                        Loc := ServiceCrMemoHeader."Ship-to City";
                        StateBuff.GET(ServiceCrMemoHeader."GST Ship-to State Code");
                        Pos := StateBuff."State Code (GST Reg. No.)";
                        Stcd := StateBuff."State Code (GST Reg. No.)";
                        Pin := COPYSTR(ServiceCrMemoHeader."Ship-to Post Code", 1, 6);
                        //Ph := COPYSTR(ShipToAddr."Phone No.",1,10);
                        Ph := '';
                        Em := GetMailId(ShipToAddr."E-Mail");//5002Fix
                    END ELSE BEGIN
                        //Customer.GET("Bill-to Customer No.");
                        //Gstin := Customer."GST Registration No.";//2019CU19
                        Gstin := ServiceCrMemoHeader."Customer GST Reg. No.";
                        LglNm := ServiceCrMemoHeader."Bill-to Name";
                        TrdNm := ServiceCrMemoHeader."Bill-to Name";
                        Addr1 := ServiceCrMemoHeader."Bill-to Address";
                        Addr2 := ServiceCrMemoHeader."Bill-to Address 2";
                        Loc := ServiceCrMemoHeader."Bill-to City";
                        //StateBuff.GET(Customer."State Code");
                        StateBuff.GET(ServiceCrMemoHeader."GST Bill-to State Code");
                        Stcd := StateBuff."State Code (GST Reg. No.)";
                        Pos := StateBuff."State Code (GST Reg. No.)";
                        Pin := COPYSTR(ServiceCrMemoHeader."Bill-to Post Code", 1, 6);
                        IF Contact.GET(ServiceCrMemoHeader."Bill-to Contact No.") THEN BEGIN
                            //Ph := COPYSTR(Contact."Phone No.",1,10);
                            Ph := '';
                            Em := GetMailId(Contact."E-Mail");//5002Fix
                        END;
                    END;
            END;
        END;
        //<< POSShipToGSTINFix
        WriteBuyerDtlsService(Gstin, LglNm, TrdNm, Pos, Addr1, Addr2, Loc, Pin, Stcd, Ph, Em);
    end;

    local procedure WriteBuyerDtlsService(Gstin: Text[15]; LglNm: Text[100]; TrdNm: Text[100]; Pos: Text[2]; Addr1: Text[100]; Addr2: Text[60]; Loc: Text[60]; Pin: Text[6]; Stcd: Code[2]; Ph: Text[10]; Em: Text[50]);
    var
        PinInt: Integer;
    begin
        //v1.03 //Parameter changed from State to Stcd and related code

        //B2B>>
        IF Gstin <> '' then
            JObjBuyerDtlsG.Add('Gstin', Gstin)
        else
            JObjBuyerDtlsG.Add('Gstin', JVOBJG.AsToken());
        IF LglNm <> '' then
            JObjBuyerDtlsG.Add('LglNm', LglNm)
        else
            JObjBuyerDtlsG.Add('Lglm', JVOBJG.AsToken());
        IF TrdNm <> '' then
            JObjBuyerDtlsG.Add('TrdNm', TrdNm)
        else
            JObjBuyerDtlsG.Add('TrdNm', JVOBJG.AsToken());
        IF Addr1 <> '' then
            JObjBuyerDtlsG.Add('Addr1', Addr1)
        else
            JObjBuyerDtlsG.Add('Addr1', JVOBJG.AsToken());
        IF Addr2 <> '' then
            JObjBuyerDtlsG.Add('Addr2', Addr2)
        else
            JObjBuyerDtlsG.Add('Addr2', JVOBJG.AsToken());
        if Loc <> '' then
            JObjBuyerDtlsG.Add('Loc', Loc)
        else
            JObjBuyerDtlsG.Add('Loc', JVOBJG.AsToken());
        If Stcd <> '' then
            JObjBuyerDtlsG.Add('Stcd', Stcd)
        else
            JObjBuyerDtlsG.Add('Stcd', JVOBJG.AsToken());
        if Ph <> '' then
            JObjBuyerDtlsG.Add('Ph', Ph)
        else
            JObjBuyerDtlsG.Add('Ph', JVOBJG.AsToken());
        if Em <> '' then
            JObjBuyerDtlsG.Add('Em', Em)
        else
            JObjBuyerDtlsG.Add('Em', JVOBJG.AsToken());
        JObjVerG.Add('BuyerDtls', JObjBuyerDtlsG);
        //B2B<<

    end;

    local procedure ReadDispDtlsService();
    var
        CompanyInformationBuff: Record 79;
        LocationBuff: Record 14;
        StateBuff: Record State;
        Nm: Text[100];
        Add1: Text[100];
        Add2: Text[60];
        Loc: Text[60];
        Pin: Text[6];
        Stcd: Text[2];
    begin
        IF IsServiceInvoice THEN BEGIN
            CompanyInformationBuff.GET;
            Nm := CompanyInformationBuff.Name;
            LocationBuff.GET(ServiceInvoiceHeader."Location Code");
            Add1 := LocationBuff.Address;
            Add2 := LocationBuff."Address 2";
            Loc := LocationBuff.Name;
            Pin := COPYSTR(LocationBuff."Post Code", 1, 6);
            StateBuff.GET(LocationBuff."State Code");
            Stcd := StateBuff."State Code (GST Reg. No.)";
        END
        ELSE BEGIN
            CompanyInformationBuff.GET;
            Nm := CompanyInformationBuff.Name;
            LocationBuff.GET(ServiceCrMemoHeader."Location Code");
            Add1 := LocationBuff.Address;
            Add2 := LocationBuff."Address 2";
            Loc := LocationBuff.Name;
            Pin := COPYSTR(LocationBuff."Post Code", 1, 6);
            StateBuff.GET(LocationBuff."State Code");
            Stcd := StateBuff."State Code (GST Reg. No.)";
        END;

        WriteDispDtlsService(Nm, Add1, Add2, Loc, Pin, Stcd);
    end;

    local procedure WriteDispDtlsService(Nm: Text[100]; Add1: Text[100]; Add2: Text[60]; Loc: Text[60]; Pin: Text[6]; Stcd: Text[2]);
    var
        PinInt: Integer;
    begin
        //B2B>>
        if Nm <> '' then
            JObjDispDtlsG.Add('Nm', Nm)
        else
            JObjDispDtlsG.Add('Nm', '');
        if Add1 <> '' then
            JObjDispDtlsG.Add('Addr', Add1)
        else
            JObjDispDtlsG.Add('Addr', Add1);
        if Add2 <> '' then
            JObjDispDtlsG.Add('Addr2', Add2)
        else
            JObjDispDtlsG.Add('Addr2', Add2);
        if Loc <> '' then
            JObjDispDtlsG.Add('Loc', Loc)
        else
            JObjDispDtlsG.Add('Loc', JVOBJG.AsToken());
        if Pin <> '' then
            JObjDispDtlsG.Add('Pin', Pin)
        else
            JObjDispDtlsG.Add('Pin', JVOBJG.AsToken());
        if Stcd <> '' then
            JObjDispDtlsG.Add('Stcd', Stcd)
        else
            JObjDispDtlsG.Add('Stcd', JVOBJG.AsToken());
        JObjVerG.Add('DispDtls', JObjDispDtlsG);
        //B2B<<
    end;

    local procedure ReadShipDtlsService();
    var
        ShipToAddr: Record 222;
        StateBuff: Record State;
        Gstin: Text[15];
        LglNm: Text[100];
        TrdNm: Text[100];
        Addr1: Text[100];
        Addr2: Text[60];
        Loc: Text[60];
        Pin: Text[6];
        Stcd: Text[2];
        Ph: Text[10];
        Em: Text[50];
        Customer: Record 18;
    begin
        IF IsServiceInvoice THEN BEGIN
            IF ShipToAddr.GET(ServiceInvoiceHeader."Customer No.", ServiceInvoiceHeader."Ship-to Code") THEN BEGIN
                LglNm := ServiceInvoiceHeader."Ship-to Name";
                TrdNm := ServiceInvoiceHeader."Ship-to Name";
                Addr1 := ServiceInvoiceHeader."Ship-to Address";
                Addr2 := ServiceInvoiceHeader."Ship-to Address 2";
                Loc := ServiceInvoiceHeader."Ship-to City";
                //v1.03  >>
                IF ServiceInvoiceHeader."GST Customer Type" <> ServiceInvoiceHeader."GST Customer Type"::Export THEN BEGIN
                    Gstin := ShipToAddr."GST Registration No.";
                    StateBuff.GET(ServiceInvoiceHeader."GST Ship-to State Code");
                    //StateBuff.GET(ShipToAddr.State);
                    Stcd := StateBuff."State Code (GST Reg. No.)";
                    Pin := COPYSTR(ServiceInvoiceHeader."Ship-to Post Code", 1, 6);
                END ELSE BEGIN
                    Gstin := '';
                    Stcd := '97';//v1.03 //Other Territory
                    Pin := '999999';
                END;
                //v1.03 <<
            END ELSE BEGIN
                LglNm := ServiceInvoiceHeader."Bill-to Name";
                TrdNm := ServiceInvoiceHeader."Bill-to Name";
                Addr1 := ServiceInvoiceHeader."Bill-to Address";
                Addr2 := ServiceInvoiceHeader."Bill-to Address 2";
                Loc := ServiceInvoiceHeader."Bill-to City";

                IF ServiceInvoiceHeader."GST Customer Type" <> ServiceInvoiceHeader."GST Customer Type"::Export THEN BEGIN
                    /*
                    Customer.GET("Bill-to Customer No.");
                    Gstin := Customer."GST Registration No.";
                    *///2019CU19
                    Gstin := ServiceInvoiceHeader."Customer GST Reg. No.";
                    //>>v1.03
                    StateBuff.GET(ServiceInvoiceHeader."GST Bill-to State Code");
                    //StateBuff.GET(Customer."State Code");
                    //<<v1.03
                    Stcd := StateBuff."State Code (GST Reg. No.)";
                    Pin := COPYSTR(ServiceInvoiceHeader."Bill-to Post Code", 1, 6);
                END ELSE BEGIN
                    Gstin := '';
                    Stcd := '97';//v1.03 //Other Territory
                    Pin := '999999';
                END;
            END;
            WriteShipDtlsService(Gstin, LglNm, TrdNm, Addr1, Addr2, Loc, Pin, Stcd);
        END ELSE BEGIN
            IF ShipToAddr.GET(ServiceCrMemoHeader."Customer No.", ServiceCrMemoHeader."Ship-to Code") THEN BEGIN
                LglNm := ServiceCrMemoHeader."Ship-to Name";
                TrdNm := ServiceCrMemoHeader."Ship-to Name";
                Addr1 := ServiceCrMemoHeader."Ship-to Address";
                Addr2 := ServiceCrMemoHeader."Ship-to Address 2";
                Loc := ServiceCrMemoHeader."Ship-to City";
                //v1.03  >>
                IF ServiceCrMemoHeader."GST Customer Type" <> ServiceCrMemoHeader."GST Customer Type"::Export THEN BEGIN
                    Gstin := ShipToAddr."GST Registration No.";
                    StateBuff.GET(ServiceCrMemoHeader."GST Ship-to State Code");
                    //StateBuff.GET(ShipToAddr.State);
                    Stcd := StateBuff."State Code (GST Reg. No.)";
                    Pin := COPYSTR(ServiceCrMemoHeader."Ship-to Post Code", 1, 6);
                END ELSE BEGIN
                    Gstin := '';
                    Stcd := '97';//v1.03 //Other Territory
                    Pin := '999999';
                END;
                //v1.03 <<
            END ELSE BEGIN
                LglNm := ServiceCrMemoHeader."Bill-to Name";
                TrdNm := ServiceCrMemoHeader."Bill-to Name";
                Addr1 := ServiceCrMemoHeader."Bill-to Address";
                Addr2 := ServiceCrMemoHeader."Bill-to Address 2";
                Loc := ServiceCrMemoHeader."Bill-to City";

                IF ServiceCrMemoHeader."GST Customer Type" <> ServiceCrMemoHeader."GST Customer Type"::Export THEN BEGIN
                    /*
                    Customer.GET("Bill-to Customer No.");
                    Gstin := Customer."GST Registration No.";
                    *///2019CU19
                    Gstin := ServiceCrMemoHeader."Customer GST Reg. No.";
                    StateBuff.GET(ServiceCrMemoHeader."GST Bill-to State Code");
                    //StateBuff.GET(Customer."State Code");
                    Stcd := StateBuff."State Code (GST Reg. No.)";
                    Pin := COPYSTR(ServiceCrMemoHeader."Bill-to Post Code", 1, 6);
                END ELSE BEGIN
                    Gstin := '';
                    Stcd := '97';//v1.03 //Other Territory
                    Pin := '999999';
                END;
            END;
            WriteShipDtlsService(Gstin, LglNm, TrdNm, Addr1, Addr2, Loc, Pin, Stcd);
        END;

    end;

    local procedure WriteShipDtlsService(Gstin: Text[15]; LglNm: Text[100]; TrdNm: Text[100]; Addr1: Text[100]; Addr2: Text[60]; Loc: Text[60]; Pin: Text[6]; Stcd: Text[2]);
    var
        PinInt: Integer;
    begin


        //B2B>>
        IF Gstin <> '' then
            JObjShipDtlsG.Add('Gstin', Gstin)
        else
            JObjShipDtlsG.Add('Gstin', JVOBJG.AsToken());
        IF LglNm <> '' then
            JObjShipDtlsG.Add('LglNm', LglNm)
        else
            JObjShipDtlsG.Add('Lglm', JVOBJG.AsToken());
        IF TrdNm <> '' then
            JObjShipDtlsG.Add('TrdNm', TrdNm)
        else
            JObjShipDtlsG.Add('TrdNm', JVOBJG.AsToken());
        IF Addr1 <> '' then
            JObjShipDtlsG.Add('Addr1', Addr1)
        else
            JObjShipDtlsG.Add('Addr1', JVOBJG.AsToken());
        IF Addr2 <> '' then
            JObjShipDtlsG.Add('Addr2', Addr2)
        else
            JObjShipDtlsG.Add('Addr2', JVOBJG.AsToken());
        if Loc <> '' then
            JObjShipDtlsG.Add('Loc', Loc)
        else
            JObjShipDtlsG.Add('Loc', Loc);
        If Stcd <> '' then
            JObjShipDtlsG.Add('Stcd', Stcd)
        else
            JObjShipDtlsG.Add('Stcd', Stcd);
        JObjVerG.Add('ShipDtls', JObjVerG);
        //B2B<<
    end;

    local procedure ReadItemListService();
    var
        ServiceInvoiceLine: Record 5993;
        ServiceCrMemoLine: Record 5995;
        SlNo: Integer;
    begin
        IF IsServiceInvoice THEN BEGIN
            ServiceInvoiceLine.SETRANGE("Document No.", DocumentNo);
            //ServiceInvoiceLine.SETFILTER("No.", '<>%1&<>%2&<>%3', '', GetInvRoundingAccService, GetGSTRoundingAccService);
            ServiceInvoiceLine.SETFILTER("No.", '<>%1&<>%2', '', GetInvRoundingAccService());
            ServiceInvoiceLine.SETFILTER(Quantity, '<>%1', 0);
            IF ServiceInvoiceLine.FINDSET THEN BEGIN
                IF ServiceInvoiceLine.COUNT > 1000 THEN
                    ERROR(SalesLinesErr, ServiceInvoiceLine.COUNT);
                REPEAT
                    SlNo += 1;
                    WriteItemService(ServiceInvoiceLine, SlNo);

                UNTIL ServiceInvoiceLine.NEXT = 0;
                //JsonTextWriter.WriteEndArray;
                JObjVerG.Add('ItemList', JObjItemArrayG);
            END;
        END ELSE BEGIN
            ServiceCrMemoLine.SETRANGE("Document No.", DocumentNo);
            //ServiceCrMemoLine.SETFILTER("No.", '<>%1&<>%2&<>%3', '', GetInvRoundingAccService, GetGSTRoundingAccService);
            ServiceCrMemoLine.SETFILTER("No.", '<>%1&<>%2', '', GetInvRoundingAccService());
            ServiceCrMemoLine.SETFILTER(Quantity, '<>%1', 0);
            IF ServiceCrMemoLine.FINDSET THEN BEGIN
                IF ServiceCrMemoLine.COUNT > 1000 THEN
                    ERROR(SalesLinesErr, ServiceCrMemoLine.COUNT);
                //JsonTextWriter.WritePropertyName('ItemList');
                //JsonTextWriter.WriteStartArray;
                REPEAT
                    SlNo += 1;
                    WriteItemService(ServiceCrMemoLine, SlNo);

                UNTIL ServiceCrMemoLine.NEXT = 0;
                // JsonTextWriter.WriteEndArray;
                JObjVerG.Add('ItemList', JObjItemArrayG);
            END;
        END;
    end;

    local procedure WriteItemService(Variant: Variant; SlNo: Integer);
    var
        RecRef: RecordRef;
        ServiceInvoiceLine: Record 5993;
        ServiceCrMemoLine: Record 5995;
        ValueEntry: Record 5802;
        ItemLedgerEntry: Record 32;
        ValueEntryRelation: Record 6508;
        ItemTrackingManagement: Codeunit 6500;
        InvoiceRowID: Text[250];
        IsServc: Text[1];
        PrdDesc: Text[100];
        HsnCd: Text[8];
        Qty: Decimal;
        Unit: Text[3];
        UnitPrice: Decimal;
        TotAmt: Decimal;
        Discount: Decimal;
        AssAmt: Decimal;
        GstRt: Decimal;
        CgstAmt: Decimal;
        SgstAmt: Decimal;
        IgstAmt: Decimal;
        CesRt: Decimal;
        CesAmt: Decimal;
        CesNonAdvlAmt: Decimal;
        StateCesRt: Decimal;
        StateCesAmt: Decimal;
        StateCesNonAdvlAmt: Decimal;
        OthChrg: Decimal;
        TotItemVal: Decimal;
        Item: Record 27;
        LotExist: Boolean;
        LineNo: Integer;
        Barcde: Text[30];
        FreeQty: Decimal;
        PreTaxVal: Decimal;
        OrdLineRef: Integer;
        OrgCntry: Code[2];
        PrdSlNo: Code[20];
        UOM: Record 204;
        CurrExchRate: Record 330;
        TotGSTAmt: Decimal;
        JobjItemLinesL: JsonObject;
    begin
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            5993:
                ServiceInvoiceLine := Variant;
            5995:
                ServiceCrMemoLine := Variant;
        END;

        IF IsServiceInvoice THEN BEGIN
            IF ServiceInvoiceLine."GST Group Type" = ServiceInvoiceLine."GST Group Type"::Service THEN
                IsServc := 'Y'
            ELSE
                IsServc := 'N';
            PrdDesc := ServiceInvoiceLine.Description + ServiceInvoiceLine."Description 2";
            HsnCd := ServiceInvoiceLine."HSN/SAC Code";
            //>>v1.03
            Barcde := '';
            PreTaxVal := ROUND(ServiceInvoiceLine.Quantity * ServiceInvoiceLine."Unit Price", 0.01, '=');//5002Fix
            OrdLineRef := ServiceInvoiceLine."Line No.";
            OrgCntry := 'IN';
            PrdSlNo := '';
            //<<v1.03
            //B2BUPG1.0>> - Comented due to free supply has no solution.
            /*
            //>>FreeSupplyFix
            IF ServiceInvoiceLine."Free Supply" THEN BEGIN
                Qty := 0;
                FreeQty := ServiceInvoiceLine.Quantity;
                AssAmt := 0;
            END ELSE BEGIN*/
            //B2BUPG1.0<< - Comented due to free supply has no solution.
            Qty := ROUND(ServiceInvoiceLine.Quantity, 0.001, '='); //BugFixUnitPrc
            FreeQty := 0;
            //IF ServiceInvoiceLine."GST Assessable Value (LCY)" <> 0 THEN  //Check
            //AssAmt := ServiceInvoiceLine."GST Assessable Value (LCY)"
            //NonGst >>
            //ELSE IF ServiceInvoiceLine."GST Base Amount" <> 0 THEN
            //B2BUPG1.0>>
            /*
            IF ServiceInvoiceLine."GST Base Amount" <> 0 THEN
                AssAmt := ServiceInvoiceLine."GST Base Amount"
            ELSE
                AssAmt := ServiceInvoiceLine."Line Amount" + ServiceInvoiceLine."Inv. Discount Amount";
                */
            AssAmt := ServiceInvoiceLine.Amount;
            //B2BUPG1.0<<
            //NonGst <<
            //END;
            //<<FreeSupplyFix
            IF UOM.GET(ServiceInvoiceLine."Unit of Measure Code") THEN
                //Unit := COPYSTR(UOM.Code, 1, 3);
                Unit := COPYSTR(UOM."GST UQC Code B2B", 1, 3);
            UnitPrice := ROUND(ServiceInvoiceLine."Unit Price", 0.01, '=');//5002Fix
            TotAmt := ServiceInvoiceLine."Line Amount" + ServiceInvoiceLine."Line Discount Amount";
            Discount := ServiceInvoiceLine."Line Discount Amount" + ServiceInvoiceLine."Inv. Discount Amount";//v1.03

            GetGSTCompRateService(ServiceInvoiceLine."Document No.", ServiceInvoiceLine."Line No.",
              GstRt, CgstAmt, SgstAmt, IgstAmt, CesRt, CesAmt, CesNonAdvlAmt, StateCesRt, StateCesAmt, StateCesNonAdvlAmt, TotGSTAmt);
            OthChrg := 0;
            //B2BUPG1.0>>
            //TotItemVal := ServiceInvoiceLine."Amount Including Tax" + ServiceInvoiceLine."Total GST Amount";
            TotItemVal := ServiceInvoiceLine."Amount Including VAT" + TotGSTAmt;
            //B2BUPG1.0<<

            IF ServiceInvoiceLine.Type = ServiceInvoiceLine.Type::Item THEN BEGIN
                Item.GET(ServiceInvoiceLine."No.");
                LotExist := Item."Item Tracking Code" <> '';
                //>>v1.03
                OrgCntry := 'IN';
                IF Item."Country/Region of Origin Code" <> '' THEN
                    OrgCntry := COPYSTR(Item."Country/Region of Origin Code", 1, 2);
                //<<v1.03
            END;
            LineNo := ServiceInvoiceLine."Line No.";
        END ELSE BEGIN
            IF ServiceCrMemoLine."GST Group Type" = ServiceCrMemoLine."GST Group Type"::Service THEN
                IsServc := 'Y'
            ELSE
                IsServc := 'N';
            PrdDesc := ServiceCrMemoLine.Description + ServiceCrMemoLine."Description 2";
            HsnCd := ServiceCrMemoLine."HSN/SAC Code";
            //>>v1.03
            Barcde := '';
            PreTaxVal := ROUND(ServiceCrMemoLine.Quantity * ServiceCrMemoLine."Unit Price", 0.01, '=');//5002Fix
            OrdLineRef := ServiceCrMemoLine."Line No.";
            OrgCntry := 'IN';
            PrdSlNo := '';
            //<<v1.03
            //B2BUPG1.0>> - Comented due to free supply has no solution.
            /*
            //>>FreeSupplyFix
            IF ServiceCrMemoLine."Free Supply" THEN BEGIN
                Qty := 0;
                FreeQty := ServiceCrMemoLine.Quantity;
                AssAmt := 0;
            END ELSE BEGIN*/
            //B2BUPG1.0<< - Comented due to free supply has no solution.
            Qty := ROUND(ServiceCrMemoLine.Quantity, 0.001, '='); //BugFixUnitPrc
            FreeQty := 0;
            //IF ServiceCrMemoLine."GST Assessable Value (LCY)" <> 0 THEN  //Check
            //AssAmt := ServiceCrMemoLine."GST Assessable Value (LCY)"
            //NonGst >>
            //ELSE IF ServiceCrMemoLine."GST Base Amount" <> 0 THEN
            //B2BUPG1.0>>
            /*
            IF ServiceCrMemoLine."GST Base Amount" <> 0 THEN
                AssAmt := ServiceCrMemoLine."GST Base Amount"
            ELSE
                AssAmt := ServiceCrMemoLine."Line Amount" + ServiceCrMemoLine."Line Discount Amount";
                */
            AssAmt := ServiceCrMemoLine.Amount;
            //B2BUPG1.0<<
            //NonGst <<
            //END;
            //<<FreeSupplyFix
            IF UOM.GET(ServiceCrMemoLine."Unit of Measure Code") THEN
                //Unit := COPYSTR(UOM.Code, 1, 3);
                Unit := COPYSTR(UOM."GST UQC Code B2B", 1, 3);
            UnitPrice := ServiceCrMemoLine."Unit Price";
            TotAmt := ServiceCrMemoLine."Line Amount" + ServiceCrMemoLine."Line Discount Amount";
            Discount := ServiceCrMemoLine."Line Discount Amount" + ServiceCrMemoLine."Inv. Discount Amount";//v1.03

            GetGSTCompRateService(ServiceCrMemoLine."Document No.", ServiceCrMemoLine."Line No.",
              GstRt, CgstAmt, SgstAmt, IgstAmt, CesRt, CesAmt, CesNonAdvlAmt, StateCesRt, StateCesAmt, StateCesNonAdvlAmt, TotGSTAmt);
            OthChrg := 0;

            //B2BUPG1.0>>
            //TotItemVal := ServiceCrMemoLine."Amount Including Tax" + ServiceCrMemoLine."Total GST Amount";
            TotItemVal := ServiceCrMemoLine."Amount Including VAT" + TotGSTAmt;
            //B2BUPG1.0<<

            IF ServiceCrMemoLine.Type = ServiceCrMemoLine.Type::Item THEN BEGIN
                Item.GET(ServiceCrMemoLine."No.");
                LotExist := Item."Item Tracking Code" <> '';
                //>>v1.03
                IF Item."Country/Region of Origin Code" <> '' THEN
                    OrgCntry := COPYSTR(Item."Country/Region of Origin Code", 1, 2);
                //<<v1.03
            END;
            LineNo := ServiceCrMemoLine."Line No.";
        END;

        //EXPFIX >>

        IF PreTaxVal <> 0 THEN
            PreTaxVal := ROUND(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                        WORKDATE, CurrCode, PreTaxVal, CurrFactor), 0.01, '=');

        IF AssAmt <> 0 THEN
            AssAmt := ROUND(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                        WORKDATE, CurrCode, AssAmt, CurrFactor), 0.01, '=');

        IF UnitPrice <> 0 THEN
            UnitPrice := ROUND(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                        WORKDATE, CurrCode, UnitPrice, CurrFactor), 0.01, '=');

        IF TotAmt <> 0 THEN
            TotAmt := ROUND(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                        WORKDATE, CurrCode, TotAmt, CurrFactor), 0.01, '=');

        IF Discount <> 0 THEN
            Discount := ROUND(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                        WORKDATE, CurrCode, Discount, CurrFactor), 0.01, '=');

        IF OthChrg <> 0 THEN
            OthChrg := ROUND(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                        WORKDATE, CurrCode, OthChrg, CurrFactor), 0.01, '=');

        IF TotItemVal <> 0 THEN
            TotItemVal := ROUND(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                        WORKDATE, CurrCode, TotItemVal, CurrFactor), 0.01, '=');
        //EXPFIX <<

        //B2B>>
        IF SlNo <> 0 then
            JobjItemLinesL.Add('SlNo', SlNo)
        else
            JobjItemLinesL.Add('SlNo', JVOBJG.AsToken());
        if IsServc <> '' then
            JobjItemLinesL.Add('IsServc', IsServc)
        else
            JobjItemLinesL.Add('IsServc', JVOBJG.AsToken());
        if PrdDesc <> '' then
            JobjItemLinesL.Add('PrdDesc', PrdDesc)
        else
            JobjItemLinesL.Add('PrdDesc', JVOBJG.AsToken());
        if HsnCd <> '' then
            JobjItemLinesL.Add('HsnCd', HsnCd)
        else
            JobjItemLinesL.Add('HsnCd', JVOBJG.AsToken());
        if Barcde <> '' then
            JobjItemLinesL.Add('Barcde', Barcde)
        else
            JobjItemLinesL.Add('Barcde', JVOBJG.AsToken());

        JobjItemLinesL.Add('Qty', Qty);
        JobjItemLinesL.Add('FreeQty', FreeQty);
        if Unit <> '' then
            JobjItemLinesL.Add('Unit', Unit)
        else
            JobjItemLinesL.Add('Unit', JVOBJG.AsToken());
        JobjItemLinesL.Add('UnitPrice', UnitPrice);
        JobjItemLinesL.Add('TotAmt', TotAmt);
        JobjItemLinesL.Add('Discount', Discount);
        JobjItemLinesL.Add('PreTaxVal', PreTaxVal);
        JobjItemLinesL.Add('AssAmt', AssAmt);
        JobjItemLinesL.Add('GstRt', GstRt);
        JobjItemLinesL.Add('SgstAmt', SgstAmt);
        JobjItemLinesL.Add('IgstAmt', IgstAmt);
        JobjItemLinesL.Add('CgstAmt', CgstAmt);
        JobjItemLinesL.Add('CesRt', CesRt);
        JobjItemLinesL.Add('CesAmt', CesAmt);
        JobjItemLinesL.Add('CesNonAdvlAmt', CesNonAdvlAmt);
        JobjItemLinesL.Add('StateCesRt', StateCesRt);
        JobjItemLinesL.Add('StateCesAmt', StateCesAmt);
        JobjItemLinesL.Add('StateCesNonAdvlAmt', StateCesNonAdvlAmt);
        JobjItemLinesL.Add('OthChrg', OthChrg);
        JobjItemLinesL.Add('TotItemVal', TotItemVal);
        JobjItemLinesL.Add('OrdLineRef', OrdLineRef);
        JobjItemLinesL.Add('OrgCntry', OrgCntry);
        JobjItemLinesL.Add('PrdSlNo', PrdSlNo);
        if LotExist then
            ReadBchDtlsService(LineNo, JobjItemLinesL)
        else
            JobjItemLinesL.Add('BchDtls', JVOBJG.AsToken());
        JobjItemLinesL.Add('AttribDtls', JVOBJG.AsToken());
        JObjItemArrayG.Add(JobjItemLinesL);
        //B2B<<

    end;

    local procedure ReadBchDtlsService(LineNo: Integer; var JObjectItems: JsonObject);
    var
        SalesInvoiceLine: Record 113;
        SalesCrMemoLine: Record 115;
        ValueEntry: Record 5802;
        ItemLedgerEntry: Record 32;
        ValueEntryRelation: Record 6508;
        ItemTrackingManagement: Codeunit 6500;
        InvoiceRowID: Text[250];
    begin
        IF IsServiceInvoice THEN
            InvoiceRowID := ItemTrackingManagement.ComposeRowID(DATABASE::"Service Invoice Line", 0, DocumentNo, '', 0, LineNo)
        ELSE
            InvoiceRowID := ItemTrackingManagement.ComposeRowID(DATABASE::"Service Cr.Memo Line", 0, DocumentNo, '', 0, LineNo);
        ValueEntryRelation.SETCURRENTKEY("Source RowId");
        ValueEntryRelation.SETRANGE("Source RowId", InvoiceRowID);
        IF ValueEntryRelation.FINDSET THEN BEGIN
            REPEAT
                ValueEntry.GET(ValueEntryRelation."Value Entry No.");
                ItemLedgerEntry.GET(ValueEntry."Item Ledger Entry No.");
                IF ItemLedgerEntry."Invoiced Quantity" <> 0 THEN
                    WriteBchDtls(
                      COPYSTR(ItemLedgerEntry."Lot No." + ItemLedgerEntry."Serial No.", 1, 20),
                      FORMAT(ItemLedgerEntry."Expiration Date", 0, '<Year4>-<Month,2>-<Day,2>'),
                      FORMAT(ItemLedgerEntry."Warranty Date", 0, '<Year4>-<Month,2>-<Day,2>'), JObjBactchLineG);
            UNTIL ValueEntryRelation.NEXT = 0;
            JObjVerG.Add('BchDtls', JObjBactchLineG);
        END;
    end;

    local procedure WriteBchDtlsService(Nm: Text[20]; ExpDt: Text[10]; WrDt: Text[10]; var JObjBchDtlsL: JsonObject);
    begin

        if Nm <> '' then
            JObjBchDtlsL.Add('Nm', Nm)
        else
            JObjBchDtlsL.Add('Nm', JVOBJG.AsToken());
        if ExpDt <> '' then
            JObjBchDtlsL.Add('ExpDt', ExpDt)
        else
            JObjBchDtlsL.Add('ExpDt', JVOBJG.AsToken());
        if WrDt <> '' then
            JObjBchDtlsL.Add('WrDt', WrDt)
        else
            JObjBchDtlsL.Add('WrDt', JVOBJG.AsToken());
    end;

    local procedure ReadPayDtlsService();
    var
        Nm: Text[100];
        AccDet: Text[18];
        Mode: Text[18];
        FinInsBr: Text[11];
        PayTerm: Text[100];
        PayInstr: Text[100];
        CrTrn: Text[100];
        DirDr: Text[100];
        CrDay: Integer;
        PaidAmt: Decimal;
        PaymtDue: Decimal;
    begin
        IF IsServiceInvoice THEN BEGIN
            Nm := '';//Payee Name
            AccDet := '';//Bank Account No.
            Mode := '';//Mode of Payment: Cash, Credit, Direct Transfer
            FinInsBr := '';//Branch or IFSC code
            PayTerm := '';//Term of Payment
            PayInstr := '';//Pay Instruction
            CrTrn := '';//Credit Transfer
            DirDr := '';//Direct Debit
            CrDay := 0;//Credit Days
            PaidAmt := 0;//The sum of amount paid in advance
            PaymtDue := 0;//Outstanding amount
        END ELSE BEGIN
            Nm := '';//Payee Name
            AccDet := '';//Bank Account No.
            Mode := '';//Mode of Payment: Cash, Credit, Direct Transfer
            FinInsBr := '';//Branch or IFSC code
            PayTerm := '';//Term of Payment
            PayInstr := '';//Pay Instruction
            CrTrn := '';//Credit Transfer
            DirDr := '';//Direct Debit
            CrDay := 0;//Credit Days
            PaidAmt := 0;//The sum of amount paid in advance
            PaymtDue := 0;//Outstanding amount
        END;

        IF (Nm = '') AND (AccDet = '') AND (Mode = '') AND (FinInsBr = '') AND (PayTerm = '') AND (PayInstr = '') AND
          (CrTrn = '') AND (DirDr = '') AND (CrDay = 0) AND (PaidAmt = 0) AND (PaymtDue = 0)
        THEN BEGIN

            JObjVerG.Add('PayDtls', JVOBJG.AsToken());
        END ELSE
            WritePayDtlsService(Nm, AccDet, Mode, FinInsBr, PayTerm, PayInstr, CrTrn, DirDr, CrDay, PaidAmt, PaymtDue);
    end;

    local procedure WritePayDtlsService(Nm: Text[100]; AccDet: Text[18]; Mode: Text[18]; FinInsBr: Text[11]; PayTerm: Text[100]; PayInstr: Text[100]; CrTrn: Text[100]; DirDr: Text[100]; CrDay: Integer; PaidAmt: Decimal; PaymtDue: Decimal);
    begin

        if Nm <> '' then
            JObjPayDtlsG.Add('Nm', Nm)
        else
            JObjPayDtlsG.Add('Nm', JVOBJG.AsToken());
        if AccDet <> '' then
            JObjPayDtlsG.Add('AccDet', AccDet)
        else
            JObjPayDtlsG.Add('AccDet', JVOBJG.AsToken());
        if Mode <> '' then
            JObjPayDtlsG.Add('Mode', Mode)
        else
            JObjPayDtlsG.Add('Mode', JVOBJG.AsToken());

        if FinInsBr <> '' then
            JObjPayDtlsG.Add('FinInsBr', FinInsBr)
        else
            JObjPayDtlsG.Add('FinInsBr', JVOBJG.AsToken());
        if PayTerm <> '' then
            JObjPayDtlsG.Add('PayTerm', PayTerm)
        else
            JObjPayDtlsG.Add('PayTerm', JVOBJG.AsToken());
        if PayInstr <> '' then
            JObjPayDtlsG.Add('PayInstr', PayInstr)
        else
            JObjPayDtlsG.Add('PayInstr', JVOBJG.AsToken());
        if CrTrn <> '' then
            JObjPayDtlsG.Add('CrTrn', CrTrn)
        else
            JObjPayDtlsG.Add('CrTrn', JVOBJG.AsToken());
        if DirDr <> '' then
            JObjPayDtlsG.Add('DirDr', DirDr)
        else
            JObjPayDtlsG.Add('DirDr', JVOBJG.AsToken());
        if CrDay <> 0 then
            JObjPayDtlsG.Add('CrDay', CrDay)
        else
            JObjPayDtlsG.Add('CrDay', JVOBJG.AsToken());
        if PaidAmt <> 0 then
            JObjPayDtlsG.Add('PaidAmt', PaidAmt)
        else
            JObjPayDtlsG.Add('PaidAmt', JVOBJG.AsToken());
        if PaymtDue <> 0 then
            JObjPayDtlsG.Add('PaymtDue', PaymtDue)
        else
            JObjPayDtlsG.Add('PaymtDue', JVOBJG.AsToken());
        JObjVerG.Add('PayDtls', JObjPayDtlsG);

    end;

    local procedure ReadRefDtlsService();
    var
        InvRm: Text[100];
        InvStDt: Text[10];
        InvEndDt: Text[10];
        InvNo: Text[16];
        InvDt: Text[10];
        OthRefNo: Text[20];
        RecAdvRefr: Text[20];
        RecAdvDt: Text[10];
        TendRefr: Text[20];
        ContrRefr: Text[20];
        ExtRefr: Text[20];
        ProjRefr: Text[20];
        PORefr: Text[16];
        PORefDt: Text[10];
    begin
        IF IsServiceInvoice THEN BEGIN
            InvRm := '';//Remarks/Note
            InvStDt := '';//Invoice Start Date
            InvEndDt := '';//Invoice End Date

            InvNo := '';//Reference of Original Invoice if any
            InvDt := '';//Date of preceding invoice
            OthRefNo := '';//Other Reference

            RecAdvRefr := '';//Receipt Advice No.
            RecAdvDt := '';//Date of Receipt Advice
            TendRefr := '';//Lot/Batch Reference No.
            ContrRefr := '';//Contract Reference No.
            ExtRefr := '';//Any other Reference
            ProjRefr := '';//Project Reference No.
            PORefr := '';//Vendor PO Reference No.
            PORefDt := '';//Vendor PO Reference Date
        END ELSE BEGIN
            InvRm := '';//Remarks/Note
            InvStDt := '';//Invoice Start Date
            InvEndDt := '';//Invoice End Date

            InvNo := '';//Reference of Original Invoice if any
            InvDt := '';//Date of preceding invoice
            OthRefNo := '';//Other Reference

            RecAdvRefr := '';//Receipt Advice No.
            RecAdvDt := '';//Date of Receipt Advice
            TendRefr := '';//Lot/Batch Reference No.
            ContrRefr := '';//Contract Reference No.
            ExtRefr := '';//Any other Reference
            ProjRefr := '';//Project Reference No.
            PORefr := '';//Vendor PO Reference No.
            PORefDt := '';//Vendor PO Reference Date
        END;

        IF (InvRm = '') AND (InvStDt = '') AND (InvEndDt = '') AND
          (InvNo = '') AND (InvDt = '') AND (OthRefNo = '') AND
          (RecAdvRefr = '') AND (RecAdvDt = '') AND (TendRefr = '') AND (ContrRefr = '') AND
          (ExtRefr = '') AND (ProjRefr = '') AND (PORefr = '') AND (PORefDt = '')
        THEN BEGIN
            // JsonTextWriter.WritePropertyName('RefDtls');
            //JsonTextWriter.WriteValue(GlobalNULL);
            JObjVerG.Add('RefDtls', JVOBJG.AsToken());
        END ELSE
            WriteRefDtlsService(InvRm, InvStDt, InvEndDt, InvNo, InvDt, OthRefNo, RecAdvRefr, RecAdvDt, TendRefr, ContrRefr, ExtRefr, ProjRefr, PORefr, PORefDt);
    end;

    local procedure WriteRefDtlsService(InvRm: Text[100]; InvStDt: Text[10]; InvEndDt: Text[10]; InvNo: Text[16]; InvDt: Text[10]; OthRefNo: Text[20]; RecAdvRefr: Text[20]; RecAdvDt: Text[10]; TendRefr: Text[20]; ContrRefr: Text[20]; ExtRefr: Text[20]; ProjRefr: Text[20]; PORefr: Text[16]; PORefDt: Text[10]);
    begin
        //B2BSaas>>
        if InvRm <> '' then
            JObjRefDtlsG.Add('InvRm', InvRm)
        else
            JObjRefDtlsG.Add('InvRm', '');
        if InvStDt <> '' then
            JObjRefDtlsG.Add('InvStDt', InvStDt)
        else
            JObjRefDtlsG.Add('InvstDt', '');
        if InvEndDt <> '' then
            JObjRefDtlsG.Add('InvEndDt', InvEndDt)
        else
            JObjRefDtlsG.Add('InvEndDt', '');
        JObjVerG.Add('RefDtls', JObjRefDtlsG);
        //B2Bsaas<<
        WritePrecDocDtlsService(InvNo, InvDt, OthRefNo);

        WriteContrDtlsService(RecAdvRefr, RecAdvDt, TendRefr, ContrRefr, ExtRefr, ProjRefr, PORefr, PORefDt);

    end;

    local procedure WritePrecDocDtlsService(InvNo: Text[16]; InvDt: Text[10]; OthRefNo: Text[20]);
    begin
        JObjVerG.Add('PrecDocDtls', '');
        JObjPreDtlsG.Add('InvNo', '');
        JObjPreDtlsG.Add('InvDt', '');
        JObjPreDtlsG.Add('OthRefNo', '');
        repeat
            if InvNo <> '' then
                JObjPreDtlsG.Add('InvNo', InvNo)
            else
                JObjPreDtlsG.Add('InvNo', JVOBJG.AsToken());
            if InvDt <> '' then
                JObjPreDtlsG.Add('InvDt', '')
            else
                JObjPreDtlsG.Add('InvDt', JVOBJG.AsToken());
            if OthRefNo <> '' then
                JObjPreDtlsG.Add('OthRefNo', '')
            else
                JObjPreDtlsG.Add('OthRefNo', JVOBJG.AsToken());
            JSArrayPreDtlsG.Add(JObjPreDtlsG);
        until true;
        JObjVerG.Add('PrecDocument', JSArrayPreDtlsG);

    end;

    local procedure WriteContrDtlsService(RecAdvRefr: Text[20]; RecAdvDt: Text[10]; TendRefr: Text[20]; ContrRefr: Text[20]; ExtRefr: Text[20]; ProjRefr: Text[20]; PORefr: Text[16]; PORefDt: Text[10]);
    begin
        JObjVerG.Add('ContrDtls', '');
        JObjContrlDtlsG.Add('RecAdvRefr', '');
        JObjContrlDtlsG.Add('RecAdvDt', '');
        JObjContrlDtlsG.Add('TendRefr', '');
        JObjContrlDtlsG.Add('ContrRefr', '');
        JObjContrlDtlsG.Add('ExtRefr', '');
        JObjContrlDtlsG.Add('ProjRefr', '');
        JObjContrlDtlsG.Add('PORefDt', '');
        repeat
            if RecAdvRefr <> '' then
                JObjContrlDtlsG.Add('RecAdvRefr', RecAdvRefr)
            else
                JObjContrlDtlsG.Add('RecAdvRefr', JVOBJG.AsToken());
            if RecAdvDt <> '' then
                JObjContrlDtlsG.Add('RecAdvDt', RecAdvDt)
            else
                JObjContrlDtlsG.Add('RecAdvDt', JVOBJG.AsToken());
            if TendRefr <> '' then
                JObjContrlDtlsG.Add('TendRefr', '')
            else
                JObjContrlDtlsG.Add('TendRefr', JVOBJG.AsToken());
            if ContrRefr <> '' then
                JObjContrlDtlsG.Add('ContrRefr', ContrRefr)
            else
                JObjContrlDtlsG.Add('ContrRefr', JVOBJG.AsToken());
            if ExtRefr <> '' then
                JObjContrlDtlsG.Add('ExtRefr', ExtRefr)
            else
                JObjContrlDtlsG.Add('ExtRefr', JVOBJG.AsToken());
            if ProjRefr <> '' then
                JObjContrlDtlsG.Add('ProjRefr', ProjRefr)
            else
                JObjContrlDtlsG.Add('ProjRefr', JVOBJG.AsToken());
            if PORefDt <> '' then
                JObjContrlDtlsG.Add('PORefDt', PORefDt)
            else
                JObjContrlDtlsG.Add('PORefDt', JVOBJG.AsToken());
            JArryContrlDtlsG.Add(JObjContrlDtlsG);
        until true;
        JObjVerG.Add('Contract', JArryContrlDtlsG);

    end;

    local procedure ReadAddlDocDtlsService();
    var
        Url: Text[100];
        Docs: Text;
        Info: Text;
    begin
        IF IsServiceInvoice THEN BEGIN
            Url := '';//Supporting Document URL
            Docs := '';//Supporting document in Base64 Format
            Info := '';//Any additional info
        END ELSE BEGIN
            Url := '';//Supporting Document URL
            Docs := '';//Supporting document in Base64 Format
            Info := '';//Any additional info
        END;

        IF (Url = '') AND (Docs = '') AND (Info = '') THEN BEGIN
            // JsonTextWriter.WritePropertyName('AddlDocDtls');
            // JsonTextWriter.WriteValue(GlobalNULL);
            JObjVerG.Add('AddlDocDtls', JVOBJG.AsToken());
        END ELSE BEGIN
            //  JsonTextWriter.WritePropertyName('AddlDocDtls');
            //JsonTextWriter.WriteStartObject;
            //JsonTextWriter.WritePropertyName('AddlDocument');
            //JsonTextWriter.WriteStartArray;
            JObjVerG.Add('AddlDocDtls', '');
            REPEAT
                WriteAddlDocDtls(Url, Docs, Info, JSODcoDtlsG);
                JSArryDocDtlsG.Add(JSODcoDtlsG);
            UNTIL TRUE;
            JObjVerG.Add('AddlDocument', JSArryDocDtlsG);

        END;
    end;

    local procedure WriteAddlDocDtlsService(Url: Text[100]; Docs: Text; Info: Text; Var JSODcoDtlsL: JsonObject);
    begin

        if Url <> '' then
            JSODcoDtlsL.Add('Url', Url)
        else
            JSODcoDtlsL.Add('Url', JVOBJG.AsToken());
        if Docs <> '' then
            JSODcoDtlsL.Add('Docs', Docs)
        else
            JSODcoDtlsL.Add('Docs', JVOBJG.AsToken());
        if Info <> '' then
            JSODcoDtlsL.Add('Info', Info)
        else
            JSODcoDtlsL.Add('Info', JVOBJG.AsToken());

    end;

    local procedure ReadValDtlsService();
    var
        AssVal: Decimal;
        CgstVal: Decimal;
        SgstVal: Decimal;
        IgstVal: Decimal;
        CesVal: Decimal;
        StCesVal: Decimal;
        CesNonAdval: Decimal;
        Disc: Decimal;
        OthChrg: Decimal;
        TotInvVal: Decimal;
        RndOffAmt: Decimal;
        TotInvValFc: Decimal;
    begin
        GetGSTValService(AssVal, CgstVal, SgstVal, IgstVal, CesVal, StCesVal, CesNonAdval, Disc, OthChrg, TotInvVal, TotInvValFc);
        RndOffAmt := GetRndOffAmt;
        WriteValDtlsService(AssVal, CgstVal, SgstVal, IgstVal, CesVal, StCesVal, Disc, OthChrg, RndOffAmt, TotInvVal, TotInvValFc);
    end;

    local procedure WriteValDtlsService(Assval: Decimal; CgstVal: Decimal; SgstVAl: Decimal; IgstVal: Decimal; CesVal: Decimal; StCesVal: Decimal; Disc: Decimal; OthChrg: Decimal; RndOffAmt: Decimal; TotInvVal: Decimal; TotInvValFc: Decimal);
    begin
        //v1.03 Disc, OthChrg and TotInvValFc parameters and related code added

        //B2B>>
        JSOBJValG.Add('AssVal', Assval);
        JSOBJValG.Add('CgstVal', CgstVal);
        JSOBJValG.Add('SgstVal', SgstVAl);
        JSOBJValG.Add('IgstVal', IgstVal);
        JSOBJValG.Add('CesVal', CesVal);
        JSOBJValG.Add('StCesVal', StCesVal);
        JSOBJValG.Add('Disc', Disc);
        JSOBJValG.Add('OthChrg', OthChrg);
        JSOBJValG.Add('RndOffAmt', RndOffAmt);
        JSOBJValG.Add('TotInvVal', TotInvVal);
        JSOBJValG.Add('TotInvValFc', TotInvValFc);
        JObjVerG.Add('ValDtls', JSOBJValG);
        //B2B<<
    end;

    procedure SetServiceInvHeader(ServiceInvoiceHeaderBuff: Record 5992);
    begin
        ServiceInvoiceHeader := ServiceInvoiceHeaderBuff;
        IsServiceInvoice := TRUE;
    end;

    procedure SetServiceCrMemoHeader(ServiceCrMemoHeaderBuff: Record 5994);
    begin
        ServiceCrMemoHeader := ServiceCrMemoHeaderBuff;
        IsServiceInvoice := FALSE;
    end;

    local procedure GetRefInvNoService(DocNo: Code[20]) RefInvNo: Code[20];
    begin
        // ReferenceInvoiceNo.SETRANGE("Document No.",DocNo);
        // IF ReferenceInvoiceNo.FINDFIRST THEN
        //  RefInvNo := ReferenceInvoiceNo."Reference Invoice Nos."
        // ELSE
        //  RefInvNo := '';
    end;

    local procedure GetGSTCompRateService(DocNo: Code[20]; LineNo: Integer; var GstRt: Decimal; var CgstAmt: Decimal; var SgstAmt: Decimal; var IgstAmt: Decimal; var CesRt: Decimal; var CessAmt: Decimal; var CesNonAdvlAmt: Decimal; var StateCesRt: Decimal; var StateCesAmt: Decimal; var StateCesNonAdvlAmt: Decimal; var TotGSTAmt: Decimal);
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTComponent: Record "Tax Component";
        CurrExchRate: Record 330;
        ServiceInvoiceLine: Record 5993;
        ServiceCrMemoLine: Record 5995;
        TotalGSTAmount: Decimal;
    begin
        DetailedGSTLedgerEntry.SETRANGE("Document No.", DocNo);
        DetailedGSTLedgerEntry.SETRANGE("Document Line No.", LineNo);

        CesRt := 0;
        CessAmt := 0;
        CesNonAdvlAmt := 0;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'CESS');
        IF DetailedGSTLedgerEntry.FINDFIRST THEN
            IF DetailedGSTLedgerEntry."GST %" > 0 THEN BEGIN
                CesRt := DetailedGSTLedgerEntry."GST %";
                CessAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            END ELSE
                CesNonAdvlAmt := ABS(DetailedGSTLedgerEntry."GST Amount");

        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'INTERCESS');
        IF DetailedGSTLedgerEntry.FINDFIRST THEN BEGIN
            CesRt += DetailedGSTLedgerEntry."GST %";
            CessAmt += ABS(DetailedGSTLedgerEntry."GST Amount");
        END;

        StateCesRt := 0;
        StateCesAmt := 0;
        StateCesNonAdvlAmt := 0;
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code");
        IF DetailedGSTLedgerEntry.FINDSET THEN
            REPEAT
                IF NOT (DetailedGSTLedgerEntry."GST Component Code" IN ['CGST', 'SGST', 'IGST', 'CESS', 'INTERCESS']) THEN
                    //IF GSTComponent.GET(DetailedGSTLedgerEntry."GST Component Code") THEN
                    //IF GSTComponent."Exclude from Reports" THEN  //Check
                    IF DetailedGSTLedgerEntry."GST %" > 0 THEN BEGIN
                        StateCesRt := DetailedGSTLedgerEntry."GST %";
                        StateCesAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
                    END ELSE
                        StateCesNonAdvlAmt := ABS(DetailedGSTLedgerEntry."GST Amount");
            UNTIL DetailedGSTLedgerEntry.NEXT = 0;

        /*
        //LCY to FCY conversion
        IF IsInvoice THEN BEGIN
          CurrencyCode := SalesInvoiceHeader."Currency Code";
          CurrencyFactor := SalesInvoiceHeader."Currency Factor";
        END ELSE BEGIN
          CurrencyCode := SalesCrMemoHeader."Currency Code";
          CurrencyFactor := SalesCrMemoHeader."Currency Factor";
        END;
        
        IF CessAmt <> 0 THEN
          CessAmt := ROUND(CurrExchRate.ExchangeAmtLCYToFCY(WORKDATE,CurrencyCode,CessAmt,CurrencyFactor),1,'=');
        IF CesNonAdvlAmt <> 0 THEN
          CesNonAdvlAmt := ROUND(CurrExchRate.ExchangeAmtLCYToFCY(WORKDATE,CurrencyCode,CesNonAdvlAmt,CurrencyFactor),1,'=');
        IF StateCesAmt <> 0 THEN
          StateCesAmt := ROUND(CurrExchRate.ExchangeAmtLCYToFCY(WORKDATE,CurrencyCode,StateCesAmt,CurrencyFactor),1,'=');
        IF StateCesNonAdvlAmt <> 0 THEN
          StateCesNonAdvlAmt := ROUND(CurrExchRate.ExchangeAmtLCYToFCY(WORKDATE,CurrencyCode,StateCesNonAdvlAmt,CurrencyFactor),1,'=');
        *///EXPFIX

        GstRt := 0;
        CgstAmt := 0;
        SgstAmt := 0;
        IgstAmt := 0;

        IF IsServiceInvoice THEN BEGIN
            ServiceInvoiceLine.GET(DocNo, LineNo);
            //TotalGSTAmount := ServiceInvoiceLine."Total GST Amount";
        END ELSE BEGIN
            ServiceCrMemoLine.GET(DocNo, LineNo);
            //TotalGSTAmount := ServiceCrMemoLine."Total GST Amount";
        END;
        TotalGSTAmount := TotGSTAmt;

        //EXPFIX >>
        IF TotalGSTAmount <> 0 THEN
            TotalGSTAmount := ROUND(
                        CurrExchRate.ExchangeAmtFCYToLCY(
                        WORKDATE, CurrCode, TotalGSTAmount, CurrFactor), 0.01, '=');
        //EXPFIX <<
        TotalGSTAmount := TotalGSTAmount - (CessAmt + StateCesAmt + CesNonAdvlAmt + StateCesNonAdvlAmt);//v1.03

        IF DetailedGSTLedgerEntry.FINDFIRST THEN
            CASE DetailedGSTLedgerEntry."GST Component Code" OF
                'IGST':
                    BEGIN
                        GstRt := DetailedGSTLedgerEntry."GST %";
                        IgstAmt := Abs(DetailedGSTLedgerEntry."GST Amount");
                    END;
                'CGST', 'SGST':
                    BEGIN
                        GstRt := 2 * DetailedGSTLedgerEntry."GST %";
                        CgstAmt := Abs(DetailedGSTLedgerEntry."GST Amount");
                        SgstAmt := Abs(DetailedGSTLedgerEntry."GST Amount");
                    END;
            END;
        TotGSTAmt := CgstAmt + SgstAmt + IgstAmt + CessAmt + StateCesAmt + CesNonAdvlAmt + StateCesNonAdvlAmt;
    end;

    local procedure GetGSTValService(var AssVal: Decimal; var CgstVal: Decimal; var SgstVal: Decimal; var IgstVal: Decimal; var CesVal: Decimal; var StCesVal: Decimal; var CesNonAdval: Decimal; var Disc: Decimal; var OthChrg: Decimal; var TotInvVal: Decimal; var TotInvValFc: Decimal);
    var
        ServiceInvoiceLine: Record 5993;
        ServiceCrMemoLine: Record 5995;
        GSTLedgerEntry: Record "GST Ledger Entry";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        CurrExchRate: Record 330;
        CustLedgerEntry: Record 21;
        GSTComponent: Record "Tax Component";
        TotGSTAmt: Decimal;
        IsSEZorExported: Boolean;
        DemmedExport: Boolean;
        TotGSTAmtFc: Decimal;
        //B2BUPG1.0>> 
        CGSTValue: Decimal;
        SGSTValue: Decimal;
        IGSTValue: Decimal;
        CESSValue: Decimal;
    //B2BUPG1.0<<
    begin
        GSTLedgerEntry.SETRANGE("Entry Type", GSTLedgerEntry."Entry Type"::"Initial Entry");//BugFix
        GSTLedgerEntry.SETRANGE("Document No.", DocumentNo);

        IF IsServiceInvoice THEN BEGIN
            ServiceInvoiceLine.SETRANGE("Document No.", DocumentNo);
            ServiceInvoiceLine.SETFILTER(Quantity, '<>%1', 0);//BugFix
            IF ServiceInvoiceLine.FINDSET THEN
                REPEAT
                    AssVal += ServiceInvoiceLine.Amount;
                    //TotGSTAmt += ServiceInvoiceLine."Total GST Amount";
                    GetGSTValueForLine(ServiceInvoiceLine."Line No.", CGSTValue, SGSTValue, IGSTValue, CESSValue);
                    TotGSTAmt += CGSTValue + SGSTValue + IGSTValue + CESSValue;
                    //B2BUPG1.0<<
                    Disc += ServiceInvoiceLine."Inv. Discount Amount";
                    //OthChrg += SalesInvoiceLine."Charges To Customer" + SalesInvoiceLine."TDS/TCS Amount";//v1.03
                    //OthChrg += ServiceInvoiceLine."Charges To Customer"; //+ ServiceInvoiceLine."Total TDS/TCS Incl. SHE CESS";//v1.03
                    OthChrg := 0;
                UNTIL ServiceInvoiceLine.NEXT = 0;
        END ELSE BEGIN
            ServiceCrMemoLine.SETRANGE("Document No.", DocumentNo);
            ServiceCrMemoLine.SETFILTER(Quantity, '<>%1', 0);//BugFix
            IF ServiceCrMemoLine.FINDSET THEN
                REPEAT
                    AssVal += ServiceCrMemoLine.Amount;
                    //B2BUPG1.0>>
                    //TotGSTAmt += ServiceCrMemoLine."Total GST Amount";
                    GetGSTValueForLine(ServiceCrMemoLine."Line No.", CGSTValue, SGSTValue, IGSTValue, CESSValue);
                    TotGSTAmt += CGSTValue + SGSTValue + IGSTValue + CESSValue;
                    //B2BUPG1.0<<
                    Disc += ServiceCrMemoLine."Inv. Discount Amount";
                    //OthChrg += SalesCrMemoLine."Charges To Customer" + SalesCrMemoLine."TDS/TCS Amount";//v1.03
                    //OthChrg += ServiceCrMemoLine."Charges To Customer";// + ServiceCrMemoLine."Total TDS/TCS Incl SHE CESS";//v1.03
                    OthChrg := 0;
                UNTIL ServiceCrMemoLine.NEXT = 0;
        END;

        CesVal := 0;
        CesNonAdval := 0;
        GSTLedgerEntry.SETRANGE("GST Component Code", 'INTERCESS');
        IF GSTLedgerEntry.FINDSET THEN
            REPEAT
                CesVal += ABS(GSTLedgerEntry."GST Amount")
            UNTIL GSTLedgerEntry.NEXT = 0;

        DetailedGSTLedgerEntry.SETRANGE("Document No.", DocumentNo);
        DetailedGSTLedgerEntry.SETRANGE("GST Component Code", 'CESS');
        IF DetailedGSTLedgerEntry.FINDFIRST THEN
            REPEAT
                IF DetailedGSTLedgerEntry."GST %" > 0 THEN
                    CesVal += ABS(DetailedGSTLedgerEntry."GST Amount")
                ELSE
                    CesNonAdval += ABS(DetailedGSTLedgerEntry."GST Amount");
            UNTIL DetailedGSTLedgerEntry.NEXT = 0; //BugFixCess

        GSTLedgerEntry.SETFILTER("GST Component Code", '<>CGST&<>SGST&<>IGST&<>CESS&<>INTERCESS');//BugFix
        IF GSTLedgerEntry.FINDSET THEN BEGIN
            REPEAT
                IF GSTComponent.GET(GSTLedgerEntry."GST Component Code") THEN
                    //IF GSTComponent."Exclude from Reports" THEN
                    StCesVal += ABS(GSTLedgerEntry."GST Amount");
            UNTIL GSTLedgerEntry.NEXT = 0;
        END;

        IF IsServiceInvoice THEN BEGIN
            //CurrencyCode := SalesInvoiceHeader."Currency Code";
            //CurrencyFactor := SalesInvoiceHeader."Currency Factor";
            IsSEZorExported := ServiceInvoiceHeader."GST Customer Type" IN [ServiceInvoiceHeader."GST Customer Type"::"SEZ Development",
                                                                          ServiceInvoiceHeader."GST Customer Type"::"SEZ Unit",
                                                                          ServiceInvoiceHeader."GST Customer Type"::Export];//v1.03
            DemmedExport := ServiceInvoiceHeader."GST Customer Type" = ServiceInvoiceHeader."GST Customer Type"::"Deemed Export";//DEFIX
        END ELSE BEGIN
            //CurrencyCode := SalesCrMemoHeader."Currency Code";
            //CurrencyFactor := SalesCrMemoHeader."Currency Factor";
            IsSEZorExported := ServiceCrMemoHeader."GST Customer Type" IN [ServiceCrMemoHeader."GST Customer Type"::"SEZ Development",
                                                                          ServiceCrMemoHeader."GST Customer Type"::"SEZ Unit",
                                                                          ServiceCrMemoHeader."GST Customer Type"::Export];//v1.03
            DemmedExport := ServiceCrMemoHeader."GST Customer Type" = ServiceCrMemoHeader."GST Customer Type"::"Deemed Export";//DEFIX
        END;

        /*
        IF CesVal <> 0 THEN
          CesVal := ROUND(CurrExchRate.ExchangeAmtLCYToFCY(WORKDATE,CurrencyCode,CesVal,CurrencyFactor),1,'=');
        IF StCesVal <> 0 THEN
          StCesVal := ROUND(CurrExchRate.ExchangeAmtLCYToFCY(WORKDATE,CurrencyCode,StCesVal,CurrencyFactor),1,'=');
        IF CesNonAdval <> 0 THEN
          CesNonAdval := ROUND(CurrExchRate.ExchangeAmtLCYToFCY(WORKDATE,CurrencyCode,CesNonAdval,CurrencyFactor),1,'=');
        *///EXPFIX

        IgstVal := 0;
        CgstVal := 0;
        SgstVal := 0;

        //EXPFIX >>
        TotGSTAmtFc := TotGSTAmt; //DEFIX
        IF TotGSTAmt <> 0 THEN
            TotGSTAmt := ROUND(
                      CurrExchRate.ExchangeAmtFCYToLCY(
                      WORKDATE, CurrCode, TotGSTAmt, CurrFactor), 0.01, '=');
        //EXPFIX <<
        TotGSTAmt := TotGSTAmt - (CesVal + StCesVal + CesNonAdval);//v1.03

        GSTLedgerEntry.SETRANGE("GST Component Code");
        IF GSTLedgerEntry.FINDSET THEN
            CASE GSTLedgerEntry."GST Component Code" OF
                'IGST':
                    IgstVal := TotGSTAmt;
                'CGST', 'SGST':
                    BEGIN
                        CgstVal := TotGSTAmt / 2;
                        SgstVal := TotGSTAmt / 2;
                    END;
            END;

        CustLedgerEntry.SETCURRENTKEY("Document No.");
        CustLedgerEntry.SETRANGE("Document No.", DocumentNo);
        IF IsServiceInvoice THEN BEGIN
            CustLedgerEntry.SETRANGE("Document Type", CustLedgerEntry."Document Type"::Invoice);
            CustLedgerEntry.SETRANGE("Customer No.", ServiceInvoiceHeader."Bill-to Customer No.");
        END ELSE BEGIN
            CustLedgerEntry.SETRANGE("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
            CustLedgerEntry.SETRANGE("Customer No.", ServiceCrMemoHeader."Bill-to Customer No.");
        END;
        IF CustLedgerEntry.FINDFIRST THEN BEGIN
            CustLedgerEntry.CALCFIELDS(Amount);
            //>>v1.03
            TotInvVal := ABS(CustLedgerEntry.Amount);
            //EXPFIX >>

            IF TotInvVal <> 0 THEN
                TotInvVal := ROUND(
                           CurrExchRate.ExchangeAmtFCYToLCY(
                           WORKDATE, CurrCode, TotInvVal, CurrFactor), 0.01, '=');

            //DEFIX >>
            IF DemmedExport THEN
                TotInvVal := TotInvVal + TotGSTAmt + (CesVal + StCesVal + CesNonAdval);
            //DEFIX <<

            TotInvValFc := ABS(CustLedgerEntry.Amount);
            //DEFIX >>
            IF DemmedExport THEN
                TotInvValFc := ABS(CustLedgerEntry.Amount) + TotGSTAmtFc;
            //DEFIX <<

            IF IsSEZorExported THEN BEGIN
                TotInvVal += TotGSTAmt + (CesVal + StCesVal + CesNonAdval);//v1.03
                TotInvValFc := ABS(CustLedgerEntry.Amount) + ROUND(CurrExchRate.ExchangeAmtLCYToFCY(WORKDATE,
                                                                  CurrCode, TotGSTAmt, CurrFactor), 0.01, '=')
                               + ROUND(CurrExchRate.ExchangeAmtLCYToFCY(WORKDATE,
                                                                  CurrCode, CesVal, CurrFactor), 0.01, '=')
                               + ROUND(CurrExchRate.ExchangeAmtLCYToFCY(WORKDATE,
                                                                  CurrCode, StCesVal, CurrFactor), 0.01, '=')
                               + ROUND(CurrExchRate.ExchangeAmtLCYToFCY(WORKDATE,
                                                                  CurrCode, CesNonAdval, CurrFactor), 0.01, '=');


            END;
            //EXPFIX <<
            //<<v1.03
        END;

        //EXPFIX >>
        IF AssVal <> 0 THEN
            AssVal := ROUND(
                      CurrExchRate.ExchangeAmtFCYToLCY(
                      WORKDATE, CurrCode, AssVal, CurrFactor), 0.01, '=');

        IF Disc <> 0 THEN
            Disc := ROUND(
                      CurrExchRate.ExchangeAmtFCYToLCY(
                      WORKDATE, CurrCode, Disc, CurrFactor), 0.01, '=');

        IF OthChrg <> 0 THEN
            OthChrg := ROUND(
                      CurrExchRate.ExchangeAmtFCYToLCY(
                      WORKDATE, CurrCode, OthChrg, CurrFactor), 0.01, '=');
        //EXPFIX <<

    end;

    local procedure GetInvRoundingAccService(): Code[20];
    var
        CustomerPostingGroup: Record 92;
        CustPosGrpCode: Code[20];
    begin
        IF IsServiceInvoice THEN
            CustPosGrpCode := ServiceInvoiceHeader."Customer Posting Group"
        ELSE
            CustPosGrpCode := ServiceCrMemoHeader."Customer Posting Group";
        IF CustPosGrpCode = '' THEN
            EXIT('');
        CustomerPostingGroup.GET(CustPosGrpCode);
        EXIT(CustomerPostingGroup."Invoice Rounding Account");
    end;

    //B2BUPG1.0>> 
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

    local procedure GetRndOffAmtService(): Decimal;
    var
        ServiceInvoiceLine: Record 5993;
        ServiceCrMemoLine: Record 5995;
    begin
        IF IsServiceInvoice THEN BEGIN
            ServiceInvoiceLine.SETRANGE("Document No.", ServiceInvoiceHeader."No.");
            //ServiceInvoiceLine.SETFILTER("No.", '%1|%2', GetInvRoundingAccService, GetGSTRoundingAccService);
            ServiceInvoiceLine.SETFILTER("No.", '%1', GetInvRoundingAccService);
            ServiceInvoiceLine.CALCSUMS(Amount);
            EXIT(ServiceInvoiceLine.Amount);
        END ELSE BEGIN
            ServiceCrMemoLine.SETRANGE("Document No.", ServiceCrMemoHeader."No.");
            //ServiceCrMemoLine.SETFILTER("No.", '%1|%2', GetInvRoundingAccService, GetGSTRoundingAccService);
            ServiceCrMemoLine.SETFILTER("No.", '%1', GetInvRoundingAccService);
            ServiceCrMemoLine.CALCSUMS(Amount);
            EXIT(ServiceCrMemoLine.Amount);
        END;
    end;

    procedure CancelEInvoiceService(Variant: Variant): Boolean;
    var
        CancelServiceInvHdr: Record 5992;
        CancelServiceCrMHdr: Record 5994;
        RecRef: RecordRef;
        //  [RunOnClient]
        //Windows: DotNet Interaction;
        CancelReason: Text;
        ReasonRemarks: Text;
        EInvoiceEntry: Record "E-Invoice Entry";
        EInvCancelUpdate: Page "E-Invoice Update Window";
    begin
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            5992:
                CancelServiceInvHdr := Variant;
            5994:
                CancelServiceCrMHdr := Variant;
        END;
        //CancelReason := Windows.InputBox('Cancellation Reason :','Reason','',10,10);//Test
        //B2BUPG1.0>>
        //IF NOT OpenWindow(CancelReason, ReasonRemarks) THEN
        //    EXIT(FALSE);
        Clear(EInvCancelUpdate);
        Commit();
        if EInvCancelUpdate.RunModal() = Action::Yes then
            EInvCancelUpdate.GetData(CancelReason, ReasonRemarks);
        //B2BUPG1.0<<

        IF CancelServiceInvHdr."No." <> '' THEN
            EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Invoice", CancelServiceInvHdr."No.")
        ELSE
            EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Cr. Memo", CancelServiceCrMHdr."No.");

        DocumentNo := EInvoiceEntry."Document No.";

        EInvoiceEntry."IRN Cancelled Reason" := CancelReason;
        EInvoiceEntry."IRN Cancelled Remarks" := ReasonRemarks;
        EInvoiceEntry."IRN Cancelled By" := USERID;
        EInvoiceEntry.MODIFY;
        if (CancelReason = '') or (ReasonRemarks = '') then
            exit(false);
        JObJCancelG.Add('Irn', EInvoiceEntry."IRN No.");
        JObJCancelG.Add('CnlRsn', CancelReason);
        JObJCancelG.Add('CnlRem', ReasonRemarks);
        EInvoiceLog.INIT;
        IF CancelServiceInvHdr."No." <> '' THEN
            EInvoiceLog."Document Type" := EInvoiceLog."Document Type"::Invoice
        ELSE
            EInvoiceLog."Document Type" := EInvoiceLog."Document Type"::"Credit Memo";
        EInvoiceLog."Document No." := DocumentNo;
        EInvoiceLog."Request Path" := JsonRequestPath;
        EInvoiceLog.Cancel := TRUE;
        EInvoiceLog.INSERT(true);
        EXIT(TRUE);
    end;

    local procedure "---E-INVB2CService---"();

    begin

    end;

    procedure GenerateFormatForB2CService(Variant: Variant);
    var
        SuppGSTIN: Code[15];
        SuppUPIID: Text;
        InvDate: Text[10];


        CompanyInfo: Record 79;
        PayeeBankAcc: Text[30];
        PayeeIFSCCode: Code[11];
        LocRec: Record 14;
        AssVal: Decimal;
        CgstVal: Decimal;
        SgstVal: Decimal;
        IgstVal: Decimal;
        CesVal: Decimal;
        StCesVal: Decimal;
        CesNonAdval: Decimal;
        Disc: Decimal;
        OthChrg: Decimal;
        TotInvVal: Decimal;
        RndOffAmt: Decimal;
        TotInvValFc: Decimal;
        PayeeBankACTxt: Label 'Payee''s Bank A/C';
        PayeeBankIFSCTxt: Label 'Payee''s Bank IFSC';
    begin


        CLEAR(CurrCode);
        CLEAR(CurrFactor);

        CompanyInfo.GET;
        PayeeBankAcc := CompanyInfo."Bank Account No.";
        //PayeeIFSCCode := CompanyInfo."Payee Bank IFSC Code";

        IF IsServiceInvoice THEN BEGIN
            DocumentNo := ServiceInvoiceHeader."No.";
            CurrCode := ServiceInvoiceHeader."Currency Code";
            CurrFactor := ServiceInvoiceHeader."Currency Factor";
            SuppGSTIN := ServiceInvoiceHeader."Location GST Reg. No.";
            InvDate := FORMAT(ServiceInvoiceHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>');
            LocRec.GET(ServiceInvoiceHeader."Location Code");
        END ELSE BEGIN
            DocumentNo := ServiceCrMemoHeader."No.";
            CurrCode := ServiceCrMemoHeader."Currency Code";
            CurrFactor := ServiceCrMemoHeader."Currency Factor";
            SuppGSTIN := ServiceCrMemoHeader."Location GST Reg. No.";
            InvDate := FORMAT(ServiceCrMemoHeader."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>');
            LocRec.GET(ServiceCrMemoHeader."Location Code");
        END;
        //SuppUPIID := LocRec."Supplier UPI ID";

        GetGSTVal(AssVal, CgstVal, SgstVal, IgstVal, CesVal, StCesVal, CesNonAdval, Disc, OthChrg, TotInvVal, TotInvValFc);

        //B2B>>
        JObjVerG.Add('Supplier GSTIN', SuppGSTIN);
        JObjVerG.Add('Supplier UPI ID', SuppUPIID);
        JObjVerG.Add('PayeeBankACTxt', PayeeBankIFSCTxt);
        JObjVerG.Add('PayeeBankIFSCTxt', PayeeBankIFSCTxt);
        JObjVerG.Add('Invoice number', DocumentNo);
        JObjVerG.Add('Invoice Date', InvDate);
        JObjVerG.Add('Total Invoice Value', TotInvVal);
        if CgstVal <> 0 then
            JObjVerG.Add('CgstVal', CgstVal)
        else
            JObjVerG.Add('CgstVal', JVOBJG.AsToken());
        if SgstVal <> 0 then
            JObjVerG.Add('SgstVal', SgstVal)
        else
            JObjVerG.Add('SgstVal', JVOBJG.AsToken());
        if IgstVal <> 0 then
            JObjVerG.Add('IgstVal', IgstVal)
        else
            JObjVerG.Add('IgstVal', JVOBJG.AsToken());
        if CesVal <> 0 then
            JObjVerG.Add('CesVal', CesVal)
        else
            JObjVerG.Add('CesVal', JVOBJG.AsToken());
        if StCesVal <> 0 then
            JObjVerG.Add('StCesVal', StCesVal)
        else
            JObjVerG.Add('StCesVal', StCesVal);
        if CesNonAdval <> 0 then
            JObjVerG.Add('CesNonAdval', CesNonAdval)
        else
            JObjVerG.Add('CesNonAdval', JVOBJG.AsToken());
        //B2B<<

    end;
    //B2BUPGSERVICE1.0<< Service Orders
    //B2BSaas Body>>
    procedure JSONFormat(var JsonFile: Text)
    begin
        JObjVerG.WriteTo(JsonFile);
    end;
    //B2BSaas Body<<
    procedure JSONcanFormat(var JsonFile: Text)
    begin
        JObJCancelG.WriteTo(JsonFile);
    end;

}
