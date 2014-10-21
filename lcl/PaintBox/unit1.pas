unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    PaintBox1: TPaintBox;
    procedure PaintBox1Paint(Sender: TObject);
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

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  with PaintBox1.Canvas do
  begin
    Pen.Color := clLime;
    MoveTo(10,10);
    LineTo(PaintBox1.Width - 50, PaintBox1.Height - 50);
    Pen.Color := clRed;
    LineTo(5, PaintBox1.Height - 40);
    Pen.Color := clBlue;
    LineTo(50,6);
  end;
end;

end.

