page 50097 "E-Way Integration Log"
{
    Editable = false;
    PageType = List;
    SourceTable = "E-Way Integration Log";
    UsageCategory = Administration;
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Group';
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Caption = 'Entry No.';
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    Caption = 'Document Type';
                    ToolTip = 'Specifies the value of the Document Type field.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'Document No.';
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field("Request Path"; Rec."Request Path")
                {
                    ApplicationArea = All;
                    Caption = 'Request Path';
                    ToolTip = 'Specifies the value of the Request Path field.';
                }
                field("Response Path"; Rec."Response Path")
                {
                    ApplicationArea = All;
                    Caption = 'Response Path';
                    ToolTip = 'Specifies the value of the Response Path field.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field("Request/Response Code"; Rec."Request/Response Code")
                {
                    ApplicationArea = All;
                    Caption = 'Request/Response Code';
                    ToolTip = 'Specifies the value of the Request/Response Code field.';
                }
                field("User Id"; Rec."User Id")
                {
                    ApplicationArea = All;
                    Caption = 'User Id';
                    ToolTip = 'Specifies the value of the User Id field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Get Request JSON")
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    Ins: InStream;
                    outs: OutStream;
                    Filename: Text;
                    Title: Text;
                    Test2: Text;
                begin
                    Title := Rec."Document No." + format(CurrentDateTime) + '.Json';
                    Filename := StrSubstNo(Title, Rec.TableCaption);
                    Rec.CalcFields("JSON Request Blob");
                    if Rec."JSON Request Blob".HasValue then begin
                        Rec."JSON Request Blob".CreateInStream(Ins);
                        DownloadFromStream(Ins, '', '', '', Filename);
                    end;
                end;
            }
            action("Get Access Token")
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    Ins: InStream;
                    outs: OutStream;
                    Filename: Text;
                    Title: Text;
                    Test2: Text;
                begin
                    Title := Rec."Document No." + format(CurrentDateTime) + '.Json';
                    Filename := StrSubstNo(Title, Rec.TableCaption);
                    Rec.CalcFields("JSON Access Token");
                    if Rec."JSON Access Token".HasValue then begin
                        Rec."JSON Access Token".CreateInStream(Ins);
                        DownloadFromStream(Ins, '', '', '', Filename);
                    end;
                end;
            }
            action("Get Response JSON")
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    Ins: InStream;
                    outs: OutStream;
                    Filename: Text;
                    Title: Text;
                    Test2: Text;
                begin
                    Title := Rec."Document No." + format(CurrentDateTime) + '.Json';
                    Filename := StrSubstNo(Title, Rec.TableCaption);
                    Rec.CalcFields("JSON Response Blob");
                    if Rec."JSON Response Blob".HasValue then begin
                        Rec."JSON Response Blob".CreateInStream(Ins);
                        DownloadFromStream(Ins, '', '', '', Filename);
                    end;
                end;
            }
        }
    }

}

