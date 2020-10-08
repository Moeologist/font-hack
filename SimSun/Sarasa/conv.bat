@echo off
SETLOCAL ENABLEEXTENSIONS

pushd "%~dp0"

REM otc2otf sarasa-regular.ttc
REM otc2otf sarasa-light.ttc
REM otc2otf sarasa-bold.ttc

del /q MicrosoftYaHei*.ttf 2>nul
del /q MicrosoftYaHei*.otf 2>nul

ttx -b -d "%cd%" -m Sarasa-UI-SC-Regular.ttf ..\Original\SimSun.ttx
ttx -b -d "%cd%" -m Sarasa-UI-SC-Regular.ttf ..\Original\NSimSun.ttx
ttx -b -d "%cd%" -m Sarasa-UI-SC-Bold.ttf ..\Original\simsunb.ttx

otf2otc NSimSun.ttf SimSun.ttf -o simsun.ttc

popd
pause