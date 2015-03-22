program EdiSyn;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, MainUnit, GotLineUnit, SearchReplaceUnit, ReplaceReqUnit, PrefsUnit,
  FrameUnit, MikroStatUnit;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TGoToLineWin, GoToLineWin);
  Application.CreateForm(TSearchReplaceWin, SearchReplaceWin);
  Application.CreateForm(TReplaceRequest, ReplaceRequest);
  Application.Run;
end.

