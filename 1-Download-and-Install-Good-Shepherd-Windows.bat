@echo off
setlocal EnableExtensions
title Good Shepherd Windows Installer Download

echo ----------------------------------------
echo Good Shepherd Windows Installer Download
echo ----------------------------------------
echo.
echo Downloading and preparing the Good Shepherd Windows installer.
echo This window will close automatically when the installer folder opens.
echo.

set "DOWNLOAD_URL=https://github.com/thriveks/good-shepherd-installers/releases/download/v0.3.0-phase-3/GoodShepherd-Windows-Local-Node-Phase3.zip"
set "WORK_DIR=%USERPROFILE%\Desktop\GoodShepherd-Phase3-Installer"
set "ZIP_FILE=%TEMP%\GoodShepherd-Windows-Local-Node-Phase3.zip"
set "LOG_FILE=%USERPROFILE%\Desktop\Good-Shepherd-Download-Log.txt"

(
    echo ----------------------------------------
    echo Good Shepherd Windows Installer Download
    echo Started: %DATE% %TIME%
    echo Download URL: %DOWNLOAD_URL%
    echo Work Folder: %WORK_DIR%
    echo Zip File: %ZIP_FILE%
    echo ----------------------------------------
) > "%LOG_FILE%"

echo Step 1 of 4: Creating clean installer folder...
echo Step 1 of 4: Creating clean installer folder...>> "%LOG_FILE%"

if exist "%WORK_DIR%" rmdir /s /q "%WORK_DIR%" >> "%LOG_FILE%" 2>&1
mkdir "%WORK_DIR%" >> "%LOG_FILE%" 2>&1

if exist "%ZIP_FILE%" del /f /q "%ZIP_FILE%" >> "%LOG_FILE%" 2>&1

echo.
echo Step 2 of 4: Downloading installer package...
echo This may take a minute.
echo Step 2 of 4: Downloading installer package...>> "%LOG_FILE%"

powershell -NoProfile -ExecutionPolicy Bypass -Command "try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%ZIP_FILE%' -TimeoutSec 300; exit 0 } catch { Write-Output $_.Exception.Message; exit 1 }" >> "%LOG_FILE%" 2>&1

if not exist "%ZIP_FILE%" (
    echo.
    echo ERROR: Download failed.
    echo Please check the internet connection and try again.
    echo ERROR: Download failed.>> "%LOG_FILE%"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Good Shepherd installer download failed. Please check the internet connection and try again. A log file was saved on the Desktop named Good-Shepherd-Download-Log.txt.', 'Good Shepherd Installer Download', 'OK', 'Error')" >nul 2>nul
    exit /b 1
)

echo.
echo Step 3 of 4: Extracting installer package...
echo Step 3 of 4: Extracting installer package...>> "%LOG_FILE%"

powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%WORK_DIR%' -Force; exit 0 } catch { Write-Output $_.Exception.Message; exit 1 }" >> "%LOG_FILE%" 2>&1

if errorlevel 1 (
    echo.
    echo ERROR: Extraction failed.
    echo ERROR: Extraction failed.>> "%LOG_FILE%"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Good Shepherd installer extraction failed. A log file was saved on the Desktop named Good-Shepherd-Download-Log.txt.', 'Good Shepherd Installer Download', 'OK', 'Error')" >nul 2>nul
    exit /b 1
)

echo.
echo Step 4 of 4: Unblocking files and opening installer folder...
echo Step 4 of 4: Unblocking files and opening installer folder...>> "%LOG_FILE%"

powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path '%WORK_DIR%' -Recurse | Unblock-File" >> "%LOG_FILE%" 2>&1

explorer "%WORK_DIR%"

echo.
echo Installer folder opened.
echo Double-click:
echo 1 - Double Click To Install Good Shepherd
echo.
echo Installer folder opened.>> "%LOG_FILE%"

timeout /t 2 /nobreak >nul 2>nul
exit /b 0