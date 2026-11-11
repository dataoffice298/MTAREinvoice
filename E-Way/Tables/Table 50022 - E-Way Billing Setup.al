table 50022 "E-Way Billing Setup"
{
    Caption = 'E-Way Billing Setup';

    fields
    {
        field(1; "Primary key"; Code[10])
        {
            Caption = 'Primary key';
            DataClassification = ToBeClassified;
        }
        field(2; "E-Way Bill Generation Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Manufacturer,Transporter,Man.& Transport';
            OptionMembers = " ",Manufacturer,Transporter,"Man.& Transport";
        }
        field(3; "E-Way File Storage Path"; Text[250])
        {
            Caption = 'JSON Request Path';
            DataClassification = ToBeClassified;
        }
        field(5; "With Posting"; Boolean)
        {
            Caption = 'With Posting';
            DataClassification = ToBeClassified;
        }
        field(6; "Access Token Date"; DateTime)
        {
            Caption = 'Access Token Date';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(10; "Access Token"; Text[250])
        {
            Caption = 'Access Token';
            DataClassification = ToBeClassified;
        }
        field(11; "Access Token 2"; Text[250])
        {
            Caption = 'Access Token 2';
            DataClassification = ToBeClassified;
        }
        field(12; "User Name"; Text[50])
        {
            Caption = 'User Name';
            DataClassification = ToBeClassified;
        }
        field(13; Password; Text[50])
        {
            Caption = 'Password';
            DataClassification = ToBeClassified;
        }
        field(14; "E-Way Request URL"; Text[250])
        {
            Caption = 'E-Way Request URL';
            DataClassification = ToBeClassified;
            ExtendedDatatype = URL;
        }
        field(15; GSTIN; Code[20])
        {
            Caption = 'GSTIN';
            DataClassification = ToBeClassified;
        }
        field(16; "Access Token Response"; Text[250])
        {
            Caption = 'Access Token Response';
            DataClassification = ToBeClassified;
        }
        field(17; "Access Token Period"; DateFormula)
        {
            Caption = 'Access Token Period';
            DataClassification = ToBeClassified;
        }
        field(18; "Access Token Expiry Date"; DateTime)
        {
            Caption = 'Access Token Expiry Date';
            DataClassification = ToBeClassified;
        }
        field(19; "Vehicle Request URL"; Text[250])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = URL;
        }
        field(20; "E-Way Cancel URL"; Text[250])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = URL;
        }
        field(21; "E-Way Reject URL"; Text[250])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = URL;
        }
        field(22; "Extend Validity URL"; Text[250])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = URL;
        }
        field(23; "Update Transporter URL"; Text[250])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = URL;
        }
        field(24; "Reject E-Way No. Series"; Code[20])
        {
            Caption = 'Reject E-Way No. Series';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(25; "GST Logo"; BLOB)
        {
            DataClassification = ToBeClassified;
            SubType = Bitmap;
        }
        field(26; "Vehicle Reason"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(27; "Vehicle Remarks"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(28; "S.O EWay Applicability"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Shipment,Invoice';
            OptionMembers = " ",Shipment,Invoice;
        }
        field(29; "MI Access Token Date"; DateTime)
        {
            Caption = 'Access Token Date';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(30; "MI Access Token"; Text[250])
        {
            Caption = 'Access Token';
            DataClassification = ToBeClassified;
        }
        field(31; "MI Access Token 2"; Text[250])
        {
            Caption = 'Access Token 2';
            DataClassification = ToBeClassified;
        }
        field(32; "MI Access Token Period"; DateFormula)
        {
            Caption = 'Access Token Period';
            DataClassification = ToBeClassified;
        }
        field(33; "MI Access Token Expiry Date"; Date)
        {
            Caption = 'Access Token Expiry Date';
            DataClassification = ToBeClassified;
        }
        field(34; "MI Vehicle Request URL"; Text[100])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = URL;
        }
        field(35; "MI E-Way Cancel URL"; Text[100])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = URL;
        }
        field(36; "MI E-Way Reject URL"; Text[100])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = URL;
        }
        field(37; "MI Extend Validity URL"; Text[100])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = URL;
        }
        field(38; "MI Update Transporter URL"; Text[100])
        {
            DataClassification = ToBeClassified;
            ExtendedDatatype = URL;
        }
        field(39; "MI Reject E-Way No. Series"; Code[20])
        {
            Caption = 'Reject E-Way No. Series';
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(40; "GSP Priority"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Adequre,MI';
            OptionMembers = " ",Adequre,MI;
        }
        field(41; "MI E-Way Request URL"; Text[100])
        {
            Caption = 'MI E-Way Request URL';
            DataClassification = ToBeClassified;
            ExtendedDatatype = URL;
        }
        field(42; "Applicable On Sales Credit Mem"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(43; "E-Invoice Applicable"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        //PIN2PIN>>
        field(44; "Distance Calculation"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = Manual,Automatic;
            OptionCaption = 'Manual,Automatic';
        }
        field(45; "Pin 2 Pin Distance URL"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        //PIN2PIN<<
        field(112; "Client ID"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(113; "Client Secret"; Text[250])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary key")
        {
        }
    }

    fieldgroups
    {
    }
}

