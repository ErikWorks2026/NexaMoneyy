@echo off
setlocal EnableExtensions
cd /d "%~dp0NexaMoney"
title NexaMoney - Build
where dotnet >nul 2>&1 || (echo .NET 8 SDK nebylo nalezeno.&pause&exit /b 1)
if exist "bin" rmdir /s /q "bin"
if exist "obj" rmdir /s /q "obj"
dotnet restore "NexaMoney.csproj" || goto FAIL
dotnet publish "NexaMoney.csproj" -c Release -r win-x64 --self-contained true || goto FAIL
set "EXE=bin\Release\net8.0-windows\win-x64\publish\NexaMoney.exe"
if not exist "%EXE%" goto FAIL
echo.
echo BUILD OK:
echo %EXE%
pause
exit /b 0
:FAIL
echo.
echo BUILD SELHAL.
pause
exit /b 1
