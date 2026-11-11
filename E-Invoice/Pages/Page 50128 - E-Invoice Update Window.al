page 50128 "E-Invoice Update Window"
{
    //This page is created for alternative solution of window dialog box - B2BUPG1.0
    PageType = ConfirmationDialog;
    Caption = 'Do you want to continue after entering with below details?';
    ApplicationArea = All;
    UsageCategory = Tasks;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            field(CancelReason; CancelReason)
            {
                Caption = 'Cancel Reason';
                ApplicationArea = All;
            }
            field(ReasonRemarks; ReasonRemarks)
            {
                Caption = 'Reason Remarks';
                ApplicationArea = all;
            }
        }
    }

    var

        CancelReason: Option " ","Wrongly Posted Invoice","Duplicate Entry","Incorrect Entry of Goods","Cancelled Order by Customer";
        ReasonRemarks: Text;

    procedure GetData(var CancelReasonPVar: Text; var ReasonRemarkPVar: Text)
    var
        Reason: Integer;
    begin
        Reason := CancelReason;
        CancelReasonPVar := Format(Reason);
        ReasonRemarkPVar := ReasonRemarks;
    end;
}