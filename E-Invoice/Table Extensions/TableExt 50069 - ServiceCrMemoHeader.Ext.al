tableextension 50069 ServiceCrMemoHdrExt extends "Service Cr.Memo Header"
{
    //B2BUPGSERVICE1.0
    var
        DuplicateIRNErr: label 'Duplicate IRN.';
        NoActiveIRNErr: label 'No active IRN found.';
        GetIRNFailedTxt: label 'Unable to Get IRN, please try after some time.';

    PROCEDURE GenerateEInvoice()
    VAR
        UnRegErr: label 'You cannot generate e-Invoice for un-registered customer.';
        ValidateEInvoiceRequest: Codeunit "Validate E-Invoice Request";
        // EInvoiceMgmt: Codeunit "E-Invoice Mgmt.";
        EInvoiceEntry: Record "E-Invoice Entry";
    BEGIN
        //>>E-INV
        IF "GST Customer Type" IN ["GST Customer Type"::Unregistered, "GST Customer Type"::" "] THEN
            ERROR(UnRegErr);
        if EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Cr. Memo", "No.") then
            IF EInvoiceEntry."IRN No." <> '' THEN
                ERROR(DuplicateIRNErr);
        ValidateEInvoiceRequest.CheckValidationsService(Rec);
        //EInvoiceMgmt.SetServiceCrMemoHeader(Rec);
        //EInvoiceMgmt.RunServiceOrder;

        //<<E-INV
    END;

    PROCEDURE CancelEInvoice()
    VAR
        ValidateEInvoiceRequest: Codeunit "Validate E-Invoice Request";
        // EInvoiceMgmt: Codeunit "E-Invoice Mgmt.";
        UnRegErr: Label 'You cannot generate e-Invoice for un-registered customer.';
        EInvoiceEntry: Record "E-Invoice Entry";
    BEGIN
        //>>E-INV
        IF "GST Customer Type" IN ["GST Customer Type"::Unregistered, "GST Customer Type"::" "] THEN
            ERROR(UnRegErr);
        if EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Cr. Memo", "No.") then
            IF EInvoiceEntry."IRN No." = '' THEN
                ERROR(NoActiveIRNErr);
        ValidateEInvoiceRequest.CheckCancelIRNValidaitonsService(Rec);
        //EInvoiceMgmt.CancelIRNService(Rec);
        //<<E-INV
    END;

    PROCEDURE GetEInvoiceByIRN()
    VAR
        UnRegErr: Label 'You cannot get e-Invoice for un-registered customer.';
        // EInvoiceMgmt: Codeunit "E-Invoice Mgmt.";
        EInvoiceEntry: Record "E-Invoice Entry";
    BEGIN
        //>>E-INV
        //ExportJsonFileManual.GenerateIRN("No.",DATABASE::"Sales Cr.Memo Header");
        IF "GST Customer Type" IN ["GST Customer Type"::Unregistered, "GST Customer Type"::" "] THEN
            ERROR(UnRegErr);
        if EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Cr. Memo", "No.") then
            IF EInvoiceEntry."IRN No." = '' THEN
                ERROR(NoActiveIRNErr);
        IF EInvoiceEntry."Ack No." <> '' THEN
            EXIT;
        // EInvoiceMgmt.SetServiceCrMemoHeader(Rec);
        //IF NOT EInvoiceMgmt.TriggerGetEInvoiceByIRNAdequareService THEN
        MESSAGE(GetIRNFailedTxt);
        //<<E-INV
    END;

    PROCEDURE GenerateQRB2C()
    VAR
        // EInvoiceMgmt: Codeunit "E-Invoice Mgmt.";
        EInvoiceEntry: Record "E-Invoice Entry";
        QRCodeErr: Label 'QR Code is already generate for this document';
        RegErr: Label 'B2C QR code is applicable only for unregistered customers';
    BEGIN
        //>>E-INVB2C
        IF "GST Customer Type" <> "GST Customer Type"::Unregistered THEN
            ERROR(RegErr);
        if EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Cr. Memo", "No.") then
            EInvoiceEntry.CALCFIELDS("QR Code");
        IF EInvoiceEntry."QR Code".HASVALUE THEN
            ERROR(QRCodeErr);
        // EInvoiceMgmt.SetServiceCrMemoHeader(Rec);
        //EInvoiceMgmt.GenerateQRCodeForB2CService(Rec);
        //<<E-INVB2C
    END;
}