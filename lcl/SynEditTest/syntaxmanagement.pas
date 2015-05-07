unit SyntaxManagement;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Contnrs, menus, SynEditHighlighter;

{
Const
  HIGHLIGHTER_NONE = 0;
  HIGHLIGHTER_C = 1;
  HIGHLIGHTER_PASCAL = 2;
  HIGHLIGHTER_HTML = 3;
}

Type
  TSyntaxHighlighterType =
  (
    shtNone,   // a.k.a. No Highlighter at all
    shtCpp,    // a.k.a. TSynCppSyn
    shtPascal, // a.k.a. TSynPasSyn
    shtHTML,   // a.k.a. TSynHTMLSyn
    shtCustom  // a.k.a. TSynFacilSyn
  );


  TSyntaxElement = class(TObject)
   private
    fSyntaxHLType : TSyntaxHighlighterType;
    fSampleCode   : pChar;
    fSamplePrefs  : pChar;
    fSyntaxDesc   : pChar;
    fName         : String;
    fMikroName    : String;
    fMenuName     : String;
    fPrefsName    : String;
    fExtensions   : Array of String;
    fMenuItem     : TMenuItem;
   public
    Constructor Create;
    Destructor  Destroy; override;
   public
    Function  HasFileExtension(Extension: String): Boolean;
   public
    property SampleCode  : pChar read fSampleCode;
    property SamplePrefs : pChar read fSamplePrefs;
    property Name        : String read fName;
    property MikroName   : String read fMikroName;
    property MenuName    : String read fMenuName;
    property PrefsName   : String read fPrefsName;
    property MenuItem    : TMenuItem read fMenuItem write fMenuItem;
    property SyntaxHLType: TSyntaxHighlighterType read fSyntaxHLType;
  end;


  TSyntaxManager = Class(TObject)
   private
    fElements : TFPObjectList;
   protected
    function  GetElement(index: LongInt): TSyntaxElement;
    function  GetElementsCount: LongInt;
    function  NewElement(ElementType: TSyntaxHighlighterType): TSyntaxElement;
   public
    constructor Create;
    destructor  Destroy; override;
   public
    property  Elements[index: LongInt]: TSyntaxElement read GetElement;
    property  ElementsCount: LongInt read GetElementsCount;
  end;


  THighlighterListItem = class(TObject)
   private
    fHighlighter : TSynCustomHighlighter;
    fSyntaxIndex : Integer;
   public
    Constructor Create;
    Destructor Destroy; override;
   public
    property HighLighter: TSynCustomHighlighter read fHighLighter;
    property SyntaxIndex: Integer read fSyntaxIndex;
  end;


  THighlighterList = class
   private
    fHighlighters : TFPObjectList;
   private
    procedure Populate;
   protected
    function  GetItem(index : LongInt): THighlighterListItem;
    Function  GetCount: LongInt;
   public
    constructor Create;
    destructor  Destroy; override;
   public
    Function  FindItemBySyntaxIndex(SyntaxIndex: Integer): THighlighterListItem;
   public
    Property Items [index : Longint]: THighlighterListItem Read GetItem;
    Property Count: LongInt Read GetCount;
  end;


  function LoadSyntaxAttributesFromFile(Syn: TSynCustomHighlighter; IniFileName: String): boolean;
  function SaveSyntaxAttributesToFile(Syn: TSynCustomHighlighter; IniFileName: String): boolean;

  function InRange(const AValue, AMin, AMax: Integer): Boolean;inline;

Var
  SyntaxManager : TSyntaxManager;


  {.$I SyntaxDeclarations.inc}          // Temp workable Syntax declarations go in here


implementation


Uses
  Forms,                               // For Application
  SynEditStrConst,                     // For SyntaxManager, official highlighter names
  SynHighlighterCpp, SynHighlighterPas,
  SynHighlighterHTML,                  // EdiSyn Syntax Highlighters
  inifiles;                            // For reading/writing attributes prefs


  {$I SyntaxDeclarations.inc}          // Syntax declarations go in here (in the end )

Const
  HIGHLIGHTER_NONE = 0;
  HIGHLIGHTER_C = 1;
  HIGHLIGHTER_PASCAL = 2;
  HIGHLIGHTER_HTML = 3;


// ############################################################################
// ###
// ###      Global Routines
// ###
// ############################################################################



// Copy from Math.InRange in order to avoid dragging in the complete math unit.
function InRange(const AValue, AMin, AMax: Integer): Boolean;inline;
begin
  Result:=(AValue>=AMin) and (AValue<=AMax);
end;



// ############################################################################
// ###
// ###      TSyntaxElement
// ###
// ############################################################################


constructor TSyntaxElement.Create;
begin
  inherited;

  fSyntaxHLType := TSyntaxHighlighterType(-1);
  fSampleCode   := nil;
  fSamplePrefs  := nil;
  fSyntaxDesc   := nil;
  fName         := '';
  fMikroName    := '';
  fMenuName     := '';
  fPrefsName    := '';
  SetLength(fExtensions, 0);
  fMenuItem     := nil;
end;


Destructor TSyntaxElement.Destroy;
begin
  SetLength(fExtensions, 0);
  inherited;
end;


function  TSyntaxElement.HasFileExtension(Extension: String): Boolean;
var
  i: Integer;
begin
  Result := False;

  for i := 0 to high(fExtensions) do
  begin
    if Extension = fExtensions[i] then
    begin
      Result := true;
      break;
    end;
  end;
end;



// ############################################################################
// ###
// ###      TSyntaxManager
// ###
// ############################################################################



constructor TSyntaxManager.Create;
begin
  inherited;
  fElements := TFPObjectList.Create(True);
end;


destructor TSyntaxManager.Destroy;
begin
  fElements.Free;
  inherited;
end;


function  TSyntaxManager.GetElementsCount: LongInt;
begin
  Result := fElements.Count;
end;


function  TSyntaxManager.GetElement(index: LongInt): TSyntaxElement;
begin
  Result := TSyntaxElement(fElements.Items[Index]);
end;


function  TSyntaxManager.NewElement(ElementType: TSyntaxHighlighterType): TSyntaxElement;
Var
  Element: TSyntaxElement;
begin
  Element := TSyntaxElement.Create;
  Element.fSyntaxHLType:= ElementType;

  fElements.Add(Element);
  result := Element;
end;



// ############################################################################
// ###
// ###      Highlighter Helpers
// ###
// ############################################################################



// LoadSyntaxAttributesFromFile and SaveSyntaxAttributesToFile
// Implemented to create a generic way of loading and saving attributes from a
// EdiSyn Custom highlighter.
// Normally one would use LoadFromFile and SaveToFile in the custom highlighter,
// but unfortunately TSynFacilSyn uses these to load and save the complete
// XML syntax file, instead of attributes.
function LoadSyntaxAttributesFromFile(Syn: TSynCustomHighlighter; IniFileName: String): boolean;
var
 AnIni : TIniFile;
 i     : Integer;
begin
  writeln('loading preferences from file ', IniFileName);
  AnIni := TIniFile.Create({UTF8ToSys}(IniFilename));
  try
    with AnIni do
    begin
      Result := true;
      for i := 0 to Pred(Syn.AttrCount) do
        Result := Result and Syn.Attribute[i].LoadFromFile(AnIni);
    end;
   finally
    AnIni.Free;
  end;
end;


function  SaveSyntaxAttributesToFile(Syn: TSynCustomHighlighter; IniFileName: String): boolean;
var
  AnIni : TIniFile;
  i     : integer;
begin
  writeln('writing preferences to file ', IniFileName);
  AnIni := TIniFile.Create({UTF8ToSys}(IniFileName));
  try
    with AnIni do
    begin
      Result := true;
      for i := 0 to Pred(Syn.AttrCount) do
        Result := Result and Syn.Attribute[i].SaveToFile(AnIni);
    end;
   finally
    AnIni.Free;
  end;
end;



// ############################################################################
// ###
// ###      THighlighterListItem
// ###
// ############################################################################



Constructor THighlighterListItem.Create;
begin
  inherited;

  fHighlighter := nil;
  fSyntaxIndex := -1;
end;


Destructor  THighlighterListItem.Destroy;
begin
  FreeAndNil(fHighlighter);

  inherited;
end;



// ############################################################################
// ###
// ###      THighlighterList
// ###
// ############################################################################



Constructor THighlighterList.Create;
begin
  inherited;

  fHighlighters := TFPObjectList.Create(True);
  Populate;     // Auto Add/Create Highlighters
end;


Destructor THighlighterList.Destroy;
begin
  fHighLighters.Free;

  inherited;
end;


Function  THighlighterList.GetItem(Index: LongInt): THighlighterListItem;
begin
  Result := THighlighterListItem(fHighLighters.Items[Index]);
end;


Function  THighlighterList.GetCount: LongInt;
begin
  Result := fHighLighters.Count;
end;


// Searches the list for the item that has a matching SyntaxIndex and return
// the coresponding Highlighter or nil in case there is no match.
Function  THighlighterList.FindItemBySyntaxIndex(SyntaxIndex: Integer): THighlighterListItem;
var
  i: integer;
begin
  result := nil;

  For i := 0 to Pred(fHighlighters.Count) do
  begin
    If THighlighterListItem(fHighlighters.Items[i]).fSyntaxIndex = SyntaxIndex then
    begin
      Result := THighlighterListItem(fHighLighters.Items[i]);
      break;
    end;
  end;
end;


Procedure THighlighterList.Populate;
var
  Highlighter   : TSynCustomHighlighter;
  ListItem      : THighlighterListItem;
begin
  // synced: (none), c, pascal, html
  ListItem    := THighlighterListItem.Create;
  Highlighter := TSynCppSyn.Create(nil);
  ListItem.fHighlighter := Highlighter;
  ListItem.fSyntaxIndex := HIGHLIGHTER_C;
  fHighlighters.Add(ListItem);

  ListItem    := THighlighterListItem.Create;
  Highlighter := TSynPasSyn.Create(nil);
  ListItem.fHighlighter := Highlighter;
  ListItem.fSyntaxIndex := HIGHLIGHTER_PASCAL;
  fHighlighters.Add(ListItem);

  ListItem    := THighlighterListItem.Create;
  Highlighter := TSynHtmlSyn.Create(nil);
  ListItem.fHighlighter := Highlighter;
  ListItem.fSyntaxIndex := HIGHLIGHTER_HTML;
  fHighlighters.Add(ListItem);
end;



// ############################################################################
// ###
// ###      Var SyntaxManager
// ###
// ############################################################################



Procedure FillNewElement(SE: TSyntaxElement;
  Name: String;
  Menuname: String;
  MikroName: String;
  PrefsName : String;
  const SampleCode: PChar;
  const SamplePrefs: PChar;
  const Extensions: Array of string;
  const Syntax: PChar = nil
  );
var i: integer;
begin
  SE.fSyntaxDesc   := Syntax;
  SE.fName         := Name;
  SE.fMenuName     := MenuName;
  SE.fMikroName    := MikroName;
  SE.fPrefsName    := PrefsName;
  SE.fSampleCode   := SampleCode;
  SE.fSamplePrefs  := SamplePrefs;

  If Length(Extensions) > 0 then
  begin
    SetLength(SE.fExtensions, Length(Extensions));
    For i := low(Extensions) to high(Extensions)
      do SE.fExtensions[i] := Extensions[i];
  end;
end;


Procedure InitializeSyntaxManager;
var
  SE      : TSyntaxElement;
  PFs     : String;
begin
  PFs := ChangeFileExt(Application.ExeName, '');
  //                  Name           ,  MenuName   , mikro  , PrefsName               , SmpCode       , PrefsCode     , File exts    , Optional Syntax Description File for custom highlighters
  SE := SyntaxManager.NewElement(shtNone);
  FillNewElement(SE, 'None'          , 'None'      , ''     , ''                      , NTEXT         , nil           , []);

  SE := SyntaxManager.NewElement(shtCPP);
  FillNewElement(SE, SYNS_LangCPP    , 'C/C++'     , 'C'    , PFs + 'C.prefs'         , CTEXT         , CShortText    , CEXT);

  SE := SyntaxManager.NewElement(shtPascal);
  FillNewElement(SE, SYNS_LangPascal , 'Pascal'    , 'Pas'  , PFs + 'Pas.prefs'       , PASTEXT       , PasShortText  , PASEXT);

  SE := SyntaxManager.NewElement(shtHTML);
  FillNewElement(SE, SYNS_LangHTML   , 'HTML'      , 'Html' , PFs + 'HTML.prefs'      , HTMLTEXT      , HTMLTEXT      , HTMLEXT);
end;



initialization
  SyntaxManager := TSyntaxManager.Create;
  InitializeSyntaxManager;


finalization
  SyntaxManager.Free;

end.

