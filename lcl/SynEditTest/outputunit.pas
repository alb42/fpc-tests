unit OutPutUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynMemo, Forms, Controls, Graphics, Dialogs,
  StdCtrls, LCLType, Menus;

const
  FatalMark   = ' ' + #27 + 'I[2:88888888,00000000,00000000]  ';
  ErrorMark   = ' ' + #27 + 'I[2:ffffffff,00000000,00000000]  ';
  WarnMark = ' ' + #27 + 'I[2:ffffffff,ffffffff,00000000]  ';
  NoteMark = ' ' + #27 + 'I[2:00000000,ffffffff,00000000]  ';
type
  TMsgData = record
    Filename: string;
    Line: integer;
    Pos: Integer;
  end;

  { TOutWindow }

  TOutWindow = class(TForm)
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    TextMenu: TMenuItem;
    OutList: TListBox;
    OutMemo: TSynMemo;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure OutListDblClick(Sender: TObject);
  private
    Files: TStringList;
    OrigText: TStringList;
    function FPCLine(Line: string;out Data: TMsgData): boolean;
    function GCCLine(Line: string;out Data: TMsgData): boolean;
    procedure BeautifyFPC;
    procedure BeautifyGCC;
  public
    CaptureMode: Integer;
    FPath: string;
    procedure BeautifyIt;
  end;

var
  OutWindow: TOutWindow;

implementation

uses
  {$ifdef HASAMIGA}
  muiformsunit,
  {$endif}
  MainUnit, FrameUnit, PrefsUnit;

{$R *.lfm}

{ TOutWindow }

procedure TOutWindow.OutListDblClick(Sender: TObject);
var
  Data: TMsgData;
  Idx: Integer;
  TabIdx: Integer;
  i: Integer;
  Valid: Boolean;
begin
  Data.Filename := '';
  Idx := OutList.ItemIndex;
  if (Idx >= 0) and (Idx < Origtext.Count) then
  begin
    case CaptureMode of
      0: Valid := FPCLine(Origtext[Idx], Data);
      1: Valid := GCCLine(Origtext[Idx], Data);
      else
        Valid := False;
    end;
    if Valid then
    begin
      TabIdx := -1;
      for i := 0 to MainWindow.Tabs.TabCount - 1 do
      begin
        if LowerCase(ExtractFilename(TEditorFrame(MainWindow.Tabs.GetTabData(i).TabObject).Filename)) = LowerCase(Data.FileName) then
        begin
          TabIdx := i;
          Break;
        end;
      end;
      if TabIdx >= 0 then
      begin
        MainWindow.Tabs.TabIndex := TabIdx;
        MainWindow.CurEditor.CaretXY := Point(Data.Pos, Data.Line);
      end else
      begin
        if FPath <> '' then
        begin
          if FileExists(IncludeTrailingPathDelimiter(FPath) + Data.FileName) then
          begin
            MainWindow.TabPlusClickEvent(nil);
            MainWindow.LoadFile(IncludeTrailingPathDelimiter(FPath) + Data.FileName);
            MainWindow.CurEditor.CaretXY := Point(Data.Pos, Data.Line);
            Exit;
          end;
        end;
        for i := 0 to Files.Count - 1 do
        begin
          if ExtractFileName(Files.Strings[i]) = Lowercase(Data.Filename) then
          begin
            if FileExists(Files.Strings[i]) then
            begin
              MainWindow.TabPlusClickEvent(nil);
              MainWindow.LoadFile(Files.Strings[i]);
              MainWindow.CurEditor.CaretXY := Point(Data.Pos, Data.Line);
              Exit;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TOutWindow.FormCreate(Sender: TObject);
begin
  Files := TStringList.Create;
  OrigText := TStringList.Create;
  SetBounds(Prefs.OutXPos, Prefs.OutYPos, Prefs.OutWidth, Prefs.OutHeight);
end;

procedure TOutWindow.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Prefs.OutXPos := Left;
  Prefs.OutYPos := Top;
  Prefs.OutHeight := Height;
  Prefs.OutWidth := Width;
end;

procedure TOutWindow.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  {$ifdef AROS}
  // dirty hack to get the window position again ;)
  if HandleAllocated and (TObject(Handle) is TMUIWindow) then
  begin
    Left := TMUIWindow(Handle).Left;
    Top := TMUIWindow(Handle).Top;
  end;
  {$endif}
  Prefs.OutXPos := Left;
  Prefs.OutYPos := Top;
  Prefs.OutHeight := Height;
  Prefs.OutWidth := Width;
end;

procedure TOutWindow.FormDestroy(Sender: TObject);
begin
  Files.Free;
  OrigText.Free;
end;

procedure TOutWindow.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Shift = [ssCtrl]) and (Key = VK_C) then
  begin
    OutMemo.DoCopyToClipboard(OutMemo.Text, '');
  end;
end;

procedure TOutWindow.FormShow(Sender: TObject);
begin

end;

procedure TOutWindow.MenuItem1Click(Sender: TObject);
begin
  OutMemo.DoCopyToClipboard(OutMemo.Text, '');
end;

function TOutWindow.FPCLine(Line: string; out Data: TMsgData): boolean;
var
  StartLine, startpos, StartType: Integer;
  Posi: string;
begin
  Result := False;
  StartLine := Pos('(', Line);
  StartType := Pos(')', Line);
  if (StartLine > 0) and (StartType > 0) then
  begin
    Data.Filename := Trim(Copy(Line, 1, StartLine - 1));
    Posi := Trim(Copy(Line, StartLine + 1, StartType - StartLine - 1));
    StartPos := Pos(',', Posi);
    if StartPos <= 0 then
      Exit;
    Data.Line := StrToIntDef(Copy(Posi, 1, StartPos - 1), -1);
    Data.Pos := StrToIntDef(Copy(Posi, StartPos + 1, Length(Posi)), -1);
    Result := True;
  end;
end;

function TOutWindow.GCCLine(Line: string; out Data: TMsgData): boolean;
var
  SL: TStringList;
begin
  Result := False;
  SL := TStringList.create;
  try
    ExtractStrings([':'], [' '], PChar(Line), SL);
    if SL.Count > 3 then
    begin
      Data.Filename := trim(SL[0]);
      Data.Line := StrToIntDef(SL[1], -1);
      Data.Pos := StrToIntDef(SL[2], 0);
      if Data.Line >= 0 then
        Result := True;
    end;
  finally
    SL.Free;
  end;
end;

procedure TOutWindow.BeautifyFPC;
var
  Line: string;
  //Filename: string;
  StartLine, StartType, StartMsg: Integer;
  i: Integer;
  //len: Integer;
  Msg: string;
  //Posi: string;
begin
  Files.Clear;
  Origtext.Assign(Outlist.Items);
  for i := 0 to OutList.Items.Count - 1 do
  begin
    Line := OutList.Items[i];
    //Len := Length(Line);
    //
    StartLine := Pos('Compiling ', Line);
    if StartLine = 1 then
    begin
      Delete(Line, 1, Length('Compiling '));
      Files.Add(LowerCase(Line));
      Continue;
    end;
    StartLine := Pos('(', Line);
    StartType := Pos(')', Line);
    StartMsg := Pos(':', Line);
    if (StartLine > 0) and (StartType > 0) and (StartMsg > 0) then
    begin
      Msg := Trim(Copy(Line, StartType + 1, StartMsg - StartType - 1));
      //Posi := Trim(Copy(Line, StartLine + 1, StartType - StartLine - 1));
      //Filename := Trim(Copy(Line, 1, StartLine - 1));
      Line := Line + chr(27)+'n';
      if (Msg = 'Note') or (Msg = 'Hint') then
      begin
        Insert(chr(27) + 'i', Line , StartType + 1);
        Insert(NoteMark, Line, 1);
      end;
      if Msg = 'Warning' then
      begin
        Insert(chr(27) + '5', Line , StartType + 1);
        Insert(WarnMark, Line, 1);
      end;
      if Msg = 'Error' then
      begin
        Insert(chr(27) + 'b', Line , StartType + 1);
        Insert(ErrorMark, Line, 1);
      end;
      if Msg = 'Fatal' then
      begin
        Insert(chr(27) + 'u' + Chr(27) + 'b', Line , StartType + 1);
        Insert(FatalMark, Line, 1);
      end;
      OutList.Items[i] := Line;
    end;
  end;
end;

procedure TOutWindow.BeautifyGCC;
var
  Line: string;
  Msg: string;
  i, Len: Integer;
  c: Integer;
  dbl: array[0..3] of Integer; // positions of ':'
  Idx: Integer;
begin
  Files.Clear;
  Origtext.Assign(Outlist.Items);
  for i := 0 to OutList.Items.Count - 1 do
  begin
    Line := OutList.Items[i];
    Len := Length(Line);
    dbl[0] := 0;
    dbl[1] := 0;
    dbl[2] := 0;
    Idx := 0;
    for c := 1 to Len do
    begin
      if Line[c] = ':' then
      begin
        dbl[Idx] := c;
        Inc(Idx);
        if Idx > High(dbl) then
          Break;
      end;
    end;
    if Idx <= High(dbl) then
      Continue;
    Msg := trim(copy(Line, dbl[2] + 1, dbl[3] - dbl[2] - 1));
    //writeln('"',msg,'"');
    Line := Line + chr(27)+'n';
    if Msg = 'note' then
    begin
      Insert(chr(27) + 'i' + chr(27) + 'b', Line , dbl[2] + 1);
      Insert(NoteMark, Line, 1);
    end;
    if Msg = 'warning' then
    begin
      Insert(chr(27) + '5', Line , dbl[2] + 1);
      Insert(WarnMark, Line, 1);
    end;
    if Msg = 'error' then
    begin
      Insert(chr(27) + 'b', Line , dbl[2] + 1);
      Insert(ErrorMark, Line, 1);
    end;
    if Msg = 'fatal' then
    begin
      Insert(chr(27) + 'u' + Chr(27) + 'b', Line , dbl[2] + 1);
      Insert(FatalMark, Line, 1);
    end;
    OutList.Items[i] := Line;
  end;
end;

procedure TOutWindow.BeautifyIt;
begin
  case CaptureMode of
    0: BeautifyFPC;
    1: BeautifyGCC;
  end;
end;

end.

