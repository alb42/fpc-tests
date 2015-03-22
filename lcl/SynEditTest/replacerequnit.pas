unit ReplaceReqUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls;

type

  { TReplaceRequest }

  TReplaceRequest = class(TForm)
    YesButton: TButton;
    NoButton: TButton;
    YesToAllButton: TButton;
    CancelButton: TButton;
    MsgPanel: TPanel;
    ButtonPanel: TPanel;
  private
    { private declarations }
  public
    function StartReq(ReqText: string): TModalResult;
  end;

var
  ReplaceRequest: TReplaceRequest;

implementation

{$R *.lfm}

{ TReplaceRequest }


function TReplaceRequest.StartReq(ReqText: string): TModalResult;
begin
  MsgPanel.Caption := ReqText;
  Result := ShowModal;
end;

end.

