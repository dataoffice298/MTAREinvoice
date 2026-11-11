tableextension 50065 SalesCrMemoHdrExt extends "Sales Cr.Memo Header"
{
    // version NAVW19.00.00.51685,NAVIN9.00.00.51685,E-INV,E-INVB2C


    //Unsupported feature: PropertyChange. Please convert manually.

    var
        DuplicateIRNErr: Label 'Duplicate IRN.';
        NoActiveIRNErr: Label 'No active IRN found.';
        GetIRNFailedTxt: Label 'Unable to Get IRN, Please try after some time.';
        EInvoiceEntry: Record "E-Invoice Entry";
        ValidateEInvoiceRequest: Codeunit "Validate E-Invoice Request";
        EInvoiceMgmt: Codeunit "E-Invoice Mgmt.";
        UnRegErr: Label 'You cannot generate e-Invoice for un-registered customer. ';
        QRCodeErr: Label 'QR Code is already generate for this document';
        RegErr: Label 'B2C QR code is applicable only for unregistered customers';

    procedure GenerateEInvoice()
    var
        myInt: Integer;
    begin
        //>>E-INV
        IF "GST Customer Type" IN ["GST Customer Type"::Unregistered, "GST Customer Type"::" "] THEN //Check
            ERROR(UnRegErr);
       if EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Cr. Memo", "No.") then;
        IF EInvoiceEntry."IRN No." <> '' THEN
            ERROR(DuplicateIRNErr);
        ValidateEInvoiceRequest.CheckValidations(Rec);
        EInvoiceMgmt.SetCrMemoHeader(Rec);
        EInvoiceMgmt.RUN;
        //<<E-INV            
    end;

    procedure CancelEInvoice()
    var
        myInt: Integer;
    begin
        //>>E-INV
        IF "GST Customer Type" IN ["GST Customer Type"::Unregistered, "GST Customer Type"::" "] THEN //Check
            ERROR(UnRegErr);
        EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Cr. Memo", "No.");
        IF EInvoiceEntry."IRN No." = '' THEN
            ERROR(NoActiveIRNErr);
        ValidateEInvoiceRequest.CheckCancelIRNValidaitons(Rec);
        EInvoiceMgmt.CancelIRN(Rec);
        //<<E-INV         
    end;

    procedure GetEInvoiceByIRN()
    var
        myInt: Integer;
    begin
        //>>E-INV
        IF "GST Customer Type" IN ["GST Customer Type"::Unregistered, "GST Customer Type"::" "] THEN //Check
            ERROR(UnRegErr);
        EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Cr. Memo", "No.");
        IF EInvoiceEntry."IRN No." = '' THEN
            ERROR(NoActiveIRNErr);
        IF EInvoiceEntry."Ack No." <> '' THEN
            EXIT;
        EInvoiceMgmt.SetCrMemoHeader(Rec);
        IF NOT EInvoiceMgmt.TriggerGetEInvoiceByIRNAdequare THEN
            MESSAGE(GetIRNFailedTxt);
        //<<E-INV       
    end;

    procedure GenerateQRB2C()
    var
        myInt: Integer;
    begin
        //>>E-INVB2C 
        IF "GST Customer Type" <> "GST Customer Type"::Unregistered THEN //Check
            ERROR(RegErr);
        EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Cr. Memo", "No.");
        EInvoiceEntry.CALCFIELDS("QR Code");
        IF EInvoiceEntry."QR Code".HASVALUE THEN
            ERROR(QRCodeErr);
        EInvoiceMgmt.SetCrMemoHeader(Rec);
        EInvoiceMgmt.GenerateQRCodeForB2C(Rec);
        //<<E-INVB2C        
    end;
}

