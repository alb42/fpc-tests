unit MainUnit;

{$mode objfpc}{$H+}

interface 

uses

  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterPas, Forms, Controls,
  Graphics, Dialogs, Menus, ComCtrls, ExtCtrls, StdCtrls, SynHighlighterCpp,
  {$ifdef HASAMIGA}
  Workbench,
  {$endif}
  synexporthtml, SynEditTypes, StrUtils, SynEditKeyCmds, LCLType, Math;

const
  VERSION = '$VER: EdiSyn 0.21 (21.03.2015)';


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
    ChangedPanel: TPanel;
    EditMenu: TMenuItem;
    CopyMenu: TMenuItem;
    CutMenu: TMenuItem;
    MenuItem1: TMenuItem;
    GoToLineMenu: TMenuItem;
    AutoMenu: TMenuItem;
    ShowNumMenu: TMenuItem;
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
    SynEdit1: TSynEdit;
    SynPasSyn1: TSynPasSyn;
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
    SynCppSyn1: TSynCppSyn;
    SynExporterHTML1: TSynExporterHTML;
    procedure AutoMenuClick(Sender: TObject);
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
    procedure NoneMenuClick(Sender: TObject);
    procedure PasteMenuClick(Sender: TObject);
    procedure PersSelMenuClick(Sender: TObject);
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
    procedure ShowNumMenuClick(Sender: TObject);
    procedure SynEdit1ProcessCommand(Sender: TObject;
      var Command: TSynEditorCommand; var AChar: TUTF8Char; Data: pointer);
    procedure SynEdit1ReplaceText(Sender: TObject; const ASearch,
      AReplace: string; Line, Column: integer;
      var ReplaceAction: TSynReplaceAction);
    procedure SynEdit1StatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure UndoMenuClick(Sender: TObject);
  private
    ProgName: string;
    FFilename: string;
    ChangedStamp: Int64;
    RecFileList: TStringList;
    RecMenuList: array[0..9] of TMenuItem;
    procedure ResetChanged;
    procedure RemakeRecentFiles;
    procedure AddNewRecent(Filename: string);
    procedure AutoHighlighter;
  public
    procedure LoadFile;
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
    SynEdit1.Lines.Text := CTEXT
  else
    if PascalMenu.checked then
      SynEdit1.Lines.Text := PASTEXT
    else
      SynEdit1.Lines.Text := NTEXT;
  ResetChanged;
end;

procedure TForm1.ExportMenuClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    SynExporterHTML1.ExportAll(SynEdit1.Lines);
    SynExporterHTML1.Highlighter := SynEdit1.Highlighter;
    SynExporterHTML1.SaveToFile(SaveDialog1.FileName);
  end;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  Res: Integer;
begin
  CanClose := True;
  if SynEdit1.Modified then
  begin
    Res := MessageDlg('Unsaved Changes', 'There are unsaved changes in this document do you really want to close?', mtConfirmation, mbYesNo, 0);
    CanClose := Res = mrYes;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i: Integer;
  NFile: string;
begin
  // Auto Highlighter
  AutoMenu.Checked := Prefs.AutoHighlighter;
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
  SynEdit1.Gutter.Parts[0].Visible:= ShowNumMenu.Checked;
  SynEdit1.Gutter.Parts[1].Visible:= ShowNumMenu.Checked;
  // Recent Files
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
    RecMenuList[i].Visible := NFile <> '';
    RecMenuList[i].Tag := i;
  end;
  // Load file if parameter list
  FFilename := '';
  if Paramcount > 0 then
  begin
    try
      FFilename := ParamStr(1);
      LoadFile;
    except
      FFilename := '';
    end;
  end;
  {$ifdef HASAMIGA}
  if (FFilename = '') and Assigned(AOS_WBMsg) then
  begin
    if PWBStartup(AOS_WBMsg)^.sm_NumArgs > 1 then
    begin
      try
        FFilename := PWBStartup(AOS_WBMsg)^.sm_ArgList^[2].WA_Name;
        LoadFile;
      except
        FFilename := '';
      end;
    end;
  end;
  {$endif}
  //
  ProgName := VERSION;
  Delete(Progname, 1, 6);
  Delete(Progname, Pos('(', Progname), Length(Progname));
  //
  if FFilename = '' then
    Caption := Progname + ' - No File Loaded'
  else
    Caption := Progname + ' - ' + ExtractFileName(FFilename);
  ResetChanged;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Prefs.XPos := Left;
  Prefs.YPos := Top;
  Prefs.Width := Width;
  Prefs.Height := Height;
  RecFileList.Free;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  SetBounds(Prefs.XPos, Prefs.YPos, Prefs.Width, Prefs.Height);
  SynEdit1.SetFocus;
end;

procedure TForm1.GoToLineMenuClick(Sender: TObject);
begin
  GotoLineWin.Visible := False;
  GoToLineWin.SynEdit1 := SynEdit1;
  GoToLineWin.SetBounds(Max(5, Left + Width - GotoLineWin.Width), Max(5, Top - GoToLineWin.Height div 2), GoToLineWin.Width, GoToLineWin.Height);
  GoToLineWin.Show;
end;

procedure TForm1.NoneMenuClick(Sender: TObject);
begin
  if NoneMenu.Checked then
  begin
    SynEdit1.Highlighter := nil;
    Prefs.DefHighlighter := HIGHLIGHTER_NONE;
    ExportMenu.Enabled := False;
  end;
end;

procedure TForm1.PasteMenuClick(Sender: TObject);
begin
  SynEdit1.PasteFromClipboard;
end;

procedure TForm1.PersSelMenuClick(Sender: TObject);
begin

end;

procedure TForm1.RecMenu1Click(Sender: TObject);
var
  Num: PtrInt;
begin
  if Sender is TMenuItem then
  begin
    Num := TMenuItem(Sender).Tag;
    if (Num >= 0) and (Num < RecFileList.Count) then
    begin
      FFileName := RecFileList[Num];
      LoadFile;
    end;
  end;
end;

procedure TForm1.RedoMenuClick(Sender: TObject);
begin
  SynEdit1.Redo;
end;

procedure TForm1.ReplaceMenuClick(Sender: TObject);
begin
  SearchReplaceWin.SynEdit1 := SynEdit1;
  SearchReplaceWin.StartReq(True);
end;

procedure TForm1.SearchAgainMenuClick(Sender: TObject);
begin
  SearchReplaceWin.SearchAgainClick(Sender);
end;

procedure TForm1.SearchMenuClick(Sender: TObject);
begin
  SearchReplaceWin.SynEdit1 := SynEdit1;
  SearchReplaceWin.StartReq(False);
end;

procedure TForm1.SelAllMenuClick(Sender: TObject);
begin
  SynEdit1.SelectAll;
end;

procedure TForm1.NewMenuClick(Sender: TObject);
begin
  FFilename := '';
  SynEdit1.Lines.Clear;
  Caption := Progname + ' - No File Loaded';
  ResetChanged;
end;

procedure TForm1.OpenMenuClick(Sender: TObject);
begin
  {$ifdef HASAMIGA}
  OpenDialog1.Filter:='#?';
  {$endif}
  OpenDialog1.InitialDir:= Prefs.InitialDir;
  if OpenDialog1.InitialDir = '' then
    OpenDialog1.InitialDir := 'Sys:';
  if OpenDialog1.Execute then
  begin
    FFilename := OpenDialog1.FileName;
    LoadFile;
    Prefs.InitialDir := ExtractFilePath(OpenDialog1.FileName);
  end;
end;

procedure TForm1.CMenuClick(Sender: TObject);
begin
  if CMenu.Checked then
  begin
    SynEdit1.Highlighter := SynCppSyn1;
    Prefs.DefHighlighter := HIGHLIGHTER_C;
    ExportMenu.Enabled := True;
  end;
end;

procedure TForm1.AutoMenuClick(Sender: TObject);
begin
  Prefs.AutoHighlighter := AutoMenu.Checked;
end;

procedure TForm1.CopyMenuClick(Sender: TObject);
begin
  SynEdit1.CopyToClipboard;
end;

procedure TForm1.CutMenuClick(Sender: TObject);
begin
  SynEdit1.CutToClipboard;
end;

procedure TForm1.PascalMenuClick(Sender: TObject);
begin
  if PascalMenu.Checked then
  begin
    SynEdit1.Highlighter := SynPasSyn1;
    Prefs.DefHighlighter := HIGHLIGHTER_PASCAL;
    ExportMenu.Enabled := True;
  end;
end;

procedure TForm1.QuitMenuClick(Sender: TObject);
begin
  SynEdit1.Lines.Clear;
  SynEdit1.SelStart := 0;
  SynEdit1.SelEnd := 0;
  Close;
end;

procedure TForm1.SaveAsMenuClick(Sender: TObject);
begin
  SaveDialog1.InitialDir:= ExtractFilePath(FFilename);
  if SaveDialog1.InitialDir = '' then
    SaveDialog1.InitialDir := Prefs.InitialDir;
  SaveDialog1.FileName:= ExtractFileName(FFilename);
  if SaveDialog1.Execute then
  begin
    FFilename := SaveDialog1.FileName;
    SynEdit1.Lines.SaveToFile(FFilename);
    Caption := Progname + ' - ' + ExtractFileName(FFilename);
    AddNewRecent(FFilename);
    ResetChanged;
  end;
end;

procedure TForm1.SaveMenuClick(Sender: TObject);
begin
  if FFilename <> '' then
  begin
    SynEdit1.Lines.SaveToFile(FFilename);
    Caption := Progname + ' - ' + ExtractFileName(FFilename);
    ResetChanged;
    SynEdit1.MarkTextAsSaved;
  end else
    SaveAsMenuClick(Sender);
end;

procedure TForm1.ShowNumMenuClick(Sender: TObject);
begin
  Prefs.LineNumbers := ShowNumMenu.Checked;
  SynEdit1.Gutter.Parts[0].Visible:= ShowNumMenu.Checked;
  SynEdit1.Gutter.Parts[1].Visible:= ShowNumMenu.Checked;
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
  end;
end;

procedure TForm1.SynEdit1ReplaceText(Sender: TObject; const ASearch,
  AReplace: string; Line, Column: integer; var ReplaceAction: TSynReplaceAction
  );
var
  Res: TModalResult;
begin
  Res := ReplaceReqUnit.ReplaceRequest.StartReq('Replace this occurence?');
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
  CoordPanel.Caption := IntToStr(SynEdit1.CaretX) + ', ' + IntToStr(SynEdit1.CaretY);
  ChangedPanel.Caption := ifthen(SynEdit1.Modified, 'Changed', '');
  UndoMenu.Enabled := SynEdit1.CanUndo;
  RedoMenu.Enabled := SynEdit1.CanRedo;
  PasteMenu.Enabled := SynEdit1.CanPaste;
end;

procedure TForm1.UndoMenuClick(Sender: TObject);
begin
  SynEdit1.Undo;
end;

procedure TForm1.ResetChanged;
begin
  ChangedStamp := SynEdit1.ChangeStamp;
  SynEdit1.Modified := False;
  ChangedPanel.Caption := ifthen(SynEdit1.Modified, 'Changed', '');
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
    Prefs.InitialDir := ExtractFilePath(FFileName);
  end;
end;

procedure TForm1.AutoHighlighter;
var
  Ext: String;
  i: Integer;
begin
  if AutoMenu.Checked then
  begin
    Ext := LowerCase(trim(ExtractFileExt(FFilename)));
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

procedure TForm1.LoadFile;
begin
  SynEdit1.Lines.LoadFromFile(FFilename);
  AutoHighlighter;
  Caption := Progname + ' - ' + ExtractFileName(FFilename);
  AddNewRecent(FFilename);
  ResetChanged;
  Prefs.InitialDir := ExtractFilePath(FFileName);
end;

end.
