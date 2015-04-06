unit PrefsUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IniFiles, Forms, Graphics;

const
  SECTION_GENERAL = 'General';
  SECTION_FILES = 'Files';
  SECTION_HIGHLIGHTER = 'Highlighter';
  SECTION_SEARCH = 'Search';
  SECTION_SEARCHHIST = 'SearchHistory';
  SECTION_REPLACEHIST = 'ReplaceHistory';
  SECTION_COLORS = 'Colors';
  SECTION_SHORTCUTS = 'ShortCuts';

  HIGHLIGHTER_NONE = 0;
  HIGHLIGHTER_C = 1;
  HIGHLIGHTER_PASCAL = 2;
  HIGHLIGHTER_HTML = 3;

type

  { TPrefs }

  TPrefs = class
  private

    function GetAutoHighlighter: boolean;
    function GetAutoIndent: boolean;
    function GetBlockOverwrite: Boolean;
    function GetBookmarks: boolean;
    function GetBracketColor: TColor;
    function GetCaseSens: boolean;
    function GetChangeIndicator: boolean;
    function GetDblSelLine: Boolean;
    function GetDefHighlighter: integer;
    function GetEdBgColor: TColor;
    function GetEdTextColor: TColor;
    function GetFullPath: boolean;
    function GetHeight: integer;
    function GetIndentWidth: Integer;
    function GetInitialDir: string;
    function GetLineNumbers: boolean;
    function GetLineSkipNum: integer;
    function GetOpenNewTab: Boolean;
    function GetPersistentBlock: Boolean;
    function GetPromptReplace: boolean;
    function GetRecFile(Idx: integer): string;
    function GetRegExp: boolean;
    function GetSAllRecursive: boolean;
    function GetSearchAllMode: Integer;
    function GetSearchBegin: boolean;
    function GetSearchFilePattern: string;
    function GetSearchFwd: boolean;
    function GetSearchGlobal: boolean;
    function GetTabIndent: Boolean;
    function GetTabsToSpaces: boolean;
    function GetTabWidth: Integer;
    function GetTrimSpaces: boolean;
    function GetWholeWord: boolean;
    function GetWidth: integer;
    function GetXPos: integer;
    function GetYPos: integer;
    function GetSAllHeight: integer;
    function GetSAllWidth: integer;
    function GetSAllXPos: integer;
    function GetSAllYPos: integer;
    procedure SetAutoHighlighter(AValue: boolean);
    procedure SetAutoIndent(AValue: boolean);
    procedure SetBlockOverwrite(AValue: Boolean);
    procedure SetBookmarks(AValue: boolean);
    procedure SetBracketColor(AValue: TColor);
    procedure SetCaseSens(AValue: boolean);
    procedure SetChangeIndicator(AValue: boolean);
    procedure SetDblSelLine(AValue: Boolean);
    procedure SetEdBgColor(AValue: TColor);
    procedure SetEdTextColor(AValue: TColor);
    procedure SetFullPath(AValue: boolean);
    procedure SetHeight(AValue: integer);
    procedure SetHighlighter(AValue: integer);
    procedure SetIndentWidth(AValue: Integer);
    procedure SetInitialDir(AValue: string);
    procedure SetLineNumbers(AValue: boolean);
    procedure SetLineSkipNum(AValue: integer);
    procedure SetOpenNewTab(AValue: Boolean);
    procedure SetPersistentBlock(AValue: Boolean);
    procedure SetPromptReplace(AValue: boolean);
    procedure SetRecFile(Idx: integer; AValue: string);
    procedure SetRegExp(AValue: boolean);
    procedure SetSAllRecursive(AValue: boolean);
    procedure SetSearchAllMode(AValue: Integer);
    procedure SetSearchBegin(AValue: boolean);
    procedure SetSearchFilePattern(AValue: string);
    procedure SetSearchFwd(AValue: boolean);
    procedure SetSearchGlobal(AValue: boolean);
    procedure SetTabIndent(AValue: Boolean);
    procedure SetTabsToSpaces(AValue: boolean);
    procedure SetTabWidth(AValue: Integer);
    procedure SetTrimSpaces(AValue: boolean);
    procedure SetWholeWord(AValue: boolean);
    procedure SetWidth(AValue: integer);
    procedure SetXPos(AValue: integer);
    procedure SetYPos(AValue: integer);
    procedure SetSAllHeight(AValue: integer);
    procedure SetSAllWidth(AValue: integer);
    procedure SetSAllXPos(AValue: integer);
    procedure SetSAllYPos(AValue: integer);
  public
    IniFile: TIniFile;
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
    property DefHighlighter: integer read GetDefHighlighter write SetHighlighter;

    property TabsToSpaces: boolean read GetTabsToSpaces write SetTabsToSpaces;
    property TabWidth: Integer read GetTabWidth write SetTabWidth;
    property TabIndent: boolean read GetTabIndent write SetTabIndent;
    property AutoIndent: boolean read GetAutoIndent write SetAutoIndent;
    property IndentWidth: Integer read GetIndentWidth write SetIndentWidth;
    property TrimSpaces: boolean read GetTrimSpaces write SetTrimSpaces;
    // sidebar
    property LineNumbers: boolean read GetLineNumbers write SetLineNumbers;
    property Bookmarks: boolean read GetBookmarks write SetBookmarks;
    property LineSkipNum: integer read GetLineSkipNum write SetLineSkipNum;
    property ChangeIndicator: boolean read GetChangeIndicator write SetChangeIndicator;
    // File Handling
    property FullPath: boolean read GetFullPath write SetFullPath;
    property OpenNewTab: Boolean read GetOpenNewTab write SetOpenNewTab;
    // Selection
    property DblSelLine: Boolean read GetDblSelLine write SetDblSelLine;
    property BlockOverwrite: Boolean read GetBlockOverwrite write SetBlockOverwrite;
    property PersistentBlock: Boolean read GetPersistentBlock write SetPersistentBlock;
    //
    property InitialDir: string read GetInitialDir write SetInitialDir;
    // Search requester
    property CaseSens: boolean read GetCaseSens write SetCaseSens;
    property WholeWord: boolean read GetWholeWord write SetWholeWord;
    property RegExp: boolean read GetRegExp write SetRegExp;
    property SearchFwd: boolean read GetSearchFwd write SetSearchFwd;
    property SearchBegin: boolean read GetSearchBegin write SetSearchBegin;
    property SearchGlobal: boolean read GetSearchGlobal write SetSearchGlobal;
    property PromptReplace: boolean read GetPromptReplace write SetPromptReplace;

    // SearchAll Requester
    property SearchAllMode: Integer read GetSearchAllMode write SetSearchAllMode;
    property SAllXPos: integer read GetSAllXPos write SetSAllXPos;
    property SAllYPos: integer read GetSAllYPos write SetSAllYPos;
    property SAllWidth: integer read GetSAllWidth write SetSAllWidth;
    property SAllHeight: integer read GetSAllHeight write SetSAllHeight;
    property SAllRecursive: boolean read GetSAllRecursive write SetSAllRecursive;
    property SearchFilePattern: string read GetSearchFilePattern write SetSearchFilePattern;
    // Colors
    property EdBgColor: TColor read GetEdBgColor write SetEdBgColor;
    property EdTextColor: TColor read GetEdTextColor write SetEdTextColor;
    property BracketColor: TColor read GetBracketColor write SetBracketColor;
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

procedure TPrefs.SetSAllXPos(AValue: integer);
begin
  IniFile.WriteInteger(SECTION_SEARCH, 'SAllXPos', AValue);
end;

procedure TPrefs.SetSAllYPos(AValue: integer);
begin
  IniFile.WriteInteger(SECTION_SEARCH, 'SAllYPos', AValue);
end;

procedure TPrefs.SetSAllWidth(AValue: integer);
begin
  IniFile.WriteInteger(SECTION_SEARCH, 'SAllWidth', AValue);
end;

procedure TPrefs.SetSAllHeight(AValue: integer);
begin
  IniFile.WriteInteger(SECTION_SEARCH, 'SAllHeight', AValue);
end;

procedure TPrefs.SetHighlighter(AValue: integer);
begin
  IniFile.WriteInteger(SECTION_HIGHLIGHTER, 'Default', AValue);
end;

procedure TPrefs.SetIndentWidth(AValue: Integer);
begin
  IniFile.WriteInteger(SECTION_GENERAL, 'IndentWidth', AValue);
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

procedure TPrefs.SetLineSkipNum(AValue: integer);
begin
  IniFile.WriteInteger(SECTION_GENERAL, 'LineSkipNum', AValue);
end;

procedure TPrefs.SetOpenNewTab(AValue: Boolean);
begin
  IniFile.WriteBool(SECTION_GENERAL, 'OpenNewTab', AValue);
end;

procedure TPrefs.SetPersistentBlock(AValue: Boolean);
begin
  IniFile.WriteBool(SECTION_GENERAL, 'PersistentBlock', AValue);
end;

procedure TPrefs.SetPromptReplace(AValue: boolean);
begin
  IniFile.WriteBool(SECTION_SEARCH, 'PromptReplace', AValue);
end;

procedure TPrefs.SetAutoHighlighter(AValue: boolean);
begin
  IniFile.WriteBool(SECTION_HIGHLIGHTER, 'Auto', AValue);
end;

procedure TPrefs.SetAutoIndent(AValue: boolean);
begin
  IniFile.WriteBool(SECTION_GENERAL, 'AutoIndent', AValue);
end;

procedure TPrefs.SetBlockOverwrite(AValue: Boolean);
begin
  IniFile.WriteBool(SECTION_GENERAL, 'BlockOverwrite', AValue);
end;

procedure TPrefs.SetBookmarks(AValue: boolean);
begin
  IniFile.WriteBool(SECTION_GENERAL, 'Bookmarks', AValue);
end;

procedure TPrefs.SetBracketColor(AValue: TColor);
begin
  IniFile.WriteInteger(SECTION_COLORS, 'Bracket', AValue);
end;

procedure TPrefs.SetCaseSens(AValue: boolean);
begin
  IniFile.WriteBool(SECTION_SEARCH, 'CaseSensitive', AValue);
end;

procedure TPrefs.SetChangeIndicator(AValue: boolean);
begin
  IniFile.WriteBool(SECTION_GENERAL, 'ChangeIndicator', AValue);
end;

procedure TPrefs.SetDblSelLine(AValue: Boolean);
begin
  IniFile.WriteBool(SECTION_GENERAL, 'DblClickSelLine', AValue);
end;

procedure TPrefs.SetEdBgColor(AValue: TColor);
begin
  IniFile.WriteInteger(SECTION_COLORS, 'EditorBackground', AValue);
end;

procedure TPrefs.SetEdTextColor(AValue: TColor);
begin
  IniFile.WriteInteger(SECTION_COLORS, 'EditorText', AValue);
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

procedure TPrefs.SetSAllRecursive(AValue: boolean);
begin
  IniFile.WriteBool(SECTION_SEARCH, 'RecursiveSearch', AValue);
end;

procedure TPrefs.SetSearchAllMode(AValue: Integer);
begin
  IniFile.WriteInteger(SECTION_SEARCH, 'SearchAllMode', AValue);
end;

procedure TPrefs.SetSearchBegin(AValue: boolean);
begin
  IniFile.WriteBool(SECTION_SEARCH, 'FromBegin', AValue);
end;

procedure TPrefs.SetSearchFilePattern(AValue: string);
begin
  IniFile.WriteString(SECTION_SEARCH, 'FilePattern', AValue);
end;

procedure TPrefs.SetSearchFwd(AValue: boolean);
begin
  IniFile.WriteBool(SECTION_SEARCH, 'Forward', AValue);
end;

procedure TPrefs.SetSearchGlobal(AValue: boolean);
begin
  IniFile.WriteBool(SECTION_SEARCH, 'Global', AValue);
end;

procedure TPrefs.SetTabIndent(AValue: Boolean);
begin
  IniFile.WriteBool(SECTION_GENERAL, 'TabIndent', AValue);
end;

procedure TPrefs.SetTabsToSpaces(AValue: boolean);
begin
  IniFile.WriteBool(SECTION_GENERAL, 'TabsToSpaces', AValue);
end;

procedure TPrefs.SetTabWidth(AValue: Integer);
begin
  IniFile.WriteInteger(SECTION_GENERAL, 'TabWidth', AValue);
end;

procedure TPrefs.SetTrimSpaces(AValue: boolean);
begin
  IniFile.WriteBool(SECTION_GENERAL, 'TrimSpaces', AValue);
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

function TPrefs.GetIndentWidth: Integer;
begin
  Result := IniFile.ReadInteger(SECTION_GENERAL, 'IndentWidth', 2);
end;

function TPrefs.GetSAllXPos: integer;
begin
  Result := IniFile.ReadInteger(SECTION_SEARCH, 'SAllXPos', 25);
end;

function TPrefs.GetSAllYPos: integer;
begin
  Result := IniFile.ReadInteger(SECTION_SEARCH, 'SAllYPos', 550);
end;

function TPrefs.GetSAllWidth: integer;
begin
  Result := IniFile.ReadInteger(SECTION_SEARCH, 'SAllWidth', 800);
end;

function TPrefs.GetSAllHeight: integer;
begin
  Result := IniFile.ReadInteger(SECTION_SEARCH, 'SAllHeight', 200);
end;

function TPrefs.GetInitialDir: string;
begin
  Result := IniFile.ReadString(SECTION_FILES, 'InitialDir', '');
end;

function TPrefs.GetLineNumbers: boolean;
begin
  Result := IniFile.ReadBool(SECTION_GENERAL, 'LineNumbers', True);
end;

function TPrefs.GetLineSkipNum: integer;
begin
  Result := IniFile.ReadInteger(SECTION_GENERAL, 'LineSkipNum', 10);
end;

function TPrefs.GetOpenNewTab: Boolean;
begin
  Result := IniFile.ReadBool(SECTION_GENERAL, 'OpenNewTab', True);
end;

function TPrefs.GetPersistentBlock: Boolean;
begin
  Result := IniFile.ReadBool(SECTION_GENERAL, 'PersistentBlock', False);
end;

function TPrefs.GetPromptReplace: boolean;
begin
  Result := IniFile.ReadBool(SECTION_SEARCH, 'PromptReplace', True);
end;

function TPrefs.GetAutoHighlighter: boolean;
begin
  Result := IniFile.ReadBool(SECTION_HIGHLIGHTER, 'Auto', True);
end;

function TPrefs.GetAutoIndent: boolean;
begin
  Result := IniFile.ReadBool(SECTION_GENERAL, 'AutoIndent', True);
end;

function TPrefs.GetBlockOverwrite: Boolean;
begin
  Result := IniFile.ReadBool(SECTION_GENERAL, 'BlockOverwrite', True);
end;

function TPrefs.GetBookmarks: boolean;
begin
  Result := IniFile.ReadBool(SECTION_GENERAL, 'Bookmarks', True);
end;

function TPrefs.GetBracketColor: TColor;
begin
  Result := IniFile.ReadInteger(SECTION_COLORS, 'Bracket', clYellow);
end;

function TPrefs.GetCaseSens: boolean;
begin
  Result := IniFile.ReadBool(SECTION_SEARCH, 'CaseSensitive', False);
end;

function TPrefs.GetChangeIndicator: boolean;
begin
  Result := IniFile.ReadBool(SECTION_GENERAL, 'ChangeIndicator', True);
end;

function TPrefs.GetDblSelLine: Boolean;
begin
  Result := IniFile.ReadBool(SECTION_GENERAL, 'DblClickSelLine', False);
end;

function TPrefs.GetDefHighlighter: integer;
begin
  Result := IniFile.ReadInteger(SECTION_HIGHLIGHTER, 'Default', HIGHLIGHTER_PASCAL);
end;

function TPrefs.GetEdBgColor: TColor;
begin
  Result := IniFile.ReadInteger(SECTION_COLORS, 'EditorBackground', $FFFFFF);
end;

function TPrefs.GetEdTextColor: TColor;
begin
  Result := IniFile.ReadInteger(SECTION_COLORS, 'EditorText', $000000);
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

function TPrefs.GetSAllRecursive: boolean;
begin
  Result := IniFile.ReadBool(SECTION_SEARCH, 'RecursiveSearch', True);
end;

function TPrefs.GetSearchAllMode: Integer;
begin
  Result := IniFile.ReadInteger(SECTION_SEARCH, 'SearchAllMode', 0);
end;

function TPrefs.GetSearchBegin: boolean;
begin
  Result := IniFile.ReadBool(SECTION_SEARCH, 'FromBegin', True);
end;

function TPrefs.GetSearchFilePattern: string;
begin
  Result := IniFile.ReadString(SECTION_SEARCH, 'FilePattern', '*.pas|*.pp|*.inc|*.h|*.c');
end;

function TPrefs.GetSearchFwd: boolean;
begin
  Result := IniFile.ReadBool(SECTION_SEARCH, 'Forward', True);
end;

function TPrefs.GetSearchGlobal: Boolean;
begin
  Result := IniFile.ReadBool(SECTION_SEARCH, 'Global', True);
end;

function TPrefs.GetTabIndent: boolean;
begin
  Result := IniFile.ReadBool(SECTION_GENERAL, 'TabIndent', True);
end;

function TPrefs.GetTabsToSpaces: boolean;
begin
  Result := IniFile.ReadBool(SECTION_GENERAL, 'TabsToSpaces', True);
end;

function TPrefs.GetTabWidth: Integer;
begin
  Result := IniFile.ReadInteger(SECTION_GENERAL, 'TabWidth', 2);
end;

function TPrefs.GetTrimSpaces: boolean;
begin
  Result := IniFile.ReadBool(SECTION_GENERAL, 'TrimSpaces', True);
end;

function TPrefs.GetWholeWord: Boolean;
begin
  Result := IniFile.ReadBool(SECTION_SEARCH, 'WholeWord', False);
end;

function TPrefs.GetYPos: integer;
begin
  Result := IniFile.ReadInteger(SECTION_GENERAL, 'YPos', 25);
end;

constructor TPrefs.Create;
begin
  IniFile := TIniFile.Create(ChangeFileExt(Application.ExeName, '.prefs'));
  IniFile.CacheUpdates := True;
end;

destructor TPrefs.Destroy;
begin
  IniFile.UpdateFile;
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
