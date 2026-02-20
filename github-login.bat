@echo off
echo ========================================
echo GitHub Login and Get First Repo
echo ========================================
echo.

echo Step 1: Opening GitHub login page...
.\ab --headed open https://github.com/login
timeout /t 3

echo.
echo Step 2: Filling username...
.\ab --headed fill "textbox Username or email address" "esor111"
timeout /t 1

echo.
echo Step 3: Filling password...
.\ab --headed fill "textbox Password" "ishwor19944"
timeout /t 1

echo.
echo Step 4: Clicking Sign in button...
.\ab --headed click "button Sign in"
timeout /t 5

echo.
echo Step 5: Waiting for login to complete...
.\ab --headed wait 3000

echo.
echo Step 6: Getting current URL to verify login...
.\ab --headed get url

echo.
echo Step 7: Going to your repositories...
.\ab --headed open https://github.com/esor111?tab=repositories
timeout /t 3

echo.
echo Step 8: Getting page snapshot to find first repo...
.\ab --headed snapshot --interactive --compact

echo.
echo Step 9: Getting first repository link...
.\ab --headed get attr "article h3 a" href

echo.
echo Step 10: Taking screenshot...
.\ab --headed screenshot github-repos.png

echo.
echo ========================================
echo Done! Check the output above for the first repo URL.
echo Screenshot saved to: github-repos.png
echo ========================================
echo.
echo Browser window is still open. Run: .\ab close
