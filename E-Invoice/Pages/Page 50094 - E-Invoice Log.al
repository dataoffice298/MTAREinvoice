page 50094 "E-Invoice Log"
{
    // version E-INV

    Caption = 'E-Invoice Log';
    Editable = false;
    PageType = List;
    SourceTable = "E-Invoice Log";
    UsageCategory = History;
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = all;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = all;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = all;
                }
                field("Request Path"; Rec."Request Path")
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field("Response Path"; Rec."Response Path")
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field(IRN; rec.IRN)
                {
                    ApplicationArea = all;
                }
                field("Ack No."; Rec."Ack No.")
                {
                    ApplicationArea = all;
                }
                field("Ack Date"; Rec."Ack Date")
                {
                    ApplicationArea = all;
                }
                field(Status; rec.Status)
                {
                    ApplicationArea = all;
                }
                field("Request/Response Code"; Rec."Request/Response Code")
                {
                    ApplicationArea = all;

                }
                field("User Id"; Rec."User Id")
                {
                    ApplicationArea = all;
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

