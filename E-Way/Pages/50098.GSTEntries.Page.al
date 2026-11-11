page 50098 "GST Entries"
{
    ApplicationArea = All;
    Caption = 'GST Entries';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "GST Entry";
     UsageCategory = Lists;
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Transaction Type"; Rec."Transaction Type")
                {
                }
                field("Document Type"; Rec."Document Type")
                {
                }
                field("Document No."; Rec."Document No.")
                {
                }
                field("GST Group Code"; Rec."GST Group Code")
                {
                }
                field("GST Component Code"; Rec."GST Component Code")
                {
                }
                field("Effective Date"; Rec."Effective Date")
                {
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                }
                field("GST Component %"; Rec."GST Component %")
                {
                }
                field(Amount; Rec.Amount)
                {
                }
            }
        }
    }
}
