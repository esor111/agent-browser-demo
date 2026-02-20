@echo off
echo ========================================
echo GITHUB AUTOMATION - WATCH IT HAPPEN!
echo ========================================
echo.
echo This will:
echo 1. Open browser window (you can see it!)
echo 2. Go to GitHub login
echo 3. Type your username
echo 4. Type your password
echo 5. Click Sign in
echo 6. Go to your repositories
echo 7. Extract first repo URL
echo.
echo Preparing browser...
taskkill /F /IM node.exe >nul 2>&1
timeout /t 2 >nul
echo.
echo Press any key to start...
pause
echo.

echo [Step 1/9] Opening GitHub login page...
.\ab --headed open https://github.com/login
timeout /t 3

echo.
echo [Step 2/9] Typing username: esor111
.\ab --headed fill "@e2" "esor111"
timeout /t 2

echo.
echo [Step 3/9] Typing password...
.\ab --headed fill "@e3" "ishwor19944"
timeout /t 2

echo.
echo [Step 4/9] Clicking Sign in button...
.\ab --headed click "@e5"
echo Waiting for login to complete...
timeout /t 6

echo.
echo [Step 5/9] Checking if logged in...
.\ab --headed get url

echo.
echo [Step 6/9] Going to your repositories page...
.\ab --headed open https://github.com/esor111?tab=repositories
timeout /t 3

echo.
echo [Step 7/9] Extracting first repository URL...
.\ab --headed eval "document.querySelector('#user-repositories-list li a').href" > first-repo-url.txt

echo.
echo [Step 8/9] First repo URL is:
type first-repo-url.txt

echo.
echo [Step 9/9] Taking final screenshot...
.\ab --headed screenshot github-automation-complete.png

echo.
echo ========================================
echo AUTOMATION COMPLETE!
echo ========================================
echo.
echo Results:
echo - First repo URL: 
type first-repo-url.txt
echo - Screenshot: github-automation-complete.png
echo.
echo Browser window is STILL OPEN.
echo You can interact with it manually if you want!
echo.
echo To close browser: .\ab close
echo.
pause
