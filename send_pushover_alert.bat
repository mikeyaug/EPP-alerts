@echo off
setlocal

:: --- Pushover API Configuration ---
set "PUSHOVER_API_TOKEN=a63fhe925k5mfnvghksrj7hnxibdik"
set "PUSHOVER_USER_KEY=u1rf152q6czys8fkoozrsehkobzs51"

:: --- Message File Path ---
set "MESSAGE_FILE_PATH=C:\Program Files\WxMesgNet\WxMesg-to-Pushover\alert.txt"

:: --- Log File Path ---
set "LOG_FILE=DebugPushover.txt"

:: --- Get Current Timestamp ---
:: For current date and time: %DATE% and %TIME%
:: Format for log: YYYY-MM-DD HH:MM:SS
for /f "tokens=1-4 delims=/ " %%a in ("%date%") do (
    set "YY=%%d"
    set "MM=%%b"
    set "DD=%%c"
)
set "HH=%time:~0,2%"
set "NN=%time:~3,2%"
set "SS=%time:~6,2%"
set "TIMESTAMP=%YY%-%MM%-%DD% %HH%:%NN%:%SS%"

:: --- Construct and Execute the cURL Command ---
:: Redirect curl's output to a temporary file, so we can check it later if needed.
:: We are only logging error messages to DebugPushover.txt, not curl's output itself.
set "CURL_OUTPUT_TEMP=%TEMP%\curl_pushover_output.tmp"
curl -s ^
  -F "token=%PUSHOVER_API_TOKEN%" ^
  -F "user=%PUSHOVER_USER_KEY%" ^
  -F "message=<\"%MESSAGE_FILE_PATH%\"" ^
  https://api.pushover.net/1/messages.json > "%CURL_OUTPUT_TEMP%" 2>&1

:: --- Check the exit code of curl and log errors ---
if %ERRORLEVEL% equ 0 (
    echo %TIMESTAMP% - Pushover notification sent successfully. >> "%LOG_FILE%"
) else (
    echo %TIMESTAMP% - Failed to send Pushover notification. cURL Exit Code: %ERRORLEVEL%. >> "%LOG_FILE%"
    :: Optionally, also log the content of curl's output if it was an error
    echo %TIMESTAMP% - cURL output for failed request: >> "%LOG_FILE%"
    type "%CURL_OUTPUT_TEMP%" >> "%LOG_FILE%"
    echo. >> "%LOG_FILE%" :: Add a blank line for readability in log
)

:: Clean up temporary curl output file
if exist "%CURL_OUTPUT_TEMP%" del "%CURL_OUTPUT_TEMP%"

endlocal
exit /b 0