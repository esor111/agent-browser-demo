@echo off
echo ========================================
echo GITHUB AUTOMATION
echo ========================================
echo.
echo Killing old processes...
taskkill /F /IM node.exe 2>nul
taskkill /F /IM chrome.exe 2>nul
timeout /t 2 >nul
echo.
echo Starting automation...
echo WATCH THE BROWSER WINDOW!
echo.

.\ab --headed open https://github.com/login
timeout /t 3

.\ab --headed fill "@e2" "esor111"
timeout /t 2

.\ab --headed fill "@e3" "ishwor19944"
timeout /t 2

.\ab --headed click "@e5"
timeout /t 6

.\ab --headed open https://github.com/esor111?tab=repositories
timeout /t 3

.\ab --headed eval "document.querySelector('#user-repositories-list li a').href" > first-repo-url.txt

echo.
echo ========================================
echo DONE!
echo ========================================
type first-repo-url.txt
echo.
echo Browser is still open. Run: .\ab close
pause
