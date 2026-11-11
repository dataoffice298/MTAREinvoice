pageextension 50088 "Posted Purc. Rcpt. Ext EWB" extends "Posted Purchase Receipt"
{
    layout
    {
        addafter(Shipping)
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
    }



    trigger OnAfterGetRecord()
    begin
        IF EWayBillingEntry.GET(EWayBillingEntry."Transaction Type"::"Purch. Order", Rec."Order No.") then;
    end;

    var
        RequestType: Option Eway,Vehicle,EWayCancel,RejectEway,ExtendValidity,UpdateTrasporter,AccessToken;
        EWayBillingEntry: Record "E-Way Billing Entry";
        EWayValidator: Codeunit "E-Way Validator";
        EWayBillingIntigration: Codeunit "E-Way Billing Mgmt.";
}