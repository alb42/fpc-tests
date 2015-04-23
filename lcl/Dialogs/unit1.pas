unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ChooseFixed: TCheckBox;
    ChooseStyle: TCheckBox;
    FindDialog1: TFindDialog;
    FontDialog1: TFontDialog;
    Label1: TLabel;
    ReplaceDialog1: TReplaceDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  if FindDialog1.Execute then
    Caption := FindDialog1.FindText;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  FontDialog1.Font := Label1.Font;
  if ChooseFixed.Checked then
    FontDialog1.Options:=FontDialog1.Options + [fdFixedPitchOnly]
  else
    FontDialog1.Options:=FontDialog1.Options - [fdFixedPitchOnly];
  if ChooseStyle.Checked then
    FontDialog1.Options:=FontDialog1.Options - [fdNoStyleSel]
  else
    FontDialog1.Options:=FontDialog1.Options + [fdNoStyleSel];
  if FontDialog1.Execute then
  begin
    Label1.Font := FontDialog1.Font;
    Caption := FontDialog1.Font.Name;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if ReplaceDialog1.Execute then
    Caption := ReplaceDialog1.FindText;
end;

end.

