unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Image1: TImage;
    procedure Button1Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
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

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  Image1.Stretch := CheckBox1.Checked;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  image1.Canvas.Pen.Color:= clRed;
  image1.Canvas.Ellipse(50,50, 80, 80);
end;

procedure TForm1.CheckBox2Change(Sender: TObject);
begin
  Image1.Proportional := CheckBox2.Checked;
end;

end.

