pageextension 50078 PostedSalesCrMemoExt extends "Posted Sales Credit Memo"
{
    // version NAVW19.00.00.51742,NAVIN9.00.00.51742,E-INV,E-INVB2C

    layout
    {
        modify("Acknowledgement No.")
        {
            Visible = false;
        }
        modify("Acknowledgement Date")
        {
            Visible = false;
        }
        modify("IRN Hash")
        {
            Visible = false;
        }
        modify("E-Inv. Cancelled Date")
        {
            Visible = false;
        }
        modify("Cancel Reason")
        {
            Visible = false;
        }
        addlast("Tax Info")
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
                    Caption = 'QR Code';
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
        modify("Generate E-Invoice")
        {
            Visible = false;
        }
        modify("Generate IRN")
        {
            Visible = false;
        }
        modify("Import E-Invoice Response")
        {
            Visible = false;
        }
        addafter(IncomingDocument)
        {
            group("E-Invoice Actions")
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
                action("Generate QR B2C")
                {
                    Caption = 'Generate QR B2C';
                    Image = Invoice;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = all;
                    trigger OnAction();
                    begin
                        rec.GenerateQRB2C;
                    end;
                }
            }
        }
    }

    var
        EInvoiceEntry: Record "E-Invoice Entry";



    trigger OnAfterGetRecord();

    begin
        //>>E-INV
        IF EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Sales Cr. Memo", rec."No.") THEN
            EInvoiceEntry.CALCFIELDS("QR Code");
        //<<E-INV
    end;
}

