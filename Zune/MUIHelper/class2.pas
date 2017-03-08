program class2;
{$mode objfpc}{$H+}

//***************************************************************************
// Here is the beginning of our simple new class...                         *
//***************************************************************************

{.$define WORKING_COORDS}

uses
  {$if defined(MorphOS) or defined(Amiga68k)}
  amigalib,
  {$endif}
  Exec, Utility, intuition, agraphics, AmigaDos, mui, muihelper;

type
  TMyData = record
    PenSpec: TMUI_PenSpec;
    Pen: LongInt;
    PenChange: Boolean;
  end;
  PMyData = ^TMyData;

const
  MYATTR_PEN = $8022; // tag value for the new attribute.


function mNew(cl: PIClass; Obj: PObject_; Msg: PopSet): PtrUInt;
var
  Data: PMyData;
  Tags, Tag: PTagItem;
begin
  mNew := 0;
  Obj := PObject_(DoSuperMethodA(Cl, Obj, Msg));
  if not Assigned(Obj) then
    Exit;

  Data := INST_DATA(cl, Pointer(obj));

  // Parse initial taglist
  Tags := Msg^.ops_AttrList;
  Tag := Tags;
  while Assigned(Tag) do
  begin
    case Tag^.ti_Tag of
      MYATTR_PEN: begin
        if Tag^.ti_Data <> 0 then
          data^.penspec := PMUI_PenSpec(tag^.ti_Data)^;
      end;
    end;
    Tag := NextTagItem(Tags);
  end;

  mNew := PtrUInt(Obj);
end;

function mDispose(cl: PIClass; Obj: PObject_; Msg: Intuition.PMsg): PtrUInt;
begin
  // OM_NEW didnt allocates something, just do nothing here...
  mDispose := DoSuperMethodA(Cl, Obj, Msg);
end;

// OM_SET method, we need to see if someone changed the penspec attribute.
function mSet(cl: PIClass; Obj: PObject_; Msg: PopSet): PtrUInt;
var
  Data: PMyData;
  Tags, Tag: PTagItem;
begin
  Data := INST_DATA(cl, Pointer(obj));

  Tags := Msg^.ops_AttrList;
  Tag := Tags;
  while Assigned(Tag) do
  begin
    case Tag^.ti_Tag of
      MYATTR_PEN: begin
        if Tag^.ti_Data <> 0 then
        begin
          data^.penspec := PMUI_PenSpec(tag^.ti_Data)^;
          data^.penchange := True;
          MUI_Redraw(Obj, MADF_DRAWOBJECT); // redraw ourselves completely
        end;
      end;
    end;
    Tag := NextTagItem(Tags);
  end;

  mSet := DoSuperMethodA(Cl, Obj, Msg);
end;

// OM_GET method, see if someone wants to read the color.
function mGet(cl: PIClass; Obj: PObject_; Msg: PopGet): PtrUInt;
var
  Data: PMyData;
  Store: ^PtrUInt;
begin
  Data := INST_DATA(cl, Pointer(obj));
  Store := Msg^.opg_Storage;
  //
  case Msg^.opg_AttrID of
    MYATTR_PEN: begin
      Store^ := PtrUInt(@data^.penspec);
      mGet := MUI_TRUE;
      Exit;
    end;
  end;

  mGet := DoSuperMethodA(Cl, Obj, Msg);
end;

function mSetup(cl: PIClass; Obj: PObject_; Msg: PMUIP_Setup): PtrUInt;
var
  Data: PMyData;
begin
  Data := INST_DATA(cl, Pointer(obj));
  if DoSuperMethodA(Cl, Obj, Msg) <> 0 then
  begin
    mSetup := MUI_TRUE;
    Exit;
  end;

  Data^.Pen := MUI_ObtainPen(muiRenderInfo(obj), @Data^.PenSpec, 0);

  mSetup := MUI_TRUE;
end;

function mCleanup(cl: PIClass; Obj: PObject_; Msg: PMUIP_Setup): PtrUInt;
var
  Data: PMyData;
begin
  Data := INST_DATA(cl, Pointer(obj));

  MUI_ReleasePen(muiRenderInfo(obj), Data^.Pen);

  mCleanup := DoSuperMethodA(Cl, Obj, Msg);
end;


// AskMinMax method will be called before the window is opened
// and before layout takes place. We need to tell MUI the
// minimum, maximum and default size of our object.

function mAskMinMax(cl: PIClass; Obj: PObject_; Msg: PMUIP_AskMinMax): PtrUInt;
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

function mDraw(cl: PIClass; Obj: PObject_; Msg: PMUIP_Draw): PtrUInt;
var
  i: Integer;
  Data: PMyData;
  {$ifdef WORKING_COORDS}
  x,y: Integer;
  {$endif}
begin
  mDraw := 0;
  Data := INST_DATA(cl, Pointer(obj));

  // let our superclass draw itself first, area class would
  // e.g. draw the frame and clear the whole region. What
  // it does exactly depends on msg->flags.

  DoSuperMethodA(cl,obj,msg);

  // if MADF_DRAWOBJECT isn't set, we shouldn't draw anything.
  // MUI just wanted to update the frame or something like that.

  if (Msg^.flags and MADF_DRAWOBJECT) = 0 then
    Exit;

  // test if someone changed our pen
  if Data^.PenChange then
  begin
    Data^.PenChange := False;
    MUI_ReleasePen(muiRenderInfo(obj), Data^.Pen);
    Data^.Pen := MUI_ObtainPen(muiRenderInfo(obj), @Data^.PenSpec, 0);
  end;

  // ok, everything ready to render...
  {$ifdef WORKING_COORDS}
  i := MUIPEN(data^.pen);
  SetAPen(OBJ_rp(obj), i);
  {$else}
  SetAPen(OBJ_rp(obj), MUIPEN(data^.pen));
  {$endif}

  i := OBJ_mleft(obj);
  while i <= OBJ_mright(obj) do
  begin
    {$ifdef WORKING_COORDS}
    x := OBJ_mleft(obj);
    y := OBJ_mbottom(obj);
    GFXMove(OBJ_rp(obj), x, y);
    y := OBJ_mtop(obj);
    Draw(OBJ_rp(obj), i, y);
    x := OBJ_mright(obj);
    y := OBJ_mbottom(obj);
    GFXMove(OBJ_rp(obj), x, y);
    y := OBJ_mtop(obj);
    Draw(OBJ_rp(obj), i, y);
    {$else}
    GFXMove(OBJ_rp(obj), OBJ_mleft(obj), OBJ_mbottom(obj));
    Draw(OBJ_rp(obj), i, OBJ_mtop(obj));
    GFXMove(OBJ_rp(obj), OBJ_mright(obj), OBJ_mbottom(obj));
    Draw(OBJ_rp(obj), i, OBJ_mtop(obj));
    {$endif}
    Inc(i, 5);
  end
end;

// Here comes the dispatcher for our custom class. We only need to
// care about MUIM_AskMinMax and MUIM_Draw in this simple case.
// Unknown/unused methods are passed to the superclass immediately.

function MyDispatcher(cl: PIClass; Obj: PObject_; Msg: intuition.PMsg): PtrUInt;
begin

  case Msg^.MethodID of
    OM_NEW: MyDispatcher := mNew(cl, Obj, Pointer(Msg));
    OM_DISPOSE: MyDispatcher := mDispose(cl, Obj, Pointer(Msg));
    OM_SET: MyDispatcher := mSet(cl, Obj, Pointer(Msg));
    OM_GET: MyDispatcher := mGet(cl, Obj, Pointer(Msg));
    MUIM_Setup: MyDispatcher := mSetup(cl, Obj, Pointer(Msg));
    MUIM_Cleanup: MyDispatcher := mCleanup(cl, Obj, Pointer(Msg));
    MUIM_AskMinMax: MyDispatcher := mAskMinMax(cl, Obj, Pointer(Msg));
    MUIM_Draw: MyDispatcher := mDraw(cl, Obj, Pointer(Msg));
    else
      MyDispatcher := DoSuperMethodA(cl, obj, msg);
  end;
end;

// Thats all there is about it. Now lets see how things are used...

procedure StartMe;
var
  App, Window, MyObj, Pen: PObject_;
  Sigs: LongInt;
  MCC: PMUI_CustomClass;
  StartPen: PMUI_PenSpec;
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
      MUIA_Application_Title,       AsTag('Class2'),
      MUIA_Application_Version,     AsTag('$VER: Class2 19.5 (12.02.97)'),
      MUIA_Application_Copyright,   AsTag('©1993, Stefan Stuntz'),
      MUIA_Application_Author,      AsTag('Stefan Stuntz'),
      MUIA_Application_Description, AsTag('Demonstrate the use of custom classes.'),
      MUIA_Application_Base,        AsTag('CLASS2'),

      SubWindow, AsTag(MH_Window(Window, [
        MUIA_Window_Title, AsTag('Another Custom Class'),
        MUIA_Window_ID,    MAKE_ID('C','L','S','2'),
        WindowContents, AsTag(MH_VGroup([

          Child, AsTag(MH_Text(
            PChar(MUIX_C + 'This is a custom class with attributes.'#10'Click on the button at the bottom of'#10'the window to adjust the color.'), [
            MUIA_Background, MUII_TextBack,
            TAG_DONE])),

          Child, AsTag(MH_NewObject(MyObj, mcc^.mcc_Class, nil, [
            MUIA_Frame, MUIV_Frame_Text,
            MUIA_Background, MUII_BACKGROUND,
            TAG_DONE])),

          Child, AsTag(MH_HGroup([MUIA_Weight, 10,
            Child, AsTag(MH_FreeLabel('Custom Class Color:')),
            Child, AsTag(MH_Poppen(Pen, [
              MUIA_CycleChain, 1,
              MUIA_Window_Title, AsTag('Custom Class Color'),
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

    DoMethod(Pen, [MUIM_Notify,MUIA_Pendisplay_Spec,MUIV_EveryTime,
        AsTag(MyObj), 3, MUIM_Set, MYATTR_PEN, MUIV_TriggerValue]);

    DoMethod(Pen, [MUIM_Pendisplay_SetMUIPen, MPEN_HALFSHINE]);

    StartPen := Pointer(MH_get(Pen, MUIA_Pendisplay_Spec));
    MH_set(MyObj, MYATTR_PEN, AsTag(StartPen));

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
      MUI_DisposeObject(app);      // dispose all objects.
    if Assigned(MCC) then          // delete the custom class.
      MUI_DeleteCustomClass(MCC);
  end;
end;

begin
  StartMe;
end.
