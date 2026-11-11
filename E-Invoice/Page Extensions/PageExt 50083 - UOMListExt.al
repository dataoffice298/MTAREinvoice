pageextension 50083 "UOM List Ext" extends "Units of Measure"
{
    layout
    {
        addlast(Control1)
        {
            field("GST UQC Code B2B"; Rec."GST UQC Code B2B")
            {
                ApplicationArea = all;
                ToolTip = 'Alternative field to enter UQC code for E-Invoice generation only.';
            }
        }
    }
}