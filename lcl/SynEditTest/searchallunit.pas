unit SearchAllUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fgl, FileUtil, SynEdit, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, EditBtn;

type

  { TSearchAllForm }

  TSearchAllForm = class(TForm)
    FilePattern: TEdit;
    SettingsPanel: TGroupBox;
    ScopPanel: TGroupBox;
    Label8: TLabel;
    Label9: TLabel;
    UseRecursive: TCheckBox;
    DirPanel: TPanel;
    SearchButton: TButton;
    Button2: TButton;
    ChooseDirectory: TRadioButton;
    ChooseProject: TRadioButton;
    DirectoryEdit1: TDirectoryEdit;
    SAllHistoryBox: TListBox;
    HistoryLabel: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Panel1: TPanel;
    ChooseOpenFiles: TRadioButton;
    Panel2: TPanel;
    SearchEdit: TEdit;
    UseCaseSen: TCheckBox;
    UseRegExp: TCheckBox;
    UseWholeWord: TCheckBox;
    procedure ChooseDirectoryClick(Sender: TObject);
    procedure ChooseOpenFilesClick(Sender: TObject);
    procedure ChooseProjectClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure SAllHistoryBoxDblClick(Sender: TObject);
    procedure SearchButtonClick(Sender: TObject);
    procedure SearchEditEditingDone(Sender: TObject);
    procedure UseCaseSenClick(Sender: TObject);
    procedure UseRegExpClick(Sender: TObject);
    procedure UseWholeWordClick(Sender: TObject);
  private
    procedure SearchOpenEditors;
    procedure SearchDirectory;
  public

  end;

var
  SearchAllForm: TSearchAllForm;

implementation

uses
  MainUnit, SynEditSearch, FrameUnit, SearchAllResultsUnit, PrefsUnit, SearchReplaceUnit;

{$R *.lfm}

{ TSearchAllForm }

procedure TSearchAllForm.SearchButtonClick(Sender: TObject);
var
  SearchString: TCaption;
  Idx: integer;
begin
  SearchReplaceWin.SearchEdit.Text := SearchEdit.Text;
  SearchString := SearchEdit.Text;
  if SearchString <> '' then
  begin
    Idx := SearchReplaceWin.SearchHist.IndexOf(SearchString);
    if Idx >= 0 then
      SearchReplaceWin.SearchHist.Delete(Idx);
    SearchReplaceWin.SearchHist.Insert(0, SearchString);
    while SearchReplaceWin.SearchHist.Count > 100 do
      SearchReplaceWin.SearchHist.Delete(SearchReplaceWin.SearchHist.Count - 1);
  end;
  if ChooseOpenFiles.Checked then
  begin
    SearchOpenEditors;
    ModalResult := mrYes;
  end;
  if ChooseDirectory.Checked then
  begin
    SearchDirectory;
    ModalResult := mrYes;
  end;
end;

procedure TSearchAllForm.SearchEditEditingDone(Sender: TObject);
begin
  {$ifdef AROS}
  SearchButtonClick(Sender);
  {$endif}
end;

procedure TSearchAllForm.UseCaseSenClick(Sender: TObject);
begin
  Prefs.CaseSens := UseCaseSen.Checked;
end;

procedure TSearchAllForm.UseRegExpClick(Sender: TObject);
begin
  Prefs.RegExp := UseRegExp.Checked;
end;

procedure TSearchAllForm.UseWholeWordClick(Sender: TObject);
begin
  Prefs.WholeWord := UseWholeWord.Checked;
end;

procedure TSearchAllForm.FormShow(Sender: TObject);
var
  FilePath: string;
begin
  FilePattern.Text := Prefs.SearchFilePattern;
  if MainWindow.CurEditor.SelText <> '' then
    SearchEdit.Text := MainWindow.CurEditor.SelText;
  FilePath := ExtractFilePath(MainWindow.CurFrame.Filename);
  if FilePath = '' then
    FilePath := ExtractFilePath(Application.ExeName);
  if FilePath = '' then
    FilePath := GetCurrentDir;
  DirectoryEdit1.Directory := FilePath;
  UseCaseSen.Checked := Prefs.CaseSens;
  UseRegExp.Checked := Prefs.RegExp;
  UseWholeWord.Checked := Prefs.WholeWord;
  UseRecursive.Checked := Prefs.SAllRecursive;
  case Prefs.SearchAllMode of
    0: ChooseOpenFiles.Checked := True;
    1: ChooseDirectory.Checked := True;
      //2: ChooseProject.Checked:= True;
    else
      ChooseOpenFiles.Checked := True;
  end;
  DirPanel.Enabled := ChooseDirectory.Checked;
  if SearchReplaceWin.Visible then
    SearchReplaceWin.Close;
  //if SAllHistoryBox.Items.Count = 0 then
  SAllHistoryBox.Items.Assign(SearchReplaceWin.SearchHist);
end;

procedure TSearchAllForm.SAllHistoryBoxDblClick(Sender: TObject);
begin
  if (SAllHistoryBox.ItemIndex >= 0) and (SAllHistoryBox.ItemIndex < SAllHistoryBox.Items.Count) then
  begin
    SearchEdit.Text := SAllHistoryBox.Items[SAllHistoryBox.ItemIndex];
  end;
end;

procedure TSearchAllForm.ChooseDirectoryClick(Sender: TObject);
begin
  DirPanel.Enabled := ChooseDirectory.Checked;
end;

procedure TSearchAllForm.ChooseOpenFilesClick(Sender: TObject);
begin
  DirPanel.Enabled := ChooseDirectory.Checked;
end;

procedure TSearchAllForm.ChooseProjectClick(Sender: TObject);
begin
  DirPanel.Enabled := ChooseDirectory.Checked;
end;

procedure TSearchAllForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Prefs.SearchFilePattern := FilePattern.Text;
  Prefs.CaseSens := UseCaseSen.Checked;
  Prefs.RegExp := UseRegExp.Checked;
  Prefs.WholeWord := UseWholeWord.Checked;
  Prefs.SAllRecursive := UseRecursive.Checked;
  if ChooseOpenFiles.Checked then
    Prefs.SearchAllMode := 0;
  if ChooseDirectory.Checked then
    Prefs.SearchAllMode := 1;
  //  if ChooseProject.Checked then
  //    Prefs.SearchAllMode := 2;
end;

procedure TSearchAllForm.SearchOpenEditors;
var
  fTSearch: TSynEditSearch;
  i: integer;
  Editor: TSynEdit;
  FSP: TPoint;
  FEP: TPoint;
  EndPoint: TPoint;
  NewResultList: TResultList;
  NewResult: TSearchResult;
begin
  fTSearch := TSynEditSearch.Create;
  try
    fTSearch.ClearResults;
    fTSearch.Sensitive := UseCaseSen.Checked;
    fTSearch.Whole := UseWholeWord.Checked;
    fTSearch.RegularExpressions := UseRegExp.Checked;
    fTSearch.Backwards := False;
    fTSearch.Pattern := SearchEdit.Text;
    NewResultList := TResultList.Create;
    for i := 0 to MainWindow.Tabs.TabCount - 1 do
    begin
      Editor := TEditorFrame(MainWindow.Tabs.GetTabData(i).TabObject).Editor;
      FEP := Point(0, 0);
      EndPoint.Y := Editor.Lines.Count;
      EndPoint.X := Length(Editor.Lines[EndPoint.Y - 1]) + 1;
      try
        while fTSearch.FindNextOne(Editor.Lines, FEP, EndPoint, FSP, FEP, False) do
        begin
          NewResult := TSearchResult.Create;
          NewResult.Frame := TEditorFrame(MainWindow.Tabs.GetTabData(i).TabObject);
          NewResult.StartPos := FSP;
          NewResult.EndPos := FEP;
          NewResult.TextLine := Editor.Lines[FSP.Y];
          NewResultList.Add(NewResult);
        end;
      except
        ;
      end;
    end;
    SearchResultsWin.ResultTabs.AddTab(-1, fTSearch.Pattern + '(' +
      IntToStr(NewResultList.Count) + ')', NewResultList);
    SearchResultsWin.TabClickEvent(nil);
    SearchResultsWin.Show;
  finally
    fTSearch.Free;
  end;
end;

procedure TSearchAllForm.SearchDirectory;
var
  Patterns: TStringList;
  Files: TStringList;
  Dirs: TStringList;
  i: integer;
  Directory: string;
  Pattern: string;
  fTSearch: TSynEditSearch;
  NewText: TStringList;
  FEP: TPoint;
  FSP: TPoint;
  NewResultList: TResultList;
  NewResult: TSearchResult;
  Filename: string;
  EndPoint: TPoint;

  procedure SearchInsideDir(Dirname: string);
  var
    Rslt: TSearchRec;
  begin
    if UseRecursive.Checked then
    begin
      if FindFirst(Dirname + AllFilesMask, faDirectory, Rslt) = 0 then
      begin
        repeat
          if (Rslt.Attr and faDirectory) = faDirectory then
          begin  // its a Directory
            if not ((Rslt.Name = '.') or (Rslt.Name = '..')) then
              Dirs.Add(Dirname + Rslt.Name);
          end;
        until FindNext(Rslt) <> 0;
      end;
      FindClose(Rslt);
    end;
    if FindFirst(Dirname + Pattern, faAnyFile, Rslt) = 0 then
    begin
      repeat
        Files.Add(Dirname + Rslt.Name);
      until FindNext(Rslt) <> 0;
    end;
    FindClose(Rslt);
  end;

begin
  Patterns := TStringList.Create;
  ExtractStrings(['|'], [], PChar(FilePattern.Text), Patterns);
  Files := TStringList.Create;
  Dirs := TStringList.Create;
  for i := 0 to Patterns.Count - 1 do
  begin
    Pattern := Patterns[i];
    Dirs.Add(DirectoryEdit1.Directory);
    while Dirs.Count > 0 do
    begin
      Directory := IncludeTrailingPathDelimiter(Dirs.Strings[0]);
      Dirs.Delete(0);
      SearchInsideDir(Directory);
    end;
  end;
  // Search for files
  fTSearch := TSynEditSearch.Create;
  try
    fTSearch.ClearResults;
    fTSearch.Sensitive := UseCaseSen.Checked;
    fTSearch.Whole := UseWholeWord.Checked;
    fTSearch.RegularExpressions := UseRegExp.Checked;
    fTSearch.Backwards := False;
    fTSearch.Pattern := SearchEdit.Text;
    NewResultList := TResultList.Create;
    for i := 0 to Files.Count - 1 do
    begin
      Filename := Files[i];
      NewText := TStringList.Create;
      try
        NewText.LoadFromFile(Filename);
      except
        Continue;
      end;
      FEP := Point(1, 1);
      EndPoint.Y := NewText.Count;
      EndPoint.X := Length(NewText[EndPoint.Y - 1]) + 1;
      fTSearch.ClearResults;
      try
        while fTSearch.FindNextOne(NewText, FEP, EndPoint, FSP, FEP, False) do
        begin
          NewResult := TSearchResult.Create;
          NewResult.Frame := nil;
          NewResult.Filename := Files[i];
          NewResult.StartPos := FSP;
          NewResult.EndPos := FEP;
          NewResult.TextLine := NewText.strings[FSP.Y - 1];
          NewResultList.Add(NewResult);
        end;
      except
        ;
      end;
      NewText.Free;
    end;
    SearchResultsWin.ResultTabs.AddTab(-1, fTSearch.Pattern + '(' +
      IntToStr(NewResultList.Count) + ')', NewResultList);
    SearchResultsWin.ResultTabs.TabIndex := SearchResultsWin.ResultTabs.TabCount - 1;
    SearchResultsWin.Show;
  finally
    fTSearch.Free;
  end;
  Dirs.Free;
  Files.Free;
  Patterns.Free;
end;

end.
