program class3;
{$mode objfpc}{$H+}

//***************************************************************************
// Here is the beginning of our simple new class...                         *
//***************************************************************************

uses
  {$if defined(MorphOS) or defined(Amiga68k)}
  amigalib,
  {$endif}
  sysutils, Exec, Utility, intuition, agraphics, AmigaDos, mui, muihelper;


// This is the instance data for our custom class.
type
  TMyData = record
    x, y, sx, sy: LongInt;
  end;
  PMyData = ^TMyData;

// AskMinMax method will be called before the window is opened
// and before layout takes place. We need to tell MUI the
// minimum, maximum and default size of our object.

function mAskMinMax(cl: PIClass; Obj: PObject_; Msg: PMUIP_AskMinMax): longword;
begin
  mAskMinMax := 0;

  // let our superclass first fill in what it thinks about sizes.
  // this will e.g. add the size of frame and inner spacing.

  DoSuperMethodA(cl, obj, msg);

  // now add the values specific to our object. note that we
  // indeed need to *add* these values, not just set them!

  msg^.MinMaxInfo^.MinWidth  := msg^.MinMaxInfo^.MinWidth + 100;
  msg^.MinMaxInfo^.DefWidth  := msg^.MinMaxInfo^.DefWidth + 120;
  msg^.MinMaxInfo^.MaxWidth  := msg^.MinMaxInfo^.MaxWidth + 500;

  msg^.MinMaxInfo^.MinHeight := msg^.MinMaxInfo^.MinHeight + 40;
  msg^.MinMaxInfo^.DefHeight := msg^.MinMaxInfo^.DefHeight + 90;
  msg^.MinMaxInfo^.MaxHeight := msg^.MinMaxInfo^.MaxHeight + 300;
end;

// Draw method is called whenever MUI feels we should render
// our object. This usually happens after layout is finished
// or when we need to refresh in a simplerefresh window.
// Note: You may only render within the rectangle
//       OBJ_mleft(obj), OBJ_mtop(obj), OBJ_mwidth(obj), OBJ_mheight(obj).

function mDraw(cl: PIClass; Obj: PObject_; Msg: PMUIP_Draw): longword;
var
  i: Integer;
  Data: PMyData;
  p: PLongWord;
begin
  mDraw := 0;
  Data := INST_DATA(cl, Pointer(obj));
  // let our superclass draw itself first, area class would
  // e.g. draw the frame and clear the whole region. What
  // it does exactly depends on msg->flags.

  DoSuperMethodA(cl,obj,msg);

  // if MADF_DRAWOBJECT isn't set, we shouldn't draw anything.
  // MUI just wanted to update the frame or something like that.
  P := Pointer(Msg);
  for i := 0 to 3 do
  begin
  //  writeln(i, ' Msg: $', IntToHex(P^, 8));
  //  Inc(P);
  end;
  //writeln('Msg1: $', IntToHex(Msg^.MethodID, 8));
  //writeln('Msg2: $', IntToHex(Msg^.flags, 8));
  //writeln(' Size: ', SizeOf(Msg^));
  if (Msg^.flags and MADF_DRAWUPDATE) <> 0 then
  begin
    if (data^.sx <> 0) or (data^.sy <> 0) then
    begin
      SetBPen(OBJ_rp(obj), OBJ_dri(obj)^.dri_Pens[SHINEPEN]);
      ScrollRaster(OBJ_rp(obj), data^.sx, data^.sy, OBJ_mleft(obj), OBJ_mtop(obj), OBJ_mright(obj), OBJ_mbottom(obj));
      SetBPen(OBJ_rp(obj), 0);
      data^.sx := 0;
      data^.sy := 0;
    end
    else
    begin
      SetAPen(OBJ_rp(obj), OBJ_dri(obj)^.dri_Pens[SHADOWPEN]);
      WritePixel(OBJ_rp(obj), Data^.x, Data^.y);
    end;
  end
  else
  begin
    if (Msg^.flags and MADF_DRAWOBJECT) <> 0 then
    begin
      SetAPen(OBJ_rp(obj), OBJ_dri(obj)^.dri_Pens[SHINEPEN]);
      RectFill(OBJ_rp(obj), OBJ_mleft(obj), OBJ_mtop(obj), OBJ_mright(obj), OBJ_mbottom(obj));
    end;
  end;
end;

function mSetup(cl: PIClass; Obj: PObject_; Msg: PMUIP_Setup): PtrUInt;
begin
  DoSuperMethodA(Cl, Obj, Msg);
  MUI_RequestIDCMP(Obj, IDCMP_MOUSEBUTTONS or IDCMP_RAWKEY);

  mSetup := MUI_TRUE;
end;

function mCleanup(cl: PIClass; Obj: PObject_; Msg: PMUIP_Setup): PtrUInt;
begin
  MUI_RejectIDCMP(Obj, IDCMP_MOUSEBUTTONS or IDCMP_RAWKEY);

  mCleanup := DoSuperMethodA(Cl, Obj, Msg);
end;

function mHandleInput(cl: PIClass; Obj: PObject_; Msg: PMUIP_HandleInput): PtrUInt;
var
  Data: PMyData;
begin
  Data := INST_DATA(cl, Pointer(obj));
  if Assigned(msg^.imsg) then
  begin
    case msg^.imsg^.IClass of
      IDCMP_MOUSEBUTTONS: begin
        if msg^.imsg^.Code = SELECTDOWN then
        begin
          if OBJ_IsInObject(msg^.imsg^.MouseX, msg^.imsg^.MouseY, obj) then
          begin
            data^.x := msg^.imsg^.MouseX;
            data^.y := msg^.imsg^.MouseY;
            MUI_Redraw(obj, MADF_DRAWUPDATE);
            MUI_RequestIDCMP(obj, IDCMP_MOUSEMOVE);
          end;
        end
        else
          MUI_RejectIDCMP(obj, IDCMP_MOUSEMOVE);
      end;
      IDCMP_MOUSEMOVE: begin
        if OBJ_IsInObject(msg^.imsg^.MouseX, msg^.imsg^.MouseY, obj) then
        begin
          data^.x := msg^.imsg^.MouseX;
          data^.y := msg^.imsg^.MouseY;
          MUI_Redraw(obj, MADF_DRAWUPDATE);
        end;
      end;
      IDCMP_RAWKEY: begin
        case msg^.imsg^.code of
          CURSORLEFT: begin
            Data^.sx := -1;
            MUI_Redraw(obj, MADF_DRAWUPDATE);
          end;
          CURSORRIGHT: begin
            Data^.sx := 1;
            MUI_Redraw(obj, MADF_DRAWUPDATE);
          end;
          CURSORUP: begin
            Data^.sy := -1;
            MUI_Redraw(obj, MADF_DRAWUPDATE);
          end;
          CURSORDOWN: begin
            Data^.sy := 1;
            MUI_Redraw(obj, MADF_DRAWUPDATE);
          end;
        end;
      end;
    end;
  end;
  mHandleInput := DoSuperMethodA(Cl, Obj, Msg);
end;

// Here comes the dispatcher for our custom class. We only need to
// care about MUIM_AskMinMax and MUIM_Draw in this simple case.
// Unknown/unused methods are passed to the superclass immediately.

function MyDispatcher(cl: PIClass; Obj: PObject_; Msg: intuition.PMsg): PtrUInt;
begin
  case Msg^.MethodID of
    MUIM_Setup: MyDispatcher := mSetup(cl, Obj, Pointer(Msg));
    MUIM_Cleanup: MyDispatcher := mCleanup(cl, Obj, Pointer(Msg));
    MUIM_AskMinMax: MyDispatcher := mAskMinMax(cl, Obj, Pointer(Msg));
    MUIM_Draw: MyDispatcher := mDraw(cl, Obj, Pointer(Msg));
    MUIM_HandleInput: MyDispatcher := mHandleInput(cl, Obj, Pointer(Msg));
    else
      MyDispatcher := DoSuperMethodA(cl, obj, msg);
  end;
end;

// Thats all there is about it. Now lets see how things are used...

procedure StartMe;
var
  App, Window, MyObj: PObject_;
  Sigs: LongInt;
  MCC: PMUI_CustomClass;
begin
  try
    // Create the new custom class with a call to MH_CreateCustomClass().
    // Caution: This function returns not a struct IClass, but a
    // TMUI_CustomClass which contains a struct IClass to be
    // used with MH_NewObject() calls.
    // Note well: MUI creates the dispatcher hook for you, you may
    // *not* use its h_Data field! If you need custom data, use the
    // cl_UserData of the IClass structure!

    MCC := MH_CreateCustomClass(nil, MUIC_Area, nil, SizeOf(TMyData), @MyDispatcher);
    if not Assigned(MCC) then
    begin
      writeln('Could not create custom class.');
      Exit;
    end;
    App := MH_Application([
      MUIA_Application_Title,       AsTag('Class3'),
      MUIA_Application_Version,     AsTag('$VER: Class3 19.5 (12.02.97)'),
      MUIA_Application_Copyright,   AsTag('©1993, Stefan Stuntz'),
      MUIA_Application_Author,      AsTag('Stefan Stuntz'),
      MUIA_Application_Description, AsTag('Demonstrate the use of custom classes.'),
      MUIA_Application_Base,        AsTag('Class3'),

      SubWindow, AsTag(MH_Window(Window, [
        MUIA_Window_Title, AsTag('A rather complex custom class'),
        MUIA_Window_ID,    MAKE_ID('C','L','S','3'),
        WindowContents, AsTag(MH_VGroup([

          Child, AsTag(MH_Text(
            PChar(MUIX_C + 'Paint with mouse,'#10'scroll with cursor keys.'), [
            MUIA_Background, MUII_TextBack,
            TAG_DONE])),

          Child, AsTag(MH_NewObject(MyObj, mcc^.mcc_Class, nil, [
            MUIA_Frame, MUIV_Frame_Text,
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

    MH_Set(Window, MUIA_Window_Open, AsTag(True));

  finally
    if Assigned(App) then
      MUI_DisposeObject(app);
    if Assigned(MCC) then
      MUI_DeleteCustomClass(MCC);
  end;
end;

begin
  StartMe;
end.
