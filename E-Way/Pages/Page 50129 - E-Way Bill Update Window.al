page 50129 "E-Way Bill Update Window"
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
            field(VehicleNo; VehicleNo)
            {
                Caption = 'Vehicle No.';
                ApplicationArea = All;
                Visible = ShowVehicle;
            }
            field(RejectEWayNo; RejectEWayNo)
            {
                Caption = 'Reject E-Way Bill No.';
                ApplicationArea = all;
                Visible = ShowReject;
            }
            field(TransportID; TransportID)
            {
                Caption = 'Transporter ID';
                ApplicationArea = all;
                Visible = ShowTransport;
            }
            field(TransportName; TransportName)
            {
                Caption = 'Transporter Name';
                ApplicationArea = all;
                Visible = ShowTransport;
            }
            field(CancelReason; CancelReason)
            {
                Caption = 'Cancel Reason';
                ApplicationArea = all;
                Visible = ShowCancel;
            }
            field(CancelRemarks; CancelRemarks)
            {
                Caption = 'Cancel Remarks';
                ApplicationArea = all;
                Visible = ShowCancel;
            }
            field(RemainingDistance; RemainingDistance)
            {
                Caption = 'Remaining Distance';
                ApplicationArea = all;
                Visible = ShowCancel;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        VehicleNo: Text;
        ShowVehicle: Boolean;
        RejectEWayNo: Text;
        ShowReject: Boolean;
        TransportID: Text;
        ShowTransport: Boolean;
        CancelReason: Text;
        CancelRemarks: Text;
        TransportName: Text;
        ShowCancel: Boolean;
        RemainingDistance: Text;

    procedure SetData(ParameterType: Option Vehicle,Reject,Transport,Cancel)
    begin
        ShowVehicle := false;
        ShowReject := false;
        ShowTransport := false;
        if ParameterType = ParameterType::Vehicle then
            ShowVehicle := true;
        if ParameterType = ParameterType::Reject then
            ShowReject := true;
        if ParameterType = ParameterType::Transport then
            ShowTransport := true;
        if ParameterType = ParameterType::Cancel then
            ShowCancel := true;
    end;

    procedure GetData(ParameterType: Option Vehicle,Reject,Transport,Cancel;
                    var OutText: Text)
    begin
        if ParameterType = ParameterType::Vehicle then
            OutText := VehicleNo;
        if ParameterType = ParameterType::Reject then
            OutText := RejectEWayNo;
        if ParameterType = ParameterType::Transport then
            OutText := TransportID;
    end;

    procedure GetCancelTransportData(ParameterType: Option Vehicle,Reject,Transport,Cancel;
                    var OutText1: Text;
                    var OutText2: Text;
                    var OutText3: Text)
    begin
        if ParameterType = ParameterType::Cancel then begin
            OutText1 := CancelReason;
            OutText2 := CancelRemarks;
            OutText3 := RemainingDistance;
        end;

        if ParameterType = ParameterType::Transport then begin
            OutText1 := TransportID;
            OutText2 := TransportName;
            OutText3 := '';
        end;
    end;
}