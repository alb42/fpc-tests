unit GotLineUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  SynEdit, LCLType, Math;

type

  { TGoToLineWin }

  TGoToLineWin = class(TForm)
    OkButton: TButton;
    AimLine: TEdit;
    Label1: TLabel;
    procedure AimLineChange(Sender: TObject);
    procedure AimLineEditingDone(Sender: TObject);
    procedure AimLineKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
  private
    OldText: string;
    NewLine: Integer;
  public
    SynEdit1: TSynEdit;
  end;

var
  GoToLineWin: TGoToLineWin;

implementation

{$R *.lfm}

{ TGoToLineWin }

procedure TGoToLineWin.FormShow(Sender: TObject);
begin
  AimLine.SetFocus;
  AimLine.Text := '';
  NewLine := SynEdit1.CaretY;
end;

procedure TGoToLineWin.OkButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TGoToLineWin.AimLineChange(Sender: TObject);
var
  NewText: string;
begin
  NewText := AimLine.Text;
  if NewText = OldText then
    Exit;
  NewLine := StrToIntDef(NewText, -1);
  if NewLine < 0 then
  begin
    AimLine.Text := OldText;
  end else
  begin
    OldText := NewText;
    SynEdit1.CaretY := NewLine;
  end;
end;

procedure TGoToLineWin.AimLineEditingDone(Sender: TObject);
begin
  SynEdit1.CaretY := Min(SynEdit1.Lines.Count, NewLine);
  Close;
end;

procedure TGoToLineWin.AimLineKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    SynEdit1.CaretY := Min(SynEdit1.Lines.Count, NewLine);
    Close;
  end;
end;

end.

