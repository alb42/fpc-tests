program MUIEvents;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, Exec, AmigaDos, Intuition, Mui, Utility, strutils;

const
  Esc33c = #27#99;
type
  THookFunction= procedure(h: PHook; obj: PObject_; Msg: Pointer);

{$undef SetHook}

{$ifdef CPU68}
{$define SetHook}
procedure _hookEntry; assembler;
asm
  move.l a1,-(a7)    // Msg
  move.l a2,-(a7)    // Obj
  move.l a0,-(a7)    // PHook
  move.l 12(a0),a0   // h_SubEntry = Offset 12
  jsr (a0)           // Call the SubEntry
  lea 12(a7),a7      // remove arguments from stack
  rts
end;

procedure SetHook(var Hook: THook; Func: THookFunction; Data: Pointer);
begin
  Hook.h_Entry := @_hookEntry;
  Hook.h_SubEntry := Func;
  Hook.h_Data := Data;
end;
{$endif}

{$ifdef CPU86}
{$define SetHook}

procedure _hookEntry(h: PHook; obj: PObject_; Msg: Pointer); cdecl;
var
  Proc: THookFunction;
begin
  Proc := THookFunction(h^.h_SubEntry);
  Proc(h, obj, msg);
end;

procedure SetHook(var Hook: THook; Func: THookFunction; Data: Pointer);
begin
  Hook.h_Entry := IPTR(@_hookEntry);
  Hook.h_SubEntry := IPTR(Func);
  Hook.h_Data := Data;
end;
{$endif}

{$ifdef CPUPOWERPC}
{$define SetHook}
procedure SetHook(var Hook: THook; Func: THookFunction; Data: Pointer);
begin
  {$WARNING "_hookEntry still not implemented, Button click will crash!"}
  //Hook.h_Entry := MISSING
  Hook.h_SubEntry := LongWord(Func);
  Hook.h_Data := Data;
end;
{$endif}

{$ifndef SetHook}
{$FATAL "SetHook not implemented for this platform"}
{$endif}


{$ifdef MorphOS}
// some missing things for morphos
const
  LTrue = 1;
  LFalse = 0;
type
  APTR = Pointer;
{$endif}


function MyGet(o: pObject_; tag: LongWord): LongWord;
var
  Res: LongWord;
begin
  {$ifdef MorphOS}
  GetAttr(tag, o, Res);
  {$else}
  GetAttr(tag, o, @Res);
  {$endif}
  MyGet := Res;
end;

function MyCallHook(h: PHook; obj: APTR; params: array of NativeUInt): LongWord;
begin
  Result := CallHookPkt(h, obj, @Params[0]);
end;

function MySetAttrs(obj: PObject_; Params: array of NativeUInt): LongWord;
begin
  Result := SetAttrsA(obj, @Params[0]);
end;

var
  wnd, app, but, txt, grp: pObject_;
  sigs: LongWord;
  ButtonHook: THook;

procedure Buttonfunc(Hook: PHook; Obj: PObject_; Msg:Pointer);
begin
  writeln('button clicked Hook:' + HexStr(Hook) + ' Obj: ' + HexStr(Obj) + ' Msg:' + HexStr(Msg));
  writeln('check params: ');
  writeln('Hook: ' + ifthen(Hook=@ButtonHook, 'OK', 'Not OK'));
  writeln('Obj: ' + ifthen(Obj=but, 'OK', 'Not OK'));
end;

begin
  {$ifdef MorphOS}
  InitMUIMasterLibrary;
  InitIntuitionLibrary;
  {$endif}

  SetHook(ButtonHook, @buttonFunc, Pointer($42));
  //
  writeln(HexStr(@ButtonHook));
  but := MUI_MakeObject(MUIO_Button, [NativeUInt(PChar('_Ok'))]);

  txt := MUI_NewObject(MUIC_Text,
    [MUIA_Text_Contents, NativeUInt(PChar(Esc33c + 'Hello world'#10'How are you?')),
     TAG_END]);

  grp := MUI_NewObject(MUIC_Group,
    [MUIA_Group_Child, NativeUInt(txt),
     MUIA_Group_Child, NativeUInt(but),
     TAG_END]);

  wnd := MUI_NewObject(MUIC_Window,
    [MUIA_Window_Title, NativeUInt(PChar('Hello World')),
     MUIA_Window_RootObject, NativeUInt(grp),
     TAG_END]);

  app := MUI_NewObject(MUIC_Application,
    [MUIA_Application_Window, NativeUInt(wnd),
     TAG_END]);

  if app <> nil then
  begin
    MyCallHook(PHook(OCLASS(wnd)), wnd,
      [MUIM_Notify, MUIA_Window_CloseRequest, LTrue,
      LongWord(app), 2,
      MUIM_Application_ReturnID, MUIV_Application_ReturnID_Quit]);

    MyCallHook(PHook(OCLASS(but)), but,
      [MUIM_Notify, MUIA_Pressed, LFalse,
      MUIV_Notify_Self, 2,
      MUIM_CallHook, LongWord(@ButtonHook)]);

    sigs := 0;
    MySetAttrs(wnd, [MUIA_Window_Open, LTrue, TAG_END]);

    if myGet(wnd, MUIA_Window_Open)<>0 then
    begin

      while Integer(MyCallHook(PHook(OCLASS(app)), app,
                     [MUIM_Application_NewInput, LongWord(@sigs)]))
            <> MUIV_Application_ReturnID_Quit do
      begin
        if (sigs <> 0) then
        begin
          sigs := Wait(sigs or SIGBREAKF_CTRL_C);
          if (Sigs and SIGBREAKF_CTRL_C) <>0 then
            Break;
        end;
      end;
    end;
    MUI_DisposeObject(app);
  end;
end.

