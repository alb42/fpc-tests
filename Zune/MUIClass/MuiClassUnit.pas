unit MuiClassUnit;

interface

{$mode Delphi}{$H+}

uses
  Classes, Exec, Intuition, Mui, AGraphics, TagsArray, sysutils;

type
  TMUICanvas = record
    RastPort: PRastPort;
    DrawRect: TRect;
  end;

  TMUIBase = class
  private
    FParent: TMUIBase;
    function GetIsHandle: Boolean;
    procedure SetParent(AParent: TMUIBase);
  protected
    FMUIObject: PObject_;
    FParentTarget: PObject_;
  public
    function CreateHandle: Boolean; virtual; abstract;
    procedure DestroyHandle; virtual; abstract;

    procedure AddChild(const NChild: TMUIBase);
    procedure RemoveChild(const NChild: TMUIBase);

    property MUIObject: PObject_ read FMUIObject;
    property IsHandle: Boolean read GetIsHandle;
    property Parent: TMUIBase read FParent write SetParent;
  end;

  TMUIWinClass = class(TMUIBase)
    function CreateHandle: Boolean; override;
  end;

  TMUIAppClass = class(TMUIBase)
    function CreateHandle: Boolean; override;
  end;


  TMUIBaseClass = class(TMUIBase)
  private
    FLeft: Integer;
    FTop: Integer;
    FWidth: Integer;
    FHeight: Integer;
    FOnDraw: TNotifyEvent;
    FMuiCanvas: TMUICanvas;
  public
    Magic: Integer;
    constructor Create;
    function CreateHandle: Boolean; override;
    procedure DestroyHandle; override;

    property Left: Integer read FLeft write FLeft;
    property Top: Integer read FTop write FTop;
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
    property MUICanvas: TMUICanvas read FMUICanvas;

    property OnDraw: TNotifyEvent read FOnDraw write FOnDraw;

  end;

var
  ALBsClass: PIClass;

implementation

var
  SuperClass: PIClass;

function TMUIBase.GetIsHandle: Boolean;
begin
  Result := Assigned(FMUIObject);
end;

procedure TMUIBase.SetParent(AParent: TMUIBase);
begin
  if AParent = FParent then
    Exit;
  if Assigned(FParent) then
    FParent.RemoveChild(Self);
  if Assigned(AParent) then
    AParent.AddChild(Self);
  FParent := AParent;
end;

procedure TMUIBase.AddChild(const NChild: TMUIBase);
begin
  DoMethod(FParentTarget, [OM_ADDMEMBER, PtrUInt(NChild.MUIObject)]);
end;

procedure TMUIBase.RemoveChild(const NChild: TMUIBase);
begin
  DoMethod(FParentTarget, [OM_REMMEMBER, PtrUInt(NChild.MUIObject)]);
end;


constructor TMUIBaseClass.Create;
begin
  FOnDraw := nil;
end;

function TMUIWinClass.CreateHandle: Boolean;
var
  Tags: TTagsList;
begin
  Result := False;
  AddTags(Tags, [Tag_Done, 0, TAG_Done, 0]);
  FParentTarget := MUI_NewObject(MUIC_Group,
    [TAG_END, TAG_END]);
  FMUIObject := MUI_NewObject(MUIC_Window,
    [MUIA_Window_RootObject, PtrUInt(FParentTarget),
     TAG_END]);

  if Assigned(FMUIObject) then
  begin
    Pointer(INST_DATA(ALBsClass, Pointer(FMUIObject))^) := Self;
    Result := True;
  end;
end;



function TMUIAppClass.CreateHandle: Boolean;
var
  Tags: TTagsList;
begin
  Result := False;
  AddTags(Tags, [Tag_Done, 0, TAG_Done, 0]);
  FMUIObject := MUI_NewObject(MUIC_Application, [0,0]);
  FParentTarget := FMUIObject;
  if Assigned(FMUIObject) then
  begin
    Pointer(INST_DATA(ALBsClass, Pointer(FMUIObject))^) := Self;
    Result := True;
  end;
end;


function TMUIBaseClass.CreateHandle: Boolean;
var
  Tags: TTagsList;
begin
  Result := False;
  AddTags(Tags, [Tag_Done, 0, TAG_Done, 0]);
  FMUIObject := NewObjectA(ALBsClass, nil, GetTagPtr(Tags));
  FParentTarget := FMUIObject;
  if Assigned(FMUIObject) then
  begin
    Pointer(INST_DATA(ALBsClass, Pointer(FMUIObject))^) := Self;
    Result := True;
  end;
end;

procedure TMUIBaseClass.DestroyHandle;
begin
  if IsHandle then
  begin
    Parent := nil;
    MUI_DisposeObject(FMUIObject);
    FMUIObject := nil;
  end;
end;


procedure DestroyClass;
begin
  if Assigned(ALBsClass) then
    FreeClass(ALBsClass);
  if Assigned(SuperClass) then
    MUI_FreeClass(SuperClass);
end;

function Dispatcher(cl: PIClass; Obj: PObject_; Msg: PMsg): LongWord; cdecl;
var
  AskMsg: PMUIP_AskMinMax;
  ri: PMUI_RenderInfo;
  rp: PRastPort;
  Region: PRegion;
  r: TRectangle;
  clip: Pointer;
  MUIB: TMUIBaseClass;
begin
  //write('Enter Dispatcher with: ');
  case Msg^.MethodID of
    OM_NEW:begin
      writeln('NEW');
      Result := DoSuperMethodA(cl, obj, msg);
    end;
    OM_DISPOSE: begin
      writeln('DISPOSE');
      Result := DoSuperMethodA(cl, obj, msg);
    end;
    MUIM_AskMinMax: begin
      Result := DoSuperMethodA(cl, obj, msg);
      AskMsg := Pointer(Msg);
      AskMsg^.MinMaxInfo^.MinWidth := AskMsg^.MinMaxInfo^.MinWidth + 25;
      AskMsg^.MinMaxInfo^.DefWidth := AskMsg^.MinMaxInfo^.DefWidth + 250;
      AskMsg^.MinMaxInfo^.MaxWidth := AskMsg^.MinMaxInfo^.MaxWidth + 2500;
      AskMsg^.MinMaxInfo^.MinHeight := AskMsg^.MinMaxInfo^.MinHeight + 18;
      AskMsg^.MinMaxInfo^.DefHeight := AskMsg^.MinMaxInfo^.DefHeight + 180;
      AskMsg^.MinMaxInfo^.MaxHeight := AskMsg^.MinMaxInfo^.MaxHeight + 1800;
      writeln('set minwidth to ', AskMsg^.MinMaxInfo^.MinWidth);
      Result := 0;
      writeln('AskMinMax');
    end;
    MUIM_Draw: begin
      writeln('DRAW');
      Result := DoSuperMethodA(cl, obj, msg);
      if PMUIP_Draw(msg)^.Flags and MADF_DRAWOBJECT = 0 then
      begin
        Exit;
      end;
      rp := nil;
      ri := MUIRenderInfo(Obj);
      if Assigned(ri) then
        rp := ri^.mri_RastPort;
      if Assigned(rp) then
      begin
        MUIB:= TMUIBaseClass(INST_DATA(cl, Pointer(obj))^);
        clip := MUI_AddClipping(ri, Obj_Left(obj), Obj_top(Obj), Obj_Width(Obj), Obj_Height(Obj));
        if Assigned(MUIB) then
        begin
          MUIB.FMUICanvas.RastPort := rp;
          MUIB.FMUICanvas.DrawRect := Rect(Obj_mLeft(Obj), Obj_mTop(Obj), Obj_mRight(Obj), Obj_mBottom(Obj));
          if Assigned(MUIB.FOnDraw) then
          begin
            MUIB.FOnDraw(MUIB);
          end;
        end;

        {SetAPen(rp, 1);
        RectFill(rp, Obj_mLeft(Obj), Obj_mTop(Obj), Obj_mRight(Obj), Obj_MBottom(Obj));
        SetAPen(rp, 2);
        RectFill(rp, Obj_mLeft(Obj) + 10, Obj_mTop(obj) + 10, Obj_mLeft(obj) + 20, Obj_mTop(obj) + 20);
        SetAPen(rp, 3);
        Move(rp, 20, 5);
        Draw(rp, Obj_Right(Obj) + 25, 200);
        Move(rp, Obj_Right(Obj) - 5, 50);
        Draw(rp, Obj_Left(Obj) - 25, Obj_Bottom(Obj));}
        MUI_RemoveClipRegion(ri, clip);
      end;
      Result := 0;
    end;
    else
    begin
      //writeln('unknown ', Msg^.MethodID);
      Result := DoSuperMethodA(cl, obj, msg);
    end;
  end;
end;


procedure CreateClass;
begin
  SuperClass := MUI_GetClass(MUIC_Group);
  if not Assigned(SuperClass) then
  begin
    writeln('Superclass for the new class not found.');
    Exit;
  end;
  ALBsClass := MakeClass(nil ,nil, SuperClass, SizeOf(Pointer), 0);
  if not Assigned(ALBsClass) then
  begin
    writeln('Cannot make class.');
    DestroyClass;
    Exit;
  end;
  ALBsClass^.cl_Dispatcher.h_Entry := IPTR(@Dispatcher);
  ALBsClass^.cl_Dispatcher.h_SubEntry := 0;
  ALBsClass^.cl_Dispatcher.h_Data := nil;

end;



initialization
  CreateClass;
finalization
  DestroyClass;
end.
