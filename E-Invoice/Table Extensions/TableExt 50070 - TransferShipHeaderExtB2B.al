tableextension 50070 TransferShipHeaderExtB2B extends "Transfer Shipment Header"
{
    fields
    {
        // Add changes to table fields here
    }

    var
        DuplicateIRNErr: label 'Duplicate IRN.';
        NoActiveIRNErr: label 'No active IRN found.';
        GetIRNFailedTxt: label 'Unable to Get IRN, please try after some time.';
        Location: Record Location;

    PROCEDURE GenerateEInvoice();
    VAR
        UnRegErr: Label 'You cannot generate e-Invoice for un-registered location.';
        ValidateEInvoiceRequest: Codeunit "Validate E-Invoice Request";
        EInvoiceMgmt: Codeunit "E-Invoice Mgmt.";
        EInvoiceEntry: Record "E-Invoice Entry";
    BEGIN
        //>>E-INV
        IF (Location.GET("Transfer-from Code")) AND (Location."GST Registration No." = '') THEN
            ERROR(UnRegErr);
        IF (Location.GET("Transfer-to Code")) AND (Location."GST Registration No." = '') THEN
            ERROR(UnRegErr);
        if EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Transfer Shipment", "No.") then
        IF EInvoiceEntry."IRN No." <> '' THEN
            ERROR(DuplicateIRNErr);
        ValidateEInvoiceRequest.CheckValidations(Rec);
        EInvoiceMgmt.SetTransferShipHeader(Rec);
        EInvoiceMgmt.RUN;
        //<<E-INV
    END;

    PROCEDURE CancelEInvoice();
    VAR
        ValidateEInvoiceRequest: Codeunit "Validate E-Invoice Request";
        EInvoiceMgmt: Codeunit "E-Invoice Mgmt.";
        UnRegErr: Label 'You cannot generate e-Invoice for un-registered location.';
        EInvoiceEntry: Record "E-Invoice Entry";
    BEGIN
        //>>E-INV
        IF (Location.GET("Transfer-from Code")) AND (Location."GST Registration No." = '') THEN
            ERROR(UnRegErr);
        IF (Location.GET("Transfer-to Code")) AND (Location."GST Registration No." = '') THEN
            ERROR(UnRegErr);
        if EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Transfer Shipment", "No.") then
        IF EInvoiceEntry."IRN No." = '' THEN
            ERROR(NoActiveIRNErr);
        ValidateEInvoiceRequest.CheckCancelIRNValidaitons(Rec);
        EInvoiceMgmt.CancelIRN(Rec);
        //<<E-INV
    END;

    PROCEDURE GetEInvoiceByIRN();
    VAR
        UnRegErr: Label 'You cannot get e-Invoice for un-registered customer.';
        EInvoiceMgmt: Codeunit "E-Invoice Mgmt.";
        EInvoiceEntry: Record "E-Invoice Entry";
    BEGIN
        //>>E-INV
        //ExportJsonFileManual.GenerateIRN("No.",DATABASE::"Sales Invoice Header");
        if EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Transfer Shipment", "No.") then
        IF EInvoiceEntry."IRN No." = '' THEN
            ERROR(NoActiveIRNErr);
        IF EInvoiceEntry."Ack No." <> '' THEN
            EXIT;
        EInvoiceMgmt.SetTransferShipHeader(Rec);
        IF NOT EInvoiceMgmt.TriggerGetEInvoiceByIRNAdequare THEN
            MESSAGE(GetIRNFailedTxt);
        //<<E-INV
    END;
}