@echo off
echo Killing processes...
taskkill /F /IM node.exe >nul 2>&1
taskkill /F /IM chrome.exe >nul 2>&1
ping 127.0.0.1 -n 3 >nul

echo [1/9] Opening GitHub...
.\ab open https://github.com/login || goto error

echo [2/9] Filling username...
.\ab fill '@e2' 'esor111' || goto error

echo [3/9] Filling password...
.\ab fill '@e3' 'ishwor19944' || goto error

echo [4/9] Clicking Sign in...
.\ab click '@e5' || goto error
ping 127.0.0.1 -n 6 >nul

echo [5/9] Checking URL...
.\ab get url || goto error

echo [6/9] Going to repos...
.\ab open https://github.com/esor111?tab=repositories || goto error
ping 127.0.0.1 -n 3 >nul

echo [7/9] Getting first repo URL...
.\ab eval "document.querySelector('#user-repositories-list li a').href" > first-repo-url.txt || goto error

echo [8/9] Screenshot...
.\ab screenshot done.png || goto error

echo [9/9] Closing...
.\ab close || goto error

echo.
echo SUCCESS!
type first-repo-url.txt
goto end

:error
echo ERROR at step!
exit /b 1

:end
