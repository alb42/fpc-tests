unit BallObj;

{$MODE Delphi}

interface

uses LCLIntf, LCLType, LMessages, SysUtils, Classes, Graphics, Math;

type
  TBallType = (btEllipse, btRectangle, btBitmap);

  TBall = class(TObject)
  private
    fCanvas      : TCanvas;
    fMoveRect    : TRect;

    fBallType    : TBallType;
    fBitmap      : Tbitmap;

    fCoord       : TPoint;
    fWidth       : integer;
    fHeight      : integer;

    fSpeed       : single;
    fDirection   : single;

    fColor       : integer;

    fEnabled     : boolean;

    fBckPen      : TPen;
    fBckBrush    : TBrush;

    _SpCosMul    : integer;
    _SpSinMul    : integer;

    procedure SetEnabled(val : boolean);
    function GetEnabled : boolean;
    procedure SetSingle(index : integer; val : single);
    procedure SetBitmap(val : TBitmap);

  protected
    procedure ComputeSPD; virtual;
    procedure SwapSpeed; virtual;
    procedure SwapDirection; virtual;
    procedure Move; virtual;
    procedure CheckOut; virtual;
  public
    constructor Create(ACanvas : TCanvas; AMoveRect : TRect);
    destructor Destroy; override;

    property Canvas      : TCanvas read fCanvas      write fCanvas;
    property MoveRect    : TRect   read fMoveRect    write fMoveRect;

    property Speed       : single  index 0 read fSpeed       write SetSingle;
    property Direction   : single  index 1 read fDirection   write SetSingle;

    property Coord       : TPoint  read fCoord       write fCoord;
    property Width       : integer read fWidth       write fWidth default 25;
    property Height      : integer read fHeight      write fHeight default 25;

    property Color       : integer read fColor       write fColor;

    property Enabled     : boolean read GetEnabled   write SetEnabled default true;

    property BallType    : TBallType read fBallType write fBallType default btEllipse;

    property BallBitmap  : TBitmap   read fBitmap   write SetBitmap;

    procedure Progress;
    procedure Draw;

    function GetRandomSpeed(const RandSign : boolean = false) : single;

    function GetRandomDirection(const RandSign : boolean = false) : single;

    function GetRandomColor : integer;

  end;



implementation

function Middle(const ALeftOrTop, ARightOrBottom : integer) : integer;
begin
  result := (ARightOrBottom-ALeftOrTop) shr 1;
end;


{ TBALL CLASS }

constructor TBall.Create(ACanvas : TCanvas; AMoveRect : TRect);
begin
  inherited Create;

  fCanvas      := ACanvas;
  fMoveRect    := AMoveRect;

  fCoord       := point(Middle(AMoveRect.Left,AMoveRect.Right),Middle(AMoveRect.Top,AMoveRect.Bottom));

  fWidth       := 25;
  fHeight      := 25;

  Direction    := GetRandomDirection(true);
  Speed        := GetRandomSpeed(True);

  ComputeSPD;

  fColor       := GetRandomColor;

  fBitmap      := TBitmap.Create;

  fBckPen      := TPen.Create;
  fBckBrush    := TBrush.Create;

  fEnabled     := Assigned(fCanvas);
end;

destructor TBall.Destroy;
begin
  fBckPen.Free;
  fBckBrush.Free;

  fBitmap.Free;

  inherited destroy;
end;



procedure TBall.SetEnabled(val : boolean);
begin
  fEnabled := assigned(fCanvas) and val;
end;

function TBall.GetEnabled : boolean;
begin
  fEnabled := assigned(fCanvas);
  result   := fEnabled;
end;

procedure TBall.SetSingle(index : integer; val : single);
begin
  case index of
    0 : fSpeed     := val;
    1 : fDirection := DegToRad(val);
  end;

  ComputeSPD;
end;

procedure TBall.SetBitmap(val : TBitmap);
begin
  fBitmap.Assign(val);
end;

procedure TBall.ComputeSPD;
var ST,CT : extended;
begin
  SinCos(fDirection,ST,CT);
  _SpCosMul := round(fSpeed * CT);
  _SpSinMul := round(fSpeed * ST);
end;

procedure TBall.SwapSpeed;
var NewSpeed : extended;
begin
  NewSpeed := GetRandomSpeed;
  if fSpeed >= 0
  then fSpeed := -NewSpeed
  else fSpeed := NewSpeed;

  ComputeSPD;
end;

procedure TBall.SwapDirection;
var NewAngle : extended;
begin
  NewAngle := DegToRad(GetRandomDirection);
  if fDirection >= 0 then
     fDirection := -NewAngle
  else
     fDirection := NewAngle;

  ComputeSPD;
end;



procedure TBall.Move;
begin
  fCoord.x := fCoord.x + _SpCosMul;
  fCoord.Y := fCoord.y + _SpSinMul;
end;

procedure TBall.CheckOut;
begin
  if (fCoord.Y+Height) >= fMoveRect.Bottom then
  begin
    fCoord.Y := fMoveRect.Bottom-fHeight;
    SwapDirection;
  end;

  if (fCoord.X+Width) >= fMoveRect.Right then
  begin
   fCoord.X := fMoveRect.Right-fWidth;
   SwapSpeed;
   SwapDirection;
  end;

  if fCoord.Y <= fMoveRect.Top then
  begin
    fCoord.Y := fMoveRect.Top;
    SwapDirection;
  end;

  if fCoord.X <= fMoveRect.Left then
  begin
    fCoord.X := fMoveRect.Left;
    SwapSpeed;
    SwapDirection;
  end;
end;

procedure TBall.Draw;
begin
  if not fEnabled then exit;

  with fCanvas do
  begin
    case fBallType of
      btEllipse :
        begin
          fBckPen.Assign(Pen);
          fBckBrush.Assign(Brush);
          Pen.Color   := fColor;
          Brush.Color := fColor;
          Ellipse(fCoord.X,fCoord.Y,fCoord.X+fWidth,fCoord.Y+fHeight);
          Pen.Assign(fBckPen);
          Brush.Assign(fBckBrush);
        end;
      btRectangle :
        begin
          fBckPen.Assign(Pen);
          fBckBrush.Assign(Brush);
          Pen.Color   := fColor;
          Brush.Color := fColor;
          Rectangle(fCoord.X,fCoord.Y,fCoord.X+fWidth,fCoord.Y+fHeight);
          Pen.Assign(fBckPen);
          Brush.Assign(fBckBrush);
        end;
      btBitmap :
        begin
          Draw(fCoord.X,fCoord.Y,fBitmap);
        end;
    end;
  end;
end;

procedure TBall.Progress;
begin
  { Animate }
  if not fEnabled then exit;
  Move;
  CheckOut;
end;

function TBall.GetRandomSpeed(const RandSign : boolean = false) : single;
begin
  result := RandomRange(4000,8001)/1000;

  if RandSign then
  case Random(100) of
    10..19,30..39,50..59,70..79,90..99 : result := -result;
  end;
end;

function TBall.GetRandomDirection(const RandSign : boolean = false) : single;
begin
  result := RandomRange(20000,80001)/1000;
  if RandSign then
  case Random(100) of
     10..19,30..39,50..59,70..79,90..99 : result := -result;
  end;
end;

function TBall.GetRandomColor : integer;
var R,G,B : byte;
begin
  R := RandomRange(64,197);
  G := RandomRange(64,197);
  B := RandomRange(64,197);
  result := (B shl 16) + (G shl 8) + R;
end;


end.
 