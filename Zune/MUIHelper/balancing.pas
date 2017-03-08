program balancing;

uses
  {$if defined(MorphOS) or defined(Amiga68k)}
  amigalib,
  {$endif}
  Exec, Utility, intuition, AmigaDos, mui, muihelper;

procedure StartMe;
var
  App, Window: PObject_;
  Sigs: LongInt;
begin
  app := MH_Application([
    MUIA_Application_Title,       AsTag('BalanceDemo'),
    MUIA_Application_Version,     AsTag('$VER: BalanceDemo 19.5 (12.02.97)'),
    MUIA_Application_Copyright,   AsTag('©1995, Stefan Stuntz'),
    MUIA_Application_Author,      AsTag('Stefan Stuntz'),
    MUIA_Application_Description, AsTag('Show balancing groups'),
    MUIA_Application_Base,        AsTag('BALANCEDEMO'),

    SubWindow, AsTag(MH_Window(Window, [
      MUIA_Window_Title,  AsTag('Balancing Groups'),
      MUIA_Window_ID,     MAKE_ID('B','A','L','A'),
      MUIA_Window_Width , MUIV_Window_Width_Screen(50),
      MUIA_Window_Height, MUIV_Window_Height_Screen(50),

      WindowContents, AsTag(MH_HGroup([

        Child, AsTag(MH_VGroup(GroupFrame, [MUIA_Weight, 15,
          Child, AsTag(MH_Rectangle(TextFrame, [MUIA_Weight,  50, TAG_END])),
          Child, AsTag(MH_Rectangle(TextFrame, [MUIA_Weight, 100, TAG_END])),
          Child, AsTag(MH_Balance([MUIA_CycleChain, 1, TAG_END])),
          Child, AsTag(MH_Rectangle(TextFrame, [MUIA_Weight, 200, TAG_END])),
          TAG_END])),

        Child, AsTag(MH_Balance([MUIA_CycleChain, 1, TAG_END])),

        Child, AsTag(MH_VGroup([
          Child, AsTag(MH_HGroup(GroupFrame, [
            Child, AsTag(MH_Rectangle(TextFrame, [MUIA_ObjectID, 123, TAG_END])),
            Child, AsTag(MH_Balance([MUIA_CycleChain, 1, TAG_END])),
            Child, AsTag(MH_Rectangle(TextFrame, [MUIA_ObjectID, 456, TAG_END])),
            TAG_END])),
          Child, AsTag(MH_HGroup(GroupFrame, [
            Child, AsTag(MH_Rectangle(TextFrame, [TAG_END])),
            Child, AsTag(MH_Balance([MUIA_CycleChain, 1, TAG_END])),
            Child, AsTag(MH_Rectangle(TextFrame, [TAG_END])),
            Child, AsTag(MH_Balance([MUIA_CycleChain, 1, TAG_END])),
            Child, AsTag(MH_Rectangle(TextFrame, [TAG_END])),
            Child, AsTag(MH_Balance([MUIA_CycleChain, 1, TAG_END])),
            Child, AsTag(MH_Rectangle(TextFrame, [TAG_END])),
            Child, AsTag(MH_Balance([MUIA_CycleChain, 1, TAG_END])),
            Child, AsTag(MH_Rectangle(TextFrame, [TAG_END])),
            TAG_END])),

          Child, AsTag(MH_HGroup(GroupFrame, [
            Child, AsTag(MH_HGroup([
              Child, AsTag(MH_Rectangle(TextFrame, [TAG_END])),
              Child, AsTag(MH_Balance([MUIA_CycleChain, 1, TAG_END])),
              Child, AsTag(MH_Rectangle(TextFrame, [TAG_END])),
              TAG_END])),
            Child, AsTag(MH_Balance([MUIA_CycleChain, 1, TAG_END])),
            Child, AsTag(MH_HGroup([
              Child, AsTag(MH_Rectangle(TextFrame, [TAG_END])),
              Child, AsTag(MH_Balance([MUIA_CycleChain, 1, TAG_END])),
              Child, AsTag(MH_Rectangle(TextFrame, [TAG_END])),
              TAG_END])),
            TAG_END])),
          Child, AsTag(MH_HGroup(GroupFrame, [
            Child, AsTag(MH_Rectangle(TextFrame, [MUIA_Weight,  50, TAG_END])),
            Child, AsTag(MH_Rectangle(TextFrame, [MUIA_Weight, 100, TAG_END])),
            Child, AsTag(MH_Balance([MUIA_CycleChain, 1, TAG_END])),
            Child, AsTag(MH_Rectangle(TextFrame, [MUIA_Weight, 200, TAG_END])),
            TAG_END])),
          Child, AsTag(MH_HGroup(GroupFrame, [
            Child, AsTag(MH_SimpleButton('Also')),
            Child, AsTag(MH_Balance([MUIA_CycleChain, 1, TAG_END])),
            Child, AsTag(MH_SimpleButton('Try')),
            Child, AsTag(MH_Balance([MUIA_CycleChain, 1, TAG_END])),
            Child, AsTag(MH_SimpleButton('Sizing')),
            Child, AsTag(MH_Balance([MUIA_CycleChain, 1, TAG_END])),
            Child, AsTag(MH_SimpleButton('With')),
            Child, AsTag(MH_Balance([MUIA_CycleChain, 1, TAG_END])),
            Child, AsTag(MH_SimpleButton('Shift')),
            TAG_END])),
          Child, AsTag(MH_HGroup(GroupFrame, [
            Child, AsTag(MH_Label('Label 1:')),
            Child, AsTag(MH_Text('data...', [TAG_END])),
            Child, AsTag(MH_Balance([MUIA_CycleChain, 1, TAG_END])),
            Child, AsTag(MH_Label('Label 2:')),
            Child, AsTag(MH_Text('more data...', [TAG_END])),
            TAG_END])),
          TAG_END])),
        TAG_END])),
      TAG_END])),

    TAG_END]);

  if not Assigned(app) then
  begin
    writeln('Failed to create Application');
    Exit;
  end;

  DoMethod(window, [MUIM_Notify, MUIA_Window_CloseRequest, MUI_TRUE,
    AsTag(app), 2, AsTag(MUIM_Application_ReturnID), AsTag(MUIV_Application_ReturnID_Quit)]);

(*
** This is the ideal input loop for an object oriented MUI application.
** Everything is encapsulated in classes, no return ids need to be used,
** we just check if the program shall terminate.
** Note that MUIM_Application_NewInput expects sigs to contain the result
** from Wait() (or 0). This makes the input loop significantly faster.
*)

  MH_Set(Window, MUIA_Window_Open, AsTag(True));

  if MH_Get(Window, MUIA_Window_Open) <> 0 then
  begin
    while Integer(DoMethod(app, [MUIM_Application_NewInput, AsTag(@sigs)])) <> MUIV_Application_ReturnID_Quit do
    begin
      if Sigs <> 0 then
      begin
        Sigs := Wait(sigs or SIGBREAKF_CTRL_C);
        if (Sigs and SIGBREAKF_CTRL_C) <>0 then
          Break;
      end;
    end;
  end;

(*
** Shut down...
*)

  MH_Set(Window, MUIA_Window_Open, AsTag(True));

  MUI_DisposeObject(app);
end;



begin
  StartMe;
end.
