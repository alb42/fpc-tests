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
var
  Points1: array of TPoint;
begin
  with PaintBox1.Canvas do
  begin
    // Line/Pen.Color Tests
    Pen.Color := clLime;
    MoveTo(10,10);
    LineTo(PaintBox1.Width - 50, PaintBox1.Height - 50);
    Pen.Color := clRed;
    LineTo(5, PaintBox1.Height - 40);
    Pen.Color := clBlue;
    LineTo(50,6);
    // Rectangle/Brush Test
    Pen.Color := clYellow;
    Brush.Color := clGreen;
    Rectangle(35,25,90,99);
    // Arc Test
    Pen.Color := clBlack;
    Arc(20,20,150,120,45 * 16, 90 * 16);
    // FillRect Test
    Brush.Color := clFuchsia;
    FillRect(100, 150, 175, PaintBox1.Height - 100);
    // Poly Line
    Pen.Color := clLime;
    SetLength(Points1, 5);
    Points1[0] := Point(110,10);
    Points1[1] := Point(140,11);
    Points1[2] := Point(190,80);
    Points1[3] := Point(PaintBox1.Width div 2,30);
    Points1[4] := Point(120,20);
    //Polyline(Points1, 0, 5);
    Polygon(@Points1[0], 5, True);
    // Text test
    Pen.Color := clRed;
    Font.Color := clRed;
    Brush.Color := clWhite;
    Brush.Style:= bsClear;
    TextOut(100, 100, 'Test Text Clear');
    Font.Color := clYellow;
    Brush.Color := clBlue;
    Brush.Style:= bsSolid;
    TextOut(100, 120, 'Test Text Solid');
  end;
end;

end.

