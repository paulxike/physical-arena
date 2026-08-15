@echo off
setlocal
set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"
set "GODOT=%ROOT%\..\Godot_v4.7-stable_win64.exe"

if not exist "%GODOT%" (
  echo Godot not found: "%GODOT%"
  pause
  exit /b 1
)

start "Physical Arena" "%GODOT%" --path "%ROOT%"
endlocal
