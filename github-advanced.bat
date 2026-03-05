@echo off
REM Advanced GitHub Automation Script
REM Supports multiple operations

SET USERNAME=esor111
SET PASSWORD=ishwor19944

:MENU
cls
echo ========================================
echo GitHub Automation Menu
echo ========================================
echo.
echo 1. Login and view all repositories
echo 2. Open specific repository
echo 3. Check repository count
echo 4. Take screenshot
echo 5. Exit
echo.
set /p choice="Enter your choice (1-5): "

IF "%choice%"=="1" GOTO LOGIN_REPOS
IF "%choice%"=="2" GOTO OPEN_REPO
IF "%choice%"=="3" GOTO COUNT_REPOS
IF "%choice%"=="4" GOTO SCREENSHOT
IF "%choice%"=="5" GOTO END

:LOGIN_REPOS
echo.
echo Logging into GitHub...
bash -c "agent-browser --headed open https://github.com/login"
timeout /t 2 /nobreak >nul
bash -c "agent-browser snapshot -i"
bash -c "agent-browser fill @e2 '%USERNAME%' && agent-browser fill @e3 '%PASSWORD%' && agent-browser click @e5"
timeout /t 3 /nobreak >nul
bash -c "agent-browser open 'https://github.com/%USERNAME%?tab=repositories'"
timeout /t 2 /nobreak >nul
bash -c "agent-browser snapshot -i"
echo.
echo Done! Press any key to return to menu...
pause >nul
GOTO MENU

:OPEN_REPO
echo.
set /p reponame="Enter repository name: "
echo Opening repository: %reponame%
bash -c "agent-browser open 'https://github.com/%USERNAME%/%reponame%'"
timeout /t 2 /nobreak >nul
bash -c "agent-browser get url"
echo.
echo Done! Press any key to return to menu...
pause >nul
GOTO MENU

:COUNT_REPOS
echo.
echo Checking repository count...
bash -c "agent-browser open 'https://github.com/%USERNAME%?tab=repositories'"
timeout /t 2 /nobreak >nul
bash -c "agent-browser snapshot -i | grep -i 'Repositories'"
echo.
echo Done! Press any key to return to menu...
pause >nul
GOTO MENU

:SCREENSHOT
echo.
set /p filename="Enter screenshot filename (without extension): "
bash -c "agent-browser screenshot %filename%.png"
echo Screenshot saved as: %filename%.png
echo.
echo Done! Press any key to return to menu...
pause >nul
GOTO MENU

:END
echo.
echo Closing browser...
bash -c "agent-browser close"
echo Goodbye!
exit
