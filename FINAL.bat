@echo off
echo Cleaning up...
taskkill /F /IM node.exe >nul 2>&1
taskkill /F /IM chrome.exe >nul 2>&1
echo Waiting for clean state...
ping 127.0.0.1 -n 5 >nul

echo.
echo Starting automation...
echo.

call .\ab open https://github.com/login
ping 127.0.0.1 -n 4 >nul

call .\ab fill '@e2' 'esor111'
ping 127.0.0.1 -n 2 >nul

call .\ab fill '@e3' 'ishwor19944'
ping 127.0.0.1 -n 2 >nul

call .\ab click '@e5'
echo Waiting for login...
ping 127.0.0.1 -n 7 >nul

call .\ab open https://github.com/esor111?tab=repositories
ping 127.0.0.1 -n 4 >nul

call .\ab eval "document.querySelector('#user-repositories-list li a').href" > result.txt

call .\ab screenshot final.png

call .\ab close

echo.
echo DONE! First repo:
type result.txt
echo.
echo Screenshot: final.png
