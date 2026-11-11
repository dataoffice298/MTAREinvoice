table 50025 "E-Invoice Setup"
{
    // version E-INV,TokenExpiryFix,E-INVB2C

    Caption = 'E-Invoice Setup';

    fields
    {
        field(1; "Primary key"; Code[10])
        {
            Caption = 'Primary key';
            DataClassification = ToBeClassified;
        }
        field(2; "Access Token Response Path"; Text[250])
        {
            Caption = 'Access Token Response Path';
            DataClassification = ToBeClassified;
        }
        field(3; "JSON Request Path"; Text[250])
        {
            Caption = 'JSON Request Path';
            DataClassification = ToBeClassified;
        }
        field(4; "JSON Response Path"; Text[250])
        {
            Caption = 'JSON Response Path';
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
        field(10; "Access Token"; Text[500])
        {
            Caption = 'Access Token';
            DataClassification = ToBeClassified;
        }
        field(11; "Access Token 2"; Text[500])
        {
            Caption = 'Access Token 2';
            DataClassification = ToBeClassified;
        }
        field(12; "User Name"; Text[250])
        {
            Caption = 'User Name';
            DataClassification = ToBeClassified;
        }
        field(13; Password; Text[250])
        {
            Caption = 'Password';
            DataClassification = ToBeClassified;
        }
        field(14; "Request URL"; Text[250])
        {
            Caption = 'Request URL';
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
            Description = 'TokenExpiryFix --Datatype changed';
        }
        field(19; "Cancel Request URL"; Text[250])
        {
            Caption = 'Cancel Request URL';
            DataClassification = ToBeClassified;
            ExtendedDatatype = URL;
        }
        field(20; "Get IRN URL"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(100; "MI Access Token Expiry Date"; DateTime)
        {
            Caption = 'MI Access Token Expiry Date';
            DataClassification = ToBeClassified;
            Description = 'TokenExpiryFix --Datatype changed';
        }
        field(101; "MI Access Token Period"; DateFormula)
        {
            Caption = 'MI Access Token Period';
            DataClassification = ToBeClassified;
        }
        field(102; "MI Access Token Response Path"; Text[100])
        {
            Caption = 'MI Access Token Response Path';
            DataClassification = ToBeClassified;
        }
        field(103; "MI Access Token Date"; DateTime)
        {
            Caption = 'MI Access Token Date';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(104; "MI Access Token"; Text[250])
        {
            Caption = 'MI Access Token';
            DataClassification = ToBeClassified;
        }
        field(105; "MI Access Token 2"; Text[250])
        {
            Caption = 'MI Access Token 2';
            DataClassification = ToBeClassified;
        }
        field(106; "MI JSON Request Path"; Text[100])
        {
            Caption = 'MI JSON Request Path';
            DataClassification = ToBeClassified;
        }
        field(107; "MI JSON Response Path"; Text[100])
        {
            Caption = 'MI JSON Response Path';
            DataClassification = ToBeClassified;
        }
        field(108; "MI Request URL"; Text[80])
        {
            Caption = 'MI Request URL';
            DataClassification = ToBeClassified;
            ExtendedDatatype = URL;
        }
        field(109; "MI Cancel Request URL"; Text[80])
        {
            Caption = 'MI Cancel Request URL';
            DataClassification = ToBeClassified;
            ExtendedDatatype = URL;
        }
        field(110; "GSP Priority"; Option)
        {
            Caption = 'GSP Priority';
            DataClassification = ToBeClassified;
            OptionCaption = 'Adequre,MI';
            OptionMembers = Adequre,MI;
        }
        field(111; "Generate QRCode B2C"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'E-INVB2C';
        }
        field(112; "Client ID"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(113; "Client Secret"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(114; "Effective Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(115; "Content Length"; Integer)
        {
            DataClassification = ToBeClassified;
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

