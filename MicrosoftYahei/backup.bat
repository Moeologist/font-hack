@echo off
SETLOCAL ENABLEEXTENSIONS

pushd "%~dp0"
if exist Original ( echo Backup already exist!&goto :End ) else ( mkdir Original )
icacls c:\windows\Fonts\msyh* /save Original\acl /T
copy C:\Windows\Fonts\msyh* Original\

pushd Original
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

:End
echo Done.
popd
pause