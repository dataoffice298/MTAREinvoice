/*pageextension 50002 "Posted Sales Inv. Ext EWB" extends "Posted Sales Invoice"
{
    layout
    {
        addafter("Foreign Trade")
        {
            group("E-way Billing")
            {
                Caption = 'E-way Billing';
                field("E-Way Bill No. "; EWayBillingEntry."E-Way Bill No.")
                {
                    ApplicationArea = all;
                    Caption = 'E-Way Bill No.';
                    ToolTip = 'Specifies the value of the E-Way Bill No. field.';
                }
                field("E-Way Bill Date"; EWayBillingEntry."E-Way Bill Date")
                {
                    ApplicationArea = all;
                    Caption = 'E-Way Bill Date';
                    ToolTip = 'Specifies the value of the E-Way Bill Date field.';
                }
                field("E-Way Valid Upto"; EWayBillingEntry."E-Way Valid Upto")
                {
                    ApplicationArea = all;
                    Caption = 'E-Way Valid Upto';
                    ToolTip = 'Specifies the value of the E-Way Valid Upto field.';
                }
                field("Vehicle Updation Date"; EWayBillingEntry."Vechicle Updation Date")
                {
                    ApplicationArea = all;
                    Caption = 'Vechicle Updation Date';
                    ToolTip = 'Specifies the value of the Vechicle Updation Date field.';
                }
                field("Vehicle Valid Upto"; EWayBillingEntry."Vechicle Valid Upto")
                {
                    ApplicationArea = all;
                    Caption = 'Vechicle Valid Upto';
                    ToolTip = 'Specifies the value of the Vechicle Valid Upto field.';
                }
                field("E-Way Cancel Date"; EWayBillingEntry."E-Way Cancel Date")
                {
                    ApplicationArea = all;
                    Caption = 'E-Way Cancel Date';
                    ToolTip = 'Specifies the value of the E-Way Cancel Date field.';
                }
                field("Ext. Validity Updt. Date"; EWayBillingEntry."Ext Validity Upd. Date")
                {
                    ApplicationArea = all;
                    Caption = 'Ext Validity Upd. Date';
                    ToolTip = 'Specifies the value of the Ext Validity Upd. Date field.';
                }
                field("Ext. Validity Valid Upto"; EWayBillingEntry."Ext Validity Valid Upto")
                {
                    ApplicationArea = all;
                    Caption = 'Ext Validity Valid Upto';
                    ToolTip = 'Specifies the value of the Ext Validity Valid Upto field.';
                }
                field("Transporter ID"; EWayBillingEntry."Transporter ID")
                {
                    ApplicationArea = all;
                    Caption = 'Transporter ID';
                    ToolTip = 'Specifies the value of the Transporter ID field.';
                }
                field("Trns. Updated Date"; EWayBillingEntry."Trns. Updated Date")
                {
                    ApplicationArea = all;
                    Caption = 'Trns. Updated Date';
                    ToolTip = 'Specifies the value of the Trns. Updated Date field.';
                }
            }
        }
        modify("QR Code")
        {
            Visible = true; 
        }
        addafter("Tax Liable")
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
        addlast(processing)
        {
            group("E-Way Bill")
            {
                Caption = 'E-Way Bill';
                action("Generate E-Way Bill No.")
                {
                    Caption = 'Generate E-Way Bill No.';
                    Image = ElectronicNumber;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Generate E-Way Bill No. action.';

                    trigger OnAction()
                    begin
                        EWayValidator.CheckValidations(Rec, RequestType::Eway);
                        EWayBillingIntigration.SetDocument(Rec, RequestType::Eway, FALSE);
                        EWayBillingIntigration.RUN;
                    end;
                }
                action("Update Vechile No.")
                {
                    Caption = 'Update Vechile No.';
                    Image = Shipment;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Update Vechile No. action.';

                    trigger OnAction()
                    begin
                        EWayValidator.CheckValidations(Rec, RequestType::Vehicle);
                        EWayBillingIntigration.SetDocument(Rec, RequestType::Vehicle, FALSE);
                        EWayBillingIntigration.RUN;
                    end;
                }
                action("Cancel E-Way Billing")
                {
                    Caption = 'Cancel E-Way Billing';
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Cancel E-Way Billing action.';

                    trigger OnAction()
                    begin
                        EWayValidator.CheckValidations(Rec, RequestType::EWayCancel);
                        EWayBillingIntigration.SetDocument(Rec, RequestType::EWayCancel, FALSE);
                        EWayBillingIntigration.RUN;
                    end;
                }
                action("Reject E-Way Billing")
                {
                    Caption = 'Reject E-Way Billing';
                    Image = Reject;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Reject E-Way Billing action.';

                    trigger OnAction()
                    begin
                        EWayBillingIntigration.SetDocument(Rec, RequestType::RejectEway, FALSE);
                        EWayBillingIntigration.RUN;
                    end;
                }
                action("Extend Validity")
                {
                    Caption = 'Extend Validity';
                    Image = ExtendedDataEntry;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Extend Validity action.';

                    trigger OnAction()
                    begin
                        EWayValidator.CheckValidations(Rec, RequestType::ExtendValidity);
                        EWayBillingIntigration.SetDocument(Rec, RequestType::ExtendValidity, FALSE);
                        EWayBillingIntigration.RUN;
                    end;
                }
                action("Update Transporter")
                {
                    Caption = 'Update Transporter';
                    Image = ExtendedDataEntry;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Update Transporter action.';

                    trigger OnAction()
                    begin
                        EWayValidator.CheckValidations(Rec, RequestType::UpdateTrasporter);
                        EWayBillingIntigration.SetDocument(Rec, RequestType::UpdateTrasporter, FALSE);
                        EWayBillingIntigration.RUN;
                    end;
                }
                //PIN2PIN>>
                action("Generate Pin 2 Pin Distance")
                {
                    Caption = 'Generate Pin 2 Pin Distance';
                    Image = GetBinContent;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Generate Pin 2 Pin Distance action.';

                    trigger OnAction()
                    begin
                        EWayBillingIntigration.SetDocument(Rec, RequestType::Pin2Pin, FALSE);
                        EWayBillingIntigration.RUN;
                    end;
                }
                //PIN2PIN<<
                action("Print E-Way Bill")
                {
                    Caption = 'Print E-Way Bill';
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Print E-Way Bill action.';

                    trigger OnAction()
                    var
                        SaleInvHdr: Record "Sales Invoice Header";
                        EWayBill: Report "E-Way Bill Report";
                    begin
                        CLEAR(EWayBill);
                        EWayBillingEntry.RESET;
                        EWayBillingEntry.SETRANGE("Transaction Type", EWayBillingEntry."Transaction Type"::"Sales Invoice");
                        EWayBillingEntry.SETRANGE("Document No.", Rec."No.");
                        IF EWayBillingEntry.FINDFIRST THEN BEGIN
                            EWayBill.SETTABLEVIEW(EWayBillingEntry);
                            EWayBill.RUN;
                        END;
                    end;
                }

            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        IF EWayBillingEntry.GET(EWayBillingEntry."Transaction Type"::"Sales Invoice", Rec."No.") THEN;
    end;

    var
        RequestType: Option Eway,Vehicle,EWayCancel,RejectEway,ExtendValidity,UpdateTrasporter,AccessToken,Pin2Pin; //PIN2PIN
        EWayBillingEntry: Record "E-Way Billing Entry";
        EWayValidator: Codeunit "E-Way Validator";
        EWayBillingIntigration: Codeunit "E-Way Billing Mgmt.";
}*/