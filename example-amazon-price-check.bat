@echo off
REM Simple example: Check Amazon product price
REM This demonstrates snapshot-driven development

echo Cleaning up...
taskkill /F /IM node.exe >nul 2>&1
taskkill /F /IM chrome.exe >nul 2>&1
ping 127.0.0.1 -n 3 >nul

echo Opening Amazon...
call .\ab open https://www.amazon.com

ping 127.0.0.1 -n 3 >nul

echo Searching for product...
call .\ab fill "textbox Search" "laptop"
call .\ab press Enter

ping 127.0.0.1 -n 5 >nul

echo Getting page structure...
call .\ab snapshot --interactive --json > search-results.json

echo Taking screenshot...
call .\ab screenshot amazon-search.png

echo Getting first product price...
call .\ab eval "document.querySelector('.a-price-whole')?.textContent" > price.txt

call .\ab close

echo Done!
echo Price found:
type price.txt
