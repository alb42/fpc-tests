program Popup;
{$mode objfpc}{$H+}
uses
  {$if defined(MorphOS) or defined(Amiga68k)}
  amigalib,
  {$endif}
  sysUtils, Exec, Utility, intuition, agraphics, AmigaDos, ASL, mui, muihelper;

function StrObjFunc(Hook: PHook; Pop: PObject_; Msg: APTR): PtrInt;
var
  Str: PObject_;
  s, x: PChar;
  i: LongInt;
begin
  Str := PObject_(Msg);
  s := PChar(MH_Get(Str, MUIA_String_Contents));
  i := 0;
  repeat
    DoMethod(Pop, [MUIM_List_GetEntry, i, AsTag(@x)]);
    if not Assigned(x) then
    begin
      MH_Set(Pop, MUIA_List_Active, AsTag(MUIV_List_Active_Off));
      Break;
    end
    else
    if Trim(s) = Trim(x) then
    begin
      MH_Set(Pop, MUIA_List_Active, i);
      Break;
    end;
    i := i + 1;
  until False;
  StrObjFunc := MUI_True;
end;

function ObjStrFunc(Hook: PHook; Pop: PObject_; Msg: APTR): PtrInt;
var
  Str: PObject_;
  x: PChar;
begin
  Str := PObject_(Msg);
  DoMethod(Pop, [MUIM_List_GetEntry, AsTag(MUIV_List_GetEntry_Active), AsTag(@x)]);
  MH_Set(Str, MUIA_String_Contents, AsTag(x));
  ObjStrFunc := MUI_True;
end;

function WindowFunc(Hook: PHook; Pop: PObject_; Msg: APTR): PtrInt;
var
  Win: PObject_;
begin
  Win := PObject_(Msg);
  MH_Set(Win, MUIA_Window_DefaultObject, AsTag(Pop));
  WindowFunc := MUI_True;
end;

const
  PopNames: array[0..20] of PChar =
   ('Stefan Becker',
    'Dirk Federlein',
    'Georg Heßmann',
    'Martin Horneffer',
    'Martin Huttenloher',
    'Kai Iske',
    'Oliver Kilian',
    'Franke Mariak',
    'Klaus Melchior',
    'Armin Sander',
    'Matthias Scheler',
    'Andreas Schildbach',
    'Wolfgang Schildbach',
    'Christian Scholz',
    'Stefan Sommerfeld',
    'Markus Stipp',
    'Henri Veistera',
    'Albert Weinert',
    'Michael-W. Hohmann',
    'Stefan Burstroem',
    nil);


procedure StartMe;
var
  app, window, pop1, pop2, pop3, pop4, pop5, plist: PObject_;
  signals: LongWord;
  Running: Boolean = True;
  StrObjHook, ObjStrHook, WindowHook: THook;
  Active: Boolean;
begin
  MH_SetHook(StrObjHook, @StrObjFunc, nil);
  MH_SetHook(ObjStrHook, @ObjStrFunc, nil);
  MH_SetHook(WindowHook, @WindowFunc, nil);
  //
  try
    App := MH_Application([
      MUIA_Application_Title,       AsTag('Popup-Demo'),
      MUIA_Application_Version,     AsTag('$VER: Popup-Demo 19.5 (12.02.97)'),
      MUIA_Application_Copyright,   AsTag('©1993, Stefan Stuntz'),
      MUIA_Application_Author,      AsTag('Stefan Stuntz'),
      MUIA_Application_Description, AsTag('Demostrate popup objects.'),
      MUIA_Application_Base,        AsTag('POPUP'),

      SubWindow, AsTag(MH_Window(Window, [
        MUIA_Window_Title, AsTag('Popup Objects'),
        MUIA_Window_ID,    MAKE_ID('P','O','P','P'),
        WindowContents, AsTag(MH_VGroup([

          Child, AsTag(MH_ColGroup(2, [

            Child, AsTag(MH_Label2('File:')),
            Child, AsTag(MH_Popasl(Pop1, [
              MUIA_Popstring_String, AsTag(MH_KeyString(nil, 256, 'f')),
              MUIA_Popstring_Button, AsTag(MH_PopButton(PChar(MUII_PopFile))),
              ASLFR_TitleText, AsTag('Please select a file...'),
              TAG_DONE])),

            Child, AsTag(MH_Label2('Drawer:')),
            Child, AsTag(MH_Popasl(Pop2, [
              MUIA_Popstring_String, AsTag(MH_KeyString(nil, 256, 'd')),
              MUIA_Popstring_Button, AsTag(MH_PopButton(PChar(MUII_PopDrawer))),
              ASLFR_TitleText, AsTag('Please select a drawer...'),
              ASLFR_DrawersOnly, MUI_TRUE,
              TAG_DONE])),

            Child, AsTag(MH_Label2('Font:')),
            Child, AsTag(MH_Popasl(Pop3, [
              MUIA_Popstring_String, AsTag(MH_KeyString(nil, 80, 'o')),
              MUIA_Popstring_Button, AsTag(MH_PopButton(PChar(MUII_PopUp))),
              MUIA_Popasl_Type, ASL_FontRequest,
              ASLFO_TitleText, AsTag('Please select a font...'),
              TAG_DONE])),

            Child, AsTag(MH_Label2('Fixed Font:')),
            Child, AsTag(MH_Popasl(Pop4, [
              MUIA_Popstring_String, AsTag(MH_KeyString(nil, 80, 'i')),
              MUIA_Popstring_Button, AsTag(MH_PopButton(PChar(MUII_PopUp))),
              MUIA_Popasl_Type, ASL_FontRequest,
              ASLFO_TitleText, AsTag('Please select a fixed font...'),
              ASLFO_FixedWidthOnly, MUI_TRUE,
              TAG_DONE])),

            Child, AsTag(MH_Label2('Thanks To:')),
            Child, AsTag(MH_PopObject(Pop5, [
              MUIA_Popstring_String, AsTag(MH_KeyString(nil, 60, 'n')),
              MUIA_Popstring_Button, AsTag(MH_PopButton(PChar(MUII_PopUp))),
              MUIA_Popobject_StrObjHook, AsTag(@StrObjHook),
              MUIA_Popobject_ObjStrHook, AsTag(@ObjStrHook),
              MUIA_Popobject_WindowHook, AsTag(@WindowHook),
              MUIA_Popobject_Object, AsTag(MH_Listview(plist, [
                MUIA_Listview_List, AsTag(MH_List([
                  MUIA_Frame, InputListFrame,
                  MUIA_List_SourceArray, AsTag(@PopNames),
                  TAG_DONE])),
                TAG_DONE])),
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

    // A double click terminates the popping list with a successful return value.
    DoMethod(plist, [MUIM_Notify, MUIA_Listview_DoubleClick, MUI_TRUE,
      AsTag(pop5), 2, MUIM_Popstring_Close, MUI_TRUE]);

// input loop...

    MH_Set(window, MUIA_Window_Open, AsTag(True));

    if MH_Get(window, MUIA_Window_Open) <> 0 then
    begin
      Running := True;
      while Running do
      begin
        case Integer(DoMethod(App, [MUIM_Application_NewInput, AsTag(@signals)])) of
          MUIV_Application_ReturnID_Quit: begin
            Active := Boolean(MH_Get(pop1, MUIA_PopASL_Active));
            if not Active then Active := Boolean(MH_Get(pop2, MUIA_PopASL_Active));
            if not Active then Active := Boolean(MH_Get(pop3, MUIA_PopASL_Active));
            if not Active then Active := Boolean(MH_Get(pop4, MUIA_PopASL_Active));
            if Active then
              MUI_Request(app, window, 0, nil, 'OK', PChar('Cannot quit now, still'#10'some asl popups opened.'), [TAG_DONE])
            else
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
