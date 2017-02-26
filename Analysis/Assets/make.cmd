for /r %%f in (*.3bpp.png) do ..\..\..\..\Delphi\bmp2tile\bmp2tile.exe "%%f" -noremovedupes -savetiles "%%~dpnf" -exit
for /r %%f in (*.4bpp.png) do ..\..\..\..\Delphi\bmp2tile\bmp2tile.exe "%%f" -noremovedupes -savetiles "%%~dpnf.bin" -exit
rem Need to make a "4bpp" not-compressor?
for /r %%f in (*.4bpp.bin) do ren "%%f" "%%~nf"
