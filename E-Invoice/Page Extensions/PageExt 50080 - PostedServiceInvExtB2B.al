pageextension 50080 PostedServiceInvExtB2B extends "Posted Service Invoice"
{
    layout
    {

        modify("QR Code")
        {
            Visible = true;
        }
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
        addafter(GST)
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
        modify("Generate E-Invoice")
        {
            Visible = false;
        }
        modify("Generate IRN")
        {
            Visible = false;
        }
        modify("Cancel E-Invoice")
        {
            Visible = false;
        }
        modify("Import E-Invoice Response")
        {
            Visible = false;
        }
        addafter("Update Document")
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
        IF EInvoiceEntry.GET(EInvoiceEntry."Document Type"::"Service Invoice", rec."No.") THEN
            EInvoiceEntry.CALCFIELDS("QR Code");
        //<<E-INV

    end;
}

