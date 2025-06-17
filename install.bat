@echo off
setlocal enabledelayedexpansion
title toFreedium Extension - One Click Installer

REM Color codes for better visual feedback
color 0A

echo.
echo ===============================================
echo    toFreedium Extension One-Click Installer
echo ===============================================
echo.

REM Check if running as administrator (optional, for better compatibility)
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrator privileges...
) else (
    echo Running with user privileges...
)

REM Find Chrome installation
echo [1/5] Searching for Chrome installation...
set "CHROME_PATH="
set "CHROME_FOUND=0"

REM Check common Chrome installation paths
for %%p in (
    "C:\Program Files\Google\Chrome\Application\chrome.exe"
    "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
    "%PROGRAMFILES%\Google\Chrome\Application\chrome.exe"
    "%PROGRAMFILES(X86)%\Google\Chrome\Application\chrome.exe"
) do (
    if exist "%%~p" (
        set "CHROME_PATH=%%~p"
        set "CHROME_FOUND=1"
        echo    Chrome found: %%~p
        goto :chrome_found
    )
)

if !CHROME_FOUND!==0 (
    echo    ERROR: Chrome not found!
    echo    Please install Google Chrome first.
    echo    Download from: https://www.google.com/chrome/
    pause
    exit /b 1
)

:chrome_found

REM Check if Chrome is running and close it
echo [2/5] Checking if Chrome is running...
tasklist /FI "IMAGENAME eq chrome.exe" 2>NUL | find /I /N "chrome.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo    Chrome is running. Attempting to close...
    taskkill /F /IM chrome.exe >nul 2>&1
    timeout /t 2 /nobreak >nul
    echo    Chrome closed.
) else (
    echo    Chrome is not running.
)

REM Set up installation directory
echo [3/5] Setting up installation directory...
set "INSTALL_DIR=%USERPROFILE%\toFreedium_Extension"
set "TEMP_DIR=%TEMP%\toFreedium_temp"

REM Clean up any existing installation
if exist "%INSTALL_DIR%" (
    echo    Removing existing installation...
    rmdir /s /q "%INSTALL_DIR%" >nul 2>&1
)
if exist "%TEMP_DIR%" (
    rmdir /s /q "%TEMP_DIR%" >nul 2>&1
)

REM Create directories
mkdir "%INSTALL_DIR%" >nul 2>&1
mkdir "%TEMP_DIR%" >nul 2>&1

REM Find and extract the ZIP file
echo [4/5] Extracting extension files...
set "ZIP_FOUND=0"
set "ZIP_FILE="

REM Look for ZIP file in the same directory as the batch file
for %%f in (*.zip) do (
    set "ZIP_FILE=%%f"
    set "ZIP_FOUND=1"
    echo    Found ZIP file: %%f
    goto :extract_zip
)

REM If no ZIP found, look for common names
for %%f in (
    "toFreedium.zip"
    "extension.zip"
    "tofreedium.zip"
    "freedium.zip"
) do (
    if exist "%%f" (
        set "ZIP_FILE=%%f"
        set "ZIP_FOUND=1"
        echo    Found ZIP file: %%f
        goto :extract_zip
    )
)

if !ZIP_FOUND!==0 (
    echo    ERROR: No ZIP file found!
    echo    Please make sure the extension ZIP file is in the same folder as this installer.
    pause
    exit /b 1
)

:extract_zip
REM Extract using PowerShell (available on Windows 7+)
echo    Extracting !ZIP_FILE!...
powershell -command "try { Expand-Archive -Path '!ZIP_FILE!' -DestinationPath '!TEMP_DIR!' -Force; Write-Host '    Extraction completed successfully' } catch { Write-Host '    ERROR: Extraction failed'; exit 1 }" 2>nul

if !ERRORLEVEL! neq 0 (
    echo    ERROR: Failed to extract ZIP file!
    echo    Please make sure the ZIP file is not corrupted.
    pause
    exit /b 1
)

REM Move extracted files to final location
echo    Moving files to installation directory...
for /d %%d in ("%TEMP_DIR%\*") do (
    move "%%d\*" "%INSTALL_DIR%\" >nul 2>&1
)
for %%f in ("%TEMP_DIR%\*") do (
    move "%%f" "%INSTALL_DIR%\" >nul 2>&1
)

REM Clean up temp directory
rmdir /s /q "%TEMP_DIR%" >nul 2>&1

REM Verify essential files exist
if not exist "%INSTALL_DIR%\manifest.json" (
    echo    ERROR: manifest.json not found in extracted files!
    echo    Please check if the ZIP file contains a valid Chrome extension.
    pause
    exit /b 1
)

echo    Extension files extracted successfully!

REM Open Chrome with extensions page
echo [5/5] Opening Chrome extensions page...
start "" "!CHROME_PATH!" --new-window --disable-features=TranslateUI chrome://extensions/

REM Wait a moment for Chrome to load
timeout /t 3 /nobreak >nul

REM Open the extension folder in Explorer
echo    Opening extension folder...
explorer "%INSTALL_DIR%"


echo.
echo ===============================================
echo           INSTALLATION COMPLETE!
echo ===============================================
echo.
echo Chrome should now be open with the Extensions page.
echo Extension folder: %INSTALL_DIR%
echo.
echo NEXT STEPS:
echo 1. In Chrome, enable "Developer mode" (toggle in top-right)
echo 2. Click "Load unpacked" button
echo 3. Select the opened folder: %INSTALL_DIR%
echo 4. The extension will be installed and ready to use!
echo.
echo TIP: You can also drag the folder directly onto the Chrome 
echo      extensions page after enabling Developer mode.
echo.
echo ===============================================

REM Ask if user wants to see detailed instructions
set /p "SHOW_HELP=Show detailed instructions? (y/n): "
if /i "!SHOW_HELP!"=="y" goto :show_help
if /i "!SHOW_HELP!"=="yes" goto :show_help
goto :end

:show_help
echo.
echo ===============================================
echo           DETAILED INSTRUCTIONS
echo ===============================================
echo.
echo 1. ENABLE DEVELOPER MODE:
echo    - Look for "Developer mode" toggle in top-right
echo    - Click to enable it (should turn blue/green)
echo.
echo 2. LOAD EXTENSION:
echo    - Click "Load unpacked" button (appears after enabling dev mode)
echo    - Navigate to: %INSTALL_DIR%
echo    - Click "Select Folder" or "Open"
echo.
echo 3. VERIFY INSTALLATION:
echo    - Extension should appear in the list
echo    - Look for "toFreedium" in your extensions
echo    - You can pin it to toolbar for easy access
echo.
echo 4. USAGE:
echo    - Click the extension icon in toolbar, OR
echo    - Right-click on any page/link and select "Open with Freedium"
echo.
echo ===============================================

:end
echo.
echo Press any key to exit...
pause >nul

REM Clean exit
color
title Command Prompt
exit /b 0