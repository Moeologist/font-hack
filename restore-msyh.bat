@REM @echo off
SETLOCAL ENABLEEXTENSIONS

net session 2>nul 1>nul
if not %errorlevel% equ 0 (
    powershell -Command "Start-Process -Verb RunAs -FilePath '%0'"
    exit /b
)

set "rootdir=%~dp0"
pushd "%rootdir%"
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Microsoft Yahei & Microsoft Yahei UI (TrueType)" 2>nul 1>nul

if %ERRORLEVEL% equ 0 (
    call:DeleteReg
    call:Warning "Press any key to logout"
    pause
    shutdown -L
) else (
    call:ReplaceFiles
    call:Warning "Press any key to logout"
    pause
    shutdown -L
)

popd
pause
exit /b 0


rem ---------------------------------------------------------------------------
:DeleteReg

pushd "%rootdir%\sarasa"
set converted=0
if exist msyh.ttc if exist msyhl.ttc if exist msyhbd.ttc set converted=1
if not %converted% equ 1 call:Error "Custom font not generated!" & exit /b -1

call:Warning "Deleting reg items..."

reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Microsoft Yahei & Microsoft Yahei UI (TrueType)" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Microsoft Yahei Bold & Microsoft Yahei UI Bold (TrueType)" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Microsoft Yahei Light & Microsoft Yahei UI Light (TrueType)" /f

popd
exit /b 0

rem ---------------------------------------------------------------------------
:ReplaceFiles

if not exist "%rootdir%\msyh-backup" call:Error "Backup directory not existed!" & exit /b -1
pushd "%rootdir%\msyh-backup"
set converted=0
if exist msyh.ttc if exist msyhl.ttc if exist msyhbd.ttc set converted=1
if not %converted% equ 1 call:Error "Vanilla font not existed!" & exit /b -1

call:Warning "Replacing Files..."
takeown /F C:\Windows\Fonts\msyh* /A
icacls C:\Windows\Fonts\msyh* /grant Administrators:F

del /f /s /q C:\Windows\Fonts\msyh*
if exist C:\Windows\Fonts\msyh* echo Delete fonts failed!&goto:End

copy "msyh*" C:\Windows\Fonts

takeown /F C:\Windows\Fonts\msyh* /A
icacls C:\Windows\Fonts\msyh* /grant Administrators:F

icacls C:\windows\Fonts\msyh* /C /setowner "NT SERVICE\TrustedInstaller"
icacls C:\windows\Fonts\ /C /restore "..\msyh-backup\acl"

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Microsoft Yahei & Microsoft Yahei UI (TrueType)" /t REG_SZ /d "msyh.ttc" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Microsoft Yahei Bold & Microsoft Yahei UI Bold (TrueType)" /t REG_SZ /d "msyhbd.ttc" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Microsoft Yahei Light & Microsoft Yahei UI Light (TrueType)" /t REG_SZ /d "msyhl.ttc" /f

popd
exit /b 0


rem ---------------------------------------------------------------------------
:Warning
echo.[93m%~1[0m>&2
exit /b 0

rem ---------------------------------------------------------------------------
:Error
echo.[91m%~1[0m>&2
exit /b 0