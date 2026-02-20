@echo off
echo Cleaning up processes...
taskkill /F /IM node.exe >nul 2>&1
taskkill /F /IM chrome.exe >nul 2>&1
timeout /t 3 /nobreak >nul

echo.
echo Starting automation with Node.js directly...
echo.

node node_modules/agent-browser/dist/index.js --headed open https://github.com/login
timeout /t 5 /nobreak >nul

echo Filling username...
node node_modules/agent-browser/dist/index.js fill "@e2" "esor111"
timeout /t 3 /nobreak >nul

echo Filling password...
node node_modules/agent-browser/dist/index.js fill "@e3" "ishwor19944"
timeout /t 3 /nobreak >nul

echo Clicking sign in...
node node_modules/agent-browser/dist/index.js click "@e5"
timeout /t 8 /nobreak >nul

echo Navigating to repositories...
node node_modules/agent-browser/dist/index.js open https://github.com/esor111?tab=repositories
timeout /t 5 /nobreak >nul

echo Extracting first repo URL...
node node_modules/agent-browser/dist/index.js eval "document.querySelector('#user-repositories-list li a').href"
timeout /t 2 /nobreak >nul

echo Taking screenshot...
node node_modules/agent-browser/dist/index.js screenshot final-working.png
timeout /t 2 /nobreak >nul

echo.
echo ===== COMPLETE =====
echo Screenshot: final-working.png
echo.
pause

echo Closing browser...
node node_modules/agent-browser/dist/index.js close
