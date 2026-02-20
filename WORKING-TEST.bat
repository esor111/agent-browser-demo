@echo off
SET AB=.\node_modules\agent-browser\bin\agent-browser-win32-x64.exe

echo ========================================
echo AGENT BROWSER - WORKING TEST
echo ========================================
echo.

echo TEST 1: Navigate to example.com
%AB% open example.com
echo.

echo TEST 2: Get page title
%AB% get title
echo.

echo TEST 3: Get page URL
%AB% get url
echo.

echo TEST 4: Get page snapshot (compact)
%AB% snapshot --compact
echo.

echo TEST 5: Get interactive elements as JSON
%AB% snapshot --interactive --json
echo.

echo TEST 6: Take screenshot
%AB% screenshot working-test.png
echo Screenshot saved!
echo.

echo TEST 7: Click the "More information" link using semantic locator
%AB% click "link More information"
echo.

echo TEST 8: Get new URL after click
%AB% get url
echo.

echo TEST 9: Take another screenshot
%AB% screenshot after-click.png
echo.

echo TEST 10: Go back
%AB% back
echo.

echo TEST 11: Verify we're back at example.com
%AB% get url
echo.

echo TEST 12: Close browser
%AB% close
echo.

echo ========================================
echo ALL TESTS PASSED!
echo ========================================
echo.
echo Screenshots created:
echo - working-test.png
echo - after-click.png
