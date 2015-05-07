unit SyntaxManagement;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Contnrs, SynEditHighlighter;


Const
  HIGHLIGHTER_NONE = 0;
  HIGHLIGHTER_C = 1;
  HIGHLIGHTER_PASCAL = 2;
  HIGHLIGHTER_HTML = 3;


Type
  THighlighterListItem = class(TObject)
   private
    fHighlighter : TSynCustomHighlighter;
    fSyntaxIndex : Integer;
   public
    Constructor Create;
    Destructor Destroy; override;
   public
    property HighLighter: TSynCustomHighlighter read fHighLighter;
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


implementation

Uses
  SynHighlighterCpp, SynHighlighterPas, SynHighlighterHTML;



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


end.

