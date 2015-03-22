unit MikroStatUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, StrUtils, Graphics, Math;

const
  CHANGED_TEXT = 'M';
  OVERWRITE_TEXT = 'Ov';
  INSERT_TEXT = 'Ins';

  NOHIGHLIGHTER_TEXT = 'No';

  INACTIVECOLOR = $00FCF5ED;
  ACTIVECOLOR= clSkyBlue;
type

  { TMikroStatus }

  TMikroStatus = class(TFrame)
    ChPanel: TPanel;
    InsModePanel: TPanel;
    HiLightPanel: TPanel;
    StatPanel: TPanel;
  private
    FChanged: boolean;
    FHighlighter: string;
    FInsMode: boolean;
    procedure SetChanged(AValue: boolean);
    procedure SetHighlighter(AValue: string);
    procedure SetInsMode(AValue: boolean);

  public
    property Changed: boolean read FChanged write SetChanged;
    property InsMode: boolean read FInsMode write SetInsMode;
    property Highlighter: string read FHighlighter write SetHighlighter;
  end;

implementation

{$R *.lfm}


function GetBevel(Active: Boolean): TPanelBevel; inline;
begin
  if Active then
    Result := bvLowered
  else
    Result := bvRaised;
end;

{ TMikroStatus }

procedure TMikroStatus.SetChanged(AValue: boolean);
begin
  if FChanged=AValue then
    Exit;
  FChanged:=AValue;
  ChPanel.Caption := ifthen(AValue, CHANGED_TEXT, '');
  ChPanel.Color:=ifthen(AValue, ACTIVECOLOR, INACTIVECOLOR);
  ChPanel.BevelOuter := GetBevel(AValue);
end;

procedure TMikroStatus.SetHighlighter(AValue: string);
begin
  if FHighlighter=AValue then
    Exit;
  FHighlighter:=AValue;
  HiLightPanel.Caption := AValue;
  HiLightPanel.Color := ifthen(AValue <> NOHIGHLIGHTER_TEXT, ACTIVECOLOR, INACTIVECOLOR);
  HiLightPanel.BevelOuter := GetBevel(AValue <> NOHIGHLIGHTER_TEXT);
end;

procedure TMikroStatus.SetInsMode(AValue: boolean);
begin
  if FInsMode = AValue then
    Exit;
  FInsMode:=AValue;
  InsModePanel.Caption := ifthen(AValue, INSERT_TEXT, OVERWRITE_TEXT);
  InsModePanel.Color:=ifthen(AValue, ACTIVECOLOR, INACTIVECOLOR);
  InsModePanel.BevelOuter := GetBevel(AValue);
end;

end.

