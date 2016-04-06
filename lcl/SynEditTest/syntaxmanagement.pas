unit SyntaxManagement;

{
  Unit SyntaxManagement holds two important classes that are used
  throughout the rest of the units (in particular MainUnit, FrameUnit and
  PrefsWinUnit).

  The classes are:
  - TSyntaxManager   - holding a list of TSyntaxElement objects
  - THighlighterList - holding a list of THighlighterListItem objects.

  TSyntaxmanager is 'exposed' by global variable SyntaxManager

  THighlighterList contains all the dynamically create highlighters and as
  such replaces the visual SynEdit highlighters previosuly used. You can
  find this class being used in units FrameUnit and PrefsWinUnit, both
  using the variable-name "Highlighters".

  The SyntaxManager is created and populated on unit initialization as well
  as disposed off on unit finalization.

  All the items added to SyntaxManager are used to 'automagically' create the
  highlighterlist. Of course, if other behaviour is required, then it should be
  fairly easy to make changes.

  Why two separate classes ?

  The Highlighter class follows that what is available regarding real dynamic
  created highlighters. Nil (or Highlighter None) is not one of them.

  SyntaxManager on the other hand follows the Highlighter Menu, and as such
  holds all data for highlighters that can be defined once. Realize that this
  concept was explicitely implemented as such.

  Why ?

  Because it seemed to be the most logical thing todo at the time, also in
  regards to possible extensions that could be implemented in the future.

  Also keep in mind that SynFacilHighlighter offers the possibility to follow
  the rule of having one highlighter per SynEdit component, but afaik there is
  no penalty on changing the actual syntax (in which case SynFacil just needs
  to be updated in order to let the Editor reflect the changes). [*]

  Alas the latter was not implemented, inspired by the current design of having
  multiple created highlighters per editor. It's the easiest/fastest solution
  atm.

  [*] would one remove the built-in Highlighters, that would theoretically mean
      that EdiSyn could do with just one SynFacil Highlighter per editor + one
      extra for the PrefsWinUnit.
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Contnrs, menus, Graphics,
  SynHighlighterCpp, SynHighlighterPas,
  SynHighlighterHTML, SynFacilHighlighter,  // EdiSyn Syntax Highlighters
  SynEditHighlighter;


Type
  TSyntaxHighlighterType =  // See SyntaxClassTypes (need to keep in sync)
  (
    shtNone,   // a.k.a. No Highlighter at all
    shtCpp,    // a.k.a. TSynCppSyn
    shtPascal, // a.k.a. TSynPasSyn
    shtHTML,   // a.k.a. TSynHTMLSyn
    shtCustom  // a.k.a. TSynFacilSyn
  );

  { TEdiSynPasSyn }

  TEdiSynPasSyn = class(TSynPasSyn)
    constructor Create(AOwner: TComponent); override;
  end;

  { TEdiSynCppSyn }

  TEdiSynCppSyn = class(TSynCppSyn)
    constructor Create(AOwner: TComponent); override;
  end;

  { TEdiSynHTMLSyn }

  TEdiSynHTMLSyn = class(TSynHTMLSyn)
    constructor Create(AOwner: TComponent); override;
  end;


const
  SyntaxClassTypes: array[TSyntaxHighlighterType] of TSynCustomHighlighterClass =
  (
    nil,
    TEdiSynCppSyn,
    TEdiSynPasSyn,
    TEdiSynHTMLSyn,
    TSynFacilSyn
  );

Type
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


  { TSyntaxManager }

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
    Function  ElementIndexByLanguageName(S: String): LongInt;
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


implementation


Uses
  Forms,                                     // For Application
  SynEditStrConst,                           // For SyntaxManager, official highlighter names
  inifiles,                                  // For reading/writing attributes prefs
  LazLogger;                                 // debug

  {$I SyntaxDeclarations.inc}                // Syntax declarations go in here (in the end )



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

{ TEdiSynCppSyn }

constructor TEdiSynCppSyn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CommentAttri.Foreground := clGreen;
  DirecAttri.Foreground := clMaroon;
  IdentifierAttri.Foreground := clBlack;
  InvalidAttri.Foreground := clRed;
  KeyAttri.Foreground := clBlue;
  NumberAttri.Foreground := clOlive;
  SpaceAttri.Foreground := clTeal;
  StringAttri.Foreground := clNavy;
  SymbolAttri.Foreground := clTeal;
end;

{ TEdiSynHTMLSyn }

constructor TEdiSynHTMLSyn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CommentAttri.Foreground := clGreen;
  IdentifierAttri.Foreground := clTeal;
  KeyAttri.Foreground := clBlue;
  SymbolAttri.Foreground := clNavy;
end;

{ TEdiSynPasSyn }

constructor TEdiSynPasSyn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CommentAttri.Foreground := clGreen;
  CommentAttri.Style := [];
  IdentifierAttri.Foreground := clBlack;
  KeyAttri.Foreground := clBlue;
  NumberAttri.Foreground := clTeal;
  StringAttri.Foreground := clPurple;
  DirectiveAttri.Foreground := clRed;
  CompilerMode := pcmFPC;
  NestedComments := True;
  ExtendedKeywordsMode := True;
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


// Note that in opposite to normal indexby functions, this function will
// return zero on failure to indicate None highlighter,
function TSyntaxManager.ElementIndexByLanguageName(S: String): LongInt;
begin
  Result := 0;
  While (Result < ElementsCount) and (CompareText(Elements[Result].Name,S) <> 0 )
    do Result := Result + 1;
  if Result = ElementsCount then Result := 0;
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
  //DebugLn('loading preferences from file ' + IniFileName);
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
  //DebugLn('writing preferences to file ' + IniFileName);
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


// XMLStringToSyntax is used to create a stringstream out of given XML-string S.
// Used to load internal stored Syntax file into TSynFacil custom highlighter.
procedure XMLStringToSyntax(S: String; Syntax: TSynFacilSyn);
Var
 SS : TStringStream;
begin
  SS := TStringStream.Create(S);
  try
    Syntax.LoadFromStream(SS);      // Read complete XML document
   finally
    SS.Free;
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


// Add / create (custom) EdiSyn highlighters based on information from
// SyntaxManager.
procedure THighlighterList.Populate;
var
  SyntaxIndex   : Integer;
  SyntaxElement : TSyntaxElement;
  Item          : THighlighterListItem;
  Highlighter   : TSynCustomHighlighter;
  SyntaxHLType  : TSyntaxHighlighterType;
begin
  // for every element present in the Syntax elementList
  For SyntaxIndex := 0 To Pred(SyntaxManager.fElements.Count) do
  begin
    Highlighter   := nil;
    SyntaxElement := TSyntaxElement(SyntaxManager.fElements.Items[SyntaxIndex]);
    SyntaxHLType  := SyntaxElement.SyntaxHLType;

    if Assigned(SyntaxClassTypes[SyntaxHLType]) then
    begin
      HighLighter := SyntaxClassTypes[SyntaxHLType].Create(nil);
    end;

    If (Highlighter <> nil) then
    begin
      Item := THighlighterListItem.Create;
      Item.fSyntaxIndex := SyntaxIndex;
      Item.fHighlighter := Highlighter;
      // If custom HL and an available syntax, add the provided syntax
      If (SyntaxHLType = shtCustom) and (SyntaxElement.fSyntaxDesc <> nil) then
      begin
        XMLStringToSyntax(SyntaxElement.fSyntaxDesc, Highlighter as TSynFacilSyn);
      end;
      fHighlighters.Add(Item);
      // SynFacilSyn missing: LanguageName not overriden.
      // Theoreticallly now possible to use TSyntaxElement.name to retrieve the
      // languagename using SyntaxClassTypes, but alas custom LangName used by
      // synfacil is not a class function inside SynFacilSyn class.
      //DebugLn('Item ' + IntTostr(SyntaxIndex) + ' added to HighlightersList: ' + HighLighter.LanguageName);
    end
    else
      //DebugLn('INFO: skipped adding syntaxitemnr ' + IntToStr(SyntaxIndex) + ' to highlighterlist');
    ;
  end;
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

  SE := SyntaxManager.NewElement(shtCustom);
  FillNewElement(SE, 'Hollywood'     , 'Hollywood' , 'Hw'   , PFs + 'Hollywood.prefs' , HOLLYWOODTEXT , HOLLYWOODTEXT , HOLLYWOODEXT , HollywoodSyntax);

  SE := SyntaxManager.NewElement(shtHTML);
  FillNewElement(SE, SYNS_LangHTML   , 'HTML'      , 'Html' , PFs + 'HTML.prefs'      , HTMLTEXT      , HTMLTEXT      , HTMLEXT);

  SE := SyntaxManager.NewElement(shtPascal);
  FillNewElement(SE, SYNS_LangPascal , 'Pascal'    , 'Pas'  , PFs + 'Pas.prefs'       , PASTEXT       , PasShortText  , PASEXT);
end;


initialization
  SyntaxManager := TSyntaxManager.Create;
  InitializeSyntaxManager;


finalization
  SyntaxManager.Free;

end.

