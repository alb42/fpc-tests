unit MainWinUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, LCLType, Math, types;

const
  VERSION = '$VER APict 1.1 (13.03.2015)';

type
  { TMainForm }

  TMainForm = class(TForm)
    IsStretched: TCheckBox;
    ZoomInButton: TBitBtn;
    ZoomOutButton: TBitBtn;
    ZoomResetButton: TBitBtn;
    OpenButton: TBitBtn;
    OpenDialog: TOpenDialog;
    PB: TPaintBox;
    PrevButton: TBitBtn;
    NextButton: TBitBtn;
    HorizontalSB: TScrollBar;
    VerticalSB: TScrollBar;
    SizeLabel: TLabel;
    TopPanel: TPanel;
    LowerPanel: TPanel;
    ImagePanel: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HorizontalSBChange(Sender: TObject);
    procedure IsStretchedClick(Sender: TObject);
    procedure NextButtonClick(Sender: TObject);
    procedure OpenButtonClick(Sender: TObject);
    procedure PBMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PBMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PBMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PBPaint(Sender: TObject);
    procedure PrevButtonClick(Sender: TObject);
    procedure VerticalSBChange(Sender: TObject);
    procedure ZoomInButtonClick(Sender: TObject);
    procedure ZoomOutButtonClick(Sender: TObject);
    procedure ZoomResetButtonClick(Sender: TObject);
  private
    TitleStr: string;
    Dir: string;
    Filename: string;
    Idx: integer;
    FileList: TStringList;
    AllowedFilesExt: TStringList;
    Picture: TPicture;
    Zoom: Double;
    LeftDown: Boolean;
    MousePos: TPoint;
    Offset: TPoint;
    StartOffset: TPoint;
    SetByGUI: Boolean;
    procedure GetFileList;
    procedure LoadFile(AFileName: string);
    procedure NextFile;
    procedure PrevFile;
    procedure RemakeStatusLine;
    procedure UpdateSB;
    procedure ZoomIn;
    procedure ZoomOut;
    procedure ZoomReset;
  public
    { public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.OpenButtonClick(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    Filename := OpenDialog.FileName;
    Dir := ExtractFilePath(Filename);
    Filename := ExtractFileName(Filename);
    GetFileList;
    LoadFile(Filename);
  end;
  ImagePanel.SetFocus;
end;

procedure TMainForm.PBMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and (not IsStretched.Checked) then
  begin
    LeftDown := True;
    MousePos := Point(X, Y);
    StartOffset := Offset;
  end;
end;

procedure TMainForm.PBMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  DX: Integer;
  DY: Integer;
begin
  if LeftDown then
  begin
    DX := (MousePos.X - X);
    DY := (MousePos.Y - Y);
    Offset.X := Min(0,Max(Min(0, StartOffset.X - DX), PB.Width - Round(Picture.Width * Zoom)));
    Offset.Y := Min(0,Max(Min(0, StartOffset.Y - DY), PB.Height - Round(Picture.Height * Zoom)));
    try
      SetByGUI := True;
      if HorizontalSB.Enabled then
        HorizontalSB.Position := -Offset.X;
      if VerticalSB.Enabled then
        VerticalSB.Position := -Offset.Y;
    except
      ;
    end;
    SetByGUI := False;
    PB.Invalidate;
  end;
end;

procedure TMainForm.PBMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    LeftDown := False;
end;

procedure TMainForm.PBPaint(Sender: TObject);
var
  F: Double;
  w: Integer;
  h: Int64;
begin
  if Picture.Height = 0 then
    Exit;
  if IsStretched.Checked then
  begin
    F := (1.0 * Picture.Width) / Picture.Height;
    if F * PB.Height > PB.Width then
    begin
      w := PB.Width;
      h := Round(w / F);
    end
    else
    begin
      h := PB.Height;
      w := Round(h * f);
    end;
    PB.Canvas.StretchDraw(Rect(0,0,w,h),Picture.Bitmap);
  end else
  begin
    if Zoom <> 1 then
    begin
      w := Round(Picture.Width * Zoom);
      h := Round(Picture.Height * Zoom);
      PB.Canvas.StretchDraw(Rect(Offset.X, Offset.Y, Offset.X + w - 1, Offset.Y + h - 1), Picture.Bitmap);
    end else
      PB.Canvas.Draw(Offset.X, Offset.Y, Picture.Bitmap);
  end;
end;

procedure TMainForm.PrevButtonClick(Sender: TObject);
begin
  PrevButton.Enabled := False;
  PrevFile;
  PrevButton.Enabled := True;
end;

procedure TMainForm.VerticalSBChange(Sender: TObject);
begin
  if VerticalSB.Enabled and not SetByGUI then
  begin
    Offset.Y := -VerticalSB.Position;
    PB.Invalidate;
  end;
end;

procedure TMainForm.ZoomInButtonClick(Sender: TObject);
begin
  ZoomIn;
end;

procedure TMainForm.ZoomOutButtonClick(Sender: TObject);
begin
  ZoomOut;
end;

procedure TMainForm.ZoomResetButtonClick(Sender: TObject);
begin
  ZoomReset;
end;

procedure TMainForm.GetFileList;
var
  Info: TSearchRec;
  Ext: string;
begin
  FileList.Clear;
  if FindFirst(IncludeTrailingPathDelimiter(Dir) + '*', faAnyFile, Info) = 0 then
  begin
    repeat
      Ext := LowerCase(ExtractFileExt(Info.Name));
      if AllowedFilesExt.IndexOf(Ext) >= 0 then
      begin
        FileList.Add(Info.Name);
      end;
    until FindNext(Info) <> 0;
  end;
end;

procedure TMainForm.LoadFile(AFileName: string);
begin
  Offset := Point(0,0);
  LeftDown := False;
  try
    Filename := AFilename;
    Idx := FileList.IndexOf(Filename);
    if Idx < 0 then
    begin
      FileList.Add(Filename);
      Idx := FileList.IndexOf(Filename);
    end;
    Caption := TitleStr + ' - ' + Filename + '(' + IntToStr(Idx + 1) + '/' + IntToStr(FileList.Count) + ')';
    Picture.LoadFromFile(IncludeTrailingPathDelimiter(Dir) + Filename);
    UpdateSB;
    PB.Invalidate;
  except
    on E: Exception do
      ShowMessage('Cannot open file ' + Filename + ' (' + E.Message + ')');
  end;
end;

procedure TMainForm.NextFile;
var
  Res: integer;
begin
  if FileList.Count = 0 then
  begin
    OpenButtonClick(nil);
    Exit;
  end;
  if Idx < FileList.Count - 1 then
  begin
    LoadFile(FileList.Strings[Idx + 1]);
  end
  else
  begin
    Res := MessageDlg('No More Images',
      'End of List, restart from beginning?', mtConfirmation, [mbYes, mbNo], 0, mbYes);
    if Res = mrYes then
      LoadFile(FileList.Strings[0]);
  end;
end;

procedure TMainForm.PrevFile;
begin
  if FileList.Count = 0 then
  begin
    OpenButtonClick(nil);
    Exit;
  end;
  if Idx > 0 then
  begin
    LoadFile(FileList.Strings[Idx - 1]);
  end
  else
  begin
    if MessageDlg('No More Images', 'Start of List, restart from end?', mtConfirmation,
      [mbYes, mbNo], 0, mbYes) = mrYes then
      LoadFile(FileList.Strings[FileList.Count - 1]);
  end;
end;

procedure TMainForm.RemakeStatusLine;
var
  F: single;
  w, h: integer;
begin
  if Filename <> '' then
  begin
    if IsStretched.Checked then
    begin
      F := (1.0 * Picture.Width) / Picture.Height;
      if F * PB.Height > PB.Width then
      begin
        w := PB.Width;
        h := Round(w / F);
      end
      else
      begin
        h := PB.Height;
        w := Round(h * f);
      end;
      SizeLabel.Caption := Format('Info: (%dpx X %dpx)  Scaled to (%dpx X %dpx)',
        [Picture.Width, Picture.Height, w, h]);
    end
    else
    begin
      if Zoom <> 1 then
        SizeLabel.Caption := Format('Info: (%dpx X %dpx)  Zoomed (%2.1fx) to (%dpx X %dpx)', [Picture.Width, Picture.Height, Zoom, Round(Picture.Width*Zoom), Round(Picture.Height*Zoom)])
      else
        SizeLabel.Caption := Format('Info: (%dpx X %dpx)', [Picture.Width, Picture.Height]);
    end;
  end
  else
    SizeLabel.Caption := '<no file open>';
end;

procedure TMainForm.UpdateSB;
var
  NMax: Integer;
begin
  SetByGUI := True;
  try
    HorizontalSB.Min := 0;
    NMax := Round(Picture.Width * Zoom) - PB.Width;
    HorizontalSB.Enabled := (NMax > 0) and not IsStretched.Checked;
    if HorizontalSB.Enabled then
    begin
      HorizontalSB.Max := NMax;
      HorizontalSB.PageSize := PB.Width;
      HorizontalSB.Position := -Offset.X;
    end else
    begin
      HorizontalSB.Position := 0;
      HorizontalSB.Max := 0;
    end;
    VerticalSB.Min := 0;
    NMax := Round(Picture.Height * Zoom) - PB.Height;
    VerticalSB.Enabled := (NMax > 0) and  not IsStretched.Checked;
    if VerticalSB.Enabled then
    begin
      VerticalSB.Max :=  NMax;
      VerticalSB.PageSize := PB.Height;
      VerticalSB.Position := -Offset.Y;
    end else
    begin
      VerticalSB.Position := 0;
      VerticalSB.Max := 0;
    end;
  except
  end;
  SetByGUI := False;
  RemakeStatusLine;
end;

procedure TMainForm.ZoomIn;
begin
  if not IsStretched.Checked then
  begin
    Zoom := Zoom + 0.1;
    Offset.X := Min(0,Max(Min(0, Offset.X), PB.Width - Round(Picture.Width * Zoom)));
    Offset.Y := Min(0,Max(Min(0, Offset.Y), PB.Height - Round(Picture.Height * Zoom)));
    UpdateSB;
    PB.Invalidate
  end;
end;

procedure TMainForm.ZoomOut;
begin
  if not IsStretched.Checked then
  begin
    Zoom := Max(0.1, Zoom - 0.1);
    Offset.X := Min(0,Max(Min(0, Offset.X), PB.Width - Round(Picture.Width * Zoom)));
    Offset.Y := Min(0,Max(Min(0, Offset.Y), PB.Height - Round(Picture.Height * Zoom)));
    UpdateSB;
    PB.Invalidate
  end;
end;

procedure TMainForm.ZoomReset;
begin
  if not IsStretched.Checked then
  begin
    Zoom := 1;
    Offset := Point(0,0);
    UpdateSB;
    PB.Invalidate;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  str: string;
  i: Integer;
begin
  TitleStr := VERSION;
  Delete(TitleStr, 1, 4);
  Caption := TitleStr;
  //
  Offset.X := 0;
  Offset.Y := 0;
  LeftDown := False;
  Zoom := 1;
  Picture := TPicture.Create;
  FileList := TStringList.Create;
  FileList.Sorted := True;
  AllowedFilesExt := TStringList.Create;
  AllowedFilesExt.Add('.bmp');
  AllowedFilesExt.Add('.jpg');
  AllowedFilesExt.Add('.jpeg');
  AllowedFilesExt.Add('.png');
  AllowedFilesExt.Add('.pnm');
  AllowedFilesExt.Add('.ico');
  TopPanel.OnKeyDown := @FormKeyDown;
  LowerPanel.OnKeyDown := @FormKeyDown;
  ImagePanel.OnKeyDown := @FormKeyDown;
  for i := 1 to ParamCount do
  begin
    str := trim(ParamStr(i));
    if Copy(str,1,1) = '-' then
    begin
      if str = '-n' then
      begin
        IsStretched.Checked := False;
      end else
        writeln('Unkown Parameter ', str);
    end else
    begin
      if Filename = '' then
      begin
        if Copy(Str, Length(Str), 1) = DirectorySeparator then
        begin
          Dir := Str;
          GetFileList;
          Idx := 0;
          if FileList.Count = 0 then
          begin
            ShowMessage('No Files Found in '+ str);
          end else
            LoadFile(FileList.Strings[0]);
        end else
        begin
          Filename := str;
          Dir := ExtractFilePath(Filename);
          Filename := ExtractFileName(Filename);
          GetFileList;
          LoadFile(Filename);
        end;
      end;
    end;
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FileList.Free;
  Picture.Free;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  //writeln('key: ', Key);
  case Key of
    VK_LEFT, VK_BACK: PrevFile;
    VK_RIGHT, VK_SPACE: NextFile;
    VK_ESCAPE: MainForm.Close;
    VK_ADD: ZoomIn;
    VK_SUBTRACT: ZoomOut;
    VK_MULTIPLY: ZoomReset;
    VK_NUMPAD4: begin
      if not IsStretched.Checked then
      begin
        Offset.X := Min(0,Max(Min(0, Offset.X + 5), PB.Width - Round(Picture.Width * Zoom)));
        UpdateSB;
        PB.Invalidate;
      end;
    end;
    VK_NUMPAD6: begin
      if not IsStretched.Checked then
      begin
        Offset.X := Min(0,Max(Min(0, Offset.X - 5), PB.Width - Round(Picture.Width * Zoom)));
        UpdateSB;
        PB.Invalidate;
      end;
    end;
    VK_NUMPAD8: begin
      if not IsStretched.Checked then
      begin
        Offset.Y := Min(0,Max(Min(0, Offset.Y + 5), PB.Height - Round(Picture.Height * Zoom)));
        UpdateSB;
        PB.Invalidate;
      end;
    end;
    VK_NUMPAD2: begin
      if not IsStretched.Checked then
      begin
        Offset.Y := Min(0,Max(Min(0, Offset.Y - 5), PB.Height - Round(Picture.Height * Zoom)));
        UpdateSB;
        PB.Invalidate;
      end;
    end;
    Ord('F'):
    begin
      IsStretched.Checked := not IsStretched.Checked;
      UpdateSB;
      PB.Invalidate;
    end;
    Ord('O'): OpenButtonClick(Sender);
  end;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  UpdateSB;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  ImagePanel.SetFocus;
end;

procedure TMainForm.HorizontalSBChange(Sender: TObject);
begin
  if HorizontalSB.Enabled and not SetByGUI then
  begin
    Offset.X := -HorizontalSB.Position;
    PB.Invalidate;
  end;
end;

procedure TMainForm.IsStretchedClick(Sender: TObject);
begin
  ZoomInButton.Enabled := not IsStretched.Checked;
  ZoomOutButton.Enabled := not IsStretched.Checked;
  ZoomResetButton.Enabled := not IsStretched.Checked;
  UpdateSB;
  PB.Invalidate;
end;

procedure TMainForm.NextButtonClick(Sender: TObject);
begin
  NextButton.Enabled := False;
  NextFile;
  NextButton.Enabled := True;
end;

end.
