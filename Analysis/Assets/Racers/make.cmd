for %%f in (*.3bpp.png) do ..\..\..\..\..\Delphi\bmp2tile\bmp2tile.exe "%%f" -noremovedupes -savetiles "%%~nf" -exit
