@echo off
taskkill /F /IM node.exe >nul 2>&1
taskkill /F /IM chrome.exe >nul 2>&1
ping 127.0.0.1 -n 3 >nul

echo [1/9] Opening GitHub...
call .\ab open https://github.com/login
ping 127.0.0.1 -n 3 >nul

echo [2/9] Filling username...
call .\ab fill '@e2' 'esor111'
ping 127.0.0.1 -n 2 >nul

echo [3/9] Filling password...
call .\ab fill '@e3' 'ishwor19944'
ping 127.0.0.1 -n 2 >nul

echo [4/9] Clicking Sign in...
call .\ab click '@e5'
ping 127.0.0.1 -n 6 >nul

echo [5/9] Checking URL...
call .\ab get url
ping 127.0.0.1 -n 2 >nul

echo [6/9] Going to repos...
call .\ab open https://github.com/esor111?tab=repositories
ping 127.0.0.1 -n 3 >nul

echo [7/9] Getting first repo URL...
call .\ab eval "document.querySelector('#user-repositories-list li a').href" > first-repo-url.txt

echo [8/9] Screenshot...
call .\ab screenshot done.png

echo [9/9] Closing...
call .\ab close

echo.
echo SUCCESS! First repo:
type first-repo-url.txt
