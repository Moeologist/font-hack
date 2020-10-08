@echo off
SETLOCAL ENABLEEXTENSIONS

pushd "%~dp0"

otc2otf SourceHanSans.ttc

del /q MicrosoftYaHei*.ttf 2>nul
del /q MicrosoftYaHei*.otf 2>nul
del /q MicrosoftYaHei*.ttx 2>nul

copy ..\Original\*.ttx .\

call :replace MicrosoftYaHei.ttx "\\x00\\x01\\x00\\x00" "OTTO"
call :replace MicrosoftYaHeiUI.ttx "\\x00\\x01\\x00\\x00" "OTTO"
call :replace MicrosoftYaHeiLight.ttx "\\x00\\x01\\x00\\x00" "OTTO"
call :replace MicrosoftYaHeiUILight.ttx "\\x00\\x01\\x00\\x00" "OTTO"
call :replace MicrosoftYaHei-Bold.ttx "\\x00\\x01\\x00\\x00" "OTTO"
call :replace MicrosoftYaHeiUI-Bold.ttx "\\x00\\x01\\x00\\x00" "OTTO"

ttx -b -d "%cd%" -m SourceHanSansSC-Regular.otf MicrosoftYaHei.ttx
ttx -b -d "%cd%" -m SourceHanSansSC-Regular.otf MicrosoftYaHeiUI.ttx
ttx -b -d "%cd%" -m SourceHanSansSC-Light.otf MicrosoftYaHeiLight.ttx
ttx -b -d "%cd%" -m SourceHanSansSC-Light.otf MicrosoftYaHeiUILight.ttx
ttx -b -d "%cd%" -m SourceHanSansSC-Bold.otf MicrosoftYaHei-Bold.ttx
ttx -b -d "%cd%" -m SourceHanSansSC-Bold.otf MicrosoftYaHeiUI-Bold.ttx

otf2otc MicrosoftYaHei.otf MicrosoftYaHeiUI.otf -o msyh.ttc
otf2otc MicrosoftYaHeiLight.otf MicrosoftYaHeiUILight.otf -o msyhl.ttc
otf2otc MicrosoftYaHei-Bold.otf MicrosoftYaHeiUI-Bold.otf -o msyhbd.ttc

popd
pause
exit /b 0

:replace
call powershell -Command "(Get-Content -encoding UTF8 """..\Original\%~1""") -replace """%~2""", """%~3""" | Out-File -encoding UTF8 %~1"
exit /b 0