@echo off
echo Killing old processes...
taskkill /F /IM node.exe >nul 2>&1
taskkill /F /IM chrome.exe >nul 2>&1
timeout /t 3 /nobreak >nul

echo Opening browser (visible mode)...
call .\ab --headed open https://github.com/login
timeout /t 8 /nobreak >nul

echo Filling username...
call .\ab fill '@e2' 'esor111'
timeout /t 4 /nobreak >nul

echo Filling password...
call .\ab fill '@e3' 'ishwor19944'
timeout /t 3 /nobreak >nul

echo Clicking sign in...
call .\ab click '@e5'
timeout /t 8 /nobreak >nul

echo Navigating to repositories...
call .\ab open https://github.com/esor111?tab=repositories
timeout /t 5 /nobreak >nul

echo Getting first repo URL...
call .\ab eval "document.querySelector('#user-repositories-list li a').href"
timeout /t 2 /nobreak >nul

echo Taking screenshot...
call .\ab screenshot github-result.png
timeout /t 2 /nobreak >nul

echo.
echo ===== AUTOMATION COMPLETE =====
echo Screenshot saved: github-result.png
echo.
pause

echo Closing browser...
call .\ab close
