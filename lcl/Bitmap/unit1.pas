unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    PaintBox1: TPaintBox;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
  private
    Bit: TBitmap;
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  Bmp: TBitmap;
begin
  Bmp := Bit;
  try
    Bmp.SetSize(100,100);
    Bmp.Canvas.Brush.Color := clRed;
    Bmp.Canvas.FillRect(0,0,99,99);
    Bmp.Canvas.Brush.Color := clLime;
    Bmp.Canvas.FillRect(80,10,90,20);
    Bmp.Canvas.Brush.Color := clBlue;
    Bmp.Canvas.FillRect(80,20,90,30);
    Bmp.Canvas.Brush.Color := clYellow;
    Bmp.Canvas.FillRect(80,30,90,40);
    Bmp.Canvas.Brush.Color := clAqua;
    Bmp.Canvas.FillRect(80,40,90,50);
    Bmp.Canvas.Brush.Color := clFuchsia;
    Bmp.Canvas.FillRect(80,50,90,60);
    Bmp.Canvas.Pen.Color := clLime;
    Bmp.Canvas.Brush.Color := clWhite;
    Bmp.Canvas.Ellipse(10, 10, 40, 40);
    Bmp.Canvas.Pen.Color := clBlue;
    Bmp.Canvas.TextOut(50,50, 'Test');
    Bmp.SaveToFile('test.bmp');
  finally
  end;
  PaintBox1.Invalidate;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Bit := TBitmap.create;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Bit.Free;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.Canvas.Draw(0,0, Bit);
end;

end.

