tableextension 50068 ServiceInvHeaderExt extends "Service Invoice Header"
{
    //B2BUPGSERVICE1.0
    var
        DuplicateIRNErr: label 'Duplicate IRN.';
        NoActiveIRNErr: label 'No active IRN found.';
        GetIRNFailedTxt: label 'Unable to Get IRN, please try after some time.';

    PROCEDURE GenerateEInvoice();
    VAR
        UnRegErr: label 'You cannot generate e-Invoice for un-registered customer.';
        ValidateEInvoiceRequest: Codeunit "Validate E-Invoice Request";
        // EInvoiceMgmt: Codeunit "E-Invoice Mgmt.";
        EInvoiceEntry: Record "E-Invoice Entry";
    BEGIN
        //>>E-INV
        IF "GST Customer Type" IN ["GST Customer Type"::Unregistered, "GST Customer Type"::" "] THEN
            ERROR(UnRegErr);
       if EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Invoice", "No.") then;
        IF EInvoiceEntry."IRN No." <> '' THEN
            ERROR(DuplicateIRNErr);
        ValidateEInvoiceRequest.CheckValidationsService(Rec);
        // EInvoiceMgmt.SetServiceInvHeader(Rec);
        //EInvoiceMgmt.RunServiceOrder;
        //<<E-INV
    END;

    PROCEDURE CancelEInvoice();
    VAR
        ValidateEInvoiceRequest: Codeunit "Validate E-Invoice Request";
        //  EInvoiceMgmt: Codeunit "E-Invoice Mgmt.";
        UnRegErr: label 'You cannot generate e-Invoice for un-registered customer.';
        EInvoiceEntry: Record "E-Invoice Entry";
    BEGIN
        //>>E-INV
        IF "GST Customer Type" IN ["GST Customer Type"::Unregistered, "GST Customer Type"::" "] THEN
            ERROR(UnRegErr);
        EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Invoice", "No.");
        IF EInvoiceEntry."IRN No." = '' THEN
            ERROR(NoActiveIRNErr);
        ValidateEInvoiceRequest.CheckCancelIRNValidaitonsService(Rec);
        //EInvoiceMgmt.CancelIRNService(Rec);
        //<<E-INV
    END;

    PROCEDURE GetEInvoiceByIRN();
    VAR
        UnRegErr: label 'You cannot get e-Invoice for un-registered customer.';
        //  EInvoiceMgmt: Codeunit "E-Invoice Mgmt.";
        EInvoiceEntry: Record "E-Invoice Entry";
    BEGIN
        //>>E-INV
        //ExportJsonFileManual.GenerateIRN("No.",DATABASE::"Sales Invoice Header");
        IF "GST Customer Type" IN ["GST Customer Type"::Unregistered, "GST Customer Type"::" "] THEN
            ERROR(UnRegErr);
        EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Invoice", "No.");
        IF EInvoiceEntry."IRN No." = '' THEN
            ERROR(NoActiveIRNErr);
        IF EInvoiceEntry."Ack No." <> '' THEN
            EXIT;
        //  EInvoiceMgmt.SetServiceInvHeader(Rec);
        //IF NOT EInvoiceMgmt.TriggerGetEInvoiceByIRNAdequareService THEN
        MESSAGE(GetIRNFailedTxt);
        //<<E-INV
    END;

    PROCEDURE GenerateQRB2C();
    VAR
        //   EInvoiceMgmt: Codeunit "E-Invoice Mgmt.";
        EInvoiceEntry: Record "E-Invoice Entry";
        QRCodeErr: label 'QR Code is already generate for this document';
        RegErr: label 'B2C QR code is applicable only for unregistered customers';
    BEGIN
        //>>E-INVB2C
        IF "GST Customer Type" <> "GST Customer Type"::Unregistered THEN
            ERROR(RegErr);
        EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Invoice", "No.");
        EInvoiceEntry.CALCFIELDS("QR Code");
        IF EInvoiceEntry."QR Code".HASVALUE THEN
            ERROR(QRCodeErr);
        //  EInvoiceMgmt.SetServiceInvHeader(Rec);
        //EInvoiceMgmt.GenerateQRCodeForB2CService(Rec);
        //<<E-INVB2C
    END;

}