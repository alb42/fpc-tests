program Layout;
{$mode objfpc}{$H+}
uses
  {$if defined(MorphOS) or defined(Amiga)}
  amigalib,
  {$endif}
  Exec, Utility, intuition, agraphics, AmigaDos, mui, muihelper;

const
  ID_REWARD = 1;

var
  App : PObject_;
  LastNum: LongInt = -1;

// Custom layout function.
// Perform several actions according to the messages lm_Type
// field. Note that you must return MUILM_UNKNOWN if you do
// not implement a specific lm_Type.

function LayoutFunc(Hook: PHook; Obj: PObject_; Msg: Pointer): PtrInt;
var
  lm: PMUI_LayoutMsg;
  Child, CState: PObject_;
  maxminwidth, maxminheight: Integer;
  l, t, mw, mh: Integer;
begin
  lm := PMUI_LayoutMsg(Msg);
  case lm^.lm_Type of
    MUILM_MINMAX: begin
      // MinMax calculation function. When this is called,
      // the children of your group have already been asked
      // about their min/max dimension so you can use their
      // dimensions to calculate yours.
      //
      // In this example, we make our minimum size twice as
      // big as the biggest child in our group.
      CState := PObject_(lm^.lm_Children^.mlh_Head);
      maxminwidth := 0;
      maxminheight := 0;

      // find out biggest widths & heights of our children
      Child := NextObject(@CState);
      while Assigned(Child) do
      begin
        if (maxminwidth < MUI_MAXMAX) and (OBJ_minwidth(Child) > maxminwidth) then
          maxminwidth := OBJ_minwidth(Child);
        if (maxminheight < MUI_MAXMAX) and (OBJ_minheight(Child) > maxminheight) then
          maxminheight := OBJ_minheight(Child);
        Child := NextObject(@CState);
      end;
      // set the result fields in the message
      lm^.lm_MinMax.MinWidth  := 2 * maxminwidth;
      lm^.lm_MinMax.MinHeight := 2 * maxminheight;
      lm^.lm_MinMax.DefWidth  := 4 * maxminwidth;
      lm^.lm_MinMax.DefHeight := 4 * maxminheight;
      lm^.lm_MinMax.MaxWidth  := MUI_MAXMAX;
      lm^.lm_MinMax.MaxHeight := MUI_MAXMAX;
      //
      LayoutFunc := 0;
    end;
    MUILM_LAYOUT: begin
      // Layout function. Here, we have to call MUI_Layout() for each
      // our children. MUI wants us to place them in a rectangle
      // defined by (0,0,lm->lm_Layout.Width-1,lm->lm_Layout.Height-1)
      // You are free to put the children anywhere in this rectangle.
      //
      // If you are a virtual group, you may also extend
      // the given dimensions and place your children anywhere. Be sure
      // to return the dimensions you need in lm->lm_Layout.Width and
      // lm->lm_Layout.Height in this case.
      //
      // Return TRUE if everything went ok, FALSE on error.
      // Note: Errors during layout are not easy to handle for MUI.
      //       Better avoid them!
      CState := PObject_(lm^.lm_Children^.mlh_Head);
      Child := NextObject(@CState);
      while Assigned(Child) do
      begin
        mw := OBJ_minwidth(Child);
        mh := OBJ_minheight(Child);
        l := Round(Random(lm^.lm_Layout.Width - mw));
        t := Round(Random(lm^.lm_Layout.Height - mh));
        if not MUI_Layout(Child, l, t, mw, mh, 0) then
        begin
          Result := MUI_FALSE;
          Exit;
        end;
        Child := NextObject(@CState);
      end;
      LayoutFunc := MUI_TRUE;
    end;
  end;
end;

function PressFunc(Hook: PHook; Obj: PObject_; Msg: Pointer): PtrInt;
begin

  Inc(LastNum);

  if Lastnum <> PLongInt(Msg)^ then
  begin
    DisplayBeep(nil);
    LastNum := -1;
  end
  else if lastnum = 7 then
  begin
    DoMethod(app, [MUIM_Application_ReturnID, ID_REWARD]);
    lastnum := -1;
  end;

  Result := 0;
end;



procedure StartMe;
var
  Window: PObject_;
  b: array[0..7] of APTR;
  Yeah: APTR;
  PressHook, LayoutHook: THook;
  signals: LongWord;
  Running: Boolean = True;
  i: Integer;
begin
  Randomize;
  //
  MH_SetHook(PressHook, @PressFunc, nil);
  MH_SetHook(LayoutHook, @LayoutFunc, nil);
  //
  try
    App := MH_Application([
      MUIA_Application_Title,       AsTag('Layout'),
      MUIA_Application_Version,     AsTag('$VER: Layout 19.5 (12.02.97)'),
      MUIA_Application_Copyright,   AsTag('©1993, Stefan Stuntz'),
      MUIA_Application_Author,      AsTag('Stefan Stuntz'),
      MUIA_Application_Description, AsTag('Demonstrate custom layout hooks.'),
      MUIA_Application_Base,        AsTag('Layout'),

      SubWindow, AsTag(MH_Window(Window, [
        MUIA_Window_Title, AsTag('Custom Layout'),
        MUIA_Window_ID,    MAKE_ID('C','L','S','3'),
        WindowContents, AsTag(MH_VGroup([
          Child, AsTag(MH_Text(
            PChar(MUIX_C + 'Demonstration of a custom layout hook.'#10'Since it''s usually no good idea to have overlapping'#10'objects, your hooks should be more sophisticated.'), [
            MUIA_Background, MUII_TextBack,
            TAG_DONE])),

          Child, AsTag(MH_VGroup(GroupFrame, [
            MUIA_Group_LayoutHook, AsTag(@LayoutHook),
            Child, AsTag(MH_SimpleButton(b[0], 'Click')),
            Child, AsTag(MH_SimpleButton(b[1], 'me')),
            Child, AsTag(MH_SimpleButton(b[2], 'in')),
            Child, AsTag(MH_SimpleButton(b[3], 'correct')),
            Child, AsTag(MH_SimpleButton(b[4], 'sequence')),
            Child, AsTag(MH_SimpleButton(b[5], 'to')),
            Child, AsTag(MH_SimpleButton(b[6], 'be')),
            Child, AsTag(MH_SimpleButton(b[7], 'rewarded!')),

            // Child, AsTag(MH_Scrollbar([MUIA_Group_Horiz, MUI_TRUE, TAG_DONE])),

            Child, AsTag(MH_SimpleButton(Yeah, 'Yeah!'#10'You did it!'#10'Click to quit!')),
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

    DoMethod(yeah, [MUIM_Notify, MUIA_Pressed, MUI_FALSE,
      AsTag(App),2, AsTag(MUIM_Application_ReturnID), AsTag(MUIV_Application_ReturnID_Quit)]);

    for i := 0 to 7 do
      DoMethod(b[i], [MUIM_Notify, MUIA_Pressed, MUI_FALSE,
        AsTag(App), 3, MUIM_CallHook, AsTag(@PressHook), i]);

    MH_Set(Yeah, MUIA_ShowMe, MUI_FALSE);

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

          ID_REWARD: begin
            MH_Set(Yeah, MUIA_ShowMe, MUI_TRUE);
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
