@echo off
SETLOCAL ENABLEEXTENSIONS

pushd %~dp0
if exist Original ( echo Backup already exist!&goto :End ) else ( mkdir Original )
icacls c:\windows\Fonts\simsun* /save Original\acl /T
copy C:\Windows\Fonts\simsun* Original\

pushd Original
otc2otf sarasa-regular.ttc
otc2otf sarasa-bold.ttc
otc2otf simsun.ttc
ttx -t name NSimSun.ttf
ttx -t name SimSun.ttf
ttx -t name simsunb.ttf
del /q SimSun.ttf 2>nul
del /q NSimSun.ttf 2>nul
popd

:End
echo Done.
popd
pause