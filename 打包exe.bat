@echo off
setlocal
set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"
set "GODOT=%ROOT%\..\Godot_v4.7-stable_win64_console.exe"
set "BUILD_DIR=%ROOT%\..\build"
set "OUT_EXE=%BUILD_DIR%\PhysicalArena.exe"

if not exist "%GODOT%" (
  echo Godot console not found: "%GODOT%"
  pause
  exit /b 1
)

if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

echo Validating project...
"%GODOT%" --headless --path "%ROOT%" --quit
if errorlevel 1 (
  echo Project validation failed. Export stopped.
  pause
  exit /b 1
)

echo Exporting Windows exe...
"%GODOT%" --headless --path "%ROOT%" --export-release "Windows Desktop" "%OUT_EXE%"
if errorlevel 1 (
  echo.
  echo Export failed. Common reason: Windows export templates are not installed.
  echo Open Godot: Project -^> Install Export Templates, then run this script again.
  pause
  exit /b 1
)

echo.
echo Export complete: %OUT_EXE%
pause
endlocal
