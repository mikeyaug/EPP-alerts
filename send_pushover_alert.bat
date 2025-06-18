@echo off
setlocal

:: --- Configuration Variables ---
set "PUSHOVER_API_TOKEN=ankqnbni7ba839ohmv3xia376r8mji"
set "PUSHOVER_USER_KEY=u1rf152q6czys8fkoozrsehkobzs51"
set "MESSAGE_FILE_PATH=C:\Program Files\WxMesgNet\WxMesg-to-Pushover\alert.txt"
set "LOG_DIR=C:\Program Files\WxMesgNet\"

:: --- Get Today's Date for Log File (YYYY-MM-DD format) ---
:: This method is more robust across different regional date formats than parsing %date% directly.
for /f "tokens=1-4 delims=, " %%a in ('wmic path win32_localtime get day^,month^,year /value') do (
    for /f "tokens=1 delims==" %%i in ("%%a") do set "Day=00%%j"
    for /f "tokens=1 delims==" %%i in ("%%b") do set "Month=00%%j"
    for /f "tokens=1 delims==" %%i in ("%%c") do set "Year=%%j"
)
set "CURRENT_DATE=%Year%-%Month:~-2%-%Day:~-2%"

:: --- Define Log File Path ---
set "LOG_FILE=%LOG_DIR%DebugPushover_%CURRENT_DATE%.txt"

:: --- Start Logging ---
echo ===================================================================== >> "%LOG_FILE%"
echo Pushover Notification Script - %DATE% %TIME% >> "%LOG_FILE%"
echo --------------------------------------------------------------------- >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"
echo Configuration: >> "%LOG_FILE%"
echo   API Token: %PUSHOVER_API_TOKEN% >> "%LOG_FILE%"
echo   User Key: %PUSHOVER_USER_KEY% >> "%LOG_FILE%"
echo   Message File: "%MESSAGE_FILE_PATH%" >> "%LOG_FILE%"
echo   Log File: "%LOG_FILE%" >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

:: --- Check if Message File Exists ---
if not exist "%MESSAGE_FILE_PATH%" (
    echo ERROR: Message file not found: "%MESSAGE_FILE_PATH%" >> "%LOG_FILE%"
    echo. >> "%LOG_FILE%"
    echo Script finished with error. >> "%LOG_FILE%"
    echo ===================================================================== >> "%LOG_FILE%"
    endlocal
    exit /b 1
) else (
    echo Message file found. >> "%LOG_FILE%"
)
echo. >> "%LOG_FILE%"

:: --- Execute the cURL Command and Redirect All Output to Log File ---
:: The 2>&1 redirects standard error to standard output, and >> "%LOG_FILE%" appends both.
:: Note: Double backslashes in the message file path within the --form-string parameter
:: are used to ensure curl correctly interprets the path, especially with spaces.
echo Executing cURL command... >> "%LOG_FILE%"
curl -s ^
  --form-string "token=%PUSHOVER_API_TOKEN%" ^
  --form-string "user=%PUSHOVER_USER_KEY%" ^
  --form-string "message=<\"%MESSAGE_FILE_PATH%\"" ^
  https://api.pushover.net/1/messages.json >> "%LOG_FILE%" 2>&1

:: --- Log Command Result ---
set "CURL_EXIT_CODE=%ERRORLEVEL%"
echo. >> "%LOG_FILE%"
echo --------------------------------------------------------------------- >> "%LOG_FILE%"
if %CURL_EXIT_CODE% equ 0 (
    echo Pushover notification sent successfully. (cURL Exit Code: %CURL_EXIT_CODE%) >> "%LOG_FILE%"
) else (
    echo FAILED to send Pushover notification. (cURL Exit Code: %CURL_EXIT_CODE%) >> "%LOG_FILE%"
    echo Please check the log above for cURL output and errors. >> "%LOG_FILE%"
)
echo Script finished. >> "%LOG_FILE%"
echo ===================================================================== >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

endlocal
exit /b %CURL_EXIT_CODE%