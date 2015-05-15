unit AboutUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, LCLType, Math, BallObj, dos;

const
  NUMBALLS = 5;
  StepSize = 1;

  MyScrollText =
    'EdiSyn'#13#10 +
    'by'#13#10 +
    'ALB42'#13#10 +
    '-'#13#10 +
    '<hold left mouse button to stop scroller>';
type
  TScrollText = record
    Text: string;
    CurPos: Integer;
    FontSize: Integer;
    Center: Boolean;
  end;

  TScrollTexts = array of TScrollText;

  ETweenieError   = class(Exception);

  TTWeenieControl = class(TCustomControl)
   private
    FDrawBuffer   : TBitmap;
    FMaxTweens    : Integer;
    FCurrentTween : Integer;
    FStartBitmap  : TBitmap;
    FEndBitmap    : TBitmap;
   protected
    Procedure UpdateDrawBuffer;
    Function  CreateNewTween(const StartBitmap: TBitmap; const StartWeight: LongWord; const EndBitmap: TBitmap; const EndWeight: LongWord): TBitmap;
    Function  InitTween(StartPicture: TPicture; EndPicture: TPicture; TweenSteps: LongWord): boolean;
    Function  IsTweenified: boolean;
   public
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
    procedure EraseBackground(DC: HDC); override;
    procedure Paint; override;
  end;

  { TAboutForm }

  TAboutForm = class(TForm)
    Button1: TButton;
    BallImage: TImage;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    NameLabel: TLabel;
    VersionLabel: TLabel;
    DateLabel: TLabel;
    PlatformLabel: TLabel;
    Memo1: TMemo;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    ImagePanel: TPanel;
    TextPanel: TPanel;
    ScrollTimer: TTimer;
    ImageTimer: TTimer;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ImageTimerTimer(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1Paint(Sender: TObject);
    procedure ScrollTimerTimer(Sender: TObject);
  private
    MoveText: Boolean;
    IsMouseDown: Boolean;
    MyTexts: TScrollTexts;
    LastLinePos: Integer;
    ShowBalls: Integer;
    Balls: array[0..NUMBALLS-1] of TBall;
    IFrom: TImage;
    ITo: TImage;
  public
    Tweenie   : TTweenieControl;
  end;



var
  AboutForm: TAboutForm;
  PrgVersion: string;
implementation

Uses
  resource, versionresource, versiontypes;

{$R *.lfm}

{ TTweenieControl }

Constructor TTweenieControl.Create(AOwner: TComponent);
begin
  Inherited;

  FDrawBuffer   := nil;
  FCurrentTween := 0;
  FMaxTweens    := 0;
End;


Destructor TTweenieControl.Destroy;
begin
  FMaxTweens    := 0;
  FCurrentTween := 0;
  FreeAndNil(FDrawBuffer);
  FreeAndNil(FStartBitmap);
  FreeAndNil(FEndBitmap);
  inherited;
end;


Function  TTweenieControl.IsTweenified: boolean;
begin
  Result := (FCurrentTween >= FMaxTweens);
end;


type
{$ifdef AROS}
 TMYColors = packed record
          rgbReserved : BYTE;
          rgbRed : BYTE;
          rgbGreen : BYTE;
          rgbBlue : BYTE;
       end;
{$else}
TMYColors = TRGBQuad;
{$endif}

Function  TTweenieControl.CreateNewTween(const StartBitmap: TBitmap; const StartWeight: LongWord; const EndBitmap: TBitmap; const EndWeight: LongWord): TBitmap;
const  // rewrite to accompany needs
  MaxPixelCount = 65536;
Type
  TRGBArray  = array[0..MaxPixelCount-1] of TMYColors;
  pRGBArray  = ^TRGBArray;

  TRGBArrayo  = array[0..MaxPixelCount-1] of TRGBQuad;
  pRGBArrayo  = ^TRGBArrayo;
var
  i          : integer;
  j          : integer;
  RowA       : pRGBArrayo;
  RowB       : pRGBArrayo;
  RowTween   : pRGBArray;
  SumWeights : LongWord;
  W, H       : LongInt;


  function WeightPixels (const pixelA, pixelB:  LongWord):  Byte;
  begin
    Result := Byte((StartWeight*pixelA + EndWeight*pixelB) div SumWeights)
  end;

Begin
  if (StartBitmap.PixelFormat <> pf32bit) or
     (EndBitmap.PixelFormat   <> pf32bit)
  then Raise ETweenieError.Create('Tweenie:  PixelFormats must be pf32bit');


  If   (StartBitmap.Width  <> EndBitmap.Width) or
       (StartBitmap.Height <> EndBitmap.Height)
  then Raise ETweenieError.Create('Tweenie:  Bitmap dimensions do not match');

  W := StartBitmap.Width;
  H := StartBitmap.Height;

  SumWeights := StartWeight + EndWeight;

  Result := TBitmap.Create;
  Result.Width  := W;
  Result.Height := H;
  Result.PixelFormat := pf32bit; // pf24bit;
  {$if defined(AROS) or defined(Win32)}
  if ( SumWeights > 0 ) then
  begin
    for j := 0 to Result.Height-1 do
    begin
      RowA     := StartBitmap.Scanline[j];
      RowB     := EndBitmap.Scanline[j];
      RowTween := Result.Scanline[j];

      for i := 0 to Result.Width-1 do
      begin
        with RowTween^[i] do
        begin
          rgbRed      := WeightPixels(rowA^[i].rgbRed     , rowB^[i].rgbRed);
          rgbGreen    := WeightPixels(rowA^[i].rgbGreen   , rowB^[i].rgbGreen);
          rgbBlue     := WeightPixels(rowA^[i].rgbBlue    , rowB^[i].rgbBlue);
          rgbReserved := WeightPixels(rowA^[i].rgbReserved, rowB^[i].rgbReserved);
        end;

      end;
    end;
  end;
  {$endif}
end;   //}


{
type
  TRGBTripleArray = array[0..32767] of TRGBQuad;
  PRGBTripleArray = ^TRGBTripleArray;

Function  TTweenieControl.CreateNewTween(const StartBitmap: TBitmap; const StartWeight: LongWord; const EndBitmap: TBitmap; const EndWeight: LongWord): TBitmap;
const  // rewrite to accompany needs
  MaxPixelCount = 65536;
Type
  TRGBArray  = array[0..MaxPixelCount-1] of TMYColors;
  pRGBArray  = ^TRGBArray;

  TRGBArrayo  = array[0..MaxPixelCount-1] of TRGBQuad;
  pRGBArrayo  = ^TRGBArrayo;
var
  i          : integer;
  j          : integer;
  IntfImgA, IntfImgB, IntfImgTween: TLazIntfImage;
  RowA       : PRGBTripleArray;
  RowB       : PRGBTripleArray;
  RowTween   : PRGBTripleArray;
  SumWeights : LongWord;
  W, H       : LongInt;
  ImgHandle,ImgMaskHandle: HBitmap;

  function WeightPixels (const pixelA, pixelB:  LongWord):  Byte;
  begin
    Result := Byte((StartWeight*pixelA + EndWeight*pixelB) div SumWeights)
  end;

Begin
  if (StartBitmap.PixelFormat <> pf32bit) or
     (EndBitmap.PixelFormat   <> pf32bit)
  then Raise ETweenieError.Create('Tweenie:  PixelFormats must be pf32bit');


  If   (StartBitmap.Width  <> EndBitmap.Width) or
       (StartBitmap.Height <> EndBitmap.Height)
  then Raise ETweenieError.Create('Tweenie:  Bitmap dimensions do not match');

  W := StartBitmap.Width;
  H := StartBitmap.Height;

  SumWeights := StartWeight + EndWeight;

  IntfImgA:=TLazIntfImage.Create(0,0);
  IntfImgA.LoadFromBitmap(StartBitmap.Handle,StartBitmap.MaskHandle);

  IntfImgB:=TLazIntfImage.Create(0,0);
  IntfImgB.LoadFromBitmap(EndBitmap.Handle,EndBitmap.MaskHandle);

  Result := TBitmap.Create;
  Result.Width  := W;
  Result.Height := H;
  Result.PixelFormat := pf32bit;

  IntfImgTween:=TLazIntfImage.Create(0,0);
  IntfImgTween.LoadFromBitmap(Result.Handle,Result.MaskHandle);

  if ( SumWeights > 0 ) then
  begin
    for j := 0 to Result.Height-1 do
    begin
      RowA     := IntfImgA.GetDataLineStart(j);
      RowB     := IntfImgB.GetDataLineStart(j);
      RowTween := IntfImgTween.GetDataLineStart(j);

      for i := 0 to Result.Width-1 do
      begin
        with RowTween^[i] do
        begin
          rgbRed      := WeightPixels(rowA^[i].rgbRed     , rowB^[i].rgbRed);
          rgbGreen    := WeightPixels(rowA^[i].rgbGreen   , rowB^[i].rgbGreen);
          rgbBlue     := WeightPixels(rowA^[i].rgbBlue    , rowB^[i].rgbBlue);
          rgbReserved := WeightPixels(rowA^[i].rgbReserved, rowB^[i].rgbReserved);
        end;
      end;
    end;
  end;
  IntfImgTween.CreateBitmaps(ImgHandle,ImgMaskHandle,false);

  Result.Handle:=ImgHandle;
  Result.MaskHandle:=ImgMaskHandle;
end;    //}


Procedure TTweenieControl.UpdateDrawBuffer;
Var
  Bitmap : TBitMap;
begin
  If FCurrentTween < FMaxTweens Then
  begin
    Bitmap := CreateNewTween(FStartBitmap, FMaxTweens - FCurrentTween, FEndBitmap, FCurrentTween);
    FDrawBuffer.Assign(Bitmap);
    BitMap.Free;
    inc(FCurrentTween);
    Invalidate;
  end;
end;


procedure TTweenieControl.EraseBackground(DC: HDC);
begin
  // Uncomment this to enable default background erasing
  inherited EraseBackground(DC);
end;


procedure TTweenieControl.Paint;
begin
  Canvas.Brush.Color:= Parent.Color;
  Canvas.Clear;
  Canvas.Draw(0, 0, FDrawBuffer);
  // inherited Paint;
end;


Function  TTweenieControl.InitTween(StartPicture: TPicture; EndPicture: TPicture; TweenSteps: LongWord): boolean;
begin
  Result := True;

  FStartBitmap  := TBitmap.Create;
  FStartBitmap.Assign(StartPicture.Graphic);

  FEndBitmap    := TBitmap.Create;
  FEndBitmap.Assign(EndPicture.Graphic);

  FDrawBuffer   := TBitmap.Create;
  FDrawBuffer.Assign(FStartBitmap);

  FCurrentTween := 0;
  FMaxTweens    := TweenSteps;
end;

{ TAboutForm }

procedure TAboutForm.PaintBox1Paint(Sender: TObject);
var
  i: Integer;

  procedure WriteText(idx: Integer);
  var
    XPos: Integer;
    YPos: Integer;
    Col: Byte;
    Txt: string;
    DisplayText: string;
    SpPos: SizeInt;
    NextPart: string;
  begin
    XPos := 5;
    YPos := MyTexts[i].CurPos;
    if (YPos < - 1000) or (YPos > PaintBox1.Height + 100) then
      Exit;
    if (Trim(MyTexts[Idx].Text) = '#') then
    begin
      if (YPos < PaintBox1.Height div 2) and (ShowBalls = 2) then
      begin
        ShowBalls := 1;
      end;
      Exit;
    end;
    if (Trim(MyTexts[Idx].Text) = '*') then
    begin
      if (YPos < PaintBox1.Height div 2) and (ShowBalls = 1) then
      begin
        ShowBalls := 0;
      end;
      Exit;
    end;
    Col := Min(255,Max(0, 255 - Round((Abs(YPos - PaintBox1.Height div 2) / (PaintBox1.Height div 2)) * 255)));
    PaintBox1.Canvas.Font.Color := RGBToColor(col, col, col);
    if MyTexts[Idx].Center then
    begin
      if (YPos < - 20) then
        Exit;
      if MyTexts[Idx].Text = '-' then
      begin
        PaintBox1.Canvas.Pen.Color := RGBToColor(col, col, col);
        PaintBox1.Canvas.Line(5, YPos, PaintBox1.Width - 10, YPos);
        PaintBox1.Canvas.Line(5, YPos + 2, PaintBox1.Width - 10, YPos + 2);
      end else
      begin
        XPos := PaintBox1.Width div 2 - PaintBox1.Canvas.TextWidth(MyTexts[IDx].Text) div 2;
        PaintBox1.Canvas.TextOut(XPos, YPos, MyTexts[Idx].Text);
      end;
    end else
    begin
      Txt := MyTexts[IDx].Text;
      while Txt <> '' do
      begin
        DisplayText := '';
        repeat
          SpPos := Pos(' ', Txt);
          if spPos = 0 then
            NextPart := Txt
          else
            NextPart := Copy(txt, 1, SpPos);
          if (PaintBox1.Canvas.TextWidth(DisplayText + NextPart) < PaintBox1.Width - 10) or (DisplayText = '') then
          begin
            DisplayText := DisplayText + NextPart;
            if spPos = 0 then
            begin
              Txt := '';
              break;
            end;
            Delete(Txt, 1, spPos);
          end else
            Break;
        until False;
        Col := Min(255,Max(0, 255 - Round((Abs(YPos - PaintBox1.Height div 2) / (PaintBox1.Height div 2)) * 255)));
        PaintBox1.Canvas.Font.Color := RGBToColor(col, col, col);
        if not (YPos < - 20) then
        begin
          if Trim(DisplayText) = '-' then
          begin
            PaintBox1.Canvas.Pen.Color := RGBToColor(col, col, col);
            PaintBox1.Canvas.Line(5, YPos, PaintBox1.Width - 10, YPos);
            PaintBox1.Canvas.Line(5, YPos + 2, PaintBox1.Width - 10, YPos + 2);
          end else
          begin
            PaintBox1.Canvas.TextOut(XPos, YPos, DisplayText);
          end;
        end;
        //
        YPos := YPos + Round(PaintBox1.Canvas.TextHeight(DisplayText) * 1.5);
        if YPos > PaintBox1.Height + 20 then
          Break;
      end;
    end;
    if YPos > LastLinePos then
      LastLinePos := YPos;
  end;

begin
  if ShowBalls > 1 then
  begin
    for i := 0 to High(Balls) div 2 do
    begin
      Balls[i].Progress;
      Balls[i].Draw;
    end;
  end;
  Paintbox1.Canvas.Brush.Style:=bsClear;
  PaintBox1.Canvas.Font.Name := 'Arial';
  if LastLinePos <= -10 then
  begin
    ShowBalls := 2;
    for i := 0 to High(MyTexts) do
    begin
      MyTexts[i].CurPos := MaxInt;
    end;
  end;
  LastLinePos := -MaxInt;
  for i := 0 to High(MyTexts) do
  begin
    PaintBox1.Canvas.Font.Size := MyTexts[i].FontSize;
    if MyTexts[i].CurPos = MaxInt then
    begin
      MyTexts[i].CurPos := PaintBox1.Height + 10;
      WriteText(i);
      break;
    end else
    begin
      if MyTexts[i].CurPos < LastLinePos then
        MyTexts[i].CurPos := LastLinePos;
      if MoveText then
        Dec(MyTexts[i].CurPos, Stepsize);
      WriteText(i);
      if MyTexts[i].CurPos + PaintBox1.Canvas.TextHeight(MyTexts[i].Text) + 5 > PaintBox1.Height then
        Break;
    end;
  end;
  if ShowBalls > 0 then
  begin
    for i := (High(Balls) div 2 + 1) to High(Balls) do
    begin
      Balls[i].Progress;
      Balls[i].Draw;
    end;
  end;
end;

procedure TAboutForm.ScrollTimerTimer(Sender: TObject);
begin
  ScrollTimer.Enabled:= AboutForm.Visible;
  if not AboutForm.Visible then
    Exit;
  MoveText := (not MoveText) and (not IsMouseDown);
  PaintBox1.Invalidate;
end;

procedure TAboutForm.FormShow(Sender: TObject);
begin
  ScrollTimer.Interval := 25;
  ScrollTimer.Enabled := True;
  ImageTimer.Enabled:= True;
  VersionLabel.Caption := PrgVersion;
end;

procedure TAboutForm.ImageTimerTimer(Sender: TObject);
var
  iTemp: TImage;
begin
  if not Visible then
  begin
    ImageTimer.Enabled := False;
    Exit;
  end;

  If ImageTimer.Interval > 100 then
  begin
    ImageTimer.Interval := 100;
  end;

  Tweenie.UpdateDrawBuffer;
  if Tweenie.FCurrentTween = 100 then
  begin
    iTemp := iFrom;
    iFrom := iTo;
    iTo := iTemp;
    Tweenie.InitTween(iFrom.Picture, iTo.Picture, 100);
    ImageTimer.Interval := 5000;
  end;
end;

procedure TAboutForm.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    IsMouseDown := True;
end;

procedure TAboutForm.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    IsMouseDown := False;
end;

procedure TAboutForm.FormCreate(Sender: TObject);
var
  SL: TStringList;
  i: Integer;
  n: Integer;
begin
  NameLabel.Caption := 'EdiSyn';
  VersionLabel.Caption := '?.?';
  DateLabel.Caption := {$I %DATE%};
  PlatformLabel.Caption := {$I %FPCTARGETCPU%} + '-' + {$I %FPCTARGETOS%};

  Image1.Visible:= False;
  Image1.Enabled:= false;

  Image2.Visible:= False;
  Image2.Enabled:= false;

  // prepare tweeniecontrol
  Tweenie := TTweenieControl.Create(Self);
  Tweenie.Parent         := ImagePanel;
  Tweenie.Align := alClient;
  Tweenie.DoubleBuffered := True;
  //Tweenie.SetBounds(16, 16, 248, 170);
  IFrom := Image1;
  ITo := Image2;
  Tweenie.InitTween(IFrom.Picture, ITo.Picture, 100);

  ShowBalls := 2;
  SL := TStringList.create;
  try
    SL.Text := MyScrollText;
    SetLength(MyTexts, SL.Count);
    for i := 0 to SL.Count - 1 do
    begin
      MyTexts[i].Text := SL.Strings[i];
      MyTexts[i].Center := True;
      MyTexts[i].CurPos := MaxInt;
      MyTexts[i].FontSize := 30;
    end;
    MyTexts[SL.Count - 1].FontSize := 11;
    SetLength(MyTexts, SL.Count + Memo1.Lines.Count);
    for i := 0 to Memo1.Lines.Count - 1 do
    begin
      MyTexts[SL.Count + i].Text := memo1.lines.Strings[i];
      MyTexts[SL.Count + i].Center := False;
      MyTexts[SL.Count + i].CurPos := MaxInt;
      MyTexts[SL.Count + i].FontSize := 22;
    end;
  finally
    SL.Free;
  end;
  Randomize;
  for n := 0 to high(Balls) do
  begin
    Balls[n] := TBall.Create(PaintBox1.Canvas, PaintBox1.ClientRect);
    with Balls[n] do
    begin
       BallType   := btBitmap;
       BallBitmap := BallImage.Picture.Bitmap;
       Width      := BallBitmap.Width;
       Height     := BallBitmap.Height;
    end;
  end;
end;

procedure TAboutForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  ImageTimer.Enabled := False;
  ScrollTimer.Enabled := False;
end;

end.

