unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
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
  memo1.lines.add('Button clicked');
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if Button1.Caption = 'Click me' then
    Button1.Caption := 'CLICK ME'
  else
    Button1.Caption := 'Click me';
  memo1.lines.add('Button1 caption changed to: ' + Button1.Caption);
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  Button1.Enabled := CheckBox1.Checked;
  if Button1.Enabled then
    memo1.lines.add('Button1 enabled')
  else
    memo1.lines.add('Button1 disabled');
end;

end.

