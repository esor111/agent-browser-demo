@echo off
REM Simple example: Test with multiple users simultaneously
REM This demonstrates session isolation

echo Cleaning up...
taskkill /F /IM node.exe >nul 2>&1
taskkill /F /IM chrome.exe >nul 2>&1
ping 127.0.0.1 -n 3 >nul

echo Testing with User 1...
start /B cmd /c ".\ab --session user1 open https://www.example.com && .\ab --session user1 screenshot user1.png"

echo Testing with User 2...
start /B cmd /c ".\ab --session user2 open https://www.google.com && .\ab --session user2 screenshot user2.png"

echo Both sessions running in parallel...
echo Wait 10 seconds for completion...
ping 127.0.0.1 -n 10 >nul

echo Done! Check user1.png and user2.png
