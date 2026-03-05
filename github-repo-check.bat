@echo off
REM GitHub Repository Checker - Automated Script
REM Usage: github-repo-check.bat [username] [password]

SET USERNAME=%1
SET PASSWORD=%2

IF "%USERNAME%"=="" SET USERNAME=esor111
IF "%PASSWORD%"=="" SET PASSWORD=ishwor19944

echo ========================================
echo GitHub Repository Automation
echo ========================================
echo.
echo Logging in as: %USERNAME%
echo.

REM Login to GitHub
bash -c "agent-browser --headed open https://github.com/login"
timeout /t 2 /nobreak >nul

bash -c "agent-browser snapshot -i"
bash -c "agent-browser fill @e2 '%USERNAME%' && agent-browser fill @e3 '%PASSWORD%' && agent-browser click @e5"
timeout /t 3 /nobreak >nul

REM Navigate to repositories
bash -c "agent-browser open 'https://github.com/%USERNAME%?tab=repositories'"
timeout /t 2 /nobreak >nul

REM Take snapshot of repositories
bash -c "agent-browser snapshot -i > repos-snapshot.txt"

REM Get current URL
bash -c "agent-browser get url > current-repo.txt"

REM Take screenshot
bash -c "agent-browser screenshot repos-screenshot.png"

echo.
echo ========================================
echo Automation Complete!
echo ========================================
echo.
echo Results saved:
echo - repos-snapshot.txt (list of repositories)
echo - current-repo.txt (current repository URL)
echo - repos-screenshot.png (screenshot)
echo.

REM Display results
type repos-snapshot.txt
echo.
echo Current working repo:
type current-repo.txt

pause
