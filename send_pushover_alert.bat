@echo off
setlocal

:: --- Pushover API Configuration ---
set "PUSHOVER_API_TOKEN=ankqnbni7ba839ohmv3xia376r8mji"
set "PUSHOVER_USER_KEY=u1rf152q6czys8fkoozrsehkobzs51"

:: --- Message File Path ---
:: Important: Use double backslashes for paths in batch files,
:: or single backslashes if the path is quoted.
:: For curl, when passing a path that contains spaces and backslashes,
:: it's safest to keep the double backslashes for consistency with how curl expects it.
set "MESSAGE_FILE_PATH=C:\\Program Files\\WxMesgNet\\WxMesg-to-Pushover\\alert.txt"

:: --- Construct and Execute the cURL Command ---
:: The ^ characters before % are needed to escape them if you were directly
:: constructing the curl command without variables, but with variables as set above,
:: we can use them directly.
:: The entire --form-string containing the path needs to be quoted
:: because of spaces in "Program Files".
curl -s ^
  --form-string "token=%PUSHOVER_API_TOKEN%" ^
  --form-string "user=%PUSHOVER_USER_KEY%" ^
  --form-string "message=<\"%MESSAGE_FILE_PATH%\"" ^
  https://api.pushover.net/1/messages.json

:: --- Optional: Check the exit code of curl ---
:: You might want to add error checking here.
:: If %ERRORLEVEL% is 0, the curl command likely succeeded.
if %ERRORLEVEL% equ 0 (
    echo Pushover notification sent successfully.
) else (
    echo Failed to send Pushover notification. cURL Exit Code: %ERRORLEVEL%
)

endlocal
exit /b 0