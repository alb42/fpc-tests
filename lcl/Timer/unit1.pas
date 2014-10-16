unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  dos, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    T1: Int64;
    T2: Int64;
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
var
  t: Integer;
begin
  t := GetMsCount;
  StaticText1.Caption:= 'Timer 1 fired at ' + IntToStr(t) + ' Interval: ' + IntToStr(t-t1) + ' ms';
  t1 := t;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  Timer1.Enabled:=CheckBox1.Checked;
end;

procedure TForm1.CheckBox2Change(Sender: TObject);
begin
  Timer2.Enabled:=CheckBox2.Checked;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
var
  t: Integer;
begin
  t := GetMsCount;
  StaticText2.Caption:= 'Timer 2 fired at ' + IntToStr(t) + ' Interval: ' + IntToStr(t-t2) + ' ms';
  t2 := t;
end;

end.

