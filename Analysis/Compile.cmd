rem @echo off
setlocal
set wla=..\..\..\c\wla-dx\binaries\Compile.bat

call :compile "Jon's Squinky Tennis.gg.asm" "Assets\Jon's Squinky Tennis\JonsSquinkyTennis.gg"
if errorlevel 1 goto :eof
call :compile "Splash screen.bin.asm" "Assets\Splash screen\SplashScreen.bin"
if errorlevel 1 goto :eof
call :compile "Micro Machines.sms.asm" "..\..\..\..\Roms\Micro Machines.sms"
if errorlevel 1 goto :eof

goto :eof

:compile
echo %1 -^> %~n1...
call %wla% %1
if errorlevel 1 echo FAIL
if errorlevel 1 exit /b 1
fc /b "%~n1" %2
if errorlevel 1 echo FAIL
if errorlevel 1 exit /b 1
goto :eof
