table 50028 "E-Way Billing Entry"
{

    fields
    {
        field(1; "Transaction Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Sales Invoice,Sales Shpt,Purch. Order,Whse. Shipment,Whse. Rect,Transfer Order,Sales Crd Memo,Purch. Crd Memo,Sales R.O,Purchase R.O,Subcontracting,Pin 2 Pin';
            OptionMembers = " ","Sales Invoice","Sales Shpt","Purch. Order","Whse. Shipment","Whse. Rect","Transfer Order","Sales Crd Memo","Purch. Crd Memo","Sales R.O","Purchase R.O",Subcontracting,"Pin 2 Pin"; //PIN2PIN
        }
        field(2; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "E-Way Bill No."; BigInteger)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "E-Way Bill Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5; "E-Way Valid Upto"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(6; "Vechicle Updation Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(7; "Vechicle Valid Upto"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(8; "E-Way Cancel Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(9; "Ext Validity Upd. Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(10; "Ext Validity Valid Upto"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(11; "Transporter ID"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(12; "Trns. Updated Date"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(13; "Old Vehicle No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        //B2BUP1.0>>
        field(14; "QR Code"; Blob)
        {
            DataClassification = CustomerContent;
        }
        //B2BUP1.0<<

        //PIN2PIN>>
        field(15; "From Pin"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(16; "To Pin"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(17; Distance; Decimal)
        {
            DataClassification = CustomerContent;
        }
        //PIN2PIN<<
    }

    keys
    {
        key(Key1; "Transaction Type", "Document No.")
        {
        }
    }

    fieldgroups
    {
    }
}

