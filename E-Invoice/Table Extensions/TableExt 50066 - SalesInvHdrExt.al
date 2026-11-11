tableextension 50066 SalesInvHdrExt extends "Sales Invoice Header"
{
    var
        DuplicateIRNErr: Label 'Duplicate IRN.';
        NoActiveIRNErr: Label 'No active IRN found.';
        GetIRNFailedTxt: Label 'Unable to Get IRN, please try after some time.';
        EInvoiceEntry: Record "E-Invoice Entry";
        ValidateEInvoiceRequest: Codeunit "Validate E-Invoice Request";
        EInvoiceMgmt: Codeunit "E-Invoice Mgmt.";
        UnRegErr: Label 'You cannot generate e-Invoice for un-registered customer. ';
        QRCodeErr: Label 'QR Code is already generate for this document';
        RegErr: Label 'B2C QR code is applicable only for unregistered customers';

    procedure GenerateEInvoice()
    var
        myInt: Integer;
    //Test: Record Test;
    begin
        //>>E-INV
        // Test.Init();
        // Test.Description := 'At Invoice Page';
        // Test.Insert(true);
        IF "GST Customer Type" IN ["GST Customer Type"::Unregistered, "GST Customer Type"::" "] THEN //Check
            ERROR(UnRegErr);
        If EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Invoice", "No.") then
            IF EInvoiceEntry."IRN No." <> '' THEN
                ERROR(DuplicateIRNErr);
        ValidateEInvoiceRequest.CheckValidations(Rec);
        EInvoiceMgmt.SetSalesInvHeader(Rec);
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
        if EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Invoice", "No.") then
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
        if EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Invoice", "No.") then
            IF EInvoiceEntry."IRN No." = '' THEN
                ERROR(NoActiveIRNErr);
        IF EInvoiceEntry."Ack No." <> '' THEN
            EXIT;
        EInvoiceMgmt.SetSalesInvHeader(Rec);
        IF NOT EInvoiceMgmt.TriggerGetEInvoiceByIRNAdequare THEN
            MESSAGE(GetIRNFailedTxt);
        //<<E-INV       
    end;

    procedure GenerateQRB2C()
    var
        myInt: Integer;
    begin
        //>>E-INVB2C 
        //IF "GST Customer Type" <> "GST Customer Type"::Unregistered THEN //Check
        ERROR(RegErr);
        if EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Invoice", "No.") then
            EInvoiceEntry.CALCFIELDS("QR Code");
        IF EInvoiceEntry."QR Code".HASVALUE THEN
            ERROR(QRCodeErr);
        EInvoiceMgmt.SetSalesInvHeader(Rec);
        EInvoiceMgmt.GenerateQRCodeForB2C(Rec);
        //<<E-INVB2C        
    end;
}

