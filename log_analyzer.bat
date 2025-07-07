@echo off
:: Windows Log Analyzer Tool (Batch Version)
:: No Python required, runs directly

setlocal enabledelayedexpansion
set LOGFILE=%1
set OUTPUT=%2

if "%LOGFILE%"=="" (
    echo Usage: %0 "C:\Windows\debug\NetSetup.LOG" [output.txt]
    exit /b 1
)

echo Windows Network Setup Log Analysis Report > "%TEMP%\log_report.tmp"
echo ================================================== >> "%TEMP%\log_report.tmp"
echo Generated: %date% %time% >> "%TEMP%\log_report.tmp"
echo. >> "%TEMP%\log_report.tmp"
echo === Basic Statistics === >> "%TEMP%\log_report.tmp"

set DOMAIN_JOINS=0
set WORKGROUP_JOINS=0
set ERRORS=0

for /f "tokens=*" %%a in ('type "%LOGFILE%"') do (
    set line=%%a
    if "!line:NetpJoinDomain=!" neq "!line!" set /a DOMAIN_JOINS+=1
    if "!line:NetpJoinWorkgroup=!" neq "!line!" set /a WORKGROUP_JOINS+=1
    
    for /f "tokens=2 delims=:" %%b in ('echo !line! ^| findstr /r "status: 0x[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]"') do (
        set status=%%b
        if "!status!" neq " 0x0" (
            set /a ERRORS+=1
            echo [Error !ERRORS!] >> "%TEMP%\log_errors.tmp"
            echo Error Code: !status! >> "%TEMP%\log_errors.tmp"
            echo Context: !line! >> "%TEMP%\log_errors.tmp"
            echo. >> "%TEMP%\log_errors.tmp"
        )
    )
)

echo Domain Join Attempts: %DOMAIN_JOINS% >> "%TEMP%\log_report.tmp"
echo Workgroup Joins: %WORKGROUP_JOINS% >> "%TEMP%\log_report.tmp"
echo Errors Found: %ERRORS% >> "%TEMP%\log_report.tmp"

if exist "%TEMP%\log_errors.tmp" (
    echo. >> "%TEMP%\log_report.tmp"
    echo === Error Details === >> "%TEMP%\log_report.tmp"
    type "%TEMP%\log_errors.tmp" >> "%TEMP%\log_report.tmp"
    del "%TEMP%\log_errors.tmp"
) else (
    echo. >> "%TEMP%\log_report.tmp"
    echo No Errors Found >> "%TEMP%\log_report.tmp"
)

if "%OUTPUT%"=="" (
    type "%TEMP%\log_report.tmp"
) else (
    copy "%TEMP%\log_report.tmp" "%OUTPUT%" >nul
    echo Report saved to: %OUTPUT%
)

del "%TEMP%\log_report.tmp"
