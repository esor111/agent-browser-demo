@echo off
echo ========================================
echo GitHub: Login and Get First Repo
echo ========================================
echo.

echo [1/10] Opening GitHub login...
.\ab open https://github.com/login
timeout /t 2

echo [2/10] Getting login form structure...
.\ab snapshot --interactive --compact

echo [3/10] Filling username...
.\ab fill "@e2" "esor111"
timeout /t 1

echo [4/10] Filling password...
.\ab fill "@e3" "ishwor19944"
timeout /t 1

echo [5/10] Clicking Sign in...
.\ab click "@e5"
echo Waiting for login...
timeout /t 5

echo [6/10] Verifying login...
.\ab get url

echo [7/10] Going to repositories...
.\ab open https://github.com/esor111?tab=repositories
timeout /t 3

echo [8/10] Getting first repository URL...
.\ab eval "document.querySelector('#user-repositories-list li a').href"

echo [9/10] Saving URL to file...
.\ab eval "document.querySelector('#user-repositories-list li a').href" > first-repo.txt
type first-repo.txt

echo [10/10] Taking screenshot...
.\ab screenshot github-repos-logged-in.png

echo.
echo ========================================
echo SUCCESS!
echo ========================================
echo First repo URL saved to: first-repo.txt
echo Screenshot saved to: github-repos-logged-in.png
echo.
echo To close browser: .\ab close
