@echo off
echo ========================================
echo GitHub: VISUAL Browser Demo
echo WATCH THE BROWSER WINDOW!
echo ========================================
echo.

echo [1/10] Opening GitHub login page...
.\ab --headed open https://github.com/login
timeout /t 3

echo [2/10] Getting login form structure...
.\ab --headed snapshot --interactive --compact

echo [3/10] Filling username...
.\ab --headed fill "@e2" "esor111"
timeout /t 2

echo [4/10] Filling password...
.\ab --headed fill "@e3" "ishwor19944"
timeout /t 2

echo [5/10] Clicking Sign in button...
.\ab --headed click "@e5"
echo Waiting for login...
timeout /t 6

echo [6/10] Verifying login...
.\ab --headed get url

echo [7/10] Going to your repositories...
.\ab --headed open https://github.com/esor111?tab=repositories
timeout /t 4

echo [8/10] Getting first repository URL...
.\ab --headed eval "document.querySelector('#user-repositories-list li a').href"

echo [9/10] Saving URL to file...
.\ab --headed eval "document.querySelector('#user-repositories-list li a').href" > first-repo.txt
type first-repo.txt

echo [10/10] Taking screenshot...
.\ab --headed screenshot github-visual-demo.png

echo.
echo ========================================
echo SUCCESS!
echo ========================================
echo First repo URL saved to: first-repo.txt
echo Screenshot saved to: github-visual-demo.png
echo.
echo Browser window is STILL OPEN so you can see it!
echo.
echo To close: .\ab close
