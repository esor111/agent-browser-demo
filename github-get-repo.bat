@echo off
echo ========================================
echo GitHub: Login and Extract First Repo URL
echo ========================================
echo.

echo [1/8] Opening GitHub login...
.\ab --headed open https://github.com/login
timeout /t 3

echo [2/8] Entering username...
.\ab --headed fill "textbox Username or email address" "esor111"
timeout /t 1

echo [3/8] Entering password...
.\ab --headed fill "textbox Password" "ishwor19944"
timeout /t 1

echo [4/8] Signing in...
.\ab --headed click "button Sign in"
echo Waiting for login...
timeout /t 5

echo [5/8] Navigating to repositories...
.\ab --headed open https://github.com/esor111?tab=repositories
timeout /t 3

echo [6/8] Getting page structure...
.\ab --headed snapshot --interactive --json > repos-snapshot.json
echo Snapshot saved to repos-snapshot.json

echo [7/8] Extracting first repository URL...
.\ab --headed eval "document.querySelector('article h3 a')?.href || document.querySelector('[itemprop=\"name codeRepository\"] a')?.href" > first-repo-url.txt
type first-repo-url.txt

echo [8/8] Taking screenshot...
.\ab --headed screenshot github-logged-in.png

echo.
echo ========================================
echo SUCCESS!
echo ========================================
echo First repo URL saved to: first-repo-url.txt
echo Screenshot saved to: github-logged-in.png
echo Page structure saved to: repos-snapshot.json
echo.
echo To close browser: .\ab close
