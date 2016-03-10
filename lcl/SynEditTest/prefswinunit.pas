unit PrefsWinUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, PrefsUnit, ATTabs, types, SynEdit, Syngutterlinenumber,
  SynEditHighlighter, SynHighlighterPas, SynHighlighterCpp, SynEditTypes,
  FrameUnit, lclProc, lcltype, stringhashlist, ValEdit, SynEditkeycmds,
  SynHighlighterHTML, Grids, menus, EditBtn, Spin, Contnrs, SyntaxManagement;

const
  FILEPATTERN = '{$f}';
  FILEwPathPATTERN = '{$F}';
  FILEwExtPATTERN = '{$e}';
  FILEwExtwPathPATTERN = '{$E}';
  PATHPATTERN = '{$p}';


type
  TUserCommands = TObjectList;

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
    AcceptCom: TButton;
    BrowseComButton: TButton;
    BrowseDirButton: TButton;
    FontButton: TButton;
    CancelComButton: TButton;
    ChooseSaveStart: TCheckBox;
    FontDialog1: TFontDialog;
    Label17: TLabel;
    TextBold: TCheckBox;
    CommandEdit: TEdit;
    DirEdit: TEdit;
    EditButton: TButton;
    ComListPanel: TGroupBox;
    ComPanel: TGroupBox;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    NewCom: TButton;
    OpenDialog1: TOpenDialog;
    ComShortCutPanel: TPanel;
    RemoveCom: TButton;
    ClearButton: TButton;
    CancelButton: TButton;
    ColEdBracket: TColorButton;
    ChooseCaptureMode: TComboBox;
    GroupBox1: TGroupBox;
    ParamHelp: TComboBox;
    ProgLabel: TEdit;
    ParamEdit: TEdit;
    KeyBox1: TPanel;
    Label21: TLabel;
    KeyPage: TTabSheet;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    SpinStack: TSpinEdit;
    TextItalic: TCheckBox;
    TextUnderline: TCheckBox;
    UserComList: TListBox;
    Panel2: TPanel;
    KeyBox: TPanel;
    KeyPAnel: TPanel;
    ChooseStartForget: TRadioButton;
    ChooseWait: TRadioButton;
    ChooseCaptureOut: TRadioButton;
    ProgTab: TTabSheet;
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
    SyntaxItems: TComboBox;
    LangSelection: TComboBox;
    Label10: TLabel;
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
    procedure AcceptComClick(Sender: TObject);
    procedure BrowseComButtonClick(Sender: TObject);
    procedure BrowseDirButtonClick(Sender: TObject);
    procedure CancelComButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure ColEdBgColorChanged(Sender: TObject);
    procedure ColEdBracketClick(Sender: TObject);
    procedure ColEdTextColorChanged(Sender: TObject);
    procedure EditButtonClick(Sender: TObject);
    procedure FontButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure KeyListEditSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure LangSelectionChange(Sender: TObject);
    procedure NewComClick(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure ParamHelpClick(Sender: TObject);
    procedure RemoveComClick(Sender: TObject);
    procedure SynEdit1DblClick(Sender: TObject);
    procedure SyntaxItemsChange(Sender: TObject);
    procedure UserComListDblClick(Sender: TObject);
    procedure UseTextColClick(Sender: TObject);
  private
    Key1Box:TCustomShortCutGrabBox;
    Key2Box:TCustomShortCutGrabBox;
    CurAtt: TSynHighlighterAttributes;
    procedure TabClickEvent(Sender: TObject);
    Function GetAtt: TSynHighlighterAttributes;
    procedure GetAttSetting;
    procedure SetAttSetting;
    procedure EnableComSett(Enable: Boolean);
  public
    CurRow: Integer;
    BlockEvent: Boolean;
    Tabs: TATTabs;
    ComIdx: Integer;
    Highlighters : THighlighterList;
    Procedure PrefsToEditor(EdFrame: TEditorFrame);
  end;

var
  PrefsWin: TPrefsWin;
  VirtualKeyStrings: TStringHashList = nil;
  CmdName: array[0..1000] of string;
  ShortCutList: array of record
    Command: TSynEditorCommand;
    CommandName: string;
    ShortCut: TShortCut;
  end;
  UserCommands: TUserCommands;

implementation

uses
  MainUnit, SynFacilHighlighter;


{$R *.lfm}

function MyShortCutToText(ShortCut: TShortCut): string;
begin
  Result := ShortCutToText(ShortCut);
  {$ifdef HASAMIGA}
  Result := StringReplace(Result, 'Meta', 'Amiga', [rfReplaceAll]);
  {$endif}
end;

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
  HighlighterItem : THighlighterListItem;
  SyntaxIndex : Integer;
  s : String;
begin
  // SynEdit Highlighters
  Highlighters := THighlighterList.Create;
  // LangSelection combobox (based on Highlighters)
  LangSelection.Items.BeginUpdate;
  LangSelection.Clear;
  for i := 0 to Pred(Highlighters.Count) do
  begin
    HighlighterItem := Highlighters.Items[i];
    If Assigned(HighlighterItem) then
    begin
      SyntaxIndex := HighlighterItem.SyntaxIndex;
      s := SyntaxManager.Elements[SyntaxIndex].MenuName;
      langselection.Items.Add(s);
    end;
  end;
  LangSelection.Items.EndUpdate;
  // required for windows to make first item appear activated ?
  LangSelection.ItemIndex := 0;
  //
  CurRow := -1;
  Key1Box:=TCustomShortCutGrabBox.Create(Self);
  with Key1Box do begin
    Name:='Key1Box';
    Caption := 'Select short cut';
    Align:=alClient;
    AutoSize:=true;
    BorderSpacing.Around:=6;
    Parent:=KeyPanel;
  end;
  //
  Key2Box:=TCustomShortCutGrabBox.Create(Self);
  with Key2Box do begin
    Name:='Key2Box';
    //Caption := 'Select short cut';
    Align:=alClient;
    AutoSize:=true;
    BorderSpacing.Around:=0;
    Parent:=ComShortCutPanel;
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

procedure TPrefsWin.FormDestroy(Sender: TObject);
begin
  Highlighters.Free;
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

procedure TPrefsWin.EditButtonClick(Sender: TObject);
begin
  UserComListDblClick(Sender);
end;

procedure TPrefsWin.FontButtonClick(Sender: TObject);
begin
  FontDialog1.Font := SynEdit1.Font;
  if FontDialog1.Execute then
  begin
    SynEdit1.Font := FontDialog1.Font;
    FontButton.Caption := FontDialog1.Font.Name + '/' + IntToStr(FontDialog1.Font.Size);
  end;
end;

procedure TPrefsWin.FormShow(Sender: TObject);
var
  i: Integer;
  cmd: String;
  j: Integer;
  UCom: TUserCommand;
  SyntaxIndex: Integer;
  s  : String;
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
  SynEdit1.Font.Name := Prefs.FontName;
  SynEdit1.Font.Size := Prefs.FontSize;
  FontButton.Caption := SynEdit1.Font.Name + '/' + IntToStr(SynEdit1.Font.Size);
  // Highlighter
  // Retrieves prefs filename for every highlighter and Load Syntax Attributes
  for i := 0 To Pred(Highlighters.Count) do
  begin
    SyntaxIndex := Highlighters.Items[i].SyntaxIndex;
    s := SyntaxManager.Elements[SyntaxIndex].PrefsName;
    LoadSyntaxAttributesFromFile(Highlighters.Items[i].HighLighter, s);
  end;
  LangSelectionChange(nil);
  // ShortCuts
  KeyListEdit.Visible:= False;
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
    KeyListEdit.Values[IntToStr(i + 1) + '. ' + ShortCutList[i].CommandName] := MyShortCutToText(ShortCutList[i].ShortCut);
    //KeyListEdit.InsertRow(IntToStr(i) + '. ' + ShortCutList[i].CommandName, ShortCutToText(ShortCutList[i].ShortCut), True);
  end;
  KeyListEdit.TitleCaptions.Strings[0] := 'Function';
  KeyListEdit.TitleCaptions.Strings[1] := 'ShortCut';
  KeyListEdit.EndUpdate;
  KeyListEdit.Visible:= True;
  // user commands
  UserCommands.Clear;
  UserComList.Clear;
  i := 0;
  while True do
  begin
    UCom := TUserCommand.Create;
    Prefs.GetUserCom(i, UCom);
    if UCom.ComLabel = '' then
    begin
      UCom.Free;
      Break;
    end;
    UserCommands.Add(UCom);
    UserComList.AddItem(UCom.ComLabel, UCom);
    Inc(i);
  end;
  EnableComSett(False);
end;

procedure TPrefsWin.KeyListEditSelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
var
  Key: Word;
  Shift: TShiftState;
begin
  if (aRow > 0) and (aRow <= High(ShortCutList) + 1) then
  begin
    KeyBox.Caption := 'Define ShortCut for ' + ShortCutList[ARow - 1].CommandName;
    Key1Box.Visible := True;
    ShortCutToKey(ShortCutList[ARow - 1].ShortCut, Key, Shift);
    Key1Box.Key := Key;
    Key1Box.ShiftState := Shift;
    AcceptButton.Visible := True;
    ClearButton.Visible := True;
    CurRow := ARow - 1;
  end
  else
  begin
    CurRow := -1;
    Key1Box.Visible := False;
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
    ShortCut := KeyToShortCut(Key1Box.Key, Key1Box.ShiftState);
    for i := 0 to High(ShortCutList) do
    begin
      if (ShortCutList[i].ShortCut = ShortCut) and (i <> CurRow) then
      begin
        ShowMessage('This Shortcut is already assigned to ' + ShortCutList[i].CommandName);
        Exit;
      end;
    end;
    ShortCutList[CurRow].ShortCut := ShortCut;
    KeyListEdit.Values[IntToStr(CurRow + 1) + '. ' + ShortCutList[CurRow].CommandName] := MyShortCutToText(ShortCutList[CurRow].ShortCut);
  end;
end;

procedure TPrefsWin.ClearButtonClick(Sender: TObject);
begin
  if (CurRow >= 0) and (CurRow <= High(ShortCutList)) then
  begin
    ShortCutList[CurRow].ShortCut := 0;
    KeyListEdit.Values[ShortCutList[CurRow].CommandName] := MyShortCutToText(ShortCutList[CurRow].ShortCut);
  end;
end;

procedure TPrefsWin.LangSelectionChange(Sender: TObject);
var
  i : Integer;
  SyntaxIndex : Integer;
  SyntaxElem  : TSyntaxElement;
  HighlighterItem: THighlighterListItem;
  Highlighter: TSynCustomHighlighter;
  s : String;
begin
  SyntaxItems.Items.BeginUpdate;
  SyntaxItems.Clear;

  // LangSelection item indices are synced with Highlighters item indices
  i := LangSelection.ItemIndex;

  // Retrieve Details from current (selected) highlighter and make them active
  If InRange(i, 0, Pred(Highlighters.Count)) then
  begin
    HighlighterItem := Highlighters.Items[i];
    If assigned(HighlighterItem) then
    begin
      Highlighter := HighlighterItem.HighLighter;
      SyntaxIndex := Highlighters.Items[i].SyntaxIndex;
      SyntaxElem  := SyntaxManager.Elements[SyntaxIndex];

      SynEdit1.Highlighter := Highlighter;
      SynEdit1.Lines.Text  := SyntaxElem.SamplePrefs;

      for i := 0 to Pred(Highlighter.AttrCount)
        do SyntaxItems.Items.Add(Highlighter.Attribute[i].Name);
    end
    else Writeln('MISSION IMPOSSIBLE: Corresponding Highlighter Item was not assigned');
  end
  else Writeln('MISSION IMPOSSIBLE: langselection.itemindex out of range: ', i);

  SyntaxItems.Items.EndUpdate;
end;

procedure TPrefsWin.OkButtonClick(Sender: TObject);
var
  i: Integer;
  SyntaxIndex: Integer;
  s : String;
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
  Prefs.FontName := SynEdit1.Font.Name;
  Prefs.FontSize := SynEdit1.Font.Size;
  // Save Syntax Attributes for all highlighters
  for i := 0 To Pred(Highlighters.Count) do
  begin
    SyntaxIndex := Highlighters.Items[i].SyntaxIndex;
    s := SyntaxManager.Elements[SyntaxIndex].PrefsName;
    SaveSyntaxAttributesToFile(Highlighters.Items[i].HighLighter, s);
  end;
  // Keys
  for i := 0 to High(ShortCutList) do
  begin
    Prefs.IniFile.WriteInteger(SECTION_SHORTCUTS,  IntToStr(i) + EditorCommandToCodeString(ShortCutList[i].Command), ShortCutList[i].ShortCut);
  end;
  //
  for i := 0 to UserCommands.Count - 1 do
  begin
    Prefs.SetUserCom(i, TUserCommand(UserCommands.Items[i]));
  end;
  MainWindow.UpdateUserMenu;
  //
  ModalResult := mrYes;
end;

procedure TPrefsWin.ParamHelpClick(Sender: TObject);
begin
  case ParamHelp.ItemIndex of
    0: ParamEdit.Text := ParamEdit.Text + FILEPATTERN;
    1: ParamEdit.Text := ParamEdit.Text + FILEwPathPATTERN;
    2: ParamEdit.Text := ParamEdit.Text + FILEwExtPATTERN;
    3: ParamEdit.Text := ParamEdit.Text + FILEwExtwPathPATTERN;
    4: ParamEdit.Text := ParamEdit.Text + PATHPATTERN;
  end;
end;

procedure TPrefsWin.RemoveComClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := UserComList.ItemIndex;
  if (Idx >= 0) and (Idx < UserComList.Items.Count) then
  begin
    UserComList.Items.Delete(Idx);
    UserCommands.Delete(Idx);
    UserComListDblClick(nil);
  end;
end;

procedure TPrefsWin.SynEdit1DblClick(Sender: TObject);
var
  Att: TSynHighlighterAttributes;
  token: string;
  i, j: Integer;
  Highlighter : TSynCustomHighlighter;
  HlItemIndex : LongInt;
  AttrIndex   : LongInt;
begin
  // Find and activate double-clicked attribute
  if SynEdit1.GetHighlighterAttriAtRowCol(SynEdit1.CaretXY, token, Att) then
  begin
    // LangSelection item indices are synced with Highlighters item indices
    HLItemIndex := LangSelection.ItemIndex;
    Highlighter := Highlighters.Items[HLItemIndex].HighLighter;

    for AttrIndex := 0 to Pred(Highlighter.AttrCount) do
    begin
      if Att = Highlighter.Attribute[AttrIndex] then
      begin
        SyntaxItems.ItemIndex := AttrIndex;
        SyntaxItemsChange(SyntaxItems);
        Break;
      end;
    end;
  end;
end;

procedure TPrefsWin.SyntaxItemsChange(Sender: TObject);
begin
  if BlockEvent then
    Exit;
  BlockEvent := True;
  GetAttSetting;
  BlockEvent := False;
end;

procedure TPrefsWin.EnableComSett(Enable: Boolean);
begin
  ProgLabel.Enabled := Enable;
  CommandEdit.Enabled := Enable;
  BrowseComButton.Enabled := Enable;
  ParamEdit.Enabled := Enable;
  ParamHelp.Enabled := Enable;
  DirEdit.Enabled := Enable;
  BrowseDirButton.Enabled := Enable;
  ChooseStartForget.Enabled := Enable;
  ChooseWait.Enabled := Enable;
  ChooseCaptureOut.Enabled := Enable;
  SpinStack.Enabled := Enable;
  ChooseCaptureMode.Enabled := Enable;
  ComShortCutPanel.Enabled := Enable;
  AcceptCom.Enabled := Enable;
  CancelComButton.Enabled := Enable;
  ComShortCutPanel.Enabled:=Enable;
  ComPanel.Enabled := Enable;
end;

procedure TPrefsWin.UserComListDblClick(Sender: TObject);
var
  Idx: Integer;
  UCom: TUserCommand;
  kKey: Word;
  kShift: TShiftState;
begin
  Idx := UserComList.ItemIndex;
  ComIdx := Idx;
  if (Idx >= 0) and (Idx < UserComList.Items.Count) then
  begin
    UCom := TUserCommand(UserCommands.Items[Idx]);
    ProgLabel.Text := UCom.ComLabel;
    CommandEdit.Text := UCom.Command;
    ParamEdit.Text := UCom.Parameter;
    DirEdit.Text := UCom.Path;
    SpinStack.Value := UCom.Stack;
    ChooseSaveStart.Checked := UCom.SaveBeforeStart;
    ShortCutToKey(UCom.ShortCut, kKey, kShift);
    Key2Box.Key := kKey;
    Key2Box.ShiftState := kShift;
    case UCom.StartModus of
      0: ChooseStartForget.Checked := True;
      1: ChooseWait.Checked := True;
      2: ChooseCaptureOut.Checked := True;
    end;
    ChooseCaptureMode.ItemIndex := UCom.CaptureModus;
    EnableComSett(True);
  end else
  begin
    EnableComSett(False);
  end;
end;

procedure TPrefsWin.NewComClick(Sender: TObject);
var
  UCom: TUserCommand;
begin
  UCom := TUserCommand.Create;
  UCom.ComLabel := '<New Command>';
  UCom.Command := '';
  UCom.Parameter := '';
  UCom.StartModus := 0;
  UCom.CaptureModus := 0;
  UserComList.AddItem(UCom.ComLabel, UCom);
  UserCommands.Add(UCom);
  UserComList.ItemIndex := UserComList.Count - 1;
  UserComListDblClick(nil);
end;

procedure TPrefsWin.AcceptComClick(Sender: TObject);
var
  Idx: Integer;
  UCom: TUserCommand;
begin
  Idx := UserComList.ItemIndex;
  if (Idx >= 0) and (Idx < UserComList.Items.Count) then
  begin
    UCom := TUserCommand(UserCommands.Items[Idx]);
    UCom.ComLabel := ProgLabel.Text;
    UCom.Command := CommandEdit.Text;
    UCom.Parameter := ParamEdit.Text;
    UCom.Path := DirEdit.Text;
    UCom.Stack := SpinStack.Value;
    UCom.SaveBeforeStart := ChooseSaveStart.Checked;
    UCom.ShortCut := KeyToShortCut(Key2Box.Key, Key2Box.ShiftState);
    if ChooseStartForget.Checked then
      UCom.StartModus := 0;
    if ChooseWait.Checked then
      UCom.StartModus := 1;
    if ChooseCaptureOut.Checked then
      UCom.StartModus := 2;
    UCom.CaptureModus := ChooseCaptureMode.ItemIndex;
    UserComList.Items.Strings[Idx] := ProgLabel.Text;
  end;
  CancelComButtonClick(Sender);
end;

procedure TPrefsWin.BrowseComButtonClick(Sender: TObject);
begin
  OpenDialog1.InitialDir := ExtractFilePath(CommandEdit.Text);
  OpenDialog1.FileName := ExtractFileName(CommandEdit.Text);;
  if OpenDialog1.Execute then
  begin
    CommandEdit.Text := OpenDialog1.FileName;
  end;
end;

procedure TPrefsWin.BrowseDirButtonClick(Sender: TObject);
begin
  SelectDirectoryDialog1.InitialDir := DirEdit.Text;
  If SelectDirectoryDialog1.Execute then
    DirEdit.Text := SelectDirectoryDialog1.FileName;
end;

procedure TPrefsWin.CancelComButtonClick(Sender: TObject);
begin
  EnableComSett(False);
end;

procedure TPrefsWin.UseTextColClick(Sender: TObject);
begin
  if BlockEvent then
    Exit;
  BlockEvent := True;
  ColHBack.Visible := UseBgCol.Checked;
  ColHText.Visible := UseTextCol.Checked;
  ColHFrame.Visible := UseFrameCol.Checked;
  SetAttSetting;

  // SynFacil manual talks of SynEdit.Invalidate in order to properly update
  // contents (Seems to help).
  If (SynEdit1.Highlighter is TSynFacilSyn) then SynEdit1.Invalidate;

  BlockEvent := False;
end;

procedure TPrefsWin.TabClickEvent(Sender: TObject);
begin
  PrefsWin.BeginFormUpdate;
  Pages.Visible:=False;
  Pages.PageIndex := Tabs.TabIndex;
  Pages.Visible:=True;
  PrefsWin.EndFormUpdate;
end;

function TPrefsWin.GetAtt: TSynHighlighterAttributes;
var
  AttrIndex   : LongInt;
  HLItemIndex : LongInt;
  Highlighter : TSynCustomHighlighter;
begin
  // LangSelection item indices are synced with Highlighters item indices
  CurAtt := nil;

  // get current/active/selected highlighter
  HLItemIndex := LangSelection.ItemIndex;
  Highlighter := Highlighters.Items[HLItemIndex].HighLighter;

  // get current/active/selected attribute
  AttrIndex := SyntaxItems.ItemIndex;
  CurAtt    := Highlighter.Attribute[AttrIndex];

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
    ColHText.Visible := Att.Foreground <> clNone;
    TextBold.Checked := fsBold in Att.Style;
    TextItalic.Checked := fsItalic in Att.Style;
    TextUnderline.Checked := fsUnderline in Att.Style;
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
    if TextBold.Checked then
      CurAtt.Style:= CurAtt.Style + [fsBold]
    else
      CurAtt.Style:= CurAtt.Style - [fsBold];
    //
    if TextItalic.Checked then
      CurAtt.Style:= CurAtt.Style + [fsItalic]
    else
      CurAtt.Style:= CurAtt.Style - [fsItalic];
    //
    if TextUnderline.Checked then
      CurAtt.Style:= CurAtt.Style + [fsUnderline]
    else
      CurAtt.Style:= CurAtt.Style - [fsUnderline];
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
  i : Integer;
  ShortCut: TShortCut;
  SyntaxIndex: Integer;
  s : String;
begin
  Ed := EdFrame.Editor;
  // Tabs/Indent Handling
  Ed.BlockIndent := Prefs.IndentWidth;
  Ed.BlockTabIndent := 0;
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
  // SideBar
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
  Ed.Font.Name := Prefs.FontName;
  Ed.Font.Size := Prefs.FontSize;
  // Load Syntax attributes for every highlighter in current editor frame.
  for i := 0 To Pred(EdFrame.Highlighters.Count) do
  begin
    SyntaxIndex := EdFrame.Highlighters.Items[i].SyntaxIndex;
    s := SyntaxManager.Elements[SyntaxIndex].PrefsName;
    LoadSyntaxAttributesFromFile(EdFrame.Highlighters.Items[i].HighLighter, s);
  end;
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
            NL := NL + 55;
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
  ssMeta:
    {$ifdef HASAMIGA}
    Result:='Amiga';
    {$else}
    Result:='Meta';
    {$endif}
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
begin
  inherited Create(TheOwner);

  FAllowedShifts:=[ssShift, ssAlt, ssCtrl,
    ssMeta, ssSuper, ssHyper, ssAltGr,
    ssCaps, ssNum, ssScroll];

  FGrabButton:=TButton.Create(Self);
  with FGrabButton do begin
    Name:='GrabButton';
    Caption:='Grab Key';
    Align := alRight;
    AutoSize:=False;
    Width := 100;
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
    Width := 100;
    //AnchorVerticalCenterTo(FGrabButton);
    //Constraints.MinWidth:=130;
  end;

  BevelOuter:=bvNone;
  ShiftButtons:=GetDefaultShiftButtons;
  ShiftState:=[];
  Key:=VK_UNKNOWN;
  KeyComboBox.Text:=KeyAndShiftStateToKeyString(Key,[]);
end;

function TCustomShortCutGrabBox.GetDefaultShiftButtons: TShiftState;
begin
  {$IFDEF HASAMIGA}
  Result:=[ssCtrl,ssShift,ssAlt,ssMeta];
  {$ELSE}
  Result:=[ssCtrl,ssShift,ssAlt];
  {$ENDIF}
end;

initialization
  UserCommands := TUserCommands.Create(True);
finalization
  UserCommands.Free;
  FreeAndNil(VirtualKeyStrings);
end.
