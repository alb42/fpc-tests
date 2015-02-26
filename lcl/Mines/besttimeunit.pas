unit BestTimeUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, crc;

const
  IniFileName = 'Mines.prefs';
  PrefsMagic = $55211255;
type
  TGameRecord = record
    Time: Int64;
    Played: Int64;
    Win: Int64;
    Lost: Int64;
  end;

  TFileRecord = record
    Magic: LongWord;
    SizeX: Integer;
    SizeY: Integer;
    PosX: Integer;
    PosY: Integer;
    GameMode: Integer;
    Space: array[0..7] of Integer;
    Easy: TGameRecord;
    Medium: TGameRecord;
    Hard: TGameRecord;
  end;


  { TForm2 }

  TForm2 = class(TForm)
    okButton: TButton;
    Stat: TMemo;
  private
  public
    procedure ShowStatistics;
  end;

function LoadPrefs: Boolean;
procedure SavePrefs;

function MyTimeToStr(t: Int64; WithMS: Boolean = True): string;


var
  Form2: TForm2;
  FileRec: TFileRecord;
implementation

uses
  MainWinUnit;

{$R *.lfm}

{ TForm2 }

function LoadPrefs: Boolean;
var
  T: TFileStream;
  crc, crcFile: LongWord;
  Buf: array[0..1023] of Byte;
  LocalRef: TFileRecord;
begin
  Result := False;
  try
    T := TFileStream.Create(IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + IniFileName, fmOpenRead);
  except
    Exit;
  end;
  try
    LocalRef := FileRec;
    crcFile := 0;
    T.Read(LocalRef, SizeOf(LocalRef));
    T.Read(crcFile, SizeOf(crcFile));
    Buf[0] := 0; // Prevent Warning
    FillChar(Buf[0], 1023, $42);
    Move(LocalRef, Buf[0], SizeOf(LocalRef));
    crc := crc32(0, nil, 0);
    crc := crc32(crc, @Buf[0], SizeOf(LocalRef));
    if crc <> crcFile then
    begin
      FileRec.Easy.Time := -1;
      FileRec.Medium.Time := -1;
      FileRec.Hard.Time := -1;
    end;
    if PrefsMagic = LocalRef.Magic then
    begin
      FileRec := LocalRef;
      Result := True;
    end;
  finally
    T.Free;
  end;
end;

procedure SavePrefs;
var
  T: TFileStream;
  Buf: array[0..1023] of Byte;
  crc: LongWord;
begin
  FileRec.Magic := PrefsMagic;
  FileRec.PosX := MainWin.Left;
  FileRec.PosY := MainWin.Top;
  FileRec.SizeX := MainWin.Width;
  FileRec.SizeY := MainWin.Height;
  T := TFileStream.Create(IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + IniFileName, fmCreate);
  try
    T.Write(FileRec, SizeOf(FileRec));
    Buf[0] := 0; // prevent warning
    FillChar(Buf[0], 1023, $42);
    Move(FileRec, Buf[0], SizeOf(FileRec));
    crc := crc32(0, nil, 0);
    crc := crc32(crc, @Buf[0], SizeOf(FileRec));
    T.Write(crc, SizeOf(crc));
  finally
    T.Free;
  end;
end;

function MyTimeToStr(t: Int64; WithMS: Boolean = True): string;
var
  s: Integer;
  ms: Integer;
  m: Integer;
  h: Integer;
begin
  s := t div 1000;
  ms := t mod 1000;
  m := s div 60;
  s := s mod 60;
  h := m div 60;
  m := m mod 60;
  if WithMS then
    Result := Format('%.2d:%.2d:%.2d.%.3d', [h,m,s,ms])
  else
    Result := Format('%.2d:%.2d:%.2d', [h,m,s])
end;

procedure TForm2.ShowStatistics;
var
  str: String;
  GamesPlayed: Integer;
begin
  GamesPlayed := FileRec.Easy.Played + FileRec.Medium.Played + FileRec.Hard.Played;
  str := 'Statistics for ' + IntToStr(GamesPlayed) + ' games'#13#10#13#10 +
    'Easy Mode:'#13#10 +
    '    Played: ' + IntToStr(FileRec.Easy.Played) + #13#10 +
    '    Win   : ' + IntToStr(FileRec.Easy.Win) + #13#10 +
    '    Lost  : ' + IntToStr(FileRec.Easy.Lost) + #13#10 +
    'Best Time : ' + MyTimeToStr(FileRec.Easy.Time) + #13#10#13#10 +
    'Medium Mode:'#13#10 +
    '    Played: ' + IntToStr(FileRec.Medium.Played) + #13#10 +
    '    Win   : ' + IntToStr(FileRec.Medium.Win) + #13#10 +
    '    Lost  : ' + IntToStr(FileRec.Medium.Lost) + #13#10 +
    'Best Time : ' + MyTimeToStr(FileRec.Medium.Time) + #13#10#13#10 +
    'Hard Mode:'#13#10 +
    '    Played: ' + IntToStr(FileRec.Hard.Played) + #13#10 +
    '    Win   : ' + IntToStr(FileRec.Hard.Win) + #13#10 +
    '    Lost  : ' + IntToStr(FileRec.Hard.Lost) + #13#10 +
    'Best Time : ' + MyTimeToStr(FileRec.Hard.Time);
  Stat.Text := str;
  ShowModal;
end;

initialization
  FileRec.Magic := PrefsMagic;
  FileRec.PosX := 0;
  FileRec.PosY := 0;
  FileRec.SizeX := 400;
  FileRec.SizeY := 400;
  FileRec.GameMode := 0;
  FileRec.Easy.Lost := 0;
  FileRec.Easy.Win := 0;
  FileRec.Easy.Played := 0;
  FileRec.Easy.Time := 0;
  FileRec.Easy.Lost := 0;
  FileRec.Medium.Win := 0;
  FileRec.Medium.Played := 0;
  FileRec.Medium.Time := 0;
  FileRec.Medium.Lost := 0;
  FileRec.Hard.Win := 0;
  FileRec.Hard.Played := 0;
  FileRec.Hard.Time := 0;
  FileRec.Hard.Lost := 0;
  FileRec.Space[0] := 0;
  FileRec.Space[1] := 0;
  FileRec.Space[2] := 0;
  FileRec.Space[3] := 0;
  FileRec.Space[4] := 0;
  FileRec.Space[5] := 0;
  FileRec.Space[6] := 0;
  FileRec.Space[7] := 0;
end.

