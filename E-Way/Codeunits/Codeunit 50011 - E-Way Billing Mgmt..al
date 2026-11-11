codeunit 50011 "E-Way Billing Mgmt."
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
        EWayBillingSetup.GET();
        ProcessWebRequest();
    end;

    var
        AccessCode: Label 'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzY29wZSI6WyJnc3AiXSwiZXhwIjoxNTg0NDE4Nzk0LCJhdXRob3JpdGllcyI6WyJST0xFX1NCX0VfQVBJX0dTVF9SRVRVUk5TIiwiUk9MRV9TQl9FX0FQSV9FSSIsIlJPTEVfU0JfRV9BUElfRVdCIl0sImp0aSI6ImQ1OGViMWVjLWZkMmEtNDk0Ny1hZThkLWMyNjIwOGYwMjljMCIsImNsaWVudF9pZCI6IkJDQzUzRkU4MEVEODQyN0E5RDY1RkNFMEIwRjk0MTNEIn0.7xcDOseH1qbkEwvYOeA3O3tAncPH9vDeWxVWa5QxjhZ8';
        RequestType: Option Eway,Vehicle,EWayCancel,RejectEway,ExtendValidity,UpdateTrasporter,AccessToken,Pin2Pin; //PIN2PIN
        EWayBillingSetup: Record "E-Way Billing Setup";
        RequestID: Code[20];
        RequestGUID: Text;
        Status: Option Success,Failed;
        SalesShipHead: Record "Sales Shipment Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        FailureMsg: Label '%1 failed with Message :';
        MessageTxt: Text;
        IsInvoice: Boolean;
        IsPosting: Boolean;
        PurchHeader: Record "Purchase Header";
        WarehouseRectHead: Record "Warehouse Receipt Header";
        EWayBillingEntry: Record "E-Way Billing Entry";
        SalesCreditHeader: Record "Sales Cr.Memo Header";

        IsEWayApplicable: Boolean;
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        TransferShipmentHeader: Record "Transfer Shipment Header";
        SalesHeaderGRec: Record "Sales Header"; //PIN2PIN
        HttpRequestMessageG: HttpRequestMessage;
        HttpResponseMessageG: HttpResponseMessage;
        HttpHeadersG: HttpHeaders;
        HttpClientG: HttpClient;
        HttpContentG: HttpContent;
        HeadersG: HttpHeaders;
        JobjG: JsonObject;
        ResponseG: Text;
        ExpiresInG: Integer;
        JTokenGAc: JsonToken;
        JTokenExp: JsonToken;



    procedure ProcessWebRequest()
    var
        SuccessMsg: Label 'E-Way Bill Generated Successfully';
    begin
        IF EWayBillingSetup."GSP Priority" = EWayBillingSetup."GSP Priority"::Adequre THEN BEGIN
            CASE RequestType OF
                RequestType::Eway:
                    BEGIN
                        IF NOT CreateWebRequest(EWayBillingSetup."E-Way Request URL") THEN
                            //  IF NOT CreateMIWebRequest(EWayBillingSetup."MI E-Way Request URL") THEN
                            UpdateEwayLog(RequestID, '', '', Status::Failed, GETLASTERRORTEXT, FALSE);
                    END;
                RequestType::Vehicle:
                    BEGIN
                        IF NOT CreateWebRequest(EWayBillingSetup."Vehicle Request URL") THEN
                            //IF NOT CreateMIWebRequest(EWayBillingSetup."MI Vehicle Request URL") THEN
                                UpdateEwayLog(RequestID, '', '', Status::Failed, GETLASTERRORTEXT, FALSE);
                    END;
                RequestType::EWayCancel:
                    BEGIN
                        IF NOT CreateWebRequest(EWayBillingSetup."E-Way Cancel URL") THEN
                            //IF NOT CreateMIWebRequest(EWayBillingSetup."MI E-Way Cancel URL") THEN
                                UpdateEwayLog(RequestID, '', '', Status::Failed, GETLASTERRORTEXT, FALSE);
                    END;
                RequestType::RejectEway:
                    BEGIN
                        IF NOT CreateWebRequest(EWayBillingSetup."E-Way Reject URL") THEN
                            //  IF NOT CreateMIWebRequest(EWayBillingSetup."MI E-Way Reject URL") THEN
                            UpdateEwayLog(RequestID, '', '', Status::Failed, GETLASTERRORTEXT, FALSE);
                    END;
                RequestType::ExtendValidity:
                    BEGIN
                        IF NOT CreateWebRequest(EWayBillingSetup."Extend Validity URL") THEN
                            // IF NOT CreateMIWebRequest(EWayBillingSetup."MI Extend Validity URL") THEN
                            UpdateEwayLog(RequestID, '', '', Status::Failed, GETLASTERRORTEXT, FALSE);
                    END;
                RequestType::UpdateTrasporter:
                    BEGIN
                        IF NOT CreateWebRequest(EWayBillingSetup."Update Transporter URL") THEN
                            // IF NOT CreateMIWebRequest(EWayBillingSetup."MI Update Transporter URL") THEN
                            UpdateEwayLog(RequestID, '', '', Status::Failed, GETLASTERRORTEXT, FALSE);
                    END;
                //PIN2PIN>>
                RequestType::Pin2Pin:
                    begin
                        if not GeneratePin2PinDistance(EWayBillingSetup."Pin 2 Pin Distance URL") then
                            UpdateEwayLog(RequestID, '', '', Status::Failed, GETLASTERRORTEXT, FALSE);
                    end;
            //PIN2PIN
            END;
        END ELSE
            IF EWayBillingSetup."GSP Priority" = EWayBillingSetup."GSP Priority"::MI THEN BEGIN
                CASE RequestType OF
                    RequestType::Eway:
                        BEGIN
                            IF NOT CreateMIWebRequest(EWayBillingSetup."MI E-Way Request URL") THEN
                                UpdateEwayLog(RequestID, '', '', Status::Failed, GETLASTERRORTEXT, FALSE);
                            //IF NOT CreateWebRequest(EWayBillingSetup."E-Way Request URL") THEN

                        END;
                    RequestType::Vehicle:
                        BEGIN
                            IF NOT CreateMIWebRequest(EWayBillingSetup."MI Vehicle Request URL") THEN
                                UpdateEwayLog(RequestID, '', '', Status::Failed, GETLASTERRORTEXT, FALSE);
                            //IF NOT CreateWebRequest(EWayBillingSetup."Vehicle Request URL") THEN

                        END;
                    RequestType::EWayCancel:
                        BEGIN
                            IF NOT CreateMIWebRequest(EWayBillingSetup."MI E-Way Cancel URL") THEN
                                //  IF NOT CreateWebRequest(EWayBillingSetup."E-Way Cancel URL") THEN
                                UpdateEwayLog(RequestID, '', '', Status::Failed, GETLASTERRORTEXT, FALSE);
                        END;
                    RequestType::RejectEway:
                        BEGIN
                            IF NOT CreateMIWebRequest(EWayBillingSetup."MI E-Way Reject URL") THEN
                                // IF NOT CreateWebRequest(EWayBillingSetup."E-Way Reject URL") THEN
                                UpdateEwayLog(RequestID, '', '', Status::Failed, GETLASTERRORTEXT, FALSE);
                        END;
                    RequestType::ExtendValidity:
                        BEGIN
                            IF NOT CreateMIWebRequest(EWayBillingSetup."MI Extend Validity URL") THEN
                                // IF NOT CreateWebRequest(EWayBillingSetup."Extend Validity URL") THEN
                                UpdateEwayLog(RequestID, '', '', Status::Failed, GETLASTERRORTEXT, FALSE);
                        END;
                    RequestType::UpdateTrasporter:
                        BEGIN
                            IF NOT CreateMIWebRequest(EWayBillingSetup."MI Update Transporter URL") THEN
                                // IF NOT CreateWebRequest(EWayBillingSetup."Update Transporter URL") THEN
                                UpdateEwayLog(RequestID, '', '', Status::Failed, GETLASTERRORTEXT, FALSE);
                        END;
                END;
            END;

        IF MessageTxt = '' THEN
            MessageTxt := GETLASTERRORTEXT;

        IF Status = Status::Failed THEN
            MESSAGE(FailureMsg, FORMAT(RequestType), MessageTxt)
        ELSE BEGIN
            IF IsPosting AND (RequestType = RequestType::Vehicle)
            AND (EWayBillingSetup."E-Way Bill Generation Type" = EWayBillingSetup."E-Way Bill Generation Type"::"Man.& Transport") THEN
                MESSAGE(MessageTxt)
            ELSE
                MESSAGE(MessageTxt);
        END;
    end;

    //B2BUPG1.0>>
    //[TryFunction] 
    //local procedure CreateWebRequest(RequestUrl: Text)
    local procedure CreateWebRequest(RequestUrl: Text): Boolean
    //B2BUPG1.0<<
    var
        FileManagement: Codeunit "File Management";
        InStr: InStream;
        TempBlob: Codeunit "Temp Blob";
        JSONText: Text;
        AttachmentOutstream: OutStream;
        RequestPath: Text;
        ResponsePath: Text;
        NoSeriesMgmt: Codeunit NoSeriesManagement;
        RequestSentMsg: Label 'Request Sent';
        RejectEwayBillNo: BigInteger;
        Location: Record Location;
        EWayJson: Codeunit "E-Way Adequre Json Generator";
        RequestTypeLVar: Option Eway,Vehicle,EWayCancel,RejectEway,ExtendValidity,UpdateTrasporter,AccessToken,Pin2Pin; //PIN2PIN
    begin
        IF GenerateToken THEN BEGIN
            //PIN2PIN>>
            If EWayBillingSetup."Distance Calculation" = EWayBillingSetup."Distance Calculation"::Automatic then begin
                RequestTypeLVar := RequestType;
                RequestType := RequestType::Pin2Pin;
                GeneratePin2PinDistance(EWayBillingSetup."Pin 2 Pin Distance URL");
                RequestType := RequestTypeLVar;
            end;
            //PIN2PIN<<
            IF RequestType <> RequestType::RejectEway THEN BEGIN
                IF SalesInvoiceHeader."No." <> '' THEN
                    RequestID := SalesInvoiceHeader."No."
                ELSE
                    IF SalesShipHead."No." <> '' THEN
                        RequestID := SalesShipHead."No."
                    ELSE
                        IF PurchHeader."No." <> '' THEN
                            RequestID := PurchHeader."Vendor Shipment No."
                        ELSE
                            IF WarehouseRectHead."No." <> '' THEN
                                RequestID := WarehouseRectHead."No."
                            ELSE
                                IF SalesCreditHeader."No." <> '' THEN
                                    RequestID := SalesCreditHeader."No."
                                ELSE
                                    IF PurchCrMemoHdr."No." <> '' THEN
                                        RequestID := PurchCrMemoHdr."No."
                                    ELSE
                                        IF TransferShipmentHeader."No." <> '' THEN
                                            RequestID := TransferShipmentHeader."No.";

                InsertEwayEntry();
                //CheckFilePathExists(RequestPath, ResponsePath, RequestID);
                RequestGUID := CREATEGUID;

                IF SalesInvoiceHeader."No." <> '' THEN BEGIN
                    EWayJson.SetSalesInvHeader(SalesInvoiceHeader, RequestType, IsPosting);
                    EWayJson.RUN;
                    EWayJson.InitJSONRequest(JSONText);
                    Location.GET(SalesInvoiceHeader."Location Code");
                END ELSE
                    IF SalesShipHead."No." <> '' THEN BEGIN
                        EWayJson.SetSalesShipHeader(SalesShipHead, RequestType, IsPosting);
                        EWayJson.RUN;
                        EWayJson.InitJSONRequest(JSONText);
                        Location.GET(SalesShipHead."Location Code");
                    END ELSE
                        IF PurchHeader."No." <> '' THEN BEGIN
                            EWayJson.SetPurchHeader(PurchHeader, RequestType, IsPosting);
                            EWayJson.RUN;
                            EWayJson.InitJSONRequest(JSONText);
                            Location.GET(PurchHeader."Location Code");
                        END ELSE
                            IF WarehouseRectHead."No." <> '' THEN BEGIN
                                EWayJson.SetWhseHeader(WarehouseRectHead, RequestType, IsPosting);
                                EWayJson.RUN;
                                EWayJson.InitJSONRequest(JSONText);
                                Location.GET(WarehouseRectHead."Location Code");
                            END ELSE
                                IF SalesCreditHeader."No." <> '' THEN BEGIN
                                    EWayJson.SetSalesCrdHeader(SalesCreditHeader, RequestType, IsPosting);
                                    EWayJson.RUN;
                                    EWayJson.InitJSONRequest(JSONText);
                                    Location.GET(SalesCreditHeader."Location Code");
                                END ELSE
                                    IF PurchCrMemoHdr."No." <> '' THEN BEGIN
                                        EWayJson.SetPurchCrdHeader(PurchCrMemoHdr, RequestType, IsPosting);
                                        EWayJson.RUN;
                                        EWayJson.InitJSONRequest(JSONText);
                                        Location.GET(PurchCrMemoHdr."Location Code");
                                    END ELSE
                                        IF TransferShipmentHeader."No." <> '' THEN BEGIN
                                            EWayJson.SetTransOrderHeader(TransferShipmentHeader, RequestType, IsPosting);
                                            EWayJson.RUN;
                                            EWayJson.InitJSONRequest(JSONText);
                                            Location.GET(TransferShipmentHeader."Transfer-from Code");
                                        END;
            END ELSE BEGIN
                EWayBillingSetup.TESTFIELD("Reject E-Way No. Series");
                RequestID := NoSeriesMgmt.GetNextNo(EWayBillingSetup."Reject E-Way No. Series", TODAY, TRUE);
                RequestGUID := CREATEGUID;
                EWayJson.InvRejectEwayJson(RequestID, RejectEwayBillNo);
            END;

            /*  HttpWebRequest := HttpWebRequest.Create(RequestUrl);
              HttpWebRequest.Method := 'POST';
              HttpWebRequest.ContentType('application/json');
              HttpWebRequest.Headers.Add('username', Location."User Name");
              HttpWebRequest.Headers.Add('password', Location.Password);
              HttpWebRequest.Headers.Add('gstin', Location."GST Registration No.");//Location."GST Registration No."
              HttpWebRequest.Headers.Add('requestid', RequestGUID);
              HttpWebRequest.Headers.Add('Authorization', 'Bearer ' + EWayBillingSetup."Access Token" + EWayBillingSetup."Access Token 2");

              FileStream := FileStream.FileStream(RequestPath, FileMode.Open);
              FileStream.CopyTo(HttpWebRequest.GetRequestStream);
              UpdateEwayLog(RequestID, RequestPath, ResponsePath, Status::Success, RequestSentMsg, FALSE);

              HttpWebResponse := HttpWebRequest.GetResponse();
              InStr := HttpWebResponse.GetResponseStream;

              IF HttpWebResponse.StatusCode <> 200 THEN
                  EXIT;*/
            Clear(HttpRequestMessageG);
            Clear(HttpClientG);
            Clear(HttpContentG);
            Clear(HttpHeadersG);
            Clear(HeadersG);
            Clear(HttpResponseMessageG);
            HttpRequestMessageG.SetRequestUri(RequestUrl);
            HttpRequestMessageG.Method := 'POST';
            HeadersG := HttpClientG.DefaultRequestHeaders;
            HeadersG.Add('username', Location."User Name");
            HeadersG.Add('password', Location.Password);
            HeadersG.Add('gstin', Location."GST Registration No.");
            HeadersG.Add('requestid', RequestGUID);
            HeadersG.Add('Authorization', 'bearer ' + EWayBillingSetup."Access Token" + EWayBillingSetup."Access Token 2");
            HttpContentG.GetHeaders(HttpHeadersG);
            HttpHeadersG.Clear();
            HttpHeadersG.Add('Content-Type', 'application/json');
            HttpContentG.WriteFrom(JSONText);//Attcah Body      
            HttpRequestMessageG.Content := HttpContentG;
            HttpClientG.Send(HttpRequestMessageG, HttpResponseMessageG);
            HttpResponseMessageG.Content().ReadAs(ResponseG);
            if not HttpResponseMessageG.IsSuccessStatusCode then
                exit(false);
            UpdateEwayLog(RequestID, JSONText, ResponseG, Status::Success, RequestSentMsg, FALSE);

            CLEAR(TempBlob);


            //B2BUPG1.0>>
            //TempBlob.EXPORT(ResponsePath);

            //B2BUPG1.0<<

            IF NOT ReadResponse(ResponseG, RequestID) THEN
                UpdateEwayLog(RequestID, '', '', Status::Failed, GETLASTERRORTEXT, TRUE);
            COMMIT;
            //B2BUPG1.0>>
            //END;
            exit(true);
        end else
            exit(false);
        //B2BUPG1.0<<
    end;

    local procedure GenerateToken(): Boolean
    var
        FileManagement: Codeunit "File Management";

        TempBlob: Codeunit "Temp Blob";
        AttachmentOutstream: OutStream;
        InStr: InStream;
        RequestPath: Text;
        ResponsePath: Text;
        AccessTokenDocNo: Code[20];
        AccessToken: Text;
        Input: Text;
        Result: Text;
        t: Record 36;
    begin
        EWayBillingSetup.GET;
        IF EWayBillingSetup."Access Token Expiry Date" <> 0DT THEN
            IF EWayBillingSetup."Access Token Expiry Date" > CURRENTDATETIME THEN
                EXIT(TRUE);

        RequestGUID := CREATEGUID;
        // AccessCodeDll := AccessCodeDll.GenerateAccessToken();
        //AccessCodeDll.AccessToken(Input, Result, AccessToken);
        HeadersG := HttpClientG.DefaultRequestHeaders;
        HeadersG.Add('gspappid', EWayBillingSetup."Client ID");
        HttpRequestMessageG.GetHeaders(HeadersG);
        HeadersG.Clear();
        HeadersG.Add('gspappsecret', EWayBillingSetup."Client Secret");
        HttpRequestMessageG.SetRequestUri('https://gsp.adaequare.com/gsp/authenticate?grant_type=token');
        HttpRequestMessageG.Method := 'POST';
        HttpRequestMessageG.Content := HttpContentG;
        HttpClientG.Send(HttpRequestMessageG, HttpResponseMessageG);
        HttpResponseMessageG.Content.ReadAs(ResponseG);
        JobjG := ReadJSONAcctoken(ResponseG);
        JobjG.Get('access_token', JTokenGAc);
        AccessToken := JTokenGAc.AsValue().AsText();
        JobjG.Get('expires_in', JTokenExp);
        ExpiresInG := JTokenExp.AsValue().AsInteger();

        AccessTokenDocNo := 'Acktkn_' + DELCHR(FORMAT(TODAY), '=', '/\_*^@');

        //CheckFilePathExists(RequestPath, ResponsePath, AccessTokenDocNo);

        //B2BUPG1.0>>

        //TempBlob.EXPORT(ResponsePath);
        //FileManagement.BLOBExportToServerFile(TempBlob, ResponsePath);
        //B2BUPG1.0<<
        EWayBillingSetup."Access Token Expiry Date" := GetTokenExpiryFromResponse(TempBlob);
        EWayBillingSetup."Access Token Date" := CURRENTDATETIME;
        EWayBillingSetup."Access Token" := COPYSTR(AccessToken, 1, 250);
        EWayBillingSetup."Access Token 2" := COPYSTR(AccessToken, 251, 500);
        EWayBillingSetup.MODIFY;

        UpdateEwayLog(AccessTokenDocNo, '', ResponseG, Status::Success, 'Access Token Generated', TRUE);
        EXIT(TRUE);
    end;



    //B2BUPG1.0>>
    //[TryFunction]
    //procedure ReadResponse(TempBlob: Codeunit "Temp Blob"; RequestID: Code[20])
    procedure ReadResponse(ResponseL: Text; RequestID: Code[20]): Boolean
    //B2BUPG1.0<<
    var

        Success: Boolean;
        JsonText: Text;
        ResponseValue: Variant;
        ValidUpto: DateTime;
        EWayBillDate: DateTime;
        EWayBillNo: BigInteger;
        vehUpdDate: DateTime;
        CancelDate: DateTime;
        EwayRejectDate: DateTime;
        UpdatedDate: DateTime;
        TransporterID: Text;
        TransUpdateDate: DateTime;
        Status: Option Success,Failed;
        //B2BUPPG1.0>>
        InstreamL: InStream;
        OutstreamL: OutStream;
        //B2BUPPG1.0<<

        //PIN2PIN>>
        FromPin: Integer;
        ToPin: Integer;
        PinDistance: Decimal;
        AccDistance: Decimal;
        JSONOBJL: JsonObject;
        JSTokenRes: JsonToken;
        messageL: Text;
        JSONOBJ2: JsonObject;
        JSTOken2: JsonToken;
        EWayBillNoT: Text;
        validUptoT: Text;
        vehUpdDateT: Text;
        cancelDateT: Text;
        EwayRejectDateT: Text;
        UpdatedDateT: Text;
        TransUpdateDateT: Text;
    //PIN2PIN<<
    begin


        JSONOBJL := ReadJson(ResponseL);

        if JSONOBJL.Get('success', JSTokenRes) then
            Success := JSTokenRes.AsValue().AsBoolean();
        Clear(JSTokenRes);

        JSONOBJL.Get('message', JSTokenRes);
        MessageTxt := JSTokenRes.AsValue().AsText();
        Clear(JSTokenRes);

        IF Success THEN BEGIN
            JSONOBJL.Get('result', JSTokenRes);
            JSTokenRes.WriteTo(JsonText);
            JSONOBJ2.ReadFrom(JsonText);
            CLEAR(ResponseValue);
            CASE RequestType OF
                RequestType::Eway:
                    BEGIN
                        JSONOBJ2.Get('ewayBillNo', JSTOken2);
                        EWayBillNo := JSTOken2.AsValue().AsBigInteger();
                        Clear(JSTOken2);
                        JSONOBJ2.Get('ewayBillDate', JSTOken2);
                        EWayBillNot := JSTOken2.AsValue().AsText();
                        EWayBillDate := GetDateTimeFromText(EWayBillNot);
                        Clear(JSTOken2);
                        JSONOBJ2.Get('validUpto', JSTOken2);
                        validUptoT := JSTOken2.AsValue().AsText();
                        ValidUpto := GetDateTimeFromText(validUptoT);

                    END;
                RequestType::Vehicle:
                    BEGIN
                        JSONOBJ2.Get('vehUpdDate', JSTOken2);
                        vehUpdDateT := JSTOken2.AsValue().AsText();
                        vehUpdDate := GetDateTimeFromText(vehUpdDateT);
                        Clear(JSTOken2);
                        JSONOBJ2.Get('validUpto', JSTOken2);
                        validUptoT := JSTOken2.AsValue().AsText();
                        ValidUpto := GetDateTimeFromText(validUptoT);
                    END;
                RequestType::EWayCancel:
                    BEGIN
                        JSONOBJ2.Get('ewayBillNo', JSTOken2);
                        EWayBillNo := JSTOken2.AsValue().AsBigInteger();
                        Clear(JSTOken2);
                        JSONOBJ2.Get('cancelDate', JSTOken2);
                        CancelDateT := JSTOken2.AsValue().AsText();
                        CancelDate := GetDateTimeFromText(CancelDateT);
                    END;
                RequestType::RejectEway:
                    BEGIN
                        JSONOBJ2.Get('ewayBillNo', JSTOken2);
                        EWayBillNo := JSTOken2.AsValue().AsBigInteger();
                        Clear(JSTOken2);
                        JSONOBJ2.Get('ewbRejectedDate', JSTOken2);
                        EwayRejectDateT := JSTOken2.AsValue().AsText();
                        EwayRejectDate := GetDateTimeFromText(EwayRejectDateT);
                    END;
                RequestType::ExtendValidity:
                    BEGIN
                        JSONOBJ2.Get('ewayBillNo', JSTOken2);
                        EWayBillNo := JSTOken2.AsValue().AsBigInteger();
                        Clear(JSTOken2);
                        JSONOBJ2.Get('validUpto', JSTOken2);
                        UpdatedDateT := JSTOken2.AsValue().AsText();
                        UpdatedDate := GetDateTimeFromText(UpdatedDateT);
                        Clear(JSTOken2);
                        JSONOBJ2.Get('validUpto', JSTOken2);
                        validUptoT := JSTOken2.AsValue().AsText();
                        ValidUpto := GetDateTimeFromText(validUptoT);
                    END;
                RequestType::UpdateTrasporter:
                    BEGIN
                        JSONOBJ2.Get('ewayBillNo', JSTOken2);
                        EWayBillNo := JSTOken2.AsValue().AsBigInteger();
                        Clear(JSTOken2);
                        JSONOBJ2.Get('transporterId', JSTOken2);
                        TransporterID := JSTOken2.AsValue().AsText();
                        Clear(JSTOken2);
                        JSONOBJ2.Get('transUpdateDate', JSTOken2);
                        TransUpdateDateT := JSTOken2.AsValue().AsText();
                        TransUpdateDate := GetDateTimeFromText(TransUpdateDateT);
                    END;
                //PIN2PIN>>
                RequestType::Pin2Pin:
                    begin
                        JSONOBJ2.Get('from', JSTOken2);
                        FromPin := JSTOken2.AsValue().AsInteger();
                        Clear(JSTOken2);
                        JSONOBJ2.Get('to', JSTOken2);
                        ToPin := JSTOken2.AsValue().AsInteger();
                        Clear(JSTOken2);
                        JSONOBJ2.Get('distance', JSTOken2);
                        PinDistance := JSTOken2.AsValue().AsDecimal();
                        Clear(JSTOken2);
                        JSONOBJ2.Get('accurateDistance', JSTOken2);
                        AccDistance := JSTOken2.AsValue().AsDecimal();
                        MessageTxt := 'Distance Calculated.';
                        Clear(JSTOken2);
                    end;
            //PIN2PIN<<
            END;
            UpdateResponse(EWayBillNo, ValidUpto, EWayBillDate, vehUpdDate, CancelDate, EwayRejectDate,
                          UpdatedDate, TransporterID, TransUpdateDate, FromPin, ToPin, PinDistance, AccDistance); //PIN2PIN

            UpdateEwayLog(RequestID, '', '', Status::Success, MessageTxt, TRUE);
            exit(true) //B2BUPG1.0
        END ELSE begin
            UpdateEwayLog(RequestID, '', '', Status::Failed, MessageTxt, FALSE);
            exit(false); //B2BUPG1.0
        end;
    end;

    local procedure GetDateTimeFromText(DateTimeText: Text): DateTime
    var
        DateText: Text;
        Day: Integer;
        Month: Integer;
        Year: Integer;
        RetTime: Time;
    begin
        DateText := COPYSTR(DateTimeText, 1, 10);
        EVALUATE(Day, COPYSTR(DateText, 1, 2));
        EVALUATE(Month, COPYSTR(DateText, 4, 2));
        EVALUATE(Year, COPYSTR(DateText, 7, 4));
        EVALUATE(RetTime, COPYSTR(DateTimeText, STRLEN(DateText) + 2, STRLEN(DateTimeText) - 3));
        EXIT(CREATEDATETIME(DMY2DATE(Day, Month, Year), RetTime));
    end;



    local procedure UpdateEwayLog(DocumentNo: Code[20]; RequestL: Text; ResponseL: Text; Staus: Option Success,Failed; Message: Text; Finished: Boolean)
    var
        EwsLog: Record "E-Way Integration Log";
        InsertNewLog: Boolean;
        Outstr: OutStream;
        Ins: InStream;
        FileName: Text;
    begin
        /* EwsLog.RESET;
         EwsLog.SETRANGE("Document No.", DocumentNo);
         EwsLog.SETRANGE("Request Type", RequestType);
         IF SalesInvoiceHeader."No." <> '' THEN
             EwsLog.SETRANGE("Document Type", EwsLog."Document Type"::Invoice)
         ELSE
             IF SalesShipHead."No." <> '' THEN
                 EwsLog.SETRANGE("Document Type", EwsLog."Document Type"::Shipment)
             ELSE
                 IF PurchHeader."No." <> '' THEN
                     EwsLog.SETRANGE("Document Type", EwsLog."Document Type"::Invoice);
         IF NOT EwsLog.FINDLAST THEN
             InsertNewLog := TRUE;*/

        //IF InsertNewLog THEN BEGIN
        EwsLog.INIT;
        EwsLog."Document No." := DocumentNo;
        IF SalesInvoiceHeader."No." <> '' THEN BEGIN
            EwsLog."Transaction Type" := EwsLog."Transaction Type"::Sales;
            EwsLog."Document Type" := EwsLog."Document Type"::Invoice
        END ELSE
            IF SalesShipHead."No." <> '' THEN BEGIN
                EwsLog."Transaction Type" := EwsLog."Transaction Type"::Sales;
                EwsLog."Document Type" := EwsLog."Document Type"::Shipment
            END ELSE
                IF PurchHeader."No." <> '' THEN BEGIN
                    EwsLog."Transaction Type" := EwsLog."Transaction Type"::Purchase;
                    EwsLog.SETRANGE("Document Type", EwsLog."Document Type"::Invoice);
                END;
        EwsLog.INSERT;


        IF Message <> '' THEN
            EwsLog."Request/Response Code" := COPYSTR(Message, 1, 250);
        EwsLog.Status := Staus;
        if RequestL <> '' then begin
            EwsLog."JSON Request Blob".CreateOutStream(OutStr);
            OutStr.WriteText(RequestL);
            // if EwsLog."JSON Request Blob".HasValue then begin
            //     EwsLog."JSON Request Blob".CreateInStream(Ins);
            //     FileName := DocumentNo + '.json';
            //     DownloadFromStream(Ins, '', '', '', FileName);
            // end;
        end;
        if ResponseL <> '' then begin
            EwsLog."JSON Response Blob".CreateOutStream(OutStr);
            OutStr.WriteText(ResponseL);

        end;
        EwsLog."Request GUID" := RequestGUID;

        EwsLog."Request Type" := RequestType;
        EwsLog."Date & Time" := CURRENTDATETIME();
        EwsLog."User Id" := USERID();
        EwsLog.Finished := Finished;
        EwsLog.MODIFY;
    end;

    procedure SetDocument(Variant: Variant; RequestTypePar: Option Eway,Vehicle,EWayCancel,RejectEway,ExtendValidity,UpdateTrasporter,AccessToken,Pin2Pin; IsPostingPar: Boolean) //PIN2PIN
    var
        RecRef: RecordRef;
        ShipHeadTemp: Record "Sales Shipment Header";
        InvHeadTemp: Record "Sales Invoice Header";
        PurchHeadTemp: Record "Purchase Header";
        WhseeRectHeaderTemp: Record "Warehouse Receipt Header";
        SalesCredMemoTemp: Record "Sales Cr.Memo Header";
        PurchCrMemoHdrTemp: Record "Purch. Cr. Memo Hdr.";
        TransferShipmentHeaderTemp: Record "Transfer Shipment Header";
        SalesHeaderTemp: Record "Sales Header";
    begin
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            110:
                BEGIN
                    ShipHeadTemp := Variant;
                    SalesShipHead.RESET;
                    SalesShipHead.SETRANGE("No.", ShipHeadTemp."No.");
                    IF SalesShipHead.FINDFIRST THEN;
                END;
            112:
                BEGIN
                    InvHeadTemp := Variant;
                    SalesInvoiceHeader.RESET;
                    SalesInvoiceHeader.SETRANGE("No.", InvHeadTemp."No.");
                    IF SalesInvoiceHeader.FINDFIRST THEN;
                END;
            38:
                BEGIN
                    PurchHeadTemp := Variant;
                    PurchHeader.RESET;
                    PurchHeader.SETRANGE("No.", PurchHeadTemp."No.");
                    IF PurchHeader.FINDFIRST THEN;
                END;
            7316:
                BEGIN
                    WhseeRectHeaderTemp := Variant;
                    WarehouseRectHead.RESET;
                    WarehouseRectHead.SETRANGE("No.", WhseeRectHeaderTemp."No.");
                    IF WarehouseRectHead.FINDFIRST THEN;
                END;
            114:
                BEGIN
                    SalesCredMemoTemp := Variant;
                    SalesCreditHeader.RESET;
                    SalesCreditHeader.SETRANGE("No.", SalesCredMemoTemp."No.");
                    IF SalesCreditHeader.FINDFIRST THEN;
                END;
            124:
                BEGIN
                    PurchCrMemoHdrTemp := Variant;
                    PurchCrMemoHdr.RESET;
                    PurchCrMemoHdr.SETRANGE("No.", PurchCrMemoHdrTemp."No.");
                    IF PurchCrMemoHdr.FINDFIRST THEN;
                END;
            5744:
                BEGIN
                    TransferShipmentHeaderTemp := Variant;
                    TransferShipmentHeader.RESET;
                    TransferShipmentHeader.SETRANGE("No.", TransferShipmentHeaderTemp."No.");
                    IF TransferShipmentHeader.FINDFIRST THEN;
                END;
            //PIN2PIN>>
            36:
                begin
                    SalesHeaderTemp := Variant;
                    SalesHeaderGRec.Reset();
                    SalesHeaderGRec.SetRange("Document Type", SalesHeaderTemp."Document Type");
                    SalesHeaderGRec.SetRange("No.", SalesHeaderTemp."No.");
                    if SalesHeaderGRec.FindFirst() then;
                end;
        //PIN2PIN<<
        END;
        RequestType := RequestTypePar;
        IsPosting := IsPostingPar;
    end;

    procedure InsertEwayEntry()
    var
        LocationRec: Record Location;
    begin
        EWayBillingEntry.RESET;
        IF SalesInvoiceHeader."No." <> '' THEN
            EWayBillingEntry.SETRANGE("Transaction Type", EWayBillingEntry."Transaction Type"::"Sales Invoice")
        ELSE
            IF SalesShipHead."No." <> '' THEN
                EWayBillingEntry.SETRANGE("Transaction Type", EWayBillingEntry."Transaction Type"::"Sales Shpt")
            ELSE
                IF PurchHeader."No." <> '' THEN
                    EWayBillingEntry.SETRANGE("Transaction Type", EWayBillingEntry."Transaction Type"::"Purch. Order")
                ELSE
                    IF WarehouseRectHead."No." <> '' THEN
                        EWayBillingEntry.SETRANGE("Transaction Type", EWayBillingEntry."Transaction Type"::"Whse. Rect")
                    ELSE
                        IF SalesCreditHeader."No." <> '' THEN
                            EWayBillingEntry.SETRANGE("Transaction Type", EWayBillingEntry."Transaction Type"::"Sales Crd Memo")
                        ELSE
                            IF PurchCrMemoHdr."No." <> '' THEN
                                EWayBillingEntry.SETRANGE("Transaction Type", EWayBillingEntry."Transaction Type"::"Purch. Crd Memo")
                            //PIN2PIN>>
                            else
                                if SalesHeaderGRec."No." <> '' then
                                    EWayBillingEntry.SetRange("Transaction Type", EWayBillingEntry."Transaction Type"::"Pin 2 Pin");
        //PIN2PIN<<
        EWayBillingEntry.SETRANGE("Document No.", RequestID);
        IF NOT EWayBillingEntry.FINDFIRST THEN BEGIN
            EWayBillingEntry.INIT;
            EWayBillingEntry."Document No." := RequestID;
            IF SalesInvoiceHeader."No." <> '' THEN
                EWayBillingEntry."Transaction Type" := EWayBillingEntry."Transaction Type"::"Sales Invoice"
            ELSE
                IF SalesShipHead."No." <> '' THEN
                    EWayBillingEntry."Transaction Type" := EWayBillingEntry."Transaction Type"::"Sales Shpt"
                ELSE
                    IF PurchHeader."No." <> '' THEN
                        EWayBillingEntry."Transaction Type" := EWayBillingEntry."Transaction Type"::"Purch. Order"
                    ELSE
                        IF WarehouseRectHead."No." <> '' THEN
                            EWayBillingEntry."Transaction Type" := EWayBillingEntry."Transaction Type"::"Whse. Rect"
                        ELSE
                            IF SalesCreditHeader."No." <> '' THEN
                                EWayBillingEntry."Transaction Type" := EWayBillingEntry."Transaction Type"::"Sales Crd Memo"
                            ELSE
                                IF PurchCrMemoHdr."No." <> '' THEN
                                    EWayBillingEntry."Transaction Type" := EWayBillingEntry."Transaction Type"::"Purch. Crd Memo"
                                ELSE
                                    IF TransferShipmentHeader."No." <> '' THEN
                                        EWayBillingEntry."Transaction Type" := EWayBillingEntry."Transaction Type"::"Transfer Order"
                                    //PIN2PIN>>
                                    else
                                        if SalesHeaderGRec."No." <> '' then
                                            EWayBillingEntry."Transaction Type" := EWayBillingEntry."Transaction Type"::"Pin 2 Pin";
            //PIN2PIN<<
            EWayBillingEntry.INSERT;
        END;
    end;

    local procedure "--------------------------MI---------------------------------"()
    begin
    end;

    procedure GenerateTokenMI(): Boolean
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        AttachmentOutstream: OutStream;
        InStr: InStream;
        Requestbody: Text;
        AccessTokenDocNo: Code[20];
        AccessToken: Text;
        EWayMIJsonGenerator: Codeunit "E-Way MI Json Generator";
        JSONText: Text;
    begin
        EWayBillingSetup.GET;
        IF EWayBillingSetup."MI Access Token Expiry Date" <> 0D THEN
            IF EWayBillingSetup."MI Access Token Expiry Date" > TODAY THEN
                EXIT(TRUE);

        /*   HttpWebRequest := HttpWebRequest.Create('https://clientbasic.mastersindia.co/oauth/access_token');
           HttpWebRequest.Method := 'POST';
           HttpWebRequest.ContentType := 'application/json';
           AccessTokenDocNo := 'Acktkn_' + DELCHR(FORMAT(TODAY), '=', '/\_*^@');
           CheckFilePathExists(RequestPath, ResponsePath, AccessTokenDocNo);
           RequestPath := EWayMIJsonGenerator.MIAccessTokenJson();

           FileStream := FileStream.FileStream(RequestPath, FileMode.Open);
           FileStream.CopyTo(HttpWebRequest.GetRequestStream);

           HttpWebResponse := HttpWebRequest.GetResponse();
           InStr := HttpWebResponse.GetResponseStream;*/
        EWayMIJsonGenerator.MIAccessTokenJson();
        EWayMIJsonGenerator.AccessTokenJSON(JSONText);
        HttpContentG.WriteFrom(JSONText);//Attcah Body   
        HttpContentG.GetHeaders(HttpHeadersG);
        HttpHeadersG.Remove('Content-Type');
        HttpHeadersG.Add('Content-Type', 'application/json');
        HttpRequestMessageG.Method := 'POST';
        HttpRequestMessageG.SetRequestUri('https://clientbasic.mastersindia.co/oauth/access_token');
        HttpRequestMessageG.Content(HttpContentG);
        HttpClientG.Send(HttpRequestMessageG, HttpResponseMessageG);
        HttpResponseMessageG.Content.ReadAs(ResponseG);
        JobjG := ReadJSONAcctoken(ResponseG);
        JobjG.Get('access_token', JTokenGAc);
        AccessToken := JTokenGAc.AsValue().AsText();
        JobjG.Get('expires_in', JTokenExp);
        ExpiresInG := JTokenExp.AsValue().AsInteger();

        RequestGUID := CREATEGUID;

        // Requestbody := EWayMIJsonGenerator.MIAccessTokenJson;

        // AccessToken := ReadAckTknResponse(TempBlob);

        EWayBillingSetup."MI Access Token Expiry Date" := CALCDATE(EWayBillingSetup."Access Token Period", TODAY);
        EWayBillingSetup."MI Access Token Date" := CURRENTDATETIME;
        EWayBillingSetup."MI Access Token" := COPYSTR(AccessToken, 1, 250);
        EWayBillingSetup."MI Access Token 2" := COPYSTR(AccessToken, 251, 500);
        EWayBillingSetup.MODIFY;

        UpdateEwayLog(AccessTokenDocNo, Requestbody, ResponseG, Status::Success, 'Access Token Generated', TRUE);
        EXIT(TRUE);
    end;

    //B2BUPG1.0>>
    //[TryFunction]
    //local procedure CreateMIWebRequest(RequestUrl: Text)
    local procedure CreateMIWebRequest(RequestUrl: Text): Boolean
    ////B2BUPG1.0<<
    var
        FileManagement: Codeunit "File Management";
        InStr: InStream;
        TempBlob: Codeunit "Temp Blob";
        AttachmentOutstream: OutStream;
        RequestPath: Text;
        ResponsePath: Text;
        NoSeriesMgmt: Codeunit NoSeriesManagement;
        RequestSentMsg: Label 'Request Sent';
        RejectEwayBillNo: BigInteger;
        Location: Record Location;
        EWayJson: Codeunit "E-Way MI Json Generator";
        JSONText: Text;
    begin
        IF (SalesInvoiceHeader."No." = '') AND (SalesShipHead."No." = '') AND (PurchHeader."No." = '') AND (WarehouseRectHead."No." = '')
                  AND (SalesCreditHeader."No." = '') AND (PurchCrMemoHdr."No." = '') AND (TransferShipmentHeader."No." = '') THEN
            EXIT;
        IF GenerateTokenMI THEN BEGIN
            IF RequestType <> RequestType::RejectEway THEN BEGIN
                IF SalesInvoiceHeader."No." <> '' THEN
                    RequestID := SalesInvoiceHeader."No."
                ELSE
                    IF SalesShipHead."No." <> '' THEN
                        RequestID := SalesShipHead."No."
                    ELSE
                        IF PurchHeader."No." <> '' THEN
                            RequestID := PurchHeader."Vendor Shipment No."
                        ELSE
                            IF WarehouseRectHead."No." <> '' THEN
                                RequestID := WarehouseRectHead."No."
                            ELSE
                                IF SalesCreditHeader."No." <> '' THEN
                                    RequestID := SalesCreditHeader."No."
                                ELSE
                                    IF PurchCrMemoHdr."No." <> '' THEN
                                        RequestID := PurchCrMemoHdr."No."
                                    ELSE
                                        IF TransferShipmentHeader."No." <> '' THEN
                                            RequestID := TransferShipmentHeader."No.";
                InsertEwayEntry();
                RequestGUID := CREATEGUID;
                IF SalesInvoiceHeader."No." <> '' THEN BEGIN
                    EWayJson.SetSalesInvHeader(SalesInvoiceHeader, RequestType, IsPosting);
                    EWayJson.RUN;
                    EWayJson.InitJSONRequest(JSONText);
                    Location.GET(SalesInvoiceHeader."Location Code");
                END ELSE
                    IF SalesShipHead."No." <> '' THEN BEGIN
                        EWayJson.SetSalesShipHeader(SalesShipHead, RequestType, IsPosting);
                        EWayJson.RUN;
                        EWayJson.InitJSONRequest(JSONText);
                        Location.GET(SalesShipHead."Location Code");
                    END ELSE
                        IF PurchHeader."No." <> '' THEN BEGIN
                            EWayJson.SetPurchHeader(PurchHeader, RequestType, IsPosting);
                            EWayJson.RUN;
                            EWayJson.InitJSONRequest(JSONText);
                            Location.GET(PurchHeader."Location Code");
                        END ELSE
                            IF WarehouseRectHead."No." <> '' THEN BEGIN
                                EWayJson.SetWhseHeader(WarehouseRectHead, RequestType, IsPosting);
                                EWayJson.RUN;
                                EWayJson.InitJSONRequest(JSONText);
                                Location.GET(WarehouseRectHead."Location Code");
                            END ELSE
                                IF SalesCreditHeader."No." <> '' THEN BEGIN
                                    EWayJson.SetSalesCrdHeader(SalesCreditHeader, RequestType, IsPosting);
                                    EWayJson.RUN;
                                    EWayJson.InitJSONRequest(JSONText);
                                    Location.GET(SalesCreditHeader."Location Code");
                                END ELSE
                                    IF PurchCrMemoHdr."No." <> '' THEN BEGIN
                                        EWayJson.SetPurchCrdHeader(PurchCrMemoHdr, RequestType, IsPosting);
                                        EWayJson.RUN;
                                        EWayJson.InitJSONRequest(JSONText);
                                        Location.GET(PurchCrMemoHdr."Location Code");
                                    END ELSE
                                        IF TransferShipmentHeader."No." <> '' THEN BEGIN
                                            EWayJson.SetTransOrderHeader(TransferShipmentHeader, RequestType, IsPosting);
                                            EWayJson.RUN;
                                            EWayJson.InitJSONRequest(JSONText);
                                            Location.GET(TransferShipmentHeader."Transfer-from Code");
                                        END;
            END ELSE BEGIN
                EWayBillingSetup.TESTFIELD("Reject E-Way No. Series");
                RequestID := NoSeriesMgmt.GetNextNo(EWayBillingSetup."Reject E-Way No. Series", TODAY, TRUE);
                RequestGUID := CREATEGUID;
                EWayJson.InvRejectEwayJson(RequestID, RejectEwayBillNo);
            END;

            /*  HttpWebRequest := HttpWebRequest.Create(RequestUrl);
              HttpWebRequest.Method := 'POST';
              HttpWebRequest.ContentType('application/json');

              FileStream := FileStream.FileStream(RequestPath, FileMode.Open);
              FileStream.CopyTo(HttpWebRequest.GetRequestStream);

              UpdateEwayLog(RequestID, RequestPath, ResponsePath, Status::Success, RequestSentMsg, FALSE);

              HttpWebResponse := HttpWebRequest.GetResponse();
              InStr := HttpWebResponse.GetResponseStream;

              IF HttpWebResponse.StatusCode <> 200 THEN
                  EXIT;*/
            Clear(HttpContentG);
            Clear(HttpHeadersG);
            Clear(HttpRequestMessageG);
            Clear(HttpResponseMessageG);
            Clear(HttpClientG);
            Clear(ResponseG);
            HttpContentG.WriteFrom(JSONText);//Attcah Body  
            HttpContentG.GetHeaders(HttpHeadersG);
            HttpHeadersG.Remove('Content-Type');
            HttpHeadersG.Add('Content-Type', 'application/json');
            HttpRequestMessageG.Method := 'POST';
            HttpRequestMessageG.SetRequestUri(RequestUrl);
            HttpRequestMessageG.Content(HttpContentG);
            HttpClientG.Send(HttpRequestMessageG, HttpResponseMessageG);
            HttpResponseMessageG.Content().ReadAs(ResponseG);


            // HttpRequestMessageG.SetRequestUri(RequestUrl);
            // HttpRequestMessageG.Method := 'POST';
            // HttpContentG.GetHeaders(HttpHeadersG);
            // HttpHeadersG.Remove('Content-Type');
            // HttpHeadersG.Add('Content-Type', 'application/json');
            // HttpContentG.WriteFrom(JSONText);//Attcah Body                                        
            // HttpRequestMessageG.Content := HttpContentG;
            // HttpClientG.Send(HttpRequestMessageG, HttpResponseMessageG);
            // HttpResponseMessageG.Content().ReadAs(ResponseG);


            UpdateEwayLog(RequestID, JSONText, ResponseG, Status::Success, RequestSentMsg, FALSE);
            if not HttpResponseMessageG.IsSuccessStatusCode then
                exit(false);
            IF NOT ReadMIResponse(ResponseG, RequestID) THEN;
            UpdateEwayLog(RequestID, '', '', Status::Failed, GETLASTERRORTEXT, TRUE);
            COMMIT;
            //B2BUPG1.0>>
            //END;
            exit(true);
        END else
            exit(false);
        //B2BUPG1.0<<
    end;

    //B2BUPG1.0>>
    //[TryFunction]
    //procedure ReadMIResponse(TempBlob: Codeunit "Temp Blob"; RequestID: Code[20])
    procedure ReadMIResponse(ResponseL: Text; RequestID: Code[20]): Boolean
    //B2BUPG1.0<<
    var

        Success: Boolean;
        JsonText: Text;
        ResponseValue: Variant;
        ValidUpto: DateTime;
        EWayBillDate: DateTime;
        EWayBillNo: BigInteger;
        vehUpdDate: DateTime;
        CancelDate: DateTime;
        EwayRejectDate: DateTime;
        UpdatedDate: DateTime;
        TransporterID: Text;
        TransUpdateDate: DateTime;
        Status: Option Success,Failed;
        StatusTxt: Text;
        InstreamL: InStream;
        OutstreamL: OutStream;
        JSONOBJL: JsonObject;
        JSTokenRes: JsonToken;
        messageL: Text;
        JSONOBJ2: JsonObject;
        JSTOken2: JsonToken;
        EWayBillNoT: Text;
        validUptoT: Text;
        vehUpdDateT: Text;
        cancelDateT: Text;
        EwayRejectDateT: Text;
        UpdatedDateT: Text;
        TransUpdateDateT: Text;
        JSONOBJ3: JsonObject;
    begin
        JSONOBJL := ReadJson(ResponseL);
        JSONOBJL.Get('results', JSTokenRes);
        JSTokenRes.WriteTo(JsonText);
        JSONOBJ2.ReadFrom(JsonText);

        if JSONOBJ2.Get('status', JSTokenRes) then
            StatusTxt := JSTokenRes.AsValue().AsText();
        Clear(JSTokenRes);

        IF StatusTxt = 'Success' THEN BEGIN
            JSONOBJ2.Get('message', JSTokenRes);
            JSTokenRes.WriteTo(JsonText);
            JSONOBJ3.ReadFrom(JsonText);
            MessageTxt := 'E-way Bill Generated Successfully';
            CLEAR(ResponseValue);
            CASE RequestType OF
                RequestType::Eway:
                    BEGIN
                        JSONOBJ3.Get('ewayBillNo', JSTOken2);
                        EWayBillNo := JSTOken2.AsValue().AsBigInteger();
                        Clear(JSTOken2);
                        JSONOBJ3.Get('ewayBillDate', JSTOken2);
                        EWayBillNot := JSTOken2.AsValue().AsText();
                        EWayBillDate := GetDateTimeFromText(EWayBillNot);
                        Clear(JSTOken2);
                        JSONOBJ3.Get('validUpto', JSTOken2);
                        validUptoT := JSTOken2.AsValue().AsText();
                        ValidUpto := GetDateTimeFromText(validUptoT);

                    END;
                RequestType::Vehicle:
                    BEGIN
                        JSONOBJ3.Get('vehUpdDate', JSTOken2);
                        vehUpdDateT := JSTOken2.AsValue().AsText();
                        vehUpdDate := GetDateTimeFromText(vehUpdDateT);
                        Clear(JSTOken2);
                        JSONOBJ3.Get('validUpto', JSTOken2);
                        validUptoT := JSTOken2.AsValue().AsText();
                        ValidUpto := GetDateTimeFromText(validUptoT);
                    END;
                RequestType::EWayCancel:
                    BEGIN
                        JSONOBJ3.Get('ewayBillNo', JSTOken2);
                        EWayBillNo := JSTOken2.AsValue().AsBigInteger();
                        Clear(JSTOken2);
                        JSONOBJ3.Get('cancelDate', JSTOken2);
                        CancelDateT := JSTOken2.AsValue().AsText();
                        CancelDate := GetDateTimeFromText(CancelDateT);
                    END;
                RequestType::RejectEway:
                    BEGIN
                        JSONOBJ3.Get('ewayBillNo', JSTOken2);
                        EWayBillNo := JSTOken2.AsValue().AsBigInteger();
                        Clear(JSTOken2);
                        JSONOBJ3.Get('ewbRejectedDate', JSTOken2);
                        EwayRejectDateT := JSTOken2.AsValue().AsText();
                        EwayRejectDate := GetDateTimeFromText(EwayRejectDateT);
                    END;
                RequestType::ExtendValidity:
                    BEGIN
                        JSONOBJ3.Get('ewayBillNo', JSTOken2);
                        EWayBillNo := JSTOken2.AsValue().AsBigInteger();
                        Clear(JSTOken2);
                        JSONOBJ3.Get('validUpto', JSTOken2);
                        UpdatedDateT := JSTOken2.AsValue().AsText();
                        UpdatedDate := GetDateTimeFromText(UpdatedDateT);
                        Clear(JSTOken2);
                        JSONOBJ3.Get('validUpto', JSTOken2);
                        validUptoT := JSTOken2.AsValue().AsText();
                        ValidUpto := GetDateTimeFromText(validUptoT);
                    END;
                RequestType::UpdateTrasporter:
                    BEGIN
                        JSONOBJ3.Get('ewayBillNo', JSTOken2);
                        EWayBillNo := JSTOken2.AsValue().AsBigInteger();
                        Clear(JSTOken2);
                        JSONOBJ3.Get('transporterId', JSTOken2);
                        TransporterID := JSTOken2.AsValue().AsText();
                        Clear(JSTOken2);
                        JSONOBJ3.Get('transUpdateDate', JSTOken2);
                        TransUpdateDateT := JSTOken2.AsValue().AsText();
                        TransUpdateDate := GetDateTimeFromText(TransUpdateDateT);
                    END;
            END;

            UpdateResponse(EWayBillNo, ValidUpto, EWayBillDate, vehUpdDate, CancelDate, EwayRejectDate,
                          UpdatedDate, TransporterID, TransUpdateDate, 0, 0, 0, 0); //PIN2PIN


            UpdateEwayLog(RequestID, '', '', Status::Success, MessageTxt, TRUE);
            exit(true); //B2BUPG1.0
        END ELSE BEGIN
            JSONOBJ2.Get('message', JSTokenRes);
            MessageTxt := JSTokenRes.AsValue().AsText();
            Clear(JSTokenRes);
            UpdateEwayLog(RequestID, '', '', Status::Failed, MessageTxt, FALSE);
            exit(false); //B2BUPG1.0
        END;
    end;

    local procedure UpdateResponse(EWayBillNo: BigInteger; ValidUpto: DateTime; EWayBillDate: DateTime; vehUpdDate: DateTime; CancelDate: DateTime; EwayRejectDate: DateTime; UpdatedDate: DateTime; TransporterID: Text; TransUpdateDate: DateTime;
                                    FromPin: Integer; ToPin: Integer; Distance: Decimal; AccDistance: Decimal)
    var
        EmptyDatetim: DateTime;
        EwsLog: Record "E-Way Integration Log";
        PurchHeaderLRec: Record "Purchase Header"; //PIN2PIN
        WhseRectLine: Record "Warehouse Receipt Line"; //PIN2PIN
    begin
        CASE RequestType OF
            RequestType::Eway:
                BEGIN
                    IF SalesInvoiceHeader."No." <> '' THEN BEGIN
                        SalesInvoiceHeader."E-Way Bill No." := FORMAT(EWayBillNo);
                        SalesInvoiceHeader.MODIFY;
                    END;
                    IF SalesShipHead."No." <> '' THEN BEGIN
                        SalesShipHead."E-Way Bill No." := FORMAT(EWayBillNo);
                        SalesShipHead.MODIFY;
                    END;
                    IF SalesCreditHeader."No." <> '' THEN BEGIN
                        SalesCreditHeader."E-Way Bill No." := FORMAT(EWayBillNo);
                        SalesCreditHeader.MODIFY;
                    END;
                    EWayBillingEntry."E-Way Bill No." := EWayBillNo;
                    EWayBillingEntry."E-Way Bill Date" := EWayBillDate;
                    EWayBillingEntry."E-Way Valid Upto" := ValidUpto;
                    EWayBillingEntry.MODIFY;
                END;
            RequestType::Vehicle:
                BEGIN
                    EWayBillingEntry."Vechicle Updation Date" := vehUpdDate;
                    EWayBillingEntry."Vechicle Valid Upto" := ValidUpto;
                    EWayBillingEntry.MODIFY;
                END;
            RequestType::EWayCancel:
                BEGIN
                    EWayBillingEntry."E-Way Cancel Date" := CancelDate;
                    EWayBillingEntry.MODIFY;
                END;
            RequestType::RejectEway:
                BEGIN
                    EwsLog.RESET;
                    EwsLog.SETRANGE("Document No.", RequestID);
                    EwsLog.SETRANGE("Request Type", RequestType);
                    IF EwsLog.FINDLAST THEN BEGIN
                        EwsLog."Reject E-Way Bill No" := EWayBillNo;
                        EwsLog."Rejected Date" := EwayRejectDate;
                        EwsLog.MODIFY;
                    END;
                END;
            RequestType::ExtendValidity:
                BEGIN
                    EWayBillingEntry."Ext Validity Upd. Date" := UpdatedDate;
                    EWayBillingEntry."Ext Validity Valid Upto" := ValidUpto;
                    EWayBillingEntry.MODIFY;
                END;
            RequestType::UpdateTrasporter:
                BEGIN
                    EWayBillingEntry."Transporter ID" := TransporterID;
                    EWayBillingEntry."Trns. Updated Date" := TransUpdateDate;
                    EWayBillingEntry.MODIFY;
                END;
            //PIN2PIN>>
            RequestType::Pin2Pin:
                begin
                    IF SalesInvoiceHeader."No." <> '' THEN BEGIN
                        SalesInvoiceHeader."Distance (Km)" := Distance;
                        SalesInvoiceHeader.MODIFY;
                    END else
                        if SalesHeaderGRec."No." <> '' then begin
                            SalesHeaderGRec."Distance (Km)" := Distance;
                            SalesHeaderGRec.Modify;
                        end else
                            IF SalesShipHead."No." <> '' THEN BEGIN
                                SalesShipHead."Distance (Km)" := Distance;
                                SalesShipHead.MODIFY;
                            END else
                                IF SalesCreditHeader."No." <> '' THEN BEGIN
                                    SalesCreditHeader."Distance (Km)" := Distance;
                                    SalesCreditHeader.MODIFY;
                                END else
                                    if PurchHeader."No." <> '' then begin
                                        PurchHeader."Distance (Km)" := Distance;
                                        PurchHeader.Modify();
                                    end else
                                        if PurchCrMemoHdr."No." <> '' then begin
                                            PurchCrMemoHdr."Distance (Km)" := Distance;
                                            PurchCrMemoHdr.Modify();
                                        end else
                                            if TransferShipmentHeader."No." <> '' then begin
                                                TransferShipmentHeader."Distance (Km)" := Distance;
                                                TransferShipmentHeader.Modify();
                                            end else
                                                if WarehouseRectHead."No." <> '' then begin
                                                    WhseRectLine.RESET;
                                                    WhseRectLine.SETRANGE("No.", WareHouseRectHead."No.");
                                                    IF WhseRectLine.FINDFIRST THEN begin
                                                        PurchHeaderLRec.GET(PurchHeaderLRec."Document Type"::Order, WhseRectLine."Source No.");
                                                        PurchHeaderLRec."Distance (Km)" := Distance;
                                                        PurchHeaderLRec.Modify();
                                                    end;
                                                end;
                    EWayBillingEntry."From Pin" := FromPin;
                    EWayBillingEntry."To Pin" := ToPin;
                    EWayBillingEntry.Distance := Distance;
                    EWayBillingEntry.MODIFY;
                end;
        //PIN2PIN<<

        END;
        IF SalesInvoiceHeader."No." <> '' THEN
            UpdateEWayEntryInvResponseInShipment(SalesInvoiceHeader)
        ELSE
            IF SalesShipHead."No." <> '' THEN
                UpdateEWayEntryShipResponseInWhse(SalesShipHead);
    end;

    local procedure UpdateEWayEntryInvResponseInShipment(SalesInvHeader: Record "Sales Invoice Header")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesShipmentHeader: Record "Sales Shipment Header";
        EWayEntry: Record "E-Way Billing Entry";
        PrevShipment: Code[20];
    begin
        SalesInvoiceLine.RESET;
        SalesInvoiceLine.SETCURRENTKEY("Shipment No.");
        SalesInvoiceLine.SETRANGE("Document No.", SalesInvHeader."No.");
        SalesInvoiceLine.SETFILTER("Shipment No.", '<>%1', '');
        IF SalesInvoiceLine.FINDSET THEN BEGIN
            REPEAT
                SalesShipHead.GET(SalesInvoiceLine."Shipment No.");
                IF PrevShipment <> SalesShipHead."No." THEN BEGIN
                    IF NOT EWayEntry.GET(EWayEntry."Transaction Type"::"Sales Shpt", SalesShipHead."No.") THEN BEGIN
                        EWayEntry.INIT;
                        EWayEntry.TRANSFERFIELDS(EWayBillingEntry);
                        EWayEntry."Document No." := SalesShipHead."No.";
                        EWayEntry."Transaction Type" := EWayEntry."Transaction Type"::"Sales Shpt";
                        EWayEntry.INSERT;
                    END ELSE BEGIN
                        EWayEntry.TRANSFERFIELDS(EWayBillingEntry);
                        EWayEntry.MODIFY;
                    END;
                    PrevShipment := SalesShipHead."No.";
                END;
            UNTIL SalesInvoiceLine.NEXT = 0;
        END;
    end;

    local procedure UpdateEWayEntryShipResponseInWhse(SalesShipHead: Record "Sales Shipment Header")
    var
        SalesShipLine: Record "Sales Shipment Line";
        WhseShipmentHead: Record "Posted Whse. Shipment Header";
        WhseShipLine: Record "Posted Whse. Shipment Line";
        EWayEntry: Record "E-Way Billing Entry";
    begin

        WhseShipLine.RESET;
        WhseShipLine.SETRANGE("Posted Source Document", WhseShipLine."Posted Source Document"::"Posted Shipment");
        WhseShipLine.SETRANGE("Posted Source No.", SalesShipHead."No.");
        IF WhseShipLine.FINDSET THEN BEGIN
            WhseShipmentHead.GET(WhseShipLine."No.");
            IF NOT EWayEntry.GET(EWayEntry."Transaction Type"::"Whse. Shipment", WhseShipmentHead."No.") THEN BEGIN
                EWayEntry.INIT;
                EWayEntry.TRANSFERFIELDS(EWayBillingEntry);
                EWayEntry."Document No." := WhseShipmentHead."No.";
                EWayEntry."Transaction Type" := EWayEntry."Transaction Type"::"Whse. Shipment";
                EWayEntry.INSERT;
            END ELSE BEGIN
                EWayEntry.TRANSFERFIELDS(EWayBillingEntry);
                EWayEntry."Document No." := WhseShipmentHead."No.";
                EWayEntry."Transaction Type" := EWayEntry."Transaction Type"::"Whse. Shipment";
                EWayEntry.MODIFY;
            END;
        END;
    end;

    local procedure "------------------EWBSales-----------------"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnBeforePostSalesDoc', '', false, false)]
    procedure CheckEwayAtSalesPost(var SalesHeader: Record "Sales Header")
    begin
        CheckEWayBillType(SalesHeader);
        IF IsEWayApplicable THEN
            SalesHeader."E-Way Bill No." := '1';
    end;

    local procedure CheckEWayBillType(SalesHeader: Record "Sales Header")
    var
        EWayValidator: Codeunit "E-Way Validator";
        RequestType: Option Eway,Vehicle,EWayCancel,RejectEway,ExtendValidity,UpdateTrasporter,AccessToken;
        EWayBillingSetup: Record "E-Way Billing Setup";
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        IF NOT (SalesHeader."Document Type" IN [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::"Credit Memo"]) THEN
            EXIT;
        EWayBillingSetup.GET;
        IF NOT EWayBillingSetup."With Posting" THEN
            EXIT;
        IF SalesHeader."Document Type" = SalesHeader."Document Type"::Order THEN
            EWayBillingSetup.TESTFIELD("S.O EWay Applicability");



        //EWAYREV >>
        IF (SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo") AND (NOT (EWayBillingSetup."Applicable On Sales Credit Mem")) THEN
            EXIT;
        //EWAYREV <<
        SalesSetup.GET;
        IF NOT (SalesHeader."GST Customer Type" IN [SalesHeader."GST Customer Type"::" "])
        AND (CheckAtleaseOneItem(SalesHeader, 1)) AND (CheckSaleShipEwayExist(SalesHeader)) AND (CheckEWayAmount(SalesHeader)) THEN BEGIN
            IF ((SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice))
            OR CheckSOApplicability(SalesHeader) THEN BEGIN
                EWayValidator.CheckValidations(SalesHeader, RequestType::Eway);
                EWayValidator.CheckValidations(SalesHeader, RequestType::Vehicle);
                IsEWayApplicable := TRUE;
            END;
        END ELSE
            IsEWayApplicable := FALSE;
    end;

    local procedure CheckAtleaseOneItem(SalesHeader: Record "Sales Header"; Type: Integer): Boolean
    var
        SalesItemError: Label 'Atlease 1 Item Should be there in Document';
        SalesLineRec: Record "Sales Line";
        EWayBillingSetup: Record "E-Way Billing Setup";
    begin
        EWayBillingSetup.GET();
        CASE Type OF
            1:
                BEGIN
                    SalesLineRec.RESET;
                    SalesLineRec.SETRANGE("Document No.", SalesHeader."No.");
                    SalesLineRec.SETRANGE(Type, SalesLineRec.Type::Item);
                    SalesLineRec.SETRANGE(Exempted, FALSE);
                    IF SalesLineRec."Document Type" = SalesLineRec."Document Type"::Order THEN
                        IF EWayBillingSetup."S.O EWay Applicability" = EWayBillingSetup."S.O EWay Applicability"::Shipment THEN
                            SalesLineRec.SETFILTER("Qty. to Ship", '<>%1', 0);
                    IF SalesLineRec.FINDFIRST THEN
                        EXIT(TRUE);

                    EXIT(FALSE);
                END;
            2:
                BEGIN
                    SalesLineRec.RESET;
                    SalesLineRec.SETRANGE("Document No.", SalesHeader."No.");
                    SalesLineRec.SETRANGE("GST Group Type", SalesLineRec."GST Group Type"::Goods);
                    SalesLineRec.SETRANGE(Exempted, FALSE);
                    IF SalesLineRec."Document Type" = SalesLineRec."Document Type"::Order THEN
                        IF EWayBillingSetup."S.O EWay Applicability" = EWayBillingSetup."S.O EWay Applicability"::Shipment THEN
                            SalesLineRec.SETFILTER("Qty. to Ship", '<>%1', 0);
                    IF SalesLineRec.FINDFIRST THEN
                        EXIT(TRUE);
                    EXIT(FALSE);
                END;
        END;
    end;

    local procedure CheckEWayAmount(SalesHeader: Record "Sales Header"): Boolean
    var
        SalesItemError: Label 'Atlease 1 Item Should be there in Document';
        SalesLineRec: Record "Sales Line";
        LineAmt: Decimal;
        EWayBillingSetup: Record "E-Way Billing Setup";
        QtyToEWay: Decimal;
    begin
        EWayBillingSetup.GET();
        SalesLineRec.RESET;
        SalesLineRec.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLineRec.SETRANGE("Document No.", SalesHeader."No.");
        SalesLineRec.SETRANGE(Type, SalesLineRec.Type::Item);
        IF SalesLineRec."Document Type" = SalesLineRec."Document Type"::Order THEN
            IF EWayBillingSetup."S.O EWay Applicability" = EWayBillingSetup."S.O EWay Applicability"::Shipment THEN
                SalesLineRec.SETFILTER("Qty. to Ship", '<>%1', 0);
        SalesLineRec.SETRANGE(Exempted, FALSE);
        IF SalesLineRec.FINDFIRST THEN BEGIN
            REPEAT
                IF SalesLineRec."Document Type" = SalesLineRec."Document Type"::Order THEN BEGIN
                    IF EWayBillingSetup."S.O EWay Applicability" = EWayBillingSetup."S.O EWay Applicability"::Shipment THEN
                        QtyToEWay := SalesLineRec."Qty. to Ship"
                    ELSE
                        IF EWayBillingSetup."S.O EWay Applicability" = EWayBillingSetup."S.O EWay Applicability"::Invoice THEN
                            QtyToEWay := SalesLineRec."Qty. to Invoice";
                END ELSE
                    QtyToEWay := SalesLineRec.Quantity;
                LineAmt += ((QtyToEWay * SalesLineRec."Unit Price") -
                           ((QtyToEWay * SalesLineRec."Unit Price") * SalesLineRec."Line Discount %" / 100)) +
                           ((QtyToEWay * SalesLineRec."Unit Price") * ReturnGSTPercent(SalesLineRec."Document No.", SalesLineRec."Line No.") / 100);
                IF SalesHeader."Currency Code" <> '' THEN
                    LineAmt := (1 / SalesHeader."Currency Factor") * LineAmt;
                IF LineAmt > 50000 THEN
                    EXIT(TRUE);
            UNTIL SalesLineRec.NEXT = 0;
        END;
        EXIT(FALSE);
    end;

    procedure CheckSaleShipEwayExist(SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLineEway: Record "Sales Line";
        SalesShipmentEway: Record "Sales Shipment Header";
        EWayExists: Boolean;
        EwayExistsError: Label 'Document shuld not contain combination of E-Way generated and Non- Generated E-Way Bill No''s.';
        EWayEntry: Record "E-Way Billing Entry";
    begin
        IF SalesHeader."Document Type" <> SalesHeader."Document Type"::Invoice THEN
            EXIT(TRUE);
        SalesLineEway.RESET;
        SalesLineEway.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLineEway.SETRANGE("Document No.", SalesHeader."No.");
        SalesLineEway.SETFILTER("Shipment No.", '<>%1', '');
        SalesLineEway.SETRANGE(Type, SalesLineEway.Type::Item);
        SalesLineEway.SETFILTER("Qty. to Invoice", '>%1', 0);
        SalesLineEway.SETRANGE(Exempted, FALSE);
        IF SalesLineEway.FINDFIRST THEN BEGIN
            SalesShipmentEway.GET(SalesLineEway."Shipment No.");
            IF GetEwayBillIngNo(EWayEntry."Transaction Type"::"Sales Shpt", SalesShipmentEway."No.") <> 0 THEN
                EWayExists := TRUE
        END;
        SalesLineEway.RESET;
        SalesLineEway.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLineEway.SETRANGE("Document No.", SalesHeader."No.");
        SalesLineEway.SETFILTER("Shipment No.", '<>%1', '');
        SalesLineEway.SETRANGE(Type, SalesLineEway.Type::Item);
        SalesLineEway.SETFILTER("Qty. to Invoice", '>%1', 0);
        SalesLineEway.SETRANGE(Exempted, FALSE);
        IF SalesLineEway.FINDSET THEN BEGIN
            REPEAT
                SalesShipmentEway.GET(SalesLineEway."Shipment No.");
                IF EWayExists THEN BEGIN
                    IF GetEwayBillIngNo(EWayEntry."Transaction Type"::"Sales Shpt", SalesShipmentEway."No.") = 0 THEN
                        ERROR(EwayExistsError);
                END ELSE BEGIN
                    IF GetEwayBillIngNo(EWayEntry."Transaction Type"::"Sales Shpt", SalesShipmentEway."No.") <> 0 THEN
                        ERROR(EwayExistsError);
                END;
            UNTIL SalesLineEway.NEXT = 0;
            IF EWayExists THEN
                EXIT(FALSE)
            ELSE
                EXIT(TRUE);
        END;
        EXIT(TRUE);
    end;

    procedure CheckSOApplicability(SalesHeader: Record "Sales Header"): Boolean
    var
        EWayBillingSetup: Record "E-Way Billing Setup";
    begin
        EWayBillingSetup.GET();

        IF SalesHeader."Document Type" <> SalesHeader."Document Type"::Order THEN
            EXIT(TRUE);
        IF EWayBillingSetup."S.O EWay Applicability" = EWayBillingSetup."S.O EWay Applicability"::Shipment THEN BEGIN
            IF SalesHeader.Ship THEN
                EXIT(TRUE)
            ELSE
                EXIT(FALSE);
        END ELSE
            IF EWayBillingSetup."S.O EWay Applicability" = EWayBillingSetup."S.O EWay Applicability"::Invoice THEN BEGIN
                IF SalesHeader.Invoice THEN
                    EXIT(TRUE)
                ELSE
                    EXIT(FALSE);
            END;
    end;

    local procedure GetEwayBillIngNo(TransType: Option " ","Sales Invoice","Sales Shpt","Purch. Order","Whse. Shipment","Whse. Rect","Transfer Order","Sales Crd Memo","Purch. Crd Memo","Sales R.O","Purchase R.O",Subcontracting; DocNo: Code[20]): BigInteger
    var
        EWayBillingEntry: Record "E-Way Billing Entry";
    begin
        IF EWayBillingEntry.GET(TransType, DocNo) THEN;
        EXIT(EWayBillingEntry."E-Way Bill No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', false, false)]
    procedure GenerateEWayAfterSalesPost(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    var
        EWayBillingSetup: Record "E-Way Billing Setup";
    begin
        EWayBillingSetup.Get();
        IF SalesShptHdrNo <> '' THEN
            SalesShipHead.GET(SalesShptHdrNo);
        IF SalesInvHdrNo <> '' THEN
            SalesInvoiceHeader.GET(SalesInvHdrNo);
        IF SalesCrMemoHdrNo <> '' THEN
            SalesCreditHeader.GET(SalesCrMemoHdrNo);
        if EWayBillingSetup."With Posting" then
            GenerateEWayBill(SalesHeader);
    end;

    local procedure GenerateEWayBill(SalesHeader: Record "Sales Header")
    var
        EWayBillingIntigration: Codeunit "E-Way Billing Mgmt.";
        RequestType: Option Eway,Vehicle,EWayCancel,RejectEway,ExtendValidity,UpdateTrasporter,AccessToken,Pin2Pin; //PIN2PIN
        EWayBillingSetup: Record "E-Way Billing Setup";
    begin
        EWayBillingSetup.GET;
        IF SalesHeader."E-Way Bill No." <> '' THEN BEGIN
            IF (SalesShipHead."No." <> '') AND (EWayBillingSetup."S.O EWay Applicability" = EWayBillingSetup."S.O EWay Applicability"::Shipment) THEN
                EWayBillingIntigration.SetDocument(SalesShipHead, RequestType::Eway, TRUE)
            ELSE
                IF ((SalesInvoiceHeader."No." <> '') AND (EWayBillingSetup."S.O EWay Applicability" = EWayBillingSetup."S.O EWay Applicability"::Invoice)) OR
           (SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice) THEN
                    EWayBillingIntigration.SetDocument(SalesInvoiceHeader, RequestType::Eway, TRUE)
                ELSE
                    IF SalesCreditHeader."No." <> '' THEN
                        EWayBillingIntigration.SetDocument(SalesCreditHeader, RequestType::Eway, TRUE);
            EWayBillingIntigration.RUN;

            IF EWayBillingSetup."E-Way Bill Generation Type" = EWayBillingSetup."E-Way Bill Generation Type"::"Man.& Transport" THEN BEGIN
                IF (SalesShipHead."No." <> '') AND (EWayBillingSetup."S.O EWay Applicability" = EWayBillingSetup."S.O EWay Applicability"::Shipment) THEN
                    EWayBillingIntigration.SetDocument(SalesShipHead, RequestType::Vehicle, TRUE)
                ELSE
                    IF ((SalesInvoiceHeader."No." <> '') AND (EWayBillingSetup."S.O EWay Applicability" = EWayBillingSetup."S.O EWay Applicability"::Invoice)) OR
               (SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice) THEN
                        EWayBillingIntigration.SetDocument(SalesInvoiceHeader, RequestType::Vehicle, TRUE)
                    ELSE
                        IF SalesCreditHeader."No." <> '' THEN
                            EWayBillingIntigration.SetDocument(SalesCreditHeader, RequestType::Vehicle, TRUE);
                EWayBillingIntigration.RUN;
            END;
        END;
    end;

    procedure GetTokenExpiryFromResponse(TempBlob: Codeunit "Temp Blob") ReturnDate: DateTime
    var

        TokenType: Integer;

        ExpiryDuration: Integer;
        Days: Integer;
        Hours: Integer;
        Mins: Integer;
        Secs: Integer;
        ExpiryDate: Date;
        ExpiryTime: Time;
        JSONText: Text;
        ResponseValue: Variant;
        //B2BUPPG1.0>>
        InstreamL: InStream;
        OutstreamL: OutStream;
    //B2BUPPG1.0<<
    begin


        //>>TokenExpiryFix
        JobjG := ReadJSONAcctoken(ResponseG);
        JobjG.Get('expires_in', JTokenExp);
        ExpiryDuration := JTokenExp.AsValue().AsInteger();
        //ExpiryDuration := ResponseValue;
        Days := ExpiryDuration DIV (60 * 60 * 24);
        ExpiryDuration := ExpiryDuration MOD (60 * 60 * 24);
        Hours := ExpiryDuration DIV (60 * 60);
        ExpiryDuration := ExpiryDuration MOD (60 * 60);
        Mins := ExpiryDuration DIV (60);
        Secs := ExpiryDuration MOD (60);
        IF Days > 0 THEN
            ExpiryDate := CALCDATE(FORMAT(Days) + 'D', TODAY)
        ELSE
            ExpiryDate := TODAY;
        EVALUATE(ExpiryTime, FORMAT(Hours) + ':' + FORMAT(Mins) + ':' + FORMAT(Secs));
        EXIT(CREATEDATETIME(ExpiryDate, ExpiryTime));
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

    //PIN2PIN>>
    procedure GeneratePin2PinDistance(RequestURL: Text): Boolean
    var

        InStr: InStream;
        TempBlob: Codeunit "Temp Blob";
        AttachmentOutstream: OutStream;
        RequestPath: Text;
        ResponsePath: Text;
        Pin2PinURL: Text;
        FromPin: Integer;
        ToPin: Integer;
        FileManagement: Codeunit "File Management";
        LocationLRec: Record Location;
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesShipLine: Record "Sales Shipment Line";
        SalesLine: Record "Sales Line";
        SalesCreditLine: Record "Sales Cr.Memo Line";
        PurchHeaderGRec: Record "Purchase Header";
        WhseRectLine: Record "Warehouse Receipt Line";
        JSONText: Text;
    begin
        IF GenerateToken THEN BEGIN
            IF SalesInvoiceHeader."No." <> '' THEN begin
                RequestID := SalesInvoiceHeader."No.";
                if LocationLRec.Get(SalesInvoiceHeader."Location Code") then
                    Evaluate(FromPin, LocationLRec."Post Code");
                SalesInvoiceLine.RESET;
                SalesInvoiceLine.SETRANGE("Document No.", SalesInvoiceHeader."No.");
                SalesInvoiceLine.SETFILTER("No.", '<>%1', '');
                SalesInvoiceLine.SETRANGE(Exempted, FALSE);
                IF SalesInvoiceLine.FINDFIRST THEN BEGIN
                    IF SalesInvoiceLine."GST Place of Supply" = SalesInvoiceLine."GST Place of Supply"::"Bill-to Address" THEN
                        Evaluate(ToPin, SalesInvoiceHeader."Bill-to Post Code");
                    IF SalesInvoiceLine."GST Place of Supply" = SalesInvoiceLine."GST Place of Supply"::"Ship-to Address" THEN
                        Evaluate(ToPin, SalesInvoiceHeader."Ship-to Post Code");
                END;
            end ELSE
                IF SalesShipHead."No." <> '' THEN begin
                    RequestID := SalesShipHead."No.";
                    if LocationLRec.Get(SalesShipHead."Location Code") then
                        Evaluate(FromPin, LocationLRec."Post Code");
                    SalesShipLine.RESET;
                    SalesShipLine.SETRANGE("Document No.", SalesShipHead."No.");
                    SalesShipLine.SETFILTER("No.", '<>%1', '');
                    SalesShipLine.SETRANGE(Exempted, FALSE);
                    IF SalesShipLine.FINDFIRST THEN BEGIN
                        IF SalesShipLine."GST Place of Supply" = SalesShipLine."GST Place of Supply"::"Bill-to Address" THEN
                            Evaluate(ToPin, SalesShipHead."Bill-to Post Code");
                        IF SalesShipLine."GST Place of Supply" = SalesShipLine."GST Place of Supply"::"Ship-to Address" THEN
                            Evaluate(ToPin, SalesShipHead."Ship-to Post Code");
                    END;
                end ELSE
                    IF PurchHeader."No." <> '' THEN begin
                        RequestID := PurchHeader."Vendor Shipment No.";
                        Evaluate(FromPin, PurchHeader."Pay-to Post Code");
                        if LocationLRec.Get(PurchHeader."Location Code") then
                            Evaluate(ToPin, LocationLRec."Post Code");
                    end ELSE
                        IF WarehouseRectHead."No." <> '' THEN begin
                            RequestID := WarehouseRectHead."No.";
                            WhseRectLine.RESET;
                            WhseRectLine.SETRANGE("No.", WareHouseRectHead."No.");
                            IF WhseRectLine.FINDFIRST THEN
                                PurchHeaderGRec.GET(PurchHeaderGRec."Document Type"::Order, WhseRectLine."Source No.");
                            Evaluate(FromPin, PurchHeaderGRec."Pay-to Post Code");
                            if LocationLRec.Get(PurchHeaderGRec."Location Code") then
                                Evaluate(ToPin, LocationLRec."Post Code");
                        end ELSE
                            IF SalesCreditHeader."No." <> '' THEN begin
                                RequestID := SalesCreditHeader."No.";
                                if LocationLRec.Get(SalesCreditHeader."Location Code") then
                                    Evaluate(FromPin, LocationLRec."Post Code");
                                SalesCreditLine.RESET;
                                SalesCreditLine.SETRANGE("Document No.", SalesCreditHeader."No.");
                                SalesCreditLine.SETFILTER("No.", '<>%1', '');
                                SalesCreditLine.SETRANGE(Exempted, FALSE);
                                IF SalesCreditLine.FINDFIRST THEN BEGIN
                                    IF SalesCreditLine."GST Place of Supply" = SalesCreditLine."GST Place of Supply"::"Bill-to Address" THEN
                                        Evaluate(ToPin, SalesCreditHeader."Bill-to Post Code");
                                    IF SalesCreditLine."GST Place of Supply" = SalesCreditLine."GST Place of Supply"::"Ship-to Address" THEN
                                        Evaluate(ToPin, SalesCreditHeader."Ship-to Post Code");
                                END;
                            end ELSE
                                IF PurchCrMemoHdr."No." <> '' THEN begin
                                    RequestID := PurchCrMemoHdr."No.";
                                    if LocationLRec.Get(PurchCrMemoHdr."Location Code") then
                                        Evaluate(FromPin, LocationLRec."Post Code");
                                    Evaluate(ToPin, PurchCrMemoHdr."Pay-to Post Code");
                                end ELSE
                                    IF TransferShipmentHeader."No." <> '' THEN begin
                                        RequestID := TransferShipmentHeader."No.";
                                        if LocationLRec.GET(TransferShipmentHeader."Transfer-from Code") then
                                            Evaluate(FromPin, LocationLRec."Post Code");
                                        if LocationLRec.GET(TransferShipmentHeader."Transfer-to Code") then
                                            Evaluate(ToPin, LocationLRec."Post Code");
                                    end else
                                        if SalesHeaderGRec."No." <> '' then begin
                                            RequestID := SalesHeaderGRec."No.";
                                            if LocationLRec.Get(SalesHeaderGRec."Location Code") then
                                                Evaluate(FromPin, LocationLRec."Post Code");
                                            SalesLine.RESET;
                                            SalesLine.SETRANGE("Document No.", SalesHeaderGRec."No.");
                                            SalesLine.SETFILTER("No.", '<>%1', '');
                                            SalesLine.SETRANGE(Exempted, FALSE);
                                            IF SalesLine.FINDFIRST THEN BEGIN
                                                IF SalesLine."GST Place of Supply" = SalesLine."GST Place of Supply"::"Bill-to Address" THEN
                                                    Evaluate(ToPin, SalesHeaderGRec."Bill-to Post Code");
                                                IF SalesLine."GST Place of Supply" = SalesLine."GST Place of Supply"::"Ship-to Address" THEN
                                                    Evaluate(ToPin, SalesHeaderGRec."Ship-to Post Code");
                                            END;
                                        end;

            InsertEwayEntryPin2Pin();
            //CheckFilePathExists(RequestPath, ResponsePath, RequestID);
            RequestGUID := CREATEGUID;
            Pin2PinURL := RequestURL + 'from=' + Format(FromPin) + '&to=' + Format(ToPin);
            /*   HttpWebRequest := HttpWebRequest.Create(Pin2PinURL);
               HttpWebRequest.Method := 'GET';
               HttpWebRequest.ContentType('application/json');
               HttpWebRequest.Headers.Add('Authorization', 'Bearer ' + EWayBillingSetup."Access Token" + EWayBillingSetup."Access Token 2");

               HttpWebResponse := HttpWebRequest.GetResponse();
               InStr := HttpWebResponse.GetResponseStream;

               UpdateEwayLogPin2Pin(RequestID, '', ResponsePath, Status::Success, 'GET', FALSE);

               IF HttpWebResponse.StatusCode <> 200 THEN
                   EXIT(false);*/
            Clear(HttpRequestMessageG);
            Clear(HttpClientG);
            Clear(HttpContentG);
            Clear(HttpHeadersG);
            Clear(HeadersG);
            Clear(HttpResponseMessageG);
            HttpRequestMessageG.SetRequestUri(Pin2PinURL);
            HttpRequestMessageG.Method := 'GET';
            HeadersG := HttpClientG.DefaultRequestHeaders;
            HeadersG.Add('Authorization', 'bearer ' + EWayBillingSetup."Access Token" + EWayBillingSetup."Access Token 2");
            HttpContentG.GetHeaders(HttpHeadersG);
            HttpHeadersG.Clear();
            HttpHeadersG.Add('Content-Type', 'application/json');
            HttpContentG.WriteFrom(JSONText);//Attcah Body                                        
            HttpRequestMessageG.Content := HttpContentG;
            HttpClientG.Send(HttpRequestMessageG, HttpResponseMessageG);
            HttpResponseMessageG.Content().ReadAs(ResponseG);
            UpdateEwayLogPin2Pin(RequestID, ResponseG, Status::Success, 'GET', FALSE);

            if not HttpResponseMessageG.IsSuccessStatusCode then
                EXIT(false);

            IF NOT ReadResponse(ResponseG, RequestID) THEN
                UpdateEwayLogPin2Pin(RequestID, ResponseG, Status::Failed, GETLASTERRORTEXT, TRUE);
            COMMIT;
            exit(true);
        end else
            exit(false);
    end;

    procedure InsertEwayEntryPin2Pin()
    var
        LocationRec: Record Location;
    begin
        EWayBillingEntry.RESET;
        EWayBillingEntry.SetRange("Transaction Type", EWayBillingEntry."Transaction Type"::"Pin 2 Pin");
        EWayBillingEntry.SETRANGE("Document No.", RequestID);
        IF NOT EWayBillingEntry.FINDFIRST THEN BEGIN
            EWayBillingEntry.INIT;
            EWayBillingEntry."Document No." := RequestID;
            EWayBillingEntry."Transaction Type" := EWayBillingEntry."Transaction Type"::"Pin 2 Pin";
            EWayBillingEntry.INSERT;
        END;
    end;

    local procedure UpdateEwayLogPin2Pin(DocumentNo: Code[20]; ResponseL: Text; Staus: Option Success,Failed; Message: Text; Finished: Boolean)
    var
        EwsLog: Record "E-Way Integration Log";
        InsertNewLog: Boolean;
    begin
        EwsLog.INIT;
        EwsLog."Document No." := DocumentNo;
        IF (PurchHeader."No." <> '') or (PurchCrMemoHdr."No." <> '') THEN
            EwsLog."Transaction Type" := EwsLog."Transaction Type"::Purchase
        else
            if (SalesHeaderGRec."No." <> '') or (SalesInvoiceHeader."No." <> '') or (SalesShipHead."No." <> '') then
                EwsLog."Transaction Type" := EwsLog."Transaction Type"::Sales;

        EwsLog.SetRange("Document Type", EwsLog."Document Type"::"Pin 2 Pin");
        EwsLog.INSERT;


        IF Message <> '' THEN
            EwsLog."Request/Response Code" := COPYSTR(Message, 1, 250);

        EwsLog.Status := Staus;
        EwsLog."Request GUID" := RequestGUID;
        EwsLog."Request Type" := RequestType;
        EwsLog."Date & Time" := CURRENTDATETIME();
        EwsLog."User Id" := USERID();
        EwsLog.Finished := Finished;
        EwsLog.MODIFY;
    end;
    //PIN2PIN<<

    //B2BSaas>>
    Procedure ReadJSONAcctoken(Data: Text) Result: JsonObject
    begin
        Result.ReadFrom(Data);
    end;

    local procedure ReadJson(data: Text) result: JsonObject;
    begin
        result.ReadFrom(data);
    end;

    /* local procedure InitJSONRequest(var JSONtext: Text)
     var
         EWayJson: Codeunit "E-Way Adequre Json Generator";
     begin
         CASE RequestType OF
             RequestType::Eway:
                 BEGIN
                     EWayJson.JSONEWayFormat(JSONText);
                 END;
             RequestType::Vehicle:
                 BEGIN
                     EWayJson.JSONVechileFormat(JSONText);
                 END;
             RequestType::EWayCancel:
                 BEGIN
                     EWayJson.JSONCancelFormat(JSONText);
                 END;
             RequestType::RejectEway:
                 BEGIN
                     EWayJson.JSONRejectFormat(JSONtext);
                 END;
             RequestType::UpdateTrasporter:
                 BEGIN
                     EWayJson.JSONtrasnsproterFormat(JSONText);
                 END;
             RequestType::ExtendValidity:
                 BEGIN
                     EWayJson.JSONExtendedFormat(JSONText);
                 END;
         END;

     end;*/


    //B2BSaas<<
}

