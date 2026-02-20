@echo off
echo ========================================
echo AGENT BROWSER TEST
echo ========================================
echo.

echo 1. Installing browser binaries...
node_modules\agent-browser\bin\agent-browser-win32-x64.exe install
echo.

echo 2. Navigating to example.com...
node_modules\agent-browser\bin\agent-browser-win32-x64.exe open example.com
echo.

echo 3. Getting page info...
node_modules\agent-browser\bin\agent-browser-win32-x64.exe get title
node_modules\agent-browser\bin\agent-browser-win32-x64.exe get url
echo.

echo 4. Taking screenshot...
node_modules\agent-browser\bin\agent-browser-win32-x64.exe screenshot test-screenshot.png
echo Screenshot saved to test-screenshot.png
echo.

echo 5. Getting page snapshot (compact)...
node_modules\agent-browser\bin\agent-browser-win32-x64.exe snapshot --compact
echo.

echo 6. Getting interactive elements only...
node_modules\agent-browser\bin\agent-browser-win32-x64.exe snapshot --interactive
echo.

echo ========================================
echo TEST COMPLETE!
echo ========================================
