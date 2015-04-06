unit PrefsWinUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, PrefsUnit, ATTabs, types, SynEdit, Syngutterlinenumber,
  SynEditHighlighter, SynHighlighterPas, SynHighlighterCpp, SynEditTypes,
  FrameUnit, lclProc, lcltype, stringhashlist, ValEdit, SynEditkeycmds,
  SynHighlighterHTML, Grids, menus;

const
  PasShortText =
    'unit Test;'#13#10 +
    '{$mode delphi}'#13#10 +
    '{%Fold%}'#13#10 +
    '  // Comment'#13#10 +
    'begin'#13#10 +
    '  writeln(''string'', 42);'#13#10 +
    '  asm'#13#10 +
    '    nop;'#13#10 +
    '  end;'#13#10 +
    '  b := 1 + color;'#13#10 +
    '  case Align of'#13#10 +
    '    alClient: writeln(''alClient''#13#10);'#13#10 +
    '  end;'#13#10 +
    'end.';
  CShortText =
    ' /*Comment*/ '#13#10 +
    '#include <stdio.h>'#13#10 +
    'int main(int argc, char **argv)'#13#10 +
    '{'#13#10 +
    '  int a = r + 10;'#13#10 +
    '  printf("hello world\n");'#13#10 +
    '  return 0'#13#10 +
    '}';


type
{$IF sizeof(TShiftState)=2}
  TShiftStateInt = word;
{$ELSE}
  TShiftStateInt = integer;
{$ENDIF}
  TIDEShortCut = record
    Key1: word;
    Shift1: TShiftState;
    Key2: word;
    Shift2: TShiftState;
  end;
  PIDEShortCut = ^TIDEShortCut;
  { TCustomShortCutGrabBox }

  TCustomShortCutGrabBox = class(TCustomPanel)
  private
    FAllowedShifts: TShiftState;
    FGrabButton: TButton;
    FKey: Word;
    FKeyComboBox: TComboBox;
    FShiftButtons: TShiftState;
    FShiftState: TShiftState;
    FCheckBoxes: array[TShiftStateEnum] of TCheckBox;
    FGrabForm: TForm;
    function GetShiftCheckBox(Shift: TShiftStateEnum): TCheckBox;
    procedure SetAllowedShifts(const AValue: TShiftState);
    procedure SetKey(const AValue: Word);
    procedure SetShiftButtons(const AValue: TShiftState);
    procedure SetShiftState(const AValue: TShiftState);
    procedure OnGrabButtonClick(Sender: TObject);
    procedure OnShiftCheckBoxClick(Sender: TObject);
    procedure OnGrabFormKeyDown(Sender: TObject; var AKey: Word;
      AShift: TShiftState);
    procedure OnKeyComboboxEditingDone(Sender: TObject);
  protected
    procedure Loaded; override;
    procedure RealSetText(const Value: TCaption); override;
    procedure UpdateShiftButons;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
           override;
    function ShiftToStr(s: TShiftStateEnum): string;
  public
    constructor Create(TheOwner: TComponent); override;
    function GetDefaultShiftButtons: TShiftState;
    property ShiftState: TShiftState read FShiftState write SetShiftState;
    property Key: Word read FKey write SetKey;
    property ShiftButtons: TShiftState read FShiftButtons write SetShiftButtons;
    property AllowedShifts: TShiftState read FAllowedShifts write SetAllowedShifts;
    property KeyComboBox: TComboBox read FKeyComboBox;
    property GrabButton: TButton read FGrabButton;
    property ShiftCheckBox[Shift: TShiftStateEnum]: TCheckBox read GetShiftCheckBox;
  end;

  { TPrefsWin }

  TPrefsWin = class(TForm)
    AcceptButton: TButton;
    ClearButton: TButton;
    CancelButton: TButton;
    ColEdBracket: TColorButton;
    KeyBox1: TPanel;
    Label21: TLabel;
    KeyPage: TTabSheet;
    Panel2: TPanel;
    KeyBox: TPanel;
    KeyPAnel: TPanel;
    SynHTMLSyn1: TSynHTMLSyn;
    UseTextCol: TCheckBox;
    UseBgCol: TCheckBox;
    UseFrameCol: TCheckBox;
    ColEdBg: TColorButton;
    ColEdText: TColorButton;
    colHText: TColorButton;
    ColHBack: TColorButton;
    ColHFrame: TColorButton;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    SynEdit1: TSynEdit;
    Panel1: TPanel;
    SynCppSyn1: TSynCppSyn;
    SynPasSyn1: TSynPasSyn;
    SyntaxItems: TComboBox;
    LangSelection: TComboBox;
    Label10: TLabel;
    Label17: TLabel;
    UseBookmarks: TCheckBox;
    UseChangeInd: TCheckBox;
    UseNewTab: TCheckBox;
    UseFullPath: TCheckBox;
    UseLineNum: TCheckBox;
    ChooseLine: TComboBox;
    TABPanel: TGroupBox;
    SelectionPanel: TGroupBox;
    SidePanel: TGroupBox;
    FilePanel: TGroupBox;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    OkButton: TButton;
    UseTabsToSpace: TCheckBox;
    USeTrimSpaces: TCheckBox;
    UseTabIndent: TCheckBox;
    UseAutoIndent: TCheckBox;
    UseDblSelect: TCheckBox;
    UseBlockOverride: TCheckBox;
    UsePersistenBlock: TCheckBox;
    ChooseTabWidth: TComboBox;
    ChooseIndentWidth: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Pages: TPageControl;
    Panel3: TPanel;
    EditorTab: TTabSheet;
    HighLightTab: TTabSheet;
    KeyListEdit: TValueListEditor;
    procedure AcceptButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure ColEdBgColorChanged(Sender: TObject);
    procedure ColEdBracketClick(Sender: TObject);
    procedure ColEdTextColorChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure KeyListEditSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure LangSelectionChange(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure SyntaxItemsChange(Sender: TObject);
    procedure UseTextColClick(Sender: TObject);
  private
    FPrimaryKey1Box:TCustomShortCutGrabBox;
    CurAtt: TSynHighlighterAttributes;
    procedure TabClickEvent(Sender: TObject);
    Function GetAtt: TSynHighlighterAttributes;
    procedure GetAttSetting;
    procedure SetAttSetting;
  public
    CurRow: Integer;
    BlockEvent: Boolean;
    Tabs: TATTabs;
    Procedure PrefsToEditor(EdFrame: TEditorFrame);
  end;

var
  PrefsWin: TPrefsWin;
  PasPrefsName: string;
  CPrefsName: string;
  HTMLPrefsName: string;
  VirtualKeyStrings: TStringHashList = nil;
  CmdName: array[0..1000] of string;
  ShortCutList: array of record
    Command: TSynEditorCommand;
    CommandName: string;
    ShortCut: TShortCut;
  end;

implementation

uses
  MainUnit;

const
  CNames: array[0..9] of string = (
    'Assembler',
    'Comment',
    'Directive',
    'Identifier',
    'Invalid',
    'Keyword',
    'Number',
    'Space',
    'String',
    'Symbol'
    );
  HTMLNames: array[0..9] of string = (
    'And Codes',
    'ASP',
    'Comment',
    'Identifier',
    'Keyword',
    'Space',
    'Symbol',
    'Text',
    'Undef',
    'Value'
    );
  PasNames: array[0..10] of string = (
    'Assembler',
    'Case Label',
    'Comment',
    'Directive',
    'IDE Directive',
    'Identifier',
    'Keyword',
    'Number',
    'Space',
    'String',
    'Symbol'
    );

{$R *.lfm}

function CompareIDEShortCuts(Data1, Data2: Pointer): integer;
var
  ShortCut1: PIDEShortCut absolute Data1;
  ShortCut2: PIDEShortCut absolute Data2;
begin
  if ShortCut1^.Key1>ShortCut2^.Key1 then
    Result:=1
  else if ShortCut1^.Key1<ShortCut2^.Key1 then
    Result:=-1
  else if TShiftStateInt(ShortCut1^.Shift1)>TShiftStateInt(ShortCut2^.Shift1) then
    Result:=1
  else if TShiftStateInt(ShortCut1^.Shift1)<TShiftStateInt(ShortCut2^.Shift1) then
    Result:=-1
  else if ShortCut1^.Key2>ShortCut2^.Key2 then
    Result:=1
  else if ShortCut1^.Key2<ShortCut2^.Key2 then
    Result:=-1
  else if TShiftStateInt(ShortCut1^.Shift2)>TShiftStateInt(ShortCut2^.Shift2) then
    Result:=1
  else if TShiftStateInt(ShortCut1^.Shift2)<TShiftStateInt(ShortCut2^.Shift2) then
    Result:=-1
  else
    Result:=0;
end;

{ TPrefsWin }

procedure TPrefsWin.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  CurRow := -1;
  FPrimaryKey1Box:=TCustomShortCutGrabBox.Create(Self);
  with FPrimaryKey1Box do begin
    Name:='FPrimaryKey1Box';
    Caption := 'Select short cut';
    Align:=alClient;
    AutoSize:=true;
    BorderSpacing.Around:=6;
    Parent:=KeyPanel;
  end;
  for i := 0 to High(CmdName) do
  begin
    CmdName[i] := '';
  end;
  CmdName[0] := 'ecGoToLine';
  CmdName[1] := 'ecSaveFile';
  CmdName[2] := 'ecOpenFile';
  CmdName[3] := 'ecSaveAs';
  CmdName[4] := 'ecFind';
  CmdName[5] := 'ecFindAgain';
  CmdName[6] := 'ecFindAgainBackwards';
  CmdName[7] := 'ecReplace';
  CmdName[8] := 'ecNewTab';
  CmdName[9] := 'ecCloseTab';
  CmdName[10] := 'ecPreviousTab';
  CmdName[11] := 'ecNextTab';
  CmdName[12] := 'ecSearchAll';
  BlockEvent := False;
  CurAtt := nil;
  Tabs := TATTabs.create(Self);
  Tabs.Align:= alTop;
  Tabs.Height:= 42;
  Tabs.TabAngle:= 0;
  Tabs.TabIndentInter:= 2;
  Tabs.TabIndentInit:= 2;
  Tabs.TabIndentTop:= 4;
  Tabs.TabIndentXSize:= 13;
  Tabs.TabWidthMin:= 18;
  Tabs.TabDragEnabled:= False;
  Tabs.TabShowMenu:= False;
  Tabs.TabShowPlus:= False;
  Tabs.TabShowClose := tbShowNone;
  // Tab control Colors
  Tabs.Font.Color:= clBlack;
  Tabs.ColorBg:= $F9EADB;
  Tabs.ColorBorderActive:= $ACA196;
  Tabs.ColorBorderPassive:= $ACA196;
  Tabs.ColorTabActive:= $FCF5ED;
  Tabs.ColorTabPassive:= $E0D3C7;
  Tabs.ColorTabOver:= $F2E4D7;
  Tabs.ColorCloseBg:= clNone;
  Tabs.ColorCloseBgOver:= $D5C9BD;
  Tabs.ColorCloseBorderOver:= $B0B0B0;
  Tabs.ColorCloseX:= $7B6E60;
  Tabs.ColorArrow:= $5C5751;
  Tabs.ColorArrowOver:= Tabs.ColorArrow;
  Tabs.Parent := Self;
  for i := 0 to Pages.PageCount - 1 do
    Tabs.AddTab(i, Pages.Pages[i].Caption, nil);
  Tabs.TabIndex := 0;
  Pages.PageIndex := 0;
  // Tab Control Events
  Tabs.OnTabClick:=@TabClickEvent;
end;

procedure TPrefsWin.ColEdBgColorChanged(Sender: TObject);
begin
  SynEdit1.Color := ColEdBg.ButtonColor;
end;

procedure TPrefsWin.ColEdBracketClick(Sender: TObject);
begin
  SynEdit1.BracketMatchColor.Background := ColEdBracket.ButtonColor;
end;

procedure TPrefsWin.ColEdTextColorChanged(Sender: TObject);
begin
  SynEdit1.Font.Color := ColEdText.ButtonColor;
end;

procedure TPrefsWin.FormShow(Sender: TObject);
var
  i: Integer;
  ShortCut: TShortCut;
  cmd: String;
  j: Integer;
begin
  // Tab Settings
  UseTabsToSpace.Checked := Prefs.TabsToSpaces;
  ChooseTabWidth.ItemIndex := ChooseTabWidth.Items.IndexOf(IntToStr(Prefs.TabWidth));
  if ChooseTabWidth.ItemIndex = -1 then
    ChooseTabWidth.ItemIndex := 1;
  UseTabIndent.Checked := Prefs.TabIndent;
  ChooseIndentWidth.ItemIndex := ChooseIndentWidth.Items.IndexOf(IntToStr(Prefs.IndentWidth));
  if ChooseIndentWidth.ItemIndex = -1 then
    ChooseIndentWidth.ItemIndex := 1;
  UseAutoIndent.Checked := Prefs.AutoIndent;
  UseTrimSpaces.Checked := Prefs.TrimSpaces;
  // Sidebar
  UseLineNum.Checked := Prefs.LineNumbers;
  ChooseLine.ItemIndex := ChooseLine.Items.IndexOf(IntToStr(Prefs.LineSkipNum));
  if ChooseLine.ItemIndex = -1 then
    ChooseLine.ItemIndex := 3;
  UseBookmarks.Checked := Prefs.Bookmarks;
  UseChangeInd.Checked := Prefs.ChangeIndicator;
  // File Handling
  UseNewTab.Checked := Prefs.OpenNewTab;
  UseFullPath.Checked := Prefs.FullPath;
  // selection
  UseDblSelect.Checked := Prefs.DblSelLine;
  UseBlockOverride.Checked := Prefs.BlockOverwrite;
  UsePersistenBlock.Checked := Prefs.PersistentBlock;
  // Colors
  ColEdBg.ButtonColor := Prefs.EdBgColor;
  ColEdText.ButtonColor := Prefs.EdTextColor;
  ColEdBracket.ButtonColor := Prefs.BracketColor;
  // Highlighter
  SynPasSyn1.LoadFromFile(PasPrefsName);
  SynCppSyn1.LoadFromFile(CPrefsName);
  SynPasSyn1.LoadFromFile(HTMLPrefsName);
  LangSelectionChange(nil);
  // ShortCuts
  KeyListEdit.BeginUpdate;
  KeyListEdit.Clear;
  SetLength(ShortCutList, SynEdit1.Keystrokes.Count);
  for i := 0 to SynEdit1.Keystrokes.Count - 1 do
  begin
    ShortCutList[i].ShortCut := Prefs.IniFile.ReadInteger(SECTION_SHORTCUTS,  IntToStr(i) + EditorCommandToCodeString(SynEdit1.Keystrokes.Items[i].Command), SynEdit1.Keystrokes.Items[i].ShortCut);
    ShortCutList[i].Command := SynEdit1.Keystrokes.Items[i].Command;
    ShortCutList[i].CommandName := '';
    if ShortCutList[i].Command >= ecUserDefinedFirst then
    begin
      ShortCutList[i].CommandName := CmdName[ShortCutList[i].Command - ecUserDefinedFirst];
    end;
    if ShortCutList[i].CommandName = '' then
      ShortCutList[i].CommandName := EditorCommandToCodeString(SynEdit1.Keystrokes.Items[i].Command);
    Delete(ShortCutList[i].CommandName, 1, 2);
    cmd := ShortCutList[i].CommandName;
    j := 2;
    while j < Length(Cmd) do
    begin
      if UpperCase(Cmd[j]) = cmd[j] then
      begin
        Insert(' ', cmd, j);
        Inc(j);
      end;
      Inc(j);
    end;
    if trim(cmd) = '' then
      cmd := 'ERR';
    ShortCutList[i].CommandName := cmd;
    KeyListEdit.Values[IntToStr(i + 1) + '. ' + ShortCutList[i].CommandName] := ShortCutToText(ShortCutList[i].ShortCut);
    //KeyListEdit.InsertRow(IntToStr(i) + '. ' + ShortCutList[i].CommandName, ShortCutToText(ShortCutList[i].ShortCut), True);
  end;
  KeyListEdit.TitleCaptions.Strings[0] := 'Function';
  KeyListEdit.TitleCaptions.Strings[1] := 'ShortCut';
  KeyListEdit.EndUpdate;
end;

procedure TPrefsWin.KeyListEditSelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
var
  AValue: PIDEShortCut;
  Key: Word;
  Shift: TShiftState;
begin
  if (aRow > 0) and (aRow <= High(ShortCutList) + 1) then
  begin
    KeyBox.Caption := 'Define ShortCut for ' + ShortCutList[ARow - 1].CommandName;
    FPrimaryKey1Box.Visible := True;
    ShortCutToKey(ShortCutList[ARow - 1].ShortCut, Key, Shift);
    FPrimaryKey1Box.Key := Key;
    FPrimaryKey1Box.ShiftState := Shift;
    AcceptButton.Visible := True;
    ClearButton.Visible := True;
    CurRow := ARow - 1;
  end
  else
  begin
    CurRow := -1;
    FPrimaryKey1Box.Visible := False;
    KeyBox.Caption := 'none';
    AcceptButton.Visible := False;
    ClearButton.Visible:= False;
  end;
end;

procedure TPrefsWin.AcceptButtonClick(Sender: TObject);
var
  ShortCut: TShortCut;
  i: Integer;
begin
  if (CurRow >= 0) and (CurRow <= High(ShortCutList)) then
  begin
    ShortCut := KeyToShortCut(FPrimaryKey1Box.Key, FPrimaryKey1Box.ShiftState);
    for i := 0 to High(ShortCutList) do
    begin
      if (ShortCutList[i].ShortCut = ShortCut) and (i <> CurRow) then
      begin
        ShowMessage('This Shortcut is already assigned to ' + ShortCutList[i].CommandName);
        Exit;
      end;
    end;
    ShortCutList[CurRow].ShortCut := ShortCut;
    KeyListEdit.Values[ShortCutList[CurRow].CommandName] := ShortCutToText(ShortCutList[CurRow].ShortCut);
  end;
end;

procedure TPrefsWin.ClearButtonClick(Sender: TObject);
begin
  if (CurRow >= 0) and (CurRow <= High(ShortCutList)) then
  begin
    ShortCutList[CurRow].ShortCut := 0;
    KeyListEdit.Values[ShortCutList[CurRow].CommandName] := ShortCutToText(ShortCutList[CurRow].ShortCut);
  end;
end;

procedure TPrefsWin.LangSelectionChange(Sender: TObject);
var
  i: Integer;
begin
  SyntaxItems.Items.BeginUpdate;
  SyntaxItems.Clear;
  case LangSelection.ItemIndex of
    0:
    begin
      SynEdit1.Highlighter := SynCppSyn1;
      SynEdit1.Lines.Text := CShortText;
      for i := 0 to High(CNames) do
        SyntaxItems.Items.Add(CNames[i]);
    end;
    1:
    begin
      SynEdit1.Highlighter := SynPasSyn1;
      SynEdit1.Lines.Text := PasShortText;
      for i := 0 to High(PasNames) do
        SyntaxItems.Items.Add(PasNames[i]);
    end;
    2:
    begin
      SynEdit1.Highlighter := SynHTMLSyn1;
      SynEdit1.Lines.Text := HTMLText;
      for i := 0 to High(HTMLNames) do
        SyntaxItems.Items.Add(HTMLNames[i]);
    end;
  end;
  SyntaxItems.Items.EndUpdate;
end;

procedure TPrefsWin.OkButtonClick(Sender: TObject);
var
  i: Integer;
begin
  // Tab Settings
  Prefs.TabsToSpaces := UseTabsToSpace.Checked;
  Prefs.TabWidth := StrToIntDef(ChooseTabWidth.Items[ChooseTabWidth.ItemIndex], 2);
  Prefs.TabIndent := UseTabIndent.Checked;
  Prefs.IndentWidth := StrToIntDef(ChooseIndentWidth.Items[ChooseIndentWidth.ItemIndex], 2);
  Prefs.AutoIndent := UseAutoIndent.Checked;
  Prefs.TrimSpaces := UseTrimSpaces.Checked;
  // SideBar
  Prefs.LineNumbers := UseLineNum.Checked;
  Prefs.Bookmarks := UseBookmarks.Checked;
  Prefs.LineSkipNum := StrToIntDef(ChooseLine.Items[ChooseLine.ItemIndex], 10);
  Prefs.ChangeIndicator := UseChangeInd.Checked;
  // File Handling
  Prefs.OpenNewTab := UseNewTab.Checked;
  Prefs.FullPath := UseFullPath.Checked;
  // Selection
  Prefs.DblSelLine := UseDblSelect.Checked;
  Prefs.BlockOverwrite := UseBlockOverride.Checked;
  Prefs.PersistentBlock := UsePersistenBlock.Checked;
  // colors
  Prefs.EdBgColor := ColEdBg.ButtonColor;
  Prefs.EdTextColor := ColEdText.ButtonColor;
  Prefs.BracketColor := ColEdBracket.ButtonColor;
  //
  SynPasSyn1.SaveToFile(PasPrefsName);
  SynCppSyn1.SaveToFile(CPrefsName);
  SynHTMLSyn1.SaveToFile(HTMLPrefsName);
  // Keys
  for i := 0 to High(ShortCutList) do
  begin
    Prefs.IniFile.WriteInteger(SECTION_SHORTCUTS,  IntToStr(i) + EditorCommandToCodeString(ShortCutList[i].Command), ShortCutList[i].ShortCut);
  end;
  //
  ModalResult := mrYes;
end;

procedure TPrefsWin.SyntaxItemsChange(Sender: TObject);
begin
  if BlockEvent then
    Exit;
  BlockEvent := True;
  GetAttSetting;
  BlockEvent := False;
end;

procedure TPrefsWin.UseTextColClick(Sender: TObject);
begin
  if BlockEvent then
    Exit;
  BlockEvent := True;
  ColHBack.Visible := UseBgCol.Checked;
  colHText.Visible := UseTextCol.Checked;
  ColHFrame.Visible := UseFrameCol.Checked;
  SetAttSetting;
  BlockEvent := False;
end;

procedure TPrefsWin.TabClickEvent(Sender: TObject);
begin
  Pages.PageIndex := Tabs.TabIndex;
end;

function TPrefsWin.GetAtt: TSynHighlighterAttributes;
begin
  CurAtt := nil;
  case LangSelection.ItemIndex of
    0: begin
      case SyntaxItems.ItemIndex of
        0: CurAtt := SynCppSyn1.AsmAttri;
        1: CurAtt := SynCppSyn1.CommentAttri;
        2: CurAtt := SynCppSyn1.DirecAttri;
        3: CurAtt := SynCppSyn1.IdentifierAttri;
        4: CurAtt := SynCppSyn1.InvalidAttri;
        5: CurAtt := SynCppSyn1.KeyAttri;
        6: CurAtt := SynCppSyn1.NumberAttri;
        7: CurAtt := SynCppSyn1.SpaceAttri;
        8: CurAtt := SynCppSyn1.StringAttri;
        9: CurAtt := SynCppSyn1.SymbolAttri;
      end;
    end;
    1: begin
      case SyntaxItems.ItemIndex of
        0: CurAtt := SynPasSyn1.AsmAttri;
        1: CurAtt := SynPasSyn1.CaseLabelAttri;
        2: CurAtt := SynPasSyn1.CommentAttri;
        3: CurAtt := SynPasSyn1.DirectiveAttri;
        4: CurAtt := SynPasSyn1.IDEDirectiveAttri;
        5: CurAtt := SynPasSyn1.IdentifierAttri;
        6: CurAtt := SynPasSyn1.KeyAttri;
        7: CurAtt := SynPasSyn1.NumberAttri;
        8: CurAtt := SynPasSyn1.SpaceAttri;
        9: CurAtt := SynPasSyn1.StringAttri;
        10: CurAtt := SynPasSyn1.SymbolAttri;
      end;
    end;
    2: begin
      case SyntaxItems.ItemIndex of
        0: CurAtt := SynHTMLSyn1.AndAttri;
        1: CurAtt := SynHTMLSyn1.ASPAttri;
        2: CurAtt := SynHTMLSyn1.CommentAttri;
        3: CurAtt := SynHTMLSyn1.IdentifierAttri;
        4: CurAtt := SynHTMLSyn1.KeyAttri;
        5: CurAtt := SynHTMLSyn1.SpaceAttri;
        6: CurAtt := SynHTMLSyn1.SymbolAttri;
        7: CurAtt := SynHTMLSyn1.TextAttri;
        8: CurAtt := SynHTMLSyn1.UndefKeyAttri;
        9: CurAtt := SynHTMLSyn1.ValueAttri;
      end;
    end;
  end;
  Result := CurAtt;
end;

procedure TPrefsWin.GetAttSetting;
var
  Att: TSynHighlighterAttributes;
begin
  Att := GetAtt;
  if Assigned(Att) then
  begin
    // BGColor
    UseBgCol.Checked := Att.Background <> clNone;
    ColHBack.Visible := Att.Background <> clNone;
    ColHBack.ButtonColor := Att.Background;
    // TextColor
    UseTextCol.Checked := Att.Foreground <> clNone;
    colHText.Visible := Att.Foreground <> clNone;
    colHText.ButtonColor := Att.Foreground;
    // TextColor
    UseFrameCol.Checked := Att.FrameColor <> clNone;
    ColHFrame.Visible := Att.FrameColor <> clNone;
    ColHFrame.ButtonColor := Att.FrameColor;
  end;
end;

procedure TPrefsWin.SetAttSetting;
begin
  if Assigned(CurAtt) then
  begin
    if UseBgCol.Checked then
      CurAtt.Background := ColHBack.ButtonColor
    else
      CurAtt.Background := clNone;
    //
    if UseTextCol.Checked then
      CurAtt.Foreground := colHText.ButtonColor
    else
      CurAtt.Foreground := clNone;
    //
    if UseFrameCol.Checked then
    begin
      CurAtt.FrameColor := ColHFrame.ButtonColor;
      CurAtt.FrameStyle := slsSolid;
      CurAtt.FrameEdges := sfeAround;
    end else
      CurAtt.FrameColor := clNone;
  end;
end;

procedure TPrefsWin.PrefsToEditor(EdFrame: TEditorFrame);
var
  Ed: TSynEdit;
  i: Integer;
  ShortCut: TShortCut;
begin
  Ed := EdFrame.Editor;
  // Tabs/Indent Handling
  Ed.BlockIndent := Prefs.IndentWidth;
  Ed.BlockTabIndent := Prefs.TabWidth;
  Ed.TabWidth:= Prefs.TabWidth;
  if Prefs.TabsToSpaces then
    Ed.Options := Ed.Options + [eoTabsToSpaces]
  else
    Ed.Options := Ed.Options - [eoTabsToSpaces];
  if Prefs.TabIndent then
    Ed.Options := Ed.Options + [eoTabIndent]
  else
    Ed.Options := Ed.Options - [eoTabIndent];
  if Prefs.AutoIndent then
    Ed.Options := Ed.Options + [eoAutoIndent]
  else
    Ed.Options := Ed.Options - [eoAutoIndent];
  if Prefs.TrimSpaces then
    Ed.Options := Ed.Options + [eoTrimTrailingSpaces]
  else
    Ed.Options := Ed.Options - [eoTrimTrailingSpaces];
  //SideBar
  Ed.Gutter.Parts[0].Visible := Prefs.Bookmarks;
  Ed.Gutter.Parts[1].Visible := Prefs.LineNumbers;
  TSynGutterLineNumber(Ed.Gutter.Parts[1]).ShowOnlyLineNumbersMultiplesOf := Prefs.LineSkipNum;
  Ed.Gutter.Parts[2].Visible := Prefs.ChangeIndicator;
  // Selection
  if Prefs.DblSelLine then
    Ed.Options := Ed.Options + [eoDoubleClickSelectsLine]
  else
    Ed.Options := Ed.Options - [eoDoubleClickSelectsLine];
  if Prefs.BlockOverwrite then
    Ed.Options2 := Ed.Options2 + [eoOverwriteBlock]
  else
    Ed.Options2 := Ed.Options2 - [eoOverwriteBlock];
  if Prefs.PersistentBlock then
    Ed.Options2 := Ed.Options2 + [eoPersistentBlock]
  else
    Ed.Options2 := Ed.Options2 - [eoPersistentBlock];
  // colors
  Ed.Color := Prefs.EdBgColor;
  Ed.Font.Color := Prefs.EdTextColor;
  Ed.BracketMatchColor.Background := Prefs.BracketColor;
  //
  EdFrame.SynCppSyn1.LoadFromFile(CPrefsName);
  EdFrame.SynPasSyn1.LoadFromFile(PasPrefsName);
  EdFrame.SynHTMLSyn1.LoadFromFile(HTMLPrefsName);
  // Keybindings
  for i := 0 to Ed.Keystrokes.Count - 1 do
  begin
    try
      ShortCut := Prefs.IniFile.ReadInteger(SECTION_SHORTCUTS,  IntToStr(i) + EditorCommandToCodeString(Ed.Keystrokes.Items[i].Command), Ed.Keystrokes.Items[i].ShortCut);
      if Ed.Keystrokes.Items[i].ShortCut <> ShortCut then
        Ed.Keystrokes.Items[i].ShortCut := ShortCut;
    except

    end;
  end;
end;

function KeyStringToVKCode(const s: string): word;
var
  i: PtrInt;
  Data: Pointer;
begin
  Result:=VK_UNKNOWN;
  if KeyStringIsIrregular(s) then begin
    Result:=word(StrToIntDef(copy(s,7,length(s)-8),VK_UNKNOWN));
    exit;
  end;
  if (s<>'none') and (s<>'') then begin
    if VirtualKeyStrings=nil then begin
      VirtualKeyStrings:=TStringHashList.Create(true);
      for i:=1 to 255 do
        VirtualKeyStrings.Add(KeyAndShiftStateToKeyString(word(i),[]), Pointer(i));
    end;
  end else
    exit;
  Data:=VirtualKeyStrings.Data[s];
  if Data<>nil then
    Result:=word(PtrUInt(Data));
end;

{ TCustomShortCutGrabBox }

procedure TCustomShortCutGrabBox.SetKey(const AValue: Word);
var
  s: String;
  i: LongInt;
begin
  if FKey=AValue then exit;
  FKey:=AValue;
  s:=KeyAndShiftStateToKeyString(FKey,[]);
  i:=KeyComboBox.Items.IndexOf(s);
  if i>=0 then
    KeyComboBox.ItemIndex:=i
  else if KeyStringIsIrregular(s) then begin
    KeyComboBox.Items.Add(s);
    KeyComboBox.ItemIndex:=KeyComboBox.Items.IndexOf(s);
  end else
    KeyComboBox.ItemIndex:=0;
end;

procedure TCustomShortCutGrabBox.OnGrabButtonClick(Sender: TObject);
begin
  FGrabForm:=TForm.Create(Self);
  FGrabForm.BorderStyle:=bsToolWindow;
  FGrabForm.KeyPreview:=true;
  FGrabForm.Position:=poScreenCenter;
  FGrabForm.OnKeyDown:=@OnGrabFormKeyDown;
  FGrabForm.Caption:='Press a key ...';
  with TLabel.Create(Self) do begin
    Caption:='Press a key ...';
    BorderSpacing.Around:=25;
    Parent:=FGrabForm;
  end;
  FGrabForm.Width:=200;
  FGrabForm.Height:=50;
  FGrabForm.AutoSize:=true;
  FGrabForm.ShowModal;
  FreeAndNil(FGrabForm);
end;

procedure TCustomShortCutGrabBox.OnShiftCheckBoxClick(Sender: TObject);
var
  s: TShiftStateEnum;
begin
  for s:=Low(TShiftStateEnum) to High(TShiftStateEnum) do
    if FCheckBoxes[s]=Sender then
      if FCheckBoxes[s].Checked then
        Include(FShiftState,s)
      else
        Exclude(FShiftState,s);
end;

procedure TCustomShortCutGrabBox.OnGrabFormKeyDown(Sender: TObject;
  var AKey: Word; AShift: TShiftState);
begin
  //DebugLn(['TCustomShortCutGrabBox.OnGrabFormKeyDown ',AKey,' ',dbgs(AShift)]);
  if not (AKey in [VK_CONTROL, VK_LCONTROL, VK_RCONTROL,
             VK_SHIFT, VK_LSHIFT, VK_RSHIFT,
             VK_MENU, VK_LMENU, VK_RMENU,
             VK_LWIN, VK_RWIN,
             VK_UNKNOWN, VK_UNDEFINED])
  then begin
    if (AKey=VK_ESCAPE) and (AShift=[]) then begin
      Key:=VK_UNKNOWN;
      ShiftState:=[];
    end else begin
      Key:=AKey;
      ShiftState:=AShift;
    end;
    FGrabForm.ModalResult:=mrOk;
  end;
end;

procedure TCustomShortCutGrabBox.OnKeyComboboxEditingDone(Sender: TObject);
begin
  Key:=KeyStringToVKCode(KeyComboBox.Text);
end;

function TCustomShortCutGrabBox.GetShiftCheckBox(Shift: TShiftStateEnum
  ): TCheckBox;
begin
  Result:=FCheckBoxes[Shift];
end;

procedure TCustomShortCutGrabBox.SetAllowedShifts(const AValue: TShiftState);
begin
  if FAllowedShifts=AValue then exit;
  FAllowedShifts:=AValue;
  ShiftState:=ShiftState*FAllowedShifts;
end;

procedure TCustomShortCutGrabBox.SetShiftButtons(const AValue: TShiftState);
begin
  if FShiftButtons=AValue then exit;
  FShiftButtons:=AValue;
  UpdateShiftButons;
end;

procedure TCustomShortCutGrabBox.SetShiftState(const AValue: TShiftState);
var
  s: TShiftStateEnum;
begin
  if FShiftState=AValue then exit;
  FShiftState:=AValue;
  for s:=low(TShiftStateEnum) to High(TShiftStateEnum) do
    if FCheckBoxes[s]<>nil then
      FCheckBoxes[s].Checked:=s in FShiftState;
end;

procedure TCustomShortCutGrabBox.Loaded;
begin
  inherited Loaded;
  UpdateShiftButons;
end;

procedure TCustomShortCutGrabBox.RealSetText(const Value: TCaption);
begin
  // do not allow to set caption
end;

procedure TCustomShortCutGrabBox.UpdateShiftButons;
var
  s: TShiftStateEnum;
  LastCheckBox: TCheckBox;
  NT, NL: Integer;
begin
  NT := 5;
  NL := 5;
  if [csLoading,csDestroying]*ComponentState<>[] then exit;
  LastCheckBox:=nil;
  DisableAlign;
  try
    for s:=low(TShiftStateEnum) to High(TShiftStateEnum) do begin
      if s in FShiftButtons then begin
        if FCheckBoxes[s]=nil then begin
          FCheckBoxes[s]:=TCheckBox.Create(Self);
          with FCheckBoxes[s] do begin
            Name:='CheckBox'+ShiftToStr(s);
            Caption:=ShiftToStr(s);
            AutoSize:=true;
            Checked:=s in FShiftState;
            Top := NT;
            Left := NL;
            NL := NL + 75;
            {if LastCheckBox<>nil then
              AnchorToNeighbour(akLeft,6,LastCheckBox)
            else
              AnchorParallel(akLeft,0,Self);
            AnchorParallel(akTop,0,Self);
            AnchorParallel(akBottom,0,Self);}
            Parent:=Self;
            OnClick:=@OnShiftCheckBoxClick;
          end;
        end;
        LastCheckBox:=FCheckBoxes[s];
      end else begin
        FreeAndNil(FCheckBoxes[s]);
      end;
    end;
    if LastCheckBox<>nil then
      FKeyComboBox.AnchorToNeighbour(akLeft,6,LastCheckBox)
    else
      FKeyComboBox.AnchorParallel(akLeft,0,Self);
  finally
    EnableAlign;
  end;
end;

procedure TCustomShortCutGrabBox.Notification(AComponent: TComponent;
  Operation: TOperation);
var
  s: TShiftStateEnum;
begin
  inherited Notification(AComponent, Operation);
  if Operation=opRemove then begin
    if AComponent=FGrabButton then
      FGrabButton:=nil;
    if AComponent=FKeyComboBox then
      FKeyComboBox:=nil;
    if AComponent=FGrabForm then
      FGrabForm:=nil;
    for s:=Low(TShiftStateEnum) to High(TShiftStateEnum) do
      if FCheckBoxes[s]=AComponent then begin
        FCheckBoxes[s]:=nil;
        Exclude(FShiftButtons,s);
      end;
  end;
end;

function TCustomShortCutGrabBox.ShiftToStr(s: TShiftStateEnum): string;
begin
  case s of
  ssShift: Result:='Shift';
  ssAlt: Result:='Alt';
  ssCtrl: Result:='Ctrl';
  ssMeta: Result:='Meta';
  ssSuper: Result:='Super';
  ssHyper: {$IFDEF Darwin}
           Result:='Cmd';
           {$ELSE}
           Result:='Hyper';
           {$ENDIF}
  ssAltGr: Result:='AltGr';
  ssCaps: Result:='Caps';
  ssNum: Result:='Numlock';
  ssScroll: Result:='Scroll';
  else Result:='Modifier'+IntToStr(ord(s));
  end;
end;

constructor TCustomShortCutGrabBox.Create(TheOwner: TComponent);
var
  i: Integer;
  s: String;
  r: Integer;
begin
  inherited Create(TheOwner);

  r := Width;
  FAllowedShifts:=[ssShift, ssAlt, ssCtrl,
    ssMeta, ssSuper, ssHyper, ssAltGr,
    ssCaps, ssNum, ssScroll];

  FGrabButton:=TButton.Create(Self);
  with FGrabButton do begin
    Name:='GrabButton';
    Caption:='Grab Key';
    Align := alRight;
    AutoSize:=true;
    Parent:=Self;
    OnClick:=@OnGrabButtonClick;
  end;

  FKeyComboBox:=TComboBox.Create(Self);
  with FKeyComboBox do begin
    Name:='FKeyComboBox';
    AutoSize:=true;
    Items.BeginUpdate;
    for i:=0 to 145 do begin
      s := KeyAndShiftStateToKeyString(i, []);
      if not KeyStringIsIrregular(s) then
        Items.Add(s);
    end;
    Items.EndUpdate;
    OnEditingDone:=@OnKeyComboboxEditingDone;
    Parent:=Self;
    AnchorToNeighbour(akRight,6,FGrabButton);
    Top := 5;
    //AnchorVerticalCenterTo(FGrabButton);
    Constraints.MinWidth:=130;
  end;

  BevelOuter:=bvNone;
  ShiftButtons:=GetDefaultShiftButtons;
  ShiftState:=[];
  Key:=VK_UNKNOWN;
  KeyComboBox.Text:=KeyAndShiftStateToKeyString(Key,[]);
end;

function TCustomShortCutGrabBox.GetDefaultShiftButtons: TShiftState;
begin
  {$IFDEF Darwin}
  Result:=[ssCtrl,ssShift,ssAlt,ssMeta];
  {$ELSE}
  Result:=[ssCtrl,ssShift,ssAlt];
  {$ENDIF}
end;

initialization
  PasPrefsName := ChangeFileExt(Application.ExeName, 'Pas.prefs');
  CPrefsName := ChangeFileExt(Application.ExeName, 'C.prefs');
  HTMLPrefsName := ChangeFileExt(Application.ExeName, 'HTML.prefs');
finalization;
  FreeAndNil(VirtualKeyStrings);
end.
