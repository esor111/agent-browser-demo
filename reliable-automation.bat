@echo off
setlocal enabledelayedexpansion

echo Cleaning up all processes...
taskkill /F /IM node.exe >nul 2>&1
taskkill /F /IM chrome.exe >nul 2>&1
timeout /t 5 /nobreak >nul

echo.
echo === GitHub Automation Starting ===
echo.

REM Open browser and wait longer
echo [1/9] Opening GitHub login page...
call .\ab --headed open https://github.com/login
if errorlevel 1 (
    echo ERROR: Failed to open browser
    pause
    exit /b 1
)
timeout /t 4 /nobreak >nul

REM Get page elements with snapshot
echo [2/9] Getting page elements...
call .\ab snapshot -i >nul
timeout /t 2 /nobreak >nul

REM Fill username using ref
echo [3/9] Filling username...
call .\ab fill "@e2" "esor111"
timeout /t 2 /nobreak >nul

REM Fill password using ref
echo [4/9] Filling password...
call .\ab fill "@e3" "ishwor19944"
timeout /t 2 /nobreak >nul

REM Click sign in using ref
echo [5/9] Clicking sign in button...
call .\ab click "@e5"
echo Waiting for login to complete...
timeout /t 6 /nobreak >nul

REM Navigate to repos
echo [6/9] Navigating to repositories...
call .\ab open https://github.com/esor111?tab=repositories
timeout /t 3 /nobreak >nul

REM Get repo URL
echo [7/9] Extracting first repository URL...
call .\ab eval "document.querySelector('#user-repositories-list li a').href" > repo-url.txt 2>&1
timeout /t 2 /nobreak >nul

REM Screenshot
echo [8/9] Taking screenshot...
call .\ab screenshot automation-success.png
timeout /t 2 /nobreak >nul

REM Close
echo [9/9] Closing browser...
call .\ab close

echo.
echo === AUTOMATION COMPLETE ===
echo.
echo Results:
type repo-url.txt 2>nul
echo.
echo Screenshot saved: automation-success.png
echo.
pause
