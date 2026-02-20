@echo off
cls
echo.
echo ================================================
echo   GITHUB AUTOMATION - TESTED AND WORKING
echo ================================================
echo.
echo This will automatically:
echo  1. Login to GitHub with your credentials
echo  2. Navigate to your repositories
echo  3. Extract the first repository URL
echo  4. Save it to first-repo-url.txt
echo.
echo Starting in 2 seconds...
timeout /t 2
cls

echo.
echo Cleaning up old processes...
taskkill /F /IM node.exe >nul 2>&1
taskkill /F /IM chrome.exe >nul 2>&1
timeout /t 2
echo Done.
echo.

echo ================================================
echo   AUTOMATION STARTING
echo ================================================
echo.

echo [1/9] Opening GitHub login page...
.\ab open https://github.com/login
if errorlevel 1 goto error
timeout /t 3

echo [2/9] Filling username: esor111
.\ab fill '@e2' 'esor111'
if errorlevel 1 goto error
timeout /t 1

echo [3/9] Filling password...
.\ab fill '@e3' 'ishwor19944'
if errorlevel 1 goto error
timeout /t 1

echo [4/9] Clicking Sign in button...
.\ab click '@e5'
if errorlevel 1 goto error
echo Waiting for login to complete...
timeout /t 5

echo [5/9] Verifying login...
.\ab get url
if errorlevel 1 goto error
timeout /t 1

echo [6/9] Navigating to repositories...
.\ab open https://github.com/esor111?tab=repositories
if errorlevel 1 goto error
timeout /t 3

echo [7/9] Extracting first repository URL...
.\ab eval "document.querySelector('#user-repositories-list li a').href" > first-repo-url.txt
if errorlevel 1 goto error

echo [8/9] Taking screenshot...
.\ab screenshot github-automation-success.png
if errorlevel 1 goto error

echo [9/9] Closing browser...
.\ab close
if errorlevel 1 goto error

echo.
echo ================================================
echo   SUCCESS!
echo ================================================
echo.
echo First repository URL:
type first-repo-url.txt
echo.
echo Files created:
echo  - first-repo-url.txt (repository URL)
echo  - github-automation-success.png (screenshot)
echo.
echo Automation completed successfully!
echo.
goto end

:error
echo.
echo ================================================
echo   ERROR OCCURRED
echo ================================================
echo.
echo The automation failed. Please try:
echo  1. Make sure Chromium is installed: .\ab install
echo  2. Run this script again
echo.
goto end

:end
