unit FrameUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterCpp, SynHighlighterPas,
  SynHighlighterHTML, Forms, Controls, ATTabs, menus, SyntaxManagement;

type

  { TEditorFrame }

  TEditorFrame = class(TFrame)
    SynCppSyn1: TSynCppSyn;
    Editor: TSynEdit;
    SynHTMLSyn1: TSynHTMLSyn;
    SynPasSyn1: TSynPasSyn;
    procedure EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FFilename: string;
    procedure SetFileName(AValue: string);
  public
    TabLink: TATTabs;
    constructor Create(TheOwner: TComponent); override;
    property Filename: string read FFilename write SetFileName;
  end;

implementation

uses
  MainUnit, PrefsWinUnit, PrefsUnit;

{ TEditorFrame }

procedure TEditorFrame.EditorKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  MI: TMenuItem;
  UCom: TUserCommand;
  kKey: Word;
  kShift: TShiftState;
  i: Integer;
begin
  for i := 0 to MainWindow.UserMenu.ComponentCount - 1 do
  begin
    if MainWindow.UserMenu.Components[i] is TMenuItem then
    begin
      MI := MainWindow.UserMenu.Components[i] as TMenuItem;
      UCom := TUserCommand(MI.Tag);
      if UCom.ShortCut <> 0 then
      begin
        ShortCutToKey(UCom.ShortCut, kKey, kShift);
        if (Key = kKey) and (Shift = kShift) then
        begin
          MainWindow.UserMenuEvent(MI);
          Key := 0;
        end;
      end;
    end;
  end;
end;

procedure TEditorFrame.SetFileName(AValue: string);
var
  TabData: TATTabData;
  i: Integer;
begin
  if FFilename = AValue then
    Exit;
  FFilename:=AValue;

  for i := 0 to TabLink.TabCount - 1 do
  begin
    TabData := TabLink.GetTabData(i);
    if TabData.TabObject = Self then
    begin
      TabData.TabCaption := ExtractFileName(FFilename);
      TabLink.Invalidate;
      Break;
    end;
  end;
end;

constructor TEditorFrame.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  Editor.OnProcessCommand := @(MainUnit.MainWindow.SynEdit1ProcessCommand);
  Editor.OnReplaceText:=@MainUnit.MainWindow.SynEdit1ReplaceText;
  Editor.OnStatusChange:=@MainUnit.MainWindow.SynEdit1StatusChange;
  Editor.BookMarkOptions.BookmarkImages := MainUnit.MainWindow.BookmarkImages;
  PrefsWin.PrefsToEditor(Self);
end;

{$R *.lfm}

end.

