page 50095 "E-Invoice Setup"
{
    // version E-INV,TokenExpiryFix,E-INVB2C

    Caption = 'E-Invoice Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "E-Invoice Setup";
    UsageCategory = Administration;
    ApplicationArea = all;
    layout
    {
        area(content)
        {
            group(General)
            {
                field("With Posting"; Rec."With Posting")
                {
                    ApplicationArea = all;
                }
                field("GSP Priority"; Rec."GSP Priority")
                {
                    ApplicationArea = all;
                }
                field("Generate QRCode B2C"; Rec."Generate QRCode B2C")
                {
                    Visible = false;
                    ApplicationArea = all;
                }
                field("Effective Date"; Rec."Effective Date")
                {
                    ApplicationArea = all;
                    ToolTip = 'Provide the E-Invoice effective date to check the posted invoices.';
                }
            }
            group(Adequre)
            {
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
                field("Access Token Date"; Rec."Access Token Date")
                {
                    ApplicationArea = all;
                }
                field("Access Token Period"; Rec."Access Token Period")
                {
                    Visible = false;
                    ApplicationArea = all;
                }
                field("Access Token Expiry Date"; Rec."Access Token Expiry Date")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Access Token"; Rec."Access Token")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Access Token 2"; Rec."Access Token 2")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Request URL"; Rec."Request URL")
                {
                    ApplicationArea = all;
                }
                field("Cancel Request URL"; Rec."Cancel Request URL")
                {
                    ApplicationArea = all;
                }
                field("Get IRN URL"; Rec."Get IRN URL")
                {
                    ApplicationArea = all;
                }
            }
            group("Master India")
            {
                field("MI Access Token Date"; Rec."MI Access Token Date")
                {
                    ApplicationArea = all;
                }
                field("MI Access Token Period"; Rec."MI Access Token Period")
                {
                    Visible = false;
                    ApplicationArea = all;
                }
                field("MI Access Token Expiry Date"; Rec."MI Access Token Expiry Date")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = all;
                }
                field("MI Access Token"; Rec."MI Access Token")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("MI Access Token 2"; Rec."MI Access Token 2")
                {
                    Editable = false;
                    Visible = (Rec."MI Access Token 2" <> '');
                    ApplicationArea = all;
                }
                field("MI Request URL"; Rec."MI Request URL")
                {
                    ApplicationArea = all;
                }
                field("MI Cancel Request URL"; Rec."MI Cancel Request URL")
                {
                    ApplicationArea = all;
                }
                field("MI Access Token Response Path"; Rec."MI Access Token Response Path")
                {
                    ApplicationArea = all;
                }
                field("MI JSON Request Path"; Rec."MI JSON Request Path")
                {
                    ApplicationArea = all;
                }
                field("MI JSON Response Path"; Rec."MI JSON Response Path")
                {
                    ApplicationArea = all;
                }
                field("Content Length"; Rec."Content Length")
                {
                    ApplicationArea = all;
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
                    Caption = 'Update E-Invoice Setup';
                    Image = UpdateXML;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = VisableAutoUpdate;
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        GSTIntegrationSetup: Record "E-Invoice Setup";
                    begin
                        if not GSTIntegrationSetup.GET then begin
                            GSTIntegrationSetup.INIT;
                            GSTIntegrationSetup."With Posting" := TRUE;
                            GSTIntegrationSetup."Request URL" := 'https://gsp.adaequare.com/test/enriched/ei/api/invoice';
                            GSTIntegrationSetup."Cancel Request URL" := 'https://gsp.adaequare.com/test/enriched/ei/api/invoice/cancel';
                            GSTIntegrationSetup."Get IRN URL" := 'https://gsp.adaequare.com/test/enriched/ei/api/invoice/irn';
                            GSTIntegrationSetup.INSERT;
                        end else begin
                            Rec."With Posting" := TRUE;
                            Rec."Request URL" := 'https://gsp.adaequare.com/test/enriched/ei/api/invoice';
                            Rec."Cancel Request URL" := 'https://gsp.adaequare.com/test/enriched/ei/api/invoice/cancel';
                            Rec."Get IRN URL" := 'https://gsp.adaequare.com/test/enriched/ei/api/invoice/irn';
                            Rec.modify;
                        end;
                    end;
                }
                action("Generate Access Token")
                {
                    Caption = 'Generate Access Token';
                    Image = UpdateXML;
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        EInvoice: Codeunit "E-Invoice Mgmt.";
                    begin
                        Clear(Rec."Access Token Expiry Date");
                        Rec.Modify();
                        if Rec."GSP Priority" = Rec."GSP Priority"::Adequre then
                            EInvoice.GenerateAccessToken()
                        else
                            AccesstokenMI();
                    end;
                }
                action("Update Gst Registration")
                {
                    ApplicationArea = All;
                    // Visible = false;
                    Caption = 'Update E_Inv Gst Registration';
                    trigger OnAction()
                    var
                        GstRegistration: Record "GST Registration Nos.";
                    begin
                        GstRegistration.Init();
                        GstRegistration.Code := '02AMBPG7773M002 ';
                        GstRegistration."State Code" := 'HP';
                        GstRegistration.Insert();
                        /*GstRegistration.Init();
                        GstRegistration.Code := '05AAACG2115R1ZN';
                        GstRegistration."State Code" := 'UK';
                        GstRegistration.Insert();*/
                    end;
                }
            }
        }
    }

    trigger OnOpenPage();
    begin
        IF NOT rec.GET THEN
            VisableAutoUpdate := TRUE
        ELSE
            VisableAutoUpdate := FALSE;
    end;

    local procedure AccesstokenMI(): Boolean;
    var
        EInvoiceMiRequest: Codeunit "E-Invoice Request -MI";
        JSONText: Text;
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
        Jobj: JsonObject;
        Jtoken: JsonToken;
        AccessTokenCode: Text;
    begin
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
        //   Rec."Access Token Expiry Date" := GetTokenExpiryFromResponse(ExpiresInG);
        Rec."Access Token Date" := CURRENTDATETIME;
        Rec."MI Access Token" := COPYSTR(AccessTokenCode, 1, 250);
        Rec."MI Access Token 2" := COPYSTR(AccessTokenCode, 251, 500);
        Rec.MODIFY;
    end;

    Procedure ReadJSONAcctoken(Data: Text) Result: JsonObject
    begin
        Result.ReadFrom(Data);
    end;

    var
        VisableAutoUpdate: Boolean;
}

