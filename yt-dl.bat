@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
set "FFMPEG_PATH=C:\ffmpeg_backup\bin"
if not exist "%FFMPEG_PATH%\ffmpeg.exe" (
    cls
    echo ERROR: ffmpeg.exe not found in:
    echo %FFMPEG_PATH%
    echo.
    echo Please adjust FFMPEG_PATH in the script.
    pause
    goto :menu
)

if not exist "%FFMPEG_PATH%\ffprobe.exe" (
    cls
    echo ERROR: ffprobe.exe not found in:
    echo %FFMPEG_PATH%
    echo.
    echo Please adjust FFMPEG_PATH in the script.
    pause
    goto :menu
)
yt-dlp --version
echo Using FFmpeg from:
echo %FFMPEG_PATH%
"%FFMPEG_PATH%\ffmpeg.exe" -version | findstr /i "version"
timeout /t 2 >nul
:menu
cls
echo loading...
set "url="
set "cleanurl="
set "format="
set "bitrate="
set "cookieparam="
title yt-dlp
ping -n 1 youtube.com >nul || (
echo ERROR: No internet connection
echo press to go to menu
pause >nul
cls
goto :menu
)
cls
echo menu
echo [1] download video
echo [2] download audio
echo [3] download video playlist
echo [4] download audio playlist
echo [5] update YT-dlp
echo [6] yt-dlp console
echo [7] Exit

choice /n /c 1234567
if errorlevel 7 exit

if errorlevel 6 (
start cmd /k yt-dlp -h
goto :menu
)

if errorlevel 5 (
cls
echo updating yt-dlp...
yt-dlp -U
echo press to go to menu
pause >nul
cls
goto :menu
)

rem Audioplaylist ------------------------------------------------
if errorlevel 4 (
title download audioplaylist
cls
set "cookieparam="
echo use cookies? ^(Y/N/B^)
choice /n /c YNB
if errorlevel 3 goto :menu
if errorlevel 2 set "cookieparam=" & goto :A
if errorlevel 1 set "cookieparam=--cookies cookies.txt" & goto :A

:A
cls
echo Enter the YouTube playlist URL:
<nul set /p=   >nul 2>&1
set /p url=
for /f "tokens=1 delims=&" %%A in ("%url%") do set "cleanurl=%%A"
yt-dlp --ignore-config --no-warnings --flat-playlist --simulate "%cleanurl%" >nul 2>&1
if errorlevel 1 (
	echo.
	echo ERROR: Invalid YouTube URL or unavailable.
	echo Press to go back
    pause >nul
    goto :A
)
cls
echo [1] Youtube Audiospur 
echo [2] Bitrate Konvertung
choice /n /c "12"
if errorlevel 2 (
cls
echo Enter the target MP3 bitrate in kbit/s:
echo [1] 128 kbit/s
echo [2] 192 kbit/s
echo [3] 256 kbit/s
echo [4] 320 kbit/s

choice /n /c 1234
if errorlevel 4 set bitrate=320 & goto :B
if errorlevel 3 set bitrate=256 & goto :B
if errorlevel 2 set bitrate=192 & goto :B
if errorlevel 1 set bitrate=128 & goto :B
)


if errorlevel 1 (
cls
yt-dlp --playlist-items 1 -F "%cleanurl%"
echo Enter a format number for audio only
<nul set /p=   >nul 2>&1
set /p format=

if "!format!"=="" (
	echo.
	echo ERROR: No format specified.
	echo press to go back
	pause >nul
    goto :A
)
yt-dlp --ffmpeg-location "%FFMPEG_PATH%" %cookieparam% -f "!format!" -o "%%USERPROFILE%%\Downloads\%%(playlist_title)s\%%(playlist_index)02d - %%(title)s.%%(ext)s" -N 4 %cleanurl%
goto :C
)

:B
cls
yt-dlp --ffmpeg-location "%FFMPEG_PATH%" %cookieparam% -x --audio-format mp3 --audio-quality %bitrate% -o "%%USERPROFILE%%\Downloads\%%(playlist_title)s\%%(playlist_index)02d - %%(title)s.%%(ext)s" -c -N 3 %cleanurl%
goto :C

:C
echo.
echo Download complete!
echo press to go to menu
pause >nul
explorer "%USERPROFILE%\Downloads"
cls
goto :menu
)

rem Videoplaylist ------------------------------------------
if errorlevel 3 (
title download videoplaylist
cls
set "cookieparam="
echo use cookies? ^(Y/N/B^)
choice /n /c YNB
if errorlevel 3 goto :menu
if errorlevel 2 set "cookieparam=" & goto :D
if errorlevel 1 set "cookieparam=--cookies cookies.txt" & goto :D

:D
cls
echo enter the Youtube Videoplaylist URL:
<nul set /p=   >nul 2>&1
set /p url=
for /f "tokens=1 delims=&" %%A in ("%url%") do set "cleanurl=%%A"
:DA
cls
yt-dlp --playlist-items 1 -F "%cleanurl%"
echo Enter a format or Video+Audio
<nul set /p=   >nul 2>&1
set /p format=

if "!format!"=="" (
	echo.
	echo ERROR: No format specified.
	echo press to go back
	pause >nul
    goto :DA
)
yt-dlp --ffmpeg-location "%FFMPEG_PATH%" %cookieparam% -f "!format!" --merge-output-format mp4 -o "%%USERPROFILE%%\Downloads\%%(playlist_title)s\%%(playlist_index)02d - %%(title)s.%%(ext)s" -N 4 %cleanurl%
if errorlevel 1 (
    echo.
    echo Error: Press to go back
    pause >nul
    cls
    goto :DA
)
echo.
echo download complete!
echo press to go to menu
pause >nul
explorer "%USERPROFILE%\Downloads"
cls
goto :menu
)

rem Audio ------------------------------------------------
if errorlevel 2 (
title download audio
cls
set "cookieparam="
echo use Youtube cookies? ^(Y/N/B^)
choice /n /c YNB
if errorlevel 3 goto :menu
if errorlevel 2 set "cookieparam=" & goto :E
if errorlevel 1 set "cookieparam=--cookies cookies.txt" & goto :E

:E
cls
echo Enter the audio URL:
<nul set /p=   >nul 2>&1
set /p url=
for /f "tokens=1 delims=&" %%A in ("%url%") do set "cleanurl=%%A"

yt-dlp --ignore-config --no-warnings --simulate "%cleanurl%" >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Invalid URL or unavailable.
	echo Press to go back
    pause >nul
    goto :E
)

:F
cls
echo Enter the target MP3 bitrate in kbit/s:
echo [1] 128 kbit/s
echo [2] 192 kbit/s
echo [3] 256 kbit/s
echo [4] 320 kbit/s

choice /n /c 1234
if errorlevel 4 set bitrate=320 & goto :G
if errorlevel 3 set bitrate=256 & goto :G
if errorlevel 2 set bitrate=192 & goto :G
if errorlevel 1 set bitrate=128 & goto :G

:G
cls
yt-dlp --ffmpeg-location "%FFMPEG_PATH%" %cookieparam% -x --audio-format mp3 --audio-quality %bitrate% -o "%%USERPROFILE%%\Downloads\%%(title)s.%%(ext)s" -N 4 %cleanurl%

echo.
echo Download complete!
echo press to go to menu
pause >nul
explorer "%USERPROFILE%\Downloads"
cls
goto :menu
)

rem Video ------------------------------------------------
if errorlevel 1 (
title download video
cls
set "cookieparam="
echo use Youtube cookies? ^(Y/N/B^)
choice /n /c YNB
if errorlevel 3 goto :menu
if errorlevel 2 set "cookieparam=" & goto :H
if errorlevel 1 set "cookieparam=--cookies helena_cookies.txt" & goto :H

:H
cls
echo video URL:
<nul set /p=   >nul 2>&1
set /p url=
for /f "tokens=1 delims=&" %%A in ("%url%") do set "cleanurl=%%A"
:I
cls
yt-dlp -F "%cleanurl%"
if errorlevel 1 (
	echo Press to go back
    pause >nul
    goto :H
)

echo.
echo Enter a format number or Video+Audio
<nul set /p=   >nul 2>&1
set /p format=

:J
yt-dlp --ffmpeg-location "%FFMPEG_PATH%" %cookieparam% -f "%format%" --merge-output-format mp4 -o "%%USERPROFILE%%\Downloads\%%(title)s.%%(ext)s" -N 4 %cleanurl%
if errorlevel 1 (
    echo.
    echo Error: Press to go back
    pause >nul
    cls
    goto :I
)
echo.
echo download complete!
echo press to go to menu
pause >nul
explorer "%USERPROFILE%\Downloads"
cls
goto :menu
)
