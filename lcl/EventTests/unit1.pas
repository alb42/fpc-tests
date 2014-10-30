unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, types;

type

  { TForm1 }

  TForm1 = class(TForm)
    PaintBox1: TPaintBox;
    PaintBox2: TPaintBox;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PaintBox1MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure PaintBox1MouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure PaintBox1Paint(Sender: TObject);
    procedure PaintBox2Paint(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure Panel1DblClick(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure Panel1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    MPos: TPoint;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  StaticText1.Caption:= Sender.classname + ' Mouse Down ' + IntToStr(X) + ', ' + IntToStr(Y);
  MPos.X := X;
  MPos.Y := Y;
  PaintBox1.Invalidate;
  PaintBox2.Invalidate;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
  StaticText1.Caption := Sender.Classname + ' KeyDown: ' + IntToStr(Key);
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: char);
begin
  StaticText1.Caption := Sender.Classname + ' KeyPress: "' + Key +'"';
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  StaticText1.Caption := Sender.Classname + ' KeyUp: ' + IntToStr(Key);
end;

procedure TForm1.PaintBox1MouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  StaticText1.Caption:= Sender.classname + ' Mouse Wheel Down ' + IntToStr(MousePos.X) + ', ' + IntToStr(MousePos.Y);
end;

procedure TForm1.PaintBox1MouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  StaticText1.Caption:= Sender.classname + ' Mouse Wheel Up ' + IntToStr(MousePos.X) + ', ' + IntToStr(MousePos.Y);
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.Canvas.Brush.Color:=clWhite;
  PaintBox1.Canvas.FillRect(0, 0, PaintBox1.Width - 1, PaintBox1.Height - 1);
  PaintBox1.Canvas.Pen.Color := clRed;
  PaintBox1.Canvas.Line(MPos.X - 10, MPos.Y, MPos.X + 10, MPos.Y);
  PaintBox1.Canvas.Line(MPos.X, MPos.Y - 10, MPos.X, MPos.Y + 10);
end;

procedure TForm1.PaintBox2Paint(Sender: TObject);
begin
  PaintBox2.Canvas.Brush.Color:=clYellow;
  PaintBox2.Canvas.FillRect(0, 0, PaintBox2.Width - 1, PaintBox2.Height - 1);
  PaintBox2.Canvas.Pen.Color := clNavy;
  PaintBox2.Canvas.Line(MPos.X - 10, MPos.Y, MPos.X + 10, MPos.Y);
  PaintBox2.Canvas.Line(MPos.X, MPos.Y - 10, MPos.X, MPos.Y + 10);
end;

procedure TForm1.Panel1Click(Sender: TObject);
begin
  StaticText1.Caption := Sender.Classname+ ' Click';
end;

procedure TForm1.Panel1DblClick(Sender: TObject);
begin
  StaticText1.Caption := Sender.Classname + ' Double click';
end;

procedure TForm1.Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  StaticText2.Caption:=Sender.classname + ' Mouse ' + IntToStr(X) + ', ' + IntToStr(Y);
end;

procedure TForm1.Panel1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  StaticText1.Caption:=Sender.classname + ' Mouse Up ' + IntToStr(X) + ', ' + IntToStr(Y);
end;

end.

