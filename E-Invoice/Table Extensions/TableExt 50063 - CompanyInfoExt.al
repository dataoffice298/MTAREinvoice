tableextension 50063 CompanyInfoExt extends "Company Information"
{
    // version NAVW19.00.00.50785,NAVIN9.00.00.50785,E-INVB2C

    fields
    {
        field(50500; "Payee Bank IFSC Code"; Code[11])
        {
            DataClassification = ToBeClassified;
            Description = 'E-INVB2C';
        }
    }

    //Unsupported feature: PropertyChange. Please convert manually


}

