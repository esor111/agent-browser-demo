@echo off
echo Step 1: Opening GitHub login (visible browser)...
call .\ab --headed open https://github.com/login
timeout /t 3 /nobreak >nul

echo Step 2: Filling username...
call .\ab fill '@e2' 'esor111'
timeout /t 2 /nobreak >nul

echo Step 3: Filling password...
call .\ab fill '@e3' 'ishwor19944'
timeout /t 2 /nobreak >nul

echo Step 4: Clicking sign in...
call .\ab click '@e5'
timeout /t 6 /nobreak >nul

echo Step 5: Going to repositories...
call .\ab open https://github.com/esor111?tab=repositories
timeout /t 3 /nobreak >nul

echo Step 6: Getting first repo URL...
call .\ab eval "document.querySelector('#user-repositories-list li a').href"

echo Step 7: Taking screenshot...
call .\ab screenshot test-result.png

echo.
echo Done! Check test-result.png
pause
