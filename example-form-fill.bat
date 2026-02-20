@echo off
REM Simple example: Fill a contact form
REM This demonstrates semantic locators

echo Cleaning up...
taskkill /F /IM node.exe >nul 2>&1
taskkill /F /IM chrome.exe >nul 2>&1
ping 127.0.0.1 -n 3 >nul

echo Opening form...
call .\ab open https://www.example.com/contact

ping 127.0.0.1 -n 3 >nul

echo Filling form with semantic locators...
call .\ab fill "textbox Name" "John Doe"
ping 127.0.0.1 -n 1 >nul

call .\ab fill "textbox Email" "john@example.com"
ping 127.0.0.1 -n 1 >nul

call .\ab fill "textbox Message" "This is a test message"
ping 127.0.0.1 -n 1 >nul

echo Taking screenshot before submit...
call .\ab screenshot before-submit.png

echo Clicking submit...
call .\ab click "button Submit"

ping 127.0.0.1 -n 5 >nul

echo Taking screenshot after submit...
call .\ab screenshot after-submit.png

call .\ab close

echo Done! Check the screenshots.
