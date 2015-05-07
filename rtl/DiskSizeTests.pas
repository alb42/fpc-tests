program DiskSizeTest;

uses
  SysUtils;

var
  Size: Int64;
  Num, i: Integer;
  
begin
  writeln(HexStr(AOS_wbMsg));
  writeln('New Method:');
  Size := DiskSize(':');
  writeln(':', FloatToStrF(Size / 1024 / 1024, ffFixed, 8,1), ' MiB');
  Size := DiskSize('RAM:');
  writeln('RAM:', FloatToStrF(Size / 1024 / 1024, ffFixed, 8,1), ' MiB');
  Size := DiskSize('DF0:');
  writeln('DF0:', FloatToStrF(Size / 1024 / 1024, ffFixed, 8,1), ' MiB');
  Size := DiskSize('SYS:');
  writeln('SYS:', FloatToStrF(Size / 1024 / 1024, ffFixed, 8,1), ' MiB');
  writeln('Old Method:');
  // make DeviceList
  Num := RefreshDeviceList;
  Writeln('Loaded: ', Num, ' Devices to DeviceList');
  for i := 0 to Num - 1 do
  begin
    Size := DiskSize(i);
    writeln(i,'(' + DeviceByIdx(i) + ')= ', FloatToStrF(Size / 1024 / 1024, ffFixed, 8,1), ' MiB');
  end;
  Num := AddDisk('EMU:');
  Size := DiskSize(Num);
  writeln('EMU: ', Num, '=', FloatToStrF(Size / 1024 / 1024, ffFixed, 8,1), ' MiB');
end.
