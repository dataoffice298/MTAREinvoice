pageextension 50096 "Sales Invoice Ext B2B" extends "Sales Invoice"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addlast(processing)
        {
            group("E-Way Bill")
            {
                //PIN2PIN>>
                action("Generate Pin 2 Pin Distance")
                {
                    Caption = 'Generate Pin 2 Pin Distance';
                    Image = GetBinContent;
                    Promoted = true;
                    PromotedCategory = Category6;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Generate Pin 2 Pin Distance action.';

                    trigger OnAction()
                    var
                        DistanceErr: Label 'Distance must be empty to calcualte the accurate distance.';
                    begin
                        if Rec."Distance (Km)" <> 0 then
                            Error(DistanceErr);
                        EWayBillingIntigration.SetDocument(Rec, RequestType::Pin2Pin, FALSE);
                        EWayBillingIntigration.RUN;
                        CurrPage.Update();
                    end;
                }
                //PIN2PIN<<
            }
        }
    }

    var
        EWayBillingIntigration: Codeunit "E-Way Billing Mgmt.";
        RequestType: Option Eway,Vehicle,EWayCancel,RejectEway,ExtendValidity,UpdateTrasporter,AccessToken,Pin2Pin; //PIN2PIN
}