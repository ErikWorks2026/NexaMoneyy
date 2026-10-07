@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title NexaMoney - BUILD SETUP EXE

echo ==========================================
echo    NEXAMONEY - BUILD INSTALLER EXE
echo ==========================================
echo.
echo Requires .NET 8 SDK and IExpress.
echo.
pause

where dotnet >nul 2>&1 || (echo .NET 8 SDK not found.&pause&exit /b 1)
where iexpress.exe >nul 2>&1 || (echo IExpress not found.&pause&exit /b 1)

call "%~dp0BUILD_NexaMoney.bat"
if errorlevel 1 exit /b 1

set "PUB=%~dp0NexaMoney\bin\Release\net8.0-windows\win-x64\publish"
set "STAGE=%TEMP%\NexaMoneySetupStage"
if exist "%STAGE%" rmdir /s /q "%STAGE%"
mkdir "%STAGE%"
copy /Y "%PUB%\NexaMoney.exe" "%STAGE%\NexaMoney.exe" >nul

> "%STAGE%\install.cmd" echo @echo off
>>"%STAGE%\install.cmd" echo setlocal EnableExtensions
>>"%STAGE%\install.cmd" echo set "APPDIR=%%LOCALAPPDATA%%\Programs\NexaMoney"
>>"%STAGE%\install.cmd" echo if not exist "%%APPDIR%%" mkdir "%%APPDIR%%"
>>"%STAGE%\install.cmd" echo taskkill /F /IM NexaMoney.exe ^>nul 2^>^&1
>>"%STAGE%\install.cmd" echo copy /Y "%%~dp0NexaMoney.exe" "%%APPDIR%%\NexaMoney.exe" ^>nul
>>"%STAGE%\install.cmd" echo if errorlevel 1 exit /b 1
>>"%STAGE%\install.cmd" echo powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$d=[Environment]::GetFolderPath('Desktop');$w=New-Object -ComObject WScript.Shell;$p=Join-Path $d 'NexaMoney.lnk';$s=$w.CreateShortcut($p);$s.TargetPath='%%APPDIR%%\NexaMoney.exe';$s.WorkingDirectory='%%APPDIR%%';$s.Description='NexaMoney - Personal Finance Manager';$s.IconLocation='%%APPDIR%%\NexaMoney.exe,0';$s.Save()"
>>"%STAGE%\install.cmd" echo start "" "%%APPDIR%%\NexaMoney.exe"
>>"%STAGE%\install.cmd" echo exit /b 0

set "SED=%STAGE%\NexaMoneySetup.sed"
(
echo [Version]
echo Class=IEXPRESS
echo SEDVersion=3
echo.
echo [Options]
echo PackagePurpose=InstallApp
echo ShowInstallProgramWindow=1
echo HideExtractAnimation=1
echo UseLongFileName=1
echo InsideCompressed=0
echo RebootMode=N
echo TargetName=%~dp0NexaMoneySetup.exe
echo FriendlyName=NexaMoney Setup
echo AppLaunched=install.cmd
echo PostInstallCmd=^<None^>
echo SourceFiles=SourceFiles
echo.
echo [Strings]
echo FILE0=NexaMoney.exe
echo FILE1=install.cmd
echo.
echo [SourceFiles]
echo SourceFiles0=%STAGE%
echo.
echo [SourceFiles0]
echo %%FILE0%%=
echo %%FILE1%%=
) > "%SED%"

iexpress.exe /N /Q "%SED%"
if not exist "%~dp0NexaMoneySetup.exe" (
    echo.
    echo BUILD SETUP FAILED.
    pause
    exit /b 1
)

echo.
echo CREATED:
echo %~dp0NexaMoneySetup.exe
pause
exit /b 0
