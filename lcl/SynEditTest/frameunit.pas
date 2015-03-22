unit FrameUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterCpp, SynHighlighterPas,
  Forms, Controls, ATTabs;

type

  { TEditorFrame }

  TEditorFrame = class(TFrame)
    SynCppSyn1: TSynCppSyn;
    Editor: TSynEdit;
    SynPasSyn1: TSynPasSyn;
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
  MainUnit;

{ TEditorFrame }

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
  Editor.OnProcessCommand := @(MainUnit.Form1.SynEdit1ProcessCommand);
  Editor.OnReplaceText:=@MainUnit.Form1.SynEdit1ReplaceText;
  Editor.OnStatusChange:=@MainUnit.Form1.SynEdit1StatusChange;
end;

{$R *.lfm}

end.
