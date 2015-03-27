unit PrefsUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IniFiles, Forms;

const
  SECTION_GENERAL = 'General';
  SECTION_FILES = 'Files';
  SECTION_HIGHLIGHTER = 'Highlighter';
  SECTION_SEARCH = 'Search';
  SECTION_SEARCHHIST = 'SearchHistory';
  SECTION_REPLACEHIST = 'ReplaceHistory';

  HIGHLIGHTER_NONE = 0;
  HIGHLIGHTER_C = 1;
  HIGHLIGHTER_PASCAL = 2;

type

  { TPrefs }

  TPrefs = class
  private
    IniFile: TIniFile;
    function GetAutoHighlighter: boolean;
    function GetBookmarks: boolean;
    function GetCaseSens: boolean;
    function GetDefHighlighter: integer;
    function GetFullPath: boolean;
    function GetHeight: integer;
    function GetInitialDir: string;
    function GetLineNumbers: boolean;
    function GetPromptReplace: boolean;
    function GetRecFile(Idx: integer): string;
    function GetRegExp: boolean;
    function GetSearchBegin: boolean;
    function GetSearchFwd: boolean;
    function GetSearchGlobal: boolean;
    function GetWholeWord: boolean;
    function GetWidth: integer;
    function GetXPos: integer;
    function GetYPos: integer;
    procedure SetAutoHighlighter(AValue: boolean);
    procedure SetBookmarks(AValue: boolean);
    procedure SetCaseSens(AValue: boolean);
    procedure SetFullPath(AValue: boolean);
    procedure SetHeight(AValue: integer);
    procedure SetHighlighter(AValue: integer);
    procedure SetInitialDir(AValue: string);
    procedure SetLineNumbers(AValue: boolean);
    procedure SetPromptReplace(AValue: boolean);
    procedure SetRecFile(Idx: integer; AValue: string);
    procedure SetRegExp(AValue: boolean);
    procedure SetSearchBegin(AValue: boolean);
    procedure SetSearchFwd(AValue: boolean);
    procedure SetSearchGlobal(AValue: boolean);
    procedure SetWholeWord(AValue: boolean);
    procedure SetWidth(AValue: integer);
    procedure SetXPos(AValue: integer);
    procedure SetYPos(AValue: integer);
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetSearchHist(S: TStringList; AsReplace: Boolean);
    procedure GetSearchHist(S: TStringList; AsReplace: Boolean);

    property XPos: integer read GetXPos write SetXPos;
    property YPos: integer read GetYPos write SetYPos;
    property Width: integer read GetWidth write SetWidth;
    property Height: integer read GetHeight write SetHeight;
    property RecentFiles[Idx: integer]: string read GetRecFile write SetRecFile;
    property AutoHighlighter: boolean read GetAutoHighlighter write SetAutoHighlighter;
    property LineNumbers: boolean read GetLineNumbers write SetLineNumbers;
    property Bookmarks: boolean read GetBookmarks write SetBookmarks;
    property DefHighlighter: integer read GetDefHighlighter write SetHighlighter;
    property InitialDir: string read GetInitialDir write SetInitialDir;
    // Search requester
    property CaseSens: boolean read GetCaseSens write SetCaseSens;
    property WholeWord: boolean read GetWholeWord write SetWholeWord;
    property RegExp: boolean read GetRegExp write SetRegExp;
    property SearchFwd: boolean read GetSearchFwd write SetSearchFwd;
    property SearchBegin: boolean read GetSearchBegin write SetSearchBegin;
    property SearchGlobal: boolean read GetSearchGlobal write SetSearchGlobal;
    property PromptReplace: boolean read GetPromptReplace write SetPromptReplace;
    property FullPath: boolean read GetFullPath write SetFullPath;
  end;

var
  Prefs: TPrefs;

implementation

{ TPrefs }

procedure TPrefs.SetXPos(AValue: integer);
begin
  IniFile.WriteInteger(SECTION_GENERAL, 'XPos', AValue);
end;

procedure TPrefs.SetYPos(AValue: integer);
begin
  IniFile.WriteInteger(SECTION_GENERAL, 'YPos', AValue);
end;

procedure TPrefs.SetWidth(AValue: integer);
begin
  IniFile.WriteInteger(SECTION_GENERAL, 'Width', AValue);
end;

procedure TPrefs.SetHeight(AValue: integer);
begin
  IniFile.WriteInteger(SECTION_GENERAL, 'Height', AValue);
end;

procedure TPrefs.SetHighlighter(AValue: integer);
begin
  IniFile.WriteInteger(SECTION_HIGHLIGHTER, 'Default', AValue);
end;

procedure TPrefs.SetInitialDir(AValue: string);
begin
  if AValue <> '' then
    IniFile.WriteString(SECTION_FILES, 'InitialDir', AValue);
end;

procedure TPrefs.SetLineNumbers(AValue: boolean);
begin
  IniFile.WriteBool(SECTION_GENERAL, 'LineNumbers', AValue);
end;

procedure TPrefs.SetPromptReplace(AValue: boolean);
begin
  IniFile.WriteBool(SECTION_SEARCH, 'PromptReplace', AValue);
end;

procedure TPrefs.SetAutoHighlighter(AValue: boolean);
begin
  IniFile.WriteBool(SECTION_HIGHLIGHTER, 'Auto', AValue);
end;

procedure TPrefs.SetBookmarks(AValue: boolean);
begin
  IniFile.WriteBool(SECTION_GENERAL, 'Bookmarks', AValue);
end;

procedure TPrefs.SetCaseSens(AValue: boolean);
begin
  IniFile.WriteBool(SECTION_SEARCH, 'CaseSensitive', AValue);
end;

procedure TPrefs.SetFullPath(AValue: boolean);
begin
  IniFile.WriteBool(SECTION_GENERAL, 'FullPath', AValue);
end;

procedure TPrefs.SetRecFile(Idx: integer; AValue: string);
begin
  IniFile.WriteString(SECTION_FILES, 'Recent_' + IntToStr(Idx), AValue);
end;

procedure TPrefs.SetRegExp(AValue: boolean);
begin
  IniFile.WriteBool(SECTION_SEARCH, 'RegularExpression', AValue);
end;

procedure TPrefs.SetSearchBegin(AValue: boolean);
begin
  IniFile.WriteBool(SECTION_SEARCH, 'FromBegin', AValue);
end;

procedure TPrefs.SetSearchFwd(AValue: boolean);
begin
  IniFile.WriteBool(SECTION_SEARCH, 'Forward', AValue);
end;

procedure TPrefs.SetSearchGlobal(AValue: boolean);
begin
  IniFile.WriteBool(SECTION_SEARCH, 'Global', AValue);
end;

procedure TPrefs.SetWholeWord(AValue: boolean);
begin
  IniFile.WriteBool(SECTION_SEARCH, 'WholeWord', AValue);
end;

function TPrefs.GetXPos: integer;
begin
  Result := IniFile.ReadInteger(SECTION_GENERAL, 'XPos', 25);
end;

function TPrefs.GetWidth: integer;
begin
  Result := IniFile.ReadInteger(SECTION_GENERAL, 'Width', 800);
end;

function TPrefs.GetHeight: integer;
begin
  Result := IniFile.ReadInteger(SECTION_GENERAL, 'Height', 500);
end;

function TPrefs.GetInitialDir: string;
begin
  Result := IniFile.ReadString(SECTION_FILES, 'InitialDir', '');
end;

function TPrefs.GetLineNumbers: boolean;
begin
  Result := IniFile.ReadBool(SECTION_GENERAL, 'LineNumbers', True);
end;

function TPrefs.GetPromptReplace: boolean;
begin
  Result := IniFile.ReadBool(SECTION_SEARCH, 'PromptReplace', True);
end;

function TPrefs.GetAutoHighlighter: boolean;
begin
  Result := IniFile.ReadBool(SECTION_HIGHLIGHTER, 'Auto', True);
end;

function TPrefs.GetBookmarks: boolean;
begin
  Result := IniFile.ReadBool(SECTION_GENERAL, 'Bookmarks', True);
end;

function TPrefs.GetCaseSens: boolean;
begin
  Result := IniFile.ReadBool(SECTION_SEARCH, 'CaseSensitive', False);
end;

function TPrefs.GetDefHighlighter: integer;
begin
  Result := IniFile.ReadInteger(SECTION_HIGHLIGHTER, 'Default', HIGHLIGHTER_PASCAL);
end;

function TPrefs.GetFullPath: boolean;
begin
  Result := IniFile.ReadBool(SECTION_GENERAL, 'FullPath', False);
end;

function TPrefs.GetRecFile(Idx: integer): string;
begin
  Result := IniFile.ReadString(SECTION_FILES, 'Recent_' + IntToStr(Idx), '');
end;

function TPrefs.GetRegExp: boolean;
begin
  Result := IniFile.ReadBool(SECTION_SEARCH, 'RegularExpression', False);
end;

function TPrefs.GetSearchBegin: boolean;
begin
  Result := IniFile.ReadBool(SECTION_SEARCH, 'FromBegin', True);
end;

function TPrefs.GetSearchFwd: boolean;
begin
  Result := IniFile.ReadBool(SECTION_SEARCH, 'Forward', True);
end;

function TPrefs.GetSearchGlobal: Boolean;
begin
  Result := IniFile.ReadBool(SECTION_SEARCH, 'Global', True);
end;

function TPrefs.GetWholeWord: Boolean;
begin
  Result := IniFile.ReadBool(SECTION_SEARCH, 'WholeWord', False);
end;

function TPrefs.GetYPos: integer;
begin
  Result := IniFile.ReadInteger(SECTION_GENERAL, 'YPos', 70);
end;

constructor TPrefs.Create;
begin
  IniFile := TIniFile.Create(ChangeFileExt(Application.ExeName, '.prefs'));
end;

destructor TPrefs.Destroy;
begin
  IniFile.Free;
  inherited Destroy;
end;

procedure TPrefs.SetSearchHist(S: TStringList; AsReplace: Boolean);
var
  i: Integer;
  Section: string;
begin
  if AsReplace then
    Section := SECTION_REPLACEHIST
  else
    Section := SECTION_SEARCHHIST;
  IniFile.EraseSection(Section);
  IniFile.WriteInteger(Section, 'Count', S.Count);
  for i := 0 to S.Count - 1 do
  begin
    IniFile.WriteString(Section, 'Search_' + IntToStr(i), s.Strings[i]);
  end;
end;

procedure TPrefs.GetSearchHist(S: TStringList; AsReplace: Boolean);
var
  Count: LongInt;
  i: Integer;
  Section: String;
begin
  if AsReplace then
    Section := SECTION_REPLACEHIST
  else
    Section := SECTION_SEARCHHIST;
  Count := IniFile.ReadInteger(Section, 'Count', 0);
  for i := 0 to Count - 1 do
  begin
    S.Add(IniFile.ReadString(Section, 'Search_' + IntToStr(i),''));
  end;
end;

initialization
  Prefs := TPrefs.Create;

finalization
  Prefs.Free;
end.
