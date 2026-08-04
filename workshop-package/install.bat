@echo off
REM Workshop one-click installer. Double-click this file.
REM All messages live in install.ps1 (UTF-8) to avoid codepage issues.
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
