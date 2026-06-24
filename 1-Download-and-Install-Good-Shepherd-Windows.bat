@echo off
setlocal EnableExtensions
title Good Shepherd Windows Installer Download v0.3.1

echo ----------------------------------------
echo Good Shepherd Windows Installer Download v0.3.1
echo ----------------------------------------
echo.
echo Downloading and preparing the Good Shepherd Windows installer.
echo This window will close automatically when the installer folder opens.
echo.

set "DOWNLOAD_URL=https://github.com/thriveks/good-shepherd-installers/releases/download/v0.3.0-phase-3/GoodShepherd-Windows-Local-Node-Phase3.zip"
set "WORK_DIR=%USERPROFILE%\Desktop\GoodShepherd-Phase3-Installer-v0.3.1-%RANDOM%%RANDOM%"
set "ZIP_FILE=%TEMP%\GoodShepherd-Windows-Local-Node-Phase3-%RANDOM%%RANDOM%.zip"
set "ZIP_TEMP_FILE=%ZIP_FILE%.download"
set "LOG_FILE=%USERPROFILE%\Desktop\Good-Shepherd-Download-Log.txt"
set "DOWNLOAD_ATTEMPT=0"
set "MIN_ZIP_SIZE_BYTES=50000000"

(
    echo ----------------------------------------
    echo Good Shepherd Windows Installer Download v0.3.1
    echo Started: %DATE% %TIME%
    echo Download URL: %DOWNLOAD_URL%
    echo Work Folder: %WORK_DIR%
    echo Zip File: %ZIP_FILE%
    echo Minimum ZIP Size: %MIN_ZIP_SIZE_BYTES% bytes
    echo ----------------------------------------
) > "%LOG_FILE%"

echo Step 1 of 4: Creating clean installer folder...
echo Step 1 of 4: Creating clean installer folder...>> "%LOG_FILE%"

if exist "%WORK_DIR%" rmdir /s /q "%WORK_DIR%" >> "%LOG_FILE%" 2>&1
mkdir "%WORK_DIR%" >> "%LOG_FILE%" 2>&1

if errorlevel 1 (
    echo.
    echo ERROR: Could not create installer folder.
    echo ERROR: Could not create installer folder.>> "%LOG_FILE%"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Good Shepherd could not create the installer folder on the Desktop. A log file was saved on the Desktop named Good-Shepherd-Download-Log.txt.', 'Good Shepherd Installer Download', 'OK', 'Error')" >nul 2>nul
    pause
    exit /b 1
)

if exist "%ZIP_FILE%" del /f /q "%ZIP_FILE%" >> "%LOG_FILE%" 2>&1
if exist "%ZIP_TEMP_FILE%" del /f /q "%ZIP_TEMP_FILE%" >> "%LOG_FILE%" 2>&1

:DOWNLOAD_PACKAGE
set /a DOWNLOAD_ATTEMPT=%DOWNLOAD_ATTEMPT%+1

echo.
echo Step 2 of 4: Downloading installer package...
echo This may take a minute.
echo Download attempt %DOWNLOAD_ATTEMPT% of 3.
echo Step 2 of 4: Downloading installer package... attempt %DOWNLOAD_ATTEMPT% of 3>> "%LOG_FILE%"

if exist "%ZIP_FILE%" del /f /q "%ZIP_FILE%" >> "%LOG_FILE%" 2>&1
if exist "%ZIP_TEMP_FILE%" del /f /q "%ZIP_TEMP_FILE%" >> "%LOG_FILE%" 2>&1

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference = 'SilentlyContinue'; try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%ZIP_TEMP_FILE%' -UseBasicParsing -TimeoutSec 900; if (!(Test-Path -LiteralPath '%ZIP_TEMP_FILE%')) { throw 'ZIP download file was not created.' }; $size = (Get-Item -LiteralPath '%ZIP_TEMP_FILE%').Length; Write-Output ('Downloaded ZIP size: ' + $size + ' bytes'); if ($size -lt %MIN_ZIP_SIZE_BYTES%) { throw ('Downloaded ZIP is too small and is probably incomplete. Size: ' + $size) }; Add-Type -AssemblyName System.IO.Compression.FileSystem; $zip = [System.IO.Compression.ZipFile]::OpenRead('%ZIP_TEMP_FILE%'); $entryCount = $zip.Entries.Count; $hasBackend = $false; $hasNodeFolder = $false; foreach ($entry in $zip.Entries) { if ($entry.FullName -ieq 'GoodShepherd_Installer_Backend_Terminal_Free.bat') { $hasBackend = $true }; if ($entry.FullName -like 'good-shepherd-local-node/*') { $hasNodeFolder = $true } }; $zip.Dispose(); Write-Output ('ZIP validation passed. Entry count: ' + $entryCount); if (-not $hasBackend) { throw 'ZIP validation failed: backend installer file is missing.' }; if (-not $hasNodeFolder) { throw 'ZIP validation failed: good-shepherd-local-node folder is missing.' }; Move-Item -LiteralPath '%ZIP_TEMP_FILE%' -Destination '%ZIP_FILE%' -Force; exit 0 } catch { Write-Output $_.Exception.Message; try { if ($zip) { $zip.Dispose() } } catch {}; exit 1 }" >> "%LOG_FILE%" 2>&1

if errorlevel 1 (
    if %DOWNLOAD_ATTEMPT% LSS 3 (
        echo Download or ZIP validation failed. Retrying...
        echo Download or ZIP validation failed. Retrying...>> "%LOG_FILE%"
        timeout /t 5 /nobreak >nul 2>nul
        goto DOWNLOAD_PACKAGE
    )

    echo.
    echo ERROR: Download failed or the ZIP was incomplete.
    echo ERROR: Download failed or the ZIP was incomplete.>> "%LOG_FILE%"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Good Shepherd could not download a complete installer ZIP after 3 attempts. A log file was saved on the Desktop named Good-Shepherd-Download-Log.txt.', 'Good Shepherd Installer Download', 'OK', 'Error')" >nul 2>nul
    pause
    exit /b 1
)

if not exist "%ZIP_FILE%" (
    echo.
    echo ERROR: ZIP file was not available after download.
    echo ERROR: ZIP file was not available after download.>> "%LOG_FILE%"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Good Shepherd could not find the installer ZIP after download. A log file was saved on the Desktop named Good-Shepherd-Download-Log.txt.', 'Good Shepherd Installer Download', 'OK', 'Error')" >nul 2>nul
    pause
    exit /b 1
)

echo.
echo Step 3 of 4: Extracting installer package...
echo Step 3 of 4: Extracting installer package...>> "%LOG_FILE%"

powershell -NoProfile -ExecutionPolicy Bypass -Command "try { if (Test-Path -LiteralPath '%WORK_DIR%') { Remove-Item -LiteralPath '%WORK_DIR%' -Recurse -Force -ErrorAction SilentlyContinue }; New-Item -ItemType Directory -Path '%WORK_DIR%' -Force | Out-Null; Expand-Archive -LiteralPath '%ZIP_FILE%' -DestinationPath '%WORK_DIR%' -Force; exit 0 } catch { Write-Output $_.Exception.Message; exit 1 }" >> "%LOG_FILE%" 2>&1

if errorlevel 1 (
    echo.
    echo ERROR: Extraction failed.
    echo ERROR: Extraction failed.>> "%LOG_FILE%"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Good Shepherd installer extraction failed. A log file was saved on the Desktop named Good-Shepherd-Download-Log.txt.', 'Good Shepherd Installer Download', 'OK', 'Error')" >nul 2>nul
    pause
    exit /b 1
)

if not exist "%WORK_DIR%\GoodShepherd_Installer_Backend_Terminal_Free.bat" (
    echo.
    echo ERROR: Installer backend file was not found after extraction.
    echo ERROR: Installer backend file was not found after extraction.>> "%LOG_FILE%"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Good Shepherd extracted the ZIP, but the installer backend file was missing. The release package may be incorrect. A log file was saved on the Desktop named Good-Shepherd-Download-Log.txt.', 'Good Shepherd Installer Download', 'OK', 'Error')" >nul 2>nul
    explorer "%WORK_DIR%"
    pause
    exit /b 1
)

if not exist "%WORK_DIR%\good-shepherd-local-node" (
    echo.
    echo ERROR: good-shepherd-local-node folder was not found after extraction.
    echo ERROR: good-shepherd-local-node folder was not found after extraction.>> "%LOG_FILE%"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Good Shepherd extracted the ZIP, but the good-shepherd-local-node folder was missing. The release package may be incorrect. A log file was saved on the Desktop named Good-Shepherd-Download-Log.txt.', 'Good Shepherd Installer Download', 'OK', 'Error')" >nul 2>nul
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
