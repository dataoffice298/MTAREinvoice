tableextension 50064 LocationTableExt extends Location
{
    // version NAVW19.00.00.50785,NAVIN9.00.00.50785,E-INV,E-INVB2C

    fields
    {
        field(50500; "User Name"; Text[250])
        {
            Caption = 'User Name';
            DataClassification = ToBeClassified;
            Description = 'E-INV';
        }
        field(50501; Password; Text[250])
        {
            Caption = 'Password';
            DataClassification = ToBeClassified;
            Description = 'E-INV';
        }
        field(50502; "MI User Name"; Text[250])
        {
            Caption = 'MI User Name';
            DataClassification = ToBeClassified;
            Description = 'E-INV';
        }
        field(50503; "MI Password"; Text[250])
        {
            Caption = 'MI Password';
            DataClassification = ToBeClassified;
            Description = 'E-INV';
        }
        field(50504; "Supplier UPI ID"; Text[100])
        {
            Caption = 'Supplier UPI ID';
            DataClassification = ToBeClassified;
            Description = 'E-INVB2C';
        }
    }

    //Unsupported feature: PropertyChange. Please convert manually.

}

