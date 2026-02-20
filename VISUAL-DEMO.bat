@echo off
echo ========================================
echo VISUAL BROWSER DEMO
echo Watch the browser window!
echo ========================================
echo.

echo Opening browser window...
.\ab --headed open example.com
timeout /t 3

echo.
echo Clicking the "More information" link...
.\ab --headed click "link More information"
timeout /t 3

echo.
echo Going back...
.\ab --headed back
timeout /t 2

echo.
echo Taking a screenshot...
.\ab --headed screenshot visual-demo.png
timeout /t 2

echo.
echo Opening GitHub...
.\ab --headed open github.com
timeout /t 3

echo.
echo Scrolling down...
.\ab --headed scroll down 500
timeout /t 2

echo.
echo Done! Browser window will stay open.
echo Run: .\ab close
echo to close it.
