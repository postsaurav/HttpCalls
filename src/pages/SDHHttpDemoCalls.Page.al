page 50001 "SDH Http Demo Calls"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(URL)
            {
                field(SourceURL; SourceURL)
                {
                    ApplicationArea = All;
                    Caption = 'URL To Access';
                    ExtendedDatatype = URL;
                    ToolTip = 'Specifies the value of the SourceURL field';
                }
            }
            group(Calls)
            {
                field(SimpleCallHttp; SimpleCallHttpLbl)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the SimpleCallHttp field';
                    trigger OnDrillDown()
                    begin
                        CheckBeforeCall();
                        ResultsTxt := ConsumeHttp.SimpleHttpCall(SourceURL);
                    end;
                }

                field(WebServiceRead; WebServiceReadLbl)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the WebServiceRead field';
                    trigger OnDrillDown()
                    begin
                        CheckBeforeCall();
                        ResultsTxt := ConsumeHttp.ReadWebService(SourceURL);
                    end;
                }

                field(WebServiceReadWrite; WebServiceReadWriteLbl)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = 'Specifies the value of the WebServiceReadWrite field';
                    trigger OnDrillDown()
                    begin
                        CheckBeforeCall();
                        ResultsTxt := ConsumeHttp.ReadWriteWebService(SourceURL);
                    end;
                }
            }
            group(Results)
            {
                field(ResultsTxt; ResultsTxt)
                {
                    Caption = 'Result Text';
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Specifies the value of the Result Text field';
                }
            }
            part("Demo"; "SDH Demo")
            {
                ApplicationArea = all;
            }
        }
    }

    local procedure CheckBeforeCall()
    begin
        if SourceURL = '' then
            error('Input Source URL.');
        clear(ResultsTxt);
    end;

    var
        ConsumeHttp: Codeunit "SDH Consume Http";
        SourceURL: Text;
        ResultsTxt: Text;
        SimpleCallHttpLbl: Label 'Simple Call';
        WebServiceReadLbl: Label 'Web Service Read';
        WebServiceReadWriteLbl: Label 'Web Service Read Write';
}