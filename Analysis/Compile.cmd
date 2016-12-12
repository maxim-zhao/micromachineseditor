call "..\..\..\c\wla dx\binaries\Compile.bat" "Micro Machines.sms.asm"
if errorlevel 1 echo FAIL
if errorlevel 1 goto :eof
fc /b "Micro Machines.sms" "..\..\..\..\Roms\Micro Machines.sms" | more
if errorlevel 1 echo FAIL
