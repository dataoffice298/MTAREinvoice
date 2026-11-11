table 50024 "E-Invoice Log"
{
    // version E-INV

    Caption = 'E-Invoice Log';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            //AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Document Type"; Option)
        {
            Caption = 'Document Type';
            DataClassification = ToBeClassified;
            Editable = false;
            OptionCaption = 'Access Token,Invoice,Credit Memo,Transfer Shipment';
            OptionMembers = "Access Token",Invoice,"Credit Memo","Transfer Shipment";
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; "Request Path"; Text[250])
        {
            Caption = 'Request Path';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5; "Response Path"; Text[250])
        {
            Caption = 'Response Path';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(6; IRN; Text[100])
        {
            Caption = 'IRN';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(7; "QR Code"; BLOB)
        {
            Caption = 'QR Code';
            DataClassification = ToBeClassified;
            SubType = Bitmap;
        }
        field(8; "Ack No."; Text[15])
        {
            Caption = 'Ack No.';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(9; "Ack Date"; DateTime)
        {
            Caption = 'Ack Date';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(12; Status; Option)
        {
            Caption = 'Status';
            DataClassification = ToBeClassified;
            Editable = false;
            OptionCaption = 'Success,Failed';
            OptionMembers = Success,Failed;
        }
        field(13; "Request/Response Code"; Text[250])
        {
            Caption = 'Request/Response Code';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(14; "Request GUID"; Guid)
        {
            Caption = 'Request GUID';
            DataClassification = ToBeClassified;
        }
        field(15; "Date & Time"; DateTime)
        {
            Caption = 'Date & Time';
            DataClassification = ToBeClassified;
        }
        field(16; "User Id"; Code[50])
        {
            Caption = 'User Id';
            DataClassification = ToBeClassified;
        }
        field(17; Cancel; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(18; "JSON Request Blob"; Blob)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "JSON Response Blob"; Blob)
        {
            DataClassification = ToBeClassified;
        }
        field(20; "JSON Access Token"; Blob)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
    trigger OnInsert()
    var
        EInvoiceLog: Record "E-Invoice Log";
    begin
        EInvoiceLog.Reset();
        if EInvoiceLog.FindLast() then
            "Entry No." := EInvoiceLog."Entry No." + 1
        else
            "Entry No." := 1;

    end;
}

