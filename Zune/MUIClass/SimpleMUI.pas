program SimpleMUI;

{$mode objfpc}{$H+}

uses
  tagsarray, Classes, SysUtils, Exec, AmigaDos, Intuition,
  Mui, Utility, AGraphics, MUIClassUnit;

const
  Esc33c = #27#99;

type
  TestClass = class
    procedure DrawIt(Sender: TObject);
    procedure DrawIt2(Sender: TObject);
  end;

procedure Buttonfunc(Hook: PHook; Obj: PObject_; Msg:Pointer); cdecl;
begin
  writeln('button clicked');
end;

procedure TestClass.DrawIt2(Sender: TObject);
var
  M: TMUIBaseClass;
  s: String;
begin
  M := TMUIBaseClass(Sender);
  with M.MUICanvas do
  begin
    SetAPen(RastPort, 1);
    GfxMove(RastPort, DrawRect.Left + 10, DrawRect.Top + 10);
    s := 'Test';
    GfxText(RastPort, PChar(s), Length(s));
  end;
end;

procedure TestClass.DrawIt(Sender: TObject);
var
  M: TMUIBaseClass;
  rp: PRastPort;
begin
  writeln('enter drawit');
  M := TMUIBaseClass(Sender);
  with M.MUICanvas do
  begin
    SetAPen(RastPort, 1);
    RectFill(RastPort, DrawRect.Left, DrawRect.Top, DrawRect.Right, DrawRect.Bottom);
    SetAPen(RastPort, 2);
    RectFill(RastPort, DrawRect.Left + 10, DrawRect.Top + 10, DrawRect.Left + 20, DrawRect.Top + 20);
    SetAPen(RastPort, 3);
    GfxMove(RastPort, 20, 5);
    Draw(RastPort, DrawRect.Right + 25, 200);
    GfxMove(RastPort, DrawRect.Right - 5, 50);
    Draw(RastPort, DrawRect.Left - 25, DrawRect.Bottom);
  end;
  writeln('leave Drawit');
end;

function MyGet(o: pObject_; tag: LongWord): LongWord;
var
  Res: LongWord;
begin
  GetAttr(tag, o, @Res);
  MyGet := Res;
end;

var
  cust, Cust2, wnd, app, but, txt, grp: pObject_;
  sigs: LongWord;
  ButtonHook: THook;
  Tags: TTagsList;
  MUIB: TMUIBaseClass;
  MUIB2: TMUIBaseClass;
  TestC: TestClass;

  Mapp: TMUIAppClass;
  MWin: TMUIWinClass;
begin
  TestC := TestClass.create;
  MUIB := TMUIBaseClass.create;
  MUIB.OnDraw := @TestC.DrawIt;
  MUIB.CreateHandle;
  MUIB2 := TMUIBaseClass.create;
  MUIB2.OnDraw := @TestC.DrawIt2;
  MUIB2.CreateHandle;


  ButtonHook.h_Entry := IPTR(@buttonFunc);

  but := MUI_MakeObject(MUIO_Button, [PtrUInt(PChar('_Ok'))]);

  AddTags(Tags, [Tag_Done, 0, TAG_Done, 0]);
  if Assigned(ALBsClass) then
  begin
    //Cust := NewObjectA(ALBsClass, nil, GetTagPtr(Tags));
    //Cust2 := NewObjectA(ALBsClass, nil, GetTagPtr(Tags));
  end;


  Mapp := TMUIAppClass.Create;
  MApp.CreateHandle;

  MWin := TMUIWinClass.Create;
  MWin.CreateHandle;

  wnd := MWin.MUIObject;
  MWin.Parent := MApp;
  MUIB.Parent := MWin;
  MUIB2.Parent := MWin;
  app := Mapp.MUIObject;
  SetAttrs(app, [MUIA_Application_Window, PtrUInt(wnd), TAG_END]);


  {txt := MUI_NewObject(MUIC_Text,
    [LongInt(MUIA_Text_Contents), PChar(Esc33c + 'Hello world'#10'How are you?'),
     TAG_END]);

  grp := MUI_NewObject(MUIC_Group,
    [LongInt(MUIA_Group_Child), MUIB.MUIObject,
     LongInt(MUIA_Group_Child), txt,
     LongInt(MUIA_Group_Child), MUIB2.MUIObject,
     LongInt(MUIA_Group_Child), but,
     TAG_END]);

  wnd := MUI_NewObject(MUIC_Window,
    [LongInt(MUIA_Window_Title), PChar('Hello World'),
     LongInt(MUIA_Window_RootObject), grp,
     TAG_END]);

  app := MUI_NewObject(MUIC_Application,
    [LongInt(MUIA_Application_Window), wnd,
     TAG_END]);}
  writeln('Start');
  if app <> nil then
  begin
    writeln('app ok');
    CallHook(PHook(OCLASS(wnd)), wnd,
      [MUIM_Notify, MUIA_Window_CloseRequest, LTrue,
      PtrUInt(app), 2,
      MUIM_Application_ReturnID, MUIV_Application_ReturnID_Quit]);
    (*
    CallHook(PHook(OCLASS(but)), but,
      [MUIM_Notify, MUIA_Pressed, False,
      LongWord(app), 2,
      MUIM_CallHook, @ButtonHook]);
   *)
    sigs := 0;
    writeln('open it');
    SetAttrs(wnd, [MUIA_Window_Open, LTrue, TAG_END]);
    if myGet(wnd, MUIA_Window_Open)<>0 then
    begin
      writeln('Window open');
      while Integer(CallHook(PHook(OCLASS(app)), app,
                     [MUIM_Application_NewInput, PtrUInt(@sigs)]))
            <> MUIV_Application_ReturnID_Quit do
      begin
        if (sigs <> 0) then
        begin
          sigs := Wait(sigs or SIGBREAKF_CTRL_C);
          if (Sigs and SIGBREAKF_CTRL_C) <>0 then
            Break;
        end;
      end;
    end else
      writeln('Window not open');
    MUI_DisposeObject(app);
  end;
end.

