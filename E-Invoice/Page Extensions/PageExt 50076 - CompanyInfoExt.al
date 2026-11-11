pageextension 50076 CompanyInfoExt extends "Company Information"
{
    // version NAVW19.00.00.50785,NAVIN9.00.00.50785,E-INVB2C

    layout
    {
        addafter(Address)
        {
            field("Payee Bank IFSC Code"; rec."Payee Bank IFSC Code")
            {
                Caption = 'Bank IFSC Code';
                ApplicationArea = All;
            }
        }
    }
}

