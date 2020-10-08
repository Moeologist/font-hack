@echo off
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Microsoft Yahei & Microsoft Yahei UI (TrueType)" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Microsoft Yahei Bold & Microsoft Yahei UI Bold (TrueType)" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Microsoft Yahei Light & Microsoft Yahei UI Light (TrueType)" /f
pause