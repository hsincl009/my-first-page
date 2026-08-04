@echo off
REM Workshop environment self-check. Double-click this file.
REM All messages live in check-env.ps1 (UTF-8) to avoid codepage issues.
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0check-env.ps1"
pause
