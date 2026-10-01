@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File ".\tools\run.ps1" %*
set RC=%errorlevel%
if not "%RC%"=="0" pause
exit /b %RC%
