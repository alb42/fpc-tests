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
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    Count: Integer;
    Y: Integer;
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
  Inc(Count);
  Label4.Caption := 'Label to Change: '+IntToStr(Count)+' Clicks'
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Y := Y + 10;
  if Y > 100 then
    Y := 0;
  Label5.Top := 48+Y;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Count := 0;
  Y := 0;
end;

end.

