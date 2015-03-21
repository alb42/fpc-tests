unit PrefsUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IniFiles, Forms;

const
  SECTION_GENERAL = 'General';
  SECTION_FILES = 'Files';
  SECTION_HIGHLIGHTER = 'Highlighter';

  HIGHLIGHTER_NONE = 0;
  HIGHLIGHTER_C = 1;
  HIGHLIGHTER_PASCAL = 2;
type

  { TPrefs }

  TPrefs = class
  private
    IniFile: TIniFile;
    function GetAutoHighlighter: Boolean;
    function GetDefHighlighter: Integer;
    function GetHeight: Integer;
    function GetInitialDir: string;
    function GetLineNumbers: Boolean;
    function GetRecFile(Idx: Integer): string;
    function GetWidth: Integer;
    function GetXPos: Integer;
    function GetYPos: Integer;
    procedure SetAutoHighlighter(AValue: Boolean);
    procedure SetHeight(AValue: Integer);
    procedure SetHighlighter(AValue: Integer);
    procedure SetInitialDir(AValue: string);
    procedure SetLineNumbers(AValue: Boolean);
    procedure SetRecFile(Idx: Integer; AValue: string);
    procedure SetWidth(AValue: Integer);
    procedure SetXPos(AValue: Integer);
    procedure SetYPos(AValue: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    property XPos: Integer read GetXPos write SetXPos;
    property YPos: Integer read GetYPos write SetYPos;
    property Width: Integer read GetWidth write SetWidth;
    property Height: Integer read GetHeight write SetHeight;
    property RecentFiles[Idx: Integer]: string read GetRecFile write SetRecFile;
    property AutoHighlighter: Boolean read GetAutoHighlighter write SetAutoHighlighter;
    property LineNumbers: Boolean read GetLineNumbers write SetLineNumbers;
    property DefHighlighter: Integer read GetDefHighlighter write SetHighlighter;
    property InitialDir: string read GetInitialDir write SetInitialDir;
  end;

var
  Prefs: TPrefs;

implementation

{ TPrefs }

procedure TPrefs.SetXPos(AValue: Integer);
begin
  IniFile.WriteInteger(SECTION_GENERAL, 'XPos', AValue);
end;

procedure TPrefs.SetYPos(AValue: Integer);
begin
  IniFile.WriteInteger(SECTION_GENERAL, 'YPos', AValue);
end;

procedure TPrefs.SetWidth(AValue: Integer);
begin
  IniFile.WriteInteger(SECTION_GENERAL, 'Width', AValue);
end;

procedure TPrefs.SetHeight(AValue: Integer);
begin
  IniFile.WriteInteger(SECTION_GENERAL, 'Height', AValue);
end;

procedure TPrefs.SetHighlighter(AValue: Integer);
begin
  IniFile.WriteInteger(SECTION_HIGHLIGHTER, 'Default', AValue);
end;

procedure TPrefs.SetInitialDir(AValue: string);
begin
  if AValue <> '' then
    IniFile.WriteString(SECTION_FILES, 'InitialDir', AValue);
end;

procedure TPrefs.SetLineNumbers(AValue: Boolean);
begin
  IniFile.WriteBool(SECTION_GENERAL, 'LineNumbers', AValue);
end;

procedure TPrefs.SetAutoHighlighter(AValue: Boolean);
begin
  IniFile.WriteBool(SECTION_HIGHLIGHTER, 'Auto', AValue);
end;

procedure TPrefs.SetRecFile(Idx: Integer; AValue: string);
begin
  IniFile.WriteString(SECTION_FILES, 'Recent_' + IntToStr(Idx), AValue);
end;

function TPrefs.GetXPos: Integer;
begin
  Result := IniFile.ReadInteger(SECTION_GENERAL, 'XPos', 25);
end;

function TPrefs.GetWidth: Integer;
begin
  Result := IniFile.ReadInteger(SECTION_GENERAL, 'Width', 800);
end;

function TPrefs.GetHeight: Integer;
begin
  Result := IniFile.ReadInteger(SECTION_GENERAL, 'Height', 500);
end;

function TPrefs.GetInitialDir: string;
begin
  Result := IniFile.ReadString(SECTION_FILES, 'InitialDir', '');
end;

function TPrefs.GetLineNumbers: Boolean;
begin
  Result := IniFile.ReadBool(SECTION_GENERAL, 'LineNumbers', True);
end;

function TPrefs.GetAutoHighlighter: Boolean;
begin
  Result := IniFile.ReadBool(SECTION_HIGHLIGHTER, 'Auto', True);
end;

function TPrefs.GetDefHighlighter: Integer;
begin
  Result := IniFile.ReadInteger(SECTION_HIGHLIGHTER, 'Default', HIGHLIGHTER_PASCAL);
end;

function TPrefs.GetRecFile(Idx: Integer): string;
begin
  Result := IniFile.ReadString(SECTION_FILES, 'Recent_' + IntToStr(Idx), '');
end;

function TPrefs.GetYPos: Integer;
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

initialization
  Prefs := TPrefs.Create;
finalization
  Prefs.Free;
end.

