@echo off
SETLOCAL ENABLEEXTENSIONS

pushd "%~dp0"

otc2otf sarasa-regular.ttc
otc2otf sarasa-light.ttc
otc2otf sarasa-bold.ttc

del /q MicrosoftYaHei*.ttf 2>nul
del /q MicrosoftYaHei*.otf 2>nul

ttx -b -d "%cd%" -m Sarasa-UI-SC-Regular.ttf ..\Original\MicrosoftYaHei.ttx
ttx -b -d "%cd%" -m Sarasa-UI-SC-Regular.ttf ..\Original\MicrosoftYaHeiUI.ttx
ttx -b -d "%cd%" -m Sarasa-UI-SC-Light.ttf ..\Original\MicrosoftYaHeiLight.ttx
ttx -b -d "%cd%" -m Sarasa-UI-SC-Light.ttf ..\Original\MicrosoftYaHeiUILight.ttx
ttx -b -d "%cd%" -m Sarasa-UI-SC-Bold.ttf ..\Original\MicrosoftYaHei-Bold.ttx
ttx -b -d "%cd%" -m Sarasa-UI-SC-Bold.ttf ..\Original\MicrosoftYaHeiUI-Bold.ttx

otf2otc MicrosoftYaHei.ttf MicrosoftYaHeiUI.ttf -o msyh.ttc
otf2otc MicrosoftYaHeiLight.ttf MicrosoftYaHeiUILight.ttf -o msyhl.ttc
otf2otc MicrosoftYaHei-Bold.ttf MicrosoftYaHeiUI-Bold.ttf -o msyhbd.ttc

popd
pause