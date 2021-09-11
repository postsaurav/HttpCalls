codeunit 50000 "SDH Consume Http"
{

    var
        ClientErr: Label 'Invalid URL %1', Comment = '%1 URL';
        ClientHttpClient: HttpClient;
        ClientHttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;

    procedure SimpleHttpCall(URL: Text): Text
    begin
        if not ClientHttpClient.Get(URL, ClientHttpResponseMessage) then
            Error(StrSubstNo(ClientErr, URL));

        if ClientHttpResponseMessage.IsSuccessStatusCode() then
            ClientHttpResponseMessage.Content().ReadAs(ResponseText);
        exit(ResponseText);
    end;

    procedure ReadWebService(URL: Text): Text
    var
        RequestHeader: HttpHeaders;
    begin
        RequestHeader := ClientHttpClient.DefaultRequestHeaders();
        RequestHeader.Add('Authorization', CreateBasicAuthHeader('apitest', '@*apiTest*'));
        if not ClientHttpClient.Get(URL, ClientHttpResponseMessage) then
            Error(StrSubstNo(ClientErr, URL));

        if ClientHttpResponseMessage.IsSuccessStatusCode() then
            ClientHttpResponseMessage.Content().ReadAs(ResponseText);
        exit(ResponseText);
    end;

    procedure ReadWriteWebService(URL: Text): Text
    var
        TempJsonBuffer: Record "JSON Buffer" temporary;
        RequestHeader: HttpHeaders;
    begin
        RequestHeader := ClientHttpClient.DefaultRequestHeaders();
        RequestHeader.Add('Authorization', CreateBasicAuthHeader('apitest', '@*apiTest*'));
        if not ClientHttpClient.Get(URL, ClientHttpResponseMessage) then
            Error(StrSubstNo(ClientErr, URL));

        if ClientHttpResponseMessage.IsSuccessStatusCode() then
            ClientHttpResponseMessage.Content().ReadAs(ResponseText);

        TempJsonBuffer.ReadFromText(ResponseText);
        WriteRecords(TempJsonBuffer);
        //exit(ResponseText);
    end;

    procedure CreateBasicAuthHeader(UserName: Text; Password: Text): Text
    var
        TempBlob: Record TempBlob;
    begin
        TempBlob.WriteAsText(StrSubstNo('%1:%2', UserName, Password), TextEncoding::UTF8);
        exit(StrSubstNo('Basic %1', TempBlob.ToBase64String()));
    end;

    local procedure WriteRecords(var JsonBuffer: Record "JSON Buffer" temporary)
    var
        DemoTable: Record "SDH Demo";
        LastEntryNo: Integer;
        i: Integer;
        Returnval: Text;
    begin
        LastEntryNo := GetLastRecordEntryNo(JsonBuffer);
        JsonBuffer.Reset();
        for i := 1 to LastEntryNo do begin
            DemoTable.Init();
            if JsonBuffer.GetPropertyValueAtPath(Returnval, 'Code', 'value[' + Format(i) + '].Code') then
                DemoTable.Code := CopyStr(Returnval, 1, MaxStrLen(DemoTable.Code));
            if JsonBuffer.GetPropertyValueAtPath(Returnval, 'Description', 'value[' + Format(i) + '].Description') then
                DemoTable.Description := CopyStr(Returnval, 1, MaxStrLen(DemoTable.Description));
            DemoTable.Insert(true);
        end;
    end;

    local procedure GetLastRecordEntryNo(var JsonBuffer: Record "JSON Buffer" temporary): Integer
    var
        tempString: Text;
        pos: Integer;
        maxrecord: Integer;
    begin
        JsonBuffer.Reset();
        JsonBuffer.SetRange(Depth, 3);
        if JsonBuffer.FindLast() then begin
            tempString := CopyStr(JsonBuffer.Path, 7);
            pos := StrPos(tempString, ']');
            tempString := CopyStr(tempString, 1, pos - 1);
            Evaluate(maxrecord, tempString);
            exit(maxrecord);
        end;
    end;
}