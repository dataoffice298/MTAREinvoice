pageextension 50077 LocationCardExt extends "Location Card"
{
    // version NAVW19.00.00.50868,NAVIN9.00.00.50868,E-INV,E-INVB2C

    layout
    {
        addafter("Bin Policies")
        {
            group("E-Invoice")
            {
                Caption = 'E-Invoice';
                group(Adequre)
                {
                    field("User Name"; Rec."User Name")
                    {
                        ApplicationArea = all;
                    }
                    field(Password; rec.Password)
                    {
                        ExtendedDatatype = Masked;
                        ApplicationArea = all;
                    }
                }
                group(MI)
                {
                    // field("MI User Name"; Rec."MI User Name")
                    // {
                    //     ApplicationArea = all;
                    // }
                    field("MI Password"; Rec."MI Password")
                    {
                        ApplicationArea = all;
                    }
                }
                field("Supplier UPI ID"; Rec."Supplier UPI ID")
                {
                    ApplicationArea = all;
                }
            }
        }
    }

}

