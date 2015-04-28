unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    PageControl1: TPageControl;
    Panel1: TPanel;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure PageControl1Changing(Sender: TObject; var AllowChange: Boolean);
    procedure TabSheet3MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
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

procedure TForm1.Button6Click(Sender: TObject);
begin
  PageControl1.ActivePageIndex:=0;
end;

procedure TForm1.CheckBox2Click(Sender: TObject);
begin
  PageControl1.Enabled := CheckBox2.Checked;
end;

procedure TForm1.CheckBox3Click(Sender: TObject);
begin
  PageControl1.Visible := CheckBox3.Checked;
end;

procedure TForm1.PageControl1Changing(Sender: TObject; var AllowChange: Boolean
  );
begin
  AllowChange := not CheckBox1.Checked;
end;

procedure TForm1.TabSheet3MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  Caption := IntToStr(X) + ', ' + IntToStr(Y);
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  PageControl1.ActivePageIndex:=1;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  PageControl1.ActivePageIndex:=2;
end;

end.

