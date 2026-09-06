@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

title GTA Launcher - Windows Build
color 0A

echo.
echo ================================================
echo          GTA LAUNCHER - WINDOWS BUILD
echo ================================================
echo.

:: ------------------------------------------------
:: 1. Check winget
:: ------------------------------------------------
where winget >nul 2>&1
if errorlevel 1 (
    echo [ERROR] winget is not installed or not available.
    echo Install App Installer from Microsoft Store and run this file again.
    pause
    exit /b 1
)

:: ------------------------------------------------
:: 2. Install Node.js LTS
:: ------------------------------------------------
echo [1/7] Checking Node.js...
where node >nul 2>&1
if errorlevel 1 (
    echo Node.js not found. Installing Node.js LTS...
    winget install --id OpenJS.NodeJS.LTS -e --accept-package-agreements --accept-source-agreements
    if errorlevel 1 goto :install_error
) else (
    echo Node.js already installed.
)

:: ------------------------------------------------
:: 3. Install Rust + rustup
:: ------------------------------------------------
echo [2/7] Checking Rust...
where rustc >nul 2>&1
if errorlevel 1 (
    echo Rust not found. Installing Rustup...
    winget install --id Rustlang.Rustup -e --accept-package-agreements --accept-source-agreements
    if errorlevel 1 goto :install_error
) else (
    echo Rust already installed.
)

:: Refresh PATH for newly installed Node/Rust in this CMD process
set "PATH=%ProgramFiles%\nodejs;%USERPROFILE%\.cargo\bin;%PATH%"

:: ------------------------------------------------
:: 4. Install Visual C++ Build Tools
:: ------------------------------------------------
echo [3/7] Checking Microsoft C++ Build Tools...
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
set "VSHASBUILD=0"
if exist "%VSWHERE%" (
    "%VSWHERE%" -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -latest >nul 2>&1
    if not errorlevel 1 set "VSHASBUILD=1"
)

if "%VSHASBUILD%"=="0" (
    echo Visual C++ Build Tools not found. Installing required workload...
    winget install --id Microsoft.VisualStudio.2022.BuildTools -e --accept-package-agreements --accept-source-agreements --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
    if errorlevel 1 goto :install_error
) else (
    echo Visual C++ Build Tools already installed.
)

:: ------------------------------------------------
:: 5. Configure Rust Windows target
:: ------------------------------------------------
echo [4/7] Configuring Rust Windows target...
call "%USERPROFILE%\.cargo\bin\rustup.exe" default stable-x86_64-pc-windows-msvc >nul 2>&1
call "%USERPROFILE%\.cargo\bin\rustup.exe" target add x86_64-pc-windows-msvc
if errorlevel 1 goto :rust_error

:: ------------------------------------------------
:: 6. Install frontend / Tauri dependencies
:: ------------------------------------------------
echo [5/7] Installing npm dependencies...
if not exist package.json (
    echo [ERROR] package.json was not found.
    goto :build_error
)

call npm install
if errorlevel 1 goto :npm_error

:: ------------------------------------------------
:: 7. Generate icons + build installer
:: ------------------------------------------------
echo [6/7] Generating Tauri icons...
if exist src-tauri\icons\icon.svg (
    call npm run tauri icon src-tauri\icons\icon.svg
    if errorlevel 1 goto :build_error
) else (
    echo [WARN] src-tauri\icons\icon.svg not found. Skipping icon generation.
)

echo [7/7] Building Windows installers...
call npm run tauri build
if errorlevel 1 goto :build_error

echo.
echo ================================================
echo                 BUILD COMPLETE
echo ================================================
echo.

echo NSIS installer:
echo   src-tauri\target\release\bundle\nsis\
echo.
echo MSI installer:
echo   src-tauri\target\release\bundle\msi\
echo.

if exist "src-tauri\target\release\bundle\nsis\*.exe" (
    echo EXE installer created successfully.
) else (
    echo [WARN] EXE installer was not found.
)

echo.
echo You can now install GTA Launcher on Windows.
echo.
pause
exit /b 0

:install_error
echo.
echo [ERROR] Dependency installation failed.
echo Run this BAT as Administrator and try again.
pause
exit /b 1

:rust_error
echo.
echo [ERROR] Rust target configuration failed.
echo Close this window, open a new CMD and run the BAT again.
pause
exit /b 1

:npm_error
echo.
echo [ERROR] npm install failed.
echo Check your internet connection and try again.
pause
exit /b 1

:build_error
echo.
echo [ERROR] Tauri build failed.
echo Check the error above for details.
pause
exit /b 1
