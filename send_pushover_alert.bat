@echo off
setlocal

:: --- Configuration Variables ---
set "PUSHOVER_API_TOKEN=ankqnbni7ba839ohmv3xia376r8mji"
set "PUSHOVER_USER_KEY=u1rf152q6czys8fkoozrsehkobzs51"
set "MESSAGE_FILE_PATH=C:\Program Files\WxMesgNet\WxMesg-to-Pushover\alert.txt"
set "LOG_DIR=C:\Program Files\WxMesgNet\"

:: --- Ensure Log Directory Exists ---
:: This will create the directory if it doesn't exist.
:: It's crucial for the log file to be written correctly.
if not exist "%LOG_DIR%" (
    echo INFO: Creating log directory "%LOG_DIR%"
    mkdir "%LOG_DIR%"
    if not exist "%LOG_DIR%" (
        echo ERROR: Could not create log directory "%LOG_DIR%". Check permissions.
        exit /b 1
    )
)

:: --- Get Today's Date for Log File (YYYY-MM-DD format using WMIC) ---
:: This method is reliable and locale-independent.
for /f "tokens=2 delims==" %%a in ('wmic path win32_localtime get year /value') do set "YYYY=%%a"
for /f "tokens=2 delims==" %%a in ('wmic path win32_localtime get month /value') do set "MM=00%%a"
for /f "tokens=2 delims==" %%a in ('wmic path win32_localtime get day /value') do set "DD=00%%a"

:: Format Month and Day with leading zeros if necessary
set "MM=%MM:~-2%"
set "DD=%DD:~-2%"

set "CURRENT_DATE=%YYYY%-%MM%-%DD%"

:: --- Define Log File Path ---
set "LOG_FILE=%LOG_DIR%DebugPushover_%CURRENT_DATE%.txt"

:: --- Start Logging ---
:: Use > to CREATE/OVERWRITE the log file with the first line.
:: All subsequent echoes will use >> to APPEND.
echo ===================================================================== > "%LOG_FILE%"
echo Pushover Notification Script Started - %DATE% %TIME% >> "%LOG_FILE%"
echo --------------------------------------------------------------------- >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"
echo Configuration Details: >> "%LOG_FILE%"
echo   API Token: %PUSHOVER_API_TOKEN% >> "%LOG_FILE%"
echo   User Key: %PUSHOVER_USER_KEY% >> "%LOG_FILE%"
echo   Message File Path: "%MESSAGE_FILE_PATH%" >> "%LOG_FILE%"
echo   Log File Name: "%LOG_FILE%" >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

:: --- Check if Message File Exists ---
if not exist "%MESSAGE_FILE_PATH%" (
    echo ERROR: Message file not found at "%MESSAGE_FILE_PATH%". >> "%LOG_FILE%"
    echo. >> "%LOG_FILE%"
    echo Script finished with error (File Not Found). >> "%LOG_FILE%"
    echo ===================================================================== >> "%LOG_FILE%"
    endlocal
    exit /b 1
) else (
    echo INFO: Message file found and readable. >> "%LOG_FILE%"
)
echo. >> "%LOG_FILE%"

:: --- Execute the cURL Command and Redirect All Output to Log File ---
echo INFO: Attempting to send Pushover notification via cURL... >> "%LOG_FILE%"
:: Redirect both standard output (1) and standard error (2) to the log file.
:: The cURL command's response (success/error from Pushover API) will be captured.
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
    echo SUCCESS: Pushover notification sent successfully. (cURL Exit Code: %CURL_EXIT_CODE%) >> "%LOG_FILE%"
) else (
    echo ERROR: FAILED to send Pushover notification. (cURL Exit Code: %CURL_EXIT_CODE%) >> "%LOG_FILE%"
    echo Please review the cURL output section above in this log file for details from Pushover API. >> "%LOG_FILE%"
)
echo Script finished. >> "%LOG_FILE%"
echo ===================================================================== >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

endlocal
exit /b %CURL_EXIT_CODE%