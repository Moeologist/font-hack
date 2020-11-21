@echo off
SETLOCAL ENABLEEXTENSIONS

pushd "%~dp0"
set /P Name=font dir:
pushd "%Name%"

dir "msyh*" 1>nul 2>nul
if ERRORLEVEL 1 echo Can not find fonts!&goto:End

takeown /F C:\Windows\Fonts\msyh* /A
icacls C:\Windows\Fonts\msyh* /grant Administrators:F

del /f /s /q C:\Windows\Fonts\msyh*
if exist C:\Windows\Fonts\msyh* echo Delete fonts failed!&goto:End

copy "msyh*" C:\Windows\Fonts

takeown /F C:\Windows\Fonts\msyh* /A
icacls C:\Windows\Fonts\msyh* /grant Administrators:F

icacls C:\windows\Fonts\msyh* /C /setowner "NT SERVICE\TrustedInstaller"
icacls C:\windows\Fonts\ /C /restore "..\Original\acl"

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Microsoft Yahei & Microsoft Yahei UI (TrueType)" /t REG_SZ /d "msyh.ttc" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Microsoft Yahei Bold & Microsoft Yahei UI Bold (TrueType)" /t REG_SZ /d "msyhbd.ttc" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Microsoft Yahei Light & Microsoft Yahei UI Light (TrueType)" /t REG_SZ /d "msyhl.ttc" /f

popd

:End
popd
pause
