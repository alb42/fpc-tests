unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, MaskEdit, Spin;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    FloatSpinEdit1: TFloatSpinEdit;
    LabeledEdit1: TLabeledEdit;
    MaskEdit1: TMaskEdit;
    Memo1: TMemo;
    SpinEdit1: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure FloatSpinEdit1Change(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpinEdit1EditingDone(Sender: TObject);
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

procedure TForm1.Button1Click(Sender: TObject);
begin
  SpinEdit1.Value:=10;
end;

procedure TForm1.FloatSpinEdit1Change(Sender: TObject);
begin
  memo1.Lines.add(Sender.ClassName + ' changed to ' + FloatToStr(FloatSpinEdit1.Value));
end;

procedure TForm1.SpinEdit1Change(Sender: TObject);
begin
  memo1.Lines.add(Sender.ClassName + ' changed to ' + IntToStr(SpinEdit1.Value));
end;

procedure TForm1.SpinEdit1EditingDone(Sender: TObject);
begin
  memo1.Lines.add(Sender.ClassName + ' ' + IntToStr(SpinEdit1.Value));
end;

end.

