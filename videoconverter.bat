@echo off
:menu
cls
echo Ziehe die Videodatei hier hinein und druecke ENTER:
set /p input=

:: Anfuehrungszeichen entfernen
set input=%input:"=%

if not exist "%input%" (
    echo Datei nicht gefunden.
    pause
    exit
)
cls
echo Gib die gewuenschte Videobitrate ein (z.B. 800k, 1000k):
set /p vbitrate=
cls
for %%F in ("%input%") do set "output=%%~dpnF_ipod_360p.mp4"
ffmpeg -i "%input%" -c:v libx264 -vf scale=-2:360 -profile:v baseline -level 3.0 -pix_fmt yuv420p -preset slow -b:v %vbitrate% -movflags +faststart -c:a libfdk_aac -profile:a aac_low -b:a 128k -ac 2 -ar 44100 "%output%"
cls
echo Fertig.
pause
goto menu