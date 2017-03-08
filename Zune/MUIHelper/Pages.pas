program Layout;
{$mode objfpc}{$H+}
uses
  {$if defined(MorphOS) or defined(Amiga68k)}
  amigalib,
  {$endif}
  Exec, Utility, intuition, agraphics, AmigaDos, mui, muihelper;

const
  Sex: array[0..2] of PChar = ('male', 'female', nil);
  Pages: array[0..4] of PChar = ('Race','Class','Armor','Level',nil);
  Races: array[0..5] of PChar = ('Human','Elf','Dwarf','Hobbit','Gnome',nil);
  Classes: array[0..6] of PChar = ('Warrior','Rogue','Bard','Monk','Magician','Archmage',nil);

const
  ID_REWARD = 1;

procedure StartMe;
var
  App, Window : PObject_;
  signals: LongWord;
  Running: Boolean = True;
begin
  //
  try
    App := MH_Application([
      MUIA_Application_Title,       AsTag('Pages-Demo'),
      MUIA_Application_Version,     AsTag('$VER: Pages-Demo 19.5 (12.02.97)'),
      MUIA_Application_Copyright,   AsTag('©1992/93, Stefan Stuntz'),
      MUIA_Application_Author,      AsTag('Stefan Stuntz'),
      MUIA_Application_Description, AsTag('Show MUIs Page Groups'),
      MUIA_Application_Base,        AsTag('PAGESDEMO'),

      SubWindow, AsTag(MH_Window(Window, [
        MUIA_Window_Title, AsTag('Character Definition'),
        MUIA_Window_ID,    MAKE_ID('P','A','G','E'),

        WindowContents, AsTag(MH_VGroup([
          Child, AsTag(MH_ColGroup(2, [
            Child, AsTag(MH_Label2('Name:')), Child, AsTag(MH_String('Frodo', 32)),
            Child, AsTag(MH_Label1('Sex:')), Child, AsTag(MH_Cycle(@Sex)),
            TAG_DONE])),

          Child, AsTag(MH_VSpace(2)),

          Child, AsTag(MH_RegisterGroup(@Pages, [
            MUIA_Register_Frame, MUI_TRUE,
            Child, AsTag(MH_HCenter(MH_Radio(nil, @Races))),
            Child, AsTag(MH_HCenter(MH_Radio(nil, @Classes))),

            Child, AsTag(MH_HGroup([
              Child, AsTag(MH_HSpace(0)),
              Child, AsTag(MH_ColGroup(2, [
                Child, AsTag(MH_Label1('Cloak:')), Child, AsTag(MH_CheckMark(True)),
                Child, AsTag(MH_Label1('Shield:')), Child, AsTag(MH_CheckMark(True)),
                Child, AsTag(MH_Label1('Gloves:')), Child, AsTag(MH_CheckMark(True)),
                Child, AsTag(MH_Label1('Helmet:')), Child, AsTag(MH_CheckMark(True)),
                TAG_DONE])),
              Child, AsTag(MH_HSpace(0)),
              TAG_DONE])),

            Child, AsTag(MH_ColGroup(2, [
              Child, AsTag(MH_Label('Experience:'  )), Child, AsTag(MH_Slider(0,100, 3)),
              Child, AsTag(MH_Label('Strength:'    )), Child, AsTag(MH_Slider(0,100,42)),
              Child, AsTag(MH_Label('Dexterity:'   )), Child, AsTag(MH_Slider(0,100,24)),
              Child, AsTag(MH_Label('Condition:'   )), Child, AsTag(MH_Slider(0,100,39)),
              Child, AsTag(MH_Label('Intelligence:')), Child, AsTag(MH_Slider(0,100,74)),
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

    DoMethod(window, [MUIM_Notify, MUIA_Window_CloseRequest, MUI_TRUE,
      AsTag(app), 2, AsTag(MUIM_Application_ReturnID), AsTag(MUIV_Application_ReturnID_Quit)]);

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
    if Assigned(App) then
      MUI_DisposeObject(app);
  end;
end;

begin
  StartMe;
end.
