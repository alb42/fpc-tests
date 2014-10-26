unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    ScrollBar1: TScrollBar;
    ScrollBar2: TScrollBar;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    procedure ScrollBar1Change(Sender: TObject);
    procedure ScrollBar2Change(Sender: TObject);
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

procedure TForm1.ScrollBar1Change(Sender: TObject);
begin
  StaticText1.Caption:= 'X-Position = ' + IntToStr(ScrollBar1.Position);
end;

procedure TForm1.ScrollBar2Change(Sender: TObject);
begin
  StaticText2.Caption:= 'Y-Position = ' + IntToStr(ScrollBar2.Position);
end;

end.

