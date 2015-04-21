unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, Forms, Controls,
  {$ifdef AROS}
  SynUniHighlighter,
  {$endif}
  Graphics, Dialogs, Menus;

type

  { TForm1 }

  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    OpenDialog1: TOpenDialog;
    SynEdit1: TSynEdit;
    {$ifdef AROS}
    SynUniSyn1: TSynUniSyn;
    {$endif}
    procedure FormCreate(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation
{$ifdef AROS}
uses
  SynUnidesigner;
{$endif}

{$R *.lfm}

{ TForm1 }

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    SynEdit1.Lines.LoadFromFile(OpenDialog1.FileName);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  {$ifdef AROS}
  SynUniSyn1 := TSynUniSyn.Create(application);
  SynEdit1.Highlighter := SynUniSyn1;
  try
    OpenDialog1.FileName := 'Highlighters/Delphi.hgl';
    SynUniSyn1.LoadFromFile(OpenDialog1.FileName);
    Caption := OpenDialog1.FileName;
    SynEdit1.Text := SynUniSyn1.SampleSource;
  except
  end;
  {$endif}
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
  {$ifdef AROS}
  if OpenDialog1.Execute then
  begin
    SynUniSyn1.LoadFromFile(OpenDialog1.FileName);
    Caption := OpenDialog1.FileName;
    SynEdit1.Text := SynUniSyn1.SampleSource;
  end;
  {$endif}
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  {$ifdef AROS}
  TSynUniDesigner.EditHighlighter(SynUniSyn1, 'Edit');
  {$endif}
end;

end.

