for /r %%f in (*.?bpp.png) do ..\..\..\..\Delphi\bmp2tile\bmp2tile.exe "%%f" -noremovedupes -savetiles "%%~dpnf" -exit
rem Need to make a "4bpp" not-compressor?
for /r %%f in (*.4bpp.png) do ..\..\..\..\Delphi\bmp2tile\bmp2tile.exe "%%f" -noremovedupes -savetiles "%%~dpnf.bin" -exit
for /r %%f in (*.4bpp.bin) do move /y "%%f" "%%~dpnf"
