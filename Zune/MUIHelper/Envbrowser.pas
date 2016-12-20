program EnvBrowser;
{$mode objfpc}{$H+}
uses
  {$if defined(MorphOS) or defined(Amiga)}
  amigalib,
  {$endif}
  Exec, Utility, intuition, agraphics, AmigaDos, mui, muihelper;

const
  ID_DISPLAY = 1;
  ID_EDIT    = 2;
  ID_DELETE  = 3;
  ID_SAVE    = 4;

var
  App: PObject_;        // Application object
  WI_Browser: PObject_; // Window object
  BT_Edit: PObject_;    // Edit Button object
  BT_Delete: PObject_;  // Delete Button object
  BT_Save: PObject_;    // Save Button object
  LV_Vars: PObject_;    // Env.Var. Listview object
  LV_Show: PObject_;    // Contents Listview object

procedure StartMe;
var
  Sigs: LongInt;
  Running: Boolean;
  Vari: PtrUInt;
  Buffer: array[0..4095] of char;
begin
  try
    App := MH_Application([
      MUIA_Application_Title,       AsTag('EnvBrowser'),
      MUIA_Application_Version,     AsTag('$VER: EnvBrowser 19.5 (12.02.97)'),
      MUIA_Application_Copyright,   AsTag('©1992/93, Stefan Stuntz'),
      MUIA_Application_Author,      AsTag('Stefan Stuntz'),
      MUIA_Application_Description, AsTag('View environment variables.'),
      MUIA_Application_Base,        AsTag('ENVBROWSER'),

      SubWindow, AsTag(MH_Window(WI_Browser, [
        MUIA_Window_ID,    MAKE_ID('M','A','I','N'),
        MUIA_Window_Title, AsTag('Environment Browser'),
        WindowContents, AsTag(MH_VGroup([
          Child, AsTag(MH_HGroup([
            Child, AsTag(MH_ListView(LV_Vars, [
              MUIA_Listview_List, AsTag(MH_Dirlist([
                MUIA_Frame, InputListFrame,
                MUIA_Dirlist_Directory, AsTag('env:'),
                MUIA_Dirlist_FilterDrawers, MUI_TRUE,
                MUIA_List_Format, AsTag('COL=0'),
                TAG_DONE])),
              TAG_DONE])),
            Child, AsTag(MH_Listview(LV_Show, [
              MUIA_Listview_List, AsTag(MH_Floattext([
                MUIA_Frame, ReadListFrame,
                MUIA_Font, AsTag(MUIV_Font_Fixed),
                TAG_DONE])),
              TAG_DONE])),
            TAG_DONE])),
          Child, AsTag(MH_HGroup([MUIA_Group_SameSize, MUI_TRUE,
            Child, AsTag(MH_SimpleButton(BT_Edit, '_Edit')),
            Child, AsTag(MH_SimpleButton(BT_Delete ,'_Delete')),
            Child, AsTag(MH_SimpleButton(BT_Save, '_Save')),
            TAG_DONE])),
          TAG_DONE])),
        TAG_DONE])),
      TAG_DONE]);
    if not Assigned(app) then
    begin
      writeln('Failed to create Application');
      Exit;
    end;

    DoMethod(WI_Browser, [MUIM_Notify, MUIA_Window_CloseRequest, MUI_TRUE,
      AsTag(app), 2, AsTag(MUIM_Application_ReturnID), AsTag(MUIV_Application_ReturnID_Quit)]);

    DoMethod(LV_Vars, [MUIM_Notify, MUIA_List_Active, MUIV_EveryTime, AsTag(App), 2, MUIM_Application_ReturnID, ID_DISPLAY]);
    DoMethod(LV_Vars, [MUIM_Notify, MUIA_Listview_DoubleClick, MUI_TRUE, AsTag(App), 2, MUIM_Application_ReturnID, ID_EDIT]);
    DoMethod(BT_Delete,[MUIM_Notify, MUIA_Pressed, MUI_FALSE, AsTag(App), 2, MUIM_Application_ReturnID, ID_DELETE]);
    DoMethod(BT_Save, [MUIM_Notify, MUIA_Pressed, MUI_FALSE, AsTag(App), 2, MUIM_Application_ReturnID, ID_SAVE]);
    DoMethod(BT_Edit, [MUIM_Notify, MUIA_Pressed, MUI_FALSE, AsTag(App), 2, MUIM_Application_ReturnID, ID_EDIT]);

    // MUIM_Window_SetCycleChain is obsolete
    //DoMethod(WI_Browser, [MUIM_Window_SetCycleChain, AsTag(LV_Vars), AsTag(LV_Show), AsTag(BT_Edit), AsTag(BT_Delete), AsTag(BT_Save), 0]);

    MH_Set(WI_Browser, MUIA_Window_Open, AsTag(True));

    if MH_Get(WI_Browser, MUIA_Window_Open) <> 0 then
    begin
      Running := True;
      while Running do
      begin
        case Integer(DoMethod(app, [MUIM_Application_NewInput, AsTag(@sigs)])) of
          MUIV_Application_ReturnID_Quit: begin
            Running := False;
          end;

          ID_DISPLAY: begin
            Vari := MH_Get(LV_Vars, MUIA_Dirlist_Path);
            if (Vari <> 0) and (GetVar(PChar(Vari), @Buffer[0], SizeOf(Buffer), GVF_GLOBAL_ONLY or GVF_BINARY_VAR) <> -1) then
              MH_set(LV_Show, MUIA_Floattext_Text, AsTag(@Buffer[0]))
            else
              DisplayBeep(nil);
          end;

          ID_DELETE: begin
            Vari := MH_Get(LV_Vars,MUIA_Dirlist_Path);
            if Vari <> 0 then
            begin
              MH_Set(LV_Show, MUIA_Floattext_Text, 0);
              DOSDeleteFile(PChar(Vari));
              DoMethod(LV_Vars, [MUIM_List_Remove, AsTag(MUIV_List_Remove_Active)]);
            end
            else
              DisplayBeep(nil);
          end;

          ID_SAVE: begin
            Vari := MH_Get(LV_Vars, MUIA_Dirlist_Path);
            if Vari <> 0 then
            begin
              MH_Set(App, MUIA_Application_Sleep, MUI_TRUE);
              Execute(PChar('copy env:' + string(FilePart(PChar(Vari))) + ' envarc:' + string(FilePart(PChar(Vari)))) , nil, nil);
              MH_Set(App, MUIA_Application_Sleep, MUI_FALSE);
            end
            else
              DisplayBeep(nil);
          end;

          ID_EDIT: begin
            Vari := MH_Get(LV_Vars, MUIA_Dirlist_Path);
            if Vari <> 0 then
            begin
              MH_Set(App, MUIA_Application_Sleep, MUI_TRUE);
              {$ifdef AROS}
              Execute(PChar('edit "' + string(PChar(Vari)) + '"'), nil, nil);
              {$else}
              Execute(PChar('ed -sticky "' + string(PChar(Vari)) + '"'), nil, nil);
              {$endif}
              MH_Set(App, MUIA_Application_Sleep, MUI_FALSE);
            end
            else
              DisplayBeep(nil);
          end;

        end;
        if running and (Sigs <> 0) then
        begin
          Sigs := Wait(sigs or SIGBREAKF_CTRL_C);
          if (Sigs and SIGBREAKF_CTRL_C) <>0 then
            Break;
        end;
      end;
    end;

    MH_Set(WI_Browser, MUIA_Window_Open, AsTag(False));

  finally
    if Assigned(App) then
      MUI_DisposeObject(app);
  end;
end;

begin
  StartMe;
end.
