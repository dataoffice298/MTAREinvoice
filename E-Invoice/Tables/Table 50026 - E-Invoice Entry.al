table 50026 "E-Invoice Entry"
{
    // version E-INV

    Caption = 'E-Invoice Entry';

    fields
    {
        field(1; "Document Type"; Option)
        {
            Caption = 'Document Type';
            DataClassification = ToBeClassified;
            OptionCaption = 'Sales Invoice,Sales Cr. Memo,,Transfer Shipment,Service Invoice,Service Cr. Memo';
            OptionMembers = "Sales Invoice","Sales Cr. Memo","Transfer Shipment","Service Invoice","Service Cr. Memo";
        }
        field(2; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "IRN No."; Text[100])
        {
            Caption = 'IRN No.';
            DataClassification = ToBeClassified;
        }
        field(11; "QR Code"; BLOB)
        {
            Caption = 'QR Code';
            DataClassification = ToBeClassified;
            SubType = Bitmap;
        }
        field(12; "Ack No."; Text[15])
        {
            Caption = 'Ack No.';
            DataClassification = ToBeClassified;
        }
        field(13; "Ack Date"; DateTime)
        {
            Caption = 'Ack Date';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14; "IRN Cancelled"; Boolean)
        {
            Caption = 'IRN Cancelled';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(15; "IRN Cancelled Date"; DateTime)
        {
            Caption = 'IRN Cancelled Date';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(16; "IRN Cancelled Reason"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "IRN Cancelled Remarks"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "IRN Cancelled By"; Code[50])
        {
            Caption = 'IRN Cancelled By';
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Document Type", "Document No.")
        {
        }
    }

    fieldgroups
    {
    }
}

