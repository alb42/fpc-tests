unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    ComboBox1: TComboBox;
    StaticText1: TStaticText;
    procedure Button1Click(Sender: TObject);
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
  ComboBox1.Clear;
  ComboBox1.Items.add('number 1');
  ComboBox1.Items.add('number 2');
  ComboBox1.Items.add('number 3');
  ComboBox1.Items.add('number 4');
  ComboBox1.Items.add('number 5');
  ComboBox1.Items.add('number 6');
  StaticText1.Caption:='Entries changed';
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  if (ComboBox1.ItemIndex <= 0) or (ComboBox1.ItemIndex >= ComboBox1.items.Count) then
    StaticText1.Caption:='Change: ' + IntToStr(ComboBox1.ItemIndex) + ' -> ' + ComboBox1.Text
  else
    StaticText1.Caption:='Change: ' + IntToStr(ComboBox1.ItemIndex) + ' -> ' + ComboBox1.Text + ' -> ' + ComboBox1.items.Strings[Combobox1.itemindex];
end;

end.

