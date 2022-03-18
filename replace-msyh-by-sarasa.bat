@echo off
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
    call:Backup
    call:Convert
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
:Backup

if exist msyh-backup ( call:Warning "msyh-backup already exist!"&exit /b 0 ) else ( mkdir msyh-backup )
pushd msyh-backup

call:Warning "Backuping msys fonts..."

icacls c:\windows\Fonts\msyh* /save msyh-backup\acl /T
copy C:\Windows\Fonts\msyh* msyh-backup\

otc2otf msyh.ttc
otc2otf msyhl.ttc
otc2otf msyhbd.ttc
ttx -t name MicrosoftYaHei.ttf
ttx -t name MicrosoftYaHeiUI.ttf
ttx -t name MicrosoftYaHeiLight.ttf
ttx -t name MicrosoftYaHeiUILight.ttf
ttx -t name MicrosoftYaHei-Bold.ttf
ttx -t name MicrosoftYaHeiUI-Bold.ttf
del /q MicrosoftYaHei*.ttf 2>nul
popd
exit /b 0

rem ---------------------------------------------------------------------------
:Convert

if not exist sarasa mkdir sarasa 
pushd "%rootdir%\sarasa"

set downloaded=0
if exist sarasa-regular.ttc if exist sarasa-light.ttc if exist sarasa-bold.ttc set downloaded=1
if not %downloaded% equ 1 call:Download
if exist sarasa-regular.ttc if exist sarasa-light.ttc if exist sarasa-bold.ttc set downloaded=1
if not %downloaded% equ 1 call:Error "Download failed!" & exit /b -1

call:Warning "Converting sarasa fonts..."

otc2otf sarasa-regular.ttc
otc2otf sarasa-light.ttc
otc2otf sarasa-bold.ttc

del /q MicrosoftYaHei*.ttf 2>nul
del /q MicrosoftYaHei*.otf 2>nul

ttx -b -d "%cd%" -m Sarasa-UI-SC-Regular.ttf ..\msyh-backup\MicrosoftYaHei.ttx
ttx -b -d "%cd%" -m Sarasa-UI-SC-Regular.ttf ..\msyh-backup\MicrosoftYaHeiUI.ttx
ttx -b -d "%cd%" -m Sarasa-UI-SC-Light.ttf ..\msyh-backup\MicrosoftYaHeiLight.ttx
ttx -b -d "%cd%" -m Sarasa-UI-SC-Light.ttf ..\msyh-backup\MicrosoftYaHeiUILight.ttx
ttx -b -d "%cd%" -m Sarasa-UI-SC-Bold.ttf ..\msyh-backup\MicrosoftYaHei-Bold.ttx
ttx -b -d "%cd%" -m Sarasa-UI-SC-Bold.ttf ..\msyh-backup\MicrosoftYaHeiUI-Bold.ttx

otf2otc MicrosoftYaHei.ttf MicrosoftYaHeiUI.ttf -o msyh.ttc
otf2otc MicrosoftYaHeiLight.ttf MicrosoftYaHeiUILight.ttf -o msyhl.ttc
otf2otc MicrosoftYaHei-Bold.ttf MicrosoftYaHeiUI-Bold.ttf -o msyhbd.ttc

del /q Sarasa*.ttf 2>nul
del /q MicrosoftYaHei*.ttf 2>nul
popd
exit /b 0


rem ---------------------------------------------------------------------------
:Download

call:Warning "Downloading sarasa fonts..."
certutil.exe -urlcache -split -f^
 "https://github.com/be5invis/Sarasa-Gothic/releases/download/v0.36.0/sarasa-gothic-ttc-0.36.0.7z"^
 sarasa-gothic-ttc-0.36.0.7z
7z x -y sarasa-gothic-ttc-0.36.0.7z

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

pushd "%rootdir%\sarasa"
set converted=0
if exist msyh.ttc if exist msyhl.ttc if exist msyhbd.ttc set converted=1
if not %converted% equ 1 call:Error "Custom font not generated!" & exit /b -1

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