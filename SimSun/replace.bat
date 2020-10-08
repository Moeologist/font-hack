@echo off
SETLOCAL ENABLEEXTENSIONS

pushd "%~1"

dir "simsun*" 1>nul 2>nul
if ERRORLEVEL 1 echo Can not find fonts!&goto:End

takeown /F C:\Windows\Fonts\simsun* /A
icacls C:\Windows\Fonts\simsun* /grant Administrators:F

del /f /s /q C:\Windows\Fonts\simsun*
if exist C:\Windows\Fonts\simsun* echo Delete fonts failed!&exit /b 1

copy "%~dp0\simsun*" C:\Windows\Fonts

takeown /F C:\Windows\Fonts\simsun* /A
icacls C:\Windows\Fonts\simsun* /grant Administrators:F

icacls C:\windows\Fonts\simsun* /C /setowner "NT SERVICE\TrustedInstaller"
icacls C:\windows\Fonts\ /C /restore "Original\asl"

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "SimSun & NSimSun (TrueType)" /t REG_SZ /d "simsun.ttc" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "SimSun-ExtB (TrueType)" /t REG_SZ /d "simsunb.ttf" /f

:End
popd
pause