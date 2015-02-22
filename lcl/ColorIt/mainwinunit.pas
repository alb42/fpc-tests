unit MainWinUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, Dos,
  StdCtrls;

type

  { TMainForm }

  TMainForm = class(TForm)
    ColPanel7: TPanel;
    ColPanel8: TPanel;
    StartGame: TButton;
    ChooseSize: TComboBox;
    ChooseColors: TComboBox;
    Gamefield: TPaintBox;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    MoveNum: TLabel;
    Label3: TLabel;
    NeedTime: TLabel;
    ColPanel1: TPanel;
    ColPanel2: TPanel;
    ColPanel3: TPanel;
    ColPanel4: TPanel;
    ColPanel5: TPanel;
    ColPanel6: TPanel;
    OverallTimer: TTimer;
    Panel7: TPanel;
    GamePanel: TPanel;
    procedure StartGameClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GamefieldPaint(Sender: TObject);
    procedure OverallTimerTimer(Sender: TObject);
    procedure ColPanel1Click(Sender: TObject);
  private
    StartTime: Int64;
    Moves: Int64;
    XSize, YSize: Integer;
    NumColors: Integer;
    SizeName: string;
    Platform: array of array of Integer;
    Colors: array of TColor;
    ColorBtn: array of TPanel;
    procedure ChangeTo(Num: Integer);
    procedure CheckForWin;
    { private declarations }
  public
    { public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.GamefieldPaint(Sender: TObject);
var
  TileWidth: Integer;
  TileHeight: Integer;
  y: Integer;
  x: Integer;
  CurCol: TColor;
  CurX, CurY: Integer;
begin
  CurCol := clBlack;
  GameField.Canvas.Brush.Color:= clBtnFace;
  GameField.Canvas.FillRect(0, 0, GameField.Width, GameField.Height);
  if (XSize > 0) and (YSize > 0) then
  begin
    TileWidth := GameField.Width div XSize;
    TileHeight := GameField.Height div YSize;
    CurX := 0;
    CurY := 0;
    for y := 0 to YSize - 1 do
    begin
      CurX := 0;
      for x := 0 to XSize - 1 do
      begin
        if CurCol <> Colors[Platform[x,y]] then
        begin
          CurCol := Colors[PlatForm[x,y]];
          GameField.Canvas.Brush.Color := CurCol;
        end;
        GameField.Canvas.FillRect(CurX, CurY, CurX + TileWidth, CurY + TileHeight);
        CurX := CurX + TileWidth;
      end;
      CurY := CurY + TileHeight;
    end;
    GameField.Canvas.Pen.Color := (not Colors[PlatForm[0,0]]) and $FFFFFF;
    GameField.Canvas.Brush.Color:= Colors[PlatForm[0,0]];
    GameField.Canvas.Line(0, 0, TileWidth div 2, TileHeight div 2);
    GameField.Canvas.Line(TileWidth div 2, TileHeight div 4, TileWidth div 2, TileHeight div 2);
    GameField.Canvas.Line(TileWidth div 4, TileHeight div 2, TileWidth div 2, TileHeight div 2);
  end;
end;

procedure TMainForm.OverallTimerTimer(Sender: TObject);
var
  CurTime: Int64;
  s, min, h: Integer;
begin
  if StartTime < 0 then
  begin
    OverallTimer.Enabled:= False;
    Exit;
  end;
  CurTime := GetMsCount;
  s := (CurTime - StartTime) div 1000;
  Min := s div 60;
  s := s mod 60;
  h := min div 60;
  min := min mod 60;
  NeedTime.Caption := Format('%.2d:%.2d:%.2d', [h,min,s]);
end;

procedure TMainForm.ColPanel1Click(Sender: TObject);
begin
  if XSize > 0 then
  begin
    Inc(Moves);
    MoveNum.Caption:= IntToStr(Moves);
    ChangeTo(TWinControl(Sender).Tag);
  end;
end;

procedure TMainForm.ChangeTo(Num: Integer);
var
  KeyColor: Integer;
  MaxIdx: Integer;
  NumColored: Integer;
  ToCheck: array of record
    x: Integer;
    y: Integer;
  end;


  procedure AddToList(x, y: Integer);
  var
    Idx: Integer;
  begin
    Inc(NumColored);
    Idx := MaxIdx;
    if MaxIdx > High(ToCheck) then
      SetLength(ToCheck, MaxIdx + 100);
    ToCheck[Idx].X := X;
    ToCheck[Idx].Y := Y;
    Inc(MaxIdx);
  end;

  procedure CheckNeighbours(x, y: Integer);
  var
    nx, ny: Integer;
  begin
    // 0 - 1
    nx := X;
    ny := Y - 1;
    if ny >= 0 then
    begin
      if PlatForm[nx, ny] = KeyColor then
      begin
        PlatForm[nx, ny] := Num;
        AddToList(nx, ny);
      end;
    end;
    // 0 + 1
    nx := X;
    ny := Y + 1;
    if ny < YSize then
    begin
      if PlatForm[nx, ny] = KeyColor then
      begin
        PlatForm[nx, ny] := Num;
        AddToList(nx, ny);
      end;
    end;
    // + 1 0
    nx := X + 1;
    ny := Y;
    if nx < XSize then
    begin
      if PlatForm[nx, ny] = KeyColor then
      begin
        PlatForm[nx, ny] := Num;
        AddToList(nx, ny);
      end;
    end;
    // - 1 0
    nx := X - 1;
    ny := Y;
    if nx >= 0 then
    begin
      if PlatForm[nx, ny] = KeyColor then
      begin
        PlatForm[nx, ny] := Num;
        AddToList(nx, ny);
      end;
    end;
  end;

begin
  if XSize = 0 then
    Exit;
  NumColored := 0;
  KeyColor := PlatForm[0, 0];
  if KeyColor = Num then
    Exit;
  SetLength(ToCheck, 100);
  MaxIdx := 0;
  PlatForm[0, 0] := Num;
  CheckNeighbours(0, 0);
  while MaxIdx > 0 do
  begin
    Dec(MaxIdx);
    CheckNeighbours(ToCheck[MaxIdx].X, ToCheck[MaxIdx].Y);
  end;
  SetLength(ToCheck, 0);
  GameField.Invalidate;
  CheckForWin;
end;

procedure TMainForm.CheckForWin;
var
  KeyColor: Integer;
  Win: Boolean;
  y: Integer;
  x: Integer;
  s: Integer;
  Min: Integer;
  h: Integer;
  str: String;
  DeltaTime: Int64;
  msec: Integer;
begin
  Win := True;
  if XSize <= 0 then
    Exit;
  KeyColor := PlatForm[0,0];
  for y := 0 to YSize - 1 do
  begin
    for x := 0 to XSize - 1 do
    begin
      if Platform[x, y] <> KeyColor then
      begin
        Win := False;
        Exit;
      end;
    end;
  end;
  if Win then
  begin
    DeltaTime := GetMsCount - StartTime;
    s := DeltaTime div 1000;
    msec := DeltaTime mod 1000;
    Min := s div 60;
    s := s mod 60;
    h := min div 60;
    min := min mod 60;
    str := Format('%.2d:%.2d:%.2d.%.3d', [h,min,s,msec]);
    OverallTimer.enabled := False;
    XSize := 0;
    StartTime := -1;
    ShowMessage('You solved ' + sizeName +  ' with ' + IntToStr(NumColors) + ' colors '#13#10 + 'Moves: ' + IntToStr(Moves) + #13#10 + 'Time: ' + str);
    GameField.Invalidate;
  end;
end;

procedure TMainForm.StartGameClick(Sender: TObject);
var
  y: Integer;
  x: Integer;
  i: Integer;
begin
  StartTime := GetMsCount;
  Moves := 0;
  MoveNum.Caption := '0';
  XSize := 20;
  SizeName := ChooseSize.Text;
  case ChooseSize.ItemIndex of
    0: XSize := 10;
    1: XSize := 20;
    2: XSize := 40;
  end;
  YSize := XSize;
  NumColors := ChooseColors.ItemIndex + 3;
  SetLength(Platform, XSize, YSize);
  for y := 0 to YSize - 1 do
  begin
    for x := 0 to XSize - 1 do
    begin
      Platform[x, y] := Random(NumColors);
    end;
  end;
  for i := 0 to High(ColorBtn) do
  begin
    ColorBtn[i].Visible := i < NumColors;
    ColorBtn[i].Tag := i;
  end;
  OverallTimer.Enabled:= True;
  GameField.Invalidate;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  StartTime := -1;
  Moves := 0;
  XSize := 0;
  YSize := 0;
  SetLength(ColorBtn, 8);
  SetLength(Colors, 8);
  ColorBtn[0] := ColPanel1;
  ColorBtn[1] := ColPanel2;
  ColorBtn[2] := ColPanel3;
  ColorBtn[3] := ColPanel4;
  ColorBtn[4] := ColPanel5;
  ColorBtn[5] := ColPanel6;
  ColorBtn[6] := ColPanel7;
  ColorBtn[7] := ColPanel8;
  for i := 0 to High(ColorBtn) do
    Colors[i] := ColorBtn[i].Color;
  Randomize;
end;

end.

