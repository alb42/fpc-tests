unit StartProgUnit;

{$mode objfpc}{$H+}

interface

uses
  {$ifdef HASAMIGA}
  Exec, amigados, utility, tagsarray, Workbench,
  {$endif}
  Classes, SysUtils;

type

  { TAROSPrgStarter }

  TAROSPrgStarter = class
  private
    IsRunning: Boolean;
    ReturnCode: Integer;
    FName: string;
    FParams: string;
    FOnUpdate: TNotifyEvent;
  public
    FStackSize: Integer;
    ErrAsOutput: boolean;
    constructor Create; virtual;
    function StartUp(Name, params: string; Output: TStrings): Integer;
    property OnUpdate: TNotifyEvent read FOnUpdate write FOnUpdate;
  end;

implementation

var
  UID: Integer = 0;

// Exit code for the command
{$ifdef HASAMIGA}
procedure MyExitCode(Ret: LongInt; Data: Pointer); cdecl;
var
  APS: TAROSPrgStarter;
begin
  if Assigned(Data) then
  begin
    if (TObject(Data) is TAROSPrgStarter) then
    begin
      APS := TAROSPrgStarter(Data);
      APS.IsRunning := False;
      APS.ReturnCode := Ret;
    end;
  end;
end;
{$endif}

{ TAROSPrgStarter }

constructor TAROSPrgStarter.Create;
begin
  inherited;
  ErrAsOutput := False;
  FStackSize := 1024*1024;
end;

{$ifdef HASAMIGA}
function CheckName(Na: string): boolean;
begin
  Result := False;
  if Pos('wanderer', Na) > 0 then    // standard (WANDERER:Wanderer)
    Result := True;
  if Pos('opus5', Na) > 0 then       // Icaros with Opus5
    Result := True;
  if Pos('shell', Na) > 0 then       // any other Shell would also do it
    Result := True;
  if Pos('directoryopus', Na) > 0 then // Other DirectoryOpus StartUp
    Result := True;
end;

// get a process with a working CLI
function GetProcess: PProcess;
var
  List: Exec.PList;
  Node: PNode;
  Na: string;
begin
  Result := nil;
  Exec.Disable();
  try
    List := @PExecBase(AOS_ExecBase)^.TaskReady;
    Node := List^.lh_Head^.ln_Succ;
    while Assigned(Node) and Assigned(Node^.ln_Succ) do
    begin
      if Assigned(Node^.ln_Name) then
      begin
        Na := LowerCase(Node^.ln_Name);
        if CheckName(Na) then
          Result := PProcess(Node);
      end;
      Node := Node^.ln_Succ;
    end;
    //
    List := @PExecBase(AOS_ExecBase)^.TaskWait;
    Node := List^.lh_Head^.ln_Succ;
    while Assigned(Node) and Assigned(Node^.ln_Succ) do
    begin
      if Assigned(Node^.ln_Name) then
      begin
        Na := LowerCase(Node^.ln_Name);
        if CheckName(Na) then
          Result := PProcess(Node);
      end;
      Node := Node^.ln_Succ;
    end;
  finally
    Exec.Enable();
  end;
end;


function TAROSPrgStarter.StartUp(Name, params: string; Output: TStrings): Integer;
var
  TempName: string;
  f: Text;
  s: string;
  Handle: BPTR;
  cer, cos: BPTR;
  CLI: Pointer;
  Process: PProcess;
  MyProcess: PProcess;
  OldCLI: Pointer;
begin
  FName := Name;
  FParams := Params;
  Cli := nil;
  OldCLI := nil;
  MyProcess := nil;
  // Temp file name
  repeat
    Inc(UID);
    TempName := 'T:'+HexStr(FindTask(nil)) + '_'  + HexStr(Self) + '_'+ IntToStr(UID) + '_Starter.tmp';
  until not FileExists(TempName);
  // open the File for the Startup, using AROS calls
  Handle := DOSOpen(PChar(TempName), MODE_READWRITE);
  // assign the very same file with RTL things
  assign(f,TempName);
  // clear result stringlist
  Output.Clear;
  // if started from CLI the path is missing
  if Assigned(AOS_WbMsg) then
  begin
    // Myself
    MyProcess := PProcess(FindTask(nil));
    // process with a usable CLI/Path
    Process := GetProcess;
    if Assigned(Process) then
      Cli := Process^.pr_CLI;
    OldCLI := MyProcess^.pr_CLI;
    MyProcess^.pr_CLI := cli;
  end;
  // Running is set to false at end of the command
  IsRunning := True;
  // header for the output
  Output.Add('Start: ' + Name + ' ' + Params);
  Output.Add('########################################');
  // Set captured Output, Error or Output to catch -> GCC Error, FPC Output
  //TODO: Catch both
  cer := nil;
  cos := nil;
  if ErrAsOutput then
    cer := Handle
  else
    Cos := Handle;
  // Start the program
  SystemTags(PChar(Name + ' ' + Params),[
    SYS_ASYNCh, LongInt(True),
    SYS_Input, 0,
    NP_CLI, 1,
    NP_StackSize, FStackSize,
    SYS_Output, PtrUInt(cos),
    SYS_Error, PtrUInt(cer),
    NP_ExitCode, PtrUInt(@MyExitCode),
    NP_ExitData, PtrUInt(Self),
    NP_UserData, PtrUInt(Self),
    TAG_END, TAG_END]);
  // Open the File to read
  Reset(F);
  // Main cycle
  while isRunning do
  begin
    // there is some output to catch
    while not EOF(F) do
    begin
      Readln(f,s);   //read the data
      Output.Add(s); // put to out StringList
    end;
    // finished ... break
    if not isRunning then
      Break;
    // Call Event to update (Main win will also call eventloop)
    if Assigned(FOnUpdate) then
      FOnUpdate(self);
    // Spend some time
    Sleep(25);
  end;
  // End of mayn cycle
  // read rest of the outputfile
  while not EOF(F) do
  begin
    Readln(f,s);
    Output.Add(s);
  end;
  // Close and Erase the output file
  Close(F);
  Erase(f);
  // Get the Resturn Code
  Result := ReturnCode;
  // End marker of Output
  Output.Add('########################################');
  // set back the CLI variable
  if Assigned(AOS_WbMsg) then
  begin
    MyProcess^.pr_CLI := OldCLI;
  end;
  // End of Output
  Output.Add('Program finished: ' + IntToStr(ReturnCode));
end;
{$else}
function TAROSPrgStarter.StartUp(Name, params: string; Output: TStrings): Integer;
begin

end;
{$endif}

end.

