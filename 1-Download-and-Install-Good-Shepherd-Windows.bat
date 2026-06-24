@echo off
setlocal EnableExtensions
cls
title Good Shepherd Windows Installer Download v0.3.1

echo ------------------------------------------------------------
echo Good Shepherd Windows Installer Download v0.3.1
echo ------------------------------------------------------------
echo.
echo Downloading and preparing the Good Shepherd Windows installer.
echo This may take several minutes depending on the internet connection.
echo.

set "DOWNLOAD_URL=https://github.com/thriveks/good-shepherd-installers/releases/download/v0.3.0-phase-3/GoodShepherd-Windows-Local-Node-Phase3.zip"
set "WORK_DIR=%USERPROFILE%\Desktop\GoodShepherd-Phase3-Installer-v0.3.1-%RANDOM%%RANDOM%"
set "ZIP_FILE=%TEMP%\GoodShepherd-Windows-Local-Node-Phase3.zip"
set "ZIP_TEMP_FILE=%TEMP%\GoodShepherd-Windows-Local-Node-Phase3.download"
set "LOG_FILE=%USERPROFILE%\Desktop\Good-Shepherd-Download-Log.txt"
set "MIN_ZIP_SIZE_BYTES=50000000"

(
    echo ------------------------------------------------------------
    echo Good Shepherd Windows Installer Download v0.3.1
    echo Started: %DATE% %TIME%
    echo Download URL: %DOWNLOAD_URL%
    echo Work Folder: %WORK_DIR%
    echo Zip File: %ZIP_FILE%
    echo Minimum ZIP Size: %MIN_ZIP_SIZE_BYTES% bytes
    echo ------------------------------------------------------------
) > "%LOG_FILE%"

echo Step 1 of 4: Creating clean installer folder...
echo Step 1 of 4: Creating clean installer folder...>> "%LOG_FILE%"

if exist "%WORK_DIR%" rmdir /s /q "%WORK_DIR%" >> "%LOG_FILE%" 2>&1
mkdir "%WORK_DIR%" >> "%LOG_FILE%" 2>&1

if errorlevel 1 (
    echo ERROR: Could not create installer folder.
    echo ERROR: Could not create installer folder.>> "%LOG_FILE%"
    pause
    exit /b 1
)

if exist "%ZIP_FILE%" del /f /q "%ZIP_FILE%" >> "%LOG_FILE%" 2>&1
if exist "%ZIP_TEMP_FILE%" del /f /q "%ZIP_TEMP_FILE%" >> "%LOG_FILE%" 2>&1

echo.
echo Step 2 of 4: Downloading installer package...
echo This is about 70 MB. Please wait.
echo Step 2 of 4: Downloading installer package...>> "%LOG_FILE%"

echo Using curl download engine...
echo Using curl download engine...>> "%LOG_FILE%"

curl.exe -L --fail --retry 8 --retry-delay 5 --connect-timeout 30 --max-time 1200 ^
  -o "%ZIP_TEMP_FILE%" ^
  "%DOWNLOAD_URL%" >> "%LOG_FILE%" 2>&1

if errorlevel 1 (
    echo.
    echo curl download failed. Trying PowerShell fallback...
    echo curl download failed. Trying PowerShell fallback...>> "%LOG_FILE%"

    if exist "%ZIP_TEMP_FILE%" del /f /q "%ZIP_TEMP_FILE%" >> "%LOG_FILE%" 2>&1

    powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference = 'SilentlyContinue'; try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%ZIP_TEMP_FILE%' -UseBasicParsing -TimeoutSec 1200; exit 0 } catch { Write-Output $_.Exception.Message; exit 1 }" >> "%LOG_FILE%" 2>&1
)

if not exist "%ZIP_TEMP_FILE%" (
    echo.
    echo ERROR: Download failed. ZIP file was not created.
    echo ERROR: Download failed. ZIP file was not created.>> "%LOG_FILE%"
    pause
    exit /b 1
)

for %%A in ("%ZIP_TEMP_FILE%") do set "ZIP_SIZE=%%~zA"

echo Downloaded ZIP size: %ZIP_SIZE% bytes
echo Downloaded ZIP size: %ZIP_SIZE% bytes>> "%LOG_FILE%"

powershell -NoProfile -ExecutionPolicy Bypass -Command "if ([int64]'%ZIP_SIZE%' -lt [int64]'%MIN_ZIP_SIZE_BYTES%') { exit 1 } else { exit 0 }" >> "%LOG_FILE%" 2>&1

if errorlevel 1 (
    echo.
    echo ERROR: Download failed or ZIP was incomplete.
    echo The downloaded file is too small.
    echo ERROR: Download failed or ZIP was incomplete. Size: %ZIP_SIZE% bytes>> "%LOG_FILE%"
    pause
    exit /b 1
)

echo.
echo Validating downloaded ZIP...
echo Validating downloaded ZIP...>> "%LOG_FILE%"

powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Add-Type -AssemblyName System.IO.Compression.FileSystem; $zip = [System.IO.Compression.ZipFile]::OpenRead('%ZIP_TEMP_FILE%'); $entryCount = $zip.Entries.Count; $hasBackend = $false; $hasNodeFolder = $false; foreach ($entry in $zip.Entries) { if ($entry.FullName -ieq 'GoodShepherd_Installer_Backend_Terminal_Free.bat') { $hasBackend = $true }; if ($entry.FullName -like 'good-shepherd-local-node/*') { $hasNodeFolder = $true } }; $zip.Dispose(); Write-Output ('ZIP validation passed. Entry count: ' + $entryCount); if (-not $hasBackend) { throw 'Backend installer file missing.' }; if (-not $hasNodeFolder) { throw 'Local node folder missing.' }; exit 0 } catch { Write-Output $_.Exception.Message; exit 1 }" >> "%LOG_FILE%" 2>&1

if errorlevel 1 (
    echo.
    echo ERROR: Downloaded ZIP failed validation.
    echo ERROR: Downloaded ZIP failed validation.>> "%LOG_FILE%"
    pause
    exit /b 1
)

move /Y "%ZIP_TEMP_FILE%" "%ZIP_FILE%" >> "%LOG_FILE%" 2>&1

echo.
echo Step 3 of 4: Extracting installer package...
echo Step 3 of 4: Extracting installer package...>> "%LOG_FILE%"

powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Expand-Archive -LiteralPath '%ZIP_FILE%' -DestinationPath '%WORK_DIR%' -Force; exit 0 } catch { Write-Output $_.Exception.Message; exit 1 }" >> "%LOG_FILE%" 2>&1

if errorlevel 1 (
    echo.
    echo ERROR: Extraction failed.
    echo ERROR: Extraction failed.>> "%LOG_FILE%"
    pause
    exit /b 1
)

if not exist "%WORK_DIR%\GoodShepherd_Installer_Backend_Terminal_Free.bat" (
    echo.
    echo ERROR: Installer backend file was not found after extraction.
    echo ERROR: Installer backend file was not found after extraction.>> "%LOG_FILE%"
    explorer "%WORK_DIR%"
    pause
    exit /b 1
)

if not exist "%WORK_DIR%\good-shepherd-local-node" (
    echo.
    echo ERROR: good-shepherd-local-node folder was not found after extraction.
    echo ERROR: good-shepherd-local-node folder was not found after extraction.>> "%LOG_FILE%"
    explorer "%WORK_DIR%"
    pause
    exit /b 1
)

echo.
echo Step 4 of 4: Unblocking files and opening installer folder...
echo Step 4 of 4: Unblocking files and opening installer folder...>> "%LOG_FILE%"

powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path '%WORK_DIR%' -Recurse -ErrorAction SilentlyContinue | Unblock-File" >> "%LOG_FILE%" 2>&1

explorer "%WORK_DIR%"

echo.
echo Installer folder opened.
echo Double-click:
echo 1 - Double Click To Install Good Shepherd
echo.
echo Installer folder opened.>> "%LOG_FILE%"

timeout /t 2 /nobreak >nul 2>nul
exit /b 0
