unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    ProgressBar1: TProgressBar;
    ProgressBar2: TProgressBar;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  ProgressBar1.StepIt;
  ProgressBar2.StepIt;
  if ProgressBar1.Position >= ProgressBar1.Max then
    ProgressBar1.Position:= Random(ProgressBar1.Max + 1);
  if ProgressBar2.Position >= ProgressBar2.Max then
    ProgressBar2.Position:= Random(ProgressBar2.Max + 1);
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  Timer1.Enabled:=CheckBox1.Checked;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  ProgressBar1.Position := 0;
  ProgressBar2.Position := 0;
end;

end.

