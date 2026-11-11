pageextension 50082 PostedTransShipExtB2B extends "Posted Transfer Shipment"
{
    layout
    {
        addafter("Foreign Trade")
        {
            group("E-Invoice")
            {
                Editable = false;

                field("IRN No."; EInvoiceEntry."IRN No.")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("QR Code 1"; EInvoiceEntry."QR Code")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Ack No."; EInvoiceEntry."Ack No.")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("Ack Date"; EInvoiceEntry."Ack Date")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("IRN Cancelled"; EInvoiceEntry."IRN Cancelled")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("IRN Cancelled Date"; EInvoiceEntry."IRN Cancelled Date")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("IRN Cancelled By"; EInvoiceEntry."IRN Cancelled By")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
                field("IRN Cancelled Remarks"; EInvoiceEntry."IRN Cancelled Remarks")
                {
                    Editable = false;
                    ApplicationArea = all;
                }
            }
        }
    }

    actions
    {
        addafter("&Shipment")
        {
            group("E-Invoice Action")
            {
                Caption = 'E-Invoice';

                action("Generate IRN 1")
                {
                    Caption = 'Generate IRN';
                    Image = Invoice;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = all;
                    trigger OnAction();
                    begin
                        rec.GenerateEInvoice;
                    end;
                }
                action("Cancel IRN")
                {
                    Caption = 'Cancel IRN';
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = all;
                    trigger OnAction();
                    begin
                        rec.CancelEInvoice;
                    end;
                }
                action("Get IRN")
                {
                    Caption = 'Get IRN';
                    Image = GetSourceDoc;
                    ApplicationArea = all;
                    trigger OnAction();
                    begin
                        rec.GetEInvoiceByIRN;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        //E-INV>>
        IF EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Transfer Shipment", Rec."No.") THEN
            EInvoiceEntry.CALCFIELDS("QR Code");
        //E-INV<<
    end;

    var
        EInvoiceEntry: Record "E-Invoice Entry";
}