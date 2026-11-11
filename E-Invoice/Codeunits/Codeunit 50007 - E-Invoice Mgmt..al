codeunit 50007 "E-Invoice Mgmt."
{
    // version E-INV,TokenExpiryFix,E-INVB2C
    Permissions = tabledata "E-Invoice Entry" = RMDI, tabledata "E-Invoice Log" = RMDI, tabledata "Sales Invoice Header" = RM;
    trigger OnRun();
    var
        RequestFail: Boolean;
        EInvoiceSetup: Record "E-Invoice Setup";
    begin
        EInvoiceSetup.GET;
        CASE EInvoiceSetup."GSP Priority" OF
            EInvoiceSetup."GSP Priority"::Adequre:
                BEGIN
                    IF NOT TriggerEInvoiceAdequre THEN
                        // IF NOT TriggerEinvoiceMI THEN
                        exit;
                END;
            EInvoiceSetup."GSP Priority"::MI:
                BEGIN
                    IF NOT TriggerEinvoiceMI THEN
                        //  IF NOT TriggerEInvoiceAdequre THEN
                        MESSAGE('%1', GETLASTERRORTEXT);
                END;
        END;
    end;

    var
        //B2B>>
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
        //B2B<<
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHdr: Record "Sales Cr.Memo Header";
        IsInvoice: Boolean;
        EInvFailTxt: Label 'E-%1 Upload failed With message : %2';
        EInvSuccessTxt: Label 'E-%1 Uploaded With message : %2';
        SuccessTxt: Label 'E-Invoice generated.';
        EInvoiceEntry: Record "E-Invoice Entry";
        GetEInvFailTxt: Label 'Get eInvoice by IRN failed With message : %1';
        JsonPath: Text;
        CreidtMemo: Boolean;
        TransferShipment: Boolean;
        TransferShipmentHeader: Record "Transfer Shipment Header";

        //B2BUPGSERVICE1.0>> Service Orders
        ServiceInvoiceHeader: Record "Service Invoice Header";
        IsServiceInvoice: Boolean;
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
    //B2BUPGSERVICE1.0<< Service Orders

    local procedure TriggerEInvoiceAdequre(): Boolean;
    begin
        IF NOT GenerateAccessToken THEN
            EXIT(FALSE);
        IF NOT SalesEInvoice THEN
            EXIT(FALSE);
        //SalesEInvoice();
        EXIT(TRUE);
    end;

    local procedure TriggerEinvoiceMI(): Boolean;
    begin
        IF NOT GenerateAccessTokenMI THEN
            EXIT(FALSE);
        IF NOT SalesEInvoiceMI THEN
            EXIT(FALSE);
        EXIT(TRUE);
    end;

    procedure CancelIRN(Variant: Variant);
    var
        EInvoiceSetup: Record "E-Invoice Setup";
    begin
        EInvoiceSetup.GET;
        CASE EInvoiceSetup."GSP Priority" OF
            EInvoiceSetup."GSP Priority"::Adequre:
                BEGIN
                    IF NOT TriggerCancelIRNAdequre(Variant) THEN
                        //  IF NOT TriggerCancelIRNMI(Variant) THEN
                        MESSAGE('%1', GETLASTERRORTEXT);
                END;
            EInvoiceSetup."GSP Priority"::MI:
                BEGIN
                    IF NOT TriggerCancelIRNMI(Variant) THEN
                        //IF NOT TriggerCancelIRNAdequre(Variant) THEN
                            MESSAGE('%1', GETLASTERRORTEXT);
                END;
        END;
    end;

    local procedure TriggerCancelIRNAdequre(Variant: Variant): Boolean;
    begin
        IF NOT GenerateAccessToken THEN
            EXIT(FALSE);
        IF NOT CancelIRNAdequre(Variant) THEN
            EXIT(FALSE);
        EXIT(TRUE);
    end;

    local procedure TriggerCancelIRNMI(Variant: Variant): Boolean;
    var
        RecRef: RecordRef;
    begin
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            112:
                SetSalesInvHeader(Variant);
            114:
                SetCrMemoHeader(Variant);
        END;

        IF NOT GenerateAccessTokenMI THEN
            EXIT(FALSE);
        IF NOT CancelIrnMI(Variant) THEN
            EXIT(FALSE);
        EXIT(TRUE);
    end;

    procedure GenerateAccessToken(): Boolean;
    var
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        AccessCode: Text;

        // AccessCodeDll: DotNet AccessCodeDllDV; BCSaaS

        Input: Text;
        Result: Text;
        EInvoiceLog: Record "E-Invoice Log";
        EInvoiceSetup: Record "E-Invoice Setup";
        FileMgmt: Codeunit "File Management";
        RequestUrl: Text;

    begin
        EInvoiceSetup.GET;
        IF EInvoiceSetup."Access Token Expiry Date" <> 0DT THEN//TokenExpiryFix
            IF EInvoiceSetup."Access Token Expiry Date" > CURRENTDATETIME THEN//TokenExpiryFix
                EXIT(TRUE);

        //B2BSaas>>
        HeadersG := HttpClientG.DefaultRequestHeaders;
        HeadersG.Add('gspappid', EInvoiceSetup."Client ID");
        HttpRequestMessageG.GetHeaders(HeadersG);
        HeadersG.Clear();
        HeadersG.Add('gspappsecret', EInvoiceSetup."Client Secret");
        HttpRequestMessageG.SetRequestUri('https://gsp.adaequare.com/gsp/authenticate?grant_type=token');
        HttpRequestMessageG.Method := 'POST';
        HttpRequestMessageG.Content := HttpContentG;
        HttpClientG.Send(HttpRequestMessageG, HttpResponseMessageG);
        HttpResponseMessageG.Content.ReadAs(ResponseG);
        JobjG := ReadJSONAcctoken(ResponseG);
        JobjG.Get('access_token', JTokenGAc);
        AccessCode := JTokenGAc.AsValue().AsText();
        JobjG.Get('expires_in', JTokenExp);
        ExpiresInG := JTokenExp.AsValue().AsInteger();
        //B2BSaas<<

        EInvoiceLog.INIT;
        EInvoiceLog."Document Type" := EInvoiceLog."Document Type"::"Access Token";
        EInvoiceLog."Document No." := 'AccessToken';
        EInvoiceLog."Date & Time" := CURRENTDATETIME;
        EInvoiceLog."User Id" := USERID;
        EInvoiceLog."JSON Access Token".CreateOutStream(OutStr);
        OutStr.WriteText(AccessCode);
        if NOT HttpResponseMessageG.IsSuccessStatusCode then
            EInvoiceLog.Status := EInvoiceLog.Status::Failed;
        EInvoiceLog.INSERT(true);


        EInvoiceSetup."Access Token Expiry Date" := GetTokenExpiryFromResponse(ExpiresInG);//TokenExpiryFix

        IF EInvoiceLog.Status = EInvoiceLog.Status::Failed THEN
            EXIT(FALSE);

        EInvoiceSetup."Access Token Date" := CURRENTDATETIME;
        EInvoiceSetup."Access Token" := COPYSTR(AccessCode, 1, MAXSTRLEN(EInvoiceSetup."Access Token"));
        EInvoiceSetup."Access Token 2" := COPYSTR(AccessCode, MAXSTRLEN(EInvoiceSetup."Access Token") + 1, MAXSTRLEN(EInvoiceSetup."Access Token 2"));
        EInvoiceSetup.MODIFY;

        EXIT(TRUE);
    end;

    //[TryFunction]
    local procedure SalesEInvoice(): Boolean;
    var
        FileManagement: Codeunit 419;
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        //B2B
        JSONText: Text;
        //B2B
        EInvoiceRequestAdequre: Codeunit "E-Invoice Request -Adequre";
        EInvoiceLog: Record "E-Invoice Log";
        EInvoiceSetup: Record "E-Invoice Setup";
        GUIDStorage: Text;
        JsonResponse: Text;
        Location: Record Location;
        UserName: Text;
        Password: Text;
        GSTIN: Code[15];
        EValidate: Codeunit "Validate E-Invoice Request";
        EInvoiceAdN: Codeunit "E-Invoice Request -Adequre";
    begin
        //TestFun();
        EInvoiceSetup.GET;
        IF IsInvoice THEN BEGIN
            // Generating JSON body >>
            EInvoiceRequestAdequre.SetSalesInvHeader(SalesInvHeader);
            EInvoiceRequestAdequre.RUN;
            EInvoiceRequestAdequre.JSONFormat(JSONText);//B2B
            // Generating JSON body <<
            EInvoiceLog.RESET;
            EInvoiceLog.SETRANGE("Document No.", SalesInvHeader."No.");
            EInvoiceLog.SETRANGE("Document Type", EInvoiceLog."Document Type"::Invoice);
            EInvoiceLog.FINDLAST;

            Location.GET(SalesInvHeader."Location Code");
        END ELSE
            IF CreidtMemo THEN BEGIN
                // Generating JSON body >>
                EInvoiceRequestAdequre.SetCrMemoHeader(SalesCrMemoHdr);
                EInvoiceRequestAdequre.RUN;
                EInvoiceRequestAdequre.JSONFormat(JSONText);//B2B
                // Generating JSON body  <<
                EInvoiceLog.RESET;
                EInvoiceLog.SETRANGE("Document Type", EInvoiceLog."Document Type"::"Credit Memo");
                EInvoiceLog.SETRANGE("Document No.", SalesCrMemoHdr."No.");
                EInvoiceLog.FINDLAST;
                Location.GET(SalesCrMemoHdr."Location Code");
            END ELSE
                IF TransferShipment THEN BEGIN
                    // Generating JSON BODY >>
                    EInvoiceRequestAdequre.SetTransferShipmentHeader(TransferShipmentHeader);
                    EInvoiceRequestAdequre.RUN;
                    EInvoiceRequestAdequre.JSONFormat(JSONText);//B2B
                    // Generating JSON BODY <<
                    EInvoiceLog.RESET;
                    EInvoiceLog.SETRANGE("Document Type", EInvoiceLog."Document Type"::"Transfer Shipment");
                    EInvoiceLog.SETRANGE("Document No.", TransferShipmentHeader."No.");
                    EInvoiceLog.FINDLAST;
                    Location.GET(TransferShipmentHeader."Transfer-from Code");
                END;

        Location.TESTFIELD("User Name");
        Location.TESTFIELD(Password);

        UserName := Location."User Name";
        Password := Location.Password;
        GSTIN := Location."GST Registration No.";
        GUIDStorage := CREATEGUID;


        //E-Invoice API Connection >>   //B2B
        Clear(HttpRequestMessageG);
        Clear(HttpClientG);
        Clear(HttpContentG);
        Clear(HttpHeadersG);
        Clear(HeadersG);
        Clear(HttpResponseMessageG);
        HttpRequestMessageG.SetRequestUri(EInvoiceSetup."Request URL");
        HttpRequestMessageG.Method := 'POST';
        HeadersG := HttpClientG.DefaultRequestHeaders;
        HeadersG.Add('user_name', UserName);
        HeadersG.Add('password', Password);
        HeadersG.Add('gstin', GSTIN);
        HeadersG.Add('requestid', GUIDStorage);
        HeadersG.Add('Authorization', 'bearer ' + EInvoiceSetup."Access Token" + EInvoiceSetup."Access Token 2");
        HttpContentG.GetHeaders(HttpHeadersG);
        HttpHeadersG.Clear();
        HttpHeadersG.Add('Content-Type', 'application/json');
        HttpContentG.WriteFrom(JSONText);//Attcah Body                                        
        HttpRequestMessageG.Content := HttpContentG;
        HttpClientG.Send(HttpRequestMessageG, HttpResponseMessageG);
        HttpResponseMessageG.Content().ReadAs(ResponseG);
        //B2BSaas>>
        IF not HttpResponseMessageG.IsSuccessStatusCode Then
            EXIT(false);
        ReadResponseJSON(ResponseG, EInvoiceLog);
        //B2BSaas<<
        EInvoiceLog."Request GUID" := GUIDStorage;
        EInvoiceLog."JSON Request Blob".CreateOutStream(OutStr);
        OutStr.WriteText(JSONText);
        EInvoiceLog."User Id" := USERID;
        //Read Json and Update Posted Document response
        EInvoiceLog.MODIFY;
        IF EInvoiceLog.Status = EInvoiceLog.Status::Failed THEN begin
            MESSAGE(EInvFailTxt, FORMAT(EInvoiceLog."Document Type"), EInvoiceLog."Request/Response Code");
            exit(false);
        end ELSE begin
            MESSAGE(SuccessTxt);
            exit(true);
        end;
    end;

    procedure SetSalesInvHeader(SalesInvoiceHeaderBuff: Record "Sales Invoice Header");
    begin
        SalesInvHeader := SalesInvoiceHeaderBuff;
        IsInvoice := TRUE;
        EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Invoice", SalesInvHeader."No.");
    end;

    procedure SetCrMemoHeader(SalesCrMemoHeaderBuff: Record "Sales Cr.Memo Header");
    begin
        SalesCrMemoHdr := SalesCrMemoHeaderBuff;
        CreidtMemo := true;
        EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Cr. Memo", SalesCrMemoHdr."No.");
    end;

    procedure SetTransferShipHeader(TransferShipmentHeaderBuff: Record "Transfer Shipment Header");
    begin
        TransferShipmentHeader := TransferShipmentHeaderBuff;
        TransferShipment := TRUE;
        EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Transfer Shipment", TransferShipmentHeader."No.");
    end;


    //B2BSaas>>
    Procedure ReadJSONAcctoken(Data: Text) Result: JsonObject
    begin
        Result.ReadFrom(Data);
    end;

    //B2BSaas<<

    procedure GetTokenExpiryFromResponse(ExpiryDuration: Integer) ReturnDate: DateTime;
    var
        Days: Integer;
        Hours: Integer;
        Mins: Integer;
        Secs: Integer;
        ExpiryDate: Date;
        ExpiryTime: Time;
        JSONText: Text;
        ResponseValue: Variant;
        InstreamL: InStream;
        OutstreamL: OutStream;
        ExpiresInl: Integer;
    begin
        //>>TokenExpiryFix
        JobjG := ReadJSONAcctoken(ResponseG);
        JobjG.Get('expires_in', JTokenExp);
        ExpiryDuration := JTokenExp.AsValue().AsInteger();
        // ExpiryDuration := ResponseValue;
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
        //<<TokenExpiryFix
    end;

    local procedure "-----Cancel IRN----------"();
    begin
    end;

    //[TryFunction]
    procedure CancelIRNAdequre(Variant: Variant): Boolean;
    var
        FileManagement: Codeunit 419;
        //FileStream: DotNet FileStreamDV;
        //FileMode: DotNet FileModeDV;
        TempBlob: Codeunit "Temp Blob";

        InStr: InStream;
        OutStr: OutStream;
        EInvoiceRequestAdequre: Codeunit "E-Invoice Request -Adequre";
        EInvoiceLog: Record "E-Invoice Log";
        EInvoiceSetup: Record "E-Invoice Setup";
        GUIDStorage: Text;

        DocumentNo: Code[20];
        RecRef: RecordRef;
        CancelSalesInvHdr: Record "Sales Invoice Header";
        CancelSalesCrMHdr: Record "Sales Cr.Memo Header";
        CancelTransferShipHdr: Record "Transfer Shipment Header";
        CancelSuccess: Label 'E-Invoice cancelled Successfully.';
        Location: Record Location;
        JSONTextl: Text;
    begin
        EInvoiceSetup.GET;
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            112:
                CancelSalesInvHdr := Variant;
            114:
                CancelSalesCrMHdr := Variant;
            5744:
                CancelTransferShipHdr := Variant;//EInvTrans
        END;
        IF GenerateAccessToken() THEN
            IF NOT (EInvoiceRequestAdequre.CancelEInvoice(Variant)) THEN
                EXIT(false);

        EInvoiceRequestAdequre.JSONcanFormat(JSONTextl);
        EInvoiceLog.RESET;
        IF CancelSalesInvHdr."No." <> '' THEN BEGIN
            EInvoiceLog.SETRANGE("Document Type", EInvoiceLog."Document Type"::Invoice);
            EInvoiceLog.SETRANGE("Document No.", CancelSalesInvHdr."No.");
            Location.GET(CancelSalesInvHdr."Location Code");
        END ELSE
            IF CancelSalesCrMHdr."No." <> '' THEN BEGIN
                EInvoiceLog.SETRANGE("Document Type", EInvoiceLog."Document Type"::"Credit Memo");
                EInvoiceLog.SETRANGE("Document No.", CancelSalesCrMHdr."No.");
                Location.GET(CancelSalesCrMHdr."Location Code");
            END ELSE
                IF CancelTransferShipHdr."No." <> '' THEN BEGIN
                    EInvoiceLog.SETRANGE("Document Type", EInvoiceLog."Document Type"::"Transfer Shipment");
                    EInvoiceLog.SETRANGE("Document No.", CancelTransferShipHdr."No.");
                    Location.GET(CancelTransferShipHdr."Transfer-from Code");
                END;
        EInvoiceLog.FINDLAST;
        GUIDStorage := CREATEGUID;


        //E-Invoice API Connection >>   //B2B
        Clear(HeadersG);
        Clear(HttpRequestMessageG);
        Clear(HttpContentG);
        Clear(HttpResponseMessageG);
        Clear(JobjG);
        Clear(ExpiresInG);
        Clear(JTokenGAc);
        Clear(JTokenExp);
        Clear(HttpHeadersG);
        HttpRequestMessageG.SetRequestUri(EInvoiceSetup."Cancel Request URL");
        HttpRequestMessageG.Method := 'POST';
        HeadersG := HttpClientG.DefaultRequestHeaders;
        HttpClientG.DefaultRequestHeaders.Clear();
        HeadersG.Add('user_name', Location."User Name");
        HeadersG.Add('password', Location.Password);
        HeadersG.Add('gstin', Location."GST Registration No.");
        HeadersG.Add('requestid', GUIDStorage);
        HeadersG.Add('Authorization', 'bearer ' + EInvoiceSetup."Access Token" + EInvoiceSetup."Access Token 2");
        HttpContentG.GetHeaders(HttpHeadersG);
        HttpHeadersG.Clear();
        HttpHeadersG.Add('Content-Type', 'application/json');
        HttpContentG.WriteFrom(JSONTextl);//Attcah Body
        HttpRequestMessageG.Content := HttpContentG;
        HttpClientG.Send(HttpRequestMessageG, HttpResponseMessageG);
        HttpResponseMessageG.Content().ReadAs(ResponseG);
        // Read Json and Update Posted Document response
        ReadCancelResponseJSON(ResponseG, EInvoiceLog);
        EInvoiceLog."Request GUID" := GUIDStorage;
        EInvoiceLog."JSON Request Blob".CreateOutStream(OutStr);
        OutStr.WriteText(JSONTextl);
        EInvoiceLog."User Id" := USERID;
        EInvoiceLog.MODIFY;

        IF EInvoiceLog.Status = EInvoiceLog.Status::Failed THEN begin
            MESSAGE(EInvFailTxt, FORMAT(EInvoiceLog."Document Type"), EInvoiceLog."Request/Response Code");
            exit(false);
        end ELSE begin
            MESSAGE(CancelSuccess);
            exit(true);
        end;
    end;

    local procedure GetDateTimeFromText(DateTimeText: Text): DateTime;
    var
        DateText: Text;
        Day: Integer;
        Month: Integer;
        Year: Integer;
        RetrivedTime: Time;
    begin
        IF DateTimeText = '' THEN
            EXIT;
        DateText := COPYSTR(DateTimeText, 1, 10);
        EVALUATE(Year, COPYSTR(DateText, 1, 4));
        EVALUATE(Month, COPYSTR(DateText, 6, 2));
        EVALUATE(Day, COPYSTR(DateText, 9, 2));
        EVALUATE(RetrivedTime, COPYSTR(DateTimeText, STRLEN(DateText) + 2, STRLEN(DateTimeText) - 3));
        EXIT(CREATEDATETIME(DMY2DATE(Day, Month, Year), RetrivedTime));
    end;

    local procedure "---MasterIndia---"();
    begin
    end;

    local procedure GenerateAccessTokenMI(): Boolean;
    var
        EInvoiceSetup: Record "E-Invoice Setup";
        EInvoiceLog: Record "E-Invoice Log";
        //B2BSaas>>
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestContent: HttpContent;
        HttpClient: HttpClient;
        Jobj: JsonObject;
        Response: Text;
        AccessToken: Text;
        Jtoken: JsonToken;
        //B2BSaas<<
        AccessTokenFile: Text;
        AccessTokenCode: Text;
        LocResult: Text[250];
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        FilePath: Text[250];
        FileName: Text[250];
        FileMgt: Codeunit "File Management";
        EInvoiceMiRequest: Codeunit "E-Invoice Request -MI";
        JSONText: Text;
        ReqText: Text;
        Contenttext: Text;
    begin
        EInvoiceSetup.GET;
        IF EInvoiceSetup."MI Access Token" <> '' THEN
            EXIT(TRUE);
        // AcquireToken('testeway@mastersindia.co', '!@#Demo!@#123', 'fIXefFyxGNfDWOcCWnj', 'QFd6dZvCGqckabKxTapfZgJc', Jobj);

        //B2BSaas>>
        /* Headers := HttpClient.DefaultRequestHeaders;
         Headers.Add('gspappid', 'BCC53FE80ED8427A9D65FCE0B0F9413D');
         Headers.Clear();
         Headers.Add('gspappsecret', '1981805CG897CG4DF8GA814GCB1CEC2E8E3B');
         RequestContent.GetHeaders(Headers);
         RequestMessage.SetRequestUri('https://clientbasic.mastersindia.co/oauth/access_token');
         RequestMessage.Method := 'POST';
         RequestMessage.Content := RequestContent;
         HttpClient.Send(RequestMessage, ResponseMessage);
         ResponseMessage.Content.ReadAs(Response);
         Jobj := ReadJSONAcctoken(Response);
         Jobj.Get('access_token', Jtoken);
         AccessTokenCode := Jtoken.AsValue().AsText();*/
        //JSONText := EInvoiceMiRequest.AccessTokenRequest();
        ////MIII
        EInvoiceMiRequest.AccessTokenRequest();
        EInvoiceMiRequest.AccessTokenJSON(JSONText);

        HttpContentG.WriteFrom(JSONText);//Attcah Body       
        HttpContentG.GetHeaders(HttpHeadersG);
        HttpHeadersG.Remove('Content-Type');
        HttpHeadersG.Add('Content-Type', 'application/json');
        HttpRequestMessageG.Method := 'POST';
        HttpRequestMessageG.SetRequestUri('https://clientbasic.mastersindia.co/oauth/access_token');
        HttpRequestMessageG.Content(HttpContentG);
        HttpClientG.Send(HttpRequestMessageG, HttpResponseMessageG);
        HttpResponseMessageG.Content().ReadAs(ResponseG);
        Jobj := ReadJSONAcctoken(ResponseG);
        Jobj.Get('access_token', Jtoken);
        AccessTokenCode := Jtoken.AsValue().AsText();
        if not HttpResponseMessageG.IsSuccessStatusCode then
            exit(false);

        EInvoiceLog.INIT;
        EInvoiceLog."Document Type" := EInvoiceLog."Document Type"::"Access Token";
        EInvoiceLog."Document No." := 'AccessTokenMI';
        EInvoiceLog."Date & Time" := CURRENTDATETIME;
        EInvoiceLog."User Id" := USERID;
        EInvoiceLog."Response Path" := FilePath;

        EInvoiceLog.Status := EInvoiceLog.Status::Success;
        EInvoiceLog.INSERT(true);

        EInvoiceSetup."MI Access Token Date" := CURRENTDATETIME;

        IF STRLEN(AccessTokenCode) > MAXSTRLEN(EInvoiceSetup."MI Access Token") THEN BEGIN
            EInvoiceSetup."MI Access Token" := COPYSTR(AccessTokenCode, 1, MAXSTRLEN(EInvoiceSetup."MI Access Token"));
            EInvoiceSetup."MI Access Token 2" :=
              COPYSTR(AccessTokenCode, MAXSTRLEN(EInvoiceSetup."MI Access Token") + 1, MAXSTRLEN(EInvoiceSetup."MI Access Token 2"));
        END ELSE
            EInvoiceSetup."MI Access Token" := AccessTokenCode;
        EInvoiceSetup.MODIFY;

        EXIT(TRUE);
    end;

    //[TryFunction]
    local procedure SalesEInvoiceMI(): Boolean;
    var
        EInvoiceSetup: Record "E-Invoice Setup";
        EInvoiceLog: Record "E-Invoice Log";
        ResponsePath: Text;
        InStr: InStream;
        OutStr: OutStream;
        TempBlob: Codeunit "Temp Blob";
        EInvoiceRequestMI: Codeunit "E-Invoice Request -MI";
        FileMgt: Codeunit "File Management";
        JSONText: Text;
    begin
        EInvoiceSetup.GET;
        IF IsInvoice THEN BEGIN
            // Generating JSON  >>
            EInvoiceRequestMI.SetSalesInvHeader(SalesInvHeader);
            EInvoiceRequestMI.RUN;
            EInvoiceRequestMI.JSONFormat(JSONText);//B2B
            // Generating JSON  <<

            EInvoiceLog.RESET;
            EInvoiceLog.SETRANGE("Document Type", EInvoiceLog."Document Type"::Invoice);
            EInvoiceLog.SETRANGE("Document No.", SalesInvHeader."No.");
            EInvoiceLog.FINDLAST;
            ResponsePath := EInvoiceSetup."MI JSON Response Path" +
                            DELCHR(SalesInvHeader."No." + '_' + FORMAT(CURRENTDATETIME), '=', '/\:*^@') + '_MI_Response' + '.Json';
        END ELSE BEGIN
            // Generating JSON  >>
            EInvoiceRequestMI.SetCrMemoHeader(SalesCrMemoHdr);
            EInvoiceRequestMI.RUN;
            EInvoiceRequestMI.JSONFormat(JSONText);//B2B
            // Generating JSON  <<
            EInvoiceLog.RESET;
            EInvoiceLog.SETRANGE("Document Type", EInvoiceLog."Document Type"::"Credit Memo");
            EInvoiceLog.SETRANGE("Document No.", SalesCrMemoHdr."No.");
            EInvoiceLog.FINDLAST;
            ResponsePath := EInvoiceSetup."MI JSON Response Path" +
                            DELCHR(SalesCrMemoHdr."No." + '_' + FORMAT(CURRENTDATETIME), '=', '/\:*^@') + '_MI_Response' + '.Json';
        END;

        /* HttpWebRequest := HttpWebRequest.Create(EInvoiceSetup."MI Request URL");
         HttpWebRequest.Method := 'POST';
         HttpWebRequest.ContentType := 'application/json';
         //Attaching Body >>
         EInvoiceLog.TESTFIELD("Request Path");
         FileStream := FileStream.FileStream(EInvoiceLog."Request Path", FileMode.Open);
         FileStream.CopyTo(HttpWebRequest.GetRequestStream);
         //Attaching Body <<

         HttpWebResponse := HttpWebRequest.GetResponse();

         InStr := HttpWebResponse.GetResponseStream;

         CLEAR(TempBlob);
         TempBlob.CREATEOUTSTREAM(OutStr);
         COPYSTREAM(OutStr, InStr);
         //TempBlob.EXPORT(ResponsePath);
         FileMgt.BLOBExportToServerFile(TempBlob, ResponsePath);

         IF HttpWebResponse.StatusCode <> 200 THEN
             EXIT(true);*/
        Clear(HeadersG);
        Clear(HttpRequestMessageG);
        Clear(HttpContentG);
        Clear(HttpResponseMessageG);
        Clear(JobjG);
        Clear(ExpiresInG);
        Clear(JTokenGAc);
        Clear(JTokenExp);
        Clear(HttpHeadersG);
        Clear(ResponseG);
        HttpContentG.WriteFrom(JSONText);//Attcah Body  
        HttpContentG.GetHeaders(HttpHeadersG);
        HttpHeadersG.Remove('Content-Type');
        HttpHeadersG.Add('Content-Type', 'application/json');
        HttpRequestMessageG.Method := 'POST';
        HttpRequestMessageG.SetRequestUri(EInvoiceSetup."MI Request URL");
        HttpRequestMessageG.Content(HttpContentG);
        HttpClientG.Send(HttpRequestMessageG, HttpResponseMessageG);
        HttpResponseMessageG.Content().ReadAs(ResponseG);
        //B2BSaas>>
        IF not HttpResponseMessageG.IsSuccessStatusCode Then
            EXIT(false);
        ReadResponseMI(ResponseG, EInvoiceLog);



        EInvoiceLog."Response Path" := ResponsePath;
        EInvoiceLog.MODIFY;

        IF EInvoiceLog.Status = EInvoiceLog.Status::Failed THEN begin
            MESSAGE(EInvFailTxt, FORMAT(EInvoiceLog."Document Type"), EInvoiceLog."Request/Response Code");
            exit(false);
        end ELSE begin
            MESSAGE(SuccessTxt);
            exit(false);
        end;
    end;

    procedure ReadResponseMI(ResponseL: Text; var EInvoiceLog: Record "E-Invoice Log");
    var

        TokenType: Integer;

        ActDate: Date;
        ActTime: Time;
        ActDateText: Text;
        dayValue: Integer;
        monthValue: Integer;
        yearValue: Integer;
        ActTimeText: Text;
        NewValue: Text;
        StatusTxt: Text;
        ResponseValue: Variant;
        JSONText: Text;
        QRText: Text;
        TempBlob2: Codeunit "Temp Blob";
        IRN: Text[100];
        AckNo: Text;
        AckDate: DateTime;
        MessageTxt: Text;
        BigInt: BigInteger;
        InstreamL: InStream;
        OutstreamL: OutStream;
        RecRef: RecordRef;
        FieldRef: FieldRef;
        JSONOBJ2: JsonObject;
        JSTOken2: JsonToken;
        AckDate1: Text;
        JSONOBJ3: JsonObject;
        JSONOBJL: JsonObject;
        JSTokenRes: JsonToken;
        ResultL: Text;
        QrCode: Codeunit "QR Generator";
    begin
        //JSONText := TempBlob.ReadAsText('', TEXTENCODING::UTF8);
        /*TempBlob.CreateInStream(InstreamL, TEXTENCODING::UTF8);
        InstreamL.ReadText(JsonText);
        TempBlob.CreateOutStream(OutstreamL, TEXTENCODING::UTF8);
        CopyStream(OutstreamL, InstreamL);
        OutstreamL.WriteText(JsonText); //B2BUPG1.0


        Jav := Jav.JavaScriptSerializer;
        Dir := Jav.DeserializeObject(JSONText);
        Dir.TryGetValue('results', Dir2);

        CLEAR(ResponseValue);
        Dir2.TryGetValue('status', ResponseValue);
        StatusTxt := FORMAT(ResponseValue);

        IF StatusTxt = 'Success' THEN BEGIN
            Dir2.TryGetValue('message', Dir3);
            CLEAR(ResponseValue);
            Dir3.TryGetValue('AckNo', ResponseValue);
            BigInt := ResponseValue;
            CLEAR(ResponseValue);
            Dir3.TryGetValue('AckDt', ResponseValue);
            AckDate := GetDateTimeFromText(FORMAT(ResponseValue));
            CLEAR(ResponseValue);
            Dir3.TryGetValue('Irn', ResponseValue);
            IRN := FORMAT(ResponseValue);
            CLEAR(ResponseValue);
            Dir3.TryGetValue('SignedQRCode', ResponseValue);
            QRText := FORMAT(ResponseValue);
            //CreateQRCode(QRText, TempBlob2);
            //B2BUPG1.0>>
            EInvoiceEntry."IRN No." := IRN;
            //EInvoiceEntry."QR Code" := TempBlob2.Blob;
            TempBlob2.CreateOutStream(OutstreamL);
            //CopyStream(OutstreamL, InstreamL);
            TempBlob2.CreateInStream(InstreamL);
            EInvoiceEntry."QR Code".CreateInStream(InstreamL); //B2BUPG1.0

            EInvoiceEntry."Ack No." := FORMAT(BigInt);
            EInvoiceEntry."Ack Date" := AckDate;
            EInvoiceEntry.MODIFY;

            RecRef.GetTable(EInvoiceEntry);
            FieldRef := RecRef.Field(EInvoiceEntry.FieldNo("IRN No."));
            FieldRef.Value := IRN;
            FieldRef := RecRef.Field(EInvoiceEntry.FieldNo("Ack No."));
            FieldRef.Value := FORMAT(BigInt);
            FieldRef := RecRef.Field(EInvoiceEntry.FieldNo("Ack Date"));
            FieldRef.Value := AckDate;
            FieldRef := RecRef.Field(EInvoiceEntry.FieldNo("QR Code"));
            TempBlob2.ToRecordRef(RecRef, EInvoiceEntry.FieldNo("QR Code"));
            RecRef.Modify();
            //B2BUPG1.0<<

            EInvoiceLog."Ack No." := AckNo;
            EInvoiceLog."Ack Date" := AckDate;
        END ELSE BEGIN
            EInvoiceLog.Status := EInvoiceLog.Status::Failed;

            CLEAR(ResponseValue);
            Dir2.TryGetValue('errorMessage', ResponseValue);
            MessageTxt := FORMAT(ResponseValue);
        END;
        EInvoiceLog."Date & Time" := CURRENTDATETIME;
        EInvoiceLog."Request/Response Code" := COPYSTR(MessageTxt, 1, MAXSTRLEN(EInvoiceLog."Request/Response Code"));*/
        EInvoiceLog."JSON Response Blob".CreateOutStream(OutstreamL);
        OutstreamL.WriteText(ResponseL);
        JSONOBJL := ReadJson(ResponseL);

        JSONOBJL.Get('results', JSTokenRes);
        JSTokenRes.WriteTo(ResultL);
        JSONOBJ2.ReadFrom(ResultL);

        if JSONOBJ2.Get('status', JSTokenRes) then
            StatusTxt := JSTokenRes.AsValue().AsText();
        Clear(JSTokenRes);

        IF StatusTxt = 'Success' THEN BEGIN
            JSONOBJ2.Get('message', JSTokenRes);
            if JSTokenRes.IsObject() then begin
                JSTokenRes.WriteTo(ResultL);
                JSONOBJ3.ReadFrom(ResultL);

                JSONOBJ3.Get('AckNo', JSTOken2);
                BigInt := JSTOken2.AsValue().AsBigInteger();
                Clear(JSTOken2);

                JSONOBJ3.Get('AckDt', JSTOken2);
                // Evaluate(AckDate1,format(JSTOken2.AsValue()));
                AckDate1 := JSTOken2.AsValue().AsText();
                Clear(JSTOken2);
                AckDate := GetDateTimeFromText(FORMAT(AckDate1));

                JSONOBJ3.Get('Irn', JSTOken2);
                IRN := JSTOken2.AsValue().AsText();
                Clear(JSTOken2);

                JSONOBJ3.Get('SignedQRCode', JSTOken2);
                QRText := JSTOken2.AsValue().AsText();
                QrCode.GenerateQRCodeImage(QRText, TempBlob2);
            end;
            EInvoiceEntry."QR Code".CreateInStream(InstreamL); //B2BUPG1.0

            EInvoiceEntry."Ack No." := FORMAT(BigInt);
            EInvoiceEntry."Ack Date" := AckDate;
            EInvoiceEntry.MODIFY;

            RecRef.GetTable(EInvoiceEntry);
            FieldRef := RecRef.Field(EInvoiceEntry.FieldNo("IRN No."));
            FieldRef.Value := IRN;
            FieldRef := RecRef.Field(EInvoiceEntry.FieldNo("Ack No."));
            FieldRef.Value := FORMAT(BigInt);
            FieldRef := RecRef.Field(EInvoiceEntry.FieldNo("Ack Date"));
            FieldRef.Value := AckDate;
            FieldRef := RecRef.Field(EInvoiceEntry.FieldNo("QR Code"));
            TempBlob2.ToRecordRef(RecRef, EInvoiceEntry.FieldNo("QR Code"));
            RecRef.Modify();
            //B2BUPG1.0<<

            EInvoiceLog."Ack No." := AckNo;
            EInvoiceLog."Ack Date" := AckDate;
        END ELSE BEGIN
            EInvoiceLog.Status := EInvoiceLog.Status::Failed;

            JSONOBJ2.Get('errorMessage', JSTokenRes);
            MessageTxt := JSTokenRes.AsValue().AsText();
            Clear(JSTokenRes);
        END;
        EInvoiceLog."Date & Time" := CURRENTDATETIME;
        EInvoiceLog."Request/Response Code" := COPYSTR(MessageTxt, 1, MAXSTRLEN(EInvoiceLog."Request/Response Code"));
    end;

    //[TryFunction]
    procedure CancelIrnMI(Variant: Variant): Boolean;
    var
        FileManagement: Codeunit 419;
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        EInvoiceRequestMI: Codeunit "E-Invoice Request -MI";
        EInvoiceLog: Record "E-Invoice Log";
        EInvoiceSetup: Record "E-Invoice Setup";
        GUIDStorage: Text;
        ResponseFileName: Text;
        DocumentNo: Code[20];
        RecRef: RecordRef;
        CancelSalesInvHdr: Record "Sales Invoice Header";
        CancelSalesCrMHdr: Record "Sales Cr.Memo Header";
        CancelSuccess: Label 'E-Invoice cancelled Successfully.';
        JSONTextl: Text;
    begin
        EInvoiceSetup.GET;
        RecRef.GETTABLE(Variant);
        CASE RecRef.NUMBER OF
            112:
                CancelSalesInvHdr := Variant;
            114:
                CancelSalesCrMHdr := Variant;
        END;

        IF NOT EInvoiceRequestMI.CancelEInvoice(Variant) THEN//Generate Json
            EXIT(false);
        EInvoiceLog.RESET;
        IF CancelSalesInvHdr."No." <> '' THEN BEGIN
            EInvoiceLog.SETRANGE("Document Type", EInvoiceLog."Document Type"::Invoice);
            EInvoiceLog.SETRANGE("Document No.", CancelSalesInvHdr."No.");
        END ELSE BEGIN
            EInvoiceLog.SETRANGE("Document Type", EInvoiceLog."Document Type"::"Credit Memo");
            EInvoiceLog.SETRANGE("Document No.", CancelSalesCrMHdr."No.");
        END;
        EInvoiceLog.FINDLAST;

        ResponseFileName := EInvoiceSetup."MI JSON Response Path" + DELCHR(EInvoiceLog."Document No.", '=', '/\-_*^@') + '_CancelResponseMI' + '.Json';
        GUIDStorage := CREATEGUID;

        //E-Invoice API Connection >>
        /* HttpWebRequest := HttpWebRequest.Create(EInvoiceSetup."MI Cancel Request URL");
         HttpWebRequest.Method := 'POST';
         HttpWebRequest.ContentType := 'application/json';
         //E-Invoice API Connection <<

         // Attaching Body >>
         FileStream := FileStream.FileStream(EInvoiceLog."Request Path", FileMode.Open);
         FileStream.CopyTo(HttpWebRequest.GetRequestStream);
         // Attaching Body <<

         HttpWebResponse := HttpWebRequest.GetResponse();

         InStr := HttpWebResponse.GetResponseStream;*/
        EInvoiceRequestMI.JSONcanFormat(JSONTextl);
        HttpContentG.WriteFrom(JSONTextl);//Attcah Body
        HttpContentG.GetHeaders(HttpHeadersG);
        HttpHeadersG.Remove('Content-Type');
        HttpHeadersG.Add('Content-Type', 'application/json');
        HttpRequestMessageG.Method := 'POST';
        HttpRequestMessageG.SetRequestUri(EInvoiceSetup."MI Cancel Request URL");
        HttpRequestMessageG.Content := HttpContentG;
        HttpClientG.Send(HttpRequestMessageG, HttpResponseMessageG);
        HttpResponseMessageG.Content().ReadAs(ResponseG);
        if not HttpResponseMessageG.IsSuccessStatusCode then
            exit(false);

        // Read Json and Update Posted Document response
        ReadCancelResponseMI(ResponseG, EInvoiceLog);

        EInvoiceLog."Request GUID" := GUIDStorage;
        EInvoiceLog."Response Path" := ResponseFileName;
        EInvoiceLog."User Id" := USERID;
        EInvoiceLog.MODIFY;

        IF EInvoiceLog.Status = EInvoiceLog.Status::Failed THEN begin
            MESSAGE(EInvFailTxt, FORMAT(EInvoiceLog."Document Type"), EInvoiceLog."Request/Response Code");
            exit(false);
        end ELSE begin
            MESSAGE(CancelSuccess);
            exit(true);
        end;
    end;

    local procedure ReadCancelResponseMI(ResponseL: Text; var EInvoiceLog: Record "E-Invoice Log");
    var

        StatusTxt: Text;
        JsonText: Text;
        ResponseValue: Variant;
        MessageTxt: Text;
        IRN: Text[100];
        CancelDate: DateTime;
        InstreamL: InStream;
        OutstreamL: OutStream;
        JSTokenMes: JsonToken;
        JSTokenRes: JsonToken;
        ResultL: Text;
        JSONOBJ2: JsonObject;
        JSIRN: JsonToken;
        CancelDateT: Text;
        JSTokencanDt: JsonToken;
        JSONOBJ3: JsonObject;
        JSONOBJL: JsonObject;
    begin
        EInvoiceLog."JSON Response Blob".CreateOutStream(OutstreamL);
        OutstreamL.WriteText(ResponseL);
        JSONOBJL := ReadJson(ResponseL);

        JSONOBJL.Get('results', JSTokenRes);
        JSTokenRes.WriteTo(ResultL);
        JSONOBJ2.ReadFrom(ResultL);
        JSONOBJ2.Get('status', JSTokenRes);
        StatusTxt := JSTokenRes.AsValue().AsText();
        Clear(JSTokenRes);

        IF EInvoiceLog."Document Type" = EInvoiceLog."Document Type"::Invoice THEN
            EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Invoice", EInvoiceLog."Document No.")
        ELSE
            EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Cr. Memo", EInvoiceLog."Document No.");

        IF StatusTxt = 'Success' THEN BEGIN
            JSONOBJ2.Get('message', JSTokenRes);
            if JSTokenRes.IsObject() then begin
                JSTokenRes.WriteTo(ResultL);
                JSONOBJ3.ReadFrom(ResultL);

                JSONOBJ3.Get('Irn', JSIRN);
                IRN := JSIRN.AsValue().AsText();

                JSONOBJ3.Get('CancelDate', JSTokencanDt);
                CancelDateT := JSTokencanDt.AsValue().AsText();
                CancelDate := GetDateTimeFromText(CancelDateT);
            END;

            EInvoiceEntry."IRN No." := IRN;
            EInvoiceEntry."IRN Cancelled" := TRUE;
            EInvoiceEntry."IRN Cancelled Date" := CancelDate;
            EInvoiceEntry."IRN Cancelled By" := USERID;
            EInvoiceEntry.MODIFY;
        END ELSE BEGIN
            EInvoiceLog.Status := EInvoiceLog.Status::Failed;

            EInvoiceEntry."IRN Cancelled Reason" := '';
            EInvoiceEntry."IRN Cancelled Remarks" := '';
            EInvoiceEntry."IRN Cancelled By" := '';
            EInvoiceEntry.MODIFY;
        END;
        EInvoiceLog."Date & Time" := CURRENTDATETIME;
    end;

    local procedure "---Get eInvoice by IRN---"();
    begin
    end;

    procedure TriggerGetEInvoiceByIRNAdequare(): Boolean;
    begin
        IF NOT GenerateAccessToken THEN
            EXIT(FALSE);
        IF NOT GetEInvoiceByIRN THEN
            EXIT(FALSE);
        EXIT(TRUE);
    end;

    //[TryFunction]
    local procedure GetEInvoiceByIRN(): Boolean;
    var
        FileManagement: Codeunit 419;
        // FileStream: Dotnet FileStreamDV;
        //FileMode: Dotnet FileModeDV;
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        EInvoiceRequestAdequre: Codeunit "E-Invoice Request -Adequre";
        EInvoiceLog: Record "E-Invoice Log";
        EInvoiceSetup: Record "E-Invoice Setup";
        GUIDStorage: Text;

        Location: Record Location;
        UserName: Text;
        Password: Text;
        GSTIN: Code[15];
        GetURL: Text[250];
    begin
        Clear(HeadersG);
        Clear(HttpHeadersG);
        Clear(HttpClientG);
        Clear(HttpContentG);
        Clear(HttpRequestMessageG);
        EInvoiceLog.INIT;
        IF IsInvoice THEN BEGIN
            EInvoiceLog."Document Type" := EInvoiceLog."Document Type"::Invoice;
            EInvoiceLog."Document No." := SalesInvHeader."No.";
        END ELSE
            IF CreidtMemo THEN BEGIN
                EInvoiceLog."Document Type" := EInvoiceLog."Document Type"::"Credit Memo";
                EInvoiceLog."Document No." := SalesCrMemoHdr."No.";
            END ELSE
                IF TransferShipment THEN BEGIN
                    EInvoiceLog."Document Type" := EInvoiceLog."Document Type"::"Transfer Shipment";
                    EInvoiceLog."Document No." := TransferShipmentHeader."No.";
                END;
        EInvoiceLog."User Id" := USERID;
        EInvoiceLog."Date & Time" := CURRENTDATETIME;
        EInvoiceLog.INSERT(true);

        EInvoiceSetup.GET;
        GetURL := EInvoiceSetup."Get IRN URL" + '?irn=' + EInvoiceEntry."IRN No.";

        IF IsInvoice THEN BEGIN


            Location.GET(SalesInvHeader."Location Code");
        END ELSE
            IF CreidtMemo THEN BEGIN


                Location.GET(SalesCrMemoHdr."Location Code");
            END ELSE
                IF TransferShipment THEN BEGIN


                    Location.GET(TransferShipmentHeader."Transfer-from Code");
                END;

        Location.TESTFIELD("User Name");
        Location.TESTFIELD(Password);

        UserName := Location."User Name";
        Password := Location.Password;
        GSTIN := Location."GST Registration No.";
        GUIDStorage := CREATEGUID;
        //E-Invoice API Connection >>
        HttpRequestMessageG.SetRequestUri(GetURL);
        HttpRequestMessageG.Method := 'POST';
        HeadersG := HttpClientG.DefaultRequestHeaders;
        HeadersG.Add('user_name', UserName);
        HeadersG.Add('password', Password);
        HeadersG.Add('gstin', GSTIN);
        HeadersG.Add('requestid', GUIDStorage);
        HeadersG.Add('Authorization', 'bearer ' + EInvoiceSetup."Access Token" + EInvoiceSetup."Access Token 2");
        HttpContentG.GetHeaders(HttpHeadersG);
        HttpRequestMessageG.Content := HttpContentG;
        HttpClientG.Send(HttpRequestMessageG, HttpResponseMessageG);
        HttpResponseMessageG.Content().ReadAs(ResponseG);
        //E-Invoice API Connection <<
        IF not HttpResponseMessageG.IsSuccessStatusCode THEN
            EXIT(false);

        EInvoiceLog."Request GUID" := GUIDStorage;
        EInvoiceLog."JSON Response Blob".CreateOutStream(OutStr);
        OutStr.WriteText(ResponseG);
        EInvoiceLog."User Id" := USERID;
        // Read Json and Update Posted Document response
        ReadResponseJSON(ResponseG, EInvoiceLog);

        EInvoiceLog.MODIFY;

        IF EInvoiceLog.Status = EInvoiceLog.Status::Failed THEN begin
            MESSAGE(GetEInvFailTxt, EInvoiceLog."Request/Response Code");
            exit(false);
        end ELSE begin
            MESSAGE(SuccessTxt);
            exit(true);
        end;
    end;

    local procedure "---E-INVB2C---"();
    begin
    end;

    procedure GenerateQRCodeForB2C(Variant: Variant);
    var
        QRText: Text;
        TempBlob: Codeunit "Temp Blob";
        eInvoiceAdaequare: Codeunit "E-Invoice Request -Adequre";
        //StringBuilderLVar: DotNet StringBuilder;
        OutstreamL: OutStream;
        InstreamL: InStream;
        TempText: Text;
        RecRef: RecordRef;
        FieldRef: FieldRef;
        QRcodegenerator: Codeunit "QR Generator";
    begin
        //>>E-INVB2C >>
        EInvoiceEntry.CALCFIELDS("QR Code");
        IF EInvoiceEntry."QR Code".HASVALUE THEN
            EXIT;
        IF IsInvoice THEN
            eInvoiceAdaequare.SetSalesInvHeader(SalesInvHeader)
        ELSE
            eInvoiceAdaequare.SetCrMemoHeader(SalesCrMemoHdr);

        eInvoiceAdaequare.GenerateFormatForB2C(Variant);


        QRcodegenerator.GenerateQRCodeImage(QRText, TempBlob);

        RecRef.GetTable(EInvoiceEntry);
        TempBlob.ToRecordRef(RecRef, EInvoiceEntry.FieldNo("QR Code"));
        RecRef.Modify();
        IF EInvoiceEntry."QR Code".HASVALUE THEN BEGIN
            EInvoiceEntry.MODIFY;
            MESSAGE('QR Code Generated');
        END;
        //>>E-INVB2C <<
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesInvHeaderInsert', '', false, false)]
    local procedure OnAfterSalesInvHeaderInsert(var SalesInvHeader: Record "Sales Invoice Header"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; WhseShip: Boolean; WhseReceive: Boolean; var TempWhseShptHeader: Record "Warehouse Shipment Header"; var TempWhseRcptHeader: Record "Warehouse Receipt Header")
    var
        EInvoice: Record "E-Invoice Entry";
    begin
        if not EInvoice.Get(EInvoice."Document Type"::"Sales Invoice", SalesInvHeader."No.") then begin
            EInvoice.Init();
            EInvoice."Document No." := SalesInvHeader."No.";
            EInvoice."Document Type" := EInvoice."Document Type"::"Sales Invoice";
            EInvoice.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesCrMemoHeaderInsert', '', false, false)]
    local procedure OnAfterSalesCrMemoHeaderInsert(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; WhseShip: Boolean; WhseReceive: Boolean; var TempWhseShptHeader: Record "Warehouse Shipment Header"; var TempWhseRcptHeader: Record "Warehouse Receipt Header")
    Var
        EInvoice: Record "E-Invoice Entry";
    begin
        if not EInvoice.Get(EInvoice."Document Type"::"Sales Cr. Memo", SalesCrMemoHeader."No.") then begin
            EInvoice.Init();
            EInvoice."Document No." := SalesCrMemoHeader."No.";
            EInvoice."Document Type" := EInvoice."Document Type"::"Sales Cr. Memo";
            EInvoice.Insert();
        end;
    end;

    // local procedure TestFun()
    // var
    //     Test: Record Test;
    // begin
    //     Test.Init();
    //     Test.Description := 'At 50500 Codeunit SalesInvoice';
    //     Test.Insert(true);
    // end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterCheckMandatoryFields', '', false, false)]
    local procedure OnAfterCheckMandatoryFields(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean)
    var
        ValidateEInvoiceRequest: Codeunit "Validate E-Invoice Request";
    begin
        //>>E-INV
        IF IsValidDocForEInvoicing(SalesHeader) THEN begin
            ValidateEInvFields(SalesHeader);

            IF SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo" THEN
                ValidateEInvoiceRequest.CheckValidEntriesApplied(SalesHeader);
        end;
        //<<E-INV
    end;

    local procedure IsValidDocForEInvoicing(VAR SalesHeader: Record "Sales Header"): Boolean;
    var
        EInvoiceSetup: Record "E-Invoice Setup";
        SalesInvHdr: Record "Sales Invoice Header";
        EInvoiceEntry: Record "E-Invoice Entry";
        ReferenceInvoiceNo: Record "Reference Invoice No.";
        CustLedgEntry: Record "Cust. Ledger Entry";
        LocationL: Record Location;
    begin
        //>>E-INV
        IF (SalesHeader."GST Customer Type" IN [SalesHeader."GST Customer Type"::Unregistered, SalesHeader."GST Customer Type"::" "]) THEN
            EXIT(FALSE);

        IF (SalesHeader."Document Type" IN [SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::"Credit Memo"]) OR
          SalesHeader.Invoice
        THEN BEGIN
            EInvoiceSetup.GET;
            IF NOT EInvoiceSetup."With Posting" THEN
                EXIT(FALSE);

            if (LocationL.Get(SalesHeader."Location Code")) and (LocationL."User Name" = '') then
                exit(false);

            IF (SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo") THEN BEGIN
                ReferenceInvoiceNo.SETRANGE("Document Type", ReferenceInvoiceNo."Document Type"::"Credit Memo");
                ReferenceInvoiceNo.SETRANGE("Document No.", SalesHeader."No.");
                ReferenceInvoiceNo.SETRANGE("Source No.", SalesHeader."Bill-to Customer No.");
                ReferenceInvoiceNo.SETRANGE("Source Type", ReferenceInvoiceNo."Source Type"::Customer);
                IF ReferenceInvoiceNo.FINDSET THEN BEGIN
                    REPEAT
                        SalesInvHdr.GET(ReferenceInvoiceNo."Reference Invoice Nos.");
                        //>>Fix 01Oct2020
                        //IF SalesInvHdr."Posting Date" >= DMY2DATE(1, 10, 2020) THEN BEGIN
                        IF SalesInvHdr."Posting Date" >= EInvoiceSetup."Effective Date" THEN BEGIN
                            EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Invoice", SalesInvHdr."No.");
                            SalesHeader."EINV Applicable" := NOT EInvoiceEntry."IRN Cancelled";
                        END ELSE
                            SalesHeader."EINV Applicable" := TRUE;
                    //<<Fix 01Oct2020
                    UNTIL (ReferenceInvoiceNo.NEXT = 0) OR (NOT SalesHeader."EINV Applicable");
                    EXIT(SalesHeader."EINV Applicable");
                END ELSE
                    IF (SalesHeader."Applies-to Doc. Type" = SalesHeader."Applies-to Doc. Type"::Invoice) AND
                      (SalesHeader."Applies-to Doc. No." <> '')
                    THEN BEGIN
                        SalesInvHdr.GET(SalesHeader."Applies-to Doc. No.");
                        //>>Fix 01Oct2020
                        //IF SalesInvHdr."Posting Date" >= DMY2DATE(1, 10, 2020) THEN BEGIN
                        IF SalesInvHdr."Posting Date" >= EInvoiceSetup."Effective Date" THEN BEGIN
                            EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Invoice", SalesInvHdr."No.");
                            SalesHeader."EINV Applicable" := NOT EInvoiceEntry."IRN Cancelled";
                        END ELSE
                            SalesHeader."EINV Applicable" := TRUE;
                        //<<Fix 01Oct2020
                        EXIT(SalesHeader."EINV Applicable");
                    END ELSE
                        IF (SalesHeader."Applies-to ID" <> '') THEN BEGIN
                            CustLedgEntry.RESET;
                            CustLedgEntry.SETCURRENTKEY("Customer No.", Open);
                            CustLedgEntry.SETRANGE("Customer No.", SalesHeader."Bill-to Customer No.");
                            CustLedgEntry.SETRANGE(Open, TRUE);
                            CustLedgEntry.SETRANGE("Applies-to ID", SalesHeader."Applies-to ID");
                            IF CustLedgEntry.FINDSET THEN
                                REPEAT
                                    IF SalesInvHdr.GET(CustLedgEntry."Document No.") THEN
                                        //IF SalesInvHdr."Posting Date" >= DMY2DATE(1, 10, 2020) THEN BEGIN//Fix 01Oct2020
                                        IF SalesInvHdr."Posting Date" >= EInvoiceSetup."Effective Date" THEN BEGIN
                                            EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Invoice", SalesInvHdr."No.");
                                            SalesHeader."EINV Applicable" := NOT EInvoiceEntry."IRN Cancelled";
                                        END ELSE
                                            SalesHeader."EINV Applicable" := TRUE;
                                UNTIL (CustLedgEntry.NEXT = 0) OR (NOT SalesHeader."EINV Applicable");
                            EXIT(SalesHeader."EINV Applicable");
                        END;
            END;

            SalesHeader."EINV Applicable" := TRUE;
            EXIT(TRUE);
        END;
        //<<E-INV
    end;

    local procedure ValidateEInvFields(SalesHeader: Record "Sales Header");
    var
        ValidateEInvoiceRequest: Codeunit "Validate E-Invoice Request";
    begin
        //>>E-INV
        IF NOT SalesHeader."EINV Applicable" THEN
            EXIT;
        ValidateEInvoiceRequest.CheckValidations(SalesHeader);
        //<<E-INV
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterFinalizePosting', '', false, false)]
    local procedure OnAfterFinalizePosting(var SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var ReturnReceiptHeader: Record "Return Receipt Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    var
        EInvoiceSetup: Record "E-Invoice Setup";
        EInvoiceMgmt: Codeunit "E-Invoice Mgmt.";
    begin
        //>>E-INV
        IF NOT SalesHeader."EINV Applicable" THEN
            EXIT;
        EInvoiceSetup.GET;
        IF (EInvoiceSetup."With Posting") AND (NOT PreviewMode) THEN BEGIN
            IF SalesInvoiceHeader."No." <> '' THEN
                EInvoiceMgmt.SetSalesInvHeader(SalesInvoiceHeader)
            ELSE
                IF SalesCrMemoHeader."No." <> '' THEN
                    EInvoiceMgmt.SetCrMemoHeader(SalesCrMemoHeader);
            EInvoiceMgmt.RUN;
        END;
        //<<E-INV
    end;

    //B2B UPG>> ------- Transfer Orders

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnBeforeInsertTransShptHeader', '', false, false)]
    local procedure OnBeforeInsertTransShptHeader(var TransShptHeader: Record "Transfer Shipment Header"; TransHeader: Record "Transfer Header"; CommitIsSuppressed: Boolean)
    begin
        IF IsValidDocForEInvoicing(TransHeader) THEN
            ValidateEInvFieldsTransfer(TransHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnAfterTransferOrderPostShipment', '', false, false)]
    local procedure OnAfterTransferOrderPostShipment(var TransferHeader: Record "Transfer Header"; CommitIsSuppressed: Boolean; var TransferShipmentHeader: Record "Transfer Shipment Header")
    begin
        InsertEInvoiceEntry(TransferShipmentHeader);
        GenerateEInvoice(TransferHeader, TransferShipmentHeader);
    end;

    LOCAL PROCEDURE InsertEInvoiceEntry(var TransShptHeader: Record "Transfer Shipment Header")
    VAR
        EInvoiceEntry: Record "E-Invoice Entry";
    BEGIN
        EInvoiceEntry.INIT;
        CASE TRUE OF
            TransShptHeader."No." <> '':
                BEGIN
                    EInvoiceEntry."Document Type" := EInvoiceEntry."Document Type"::"Transfer Shipment";
                    EInvoiceEntry."Document No." := TransShptHeader."No.";
                END;
            ELSE
                EXIT;
        END;
        EInvoiceEntry.INSERT;
    END;

    LOCAL PROCEDURE IsValidDocForEInvoicing(TransHeader: Record "Transfer Header"): Boolean
    VAR
        EInvoiceSetup: Record "E-Invoice Setup";
        SalesInvHdr: Record "Sales Invoice Header";
        EInvoiceEntry: Record "E-Invoice Entry";
        CustLedgEntry: Record "Cust. Ledger Entry";
        Location: Record Location;
    BEGIN
        IF (Location.GET(TransHeader."Transfer-from Code")) AND (Location."GST Registration No." = '') THEN
            EXIT(FALSE);
        if Location."User Name" = '' then
            exit(false);
        IF (Location.GET(TransHeader."Transfer-to Code")) AND (Location."GST Registration No." = '') THEN
            EXIT(FALSE);
        EInvoiceSetup.GET;
        IF NOT EInvoiceSetup."With Posting" THEN
            EXIT(FALSE);
        EXIT(TRUE);
    END;

    LOCAL PROCEDURE ValidateEInvFieldsTransfer(TransHeader: Record "Transfer Header")
    VAR
        ValidateEInvoiceRequest: Codeunit "Validate E-Invoice Request";
    BEGIN
        IF NOT IsValidDocForEInvoicing(TransHeader) THEN
            EXIT;
        ValidateEInvoiceRequest.CheckValidations(TransHeader);
    END;

    LOCAL PROCEDURE GenerateEInvoice(var TransferHeader: Record "Transfer Header"; var TransShptHeader: Record "Transfer Shipment Header")
    VAR
        EInvoiceSetup: Record "E-Invoice Setup";
        EInvoiceMgmt: Codeunit "E-Invoice Mgmt.";
    BEGIN
        IF NOT IsValidDocForEInvoicing(TransferHeader) THEN
            EXIT;
        EInvoiceSetup.GET;
        IF (EInvoiceSetup."With Posting") THEN BEGIN
            IF TransShptHeader."No." <> '' THEN
                EInvoiceMgmt.SetTransferShipHeader(TransShptHeader);
            EInvoiceMgmt.RUN;
        END;
    END;
    //B2B UPG<< ----- Transfer Orders

    //B2BUPGSERVICE1.0>> Service Orders
    LOCAL PROCEDURE "-----Service Order---------"();
    BEGIN
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnBeforePostWithLines', '', false, false)]

    local procedure OnBeforePostWithLines(var PassedServHeader: Record "Service Header"; var PassedServLine: Record "Service Line"; var PassedShip: Boolean; var PassedConsume: Boolean; var PassedInvoice: Boolean)
    var
        ValidateEInvoiceRequest: Codeunit "Validate E-Invoice Request";
    begin
        //>>E-INV
        IF PassedServHeader."Document Type" = PassedServHeader."Document Type"::"Credit Memo" THEN
            ValidateEInvoiceRequest.CheckValidEntriesAppliedService(PassedServHeader);
        //<<E-INV
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Service-Post", 'OnBeforeTestMandatoryFields', '', false, false)]
    local procedure OnBeforeTestMandatoryFields(var PassedServiceHeader: Record "Service Header")
    begin
        //>>E-INV
        ValidateEInvFieldsService(PassedServiceHeader);
        //<<E-INV
    end;

    LOCAL PROCEDURE IsValidDocForEInvoicingService(ServiceHeader: Record "Service Header"): Boolean;
    VAR
        EInvoiceSetup: Record "E-Invoice Setup";
        ServiceInvHdr: Record "Service Invoice Header";
        EInvoiceEntry: Record "E-Invoice Entry";
        CustLedgEntry: Record "Cust. Ledger Entry";
        IsEInvoicingDoc: Boolean;
        LocationL: Record Location;
    BEGIN
        IF (ServiceHeader."GST Customer Type" IN [ServiceHeader."GST Customer Type"::Unregistered, ServiceHeader."GST Customer Type"::" "]) THEN
            EXIT(FALSE);

        IF (ServiceHeader."Document Type" IN [ServiceHeader."Document Type"::Invoice, ServiceHeader."Document Type"::"Credit Memo"]) THEN BEGIN
            EInvoiceSetup.GET;
            IF NOT EInvoiceSetup."With Posting" THEN
                EXIT(FALSE);

            if (LocationL.Get(ServiceHeader."Location Code")) and (LocationL."User Name" = '') then
                exit(false);

            IF (ServiceHeader."Document Type" = ServiceHeader."Document Type"::"Credit Memo") AND
              (ServiceHeader."Applies-to Doc. Type" = ServiceHeader."Applies-to Doc. Type"::Invoice) AND
              (ServiceHeader."Applies-to Doc. No." <> '')
            THEN BEGIN
                ServiceInvHdr.GET(ServiceHeader."Applies-to Doc. No.");

                //IF ServiceInvHdr."Posting Date" >= DMY2DATE(1, 12, 2020) THEN BEGIN   //B2B1.0
                IF ServiceInvHdr."Posting Date" >= EInvoiceSetup."Effective Date" THEN BEGIN
                    EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Invoice", ServiceInvHdr."No.");
                    //>> ValidIRNFix
                    IsEInvoicingDoc := EInvoiceEntry."IRN No." <> '';
                    IF IsEInvoicingDoc THEN
                        //<< ValidIRNFix
                        IsEInvoicingDoc := NOT EInvoiceEntry."IRN Cancelled";
                END;  //B2B1.0


                EXIT(IsEInvoicingDoc);
            END ELSE
                IF (ServiceHeader."Applies-to ID" <> '') THEN BEGIN
                    CustLedgEntry.RESET;
                    CustLedgEntry.SETCURRENTKEY("Customer No.", Open);
                    CustLedgEntry.SETRANGE("Customer No.", ServiceHeader."Bill-to Customer No.");
                    CustLedgEntry.SETRANGE(Open, TRUE);
                    CustLedgEntry.SETRANGE("Applies-to ID", ServiceHeader."Applies-to ID");
                    IF CustLedgEntry.FINDSET THEN
                        REPEAT
                            IF ServiceInvHdr.GET(CustLedgEntry."Document No.") THEN
                                //IF ServiceInvHdr."Posting Date" >= DMY2DATE(1, 10, 2020) THEN BEGIN//Fix 01Oct2020
                                IF ServiceInvHdr."Posting Date" >= EInvoiceSetup."Effective Date" THEN BEGIN
                                    EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Invoice", ServiceInvHdr."No.");
                                    //>> ValidIRNFix
                                    IsEInvoicingDoc := EInvoiceEntry."IRN No." <> '';
                                    IF IsEInvoicingDoc THEN
                                        //<< ValidIRNFix
                                        IsEInvoicingDoc := NOT EInvoiceEntry."IRN Cancelled";
                                END ELSE
                                    IsEInvoicingDoc := TRUE;
                        UNTIL (CustLedgEntry.NEXT = 0) OR (NOT IsEInvoicingDoc);
                    EXIT(IsEInvoicingDoc);
                END;


            IsEInvoicingDoc := TRUE;
            EXIT(TRUE);
        END;
    END;

    LOCAL PROCEDURE ValidateEInvFieldsService(ServiceHeader: Record "Service Header")
    VAR
        ValidateEInvoiceRequest: Codeunit "Validate E-Invoice Request";
    BEGIN
        //>>E-INV
        IF NOT IsValidDocForEInvoicingService(ServiceHeader) THEN
            EXIT;
        ValidateEInvoiceRequest.CheckValidations(ServiceHeader);
        //<<E-INV
    END;

    /*  PROCEDURE RunServiceOrder()
      VAR
          EInvoiceSetup: Record "E-Invoice Setup";
      BEGIN
          EInvoiceSetup.GET;
          CASE EInvoiceSetup."GSP Priority" OF
              EInvoiceSetup."GSP Priority"::Adequre:
                  BEGIN
                      IF NOT TriggerEInvoiceAdequreService THEN
                          IF NOT TriggerEinvoiceMIService THEN
                              MESSAGE('%1', GETLASTERRORTEXT);
                  END;
              EInvoiceSetup."GSP Priority"::MI:
                  BEGIN
                      IF NOT TriggerEinvoiceMIService THEN
                          IF NOT TriggerEInvoiceAdequreService THEN
                              MESSAGE('%1', GETLASTERRORTEXT);
                  END;
          END;
      END;*/

    LOCAL PROCEDURE TriggerEInvoiceAdequreService(): Boolean
    BEGIN
        IF NOT GenerateAccessTokenService THEN
            EXIT(FALSE);
        IF NOT SalesEInvoiceService THEN
            EXIT(FALSE);
        EXIT(TRUE);
    END;

    /*    LOCAL PROCEDURE TriggerEinvoiceMIService(): Boolean;
        BEGIN
            IF NOT GenerateAccessTokenMIService THEN
                EXIT(FALSE);
            IF NOT SalesEInvoiceMIService THEN
                EXIT(FALSE);
            EXIT(TRUE);
        END;*/

    /*  PROCEDURE CancelIRNService(Variant: Variant);
      VAR
          EInvoiceSetup: Record "E-Invoice Setup";
      BEGIN
          EInvoiceSetup.GET;
          CASE EInvoiceSetup."GSP Priority" OF
              EInvoiceSetup."GSP Priority"::Adequre:
                  BEGIN
                      IF NOT TriggerCancelIRNAdequreService(Variant) THEN
                          IF NOT TriggerCancelIRNMIService(Variant) THEN
                              MESSAGE('%1', GETLASTERRORTEXT);
                  END;
              EInvoiceSetup."GSP Priority"::MI:
                  BEGIN
                      IF NOT TriggerCancelIRNMIService(Variant) THEN
                          IF NOT TriggerCancelIRNAdequreService(Variant) THEN
                              MESSAGE('%1', GETLASTERRORTEXT);
                  END;
          END;
      END;*/

    /* LOCAL PROCEDURE TriggerCancelIRNAdequreService(Variant: Variant): Boolean;
     BEGIN
         IF NOT GenerateAccessTokenService THEN
             EXIT(FALSE);
         IF NOT CancelIRNAdequreService(Variant) THEN
             EXIT(FALSE);
         EXIT(TRUE);
     END;*/

    /* LOCAL PROCEDURE TriggerCancelIRNMIService(Variant: Variant): Boolean;
     VAR
         RecRef: RecordRef;
     BEGIN
         RecRef.GETTABLE(Variant);
         CASE RecRef.NUMBER OF
             5992:
                 SetServiceInvHeader(Variant);
             5994:
                 SetServiceCrMemoHeader(Variant);
         END;

         IF NOT GenerateAccessTokenMIService THEN
             EXIT(FALSE);
         IF NOT CancelIrnMIService(Variant) THEN
             EXIT(FALSE);
         EXIT(TRUE);
     END;*/

    LOCAL PROCEDURE GenerateAccessTokenService(): Boolean;
    VAR
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        AccessCode: Text;
        // AccessCodeDll: DotNet AccessCodeDllDV;
        Input: Text;
        Result: Text;
        EInvoiceLog: Record "E-Invoice Log";
        EInvoiceSetup: Record "E-Invoice Setup";
        FileMgmt: Codeunit "File Management";
    BEGIN
        EInvoiceSetup.GET;
        IF EInvoiceSetup."Access Token Expiry Date" <> 0DT THEN//TokenExpiryFix
            IF EInvoiceSetup."Access Token Expiry Date" > CURRENTDATETIME THEN//TokenExpiryFix
                EXIT(TRUE);
        //B2BSaas>>
        HeadersG := HttpClientG.DefaultRequestHeaders;
        HeadersG.Add('gspappid', 'BCC53FE80ED8427A9D65FCE0B0F9413D');
        HttpRequestMessageG.GetHeaders(HeadersG);
        HeadersG.Clear();
        HeadersG.Add('gspappsecret', '1981805CG897CG4DF8GA814GCB1CEC2E8E3B');
        HttpRequestMessageG.SetRequestUri('https://gsp.adaequare.com/gsp/authenticate?grant_type=token');
        HttpRequestMessageG.Method := 'POST';
        HttpRequestMessageG.Content := HttpContentG;
        HttpClientG.Send(HttpRequestMessageG, HttpResponseMessageG);
        HttpRequestMessageG.Content.ReadAs(ResponseG);
        JobjG := ReadJSONAcctoken(ResponseG);
        JobjG.Get('access_token', JTokenGAc);
        AccessCode := JTokenGAc.AsValue().AsText();
        JobjG.Get('expires_in', JTokenExp);
        ExpiresInG := JTokenExp.AsValue().AsInteger();
        //B2BSaas<<
        EInvoiceLog.INIT;
        EInvoiceLog."Document Type" := EInvoiceLog."Document Type"::"Access Token";
        EInvoiceLog."Document No." := 'AccessToken';
        EInvoiceLog."Date & Time" := CURRENTDATETIME;
        EInvoiceLog."User Id" := USERID;
        EInvoiceLog."JSON Response Blob".CreateOutStream(OutStr);
        OutStr.WriteText(ResponseG);
        IF not HttpResponseMessageG.IsSuccessStatusCode THEN
            EInvoiceLog.Status := EInvoiceLog.Status::Failed;
        EInvoiceLog.INSERT(true);

        //CLEAR(TempBlob);
        //TempBlob.CREATEOUTSTREAM(OutStr);
        // OutStr.WRITETEXT(Input);
        //TempBlob.EXPORT(EInvoiceLog."Response Path");
        // FileMgmt.BLOBExportToServerFile(TempBlob, EInvoiceLog."Response Path");

        EInvoiceSetup."Access Token Expiry Date" := GetTokenExpiryFromResponse(ExpiresInG);//TokenExpiryFix

        IF EInvoiceLog.Status = EInvoiceLog.Status::Failed THEN
            EXIT(FALSE);


        EInvoiceSetup."Access Token Date" := CURRENTDATETIME;
        EInvoiceSetup."Access Token" := COPYSTR(AccessCode, 1, MAXSTRLEN(EInvoiceSetup."Access Token"));
        EInvoiceSetup."Access Token 2" := COPYSTR(AccessCode, MAXSTRLEN(EInvoiceSetup."Access Token") + 1, MAXSTRLEN(EInvoiceSetup."Access Token 2"));
        EInvoiceSetup.MODIFY;

        EXIT(TRUE);
    END;

    //[TryFunction] //B2BUPG1.0
    LOCAL PROCEDURE SalesEInvoiceService(): Boolean
    VAR
        // FileManagement: Codeunit "File Management";
        //FileStream: DotNet FileStreamDV;
        //FileMode: DotNet FileModeDV;
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        EInvoiceRequestAdequre: Codeunit "E-Invoice Request -Adequre";
        EInvoiceLog: Record "E-Invoice Log";
        EInvoiceSetup: Record "E-Invoice Setup";
        GUIDStorage: Text;
        ResponseFileName: Text;
        Location: Record Location;
        UserName: Text;
        Password: Text;
        GSTIN: Code[15];
    BEGIN
        EInvoiceSetup.GET;

        IF IsServiceInvoice THEN BEGIN
            // Generating JSON  >>
            EInvoiceRequestAdequre.SetServiceInvHeader(ServiceInvoiceHeader);
            EInvoiceRequestAdequre.RunServiceDocument;
            // Generating JSON  <<
            EInvoiceLog.RESET;
            EInvoiceLog.SETRANGE("Document No.", ServiceInvoiceHeader."No.");
            EInvoiceLog.SETRANGE("Document Type", EInvoiceLog."Document Type"::Invoice);
            EInvoiceLog.FINDLAST;
            Location.GET(ServiceInvoiceHeader."Location Code");
        END ELSE BEGIN
            // Generating JSON  >>
            EInvoiceRequestAdequre.SetServiceCrMemoHeader(ServiceCrMemoHeader);
            EInvoiceRequestAdequre.RunServiceDocument;
            // Generating JSON  <<
            EInvoiceLog.RESET;
            EInvoiceLog.SETRANGE("Document Type", EInvoiceLog."Document Type"::"Credit Memo");
            EInvoiceLog.SETRANGE("Document No.", ServiceCrMemoHeader."No.");
            EInvoiceLog.FINDLAST;

            Location.GET(ServiceCrMemoHeader."Location Code");
        END;

        Location.TESTFIELD("User Name");
        Location.TESTFIELD(Password);

        UserName := Location."User Name";
        Password := Location.Password;
        GSTIN := Location."GST Registration No.";
        GUIDStorage := CREATEGUID;


        HttpRequestMessageG.SetRequestUri(EInvoiceSetup."Request URL");
        HttpRequestMessageG.Method := 'POST';
        HeadersG := HttpClientG.DefaultRequestHeaders;
        HeadersG.Add('user_name', UserName);
        HeadersG.Add('password', Password);
        HeadersG.Add('gstin', GSTIN);
        HeadersG.Add('requestid', GUIDStorage);
        HeadersG.Add('Authorization', 'bearer ' + EInvoiceSetup."Access Token" + EInvoiceSetup."Access Token 2");
        HttpContentG.GetHeaders(HttpHeadersG);
        HttpHeadersG.Clear();
        HttpHeadersG.Add('Content-Type', 'application/json');
        // HttpContentG.WriteFrom(JSONText);//Attcah Body
        HttpRequestMessageG.Content := HttpContentG;
        HttpClientG.Send(HttpRequestMessageG, HttpResponseMessageG);
        HttpResponseMessageG.Content().ReadAs(ResponseG);
        //B2BSaas>>
        IF Not HttpResponseMessageG.IsSuccessStatusCode THEN
            EXIT(false);
        EInvoiceLog."Request GUID" := GUIDStorage;
        EInvoiceLog."JSON Response Blob".CreateOutStream(OutStr);
        OutStr.WriteText(ResponseG);
        EInvoiceLog."User Id" := USERID;
        // Read Json and Update Posted Document response
        //ReadResponseService(TempBlob, EInvoiceLog);

        EInvoiceLog.MODIFY;

        IF EInvoiceLog.Status = EInvoiceLog.Status::Failed THEN begin
            MESSAGE(EInvFailTxt, FORMAT(EInvoiceLog."Document Type"), EInvoiceLog."Request/Response Code");
            exit(false);
        end ELSE begin
            MESSAGE(SuccessTxt);
            exit(true);
        end;
    END;
    /*
        LOCAL PROCEDURE CreateQRCodeService(QRCodeInput: Text; VAR TempBLOBPar: Codeunit "Temp Blob");
        VAR
            FileManagement: Codeunit "File Management";
            QRCodeFileName: Text;
        BEGIN
            CLEAR(TempBLOBPar);
            QRCodeFileName := GetQRCodeService(QRCodeInput);
            FileManagement.BLOBImportFromServerFile(TempBLOBPar, QRCodeFileName);
            DeleteServerFileService(QRCodeFileName);
        END;

        LOCAL PROCEDURE GetQRCodeService(QRCodeInput: Text) QRCodeFileName: Text;
        VAR
            IBarCodeProvider: DotNet IBarCodeProviderDV;
        BEGIN
            GetBarCodeProviderService(IBarCodeProvider);
            QRCodeFileName := IBarCodeProvider.GetBarcode(QRCodeInput);
        END;

        LOCAL PROCEDURE GetBarCodeProviderService(VAR IBarCodeProvider: DotNet IBarCodeProviderDV);
        VAR
            QRCodeProvider: DotNet QRCodeProviderDV;
        BEGIN
            //IF ISNULL(IBarCodeProvider) THEN
            //IBarCodeProvider := QRCodeProvider.QRCodeProvider;

            CLEAR(QRCodeProvider);
            QRCodeProvider := QRCodeProvider.QRCodeProvider;
            IBarCodeProvider := QRCodeProvider;
        END;

        LOCAL PROCEDURE DeleteServerFileService(ServerFileName: Text);
        BEGIN
            IF ERASE(ServerFileName) THEN;
        END;
    */
    PROCEDURE SetServiceInvHeader(ServiceInvoiceHeaderBuff: Record "Service Invoice Header");
    BEGIN
        ServiceInvoiceHeader := ServiceInvoiceHeaderBuff;
        IsServiceInvoice := TRUE;
        EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Invoice", ServiceInvoiceHeaderBuff."No.");
    END;

    PROCEDURE SetServiceCrMemoHeader(ServiceCrMemoHeaderBuff: Record "Service Cr.Memo Header");
    BEGIN
        ServiceCrMemoHeader := ServiceCrMemoHeaderBuff;
        IsServiceInvoice := FALSE;
        EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Cr. Memo", ServiceCrMemoHeaderBuff."No.");
    END;

    // PROCEDURE ReadAccessTokenService(JSONText: Text) AccessCode: Text
    // VAR
    //     JSONTextReader: DotNet JsonTextReader;
    //     StringReader: DotNet StringReader;
    //     TokenType: Integer;
    //     Jav: DotNet Serialization;
    //     Dir: DotNet GenericDictionary2;
    //     Dir2: DotNet GenericDictionary2;
    // BEGIN
    //     Jav := Jav.JavaScriptSerializer;
    //     Dir := Jav.DeserializeObject(JSONText);
    //     //Dir.TryGetValue('access_token',AccessCode);
    //     //AccessCode := 'bearer'+ AccessCode;
    // END;

    PROCEDURE GetTokenExpiryFromResponseService(TempBlob: Codeunit "Temp Blob") ReturnDate: DateTime;
    VAR
        // JSONTextReader: DotNet JsonTextReader;
        // StringReader: DotNet StringReader;
        // TokenType: Integer;
        // Jav: DotNet Serialization;
        // Dir: DotNet GenericDictionary2;
        // Dir2: DotNet GenericDictionary2;
        ExpiryDuration: Integer;
        Days: Integer;
        Hours: Integer;
        Mins: Integer;
        Secs: Integer;
        ExpiryDate: Date;
        ExpiryTime: Time;
        JSONText: Text;
        ResponseValue: Variant;
        InstreamL: InStream;
        OutstreamL: OutStream;
    BEGIN
        //>>TokenExpiryFix
        //JSONText := TempBlob.ReadAsText('', TEXTENCODING::UTF8);
        // TempBlob.CreateInStream(InstreamL, TEXTENCODING::UTF8);
        // InstreamL.ReadText(JsonText);
        // TempBlob.CreateOutStream(OutstreamL, TEXTENCODING::UTF8);
        // CopyStream(OutstreamL, InstreamL);
        // OutstreamL.WriteText(JsonText);
        JobjG := ReadJSONAcctoken(ResponseG);
        JobjG.Get('expires_in', JTokenExp);
        ExpiryDuration := JTokenExp.AsValue().AsInteger();

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
        //<<TokenExpiryFix
    END;



    PROCEDURE GenerateSignedQrCodeService(QRText: Text; VAR TempBlob: Codeunit "Temp Blob");
    VAR
        QrPart2: Text;
        TempQrText: Text;
        // Convert: DotNet Convert;
        // MemoryStream: DotNet MemoryStream;
        OStream: OutStream;
        Value: Text;
        i: Integer;
        Mod4: Integer;
        AppendCount: Integer;
        InstreamL: InStream;
        OutstreamL: OutStream;
    //QRCodeGenertor: Codeunit "QR Generator";
    BEGIN
        TempQrText := QRText;
        TempQrText := CONVERTSTR(TempQrText, '.', ',');
        QrPart2 := SELECTSTR(2, TempQrText);

        //To check & Resolve base64 Valid length >>
        Mod4 := STRLEN(QrPart2) MOD 4;
        IF Mod4 > 0 THEN BEGIN
            AppendCount := 4 - Mod4;
            FOR i := 1 TO AppendCount DO
                QrPart2 += '=';
        END;
        //To check & Resolve base64 Valid length <<

        // //Part 2 is decoded from base64 >>
        // MemoryStream := MemoryStream.MemoryStream(Convert.FromBase64String(QrPart2));
        // TempBlob.CREATEOUTSTREAM(OStream);
        // MemoryStream.WriteTo(OStream);
        // MemoryStream.Close;
        //TempQrText := TempBlob.ReadAsText('', TEXTENCODING::UTF8);
        TempBlob.CreateInStream(InstreamL, TEXTENCODING::UTF8);
        InstreamL.ReadText(TempQrText);
        TempBlob.CreateOutStream(OutstreamL, TEXTENCODING::UTF8);
        CopyStream(OutstreamL, InstreamL);
        OutstreamL.WriteText(TempQrText);
        //Part 2 is decoded from base64 <<

        //QRCodeGenertor.GenerateQRCodeImage(TempQrText, TempBlob);//Creation of QR code for part 2
    END;

    LOCAL PROCEDURE "-----Cancel Service IRN----------"();
    BEGIN
    END;

    //[TryFunction] //B2BUPG1.0
    /*  PROCEDURE CancelIRNAdequreService(Variant: Variant): Boolean
      VAR
          FileManagement: Codeunit "File Management";
          FileStream: DotNet FileStreamDV;
          FileMode: DotNet FileModeDV;
          TempBlob: Codeunit "Temp Blob";
          InStr: InStream;
          OutStr: OutStream;
          EInvoiceRequestAdequre: Codeunit "E-Invoice Adequre Saas";
          EInvoiceLog: Record "E-Invoice Log";
          EInvoiceSetup: Record "E-Invoice Setup";
          GUIDStorage: Text;
          ResponseFileName: Text;
          DocumentNo: Code[20];
          RecRef: RecordRef;
          CancelServiceInvHdr: Record "Service Invoice Header";
          CancelServiceCrMHdr: Record "Service Cr.Memo Header";
          CancelSuccess: Label 'E-Invoice cancelled Successfully.';
          Location: Record 14;
      BEGIN
          EInvoiceSetup.GET;
          RecRef.GETTABLE(Variant);
          CASE RecRef.NUMBER OF
              5992:
                  CancelServiceInvHdr := Variant;
              5994:
                  CancelServiceCrMHdr := Variant;
          END;
          IF GenerateAccessTokenService() THEN
              IF NOT (EInvoiceRequestAdequre.CancelEInvoiceService(Variant)) THEN//Generate Json
                  EXIT(false);
          EInvoiceLog.RESET;
          IF CancelServiceInvHdr."No." <> '' THEN BEGIN
              EInvoiceLog.SETRANGE("Document Type", EInvoiceLog."Document Type"::Invoice);
              EInvoiceLog.SETRANGE("Document No.", CancelServiceInvHdr."No.");
              Location.GET(CancelServiceInvHdr."Location Code");
          END ELSE BEGIN
              EInvoiceLog.SETRANGE("Document Type", EInvoiceLog."Document Type"::"Credit Memo");
              EInvoiceLog.SETRANGE("Document No.", CancelServiceCrMHdr."No.");
              Location.GET(CancelServiceCrMHdr."Location Code");
          END;
          EInvoiceLog.FINDLAST;

          ResponseFileName := EInvoiceSetup."JSON Response Path" + DELCHR(EInvoiceLog."Document No.", '=', '/\-_*^@') + '_CancelResponse' + '.Json';
          GUIDStorage := CREATEGUID;

          //E-Invoice API Connection >>
          HttpWebRequest := HttpWebRequest.Create(EInvoiceSetup."Cancel Request URL");
          HttpWebRequest.Method := 'POST';
          HttpWebRequest.Headers.Add('user_name', Location."User Name");
          HttpWebRequest.Headers.Add('password', Location.Password);
          HttpWebRequest.Headers.Add('gstin', Location."GST Registration No.");
          HttpWebRequest.Headers.Add('requestid', GUIDStorage);
          HttpWebRequest.Headers.Add('Authorization', 'bearer ' + EInvoiceSetup."Access Token" + EInvoiceSetup."Access Token 2");
          //E-Invoice API Connection <<

          //Attaching Body >>
          FileStream := FileStream.FileStream(EInvoiceLog."Request Path", FileMode.Open);
          FileStream.CopyTo(HttpWebRequest.GetRequestStream);
          // Attaching Body <<

          HttpWebResponse := HttpWebRequest.GetResponse();

          InStr := HttpWebResponse.GetResponseStream;

          if File.Exists(ResponseFileName) then
              File.Erase(ResponseFileName);

          CLEAR(TempBlob);
          TempBlob.CREATEOUTSTREAM(OutStr);
          COPYSTREAM(OutStr, InStr);
          //TempBlob.EXPORT(ResponseFileName);
          FileManagement.BLOBExportToServerFile(TempBlob, ResponseFileName);

          // Read Json and Update Posted Document response
          ReadCancelResponseService(TempBlob, EInvoiceLog);

          EInvoiceLog."Request GUID" := GUIDStorage;
          EInvoiceLog."Response Path" := ResponseFileName;
          EInvoiceLog."User Id" := USERID;
          EInvoiceLog.MODIFY;

          IF EInvoiceLog.Status = EInvoiceLog.Status::Failed THEN Begin
              MESSAGE(EInvFailTxt, FORMAT(EInvoiceLog."Document Type"), EInvoiceLog."Request/Response Code");
              exit(false);
          end ELSE begin
              MESSAGE(CancelSuccess);
              exit(true);
          end;
      END;*/

    /*  LOCAL PROCEDURE ReadCancelResponseService(TempBlob: Codeunit "Temp Blob"; VAR EInvoiceLog: Record "E-Invoice Log");
      VAR
          // JSONTextReader: DotNet JsonTextReader;
          // Jav: DotNet Serialization;
          // Dir: DotNet GenericDictionary2;
          // Dir2: DotNet GenericDictionary2;
          Success: Boolean;
          JsonText: Text;
          ResponseValue: Variant;
          MessageTxt: Text;
          IRN: Text[100];
          CancelDate: DateTime;
          InstreamL: InStream;
          OutstreamL: OutStream;
      BEGIN
          //JSONText := TempBlob.ReadAsText('', TEXTENCODING::UTF8);
          TempBlob.CreateInStream(InstreamL, TEXTENCODING::UTF8);
          InstreamL.ReadText(JsonText);
          TempBlob.CreateOutStream(OutstreamL, TEXTENCODING::UTF8);
          CopyStream(OutstreamL, InstreamL);
          OutstreamL.WriteText(JsonText);

          Jav := Jav.JavaScriptSerializer;
          Dir := Jav.DeserializeObject(JsonText);

          CLEAR(ResponseValue);
          Dir.TryGetValue('success', ResponseValue);
          Success := ResponseValue;

          CLEAR(ResponseValue);
          Dir.TryGetValue('message', ResponseValue);
          MessageTxt := FORMAT(ResponseValue);

          IF EInvoiceLog."Document Type" = EInvoiceLog."Document Type"::Invoice THEN
              EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Invoice", EInvoiceLog."Document No.")
          ELSE
              EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Cr. Memo", EInvoiceLog."Document No.");

          IF Success THEN BEGIN
              Dir.TryGetValue('result', Dir2);
              Dir2.TryGetValue('Irn', ResponseValue);
              IRN := ResponseValue;
              CLEAR(ResponseValue);
              Dir2.TryGetValue('CancelDate', ResponseValue);
              CancelDate := GetDateTimeFromText(FORMAT(ResponseValue));

              EInvoiceEntry."IRN No." := IRN;
              EInvoiceEntry."IRN Cancelled" := TRUE;
              EInvoiceEntry."IRN Cancelled Date" := CancelDate;
              EInvoiceEntry."IRN Cancelled By" := USERID;
              EInvoiceEntry.MODIFY;
          END ELSE BEGIN
              EInvoiceLog.Status := EInvoiceLog.Status::Failed;

              EInvoiceEntry."IRN Cancelled Reason" := '';
              EInvoiceEntry."IRN Cancelled Remarks" := '';
              EInvoiceEntry."IRN Cancelled By" := '';
              EInvoiceEntry.MODIFY;
          END;
          EInvoiceLog."Date & Time" := CURRENTDATETIME;
          EInvoiceLog."Request/Response Code" := COPYSTR(MessageTxt, 1, MAXSTRLEN(EInvoiceLog."Request/Response Code"));
      END;*/

    LOCAL PROCEDURE GetDateTimeFromTextService(DateTimeText: Text): DateTime;
    VAR
        DateText: Text;
        Day: Integer;
        Month: Integer;
        Year: Integer;
        RetrivedTime: Time;
    BEGIN
        IF DateTimeText = '' THEN
            EXIT;
        DateText := COPYSTR(DateTimeText, 1, 10);
        EVALUATE(Year, COPYSTR(DateText, 1, 4));
        EVALUATE(Month, COPYSTR(DateText, 6, 2));
        EVALUATE(Day, COPYSTR(DateText, 9, 2));
        EVALUATE(RetrivedTime, COPYSTR(DateTimeText, STRLEN(DateText) + 2, STRLEN(DateTimeText) - 3));
        EXIT(CREATEDATETIME(DMY2DATE(Day, Month, Year), RetrivedTime));
    END;

    /*       LOCAL PROCEDURE "---MasterIndia Service---"();
           BEGIN
           END;

           LOCAL PROCEDURE GenerateAccessTokenMIService(): Boolean;
           VAR
               EInvoiceSetup: Record "E-Invoice Setup";
               EInvoiceLog: Record "E-Invoice Log";
               // GenerateAccessToken: DotNet AccessCodeDllDV;
               //B2BSaas>>
               Headers: HttpHeaders;
               RequestMessage: HttpRequestMessage;
               ResponseMessage: HttpResponseMessage;
               RequestContent: HttpContent;
               HttpClient: HttpClient;
               Jobj: JsonObject;
               Response: Text;
               AccessToken: Text;
               Jtoken: JsonToken;
               //B2BSaas<<
               AccessTokenFile: Text;
               AccessTokenCode: Text;
               LocResult: Text[250];
               TempBlob: Codeunit "Temp Blob";
               OutStr: OutStream;
               FilePath: Text[250];
               FileName: Text[250];
               FileMgmt: Codeunit "File Management";
           BEGIN
               EInvoiceSetup.GET;
               IF EInvoiceSetup."MI Access Token" <> '' THEN
                   EXIT(TRUE);

               //Generate Access Code >>
               // GenerateAccessToken := GenerateAccessToken.GenerateAccessToken();
               //GenerateAccessToken.AccessToken(AccessTokenFile, LocResult, AccessTokenCode);
               //B2BSaas>>
               Headers := HttpClient.DefaultRequestHeaders;
               Headers.Add('gspappid', 'BCC53FE80ED8427A9D65FCE0B0F9413D');
               Headers.Clear();
               Headers.Add('gspappsecret', '1981805CG897CG4DF8GA814GCB1CEC2E8E3B');
               RequestContent.GetHeaders(Headers);
               RequestMessage.SetRequestUri('https://gsp.adaequare.com/gsp/authenticate?grant_type=token');
               RequestMessage.Method := 'POST';
               RequestMessage.Content := RequestContent;
               HttpClient.Send(RequestMessage, ResponseMessage);
               ResponseMessage.Content.ReadAs(Response);
               Jobj := ReadJSONAcctoken(Response);
               Jobj.Get('access_token', Jtoken);
               AccessTokenCode := Jtoken.AsValue().AsText();
               //B2BSaas<<

               FileName := 'MIAccessTokenResponse' + DELCHR(FORMAT(TODAY), '=', '/\_-*^@') + '.Json';//TokenExpiryFix
               FilePath := EInvoiceSetup."MI Access Token Response Path" + FileName;

               TempBlob.CREATEOUTSTREAM(OutStr);
               OutStr.WRITETEXT(AccessTokenFile);
               //TempBlob.EXPORT(FilePath);
               FileMgmt.BLOBExportToServerFile(TempBlob, FilePath);

               EInvoiceLog.INIT;
               EInvoiceLog."Document Type" := EInvoiceLog."Document Type"::"Access Token";
               EInvoiceLog."Document No." := 'AccessTokenMI';
               EInvoiceLog."Date & Time" := CURRENTDATETIME;
               EInvoiceLog."User Id" := USERID;
               EInvoiceLog."Response Path" := FilePath;
               IF LocResult <> 'Success' THEN
                   EInvoiceLog.Status := EInvoiceLog.Status::Failed;
               EInvoiceLog.INSERT(true);

               IF EInvoiceLog.Status = EInvoiceLog.Status::Failed THEN
                   EXIT(FALSE);

               EInvoiceSetup."MI Access Token Date" := CURRENTDATETIME;

               IF STRLEN(AccessTokenCode) > MAXSTRLEN(EInvoiceSetup."MI Access Token") THEN BEGIN
                   EInvoiceSetup."MI Access Token" := COPYSTR(AccessTokenCode, 1, MAXSTRLEN(EInvoiceSetup."MI Access Token"));
                   EInvoiceSetup."MI Access Token 2" :=
                     COPYSTR(AccessTokenCode, MAXSTRLEN(EInvoiceSetup."MI Access Token") + 1, MAXSTRLEN(EInvoiceSetup."MI Access Token 2"));
               END ELSE
                   EInvoiceSetup."MI Access Token" := AccessTokenCode;
               EInvoiceSetup.MODIFY;

               EXIT(TRUE);
           END;

           //[TryFunction] //B2BUPG1.0
           LOCAL PROCEDURE SalesEInvoiceMIService(): Boolean
           VAR
               FileStream: DotNet FileStreamDV;
               FileMode: DotNet FileModeDV;
               EInvoiceSetup: Record "E-Invoice Setup";
               EInvoiceLog: Record "E-Invoice Log";
               ResponsePath: Text;
               InStr: InStream;
               OutStr: OutStream;
               TempBlob: Codeunit "Temp Blob";
               EInvoiceRequestMI: Codeunit "E-Invoice Request -MI";
               FileMgmt: Codeunit "File Management";
           BEGIN
               EInvoiceSetup.GET;

               IF IsServiceInvoice THEN BEGIN
                   // Generating JSON  >>
                   EInvoiceRequestMI.SetServiceInvHeader(ServiceInvoiceHeader);
                   EInvoiceRequestMI.RunServiceOrder;
                   // Generating JSON  <<

                   EInvoiceLog.RESET;
                   EInvoiceLog.SETRANGE("Document Type", EInvoiceLog."Document Type"::Invoice);
                   EInvoiceLog.SETRANGE("Document No.", ServiceInvoiceHeader."No.");
                   EInvoiceLog.FINDLAST;
                   ResponsePath := EInvoiceSetup."MI JSON Response Path" +
                                   DELCHR(SalesInvHeader."No." + '_' + FORMAT(CURRENTDATETIME), '=', '/\:*^@') + '_MI_Response' + '.Json';
               END ELSE BEGIN
                   // Generating JSON  >>
                   EInvoiceRequestMI.SetServiceCrMemoHeader(ServiceCrMemoHeader);
                   EInvoiceRequestMI.RunServiceOrder;
                   // Generating JSON  <<
                   EInvoiceLog.RESET;
                   EInvoiceLog.SETRANGE("Document Type", EInvoiceLog."Document Type"::"Credit Memo");
                   EInvoiceLog.SETRANGE("Document No.", ServiceCrMemoHeader."No.");
                   EInvoiceLog.FINDLAST;
                   ResponsePath := EInvoiceSetup."MI JSON Response Path" +
                                   DELCHR(ServiceCrMemoHeader."No." + '_' + FORMAT(CURRENTDATETIME), '=', '/\:*^@') + '_MI_Response' + '.Json';
               END;

               HttpWebRequest := HttpWebRequest.Create(EInvoiceSetup."MI Request URL");
               HttpWebRequest.Method := 'POST';
               HttpWebRequest.ContentType := 'application/json';
               //Attaching Body >>
               EInvoiceLog.TESTFIELD("Request Path");
               FileStream := FileStream.FileStream(EInvoiceLog."Request Path", FileMode.Open);
               FileStream.CopyTo(HttpWebRequest.GetRequestStream);
               //Attaching Body <<

               HttpWebResponse := HttpWebRequest.GetResponse();

               InStr := HttpWebResponse.GetResponseStream;

               CLEAR(TempBlob);
               TempBlob.CREATEOUTSTREAM(OutStr);
               COPYSTREAM(OutStr, InStr);
               //TempBlob.EXPORT(ResponsePath);
               FileMgmt.BLOBExportToServerFile(TempBlob, ResponsePath);

               IF HttpWebResponse.StatusCode <> 200 THEN
                   EXIT(false);

               // Read Json and Update Posted Document response
               ReadResponseMIService(TempBlob, EInvoiceLog);

               EInvoiceLog."Response Path" := ResponsePath;
               EInvoiceLog.MODIFY;

               IF EInvoiceLog.Status = EInvoiceLog.Status::Failed THEN begin
                   MESSAGE(EInvFailTxt, FORMAT(EInvoiceLog."Document Type"), EInvoiceLog."Request/Response Code");
                   exit(false);
               end ELSE begin
                   MESSAGE(SuccessTxt);
                   exit(true);
               end;
           END;

           PROCEDURE ReadResponseMIService(TempBlob: Codeunit "Temp Blob"; VAR EInvoiceLog: Record "E-Invoice Log");
           VAR
               JSONTextReader: DotNet JsonTextReader;
               StringReader: DotNet StringReader;
               TokenType: Integer;
               Jav: DotNet Serialization;
               Dir: DotNet GenericDictionary2;
               Dir2: DotNet GenericDictionary2;
               ActDate: Date;
               ActTime: Time;
               ActDateText: Text;
               dayValue: Integer;
               monthValue: Integer;
               yearValue: Integer;
               ActTimeText: Text;
               NewValue: Text;
               StatusTxt: Text;
               ResponseValue: Variant;
               JSONText: Text;
               QRText: Text;
               TempBlob2: Codeunit "Temp Blob";
               IRN: Text[100];
               AckNo: Text;
               AckDate: DateTime;
               MessageTxt: Text;
               BigInt: BigInteger;
               Dir3: DotNet GenericDictionary2;
               InstreamL: InStream;
               OutstreamL: OutStream;
               RecRef: RecordRef;
               FieldRef: FieldRef;
           BEGIN
               //JSONText := TempBlob.ReadAsText('', TEXTENCODING::UTF8);
               TempBlob.CreateInStream(InstreamL, TEXTENCODING::UTF8);
               InstreamL.ReadText(JsonText);
               TempBlob.CreateOutStream(OutstreamL, TEXTENCODING::UTF8);
               CopyStream(OutstreamL, InstreamL);
               OutstreamL.WriteText(JsonText);

               Jav := Jav.JavaScriptSerializer;
               Dir := Jav.DeserializeObject(JSONText);
               Dir.TryGetValue('results', Dir2);

               CLEAR(ResponseValue);
               Dir2.TryGetValue('status', ResponseValue);
               StatusTxt := FORMAT(ResponseValue);

               IF StatusTxt = 'Success' THEN BEGIN
                   Dir2.TryGetValue('message', Dir3);
                   CLEAR(ResponseValue);
                   Dir3.TryGetValue('AckNo', ResponseValue);
                   BigInt := ResponseValue;
                   CLEAR(ResponseValue);
                   Dir3.TryGetValue('AckDt', ResponseValue);
                   AckDate := GetDateTimeFromText(FORMAT(ResponseValue));
                   CLEAR(ResponseValue);
                   Dir3.TryGetValue('Irn', ResponseValue);
                   IRN := FORMAT(ResponseValue);
                   CLEAR(ResponseValue);
                   Dir3.TryGetValue('SignedQRCode', ResponseValue);
                   QRText := FORMAT(ResponseValue);
                   CreateQRCode(QRText, TempBlob2);

                   // EInvoiceEntry."IRN No." := IRN;
                   // EInvoiceEntry."QR Code" := TempBlob2.Blob;
                   // EInvoiceEntry."Ack No." := FORMAT(BigInt);
                   // EInvoiceEntry."Ack Date" := AckDate;
                   // EInvoiceEntry.MODIFY;
                   RecRef.GetTable(EInvoiceEntry);
                   FieldRef := RecRef.Field(EInvoiceEntry.FieldNo("IRN No."));
                   FieldRef.Value := IRN;
                   FieldRef := RecRef.Field(EInvoiceEntry.FieldNo("Ack No."));
                   FieldRef.Value := FORMAT(BigInt);
                   FieldRef := RecRef.Field(EInvoiceEntry.FieldNo("Ack Date"));
                   FieldRef.Value := AckDate;
                   FieldRef := RecRef.Field(EInvoiceEntry.FieldNo("QR Code"));
                   TempBlob2.ToRecordRef(RecRef, EInvoiceEntry.FieldNo("QR Code"));
                   RecRef.Modify();

                   EInvoiceLog."Ack No." := AckNo;
                   EInvoiceLog."Ack Date" := AckDate;
               END ELSE BEGIN
                   EInvoiceLog.Status := EInvoiceLog.Status::Failed;

                   CLEAR(ResponseValue);
                   Dir2.TryGetValue('errorMessage', ResponseValue);
                   MessageTxt := FORMAT(ResponseValue);
               END;
               EInvoiceLog."Date & Time" := CURRENTDATETIME;
               EInvoiceLog."Request/Response Code" := COPYSTR(MessageTxt, 1, MAXSTRLEN(EInvoiceLog."Request/Response Code"));
           END;

           //[TryFunction] //B2BUPG1.0
           PROCEDURE CancelIrnMIService(Variant: Variant): Boolean
           VAR
               FileManagement: Codeunit "File Management";
               FileStream: DotNet FileStreamDV;
               FileMode: DotNet FileModeDV;
               TempBlob: Codeunit "Temp Blob";
               InStr: InStream;
               OutStr: OutStream;
               EInvoiceRequestMI: Codeunit "E-Invoice Request -MI";
               EInvoiceLog: Record "E-Invoice Log";
               EInvoiceSetup: Record "E-Invoice Setup";
               GUIDStorage: Text;
               ResponseFileName: Text;
               DocumentNo: Code[20];
               RecRef: RecordRef;
               CancelServiceInvHdr: Record "Service Invoice Header";
               CancelServiceCrMHdr: Record "Service Cr.Memo Header";
               CancelSuccess: Label 'E-Invoice cancelled Successfully.';
           BEGIN
               EInvoiceSetup.GET;
               RecRef.GETTABLE(Variant);
               CASE RecRef.NUMBER OF
                   5992:
                       CancelServiceInvHdr := Variant;
                   5994:
                       CancelServiceCrMHdr := Variant;
               END;

               IF NOT EInvoiceRequestMI.CancelEInvoiceService(Variant) THEN//Generate Json
                   EXIT;
               EInvoiceLog.RESET;
               IF CancelServiceInvHdr."No." <> '' THEN BEGIN
                   EInvoiceLog.SETRANGE("Document Type", EInvoiceLog."Document Type"::Invoice);
                   EInvoiceLog.SETRANGE("Document No.", CancelServiceInvHdr."No.");
               END ELSE BEGIN
                   EInvoiceLog.SETRANGE("Document Type", EInvoiceLog."Document Type"::"Credit Memo");
                   EInvoiceLog.SETRANGE("Document No.", CancelServiceCrMHdr."No.");
               END;
               EInvoiceLog.FINDLAST;

               ResponseFileName := EInvoiceSetup."MI JSON Response Path" + DELCHR(EInvoiceLog."Document No.", '=', '/\-_*^@') + '_CancelResponseMI' + '.Json';
               GUIDStorage := CREATEGUID;

               //E-Invoice API Connection >>
               HttpWebRequest := HttpWebRequest.Create(EInvoiceSetup."MI Cancel Request URL");
               HttpWebRequest.Method := 'POST';
               HttpWebRequest.ContentType := 'application/json';
               //E-Invoice API Connection <<

               // Attaching Body >>
               FileStream := FileStream.FileStream(EInvoiceLog."Request Path", FileMode.Open);
               FileStream.CopyTo(HttpWebRequest.GetRequestStream);
               // Attaching Body <<

               HttpWebResponse := HttpWebRequest.GetResponse();

               InStr := HttpWebResponse.GetResponseStream;

               if File.Exists(ResponseFileName) then
                   File.Erase(ResponseFileName);

               CLEAR(TempBlob);
               TempBlob.CREATEOUTSTREAM(OutStr);
               COPYSTREAM(OutStr, InStr);
               //TempBlob.EXPORT(ResponseFileName);
               FileManagement.BLOBExportToServerFile(TempBlob, ResponseFileName);

               // Read Json and Update Posted Document response
               ReadCancelResponseMIService(TempBlob, EInvoiceLog);

               EInvoiceLog."Request GUID" := GUIDStorage;
               EInvoiceLog."Response Path" := ResponseFileName;
               EInvoiceLog."User Id" := USERID;
               EInvoiceLog.MODIFY;

               IF EInvoiceLog.Status = EInvoiceLog.Status::Failed THEN begin
                   MESSAGE(EInvFailTxt, FORMAT(EInvoiceLog."Document Type"), EInvoiceLog."Request/Response Code");
                   exit(false);
               end ELSE begin
                   MESSAGE(CancelSuccess);
                   exit(true);
               end;
           END;

           LOCAL PROCEDURE ReadCancelResponseMIService(TempBlob: Codeunit "Temp Blob"; VAR EInvoiceLog: Record "E-Invoice Log");
           VAR
               JSONTextReader: DotNet JsonTextReader;
               Jav: DotNet Serialization;
               Dir: DotNet GenericDictionary2;
               Dir2: DotNet GenericDictionary2;
               StatusTxt: Text;
               JsonText: Text;
               ResponseValue: Variant;
               MessageTxt: Text;
               IRN: Text[100];
               CancelDate: DateTime;
               Dir3: DotNet GenericDictionary2;
               InstreamL: InStream;
               OutstreamL: OutStream;
           BEGIN
               //JSONText := TempBlob.ReadAsText('', TEXTENCODING::UTF8);
               TempBlob.CreateInStream(InstreamL, TEXTENCODING::UTF8);
               InstreamL.ReadText(JsonText);
               TempBlob.CreateOutStream(OutstreamL, TEXTENCODING::UTF8);
               CopyStream(OutstreamL, InstreamL);
               OutstreamL.WriteText(JsonText);

               Jav := Jav.JavaScriptSerializer;
               Dir := Jav.DeserializeObject(JsonText);

               Dir.TryGetValue('results', Dir2);

               CLEAR(ResponseValue);
               Dir2.TryGetValue('status', ResponseValue);
               StatusTxt := FORMAT(ResponseValue);

               IF EInvoiceLog."Document Type" = EInvoiceLog."Document Type"::Invoice THEN
                   EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Invoice", EInvoiceLog."Document No.")
               ELSE
                   EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Cr. Memo", EInvoiceLog."Document No.");

               IF StatusTxt = 'Success' THEN BEGIN
                   Dir2.TryGetValue('message', Dir3);
                   CLEAR(ResponseValue);
                   Dir3.TryGetValue('Irn', ResponseValue);
                   IRN := ResponseValue;
                   CLEAR(ResponseValue);
                   Dir3.TryGetValue('CancelDate', ResponseValue);
                   CancelDate := GetDateTimeFromText(FORMAT(ResponseValue));

                   EInvoiceEntry."IRN No." := IRN;
                   EInvoiceEntry."IRN Cancelled" := TRUE;
                   EInvoiceEntry."IRN Cancelled Date" := CancelDate;
                   EInvoiceEntry."IRN Cancelled By" := USERID;
                   EInvoiceEntry.MODIFY;
               END ELSE BEGIN
                   EInvoiceLog.Status := EInvoiceLog.Status::Failed;

                   EInvoiceEntry."IRN Cancelled Reason" := '';
                   EInvoiceEntry."IRN Cancelled Remarks" := '';
                   EInvoiceEntry."IRN Cancelled By" := '';
                   EInvoiceEntry.MODIFY;
               END;
               EInvoiceLog."Date & Time" := CURRENTDATETIME;
           END;

           LOCAL PROCEDURE "---Get eInvoice by IRN Service---"();
           BEGIN
           END;*/

    /* PROCEDURE TriggerGetEInvoiceByIRNAdequareService(): Boolean;
     BEGIN
         IF NOT GenerateAccessTokenService THEN
             EXIT(FALSE);
         IF NOT GetEInvoiceByIRNService THEN
             EXIT(FALSE);
         EXIT(TRUE);
     END;

     //[TryFunction] //B2BUPG1.0
    LOCAL PROCEDURE GetEInvoiceByIRNService(): Boolean
     VAR
         FileManagement: Codeunit "File Management";
         FileStream: DotNet FileStreamDV;
         FileMode: DotNet FileModeDV;
         TempBlob: Codeunit "Temp Blob";
         InStr: InStream;
         OutStr: OutStream;
         EInvoiceRequestAdequre: Codeunit "E-Invoice Adequre Saas";
         EInvoiceLog: Record "E-Invoice Log";
         EInvoiceSetup: Record "E-Invoice Setup";
         GUIDStorage: Text;
         ResponseFileName: Text;
         Location: Record Location;
         UserName: Text;
         Password: Text;
         GSTIN: Code[15];
         GetURL: Text[250];
     BEGIN
         EInvoiceLog.INIT;

         IF IsInvoice THEN BEGIN
             EInvoiceLog."Document Type" := EInvoiceLog."Document Type"::Invoice;
             EInvoiceLog."Document No." := ServiceInvoiceHeader."No.";
         END ELSE BEGIN
             EInvoiceLog."Document Type" := EInvoiceLog."Document Type"::"Credit Memo";
             EInvoiceLog."Document No." := ServiceCrMemoHeader."No.";
         END;

         EInvoiceLog."User Id" := USERID;
         EInvoiceLog."Date & Time" := CURRENTDATETIME;
         EInvoiceLog.INSERT(true);

         EInvoiceSetup.GET;
         GetURL := EInvoiceSetup."Get IRN URL" + '?irn=' + EInvoiceEntry."IRN No.";

         IF IsInvoice THEN BEGIN
             ResponseFileName := EInvoiceSetup."JSON Response Path" +
                                 DELCHR(SalesInvHeader."No." + '_' + FORMAT(CURRENTDATETIME), '=', '/\:-*^@') + '_GetResponse' + '.Json';

             Location.GET(SalesInvHeader."Location Code");
         END ELSE BEGIN
             ResponseFileName := EInvoiceSetup."JSON Response Path" +
                                 DELCHR(SalesCrMemoHdr."No." + '_' + FORMAT(CURRENTDATETIME), '=', '/\:-*^@') + '_GetResponse' + '.Json';

             Location.GET(SalesCrMemoHdr."Location Code");
         END;

         Location.TESTFIELD("User Name");
         Location.TESTFIELD(Password);

         UserName := Location."User Name";
         Password := Location.Password;
         GSTIN := Location."GST Registration No.";
         GUIDStorage := CREATEGUID;


         //E-Invoice API Connection >>
         HttpRequestMessageG.SetRequestUri(GetURL);
         HttpRequestMessageG.Method := 'GET';
         HeadersG := HttpClientG.DefaultRequestHeaders;
         HeadersG.Add('user_name', UserName);
         HeadersG.Add('password', Password);
         HeadersG.Add('gstin', GSTIN);
         HeadersG.Add('requestid', GUIDStorage);
         HeadersG.Add('Authorization', 'bearer ' + EInvoiceSetup."Access Token" + EInvoiceSetup."Access Token 2");
         HttpContentG.GetHeaders(HttpHeadersG);
         HttpRequestMessageG.Content := HttpContentG;
         HttpClientG.Send(HttpRequestMessageG, HttpResponseMessageG);
         HttpResponseMessageG.Content().ReadAs(ResponseG);
         //E-Invoice API Connection <<

         // CLEAR(TempBlob);
         // TempBlob.CREATEOUTSTREAM(OutStr);
         // COPYSTREAM(OutStr, InStr);
         // //TempBlob.Blob.EXPORT(ResponseFileName);
         // FileManagement.BLOBExportToServerFile(TempBlob, ResponseFileName);

         // IF HttpWebResponse.StatusCode <> 200 THEN
         //     EXIT(false);
         if not HttpResponseMessageG.IsSuccessStatusCode then
             exit(false);

         EInvoiceLog."Request GUID" := GUIDStorage;
         EInvoiceLog."JSON Response Blob".CreateOutStream(OutStr);
         OutStr.WriteText(ResponseG);
         EInvoiceLog."User Id" := USERID;
         // Read Json and Update Posted Document response
         // ReadResponseService(TempBlob, EInvoiceLog);
         ReadResponseServiceJSON(ResponseG, EInvoiceLog);
         EInvoiceLog.MODIFY;

         IF EInvoiceLog.Status = EInvoiceLog.Status::Failed THEN begin
             MESSAGE(GetEInvFailTxt, EInvoiceLog."Request/Response Code");
             exit(false);
         end ELSE begin
             MESSAGE(SuccessTxt);
             exit(true);
         end;
     END;*/

    LOCAL PROCEDURE "---E-INVB2C Service---"();
    BEGIN
    END;

    /*  PROCEDURE GenerateQRCodeForB2CService(Variant: Variant);
      VAR
          QRText: Text;
          TempBlob: Codeunit "Temp Blob";
          // eInvoiceAdaequare: Codeunit 50502;
          // StringBuilderLVar: DotNet StringBuilder;
          QRCodeGenerator: Codeunit "QR Generator";
          RecRef: RecordRef;
      BEGIN
          //>>E-INVB2C >>
          EInvoiceEntry.CALCFIELDS("QR Code");
          IF EInvoiceEntry."QR Code".HASVALUE THEN
              EXIT;

          IF IsInvoice THEN
              eInvoiceAdaequare.SetServiceInvHeader(ServiceInvoiceHeader)
          ELSE
              eInvoiceAdaequare.SetServiceCrMemoHeader(ServiceCrMemoHeader);

          //eInvoiceAdaequare.GenerateFormatForB2C(Variant,StringBuilderLVar);

          CLEAR(TempBlob);
          QRText := StringBuilderLVar.ToString;
          //CreateQRCodeService(QRText, TempBlob);
          QRCodeGenerator.GenerateQRCodeImage(QRText,TempBlob);
          //EInvoiceEntry."QR Code" := TempBlob.Blob;
          //IF EInvoiceEntry."QR Code".HASVALUE THEN BEGIN
          //    EInvoiceEntry.MODIFY;
          //    MESSAGE('QR Code Generated');
          //END;
          if TempBlob.HasValue() then begin
              RecRef.GetTable(EInvoiceEntry);
              TempBlob.ToRecordRef(RecRef, EInvoiceEntry.FieldNo("QR Code"));
              RecRef.Modify();
              MESSAGE('QR Code Generated');
          end;
          //>>E-INVB2C <<
      END;*/

    /*LOCAL PROCEDURE GetIRNFromDuplicateIRNResponseService(JSONText: Text; VAR EInvoiceLog: Record "E-Invoice Log");
    VAR
        Dir: DotNet GenericDictionary2;
        Dir2: DotNet GenericDictionary2;
    BEGIN
        // Dir.TryGetValue('result',Dir2);
        // CLEAR(ResponseValue);
        // Dir2.TryGetValue('AckNo',ResponseValue);
        // BigInt := ResponseValue;
    END;*/

    /* LOCAL PROCEDURE ReadJsonDuplicateIRNService(VAR String: DotNet String;VAR IRN: Text);
     VAR
         // JsonToken: DotNet JsonTokenDV;
         // PrefixArray: DotNet Array;
         // PrefixString: DotNet String;
         PropertyName: Text;
         ColumnNo: Integer;
         InArray: ARRAY[250] OF Boolean;
         // StringReader: DotNet StringReader;
         // JsonTextReader: DotNet JsonTextReader;
         TempPostingExchField: Record 1221;
     BEGIN
         TempPostingExchField.DELETEALL;
         PrefixArray := PrefixArray.CreateInstance(GETDOTNETTYPE(String), 250);
         StringReader := StringReader.StringReader(String);
         JsonTextReader := JsonTextReader.JsonTextReader(StringReader);
         WHILE JsonTextReader.Read DO
             CASE TRUE OF
                 JsonTextReader.TokenType.CompareTo(JsonToken.StartObject) = 0:
                     ;
                 JsonTextReader.TokenType.CompareTo(JsonToken.StartArray) = 0:
                     BEGIN
                         InArray[JsonTextReader.Depth + 1] := TRUE;
                         ColumnNo := 0;
                     END;
                 JsonTextReader.TokenType.CompareTo(JsonToken.StartConstructor) = 0:
                     ;
                 JsonTextReader.TokenType.CompareTo(JsonToken.PropertyName) = 0:
                     BEGIN
                         PrefixArray.SetValue(JsonTextReader.Value, JsonTextReader.Depth - 1);
                         IF JsonTextReader.Depth > 1 THEN BEGIN
                             PrefixString := PrefixString.Join('.', PrefixArray, 0, JsonTextReader.Depth - 1);
                             IF PrefixString.Length > 0 THEN
                                 PropertyName := PrefixString.ToString + '.' + FORMAT(JsonTextReader.Value, 0, 9)
                             ELSE
                                 PropertyName := FORMAT(JsonTextReader.Value, 0, 9);
                         END ELSE
                             PropertyName := FORMAT(JsonTextReader.Value, 0, 9);
                     END;
                 JsonTextReader.TokenType.CompareTo(JsonToken.String) = 0,
                 JsonTextReader.TokenType.CompareTo(JsonToken.Integer) = 0,
                 JsonTextReader.TokenType.CompareTo(JsonToken.Float) = 0,
                 JsonTextReader.TokenType.CompareTo(JsonToken.Boolean) = 0,
                 JsonTextReader.TokenType.CompareTo(JsonToken.Date) = 0,
                 JsonTextReader.TokenType.CompareTo(JsonToken.Bytes) = 0:
                     BEGIN
                         TempPostingExchField."Data Exch. No." := JsonTextReader.Depth;
                         TempPostingExchField."Line No." := JsonTextReader.LineNumber;
                         TempPostingExchField."Column No." := ColumnNo;
                         TempPostingExchField."Node ID" := PropertyName;
                         TempPostingExchField.Value := FORMAT(JsonTextReader.Value, 0, 9);
                         TempPostingExchField."Data Exch. Line Def Code" := JsonTextReader.TokenType.ToString;
                         TempPostingExchField.INSERT;
                     END;
                 JsonTextReader.TokenType.CompareTo(JsonToken.EndConstructor) = 0:
                     ;
                 JsonTextReader.TokenType.CompareTo(JsonToken.EndArray) = 0:
                     InArray[JsonTextReader.Depth + 1] := FALSE;
                 JsonTextReader.TokenType.CompareTo(JsonToken.EndObject) = 0:
                     IF JsonTextReader.Depth > 0 THEN
                         IF InArray[JsonTextReader.Depth] THEN
                             ColumnNo += 1;
             END;

         TempPostingExchField.RESET;
         TempPostingExchField.SETRANGE("Node ID", 'result..Desc.Irn');
         IF TempPostingExchField.FINDFIRST THEN
             IRN := TempPostingExchField.Value;
     END;*/

    /*  [EventSubscriber(ObjectType::Codeunit, 5980, 'OnAfterPostServiceDoc', '', false, false)]
      LOCAL PROCEDURE EventSubServiceOrder(VAR ServiceHeader: Record 5900; ServShipmentNo: Code[20]; ServInvoiceNo: Code[20]; ServCrMemoNo: Code[20]);
      VAR
          ServiceInvoiceHeaderLrec: Record "Service Invoice Header";
          ServiceCrMemoHeaderLrec: Record "Service Cr.Memo Header";
          EInvoiceSetup: Record "E-Invoice Setup";
          EInvoiceMgmt: Codeunit "E-Invoice Mgmt.";
      BEGIN
          //>>E-INV
          EInvoiceEntry.INIT;
          CASE TRUE OF
              ServInvoiceNo <> '':
                  BEGIN
                      EInvoiceEntry."Document Type" := EInvoiceEntry."Document Type"::"Service Invoice";
                      EInvoiceEntry."Document No." := ServInvoiceNo;
                      ServiceInvoiceHeaderLrec.GET(ServInvoiceNo);
                  END;
              ServCrMemoNo <> '':
                  BEGIN
                      EInvoiceEntry."Document Type" := EInvoiceEntry."Document Type"::"Service Cr. Memo";
                      EInvoiceEntry."Document No." := ServCrMemoNo;
                      ServiceCrMemoHeaderLrec.GET(ServCrMemoNo);
                  END;
              ELSE
                  EXIT;
          END;
          EInvoiceEntry.INSERT;

          EInvoiceSetup.GET;
          IF (EInvoiceSetup."With Posting") THEN BEGIN
              IF ServInvoiceNo <> '' THEN
                  EInvoiceMgmt.SetServiceInvHeader(ServiceInvoiceHeaderLrec)
              ELSE
                  IF ServCrMemoNo <> '' THEN
                      EInvoiceMgmt.SetServiceCrMemoHeader(ServiceCrMemoHeaderLrec);
              EInvoiceMgmt.RunServiceOrder;
          END;

          //<<E-INV
      END;*/
    //B2BUPGSERVICE1.0<< Service Orders

    local procedure ReadJson(data: Text) result: JsonObject;
    begin
        result.ReadFrom(data);
    end;

    procedure ReadResponseJSON(ResponseL: Text; var EInvoiceLog: Record "E-Invoice Log")
    var
        JSONOBJL: JsonObject;
        SuccessL: Boolean;
        RecRef: RecordRef;
        FieldRef: FieldRef;
        BigInt: BigInteger;
        AckDate: DateTime;
        QRText: Text;
        IRN: Text;
        TempBlob2: Codeunit "Temp Blob";
        Success: Boolean;
        ResultL: Text;
        JSTokenRes: JsonToken;
        messageL: Text;
        JSONOBJ2: JsonObject;
        JSTOken2: JsonToken;
        QrCode: Codeunit "QR Generator";
        OutstreamL: OutStream;
        InstreamL: InStream;
        AckDate1: Text;

    begin
        EInvoiceLog."JSON Response Blob".CreateOutStream(OutstreamL);
        OutstreamL.WriteText(ResponseL);
        JSONOBJL := ReadJson(ResponseL);
        if JSONOBJL.Get('success', JSTokenRes) then
            Success := JSTokenRes.AsValue().AsBoolean();
        Clear(JSTokenRes);

        if JSONOBJL.Get('message', JSTokenRes) then
            messageL := JSTokenRes.AsValue().AsText();
        Clear(JSTokenRes);

        if Success then begin
            JSONOBJL.Get('result', JSTokenRes);
            if JSTokenRes.IsObject() then begin
                JSTokenRes.WriteTo(ResultL);
                JSONOBJ2.ReadFrom(ResultL);

                JSONOBJ2.Get('AckNo', JSTOken2);
                BigInt := JSTOken2.AsValue().AsBigInteger();
                Clear(JSTOken2);

                JSONOBJ2.Get('AckDt', JSTOken2);
                // Evaluate(AckDate1,format(JSTOken2.AsValue()));
                AckDate1 := JSTOken2.AsValue().AsText();
                Clear(JSTOken2);
                AckDate := GetDateTimeFromText(FORMAT(AckDate1));

                JSONOBJ2.Get('Irn', JSTOken2);
                IRN := JSTOken2.AsValue().AsText();
                Clear(JSTOken2);

                JSONOBJ2.Get('SignedQRCode', JSTOken2);
                QRText := JSTOken2.AsValue().AsText();
                QrCode.GenerateQRCodeImage(QRText, TempBlob2);
            end;
            if IsInvoice then begin
                RecRef.GetTable(SalesInvHeader);
                FieldRef := RecRef.Field(SalesInvHeader.FieldNo("IRN Hash"));
                FieldRef.Value := IRN;
                FieldRef := RecRef.Field(SalesInvHeader.FieldNo("Acknowledgement No."));
                FieldRef.Value := FORMAT(BigInt);
                FieldRef := RecRef.Field(SalesInvHeader.FieldNo("Acknowledgement Date"));
                FieldRef.Value := AckDate;
                FieldRef := RecRef.Field(SalesInvHeader.FieldNo("QR Code"));
                TempBlob2.ToRecordRef(RecRef, SalesInvHeader.FieldNo("QR Code"));
                RecRef.Modify();
            end;
            RecRef.GetTable(EInvoiceEntry);
            FieldRef := RecRef.Field(EInvoiceEntry.FieldNo("IRN No."));
            FieldRef.Value := IRN;
            FieldRef := RecRef.Field(EInvoiceEntry.FieldNo("Ack No."));
            FieldRef.Value := FORMAT(BigInt);
            FieldRef := RecRef.Field(EInvoiceEntry.FieldNo("Ack Date"));
            FieldRef.Value := AckDate;
            FieldRef := RecRef.Field(EInvoiceEntry.FieldNo("QR Code"));
            TempBlob2.ToRecordRef(RecRef, EInvoiceEntry.FieldNo("QR Code"));
            RecRef.Modify();
            if JSONOBJ2.Get('EwbNo', JSTOken2) then
                InsertEwayEntry(EInvoiceLog."Document No.", JSONOBJ2);
        end else
            EInvoiceLog.Status := EInvoiceLog.Status::Failed;
        EInvoiceLog.IRN := IRN;
        EInvoiceLog."Ack No." := Format(BigInt);
        EInvoiceLog."Ack Date" := AckDate;
        EInvoiceLog."Date & Time" := CURRENTDATETIME;
        EInvoiceLog."Request/Response Code" := COPYSTR(messageL, 1, MAXSTRLEN(EInvoiceLog."Request/Response Code"));
    end;

    procedure ReadCancelResponseJSON(ResponseL: Text; var EInvoiceLog: Record "E-Invoice Log")
    var
        JSONOBJL: JsonObject;
        JSTokenSu: JsonToken;
        JSTokenMes: JsonToken;
        JSTokenRes: JsonToken;
        SuccessL: Boolean;
        JSTokencanDt: JsonToken;
        JSIRN: JsonToken;
        JSTokenSign: JsonToken;
        SuccessTxt: Text;
        MessageTxt: Text;
        Success: Boolean;
        CancelDate: DateTime;
        IRN: Text;
        JSONOBJ2: JsonObject;
        JSTOken2: JsonToken;
        ResultL: Text;
        OutS: OutStream;
        CancelDateT: Text;
    begin
        EInvoiceLog."JSON Response Blob".CreateOutStream(OutS);
        OutS.WriteText(ResponseL);
        JSONOBJL := ReadJson(ResponseL);

        JSONOBJL.Get('success', JSTokenSu);
        SuccessTxt := JSTokenSu.AsValue().AsText();
        Success := JSTokenSu.AsValue().AsBoolean();

        JSONOBJL.Get('message', JSTokenMes);
        MessageTxt := JSTokenMes.AsValue().AsText();

        CASE EInvoiceLog."Document Type" OF
            EInvoiceLog."Document Type"::Invoice:
                EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Invoice", EInvoiceLog."Document No.");
            EInvoiceLog."Document Type"::"Credit Memo":
                EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Cr. Memo", EInvoiceLog."Document No.");
            EInvoiceLog."Document Type"::"Transfer Shipment":
                EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Transfer Shipment", EInvoiceLog."Document No.");
        END;

        IF Success THEN BEGIN
            JSONOBJL.Get('result', JSTokenRes);
            if JSTokenRes.IsObject() then begin
                JSTokenRes.WriteTo(ResultL);
                JSONOBJ2.ReadFrom(ResultL);
                JSONOBJL.Get('result', JSTokenRes);

                JSONOBJ2.Get('Irn', JSIRN);
                IRN := JSIRN.AsValue().AsText();

                JSONOBJ2.Get('CancelDate', JSTokencanDt);
                CancelDateT := JSTokencanDt.AsValue().AsText();
                CancelDate := GetDateTimeFromText(CancelDateT);
            END;
            EInvoiceEntry."IRN No." := IRN;
            EInvoiceEntry."IRN Cancelled" := TRUE;
            EInvoiceEntry."IRN Cancelled Date" := CancelDate;
            EInvoiceEntry."IRN Cancelled By" := USERID;
            EInvoiceEntry.MODIFY;
        END ELSE BEGIN
            EInvoiceLog.Status := EInvoiceLog.Status::Failed;
            EInvoiceEntry."IRN Cancelled Reason" := '';
            EInvoiceEntry."IRN Cancelled Remarks" := '';
            EInvoiceEntry."IRN Cancelled By" := '';
            EInvoiceEntry.MODIFY;
        END;
        EInvoiceLog."Date & Time" := CURRENTDATETIME;
        EInvoiceLog."Request/Response Code" := COPYSTR(MessageTxt, 1, MAXSTRLEN(EInvoiceLog."Request/Response Code"));

    end;

    procedure ReadResponseServiceJSON(ResponseL: Text; var EInvoiceLog: Record "E-Invoice Log")
    var
        JSONOBJL: JsonObject;
        JSTokenSu: JsonToken;
        JSTokenMes: JsonToken;
        JSTokenAcc: JsonToken;
        SuccessL: Boolean;
        JSTokenAdt: JsonToken;
        JSIRN: JsonToken;
        JSTokenSign: JsonToken;
        Success: Boolean;
        BigInt: BigInteger;
        AckDate: DateTime;
        IRN: Text;
        QRText: Text;
        RecRef: RecordRef;
        FieldRef: FieldRef;
        TempBlob2: Codeunit "Temp Blob";
    begin
        JSONOBJL := ReadJson(ResponseL);
        JSONOBJL.Get('success', JSTokenSu);
        JSONOBJL.Get('message', JSTokenMes);
        Success := JSTokenSu.AsValue().AsBoolean();
        // Success := ResponseL;
        IF Success THEN BEGIN

            JSONOBJL.Get('AckNo', JSTokenAcc);
            BigInt := JSTokenAcc.AsValue().AsBigInteger();
            JSONOBJL.Get('AckDt', JSTokenAdt);
            AckDate := JSTokenAdt.AsValue().AsDateTime();
            JSONOBJL.Get('Irn', JSIRN);
            IRN := JSIRN.AsValue().AsText();
            JSONOBJL.Get('SignedQRCode', JSTokenSign);
            QRText := JSTokenSign.AsValue().AsText();


            if IsInvoice then begin
                RecRef.GetTable(SalesInvHeader);
                FieldRef := RecRef.Field(SalesInvHeader.FieldNo("IRN Hash"));
                FieldRef.Value := IRN;
                FieldRef := RecRef.Field(SalesInvHeader.FieldNo("Acknowledgement No."));
                FieldRef.Value := FORMAT(BigInt);
                FieldRef := RecRef.Field(SalesInvHeader.FieldNo("Acknowledgement Date"));
                FieldRef.Value := AckDate;
                FieldRef := RecRef.Field(SalesInvHeader.FieldNo(IsJSONImported));
                FieldRef.Value := true;
                FieldRef := RecRef.Field(SalesInvHeader.FieldNo("QR Code"));
                TempBlob2.ToRecordRef(RecRef, SalesInvHeader.FieldNo("QR Code"));
                RecRef.Modify();
            end;
            RecRef.GetTable(EInvoiceEntry);
            FieldRef := RecRef.Field(EInvoiceEntry.FieldNo("IRN No."));
            FieldRef.Value := IRN;
            FieldRef := RecRef.Field(EInvoiceEntry.FieldNo("Ack No."));
            FieldRef.Value := FORMAT(BigInt);
            FieldRef := RecRef.Field(EInvoiceEntry.FieldNo("Ack Date"));
            FieldRef.Value := AckDate;
            FieldRef := RecRef.Field(EInvoiceEntry.FieldNo("QR Code"));
            TempBlob2.ToRecordRef(RecRef, EInvoiceEntry.FieldNo("QR Code"));
            RecRef.Modify();
            //B2BUPG1.0<<
            EInvoiceLog.IRN := IRN;
            EInvoiceLog."Ack No." := EInvoiceEntry."Ack No.";
            EInvoiceLog."Ack Date" := EInvoiceEntry."Ack Date";
        END ELSE
            EInvoiceLog.Status := EInvoiceLog.Status::Failed;
        EInvoiceLog."Date & Time" := CURRENTDATETIME;
        EInvoiceLog."Request/Response Code" := COPYSTR(JSTokenMes.AsValue().AsText(), 1, MAXSTRLEN(EInvoiceLog."Request/Response Code"));
    end;

    local procedure AcquireToken(
           UserName: Text;
           Password: Text;
           ClientId: Text;
           ClientSecret: Text;
           JAccessToken: JsonObject): Boolean;
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        ContentText: Text;
        ResponseText: Text;
        IsSuccess: Boolean;
        DotNetUriBuilder: Codeunit Uri;
        TokenEndpointURL: Text;
    begin

        ContentText := 'grant_type=password' +
            '&username=' + DotNetUriBuilder.EscapeDataString(UserName) +
            '&password=' + DotNetUriBuilder.EscapeDataString(Password) +
            '&client_id=' + DotNetUriBuilder.EscapeDataString(ClientId) +
            '&client_secret=' + DotNetUriBuilder.EscapeDataString(ClientSecret);
        Content.WriteFrom(ContentText);

        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');

        Request.Method := 'POST';
        TokenEndpointURL := 'https://clientbasic.mastersindia.co/oauth/access_token';
        Request.SetRequestUri(TokenEndpointURL);
        Request.Content(Content);

        if Client.Send(Request, Response) then
            if Response.IsSuccessStatusCode() then begin
                if Response.Content.ReadAs(ResponseText) then
                    IsSuccess := JAccessToken.ReadFrom(ResponseText);
            end else
                if Response.Content.ReadAs(ResponseText) then
                    JAccessToken.ReadFrom(ResponseText);
        exit(IsSuccess);
    end;

    local procedure InsertEwayEntry(DocNo: Code[20]; JSONOBJ2: JsonObject)
    var
        EWayEntry: Record "E-Way Billing Entry";
        JSTOken2: JsonToken;
    begin
        EWayEntry.Init();
        EWayEntry."Transaction Type" := EWayEntry."Transaction Type"::"Sales Invoice";
        EWayEntry."Document No." := DocNo;

        Clear(JSTOken2);
        if JSONOBJ2.Get('EwbNo', JSTOken2) then
            if not JSTOken2.AsValue().IsNull then
                EWayEntry."E-Way Bill No." := JSTOken2.AsValue().AsBigInteger();

        Clear(JSTOken2);
        if JSONOBJ2.Get('EwbDt', JSTOken2) then
            if not JSTOken2.AsValue().IsNull then
                Evaluate(EWayEntry."E-Way Bill Date", JSTOken2.AsValue.AsText());

        Clear(JSTOken2);
        if JSONOBJ2.Get('EwbValidTill', JSTOken2) then
            if not JSTOken2.AsValue().IsNull then
                Evaluate(EWayEntry."E-Way Valid Upto", JSTOken2.AsValue.AsText());

        EWayEntry.Insert();
    end;
}

