@echo off
cls
echo.
echo ================================================
echo   GITHUB AUTOMATION - SIMPLE VERSION
echo ================================================
echo.
echo This will:
echo  - Open browser window (visible)
echo  - Login to GitHub
echo  - Get first repository URL
echo.
echo Press Ctrl+C to cancel, or
pause
cls

echo.
echo Cleaning up...
taskkill /F /IM node.exe >nul 2>&1
taskkill /F /IM chrome.exe >nul 2>&1
timeout /t 2 >nul

echo.
echo ================================================
echo   STARTING AUTOMATION
echo ================================================
echo.

echo Step 1: Opening GitHub login...
call .\ab --headed open https://github.com/login
if errorlevel 1 goto error
timeout /t 3 >nul

echo Step 2: Typing username...
call .\ab --headed fill "@e2" "esor111"
if errorlevel 1 goto error
timeout /t 2 >nul

echo Step 3: Typing password...
call .\ab --headed fill "@e3" "ishwor19944"
if errorlevel 1 goto error
timeout /t 2 >nul

echo Step 4: Clicking Sign in...
call .\ab --headed click "@e5"
if errorlevel 1 goto error
echo Waiting for login...
timeout /t 6 >nul

echo Step 5: Going to repositories...
call .\ab --headed open https://github.com/esor111?tab=repositories
if errorlevel 1 goto error
timeout /t 3 >nul

echo Step 6: Getting first repo URL...
call .\ab --headed eval "document.querySelector('#user-repositories-list li a').href" > first-repo-url.txt
if errorlevel 1 goto error

echo Step 7: Taking screenshot...
call .\ab --headed screenshot github-done.png
if errorlevel 1 goto error

echo.
echo ================================================
echo   SUCCESS!
echo ================================================
echo.
echo First repository URL:
type first-repo-url.txt
echo.
echo Screenshot saved: github-done.png
echo.
echo Browser is still open. To close: .\ab close
echo.
pause
goto end

:error
echo.
echo ================================================
echo   ERROR!
echo ================================================
echo.
echo Something went wrong. Try:
echo 1. Run: .\ab install
echo 2. Run this script again
echo.
pause

:end
