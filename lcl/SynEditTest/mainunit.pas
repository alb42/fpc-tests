unit MainUnit;

{$mode objfpc}{$H+}

interface 

uses

  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterPas, Forms, Controls,
  Graphics, Dialogs, Menus, ExtCtrls, SynHighlighterCpp, FrameUnit, LCLIntf,
  {$ifdef HASAMIGA}
  Workbench, muiformsunit, LCLMessageGlue,
  {$endif}
  synexporthtml, SynEditTypes, SynEditKeyCmds, LCLType, Math, ATTabs,
  MikroStatUnit;

const
  VERSION = '$VER: EdiSyn 0.32 (24.03.2015)';


  PASEXT: array[0..2] of string = ('.pas', '.pp', '.inc');
  CEXT: array[0..3] of string = ('.c', '.h', '.cpp','.hpp');

  CTEXT =
    '#include <proto/exec.h>'#13#10 +
    '#include <dos/dos.h>'#13#10 +
    '#include <intuition/intuition.h>'#13#10 +
    '#include <intuition/intuitionbase.h>'#13#10 +
    '#include <proto/intuition.h>'#13#10 +
    '#include <intuition/screens.h>'#13#10 +
    ''#13#10 +
    'const TEXT version[] = "VER: Beep 41.2 (03.03.2011)";'#13#10 +
    ''#13#10 +
    '__startup AROS_PROCH(Start, argstr, argsize, SysBase)'#13#10 +
    '{'#13#10 +
    '  AROS_PROCFUNC_INIT'#13#10 +
    ''#13#10 +
    '  struct IntuitionBase *IntuitionBase;  // Its a comment'#13#10 +
    ''#13#10 +
    '              /*Another'#13#10 +
    '                Comment*/'#13#10 +
    '  IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library", 0);'#13#10 +
    '  if (!IntuitionBase)'#13#10 +
    '    return RETURN_FAIL;'#13#10 +
    ''#13#10 +
    '  DisplayBeep( NULL );'#13#10 +
    ''#13#10 +
    '  CloseLibrary(&IntuitionBase->LibNode);'#13#10 +
    '  return RETURN_OK;'#13#10 +
    '  AROS_PROCFUNC_EXIT'#13#10 +
    '}';

  PASTEXT =
    'unit Unit1;'#13#10 +
    ''#13#10 +
    '{$mode objfpc}{$H+}'#13#10 +
    ''#13#10 +
    'interface'#13#10 +
    ''#13#10 +
    'uses'#13#10 +
    '  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterPas, Forms, Controls,'#13#10 +
    '  Graphics, Dialogs;'#13#10 +
    ''#13#10 +
    'type'#13#10 +
    ''#13#10 +
    '  { TForm1 }'#13#10 +
    ''#13#10 +
    '  TForm1 = class(TForm)'#13#10 +
    '    SynEdit1: TSynEdit;'#13#10 +
    '    SynPasSyn1: TSynPasSyn;'#13#10 +
    '  private'#13#10 +
    '    procedure Test;'#13#10 +
    '    { private declarations }'#13#10 +
    '  public'#13#10 +
    '    { public declarations }'#13#10 +
    '  end;'#13#10 +
    ''#13#10 +
    'var'#13#10 +
    '  Form1: TForm1;'#13#10 +
    ''#13#10 +
    'implementation'#13#10 +
    ''#13#10 +
    '{$R *.lfm}'#13#10 +
    ''#13#10 +
    '{ TForm1 }'#13#10 +
    ''#13#10 +
    'procedure TForm1.Test;'#13#10 +
    'begin'#13#10 +
    '  writeln(''something to test with'', 14, '' also with numbers ;)'');'#13#10 +
    'end;'#13#10 +
    ''#13#10 +
    'end.';

NText =
    'Sed ut perspiciatis unde omnis iste natus error sit voluptatem'#13#10 +
    'accusantium doloremque laudantium, totam rem aperiam, eaque'#13#10 +
    'ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae'#13#10 +
    'dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas'#13#10 +
    'sit aspernatur aut odit aut fugit, sed quia consequuntur magni'#13#10 +
    'dolores eos qui ratione voluptatem sequi nesciunt. Neque porro'#13#10 +
    'quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur,'#13#10 +
    'adipisci velit, sed quia non numquam eius modi tempora incidunt'#13#10 +
    'ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim'#13#10 +
    'ad minima veniam, quis nostrum exercitationem ullam corporis'#13#10 +
    'suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur?'#13#10 +
    'Quis autem vel eum iure reprehenderit qui in ea voluptate velit'#13#10 +
    'esse quam nihil molestiae consequatur, vel illum qui dolorem eum'#13#10 +
    'fugiat quo voluptas nulla pariatur?'#13#10 +
    ''#13#10 +
    'At vero eos et accusamus et iusto odio dignissimos ducimus qui'#13#10 +
    'blanditiis praesentium voluptatum deleniti atque corrupti quos'#13#10 +
    'dolores et quas molestias excepturi sint occaecati cupiditate non'#13#10 +
    'provident, similique sunt in culpa qui officia deserunt mollitia animi,'#13#10 +
    'id est laborum et dolorum fuga. Et harum quidem rerum facilis est'#13#10 +
    'et expedita distinctio. Nam libero tempore, cum soluta nobis est'#13#10 +
    'eligendi optio cumque nihil impedit quo minus id quod maxime'#13#10 +
    'placeat facere possimus, omnis voluptas assumenda est, omnis'#13#10 +
    'dolor repellendus. Temporibus autem quibusdam et aut officiis'#13#10 +
    'debitis aut rerum necessitatibus saepe eveniet ut et voluptates'#13#10 +
    'repudiandae sint et molestiae non recusandae. Itaque earum'#13#10 +
    'rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus'#13#10 +
    'maiores alias consequatur aut perferendis doloribus asperiores'#13#10 +
    'repellat. '#13#10 +
    ''#13#10 +
    '                              "De finibus bonorum et malorum" Cicero';

type
  { TForm1 }

  TForm1 = class(TForm)
    EditMenu: TMenuItem;
    CopyMenu: TMenuItem;
    CutMenu: TMenuItem;
    BookmarkImages: TImageList;
    MenuItem1: TMenuItem;
    GoToLineMenu: TMenuItem;
    AutoMenu: TMenuItem;
    EditorPanel: TPanel;
    CloseTabMenu: TMenuItem;
    CloseAllMenu: TMenuItem;
    BookMarkMenu: TMenuItem;
    SepMenu4: TMenuItem;
    NewTabMenu: TMenuItem;
    MikroStat: TMikroStatus;
    SetDefHighMenu: TMenuItem;
    ShowNumMenu: TMenuItem;
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
    NoneMenu: TMenuItem;
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
    CMenu: TMenuItem;
    PascalMenu: TMenuItem;
    ExampleMenu: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    SynExporterHTML1: TSynExporterHTML;
    procedure AutoMenuClick(Sender: TObject);
    procedure BookMarkMenuClick(Sender: TObject);
    procedure CloseAllMenuClick(Sender: TObject);
    procedure CloseTabMenuClick(Sender: TObject);
    procedure CMenuClick(Sender: TObject);
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
    procedure NewTabMenuClick(Sender: TObject);
    procedure NoneMenuClick(Sender: TObject);
    procedure PasteMenuClick(Sender: TObject);
    procedure RecMenu1Click(Sender: TObject);
    procedure RedoMenuClick(Sender: TObject);
    procedure ReplaceMenuClick(Sender: TObject);
    procedure SearchAgainMenuClick(Sender: TObject);
    procedure SearchMenuClick(Sender: TObject);
    procedure SelAllMenuClick(Sender: TObject);
    procedure NewMenuClick(Sender: TObject);
    procedure OpenMenuClick(Sender: TObject);
    procedure PascalMenuClick(Sender: TObject);
    procedure QuitMenuClick(Sender: TObject);
    procedure SaveAsMenuClick(Sender: TObject);
    procedure SaveMenuClick(Sender: TObject);
    procedure SetDefHighMenuClick(Sender: TObject);
    procedure ShowNumMenuClick(Sender: TObject);
    procedure SynEdit1ProcessCommand(Sender: TObject;
      var Command: TSynEditorCommand; var AChar: TUTF8Char; Data: pointer);
    procedure SynEdit1ReplaceText(Sender: TObject; const ASearch,
      AReplace: string; Line, Column: integer;
      var ReplaceAction: TSynReplaceAction);
    procedure SynEdit1StatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure TabClickEvent(Sender: TObject);
    procedure TabCloseEvent(Sender: TObject; ATabIndex: Integer; var ACanClose,
      ACanContinue: boolean);
    procedure TabPlusClickEvent(Sender: TObject);
    procedure UndoMenuClick(Sender: TObject);
  private
    FAbsCount: Integer;
    ProgName: string;
    RecFileList: TStringList;
    RecMenuList: array[0..9] of TMenuItem;
    procedure ResetChanged;
    procedure RemakeRecentFiles;
    procedure AddNewRecent(Filename: string);
    procedure AutoHighlighter;
    procedure UpdateStatusBar;
    procedure UpdateTitlebar;
  public
    Tabs: TATTabs;
    procedure LoadFile(AFileName: string);
    function AbsCount: Integer;
    function CurEditor: TSynEdit;
    function CurFrame: TEditorFrame;
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  GotLineUnit, SearchReplaceUnit, ReplaceReqUnit, PrefsUnit;

{$R *.lfm}

{ TForm1 }

procedure TForm1.ExampleMenuClick(Sender: TObject);
begin
  if CMenu.Checked then
    CurEditor.Lines.Text := CTEXT
  else
    if PascalMenu.checked then
      CurEditor.Lines.Text := PASTEXT
    else
      CurEditor.Lines.Text := NTEXT;
  ResetChanged;
end;

procedure TForm1.ExportMenuClick(Sender: TObject);
begin
  // if Highlighter is not assigned the HTML export will crash!
  if CurEditor.Highlighter = nil then
    Exit;
  if SaveDialog1.Execute then
  begin
    SynExporterHTML1.ExportAll(CurEditor.Lines);
    SynExporterHTML1.Highlighter := CurEditor.Highlighter;
    SynExporterHTML1.SaveToFile(SaveDialog1.FileName);
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  Res: Integer;
  i: Integer;
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
    Res := MessageDlg('Unsaved Data', 'There are unsaved changes.'#13#10'Do you really want to close?', mtConfirmation, mbYesNo, 0);
    CanClose := Res = mrYes;
  end;
  {$ifdef AROS}
  // dirty hack to get the window position again ;)
  if HandleAllocated and (TObject(Handle) is TMUIWindow) then
    LCLSendMoveMsg(Self, TMUIWindow(Handle).Top, TMUIWindow(Handle).Left, Move_Default, False);
  {$endif}
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i: Integer;
  NFile: string;
  NewFrame: TEditorFrame;
begin
  // Counter for Editornames ;)
  FAbsCount := 0;
  // Tab control initial Values
  Tabs := TATTabs.create(Self);
  Tabs.Align:= alTop;
  Tabs.Font.Size:= 8;
  Tabs.Height:= 42;
  Tabs.TabAngle:= 0;
  Tabs.TabIndentInter:= 2;
  Tabs.TabIndentInit:= 2;
  Tabs.TabIndentTop:= 4;
  Tabs.TabIndentXSize:= 13;
  Tabs.TabWidthMin:= 18;
  Tabs.TabDragEnabled:= false;
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
  // Tab Control Events
  Tabs.OnTabPlusClick:=@TabPlusClickEvent;
  Tabs.OnTabClose:=@TabCloseEvent;
  Tabs.OnTabClick:=@TabClickEvent;
  // we create the first Tab (there should never be an empty Tab control)
  NewFrame := TEditorFrame.Create(Self);
  NewFrame.TabLink := Tabs;
  NewFrame.Name := 'NewFrame'+IntToStr(AbsCount);
  NewFrame.Align := alClient;
  NewFrame.Editor.Parent := EditorPanel;
  Tabs.AddTab(-1, 'Empty Tab', NewFrame, False, clNone);
  // Auto Highlighter preferences
  AutoMenu.Checked := Prefs.AutoHighlighter;
  // which highlighter is default
  case Prefs.DefHighlighter of
    HIGHLIGHTER_C: begin
      CMenu.Checked := True;
      CMenuClick(nil);
    end;
    HIGHLIGHTER_PASCAL: begin
      PascalMenu.Checked := True;
      PascalMenuClick(Sender);
    end;
    else begin
      NoneMenu.Checked := True;
      NoneMenuClick(Sender);
    end;
  end;
  // LineNumbers
  ShowNumMenu.Checked := Prefs.LineNumbers;
  BookMarkMenu.Checked := Prefs.Bookmarks;
  CurEditor.Gutter.Parts[0].Visible:= BookMarkMenu.Checked;
  CurEditor.Gutter.Parts[1].Visible:= ShowNumMenu.Checked;
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
  CurFrame.Filename := '';
  if Paramcount > 0 then
  begin
    try
      LoadFile(ParamStr(1)); // Try to load the file will set CurFrame.Filename
    except
      CurFrame.Filename := '';
    end;
  end;
  {$ifdef HASAMIGA}
  // Some AROS Quirks when started via icon from a TextFile
  if (CurFrame.Filename = '') and Assigned(AOS_WBMsg) then
  begin
    if PWBStartup(AOS_WBMsg)^.sm_NumArgs > 1 then
    begin
      try
        LoadFile(PWBStartup(AOS_WBMsg)^.sm_ArgList^[2].WA_Name); // Load it
      except
        CurFrame.Filename := '';
      end;
    end;
  end;
  {$endif}
  // set Programname for the Caption
  ProgName := VERSION;
  Delete(Progname, 1, 6);  // Cut Version
  Delete(Progname, Pos('(', Progname), Length(Progname)); // Cut Date
  // Init Mikrostats set everything twice, to init (because it compares for equal values)
  MikroStat.Highlighter := '';
  MikroStat.Changed := True;
  MikroStat.Changed := False;
  MikroStat.InsMode:=False;
  MikroStat.InsMode := True;
  // Update Titlebar, status bar
  UpdateTitlebar;
  ResetChanged;
  UpdateStatusBar;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  // save The current position for next run
  Prefs.XPos := Left;
  Prefs.YPos := Top;
  Prefs.Width := Width;
  Prefs.Height := Height;
  // Recent File list
  RecFileList.Free;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  // Move/Size the window to the previous saved parameters
  SetBounds(Prefs.XPos, Prefs.YPos, Prefs.Width, Prefs.Height);
end;

procedure TForm1.GoToLineMenuClick(Sender: TObject);
begin
  // Open jump to Line window, (Next to the upper Right side of mainwindow)
  GotoLineWin.Visible := False;
  GoToLineWin.SetBounds(Max(5, Left + Width - GotoLineWin.Width), Max(5, Top - GoToLineWin.Height div 2), GoToLineWin.Width, GoToLineWin.Height);
  GoToLineWin.Show;
end;

procedure TForm1.DestroyTabTimerTimer(Sender: TObject);
begin
  // Destroy a Tab, via Timer, because we are not allowed to destroy the
  // SynEdit Editor inside one of its Events -> Key press -> Close Tab
  DestroyTabTimer.Enabled:= False;
  CloseTabMenuClick(Sender)
end;

procedure TForm1.NewTabMenuClick(Sender: TObject);
begin
  // New Tab please.
  TabPlusClickEvent(Tabs);
end;

procedure TForm1.NoneMenuClick(Sender: TObject);
begin
  // Switch Highlighter off
  if NoneMenu.Checked then
  begin
    CurEditor.Highlighter := nil;
    ExportMenu.Enabled := False;
    MikroStat.Highlighter := NOHIGHLIGHTER_TEXT;
  end;
end;

procedure TForm1.PasteMenuClick(Sender: TObject);
begin
  // Paste
  CurEditor.PasteFromClipboard;
end;

procedure TForm1.RecMenu1Click(Sender: TObject);
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

procedure TForm1.RedoMenuClick(Sender: TObject);
begin
  CurEditor.Redo;
end;

procedure TForm1.ReplaceMenuClick(Sender: TObject);
begin
  // Search and replace is one Window with two modes
  SearchReplaceWin.StartReq(True);
end;

procedure TForm1.SearchAgainMenuClick(Sender: TObject);
begin
  // Search again F3
  SearchReplaceWin.SearchAgainClick(Sender);
end;

procedure TForm1.SearchMenuClick(Sender: TObject);
begin
  if CurEditor.SelAvail then
    SearchReplaceWin.SearchEdit.Text := CurEditor.SelText;
  SearchReplaceWin.StartReq(False);
end;

procedure TForm1.SelAllMenuClick(Sender: TObject);
begin
  // give me everything
  CurEditor.SelectAll;
end;

procedure TForm1.NewMenuClick(Sender: TObject);
var
  Res: Integer;
begin
  if CurEditor.Modified then
  begin
    Res := MessageDlg('Unsaved Data', 'There are unsaved changes in this Tab.'#13#10'Do you really want to close it?', mtConfirmation, mbYesNo, 0);
    if Res <> mrYes then
      Exit;
  end;
  // Delete the contents of the current Tab
  CurFrame.Filename := '';
  CurEditor.Lines.Clear;
  UpdateTitlebar;
  ResetChanged;
end;

procedure TForm1.OpenMenuClick(Sender: TObject);
var
  Res: Integer;
begin
  if CurEditor.Modified then
  begin
    Res := MessageDlg('Unsaved Data', 'There are unsaved changes in this Tab.'#13#10'Do you really want to close it?', mtConfirmation, mbYesNo, 0);
    if Res <> mrYes then
      Exit;
  end;
  // Open a new File
  {$ifdef HASAMIGA}
  // Quirk for amiga, or the Filter is just invisible -> better set then the
  // can type an own Filter if needed
  OpenDialog1.Filter:='#?';
  {$endif}
  OpenDialog1.InitialDir:= Prefs.InitialDir;
  if OpenDialog1.InitialDir = '' then
    OpenDialog1.InitialDir := 'Sys:';
  if OpenDialog1.Execute then
  begin
    LoadFile(OpenDialog1.FileName);
    Prefs.InitialDir := ExtractFilePath(OpenDialog1.FileName);
  end;
end;

procedure TForm1.CMenuClick(Sender: TObject);
begin
  // Set the C Highlighter
  if CMenu.Checked then
  begin
    CurEditor.Highlighter := CurFrame.SynCppSyn1;
    ExportMenu.Enabled := True;
    MikroStat.Highlighter:='C';
  end;
end;

procedure TForm1.AutoMenuClick(Sender: TObject);
begin
  // save Autohighlighter function to preferences
  Prefs.AutoHighlighter := AutoMenu.Checked;
end;

procedure TForm1.BookMarkMenuClick(Sender: TObject);
var
  i: Integer;
  Editor: TSynEdit;
begin
  Prefs.Bookmarks := BookMarkMenu.Checked;
  for i := 0 to Tabs.TabCount - 1 do
  begin
    Editor := TSynEdit(TEditorFrame(Tabs.GetTabData(i).TabObject).Editor);
    Editor.Gutter.Parts[0].Visible := BookMarkMenu.Checked;
  end;
end;

procedure TForm1.CloseAllMenuClick(Sender: TObject);
var
  i: Integer;
  Modified: Boolean;
  CanClose: boolean;
  CanCont: boolean;
  Res: Integer;
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
    Res := MessageDlg('Unsaved Data', 'There are unsaved changes.'#13#10'Do you really want to close all Tabs?', mtConfirmation, mbYesNo, 0);
    if Res <> mrYes then
      Exit;
  end;
  //and now... to something completely different... ehm I mean trash everything
  //we delete all except one, which one is not important thats the reason for
  // the -2, thats the Tan we clean then
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

procedure TForm1.CloseTabMenuClick(Sender: TObject);
begin
  // Delete Tab, the tab control will call the Event to check if really to Delete
  Tabs.DeleteTab(Tabs.TabIndex, True, True);
end;

procedure TForm1.CopyMenuClick(Sender: TObject);
begin
  // Clip
  CurEditor.CopyToClipboard;
end;

procedure TForm1.CutMenuClick(Sender: TObject);
begin
  // CutClip
  CurEditor.CutToClipboard;
end;

procedure TForm1.PascalMenuClick(Sender: TObject);
begin
  // Pascal highlighter
  // TODO: Change Highlighters to a List with Tags as Index
  if PascalMenu.Checked then
  begin
    CurEditor.Highlighter := CurFrame.SynPasSyn1;
    ExportMenu.Enabled := True;
    MikroStat.Highlighter:='Pas';
  end;
end;

procedure TForm1.QuitMenuClick(Sender: TObject);
begin
  // This quirk is not needed anymore, but also does not harm
  // remove selection -> or crash
  CurEditor.Lines.Clear;
  CurEditor.SelStart := 0;
  CurEditor.SelEnd := 0;
  // bybye
  Close;
end;

procedure TForm1.SaveAsMenuClick(Sender: TObject);
begin
  // Save as, use the current File+Path as Start
  SaveDialog1.InitialDir:= ExtractFilePath(CurFrame.Filename);
  if SaveDialog1.InitialDir = '' then
    SaveDialog1.InitialDir := Prefs.InitialDir;
  SaveDialog1.FileName:= ExtractFileName(CurFrame.Filename);
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

procedure TForm1.SaveMenuClick(Sender: TObject);
begin
  // if filename is set use it to save,
  // if not call save as to ask the user
  if CurFrame.Filename <> '' then
  begin
    CurEditor.Lines.SaveToFile(CurFrame.Filename);
    UpdateTitlebar;
    ResetChanged;
    CurEditor.MarkTextAsSaved;
  end else
    SaveAsMenuClick(Sender);
end;

procedure TForm1.SetDefHighMenuClick(Sender: TObject);
begin
  // HighlighterSetting as Default (TODO: as List? for more Highlighters?)
  if CMenu.Checked then
    Prefs.DefHighlighter := HIGHLIGHTER_C;
  if PascalMenu.Checked then
    Prefs.DefHighlighter := HIGHLIGHTER_PASCAL;
  if NoneMenu.Checked then
    Prefs.DefHighlighter := HIGHLIGHTER_NONE;
end;

procedure TForm1.ShowNumMenuClick(Sender: TObject);
var
  Editor: TSynEdit;
  i: Integer;
begin
  // Show the LineNumbers on the Left Side
  Prefs.LineNumbers := ShowNumMenu.Checked;
  for i := 0 to Tabs.TabCount - 1 do
  begin
    Editor := TSynEdit(TEditorFrame(Tabs.GetTabData(i).TabObject).Editor);
    Editor.Gutter.Parts[1].Visible:= ShowNumMenu.Checked;
  end;
end;

procedure TForm1.SynEdit1ProcessCommand(Sender: TObject;
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
    9: DestroyTabTimer.Enabled:= True; // Ctrl + G Close Tab
    10: Tabs.SwitchTab(False);    // Ctrl + Shift + F1 previous Tab
    11: Tabs.SwitchTab(True);     // Ctrl + Shift + F2 next Tab
  end;
end;

procedure TForm1.SynEdit1ReplaceText(Sender: TObject; const ASearch,
  AReplace: string; Line, Column: integer; var ReplaceAction: TSynReplaceAction
  );
var
  Res: TModalResult;
begin
  Res := ReplaceReqUnit.ReplaceRequest.StartReq('Replace this occurence by "' + AReplace + '" ?');
  case Res of
    mrYes: ReplaceAction := raReplace;
    mrYesToAll: ReplaceAction := raReplaceAll;
    mrNo: ReplaceAction := raSkip;
    mrCancel: ReplaceAction := raCancel;
  end;
end;

procedure TForm1.SynEdit1StatusChange(Sender: TObject;
  Changes: TSynStatusChanges);
begin
  if CurEditor = Sender then
  begin
    UpdateStatusBar;
  end;
end;

procedure TForm1.TabClickEvent(Sender: TObject);
var
  i: Integer;
  Frame: TEditorFrame;
begin
  EditorPanel.BeginUpdateBounds;
  for i := 0 to Tabs.TabCount - 1 do
  begin
    Frame := TEditorFrame(Tabs.GetTabData(i).TabObject);
    if Frame.Editor.Visible <> (i = Tabs.TabIndex) then
      Frame.Editor.Visible := (i = Tabs.TabIndex);
  end;
  if Assigned(CurEditor.Highlighter) then
  begin
    if CurEditor.Highlighter is TSynCppSyn then
      CMenu.Checked := True
    else
      PascalMenu.Checked := True
  end else
    NoneMenu.Checked := True;
  UpdateStatusBar;
  UpdateTitlebar;
  EditorPanel.EndUpdateBounds;
  Frame := TEditorFrame(Tabs.GetTabData(Tabs.TabIndex).TabObject);
  Frame.Editor.SetFocus;
end;

procedure TForm1.TabCloseEvent(Sender: TObject; ATabIndex: Integer;
  var ACanClose, ACanContinue: boolean);
var
  TabData: TATTabData;
  Res: Integer;
begin
  ACanClose := True;
  TabData := Tabs.GetTabData(ATabIndex);
  if TEditorFrame(TabData.TabObject).Editor.Modified then
  begin
    Res := MessageDlg('Unsaved Data', 'The Text in this Tab is not saved.'#13#10'Do you really want to close it?', mtConfirmation, mbYesNo, 0);
    ACanClose := Res = mrYes;
  end;
  if not ACanClose then
    Exit;
  if Tabs.TabCount > 1 then
  begin
    if ACanClose then
      TabData.TabObject.Free;
  end else
  begin
    CurEditor.Lines.Clear;
    CurEditor.Modified := False;
    TabData := Tabs.GetTabData(Tabs.TabIndex);
    TabData.TabModified := False;
    TEditorFrame(TabData.TabObject).Filename := '';
    TabData.TabCaption := 'Empty Tab';
    Tabs.Invalidate;
    ACanClose := False;
  end;
end;

procedure TForm1.TabPlusClickEvent(Sender: TObject);
var
  NewFrame: TEditorFrame;
begin
  NewFrame := TEditorFrame.Create(Self);
  NewFrame.Editor.Parent := EditorPanel;
  NewFrame.TabLink := Tabs;
  NewFrame.Name := 'NewFrame'+IntToStr(AbsCount);
  NewFrame.Align := alClient;
  NewFrame.Editor.Gutter.Parts[0].Visible:= BookMarkMenu.Checked;
  NewFrame.Editor.Gutter.Parts[1].Visible:= ShowNumMenu.Checked;
  if PascalMenu.Checked then
    NewFrame.Editor.Highlighter := NewFrame.SynPasSyn1;
  if CMenu.Checked then
    NewFrame.Editor.Highlighter := NewFrame.SynCppSyn1;
  if NoneMenu.Checked then
    NewFrame.Editor.Highlighter := nil;
  Tabs.AddTab(-1, 'Empty Tab', NewFrame, False, clNone);
  NewFrame.Editor.Visible := True;
  NewFrame.Editor.SetFocus;
  Tabs.TabIndex := Tabs.TabCount - 1;
end;

procedure TForm1.UndoMenuClick(Sender: TObject);
begin
  CurEditor.Undo;
end;

procedure TForm1.ResetChanged;
begin
  CurEditor.Modified := False;
  Tabs.GetTabData(Tabs.TabIndex).TabModified := False;
  Tabs.Invalidate;
  UpdateTitlebar;
end;

procedure TForm1.RemakeRecentFiles;
var
  i: Integer;
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

procedure TForm1.AddNewRecent(Filename: string);
var
  Idx: Integer;
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

procedure TForm1.AutoHighlighter;
var
  Ext: String;
  i: Integer;
begin
  if AutoMenu.Checked then
  begin
    Ext := LowerCase(trim(ExtractFileExt(CurFrame.Filename)));
    for i := 0 to High(PASEXT) do
    begin
      if Ext = PASEXT[i] then
      begin
        PascalMenu.Checked := True;
        PascalMenuClick(PascalMenu);
        Exit;
      end;
    end;
    for i := 0 to High(CEXT) do
    begin
      if Ext = CEXT[i] then
      begin
        CMenu.Checked := True;
        CMenuClick(CMenu);
        Exit;
      end;
    end;
    NoneMenu.Checked:=True;
    NoneMenuClick(NoneMenu);
  end;
end;

procedure TForm1.UpdateStatusBar;
begin
  CoordPanel.Caption := IntToStr(CurEditor.CaretX) + ', ' + IntToStr(CurEditor.CaretY);
  MikroStat.Changed:= CurEditor.Modified;
  if CurEditor.Highlighter = nil then
  begin
    MikroStat.Highlighter := NOHIGHLIGHTER_TEXT;
  end else
  begin
    if CurEditor.Highlighter is TSynCppSyn then
      MikroStat.Highlighter := 'C'
    else
      MikroStat.Highlighter := 'Pas';
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
end;

procedure TForm1.UpdateTitlebar;
begin
  Caption := Progname + ' - ' + IntToStr(Tabs.TabIndex + 1) + ': ' + Tabs.GetTabData(Tabs.TabIndex).TabCaption;
  CurEditor;
end;

procedure TForm1.LoadFile(AFileName: string);
var
  Res: Integer;
begin
  if CurEditor.Modified then
  begin
    Res := MessageDlg('Unsaved Data', 'There are unsaved changes in this Tab.'#13#10'Do you really want to close it?', mtConfirmation, mbYesNo, 0);
    if Res <> mrYes then
      Exit;
  end;
  CurFrame.Filename := AFileName;
  CurEditor.Lines.LoadFromFile(CurFrame.Filename);
  AutoHighlighter;
  UpdateTitlebar;
  AddNewRecent(CurFrame.Filename);
  ResetChanged;
  Prefs.InitialDir := ExtractFilePath(CurFrame.FileName);
end;

function TForm1.AbsCount: Integer;
begin
  Result := FAbsCount;
  Inc(FAbsCount);
end;

function TForm1.CurEditor: TSynEdit;
begin
  REsult := nil;
  if Tabs.TabIndex >= 0 then
  begin
    Result := TSynEdit(CurFrame.Editor);
  end;
end;

function TForm1.CurFrame: TEditorFrame;
begin
  Result := nil;
  if Tabs.TabIndex >= 0 then
  begin
    if Assigned(Tabs.GetTabData(Tabs.TabIndex)) then
      Result := TEditorFrame(Tabs.GetTabData(Tabs.TabIndex).TabObject);
  end;
end;

end.
