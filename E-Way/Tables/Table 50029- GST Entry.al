table 50029 "GST Entry"
{
    Caption = 'GST Calculation Entries';

    fields
    {
        field(1; "Transaction Type"; Option)
        {
            Caption = 'Transaction Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Purchase,Sales,Transfer,Service,Service Transfer,Production';
            OptionMembers = Purchase,Sales,Transfer,Service,"Service Transfer",Production;
        }
        field(2; "Document Type"; Option)
        {
            Caption = 'Document Type';
            DataClassification = SystemMetadata;
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order,Shipment';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order",Shipment;
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(5; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            DataClassification = SystemMetadata;
            NotBlank = true;
            TableRelation = "GST Group";
        }
        field(6; "GST Component Code"; Code[10])
        {
            Caption = 'GST Component Code';
            DataClassification = SystemMetadata;


        }
        field(7; "Effective Date"; Date)
        {
            Caption = 'Effective Date';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(8; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = SystemMetadata;
        }
        field(9; "GST Component %"; Decimal)
        {
            Caption = 'GST Component %';
            DataClassification = SystemMetadata;
        }
        field(10; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Transaction Type", "Document Type", "Document No.", "Document Line No.", "GST Group Code", "GST Component Code", "Effective Date")
        {
        }
        key(Key2; "Transaction Type", "Document Type", "Document No.", "Document Line No.", Amount)
        {
        }
    }

    fieldgroups
    {
    }

    var

}

