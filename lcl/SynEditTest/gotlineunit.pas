unit GotLineUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  SynEdit, LCLType, Spin, Math;

type

  { TGoToLineWin }

  TGoToLineWin = class(TForm)
    OkButton: TButton;
    Label1: TLabel;
    AimLine: TSpinEdit;
    procedure AimLineChange(Sender: TObject);
    procedure AimLineEditingDone(Sender: TObject);
    procedure AimLineKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
  private
  public
  end;

var
  GoToLineWin: TGoToLineWin;

implementation
uses
  MainUnit;

{$R *.lfm}

{ TGoToLineWin }

procedure TGoToLineWin.FormShow(Sender: TObject);
begin
  AimLine.SetFocus;
  AimLine.Value := 0;
end;

procedure TGoToLineWin.OkButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TGoToLineWin.AimLineChange(Sender: TObject);
begin
  if AimLine.Value < MainWindow.CurEditor.Lines.Count then
    MainWindow.CurEditor.CaretY := AimLine.Value;
end;

procedure TGoToLineWin.AimLineEditingDone(Sender: TObject);
begin
  MainWindow.CurEditor.CaretY := Min(MainWindow.CurEditor.Lines.Count, AimLine.Value);
  Close;
end;

procedure TGoToLineWin.AimLineKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    MainWindow.CurEditor.CaretY := Min(MainWindow.CurEditor.Lines.Count, AimLine.Value);
    Close;
  end;
end;

end.

