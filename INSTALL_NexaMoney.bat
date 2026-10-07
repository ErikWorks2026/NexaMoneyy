@echo off
setlocal EnableExtensions
cd /d "%~dp0NexaMoney"
title NexaMoney - Cista instalace

echo ==========================================
echo       NEXAMONEY - CISTA INSTALACE
echo ==========================================
echo.
echo 1 - CISTA INSTALACE - smazat lokalni data
echo 2 - PREINSTALOVAT - ponechat data
echo.
choice /C 12 /N /M "Vyber [1/2]: "
if errorlevel 2 goto KEEP
if errorlevel 1 goto CLEAN
exit /b 1

:CLEAN
echo.
echo Mazani lokalnich dat NexaMoney...
if exist "%LOCALAPPDATA%\NexaMoney" rmdir /s /q "%LOCALAPPDATA%\NexaMoney"

:KEEP
taskkill /F /IM NexaMoney.exe >nul 2>&1
if exist "bin" rmdir /s /q "bin"
if exist "obj" rmdir /s /q "obj"

where dotnet >nul 2>&1
if errorlevel 1 (
  echo.
  echo CHYBA: .NET 8 SDK nebylo nalezeno.
  pause
  exit /b 1
)

echo.
echo [1/4] Obnovuji projekt...
dotnet restore "NexaMoney.csproj" || goto FAIL

echo.
echo [2/4] Vytvarim samostatnou Windows x64 aplikaci...
dotnet publish "NexaMoney.csproj" -c Release -r win-x64 --self-contained true || goto FAIL

set "PUB=bin\Release\net8.0-windows\win-x64\publish\NexaMoney.exe"
if not exist "%PUB%" goto FAIL

set "APPDIR=%LOCALAPPDATA%\Programs\NexaMoney"
if not exist "%APPDIR%" mkdir "%APPDIR%"

echo.
echo [3/4] Instaluji...
copy /Y "%PUB%" "%APPDIR%\NexaMoney.exe" >nul || goto FAIL

echo.
echo [4/4] Vytvarim zastupce...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$d=[Environment]::GetFolderPath('Desktop');$w=New-Object -ComObject WScript.Shell;$p=Join-Path $d 'NexaMoney.lnk';$s=$w.CreateShortcut($p);$s.TargetPath='%APPDIR%\NexaMoney.exe';$s.WorkingDirectory='%APPDIR%';$s.Description='NexaMoney - Osobni finance';$s.IconLocation='%APPDIR%\NexaMoney.exe,0';$s.Save()"

echo.
echo ==========================================
echo        INSTALACE DOKONCENA
echo ==========================================
echo.
start "" "%APPDIR%\NexaMoney.exe"
pause
exit /b 0

:FAIL
echo.
echo INSTALACE SELHALA. Zkontroluj chybu vyse.
pause
exit /b 1
