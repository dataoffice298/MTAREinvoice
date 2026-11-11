table 50027 "E-Way Integration Log"
{
    Caption = 'GST Integration Log';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Document Type"; Option)
        {
            Caption = 'Document Type';
            DataClassification = ToBeClassified;
            Editable = false;
            OptionCaption = 'Access Token,Invoice,Shipment,Pin 2 Pin';
            OptionMembers = "Access Token",Invoice,Shipment,"Pin 2 Pin";
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
        field(17; "Request Type"; Option)
        {
            Caption = 'Request Type';
            DataClassification = ToBeClassified;
            OptionCaption = 'Eway,Vehicle,EWayCancel,RejectEway,ExtendValidity,UpdateTrasporter,AccessToken,Pin2Pin';
            OptionMembers = Eway,Vehicle,EWayCancel,RejectEway,ExtendValidity,UpdateTrasporter,AccessToken,Pin2Pin; //PIN2PIN
        }
        field(18; "Reject E-Way Bill No"; BigInteger)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Rejected Date"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(20; Finished; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Transaction Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Purchase,Sales';
            OptionMembers = " ",Purchase,Sales;
        }
        field(22; "JSON Request Blob"; Blob)
        {
            DataClassification = ToBeClassified;
        }
        field(23; "JSON Response Blob"; Blob)
        {
            DataClassification = ToBeClassified;
        }
        field(24; "JSON Access Token"; Blob)
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
}

