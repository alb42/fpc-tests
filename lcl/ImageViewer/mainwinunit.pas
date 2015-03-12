unit MainWinUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, LCLType;

const
  VERSION = '$VER APict 1.0 (12.03.2015)';

type
  { TMainForm }

  TMainForm = class(TForm)
    OpenButton: TBitBtn;
    OpenDialog: TOpenDialog;
    PrevButton: TBitBtn;
    NextButton: TBitBtn;
    Image1: TImage;
    SizeLabel: TLabel;
    TopPanel: TPanel;
    LowerPanel: TPanel;
    ImagePanel: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure NextButtonClick(Sender: TObject);
    procedure OpenButtonClick(Sender: TObject);
    procedure PrevButtonClick(Sender: TObject);
  private
    Dir: string;
    Filename: string;
    Idx: Integer;
    FileList: TStringList;
    AllowedFilesExt: TStringList;

    procedure GetFileList;
    procedure LoadFile(AFileName: String);
    procedure NextFile;
    procedure PrevFile;
    procedure RemakeStatusLine;
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

procedure TMainForm.PrevButtonClick(Sender: TObject);
begin
  PrevButton.Enabled:=False;
  PrevFile;
  PrevButton.Enabled:=True;
end;

procedure TMainForm.GetFileList;
var
  Info: TSearchRec;
  Ext: String;
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

procedure TMainForm.LoadFile(AFileName: String);
begin
  try
    Filename := AFilename;
    Idx := FileList.IndexOf(Filename);
    if Idx < 0 then
    begin
      FileList.Add(Filename);
      Idx := FileList.IndexOf(Filename);
    end;
    Caption := Filename + '(' + IntToStr(Idx + 1) + '/' + IntToStr(FileList.Count) + ')';
    Image1.Picture.LoadFromFile(IncludeTrailingPathDelimiter(Dir) + Filename);
    RemakeStatusLine;
  except
    on E:Exception do
      Showmessage('Cannot open file ' + Filename + ' (' + E.Message + ')');
  end;
end;

procedure TMainForm.NextFile;
var
  Res: Integer;
begin
  if FileList.Count = 0 then
  begin
    OpenButtonClick(nil);
    Exit;
  end;
  if Idx < FileList.Count - 1 then
  begin
    LoadFile(FileList.Strings[Idx + 1]);
  end else
  begin
    Res := MessageDlg('No More Images', 'End of List, restart from beginning?',mtConfirmation, [mbYes, mbNo], 0, mbYes);
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
  end else
  begin
    if MessageDlg('No More Images', 'Start of List, restart from end?',mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
      LoadFile(FileList.Strings[FileList.Count - 1]);
  end;
end;

procedure TMainForm.RemakeStatusLine;
var
  F: Single;
  w,h: Integer;
begin
  if Filename <> '' then
  begin
    if Image1.Stretch then
    begin
      F := (1.0 * Image1.Picture.Width) / Image1.Picture.Height;
      if F * Image1.Height > Image1.Width then
      begin
        w := Image1.Width;
        h := Round(w / F);
      end else
      begin
        h := Image1.Height;
        w := Round(h * f)
      end;
      SizeLabel.Caption := Format('Info: (%dpx X %dpx)  Scaled to (%dpx x %dpx)', [Image1.Picture.Width, Image1.Picture.Height, w, h]);
    end else
    begin
      SizeLabel.Caption := Format('Info: (%dpx X %dpx)', [Image1.Picture.Width, Image1.Picture.Height]);
    end;
  end else
    SizeLabel.Caption := '<no file open>';
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  str: String;
begin
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
  if ParamCount > 0 then
  begin
    Filename := ParamStr(1);
    Dir := ExtractFilePath(Filename);
    Filename := ExtractFileName(Filename);
    GetFileList;
    LoadFile(Filename);
  end;
  str := VERSION;
  Delete(str, 1,4);
  Caption := str;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FileList.Free;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_LEFT,VK_BACK: PrevFile;
    VK_RIGHT,VK_SPACE: NextFile;
    Ord('F'): begin
      Image1.Stretch:=not Image1.Stretch;
      Image1.Proportional:= Image1.Stretch;
      RemakeStatusLine;
    end;
    Ord('O'): OpenButtonClick(Sender);
    VK_ESCAPE: MainForm.Close;
  end;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  RemakeStatusLine;
end;

procedure TMainForm.NextButtonClick(Sender: TObject);
begin
  NextButton.Enabled:=False;
  NextFile;
  NextButton.Enabled:=True;
end;

end.

