unit SearchAllResultsUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  {$ifdef HASAMIGA}
  Workbench, muiformsunit,
  {$endif}
  ATTabs, fgl, SynEdit, FrameUnit, MainUnit, Contnrs;
type
  TSearchResult = class
    Frame: TEditorFrame;
    StartPos: TPoint;
    EndPos: TPoint;
    TextLine: string;
    Filename: string;
  end;

  TResultList = TObjectList;

  { TSearchResultsWin }

  TSearchResultsWin = class(TForm)
    ListBox: TListBox;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListBoxDblClick(Sender: TObject);
  private
    procedure TabCloseEvent(Sender: TObject; ATabIndex: Integer; var ACanClose, ACanContinue: boolean);
    function TabNumByFrame(Frame: TEditorFrame): Integer;
    function TabNumByFilename(AFileName: string): Integer;
  public
    ResultTabs: TATTabs;
    procedure TabClickEvent(Sender: TObject);
  end;

var
  SearchResultsWin: TSearchResultsWin;

implementation

uses
  PrefsUnit;

{$R *.lfm}

{ TSearchResultsWin }

procedure TSearchResultsWin.FormCreate(Sender: TObject);
begin
  Left := Prefs.SAllXPos;
  Top := Prefs.SAllYPos;
  Width := Prefs.SAllWidth;
  Height := Prefs.SAllHeight;
  // Tab control initial Values
  ResultTabs := TATTabs.create(Self);
  ResultTabs.Align:= alTop;
  ResultTabs.Font.Size:= 8;
  ResultTabs.Height:= 42;
  ResultTabs.TabAngle:= 0;
  ResultTabs.TabIndentInter:= 2;
  ResultTabs.TabIndentInit:= 2;
  ResultTabs.TabIndentTop:= 4;
  ResultTabs.TabIndentXSize:= 13;
  ResultTabs.TabWidthMin:= 18;
  ResultTabs.TabDragEnabled:= False;
  ResultTabs.TabShowPlus:= False;

  // Tab control Colors
  ResultTabs.Font.Color:= clBlack;
  ResultTabs.ColorBg:= $F9EADB;
  ResultTabs.ColorBorderActive:= $ACA196;
  ResultTabs.ColorBorderPassive:= $ACA196;
  ResultTabs.ColorTabActive:= $FCF5ED;
  ResultTabs.ColorTabPassive:= $E0D3C7;
  ResultTabs.ColorTabOver:= $F2E4D7;
  ResultTabs.ColorCloseBg:= clNone;
  ResultTabs.ColorCloseBgOver:= $D5C9BD;
  ResultTabs.ColorCloseBorderOver:= $B0B0B0;
  ResultTabs.ColorCloseX:= $7B6E60;
  ResultTabs.ColorArrow:= $5C5751;
  ResultTabs.ColorArrowOver:= ResultTabs.ColorArrow;
  ResultTabs.Parent := Self;
  // Tab Control Events
  //ResultTabs.OnTabPlusClick:=@TabPlusClickEvent;
  ResultTabs.OnTabClose:=@TabCloseEvent;
  ResultTabs.OnTabClick:=@TabClickEvent;
end;

procedure TSearchResultsWin.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  {$ifdef AROS}
  // dirty hack to get the window position again ;)
  if HandleAllocated and (TObject(Handle) is TMUIWindow) then
  begin
    Left := TMUIWindow(Handle).Left;
    Top := TMUIWindow(Handle).Top
  end;
  {$endif}
  Prefs.SAllXPos := Left;
  Prefs.SAllYPos := Top;
  Prefs.SAllWidth := Width;
  Prefs.SAllHeight := Height;
end;

procedure TSearchResultsWin.FormDestroy(Sender: TObject);
begin
  //
end;

procedure TSearchResultsWin.ListBoxDblClick(Sender: TObject);
var
  Obj: TObject;
  SResult: TSearchResult;
  TabIdx: Integer;
  Editor: TSynEdit;
begin
  if (ListBox.ItemIndex >= 0) and (ListBox.ItemIndex < ListBox.Items.Count) then
  begin
    Obj := ListBox.Items.Objects[ListBox.ItemIndex];
    if Assigned(Obj) and (Obj is TSearchResult) then
    begin
      SResult := TSearchResult(Obj);
      if Assigned(SResult.Frame) then
      begin
        TabIdx := TabNumByFrame(SResult.Frame);
        if TabIdx < 0 then
        begin
          ShowMessage('File already closed.');
          Exit;
        end;
        MainWindow.Tabs.TabIndex := TabIdx;
        Editor := SResult.Frame.Editor;
        Editor.LogicalCaretXY := SResult.EndPos;
        Editor.BlockBegin := SResult.StartPos;
        Editor.BlockEnd := SResult.EndPos;
        Editor.LogicalCaretXY := SResult.StartPos;
      end else
      begin
        TabIdx := TabNumByFilename(SResult.Filename);
        if TabIdx >= 0 then
        begin
          MainWindow.Tabs.TabIndex := TabIdx;
        end else
        begin
          MainWindow.TabPlusClickEvent(nil);
          MainWindow.LoadFile(SResult.Filename);
        end;
        Editor := MainWindow.CurEditor;
        Editor.LogicalCaretXY := SResult.EndPos;
        Editor.BlockBegin := SResult.StartPos;
        Editor.BlockEnd := SResult.EndPos;
        Editor.LogicalCaretXY := SResult.StartPos;
      end;
    end;
  end;
end;

procedure TSearchResultsWin.TabCloseEvent(Sender: TObject; ATabIndex: Integer; var ACanClose, ACanContinue: boolean);
var
  ResultList: TResultList;
begin
  ResultList := TResultList(ResultTabs.GetTabData(ATabIndex).TabObject);
  ResultList.Free;
  ACanClose := True;
  ListBox.Clear;
end;

procedure TSearchResultsWin.TabClickEvent(Sender: TObject);
var
  BOLDMARKUP: string;
  NORMALMARKUP: string;
  ResultList: TResultList;
  SResult: TSearchResult;
  LastEdit: TSynEdit;
  i: Integer;
  TabIdx: Integer;
  Filename: String;
  LastFile: string;
  TextLine: String;
begin
  {$ifdef HASAMIGA}
  BOLDMARKUP := Chr(27) + 'b';
  NORMALMARKUP := Chr(27) + 'n';
  {$else}
  BOLDMARKUP := '';
  NORMALMARKUP := '';
  {$endif}

  ListBox.Items.BeginUpdate;
  ListBox.Clear;
  LastEdit := nil;
  LastFile := '';
  ResultList := TResultList(ResultTabs.GetTabData(ResultTabs.TabIndex).TabObject);
  for i := 0 to ResultList.Count - 1 do
  begin
    SResult := TSearchResult(ResultList.Items[i]);
    if Assigned(SResult.Frame) then
    begin
      TabIdx := TabNumByFrame(SResult.Frame);
      if TabIdx < 0 then // result Deleted :-O
        Continue;
      if SResult.Frame.Editor <> LastEdit then
      begin
        LastEdit := SResult.Frame.Editor;
        Filename := SResult.Frame.Filename;
        if Filename = '' then
          Filename := MainWindow.Tabs.GetTabData(TabIdx).TabCaption;
        ListBox.AddItem(BOLDMARKUP + 'Tab ' + IntToStr(TabIdx + 1) + ': ' + Filename + NORMALMARKUP, nil);
      end;
      TextLine := SResult.Frame.Editor.Lines.Strings[SResult.StartPos.Y - 1];
      Insert(NORMALMARKUP, TextLine, SResult.EndPos.X);
      Insert(BOLDMARKUP, TextLine, SResult.StartPos.X);
      ListBox.AddItem('    ' + Format('%4d', [SResult.StartPos.Y]) + ': ' + TextLine, SResult);
    end else
    begin
      if SResult.Filename <> LastFile then
      begin
        LastFile := SResult.Filename;
        Filename := SResult.Filename;
        ListBox.AddItem(BOLDMARKUP + 'File:' + Filename + NORMALMARKUP, nil);
      end;
      TextLine := SResult.TextLine;
      Insert(NORMALMARKUP, TextLine, SResult.EndPos.X);
      Insert(BOLDMARKUP, TextLine, SResult.StartPos.X);
      ListBox.AddItem('    ' + Format('%4d', [SResult.StartPos.Y]) + ': ' + TextLine, SResult);
    end;
  end;
  ListBox.Items.EndUpdate;
end;

function TSearchResultsWin.TabNumByFrame(Frame: TEditorFrame): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to MainWindow.Tabs.TabCount - 1 do
  begin
    if MainWindow.Tabs.GetTabData(i).TabObject = Frame then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

function TSearchResultsWin.TabNumByFilename(AFileName: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to MainWindow.Tabs.TabCount - 1 do
  begin
    if LowerCase(TEditorFrame(MainWindow.Tabs.GetTabData(i).TabObject).Filename) = LowerCase(AFileName) then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

end.
