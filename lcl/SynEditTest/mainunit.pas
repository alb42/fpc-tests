unit MainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterPas, Forms, Controls,
  Graphics, Dialogs, Menus, ExtCtrls, SynHighlighterCpp, FrameUnit, LCLIntf,
  {$ifdef HASAMIGA}
  Workbench, muiformsunit, amigaDos, StartProgUnit,
  {$endif}
  {$ifdef Unix}
  Unix,
  {$endif}
  synexporthtml, SynEditTypes, SynEditKeyCmds, LCLType, StdCtrls, Math, ATTabs,
  MikroStatUnit, SynHighlighterhtml, synEditTextbuffer, Process;

const
  VERSION = '$VER: EdiSyn 0.54 (' +{$I %DATE%} +')';


type
  { TMainWindow }

  TMainWindow = class(TForm)
    EditMenu: TMenuItem;
    CopyMenu: TMenuItem;
    CutMenu: TMenuItem;
    BookmarkImages: TImageList;
    ComOutputMenu: TMenuItem;
    MenuPrint: TMenuItem;
    UserMenu: TMenuItem;
    StatLabel: TLabel;
    MenuItem1: TMenuItem;
    GoToLineMenu: TMenuItem;
    AutoMenu: TMenuItem;
    EditorPanel: TPanel;
    CloseTabMenu: TMenuItem;
    CloseAllMenu: TMenuItem;
    AboutMainMenu: TMenuItem;
    AboutMenu: TMenuItem;
    PrefsMenu: TMenuItem;
    SearchAllWindowMenu: TMenuItem;
    WindowMenu: TMenuItem;
    SearchAllMenu: TMenuItem;
    SepMenu4: TMenuItem;
    NewTabMenu: TMenuItem;
    MikroStat: TMikroStatus;
    SetDefHighMenu: TMenuItem;
    DestroyTabTimer: TTimer;
    ViewMenu: TMenuItem;
    RecMenu5: TMenuItem;
    RecMenu6: TMenuItem;
    RecMenu7: TMenuItem;
    RecMenu8: TMenuItem;
    RecMenu9: TMenuItem;
    RecMenu10: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem4: TMenuItem;
    LowerPanel: TPanel;
    CoordPanel: TPanel;
    MenuItem5: TMenuItem;
    RecMenu1: TMenuItem;
    RecMenu2: TMenuItem;
    RecMenu3: TMenuItem;
    RecMenu4: TMenuItem;
    NaviMenu: TMenuItem;
    SearchMenu: TMenuItem;
    ReplaceMenu: TMenuItem;
    SearchAgainMenu: TMenuItem;
    SepMenu3: TMenuItem;
    SepMenu2: TMenuItem;
    UndoMenu: TMenuItem;
    RedoMenu: TMenuItem;
    SepMenu1: TMenuItem;
    PasteMenu: TMenuItem;
    SelAllMenu: TMenuItem;
    SaveAsMenu: TMenuItem;
    MainMenu: TMainMenu;
    FileMenu: TMenuItem;
    NewMenu: TMenuItem;
    OpenMenu: TMenuItem;
    SaveMenu: TMenuItem;
    ExportMenu: TMenuItem;
    QuitMenu: TMenuItem;
    HighLightMenu: TMenuItem;
    ExampleMenu: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    SynExporterHTML1: TSynExporterHTML;
    procedure AboutMenuClick(Sender: TObject);
    procedure AutoMenuClick(Sender: TObject);
    procedure CloseAllMenuClick(Sender: TObject);
    procedure CloseTabMenuClick(Sender: TObject);
    procedure ComOutputMenuClick(Sender: TObject);
    procedure CopyMenuClick(Sender: TObject);
    procedure CutMenuClick(Sender: TObject);
    procedure ExampleMenuClick(Sender: TObject);
    procedure ExportMenuClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GoToLineMenuClick(Sender: TObject);
    procedure DestroyTabTimerTimer(Sender: TObject);
    procedure MenuPrintClick(Sender: TObject);
    procedure NewTabMenuClick(Sender: TObject);
    procedure PasteMenuClick(Sender: TObject);
    procedure PrefsMenuClick(Sender: TObject);
    procedure RecMenu1Click(Sender: TObject);
    procedure RedoMenuClick(Sender: TObject);
    procedure ReplaceMenuClick(Sender: TObject);
    procedure SearchAgainMenuClick(Sender: TObject);
    procedure SearchAllMenuClick(Sender: TObject);
    procedure SearchAllWindowMenuClick(Sender: TObject);
    procedure SearchMenuClick(Sender: TObject);
    procedure SelAllMenuClick(Sender: TObject);
    procedure NewMenuClick(Sender: TObject);
    procedure OpenMenuClick(Sender: TObject);
    procedure QuitMenuClick(Sender: TObject);
    procedure SaveAsMenuClick(Sender: TObject);
    procedure SaveMenuClick(Sender: TObject);
    procedure SetDefHighMenuClick(Sender: TObject);
    procedure SynEdit1ProcessCommand(Sender: TObject;
      var Command: TSynEditorCommand; var AChar: TUTF8Char; Data: pointer);
    procedure SynEdit1ReplaceText(Sender: TObject; const ASearch, AReplace: string;
      Line, Column: integer; var ReplaceAction: TSynReplaceAction);
    procedure SynEdit1StatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure TabClickEvent(Sender: TObject);
    procedure TabCloseEvent(Sender: TObject; ATabIndex: integer;
      var ACanClose, ACanContinue: boolean);
    procedure TabPlusClickEvent(Sender: TObject);
    procedure UndoMenuClick(Sender: TObject);
  private
    FAbsCount: integer;
    ProgName: string;
    RecFileList: TStringList;
    RecMenuList: array[0..9] of TMenuItem;
    procedure ResetChanged;
    procedure RemakeRecentFiles;
    procedure AddNewRecent(Filename: string);
    procedure AutoHighlighter;
    procedure UpdateStatusBar;
    procedure UpdateTitlebar;
    procedure UpdateOutputEvent(Sender: TObject);
    function ReplaceFilePat(Base: string): string;
  public
    Tabs: TATTabs;
    procedure HighLightMenuItemClick(Sender: TObject);
    procedure LoadFile(AFileName: string);
    function AbsCount: integer;
    function CurEditor: TSynEdit;
    function CurFrame: TEditorFrame;
    procedure HandleExceptions(Sender: TObject; E: Exception);
    procedure UserMenuEvent(Sender: TObject);
    procedure UpdateUserMenu;
    { public declarations }
  end;

var
  MainWindow: TMainWindow;

implementation

uses
  GotLineUnit, SearchReplaceUnit, ReplaceReqUnit, PrefsUnit, AboutUnit,
  SearchAllUnit, SearchAllResultsUnit, PrefsWinUnit, OutputUnit,
  SyntaxManagement;

{$R *.lfm}

{ TMainWindow }

procedure TMainWindow.ExampleMenuClick(Sender: TObject);
var
  SyntaxIndex: Integer;
begin
  // Retrieve example code from SyntaxManager
  for SyntaxIndex := 0 to Pred(SyntaxManager.ElementsCount) do
  begin
    if SyntaxManager.Elements[SyntaxIndex].MenuItem.Checked then
    begin
      CurEditor.Lines.Text := SyntaxManager.Elements[SyntaxIndex].SampleCode;
      break;
    end;
  end;
  ResetChanged;
end;

procedure TMainWindow.ExportMenuClick(Sender: TObject);
begin
  // if Highlighter is not assigned the HTML export will crash!
  if CurEditor.Highlighter = nil then
    Exit;
  if SaveDialog1.Execute then
  begin
    SynExporterHTML1.Highlighter := CurEditor.Highlighter;
    SynExporterHTML1.ExportAll(CurEditor.Lines);
    SynExporterHTML1.SaveToFile(SaveDialog1.FileName);
  end;
end;

procedure TMainWindow.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  Res: integer;
  i: integer;
begin
  CanClose := True;
  // Check if there is a Tab with changed Data
  for i := 0 to Tabs.TabCount - 1 do
  begin
    if TEditorFrame(Tabs.GetTabData(Tabs.TabIndex).TabObject).Editor.Modified then
      CanClose := False;
  end;
  // Some Data Changed -> Ask the user what to do
  if not CanClose then
  begin
    Res := MessageDlg('Unsaved Data',
      'There are unsaved changes.'#13#10'Do you really want to close?',
      mtConfirmation, mbYesNo, 0);
    CanClose := Res = mrYes;
  end;
  {$ifdef AROS}
  // dirty hack to get the window position again ;)
  if HandleAllocated and (TObject(Handle) is TMUIWindow) then
  begin
    Left := TMUIWindow(Handle).Left;
    Top := TMUIWindow(Handle).Top;
  end;
  {$endif}
end;


{$ifdef AROS}
function GetWBArg(Idx: integer): string;
var
  startup: PWBStartup;
  wbarg: PWBArgList;
  Path: array[0..254] of char;
  strPath: string;
  Len: integer;
begin
  GetWBArg := '';
  strPath := '';
  FillChar(Path[0], 255, #0);
  Startup := PWBStartup(AOS_wbMsg);
  if Startup <> nil then
  begin
    //if (Idx >= 0) and (Idx < Startup^.sm_NumArgs) then
    begin
      wbarg := Startup^.sm_ArgList;
      if NameFromLock(wbarg^[Idx + 1].wa_Lock, @Path[0], 255) then
      begin
        Len := 0;
        while (Path[Len] <> #0) and (Len < 254) do
          Inc(Len);
        if Len > 0 then
          if (Path[Len - 1] <> ':') and (Path[Len - 1] <> '/') then
            Path[Len] := '/';
        strPath := Path;
      end;
      Result := strPath + wbarg^[Idx + 1].wa_Name;
    end;
  end;
end;

{$endif}

procedure TMainWindow.FormCreate(Sender: TObject);
var
  i: integer;
  NFile: string;
  NewFrame: TEditorFrame;
  SyntaxIndex : Integer;
  MenuItem : TMenuItem;
begin
  application.OnException := @HandleExceptions;
  // Create dynamic MenuItems for Highlighter Menu
  For SyntaxIndex := 0 to Pred(SyntaxManager.ElementsCount) do
  begin
    MenuItem := TMenuItem.Create(HighLightMenu);
    MenuItem.Caption    := SyntaxManager.Elements[SyntaxIndex].MenuName;
    MenuItem.Tag        := SyntaxIndex;
    MenuItem.GroupIndex := 1;
    MenuItem.RadioItem  := true;
    MenuItem.Checked    := false;
    MenuItem.AutoCheck  := true;
    MenuItem.OnClick    := @HighlightMenuItemClick;
    HighLightMenu.Insert(SyntaxIndex, MenuItem);
    // Because of the autocheck we need to keep track of its status. Use the
    // individual dynamic created menuitems stored in SyntaxManager for that.
    // The MenuItem's tag can be used to sync with Syntaxmanager.
    SyntaxManager.Elements[SyntaxIndex].MenuItem := MenuItem;
  end;
  // Counter for Editornames ;)
  FAbsCount := 0;
  // Tab control initial Values
  Tabs := TATTabs.Create(Self);
  Tabs.Align := alTop;
  Tabs.Height := 42;
  Tabs.TabAngle := 0;
  Tabs.TabIndentInter := 2;
  Tabs.TabIndentInit := 2;
  Tabs.TabIndentTop := 4;
  Tabs.TabIndentXSize := 13;
  Tabs.TabWidthMin := 18;
  Tabs.TabDragEnabled := True;
  // Tab control Colors
  Tabs.Font.Color := clBlack;
  Tabs.ColorBg := $F9EADB;
  Tabs.ColorBorderActive := $ACA196;
  Tabs.ColorBorderPassive := $ACA196;
  Tabs.ColorTabActive := $FCF5ED;
  Tabs.ColorTabPassive := $E0D3C7;
  Tabs.ColorTabOver := $F2E4D7;
  Tabs.ColorCloseBg := clNone;
  Tabs.ColorCloseBgOver := $D5C9BD;
  Tabs.ColorCloseBorderOver := $B0B0B0;
  Tabs.ColorCloseX := $7B6E60;
  Tabs.ColorArrow := $5C5751;
  Tabs.ColorArrowOver := Tabs.ColorArrow;
  Tabs.Parent := Self;
  // Tab Control Events
  Tabs.OnTabPlusClick := @TabPlusClickEvent;
  Tabs.OnTabClose := @TabCloseEvent;
  Tabs.OnTabClick := @TabClickEvent;
  // we create the first Tab (there should never be an empty Tab control)
  NewFrame := TEditorFrame.Create(Self);
  NewFrame.TabLink := Tabs;
  NewFrame.Name := 'NewFrame' + IntToStr(AbsCount);
  NewFrame.Align := alClient;
  NewFrame.Editor.Parent := EditorPanel;
  Tabs.AddTab(-1, 'New Tab', NewFrame, False, clNone);
  // Auto Highlighter preferences
  AutoMenu.Checked := Prefs.AutoHighlighter;
  // which highlighter is default
  SyntaxIndex := Prefs.DefHighlighter;
  // Fallback to Highlighter None in case of an error. harcoded zero value though.
  If not InRange(SyntaxIndex, 0, Pred(SyntaxManager.ElementsCount)) then SyntaxIndex := 0;
  SyntaxManager.Elements[SyntaxIndex].MenuItem.Checked := True;
  HighlightMenuItemClick(SyntaxManager.Elements[SyntaxIndex].MenuItem);
  // Recent Files up to 10
  RecFileList := TStringList.Create;
  RecMenuList[0] := RecMenu1;
  RecMenuList[1] := RecMenu2;
  RecMenuList[2] := RecMenu3;
  RecMenuList[3] := RecMenu4;
  RecMenuList[4] := RecMenu5;
  RecMenuList[5] := RecMenu6;
  RecMenuList[6] := RecMenu7;
  RecMenuList[7] := RecMenu8;
  RecMenuList[8] := RecMenu9;
  RecMenuList[9] := RecMenu10;
  for i := Low(RecMenuList) to High(RecMenuList) do
  begin
    NFile := Prefs.RecentFiles[i];
    if NFile <> '' then
      RecFileList.Add(NFile);
    RecMenuList[i].Caption := NFile;
    RecMenuList[i].Visible := NFile <> ''; // only show if there is something in
    RecMenuList[i].Tag := i;
  end;
  // Load file if there is a parameter list
  NewFrame.Filename := '';
  if Paramcount > 0 then
  begin
    try
      LoadFile(ParamStr(1)); // Try to load the file will set CurFrame.Filename
    except
      NewFrame.Filename := '';
    end;
  end;
  // set Programname for the Caption
  ProgName := VERSION;
  Delete(Progname, 1, 6);  // Cut Version
  Delete(Progname, Pos('(', Progname), Length(Progname)); // Cut Date
  AboutUnit.PrgVersion := Trim(Copy(Progname, Pos(' ', Progname), Length(Progname)));
  // Init Mikrostats set everything twice, to init (because it compares for equal values)
  MikroStat.Highlighter := '';
  MikroStat.Changed := True;
  MikroStat.Changed := False;
  MikroStat.InsMode := False;
  MikroStat.InsMode := True;
  // make usermenu things
  UpdateUserMenu;
  // Update Titlebar, status bar
  UpdateTitlebar;
  ResetChanged;
  UpdateStatusBar;
end;

procedure TMainWindow.FormDestroy(Sender: TObject);
begin
  // save The current position for next run
  Prefs.XPos := Left;
  Prefs.YPos := Top;
  Prefs.Width := Width;
  Prefs.Height := Height;
  // Recent File list
  RecFileList.Free;
end;

procedure TMainWindow.FormShow(Sender: TObject);
begin
  // Move/Size the window to the previous saved parameters
  SetBounds(Prefs.XPos, Prefs.YPos, Prefs.Width, Prefs.Height);
end;

procedure TMainWindow.GoToLineMenuClick(Sender: TObject);
begin
  // Open jump to Line window, (Next to the upper Right side of mainwindow)
  GotoLineWin.Visible := False;
  GoToLineWin.SetBounds(Max(5, Left + Width - GotoLineWin.Width),
    Max(5, Top - GoToLineWin.Height div 2), GoToLineWin.Width, GoToLineWin.Height);
  GoToLineWin.Show;
end;

procedure TMainWindow.DestroyTabTimerTimer(Sender: TObject);
begin
  // Destroy a Tab, via Timer, because we are not allowed to destroy the
  // SynEdit Editor inside one of its Events -> Key press -> Close Tab
  DestroyTabTimer.Enabled := False;
  CloseTabMenuClick(Sender);
end;

procedure TMainWindow.MenuPrintClick(Sender: TObject);
var
  F: File;
  i, num: Integer;
  str: string;
begin
  {$I-}
  AssignFile(F, 'PRT:');
  Rewrite(F,1);
  {$I+}
  if IOResult = 0 then
  begin
    str := #27'[4w' + CurEditor.Lines.Text + #0;
    Blockwrite(F, str[1], Length(str), i);
    CloseFile(F);
  end;
end;

procedure TMainWindow.HighLightMenuItemClick(Sender: TObject);
var
  SyntaxIndex : LongInt;
  HighlighterItem : THighlighterListItem;
begin
  // NOTE: behavioral change, Sender _needs_ to be the MenuItem from which
  // the click was invoked. See also: dynamic menu creation @ FormCreate;
  If (Sender As TMenuItem).Checked then
  begin
    // Sync
    SyntaxIndex := (Sender As TMenuItem).Tag;
    // In case of invalid SyntaxIndex default to harcoded zero value (no highlighter)
    If not InRange(SyntaxIndex, 0, Pred(SyntaxManager.ElementsCount)) then SyntaxIndex := 0;

    // Obtain highlighter listitem
    HighlighterItem := CurFrame.Highlighters.FindItemBySyntaxIndex(SyntaxIndex);

    If Assigned(HighlighterItem)
    then CurEditor.Highlighter := HighlighterItem.HighLighter
    else CurEditor.Highlighter := nil;

    ExportMenu.Enabled    := assigned(CurEditor.Highlighter);
    MikroStat.Highlighter := SyntaxManager.Elements[SyntaxIndex].MikroName;
  end;
end;

procedure TMainWindow.NewTabMenuClick(Sender: TObject);
begin
  // New Tab please.
  TabPlusClickEvent(Tabs);
end;

procedure TMainWindow.PasteMenuClick(Sender: TObject);
begin
  // Paste
  CurEditor.PasteFromClipboard;
end;

procedure TMainWindow.PrefsMenuClick(Sender: TObject);
var
  i: integer;
  EdFrame: TEditorFrame;
begin
  if PrefsWin.ShowModal = mrYes then
  begin
    for i := 0 to Tabs.TabCount - 1 do
    begin
      EdFrame := TEditorFrame(Tabs.GetTabData(i).TabObject);
      PrefsWin.PrefsToEditor(EdFrame);
    end;
  end;
  UpdateStatusBar;
  UpdateTitlebar;
end;

procedure TMainWindow.RecMenu1Click(Sender: TObject);
var
  Num: PtrInt;
begin
  // A recent file was selected
  if Sender is TMenuItem then
  begin
    // Tag represents the Index in the RecFileList
    Num := TMenuItem(Sender).Tag;
    if (Num >= 0) and (Num < RecFileList.Count) then
      LoadFile(RecFileList[Num]);
  end;
end;

procedure TMainWindow.RedoMenuClick(Sender: TObject);
begin
  CurEditor.Redo;
end;

procedure TMainWindow.ReplaceMenuClick(Sender: TObject);
begin
  // Search and replace is one Window with two modes
  SearchReplaceWin.StartReq(True);
end;

procedure TMainWindow.SearchAgainMenuClick(Sender: TObject);
begin
  // Search again F3
  SearchReplaceWin.SearchAgainClick(Sender);
end;

procedure TMainWindow.SearchAllMenuClick(Sender: TObject);
begin
  SearchAllForm.ShowModal;
end;

procedure TMainWindow.SearchAllWindowMenuClick(Sender: TObject);
begin
  SearchAllResultsUnit.SearchResultsWin.Show;
end;

procedure TMainWindow.SearchMenuClick(Sender: TObject);
begin
  if CurEditor.SelAvail then
    SearchReplaceWin.SearchEdit.Text := CurEditor.SelText;
  SearchReplaceWin.StartReq(False);
end;

procedure TMainWindow.SelAllMenuClick(Sender: TObject);
begin
  // give me everything
  CurEditor.SelectAll;
end;

procedure TMainWindow.NewMenuClick(Sender: TObject);
var
  Res: integer;
begin
  if CurEditor.Modified then
  begin
    Res := MessageDlg('Unsaved Data',
      'There are unsaved changes in this Tab.'#13#10'Do you really want to close it?',
      mtConfirmation, mbYesNo, 0);
    if Res <> mrYes then
      Exit;
  end;
  // Delete the contents of the current Tab
  CurFrame.Filename := '';
  CurEditor.Lines.Clear;
  UpdateTitlebar;
  ResetChanged;
end;

procedure TMainWindow.OpenMenuClick(Sender: TObject);
var
  Res: integer;
begin
  if CurEditor.Modified then
  begin
    Res := MessageDlg('Unsaved Data',
      'There are unsaved changes in this Tab.'#13#10'Do you really want to close it?',
      mtConfirmation, mbYesNo, 0);
    if Res <> mrYes then
      Exit;
  end;
  // Open a new File
  {$ifdef HASAMIGA}
  // Quirk for amiga, or the Filter is just invisible -> better set then the
  // can type an own Filter if needed
  OpenDialog1.Filter := '#?';
  {$endif}
  OpenDialog1.InitialDir := Prefs.InitialDir;
  if OpenDialog1.InitialDir = '' then
    OpenDialog1.InitialDir := 'Sys:';
  if OpenDialog1.Execute then
  begin
    LoadFile(OpenDialog1.FileName);
    Prefs.InitialDir := ExtractFilePath(OpenDialog1.FileName);
  end;
end;

procedure TMainWindow.ComOutputMenuClick(Sender: TObject);
begin
  OutWindow.Show;
end;

procedure TMainWindow.AutoMenuClick(Sender: TObject);
begin
  // save Autohighlighter function to preferences
  Prefs.AutoHighlighter := AutoMenu.Checked;
end;

procedure TMainWindow.AboutMenuClick(Sender: TObject);
begin
  AboutForm.Showmodal;
end;

procedure TMainWindow.CloseAllMenuClick(Sender: TObject);
var
  i: integer;
  Modified: boolean;
  CanClose: boolean;
  CanCont: boolean;
  Res: integer;
begin
  // Close everything, first check if at least one is modified
  Modified := False;
  for i := 0 to Tabs.TabCount - 1 do
  begin
    Modified := TEditorFrame(Tabs.GetTabData(i).TabObject).Editor.Modified;
    if Modified then
      Break;
  end;
  // ask the user what to do
  if Modified then
  begin
    Res := MessageDlg('Unsaved Data',
      'There are unsaved changes.'#13#10'Do you really want to close all Tabs?',
      mtConfirmation, mbYesNo, 0);
    if Res <> mrYes then
      Exit;
  end;
  // and now... for something completely different... ehm ... I mean trash
  // everything. We delete all except one, which one is not important thats the
  // reason for the -2, thats the Tan we clean then
  for i := 0 to Tabs.TabCount - 2 do
    Tabs.DeleteTab(0, False, False);
  // switch to the last exisiting tab
  Tabs.TabIndex := 0;
  // We call the TabCloseEvent as it would be cleared by the Close icon
  CurEditor.Modified := False;
  CanClose := True;
  CanCont := True;
  TabCloseEvent(Tabs, 0, CanClose, CanCont);
end;

procedure TMainWindow.CloseTabMenuClick(Sender: TObject);
begin
  // Delete Tab, the tab control will call the Event to check if really to Delete
  Tabs.DeleteTab(Tabs.TabIndex, True, True);
end;

procedure TMainWindow.CopyMenuClick(Sender: TObject);
begin
  // Clip
  CurEditor.CopyToClipboard;
end;

procedure TMainWindow.CutMenuClick(Sender: TObject);
begin
  // CutClip
  CurEditor.CutToClipboard;
end;

procedure TMainWindow.QuitMenuClick(Sender: TObject);
begin
  // This quirk is not needed anymore, but also does not harm
  // remove selection -> or crash
  CurEditor.Lines.Clear;
  CurEditor.SelStart := 0;
  CurEditor.SelEnd := 0;
  // bybye
  Close;
end;

procedure TMainWindow.SaveAsMenuClick(Sender: TObject);
begin
  // Save as, use the current File+Path as Start
  SaveDialog1.InitialDir := ExtractFilePath(CurFrame.Filename);
  if SaveDialog1.InitialDir = '' then
    SaveDialog1.InitialDir := Prefs.InitialDir;
  SaveDialog1.FileName := ExtractFileName(CurFrame.Filename);
  // aaaaaand do it
  if SaveDialog1.Execute then
  begin
    CurFrame.Filename := SaveDialog1.FileName;
    CurEditor.Lines.SaveToFile(CurFrame.Filename);
    UpdateTitlebar;
    AddNewRecent(CurFrame.Filename);
    ResetChanged;
  end;
end;

procedure TMainWindow.SaveMenuClick(Sender: TObject);
begin
  // if filename is set use it to save,
  // if not call save as to ask the user
  if CurFrame.Filename <> '' then
  begin
    CurEditor.Lines.SaveToFile(CurFrame.Filename);
    UpdateTitlebar;
    ResetChanged;
    CurEditor.MarkTextAsSaved;
  end
  else
    SaveAsMenuClick(Sender);
end;

procedure TMainWindow.SetDefHighMenuClick(Sender: TObject);
Var
  SyntaxIndex: Integer;
begin
  // HighlighterSetting as Default
  For SyntaxIndex := 0 to Pred(SyntaxManager.ElementsCount) do
  begin
    if SyntaxManager.Elements[SyntaxIndex].MenuItem.Checked then
    begin
      Prefs.DefHighlighter:= SyntaxIndex;
      break;
    end;
  end;
end;

procedure TMainWindow.SynEdit1ProcessCommand(Sender: TObject;
  var Command: TSynEditorCommand; var AChar: TUTF8Char; Data: pointer);
begin
  case Command - ecUserDefinedFirst of
    0: GoToLineMenuClick(Sender); // Ctrl + I   GoToLine
    1: SaveMenuClick(Sender);     // Ctrl + S   Save
    2: OpenMenuClick(Sender);     // Ctrl + O   Open
    3: SaveAsMenuClick(Sender);   // Ctrl + W   Save As
    4: SearchMenuClick(Sender);   // Ctrl + F Search
    5: SearchAgainMenuClick(Sender); // F3 Search
    6: SearchReplaceWin.SearchBackClick(Sender); // Shift + F3 Search backwards
    7: ReplaceMenuClick(Sender);  // Ctrl + R Replace
    8: NewTabMenuClick(Sender);   // Ctrl + B Open New Tab
    9: DestroyTabTimer.Enabled := True; // Ctrl + G Close Tab
    10: Tabs.SwitchTab(False);    // Ctrl + Shift + F1 previous Tab
    11: Tabs.SwitchTab(True);     // Ctrl + Shift + F2 next Tab
    12: SearchAllForm.ShowModal;  // Ctrl + Shift + F Search all
  end;
end;

procedure TMainWindow.SynEdit1ReplaceText(Sender: TObject;
  const ASearch, AReplace: string; Line, Column: integer;
  var ReplaceAction: TSynReplaceAction);
var
  Res: TModalResult;
begin
  Res := ReplaceReqUnit.ReplaceRequest.StartReq('Replace this occurence by "' +
    AReplace + '" ?');
  case Res of
    mrYes: ReplaceAction := raReplace;
    mrYesToAll: ReplaceAction := raReplaceAll;
    mrNo: ReplaceAction := raSkip;
    mrCancel: ReplaceAction := raCancel;
  end;
end;

procedure TMainWindow.SynEdit1StatusChange(Sender: TObject; Changes: TSynStatusChanges);
begin
  if CurEditor = Sender then
  begin
    UpdateStatusBar;
    if Assigned(SearchReplaceWin) then
      if CurEditor.SelText <> SearchReplaceWin.SearchString then
        CurEditor.SetHighlightSearch('', []);
  end;
end;

procedure TMainWindow.TabClickEvent(Sender: TObject);
var
  i: integer;
  Frame: TEditorFrame;
  SyntaxIndex: Integer;
begin
  // writeln('enter - MainUnit.TabClickEvent');

  EditorPanel.BeginUpdateBounds;
  for i := 0 to Tabs.TabCount - 1 do
  begin
    Frame := TEditorFrame(Tabs.GetTabData(i).TabObject);
    if Frame.Editor.Visible <> (i = Tabs.TabIndex) then
      Frame.Editor.Visible := (i = Tabs.TabIndex);
  end;
  // Let correct menuitem be checked based on active Frame/Editor
  if Assigned(CurEditor.Highlighter) then
  begin
    For i := 0 To Pred(CurFrame.Highlighters.Count) do
    begin
      // writeln('MainUnit.TabClickEvent: Highlighter name: ', CurEditor.Highlighter.LanguageName);
      If CurEditor.Highlighter = CurFrame.Highlighters.Items[i].HighLighter then
      begin
        SyntaxIndex := CurFrame.Highlighters.Items[i].SyntaxIndex;
        SyntaxManager.Elements[SyntaxIndex].MenuItem.Checked := true;
        // writeln('MainUnit.TabClickEvent: Matched a highlighter and checked MenuItem');
        break;
      end;
    end;
  end
  // ToDo: remove hardcoded zero index fallback value (highlighter is None)
  else
  begin
    // writeln('MainUnit.TabClickEvent: No valid highlighter, Check None menuitem');
    SyntaxManager.Elements[0].MenuItem.Checked:= true;
  end;

  UpdateStatusBar;
  UpdateTitlebar;
  EditorPanel.EndUpdateBounds;
  Frame := TEditorFrame(Tabs.GetTabData(Tabs.TabIndex).TabObject);
  if EditorPanel.Visible then
    Frame.Editor.SetFocus;
  // writeln('leave - MainUnit.TabClickEvent');
end;

procedure TMainWindow.TabCloseEvent(Sender: TObject; ATabIndex: integer;
  var ACanClose, ACanContinue: boolean);
var
  TabData: TATTabData;
  Res: integer;
begin
  ACanClose := True;
  TabData := Tabs.GetTabData(ATabIndex);
  if TEditorFrame(TabData.TabObject).Editor.Modified then
  begin
    Res := MessageDlg('Unsaved Data',
      'The Text in this Tab is not saved.'#13#10'Do you really want to close it?',
      mtConfirmation, mbYesNo, 0);
    ACanClose := Res = mrYes;
  end;
  if not ACanClose then
    Exit;
  if Tabs.TabCount > 1 then
  begin
    if ACanClose then
      TabData.TabObject.Free;
  end
  else
  begin
    CurEditor.Lines.Clear;
    CurEditor.Modified := False;
    TabData := Tabs.GetTabData(Tabs.TabIndex);
    TabData.TabModified := False;
    TEditorFrame(TabData.TabObject).Filename := '';
    TabData.TabCaption := 'New Tab';
    Tabs.Invalidate;
    ACanClose := False;
  end;
end;

procedure TMainWindow.TabPlusClickEvent(Sender: TObject);
var
  NewFrame: TEditorFrame;
  SyntaxIndex: Integer;
begin
  EditorPanel.Visible := False;
  NewFrame := TEditorFrame.Create(Self);
  NewFrame.Editor.Parent := EditorPanel;
  NewFrame.TabLink := Tabs;
  NewFrame.Name := 'NewFrame' + IntToStr(AbsCount);
  NewFrame.Align := alClient;
  // Preferences
  NewFrame.Editor.Gutter.Parts[0].Visible := Prefs.Bookmarks;
  NewFrame.Editor.Gutter.Parts[1].Visible := Prefs.LineNumbers;
  // Highlighter
  For SyntaxIndex := 0 to Pred(SyntaxManager.ElementsCount) do
  begin
    If SyntaxManager.Elements[SyntaxIndex].MenuItem.Checked then
    begin
      if SyntaxManager.Elements[SyntaxIndex].SyntaxHLType = shtNone
      then NewFrame.Editor.Highlighter := nil
      else NewFrame.Editor.Highlighter := NewFrame.Highlighters.FindItemBySyntaxIndex(SyntaxIndex).HighLighter;
      break;
    end;
  end;

  // Add the Tab
  Tabs.AddTab(-1, 'New Tab', NewFrame, False, clNone);

  NewFrame.Editor.Visible := True;
  Tabs.TabIndex := Tabs.TabCount - 1;

  EditorPanel.Visible := True;

  NewFrame.Editor.SetFocus;

end;

procedure TMainWindow.UndoMenuClick(Sender: TObject);
begin
  CurEditor.Undo;
end;

procedure TMainWindow.ResetChanged;
begin
  CurEditor.Modified := False;
  Tabs.GetTabData(Tabs.TabIndex).TabModified := False;
  Tabs.Invalidate;
  UpdateTitlebar;
end;

procedure TMainWindow.RemakeRecentFiles;
var
  i: integer;
  NFile: string;
begin
  while RecFileList.Count > 10 do
    RecFileList.Delete(10);
  for i := Low(RecMenuList) to High(RecMenuList) do
  begin
    if i < RecFileList.Count then
      NFile := RecFileList[i]
    else
      NFile := '';
    Prefs.RecentFiles[i] := NFile;
    RecMenuList[i].Caption := NFile;
    RecMenuList[i].Visible := NFile <> '';
  end;
end;

procedure TMainWindow.AddNewRecent(Filename: string);
var
  Idx: integer;
begin
  if Trim(Filename) <> '' then
  begin
    Idx := RecFileList.IndexOf(Filename);
    if Idx >= 0 then
      RecFileList.Delete(Idx);
    RecFileList.Insert(0, Filename);
    RemakeRecentFiles;
    Prefs.InitialDir := ExtractFilePath(CurFrame.FileName);
  end;
end;

procedure TMainWindow.AutoHighlighter;
var
  Ext: string;
  i: integer;
  SyntaxIndex: Integer;
begin
  if AutoMenu.Checked then
  begin
    Ext := LowerCase(trim(ExtractFileExt(CurFrame.Filename)));

    For SyntaxIndex := 0 to Pred(SyntaxManager.ElementsCount) do
    begin
      if SyntaxManager.Elements[SyntaxIndex].HasFileExtension(Ext) then
      begin
        SyntaxManager.Elements[SyntaxIndex].MenuItem.Checked := True;
        HighlightMenuItemClick(SyntaxManager.Elements[SyntaxIndex].MenuItem);
        Exit;
      end;
    end;
    // ToDo: Remove hardcoded zero index (highlighter is None)
    // e.g. implement findbytype method in syntaxmanager
    SyntaxManager.Elements[0].MenuItem.Checked := True;
    HighlightMenuItemClick(SyntaxManager.Elements[0].MenuItem);
  end;
end;

procedure TMainWindow.UpdateStatusBar;
var
  i               : LongInt;
  SyntaxIndex     : Integer;
  HighlighterItem : THighlighterListItem;
begin
  CoordPanel.Caption := IntToStr(CurEditor.CaretX) + ', ' + IntToStr(CurEditor.CaretY);
  MikroStat.Changed := CurEditor.Modified;

  if (CurEditor.Highlighter = nil) then
  begin
    // writeln('Highlighter = nil, done newcode');
    MikroStat.Highlighter := NOHIGHLIGHTER_TEXT;  // TODO: transfer const to SyntaxManagement unit ?
  end
  else
  begin
    //  writeln('Highlighter <> nil, for-next looping');
    for i := 0 to Pred(curFrame.Highlighters.Count) do
    begin
      HighlighterItem := curFrame.Highlighters.Items[i];
      If Assigned(HighlighterItem) then
      begin
        if CurEditor.Highlighter = HighlighterItem.HighLighter then
        begin
          // Writeln('set highlighter text');
          SyntaxIndex := HighlighterItem.SyntaxIndex;
          MikroStat.Highlighter :=  SyntaxManager.Elements[SyntaxIndex].MikroName;
          break;
        end;
      end;
    end;
  end;

  MikroStat.InsMode := CurEditor.InsertMode;
  UndoMenu.Enabled := CurEditor.CanUndo;
  RedoMenu.Enabled := CurEditor.CanRedo;
  PasteMenu.Enabled := CurEditor.CanPaste;
  ExportMenu.Enabled := Assigned(CurEditor.Highlighter);
  if Tabs.GetTabData(Tabs.TabIndex).TabModified <> CurEditor.Modified then
  begin
    Tabs.GetTabData(Tabs.TabIndex).TabModified := CurEditor.Modified;
    Tabs.Invalidate;
  end;
  MikroStat.Invalidate;
  StatLabel.Caption := IntToStr(CurEditor.Lines.Count) + ' Lines | ' +
    IntToStr(Length(CurEditor.Text)) + ' bytes';
end;

procedure TMainWindow.UpdateTitlebar;
var
  DispName: string;
begin
  if Prefs.FullPath then
    DispName := CurFrame.Filename
  else
    DispName := ExtractFileName(CurFrame.Filename);
  if Dispname = '' then
    Dispname := 'New Tab';
  Caption := Progname + ' - ' + IntToStr(Tabs.TabIndex + 1) + ': ' + DispName;
end;

procedure TMainWindow.LoadFile(AFileName: string);
var
  Res: integer;
  i: integer;
  KeepSameTab: boolean;
begin
  if Trim(AFilename) = '' then
    Exit;
  {$ifdef AROS}
  if Pos(':', AFilename) <= 0 then
    AFilename := IncludeTrailingPathDelimiter(GetCurrentDir) + AFilename;
  {$endif}
  KeepSameTab := False;
  for i := 0 to Tabs.TabCount - 1 do
  begin
    if LowerCase(TEditorFrame(Tabs.GetTabData(i).TabObject).Filename) =
      lowercase(AFilename) then
    begin
      if i <> Tabs.TabIndex then
      begin
        Res := MessageDlg('Already open', 'This file is already open in Tab ' +
          IntToStr(i + 1) + #13#10 + 'Change to this Tab, instead of loading?',
          mtConfirmation, mbYesNo, 0);
        if Res = mrYes then
        begin
          AddNewRecent(AFilename);
          Tabs.TabIndex := i;
          Exit;
        end;
      end
      else
        KeepSameTab := True;
    end;
  end;
  if Prefs.OpenNewTab and (not CurEditor.Modified) and (not KeepSameTab) then
  begin
    if Length(CurEditor.Lines.Text) > 1 then
      Self.TabPlusClickEvent(nil);
  end
  else
  begin
    if CurEditor.Modified then
    begin
      Res := MessageDlg('Unsaved Data',
        'There are unsaved changes in this Tab.'#13#10'Do you really want to close it?',
        mtConfirmation, mbYesNo, 0);
      if Res <> mrYes then
        Exit;
    end;
  end;
  try
    CurEditor.Lines.LoadFromFile(AFilename);
  except
    ShowMessage('Cannot open File: "' + AFilename + '"');
    Exit;
  end;
  CurFrame.Filename := AFileName;
  AutoHighlighter;
  UpdateTitlebar;
  AddNewRecent(CurFrame.Filename);
  ResetChanged;
  Prefs.InitialDir := ExtractFilePath(CurFrame.FileName);
end;

function TMainWindow.AbsCount: integer;
begin
  Result := FAbsCount;
  Inc(FAbsCount);
end;

function TMainWindow.CurEditor: TSynEdit;
var
  Frame: TEditorFrame;
begin
  Result := nil;
  if Tabs.TabIndex >= 0 then
  begin
    Frame := CurFrame;
    if Assigned(Frame) then
      Result := TSynEdit(Frame.Editor);
  end;
end;

function TMainWindow.CurFrame: TEditorFrame;
begin
  Result := nil;
  if Tabs.TabIndex >= 0 then
  begin
    if Assigned(Tabs.GetTabData(Tabs.TabIndex)) then
      Result := TEditorFrame(Tabs.GetTabData(Tabs.TabIndex).TabObject);
  end;
end;

procedure TMainWindow.HandleExceptions(Sender: TObject; E: Exception);
begin
  {$ifdef AROS}
  DebugLn('Handled Exception: ' + E.Message + ' in ' + E.UnitName);
  {$endif}
end;

procedure TMainWindow.UpdateUserMenu;
var
  Men: TMenuItem;
  i: integer;
  UCom: TUserCommand;
begin
  for i := 0 to UserMenu.ComponentCount - 1 do
  begin
    Men := TMenuItem(UserMenu.Components[0]);
    UserMenu.Remove(Men);
    UCom := TUserCommand(Men.Tag);
    UCom.Free;
    Men.Free;
  end;
  i := 0;
  while True do
  begin
    UCom := TUserCommand.Create;
    Prefs.GetUserCom(i, UCom);
    if UCom.ComLabel = '' then
    begin
      UCom.Free;
      Exit;
    end;
    Men := TMenuItem.Create(UserMenu);
    Men.Caption := UCom.ComLabel;
    Men.OnClick := @UserMenuEvent;
    Men.Tag := PtrUInt(UCom);
    UserMenu.Add(Men);
    Inc(i);
  end;
end;

{$undef IMPLEMENTPROCCESS}

procedure TMainWindow.UserMenuEvent(Sender: TObject);
var
  Men: TMenuItem;
  UCom: TUserCommand;
  Params: string;
  Dir: string;
  OldDir: string;
  {$if defined(Linux) or defined(Win32)}
  AProcess: TProcess;
  {$define IMPLEMENTPROCCESS}
  {$endif}
  {$ifdef HASAMIGA}
  PrgStarter: TAROSPrgStarter;
  {$define IMPLEMENTPROCCESS}
  {$endif}

  {$ifndef IMPLEMENTPROCCESS}
    {$FATAL Implement process for this platform}
  {$endif}

begin
  if Sender is TMenuItem then
  begin
    Men := TMenuItem(Sender);
    UCom := TUserCommand(Men.Tag);
    if (UCom.ComLabel = '-') or (UCom.Command = '') then
      Exit;
    if UCom.SaveBeforeStart then
      SaveMenuClick(nil);
    Params := ReplaceFilePat(UCom.Parameter);
    Dir := ReplaceFilePat(UCom.Path);
    OldDir := '';
    if Dir <> '' then
    begin
      OldDir := GetCurrentDir;
      SetCurrentDir(Dir);
    end;
    case UCom.StartModus of
      0: begin
        {$ifdef HASAMIGA}
        ExecuteProcess('c:run', UCom.Command + ' ' + Params);
        {$endif}
        {$if defined(linux) or defined(windows)}
        AProcess := TProcess.Create(nil);
        AProcess.Commandline := UCom.Command + ' ' + Params;
        AProcess.Options := AProcess.Options - [poWaitOnExit] + [poNewConsole];
        AProcess.Execute;
        AProcess.Free;
        {$endif}
      end;
      1: begin
        ExecuteProcess(UCom.Command, Params);
      end;
      2: begin
        OutWindow.Show;
        {$if defined(linux) or defined(Windows)}
        OutWindow.OutList.Visible := True;
        OutWindow.OutMemo.Visible := False;
        AProcess := TProcess.Create(nil);
        AProcess.Commandline := UCom.Command + ' ' + Params;
        AProcess.Options := AProcess.Options + [poWaitOnExit, poUsePipes];
        AProcess.Execute;
        OutWindow.OutList.Items.LoadFromStream(AProcess.Output);
        AProcess.Free;
        {$endif}
        {$ifdef HASAMIGA}
        OutWindow.CaptureMode := UCom.CaptureModus;
        OutWindow.FPath := Trim(ExtractFilePath(UCom.Command));
        if OutWindow.FPath = '' then
          OutWindow.FPath := Trim(ExtractFilePath(CurFrame.Filename));
        OutWindow.OutList.Visible := False;
        OutWindow.OutMemo.Visible := True;
        PrgStarter := TAROSPrgStarter.Create;
        PrgStarter.ErrAsOutput := UCom.CaptureModus = 1;
        PrgStarter.FStackSize := Min(4096, UCom.Stack);
        PrgStarter.OnUpdate := @UpdateOutputEvent;
        PrgStarter.StartUp(UCom.Command, Params, OutWindow.OutMemo.Lines);
        PrgStarter.Free;
        OutWindow.OutList.Items.Assign(OutWindow.OutMemo.Lines);
        OutWindow.BeautifyIt;
        OutWindow.OutList.ItemIndex := OutWindow.OutList.Count - 1;
        OutWindow.OutMemo.Visible := False;
        OutWindow.OutList.Visible := True;
        {$endif}
      end;
    end;
    if Dir <> '' then
    begin
      SetCurrentDir(OldDir);
    end;
  end;
end;

function TMainWindow.ReplaceFilePat(Base: string): string;
var
  FN: string;
begin
  FN := CurFrame.Filename;
  Result := StringReplace(Base, FILEPATTERN, ExtractFileName(FN), [rfReplaceAll]);
  Result := StringReplace(Result, FILEwPathPATTERN, FN, [rfReplaceAll]);
  Result := StringReplace(Result, FILEwExtPATTERN, ExtractFileNameWithoutExt(ExtractFileName(FN)), [rfReplaceAll]);
  Result := StringReplace(Result, FILEwExtwPathPATTERN, ExtractFileNameWithoutExt(FN), [rfReplaceAll]);
  Result := StringReplace(Result, PATHPATTERN, ExtractFilePath(FN), [rfReplaceAll]);
end;

procedure TMainWindow.UpdateOutputEvent(Sender: TObject);
begin
  OutWindow.OutMemo.CaretY := OutWindow.OutMemo.Lines.Count;
  application.ProcessMessages;
end;

end.
