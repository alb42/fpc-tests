unit MainWinUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Math, dos;

const
  Version = '$VER: FPCMines 1.0 (26.02.2015)';

type
  TDrawStatus = (dsClosed, dsQuestion, dsMine, dsOpen);

  TMTile = record
    Status: ShortInt; // -1 = Mine, 0..8 neighbour mines
    DrawStatus: TDrawStatus;
  end;
  TMArea = array of array of TMTile;

  { TMainWin }

  TMainWin = class(TForm)
    Panel1: TPanel;
    ScoreBoard: TButton;
    Label1: TLabel;
    Label2: TLabel;
    TimeLabel: TLabel;
    MineLabel: TLabel;
    PlayMode: TComboBox;
    NewButton: TButton;
    PlayField: TPaintBox;
    PlayPanel: TPanel;
    GameTimer: TTimer;
    TopPanel: TPanel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GameTimerTimer(Sender: TObject);
    procedure NewButtonClick(Sender: TObject);
    procedure PlayFieldDblClick(Sender: TObject);
    procedure PlayFieldMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PlayFieldMouseLeave(Sender: TObject);
    procedure PlayFieldMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure PlayFieldMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PlayFieldPaint(Sender: TObject);
    procedure ScoreBoardClick(Sender: TObject);
  private
    TileWidth, TileHeight: Integer; // Width of one tile, changed on resize, faster acces
    MArea: TMArea;         // the Gamefield
    XSize, YSize: Integer; // Size of the Gamefield (faster access than Length)
    NumBombs: Integer;     // Number of Mines on the Game
    SetBombs: Integer;     // Number of Flags set by the User (never > NumBombs)

    LeftDown: TPoint;      // if a mouse is pressed on a tile, its coordinates, or -1,-1
    StartTime: Int64;      // Time the Game was started
    GameRunning: Boolean;  // Game is still running (without any click forbidden and result shown)

    LastTile: TPoint;      // Tile Position of Mouse for DoubleClick

    FirstShow: Boolean;    // Initial Open the Window -> Start Game
    //
    procedure DrawIt(Cv: TCAnvas);
    function MouseToPiece(mx, my: Integer): TPoint;
    procedure LeftClickTile(TilePos: TPoint);
    procedure LeftClickUpTile(TilePos: TPoint);
    procedure RightClickTile(TilePos: TPoint);
    procedure OpenAllZeros(CX, CY: Integer);
    function IsInside(tx, ty: Integer): Boolean;
    function CheckForWin: Boolean;
    function OpenTile(x,y: Integer): Boolean;
  public
    procedure NewGame(NX, NY, NMines: Integer);
  end;

var
  MainWin: TMainWin;

implementation

uses
  BestTimeUnit;

{$R *.lfm}

{ TMainWin }

procedure TMainWin.PlayFieldPaint(Sender: TObject);
begin
  if XSize > 0 then
  begin
    TileWidth := PlayField.Width div XSize;
    TileHeight := PlayField.Height div YSize;
    DrawIt(PlayField.Canvas);
  end;
end;

procedure TMainWin.ScoreBoardClick(Sender: TObject);
begin
  Form2.ShowStatistics;
end;

procedure TMainWin.DrawIt(Cv: TCAnvas);
var
  XPos, YPos: Integer;
  x,y: Integer;
  cx,cy: Integer;
  Down: Boolean;
  rx: Integer;
  ry: Integer;
  ARect: TRect;
begin
  XPos := 0;
  Cv.Pen.Style:= psSolid;
  Cv.Brush.Style:= bsSolid;
  CV.Pen.Mode:= pmCopy;
  Cv.Font.Name:='Arial';
  cv.Font.Height:=13;
  // redraw all tiles
  for x := 0 to XSize - 1 do
  begin
    YPos := 0;
    for y := 0 to YSize - 1 do
    begin
      if MArea[x,y].DrawStatus = dsOpen then
      begin
        // White BG for open tiles
        Cv.Pen.Color := $CCCCCC;
        Cv.Brush.Color := clWhite;
        CV.Rectangle(XPos, YPos, XPos + TileWidth - 1, YPos + TileHeight - 1);
        //
        Cv.Pen.Color := clBlack;
        if MArea[x, y].Status >= 0 then
        begin
          Cv.Brush.Color := clWhite;
          if MArea[x,y].Status > 0 then // it has a number paint the number
          begin
            cx := TileWidth div 2 + XPos;
            cy := TileHeight div 2 + YPos;
            CV.TextOut(cx, cy, IntToStr(MArea[x,y].Status));
          end;
        end else
        begin   // Paint the Mine in Red (an open Mine is where you stepped on)
          Cv.Brush.Color := clRed;
          CV.Rectangle(XPos, YPos, XPos + TileWidth - 1, YPos + TileHeight - 1);
          Cv.Brush.Color := clBlack;
          Cv.Pen.Color := clBlack;
          cx := TileWidth div 2 + XPos;
          cy := TileHeight div 2 + YPos;
          rx := max(4, min(TileWidth, TileHeight) div 8);
          ry := max(4, min(TileWidth, TileHeight) div 8);
          Cv.Pen.Color := clBlack;
          cv.Line(cx - 2*rx, cy, cx + 2*rx, cy);
          cv.Line(cx, cy - 2*ry, cx, cy + 2*ry);
          cv.Line(cx - 2 * rx, cy - 2*ry, cx + 2*rx, cy + 2*ry);
          cv.Line(cx - 2 * rx, cy + 2*ry, cx + 2*rx, cy - 2*ry);
          Cv.Pen.Color := clBlack;
          Cv.Brush.Color := clBlack;
          Cv.EllipseC(cx, cy, rx, ry);
        end;
      end else
      begin    // Closed tile
        Down := (LeftDown.X = x) and (LeftDown.Y = y) and (MArea[x,y].DrawStatus = dsClosed);
        ARect :=  Rect(XPos, YPos, XPos + TileWidth - 1, YPos + TileHeight - 1);
        // Pushed down button, tile is slected on release
        if Down then
        begin
          Cv.Frame3d(ARect, 1, bvLowered);
        end else
        begin
          Cv.Frame3d(ARect, 1, bvRaised);
        end;
        // User Set a mineFlag on it
        if MArea[x,y].DrawStatus = dsMine then
        begin
          // First the Flag stick
          Cv.Brush.Color := clBlack;
          cx := TileWidth div 2 + XPos;
          cy := TileHeight div 2 + YPos;
          CV.FillRect(CX - 1, CY - TileHeight div 4, CX + 1,CY + TileHeight div 4);
          if not GameRunning then // after Game End
          begin
            if MArea[x,y].Status = -1 then
              Cv.Brush.Color := clLime      // This Flag was right set
            else
              Cv.Brush.Color := clWhite;    // at this position there was no Mine
          end else
          begin
            Cv.Brush.Color := clRed;   // default mine flag
          end;
          // Draw the flag
          CV.FillRect(CX + 1, CY - TileHeight div 4, CX + TileWidth div 4, CY);
        end else
        begin
          // Game end, not flagged Mines
          if not GameRunning and (MArea[x, y].Status < 0) then
          begin
            Cv.Brush.Color := clBlack;
            Cv.Pen.Color := clBlack;
            cx := TileWidth div 2 + XPos;
            cy := TileHeight div 2 + YPos;
            rx := max(4, min(TileWidth, TileHeight) div 8);
            ry := max(4, min(TileWidth, TileHeight) div 8);
            cv.Line(cx - 2*rx, cy, cx + 2*rx, cy);
            cv.Line(cx, cy - 2*ry, cx, cy + 2*ry);
            cv.Line(cx - 2 * rx, cy - 2*ry, cx + 2*rx, cy + 2*ry);
            cv.Line(cx - 2 * rx, cy + 2*ry, cx + 2*rx, cy - 2*ry);
            Cv.EllipseC(cx, cy, rx, ry);
          end;
        end;
      end;
      YPos := YPos + TileHeight;
    end;
    XPos := XPos + TileWidth;
  end;
end;

// Convert Mouse coordinates to Piece coordinates
function TMainWin.MouseToPiece(mx, my: Integer): TPoint;
begin
  Result := Point(-1, -1);
  if (XSize > 0) and (YSize > 0) then
  begin
    Result.X := mx div TileWidth;
    Result.Y := my div TileHeight;
    if not IsInside(Result.X, Result.Y) then
      Result := Point(-1, -1);
  end;
end;

// Left Click on a tile (show the Button as pressed)
procedure TMainWin.LeftClickTile(TilePos: TPoint);
begin
  if IsInSide(TilePos.X, TilePos.Y) then
  begin
    LeftDown := Point(TilePos.X, TilePos.Y);
    PlayField.Invalidate;
  end;
end;

// Left release on a tile (open it)
procedure TMainWin.LeftClickUpTile(TilePos: TPoint);
begin
  if LeftDown.X < 0 then
    Exit;
  LeftDown := Point(-1, -1);
  if IsInside(TilePos.X, TilePos.Y) then
  begin
    if MArea[TilePos.X, TilePos.Y].DrawStatus = dsClosed then
    begin
      if not OpenTile(TilePos.X, TilePos.Y) then
        Exit;
    end;
  end;
  PlayField.Invalidate;
end;

procedure TMainWin.RightClickTile(TilePos: TPoint);
begin
  if isInside(TilePos.X, TilePos.Y) then
  begin
    case MArea[TilePos.X, TilePos.Y].DrawStatus of
      dsClosed: begin
        if SetBombs < NumBombs then
        begin
          MArea[TilePos.X, TilePos.Y].DrawStatus := dsMine;
          Inc(SetBombs);
          MineLabel.Caption := Format('%.2d',[NumBombs - SetBombs]);
          CheckForWin;
        end;
      end;
      dsMine: begin
        MArea[TilePos.X, TilePos.Y].DrawStatus := dsClosed;
        if SetBombs > 0 then
          Dec(SetBombs);
        MineLabel.Caption := Format('%.2d',[NumBombs - SetBombs]);
      end;
    end;
    PlayField.Invalidate;
  end;
end;

procedure TMainWin.OpenAllZeros(CX, CY: Integer);
begin
  if IsInside(CX, CY) then
  begin
    if MArea[CX, CY].DrawStatus = dsClosed then
    begin
      MArea[CX, CY].DrawStatus := dsOpen;
      if MArea[CX, CY].Status = 0 then
      begin
        OpenAllZeros(CX - 1, CY - 1);
        OpenAllZeros(CX - 1, CY);
        OpenAllZeros(CX - 1, CY + 1);
        OpenAllZeros(CX, CY - 1);
        OpenAllZeros(CX, CY + 1);
        OpenAllZeros(CX + 1, CY - 1);
        OpenAllZeros(CX + 1, CY);
        OpenAllZeros(CX + 1, CY + 1);
      end;
    end;
  end;
end;

function TMainWin.IsInside(tx, ty: Integer): Boolean;
begin
  Result := (TX >= 0) and (TY >= 0) and (TX < XSize) and (TY < YSize);
end;

function TMainWin.CheckForWin: Boolean;
var
  x, y: Integer;
  CurTime: Int64;
  NewRecord: Boolean;
  ModeName: String;
begin
  if SetBombs < NumBombs then
  begin
    Result := False;
    Exit;
  end;
  Result := True;
  for x := 0 to XSize - 1 do
  begin
    for y := 0 to YSize - 1 do
    begin
      case MArea[x,y].DrawStatus of
        dsMine: if MArea[x, y].Status <> -1 then Result := False;
        dsClosed: Result := False;
        dsQuestion: Result := False;
      end;
      if not Result then
        Exit;
    end;
  end;
  if Result then
  begin
    GameRunning:= False;
    PlayField.Invalidate;
    CurTime := GetMsCount - StartTime;

    NewRecord := False;
    case FileRec.GameMode of
      0: begin
        ModeName := 'Easy';
        Inc(FileRec.Easy.Win);
        if (FileRec.Easy.Time <= 0) or (FileRec.Easy.Time > CurTime) then
        begin
          FileRec.Easy.Time := CurTime;
          NewRecord := True;
        end;
      end;
      1: begin
        ModeName := 'Medium';
        Inc(FileRec.Medium.Win);
        if (FileRec.Medium.Time <= 0) or (FileRec.Medium.Time > CurTime) then
        begin
          FileRec.Medium.Time := CurTime;
          NewRecord := True;
        end;
      end;
      2: begin
        ModeName := 'Hard';
        Inc(FileRec.Hard.Win);
        if (FileRec.Hard.Time <= 0) or (FileRec.Hard.Time > CurTime) then
        begin
          FileRec.Hard.Time := CurTime;
          NewRecord := True;
        end;
      end;
    end;
    SavePrefs;
    TimeLabel.Caption := MyTimeToStr(CurTime, False);
    GameTimer.Enabled:= False;
    if NewRecord then
    begin
      ShowMessage('          Congratulation!          '#13#10'          You win this level in: ' + MyTimeToStr(CurTime) + #13#10 +'          This is a new record for ' + ModeName + '-Mode');
    end else
    begin
      ShowMessage('          Congratulation!          '#13#10'          You win this level in: ' + MyTimeToStr(CurTime));
    end;
  end;
end;

function TMainWin.OpenTile(x, y: Integer): Boolean;
begin
  Result := True;
  if MArea[X, Y].Status = 0 then
  begin
    OpenAllZeros(X, Y);
  end;
  MArea[X, Y].DrawStatus := dsOpen;
  if MArea[X, Y].Status = -1 then
  begin
    GameRunning := False;
    case FileRec.GameMode of
      0: Inc(FileRec.Easy.Lost);
      1: Inc(FileRec.Medium.Lost);
      2: Inc(FileRec.Hard.Lost);
    end;
    SavePrefs;
    PlayField.Invalidate;
    GameTimer.Enabled:= False;
    Showmessage('          You stepped on a mine.          '#13#10'                    Game Over          ');
    Result := False;
  end;
  if CheckForWin then
    Result := False;
end;

procedure TMainWin.NewGame(NX, NY, NMines: Integer);
var
  x: Integer;
  y: Integer;
  NumMines: Integer;

  procedure IncNeighbour(ax, ay: Integer);
  begin
    if IsInside(ax, ay) then
    begin
      if MArea[ax, ay].Status >= 0 then
        Inc(MArea[ax, ay].Status);
    end;
  end;

begin
  MainWin.Constraints.MinHeight:= TopPanel.Height + NY * 20 + 20;
  MainWin.Constraints.MinWidth:=  Max(ScoreBoard.Left + ScoreBoard.Width, NX * 20 + 20);
  if MainWin.Width < MainWin.Constraints.MinWidth then
    MainWin.Width := MainWin.Constraints.MinWidth
  else
    MainWin.Width := MainWin.Width;
  StartTime := GetMsCount;
  PlayPanel.SetFocus;
  GameRunning := True;
  XSize := NX;
  YSize := NY;

  SetLength(MArea, NX, NY);
  for x := 0 to XSize - 1 do
  begin
    for y := 0 to YSize - 1 do
    begin
      MArea[x, y].Status := 0;
      MArea[x, y].DrawStatus := dsClosed;
    end;
  end;
  NumBombs := NMines;
  SetBombs := 0;
  NumMines := 0;
  Randomize;
  while NumMines < NumBombs do
  begin
    x := Random(XSize);
    y := Random(YSize);
    if MArea[x, y].Status <> -1 then // not a mine already
    begin
      Inc(NumMines);
      MArea[x, y].Status := -1; // Set Mine;
      // Inc all neighbours
      IncNeighbour(x - 1, y - 1);
      IncNeighbour(x - 1, y);
      IncNeighbour(x - 1, y + 1);
      IncNeighbour(x, y - 1);
      IncNeighbour(x, y + 1);
      IncNeighbour(x + 1, y - 1);
      IncNeighbour(x + 1, y);
      IncNeighbour(x + 1, y + 1);
    end;
  end;
  MineLabel.Caption := Format('%.2d',[NumBombs - SetBombs]);
  GameTimer.Enabled := True;
end;

procedure TMainWin.NewButtonClick(Sender: TObject);
begin
  LeftDown := Point(-1, -1);
  FileRec.GameMode := PlayMode.ItemIndex;
  case PlayMode.ItemIndex of
    0: begin
      NewGame(9, 9, 10);
      Inc(FileRec.Easy.Played);
    end;
    1: begin
      NewGame(16,16,40);
      Inc(FileRec.Medium.Played);
    end;
    2: begin
      NewGame(30,16,99);
      Inc(FileRec.Hard.Played);
    end;
  end;
  PlayField.Invalidate;
end;

procedure TMainWin.GameTimerTimer(Sender: TObject);
var
  CurTime: Int64;
begin
  if GameRunning then
  begin
    CurTime := GetMsCount;
    TimeLabel.Caption := MyTimeToStr(CurTime - StartTime, False);
  end else
    GameTimer.Enabled := False;
end;

procedure TMainWin.FormCreate(Sender: TObject);
begin
  FirstShow := True;
  Caption := Copy(Version, 6, Length(Version));
end;

procedure TMainWin.FormShow(Sender: TObject);
begin
  if FirstShow then
    if BestTimeUnit.LoadPrefs then
    begin
      SetBounds(FileRec.PosX, FileRec.PosY, FileRec.SizeX, FileRec.SizeY);
      PlayMode.ItemIndex := FileRec.GameMode;
      NewButtonClick(Sender);
    end;
  FirstShow := False;
end;

procedure TMainWin.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  FileRec.GameMode := MainWin.PlayMode.ItemIndex;
  SavePrefs;
end;

procedure TMainWin.PlayFieldDblClick(Sender: TObject);
var
  ShouldBombs: Integer;
  Bombs: Integer;
  x,y:Integer;

  procedure CountBomb(tx,ty: Integer);
  begin
    if IsInside(tx, ty) then
    begin
      if MArea[tx, ty].DrawStatus = dsMine then
        Inc(Bombs);
    end;
  end;

  procedure OpenIt(tx,ty: Integer);
  begin
    if IsInSide(tx,ty) then
    begin
      if MArea[tx, ty].DrawStatus = dsClosed then
      begin
        OpenTile(tx, ty);
      end;
    end;
  end;

begin
  x := LastTile.X;
  y := LastTile.y;
  if IsInside(X, Y) and GameRunning then
  begin
    if MArea[X, Y].DrawStatus = dsOpen then
    begin
      Bombs := 0;
      ShouldBombs := MArea[X, Y].Status;
      CountBomb(x - 1, y - 1);
      CountBomb(x - 1, y);
      CountBomb(x - 1, y + 1);
      CountBomb(x, y - 1);
      CountBomb(x, y + 1);
      CountBomb(x + 1, y - 1);
      CountBomb(x + 1, y);
      CountBomb(x + 1, y + 1);
      if ShouldBombs = Bombs then
      begin
        OpenIt(x - 1, y - 1);
        OpenIt(x - 1, y);
        OpenIt(x - 1, y + 1);
        OpenIt(x, y - 1);
        OpenIt(x, y + 1);
        OpenIt(x + 1, y - 1);
        OpenIt(x + 1, y);
        OpenIt(x + 1, y + 1);
      end;
    end;
  end;
end;

procedure TMainWin.PlayFieldMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  T: TPoint;
begin
  if not GameRunning then
    Exit;
  T := MouseToPiece(X,Y);
  if T.X >= 0 then
  begin
    case Button of
      mbLeft: LeftClickTile(T);
      mbRight: RightClickTile(T);
    end;
  end;
end;

procedure TMainWin.PlayFieldMouseLeave(Sender: TObject);
begin
  LeftDown := Point(-1, -1);
  PlayField.Invalidate;
end;

procedure TMainWin.PlayFieldMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if not GameRunning then
    Exit;
  LastTile := MouseToPiece(X,Y);
  if (LeftDown.X >= 0) then
  begin
    if (LeftDown.X <> LastTile.X) or (LeftDown.Y <> LastTile.Y) then
    begin
      LeftDown := Point(-1, -1);
      PlayField.Invalidate;
    end;
  end;
end;

procedure TMainWin.PlayFieldMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  T: TPoint;
begin
  if not GameRunning then
    Exit;
  T := MouseToPiece(X,Y);
  if T.X >= 0 then
  begin
    case Button of
      mbLeft: LeftClickUpTile(T);
    end;
  end;
end;

end.

