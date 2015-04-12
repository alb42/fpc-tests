program EdiSyn;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, MainUnit, GotLineUnit, SearchReplaceUnit, ReplaceReqUnit, PrefsUnit,
  FrameUnit, MikroStatUnit, AboutUnit, ATTabs, SearchAllUnit, 
SearchAllResultsUnit, PrefsWinUnit, startprogunit, OutPutUnit;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMainWindow, MainWindow);
  Application.CreateForm(TGoToLineWin, GoToLineWin);
  Application.CreateForm(TSearchReplaceWin, SearchReplaceWin);
  Application.CreateForm(TReplaceRequest, ReplaceRequest);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TSearchAllForm, SearchAllForm);
  Application.CreateForm(TSearchResultsWin, SearchResultsWin);
  Application.CreateForm(TPrefsWin, PrefsWin);
  Application.CreateForm(TOutWindow, OutWindow);
  Application.Run;
end.

