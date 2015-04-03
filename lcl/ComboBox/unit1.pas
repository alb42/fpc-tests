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
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    StaticText1: TStaticText;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
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
  ComboBox1.Items.BeginUpdate;
  ComboBox1.Items.Clear;
  ComboBox1.Items.add('number 1');
  ComboBox1.Items.add('number 2');
  ComboBox1.Items.add('number 3');
  ComboBox1.Items.add('number 4');
  ComboBox1.Items.add('number 5');
  ComboBox1.Items.add('number 6');
  ComboBox1.Items.EndUpdate;
  ComboBox2.Items.Assign(ComboBox1.Items);
  StaticText1.Caption:='Entries changed';
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  ComboBox1.ItemIndex := 2;
  ComboBox2.ItemIndex := 2;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
var
  cbx: TComboBox;
begin
  if not (Sender is TComboBox) then
    Exit;
  Cbx := TComboBox(Sender);
  if (cbx.ItemIndex < 0) or (cbx.ItemIndex >= cbx.items.Count) then
    StaticText1.Caption:= cbx.Name +' Change nok: ' + IntToStr(cbx.ItemIndex) + ' -> ' + cbx.Text
  else
    StaticText1.Caption:=cbx.Name+ ' Change ok: ' + IntToStr(cbx.ItemIndex) + ' -> ' + cbx.Text + ' -> ' + cbx.items.Strings[cbx.itemindex];
end;

end.

