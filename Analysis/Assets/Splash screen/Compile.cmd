setlocal
set bmp2tile=..\..\..\..\..\Delphi\bmp2tile\bmp2tile.exe
set compile="..\..\..\..\..\c\wla dx\binaries\Compile.bat" 

rem Convert graphics
for %%f in (*.png) do %bmp2tile% "%%f" -noremovedupes -savetiles "%%~nf" -exit

call %compile% splashscreen.bin.asm

fc /b splashscreen.bin SplashScreen.bin.original

rem TODO: compression