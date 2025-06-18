@echo off
setlocal

:: --- Configuration Variables ---
set "PUSHOVER_API_TOKEN=ankqnbni7ba839ohmv3xia376r8mji"
set "PUSHOVER_USER_KEY=u1rf152q6czys8fkoozrsehkobzs51"
set "MESSAGE_FILE_PATH=C:\Program Files\WxMesgNet\WxMesg-to-Pushover\alert.txt"
set "LOG_DIR=C:\Program Files\WxMesgNet\"

:: --- Ensure Log Directory Exists ---
if not exist "%LOG_DIR%" (
    echo INFO: Creating log directory "%LOG_DIR%"
    mkdir "%LOG_DIR%"
    if not exist "%LOG_DIR%" (
        echo ERROR: Could not create log directory "%LOG_DIR%". Check permissions.
        exit /b 1
    )
)

:: --- Get Today's Date for Log File (YYYY-MM-DD format using WMIC - More Robust) ---
:: We pipe WMIC output through findstr to filter out blank lines and ensure only "Key=Value" lines are processed.
:: Then, we use if/else for padding instead of substring slicing, which is safer if the variable is not set.

:: Get Year
set "YYYY="
for /f "tokens=2 delims==" %%a in ('wmic path win32_localtime get year /value ^| findstr "="') do set "YYYY=%%a"
if not defined YYYY (
    set "YYYY=UNKNOWN"
    echo ERROR: Could not determine Year from WMIC. >> "%LOG_DIR%_error.log"
)

:: Get Month
set "MM_RAW="
for /f "tokens=2 delims==" %%a in ('wmic path win32_localtime get month /value ^| findstr "="') do set "MM_RAW=%%a"
if not defined MM_RAW (
    set "MM=UN"
    echo ERROR: Could not determine Month from WMIC. >> "%LOG_DIR%_error.log"
) else (
    if "%MM_RAW%" LSS "10" (set "MM=0%MM_RAW%") else (set "MM=%MM_RAW%")
)

:: Get Day
set "DD_RAW="
for /f "tokens=2 delims==" %%a in ('wmic path win32_localtime get day /value ^| findstr "="') do set "DD_RAW=%%a"
if not defined DD_RAW (
    set "DD=KN"
    echo ERROR: Could not determine Day from WMIC. >> "%LOG_DIR%_error.log"
) else (
    if "%DD_RAW%" LSS "10" (set "DD=0%DD_RAW%") else (set "DD=%DD_RAW%")
)

:: Assemble Current Date (fallback if parts are unknown)
set "CURRENT_DATE=%YYYY%-%MM%-%DD%"
if "%CURRENT_DATE%" == "UNKNOWN-UN-KN" (
    echo WARNING: Date components could not be fully determined. Using generic date. >> "%LOG_DIR%_error.log"
    set "CURRENT_DATE=NODATE_%RANDOM%"
)

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