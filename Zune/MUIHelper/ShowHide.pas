program ShowHide;
{$mode objfpc}{$H+}

// The ShowHide demo shows how to hide and show objects.

uses
  {$if defined(MorphOS) or defined(Amiga68k)}
  amigalib,
  {$endif}
  sysUtils, Exec, Utility, intuition, agraphics, AmigaDos, mui, muihelper;

procedure StartMe;
var
  app, window, cm1, cm2, cm3, cm4, cm5, bt1, bt2, bt3, bt4, bt5: PObject_;
  signals: LongWord;
  Running: Boolean = True;
begin
  //
  try
    App := MH_Application([
      MUIA_Application_Title,       AsTag('ShowHide'),
      MUIA_Application_Version,     AsTag('$VER: ShowHide 19.5 (12.02.97)'),
      MUIA_Application_Copyright,   AsTag('©1992/93, Stefan Stuntz'),
      MUIA_Application_Author,      AsTag('Stefan Stuntz'),
      MUIA_Application_Description, AsTag('Show object hiding.'),
      MUIA_Application_Base,        AsTag('SHOWHIDE'),

      SubWindow, AsTag(MH_Window(Window, [
        MUIA_Window_Title, AsTag('Show & Hide'),
        MUIA_Window_ID,    MAKE_ID('S','H','H','D'),

        WindowContents, AsTag(MH_HGroup([

          Child, AsTag(MH_VGroup([
            MUIA_Frame, GroupFrame,

            Child, AsTag(MH_HGroup([MUIA_Weight, 0,
              Child, AsTag(MH_CheckMark(cm1, True)),
              Child, AsTag(MH_CheckMark(cm2, True)),
              Child, AsTag(MH_CheckMark(cm3, True)),
              Child, AsTag(MH_CheckMark(cm4, True)),
              Child, AsTag(MH_CheckMark(cm5, True)),
              TAG_DONE])),

            Child, AsTag(MH_VGroup([
              Child, AsTag(MH_SimpleButton(bt1, 'Button 1')),
              Child, AsTag(MH_SimpleButton(bt2, 'Button 2')),
              Child, AsTag(MH_SimpleButton(bt3, 'Button 3')),
              Child, AsTag(MH_SimpleButton(bt4, 'Button 4')),
              Child, AsTag(MH_SimpleButton(bt5, 'Button 5')),
              Child, AsTag(MH_VSpace(0)),
              TAG_DONE])),
            TAG_DONE])),
          TAG_DONE])),
        TAG_DONE])),
      TAG_DONE]);

    if not Assigned(app) then
    begin
      writeln('Failed to create Application');
      Exit;
    end;

// Install notification events...

    DoMethod(window, [MUIM_Notify, MUIA_Window_CloseRequest, MUI_TRUE,
      AsTag(app), 2, AsTag(MUIM_Application_ReturnID), AsTag(MUIV_Application_ReturnID_Quit)]);

    DoMethod(cm1, [MUIM_Notify, MUIA_Selected, MUIV_EveryTime, AsTag(bt1), 3, MUIM_Set, MUIA_ShowMe, MUIV_TriggerValue]);
    DoMethod(cm2, [MUIM_Notify, MUIA_Selected, MUIV_EveryTime, AsTag(bt2), 3, MUIM_Set, MUIA_ShowMe, MUIV_TriggerValue]);
    DoMethod(cm3, [MUIM_Notify, MUIA_Selected, MUIV_EveryTime, AsTag(bt3), 3, MUIM_Set, MUIA_ShowMe, MUIV_TriggerValue]);
    DoMethod(cm4, [MUIM_Notify, MUIA_Selected, MUIV_EveryTime, AsTag(bt4), 3, MUIM_Set, MUIA_ShowMe, MUIV_TriggerValue]);
    DoMethod(cm5, [MUIM_Notify, MUIA_Selected, MUIV_EveryTime, AsTag(bt5), 3, MUIM_Set, MUIA_ShowMe, MUIV_TriggerValue]);

    MH_set(cm3, MUIA_Selected, MUI_FALSE);

// This is the ideal input loop for an object oriented MUI application.
// Everything is encapsulated in classes, no return ids need to be used,
// we just check if the program shall terminate.
// Note that MUIM_Application_NewInput expects sigs to contain the result
// from Wait() (or 0). This makes the input loop significantly faster.

    MH_Set(window, MUIA_Window_Open, AsTag(True));

    if MH_Get(window, MUIA_Window_Open) <> 0 then
    begin
      Running := True;
      while Running do
      begin
        case Integer(DoMethod(App, [MUIM_Application_NewInput, AsTag(@signals)])) of
          MUIV_Application_ReturnID_Quit: begin
            Running := False;
          end;
        end;
        if running and (signals <> 0) then
        begin
          signals := Wait(signals or SIGBREAKF_CTRL_C);
          if (signals and SIGBREAKF_CTRL_C) <>0 then
            Break;
        end;
      end;
    end;

    MH_Set(Window, MUIA_Window_Open, AsTag(False));

  finally
// Shut down...
    if Assigned(App) then
      MUI_DisposeObject(app);
  end;
end;

begin
  StartMe;
end.
