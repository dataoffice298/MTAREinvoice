page 50096 "E-Way Billing Setup"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "E-Way Billing Setup";
    UsageCategory = Administration;
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("E-Way Bill Generation Type"; Rec."E-Way Bill Generation Type")
                {
                    ApplicationArea = All;
                    Caption = 'E-Way Bill Generation Type';
                    ToolTip = 'Specifies the value of the E-Way Bill Generation Type field.';
                }
                field("With Posting"; Rec."With Posting")
                {
                    ApplicationArea = All;
                    Caption = 'With Posting';
                    ToolTip = 'Specifies the value of the With Posting field.';
                }
                field("S.O EWay Applicability"; Rec."S.O EWay Applicability")
                {
                    ApplicationArea = All;
                    Caption = 'S.O EWay Applicability';
                    ToolTip = 'Specifies the value of the S.O EWay Applicability field.';
                }
                field("GSP Priority"; Rec."GSP Priority")
                {
                    ApplicationArea = All;
                    Caption = 'GSP Priority';
                    ToolTip = 'Specifies the value of the GSP Priority field.';
                }
                field("E-Way File Storage Path"; Rec."E-Way File Storage Path")
                {
                    Caption = 'E-Way File Storage Path';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Way File Storage Path field.';
                }
                field("Vehicle Reason"; Rec."Vehicle Reason")
                {
                    ApplicationArea = All;
                    Caption = 'Vehicle Reason';
                    ToolTip = 'Specifies the value of the Vehicle Reason field.';
                }
                field("Vehicle Remarks"; Rec."Vehicle Remarks")
                {
                    ApplicationArea = All;
                    Caption = 'Vehicle Remarks';
                    ToolTip = 'Specifies the value of the Vehicle Remarks field.';
                }
                field("Reject E-Way No. Series"; Rec."Reject E-Way No. Series")
                {
                    ApplicationArea = All;
                    Caption = 'Reject E-Way No. Series';
                    ToolTip = 'Specifies the value of the Reject E-Way No. Series field.';
                }
                field("GST Logo"; Rec."GST Logo")
                {
                    ApplicationArea = All;
                    Caption = 'GST Logo';
                    ToolTip = 'Specifies the value of the GST Logo field.';
                }
                field("Applicable On Sales Credit Mem"; Rec."Applicable On Sales Credit Mem")
                {
                    ApplicationArea = All;
                    Caption = 'Applicable On Sales Credit Mem';
                    ToolTip = 'Specifies the value of the Applicable On Sales Credit Mem field.';
                }
                field("E-Invoice Applicable"; Rec."E-Invoice Applicable")
                {
                    ApplicationArea = All;
                    Caption = 'E-Invoice Applicable';
                    ToolTip = 'Specifies the value of the E-Invoice Applicable field.';
                }
                //PIN2PIN>>
                field("Distance Calculation"; Rec."Distance Calculation")
                {
                    ApplicationArea = All;
                    Caption = 'Distance Calculation';
                    ToolTip = 'Specifies the value of the Distance Calculation field.';
                }
                //PIN2PIN<<
            }
            group("Adequre URL's")
            {
                Caption = 'Adequre URL''s';
                field("Client ID"; Rec."Client ID")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("Client Secret"; Rec."Client Secret")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                }
                field("Access Token Period"; Rec."Access Token Period")
                {
                    ApplicationArea = All;
                    Caption = 'Access Token Period';
                    ToolTip = 'Specifies the value of the Access Token Period field.';
                }
                field("Access Token Date"; Rec."Access Token Date")
                {
                    ApplicationArea = All;
                    Caption = 'Access Token Date';
                    ToolTip = 'Specifies the value of the Access Token Date field.';
                }
                field("Access Token"; Rec."Access Token")
                {
                    Editable = false;
                    ApplicationArea = All;
                    Caption = 'Access Token';
                    ToolTip = 'Specifies the value of the Access Token field.';
                }
                field("Access Token 2"; Rec."Access Token 2")
                {
                    Editable = false;
                    ApplicationArea = All;
                    Caption = 'Access Token 2';
                    ToolTip = 'Specifies the value of the Access Token 2 field.';
                }
                field("User Name"; Rec."User Name")
                {
                    Visible = false;
                    ApplicationArea = All;
                    Caption = 'User Name';
                    ToolTip = 'Specifies the value of the User Name field.';
                }
                field(Password; Rec.Password)
                {
                    ExtendedDatatype = Masked;
                    Visible = false;
                    ApplicationArea = All;
                    Caption = 'Password';
                    ToolTip = 'Specifies the value of the Password field.';
                }
                field(GSTIN; Rec.GSTIN)
                {
                    Visible = false;
                    ApplicationArea = All;
                    Caption = 'GSTIN';
                    ToolTip = 'Specifies the value of the GSTIN field.';
                }
                field("Access Token Expiry Date"; Rec."Access Token Expiry Date")
                {
                    Editable = false;
                    ApplicationArea = All;
                    Caption = 'Access Token Expiry Date';
                    ToolTip = 'Specifies the value of the Access Token Expiry Date field.';
                }
                field("E-Way Request URL"; Rec."E-Way Request URL")
                {
                    ApplicationArea = All;
                    Caption = 'E-Way Request URL';
                    ToolTip = 'Specifies the value of the E-Way Request URL field.';
                }
                field("Vehicle Request URL"; Rec."Vehicle Request URL")
                {
                    ApplicationArea = All;
                    Caption = 'Vehicle Request URL';
                    ToolTip = 'Specifies the value of the Vehicle Request URL field.';
                }
                field("E-Way Cancel URL"; Rec."E-Way Cancel URL")
                {
                    ApplicationArea = All;
                    Caption = 'E-Way Cancel URL';
                    ToolTip = 'Specifies the value of the E-Way Cancel URL field.';
                }
                field("E-Way Reject URL"; Rec."E-Way Reject URL")
                {
                    ApplicationArea = All;
                    Caption = 'E-Way Reject URL';
                    ToolTip = 'Specifies the value of the E-Way Reject URL field.';
                }
                field("Extend Validity URL"; Rec."Extend Validity URL")
                {
                    ApplicationArea = All;
                    Caption = 'Extend Validity URL';
                    ToolTip = 'Specifies the value of the Extend Validity URL field.';
                }
                field("Update Transporter URL"; Rec."Update Transporter URL")
                {
                    ApplicationArea = All;
                    Caption = 'Update Transporter URL';
                    ToolTip = 'Specifies the value of the Update Transporter URL field.';
                }
                //PIN2PIN>>
                field("Pin 2 Pin Distance URL"; Rec."Pin 2 Pin Distance URL")
                {
                    ApplicationArea = All;
                    Caption = 'Pin 2 Pin Distance URL';
                    ToolTip = 'Specifies the value of the Pin 2 Pin Distance URL field.';
                }
                //PIN2PIN<<
            }
            group("Master India URL's")
            {
                Caption = 'Master India URL''s';
                field("MI Access Token Date"; Rec."MI Access Token Date")
                {
                    ApplicationArea = All;
                    Caption = 'Access Token Date';
                    ToolTip = 'Specifies the value of the Access Token Date field.';
                }
                field("MI Access Token"; Rec."MI Access Token")
                {
                    ApplicationArea = All;
                    Caption = 'Access Token';
                    ToolTip = 'Specifies the value of the Access Token field.';
                }
                field("MI Access Token 2"; Rec."MI Access Token 2")
                {
                    ApplicationArea = All;
                    Caption = 'Access Token 2';
                    ToolTip = 'Specifies the value of the Access Token 2 field.';
                }
                field("MI Access Token Period"; Rec."MI Access Token Period")
                {
                    ApplicationArea = All;
                    Caption = 'Access Token Period';
                    ToolTip = 'Specifies the value of the Access Token Period field.';
                }
                field("MI Access Token Expiry Date"; Rec."MI Access Token Expiry Date")
                {
                    ApplicationArea = All;
                    Caption = 'Access Token Expiry Date';
                    ToolTip = 'Specifies the value of the Access Token Expiry Date field.';
                }
                field("MI E-Way Request URL"; Rec."MI E-Way Request URL")
                {
                    ApplicationArea = All;
                    Caption = 'MI E-Way Request URL';
                    ToolTip = 'Specifies the value of the MI E-Way Request URL field.';
                }
                field("MI Vehicle Request URL"; Rec."MI Vehicle Request URL")
                {
                    ApplicationArea = All;
                    Caption = 'MI Vehicle Request URL';
                    ToolTip = 'Specifies the value of the MI Vehicle Request URL field.';
                }
                field("MI E-Way Cancel URL"; Rec."MI E-Way Cancel URL")
                {
                    ApplicationArea = All;
                    Caption = 'MI E-Way Cancel URL';
                    ToolTip = 'Specifies the value of the MI E-Way Cancel URL field.';
                }
                field("MI E-Way Reject URL"; Rec."MI E-Way Reject URL")
                {
                    ApplicationArea = All;
                    Caption = 'MI E-Way Reject URL';
                    ToolTip = 'Specifies the value of the MI E-Way Reject URL field.';
                }
                field("MI Extend Validity URL"; Rec."MI Extend Validity URL")
                {
                    ApplicationArea = All;
                    Caption = 'MI Extend Validity URL';
                    ToolTip = 'Specifies the value of the MI Extend Validity URL field.';
                }
                field("MI Update Transporter URL"; Rec."MI Update Transporter URL")
                {
                    ApplicationArea = All;
                    Caption = 'MI Update Transporter URL';
                    ToolTip = 'Specifies the value of the MI Update Transporter URL field.';
                }
                field("MI Reject E-Way No. Series"; Rec."MI Reject E-Way No. Series")
                {
                    ApplicationArea = All;
                    Caption = 'Reject E-Way No. Series';
                    ToolTip = 'Specifies the value of the Reject E-Way No. Series field.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("Auto-Update")
            {
                Caption = 'Auto-Update';
                action("Update E-Invoice Setup")
                {
                    Caption = 'Update E-Way Setup';
                    Image = UpdateXML;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = VisableAutoUpdate;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Update E-Way Setup action.';

                    trigger OnAction()
                    var
                        EWaySetup: Record "E-Way Billing Setup";

                    begin
                        EWaySetup.INIT;
                        EWaySetup."With Posting" := TRUE;
                        EWaySetup."User Name" := '05AAACG2115R1ZN';
                        EWaySetup.Password := 'abc123@@';
                        EWaySetup.GSTIN := '05AAACG2115R1ZN';
                        EVALUATE(EWaySetup."Access Token Period", '29D');
                        EWaySetup."E-Way Request URL" := 'https://gsp.adaequare.com/test/enriched/ewb/ewayapi?action=GENEWAYBILL';
                        EWaySetup."Vehicle Request URL" := 'https://gsp.adaequare.com/test/enriched/ewb/ewayapi?action=VEHEWB';
                        EWaySetup."E-Way Cancel URL" := 'https://gsp.adaequare.com/test/enriched/ewb/ewayapi?action=CANEWB';
                        EWaySetup."E-Way Reject URL" := 'https://gsp.adaequare.com/test/enriched/ewb/ewayapi?action=REJEWB';
                        EWaySetup."Extend Validity URL" := 'http://gsp.adaequare.com/test/enriched/ewb/ewayapi?action=EXTENDVALIDITY';
                        EWaySetup."Update Transporter URL" := 'http://gsp.adaequare.com/test/enriched/ewb/ewayapi?action=UPDATETRANSPORTER';
                        EVALUATE(EWaySetup."MI Access Token Period", '29D');
                        EWaySetup."MI E-Way Request URL" := 'https://clientbasic.mastersindia.co/ewayBillsGenerate';
                        EWaySetup."MI Vehicle Request URL" := 'https://clientbasic.mastersindia.co/updateVehicleNumber';
                        EWaySetup."MI E-Way Cancel URL" := 'https://clientbasic.mastersindia.co/ewayBillCancel';
                        EWaySetup."MI E-Way Reject URL" := 'https://clientbasic.mastersindia.co/ewayBillReject';
                        EWaySetup."MI Extend Validity URL" := 'https://clientbasic.mastersindia.co/ewayBillValidityExtend';
                        EWaySetup."MI Update Transporter URL" := 'https://clientbasic.mastersindia.co/transporterIdUpdate';
                        EWaySetup.INSERT;
                    end;
                }
                action("Generate Access Token")
                {
                    ApplicationArea = All;
                    Caption = 'Generate Access Token';
                    ToolTip = 'Executes the Generate Access Token action.';

                    trigger OnAction()
                    begin
                        Clear(Rec."Access Token Expiry Date");
                        IF GenerateToken() then
                            Message(ActText);
                    end;
                }

                /*  action("Generate Access Token MI")
                  {
                      ApplicationArea = All;
                      Caption = 'Generate Access Token MI';
                      ToolTip = 'Executes the Generate Access Token action.';

                      trigger OnAction()
                      var
                          EWayMgmt: Codeunit "E-Way Billing Mgmt.";
                      begin
                          Clear(Rec."MI Access Token Expiry Date");
                          IF EWayMgmt.GenerateTokenMI() then
                              Message(ActText);
                      end;
                  }*/

                action("Update Gst Registration")
                {
                    ApplicationArea = All;
                    Caption = 'Update E_WAY Gst Registration';
                    trigger OnAction()
                    var
                        GstRegistration: Record "GST Registration Nos.";
                    begin
                        GstRegistration.Init();
                        GstRegistration.Code := '05AAACG2115R1ZN';
                        GstRegistration."State Code" := 'UK';
                        GstRegistration.Insert();
                    end;
                }

            }
        }
    }

    trigger OnOpenPage()
    begin
        IF NOT Rec.GET THEN
            VisableAutoUpdate := TRUE
        ELSE
            VisableAutoUpdate := FALSE;
    end;

    var
        VisableAutoUpdate: Boolean;
        ActText: Label 'Access Token Gnerated.';
        JobjG: JsonObject;
        ResponseG: Text;
        HttpRequestMessageG: HttpRequestMessage;
        HttpResponseMessageG: HttpResponseMessage;
        HttpHeadersG: HttpHeaders;
        HttpClientG: HttpClient;
        HttpContentG: HttpContent;
        HeadersG: HttpHeaders;

        ExpiresInG: Integer;

    //B2BUPG1.0>>
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


        JTokenGAc: JsonToken;
        JTokenExp: JsonToken;
        RequestGUID: Text;
    begin
        IF Rec."Access Token Expiry Date" <> 0DT THEN
            IF Rec."Access Token Expiry Date" > CURRENTDATETIME THEN
                EXIT(TRUE);

        RequestGUID := CREATEGUID;
        // AccessCodeDll := AccessCodeDll.GenerateAccessToken();
        // AccessCodeDll.AccessToken(Input, Result, AccessToken);
        HeadersG := HttpClientG.DefaultRequestHeaders;
        HeadersG.Add('gspappid', Rec."Client ID");
        HttpRequestMessageG.GetHeaders(HeadersG);
        HeadersG.Clear();
        HeadersG.Add('gspappsecret', Rec."Client Secret");
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


        AccessTokenDocNo := 'Acktkn_' + DELCHR(FORMAT(TODAY), '=', '/\_*^@');

        ResponsePath := Rec."Access Token Response" + AccessTokenDocNo + '.Json';


        //TempBlob.EXPORT(ResponsePath);
        // FileManagement.BLOBExportToServerFile(TempBlob, ResponsePath);
        //B2BUPG1.0<<
        Rec."Access Token Expiry Date" := GetTokenExpiryFromResponse(ExpiresInG);
        Rec."Access Token Date" := CURRENTDATETIME;
        Rec."Access Token" := COPYSTR(AccessToken, 1, 250);
        Rec."Access Token 2" := COPYSTR(AccessToken, 251, 500);
        Rec.MODIFY;

        //UpdateEwayLog(AccessTokenDocNo, RequestPath, ResponsePath, Status::Success, 'Access Token Generated', TRUE);
        EXIT(TRUE);
    end;

    procedure GetTokenExpiryFromResponse(ExpiryDuration: Integer) ReturnDate: DateTime
    var

        Days: Integer;
        Hours: Integer;
        Mins: Integer;
        Secs: Integer;
        ExpiryDate: Date;
        ExpiryTime: Time;
        JSONText: Text;
        ResponseValue: Variant;
        JTokenExp: JsonToken;
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
    //B2BUPG1.0<<


    Procedure ReadJSONAcctoken(Data: Text) Result: JsonObject
    begin
        Result.ReadFrom(Data);
    end;

}

