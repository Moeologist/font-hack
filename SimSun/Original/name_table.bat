pushd "%~dp0"
otc2otf sarasa-regular.ttc
otc2otf sarasa-bold.ttc
otc2otf simsun.ttc
ttx -t name NSimSun.ttf
ttx -t name SimSun.ttf
ttx -t name simsunb.ttf
del /q SimSun.ttf 2>nul
del /q NSimSun.ttf 2>nul
popd
