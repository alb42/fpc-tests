unit SearchReplaceUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, SynEdit, SynEditTypes;

type

  { TSearchReplaceWin }

  TSearchReplaceWin = class(TForm)
    IsBackwards: TCheckBox;
    InSelection: TCheckBox;
    ResultPanel: TPanel;
    SearchBack: TButton;
    UseRegExp: TCheckBox;
    SearchSettings: TPanel;
    SearchAgain: TButton;
    SearchButton: TButton;
    ReplaceLabel: TLabel;
    SearchEdit: TEdit;
    ReplaceEdit: TEdit;
    Label1: TLabel;
    procedure SearchAgainClick(Sender: TObject);
    procedure SearchBackClick(Sender: TObject);
    procedure SearchButtonClick(Sender: TObject);
    procedure SearchEditEditingDone(Sender: TObject);
  private
    SearchString: string;
    ReplaceString: string;
    SearchSett: TSynSearchOptions;
    ReplaceMode: Boolean;
    procedure GetSearchSettings;
  public
    SynEdit1: TSynEdit;

    procedure StartReq(AsReplace: Boolean);
  end;

var
  SearchReplaceWin: TSearchReplaceWin;

implementation

{$R *.lfm}

{ TSearchReplaceWin }

{
ssoMatchCase, ssoWholeWord,
      ssoBackwards,
      ssoEntireScope, ssoSelectedOnly,
      ssoReplace, ssoReplaceAll,
      ssoPrompt,
      ssoSearchInReplacement,    // continue search-replace in replacement (with ssoReplaceAll) // replace recursive
      ssoRegExpr, ssoRegExprMultiLine,
      ssoFindContinue
}

procedure TSearchReplaceWin.SearchButtonClick(Sender: TObject);
begin
  if SearchEdit.Text = '' then
  begin
    ResultPanel.Caption := 'Nothing to find';
    Exit;
  end;
  ResultPanel.caption := '';
  if ReplaceMode then
  begin
    SearchString := SearchEdit.Text;
    ReplaceString := ReplaceEdit.Text;
    GetSearchSettings;
    Close;
    if not SynEdit1.SearchReplace(SearchString, ReplaceString, SearchSett + [ssoEntireScope, ssoReplaceAll, ssoPrompt]) > 0 then
    begin
      ResultPanel.Caption:= 'Nothing found';
      Show;
    end;
  end else
  begin
    GetSearchSettings;
    SearchString := SearchEdit.Text;
    Close;
    if not SynEdit1.SearchReplace(SearchString, '', SearchSett + [ssoEntireScope]) > 0 then
    begin
      ResultPanel.Caption:= 'Nothing found';
      Show;
    end;
  end;
end;

procedure TSearchReplaceWin.SearchEditEditingDone(Sender: TObject);
begin
  {$ifdef AROS}
  SearchButtonClick(Sender);
  {$endif}
end;

procedure TSearchReplaceWin.GetSearchSettings;
begin
  SearchSett := [];
  if IsBackwards.Checked then
    Include(SearchSett, ssoBackwards);
  if InSelection.Checked then
    Include(SearchSett, ssoSelectedOnly);
  if UseRegExp.Checked then
    Include(SearchSett, ssoRegExpr);
end;

procedure TSearchReplaceWin.SearchAgainClick(Sender: TObject);
begin
  SynEdit1.SearchReplace(SearchString, '', SearchSett + [ssoFindContinue]);
end;

procedure TSearchReplaceWin.SearchBackClick(Sender: TObject);
begin
  SynEdit1.SearchReplace(SearchString, '', SearchSett + [ssoBackwards,ssoFindContinue]);
end;

procedure TSearchReplaceWin.StartReq(AsReplace: Boolean);
begin
  ReplaceMode := AsReplace;
  ResultPanel.caption := '';
  if AsReplace then
    SearchButton.Caption := 'Replace'
  else
    SearchButton.Caption := 'Find';
  ReplaceLabel.visible := AsReplace;
  ReplaceEdit.Visible := AsReplace;
  SearchAgain.Visible:= not AsReplace;
  SearchBack.Visible:= not AsReplace;
  Show;
  BringToFront;
end;

end.

