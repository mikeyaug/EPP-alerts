# This script tests email for automated weather alerts using Google Workspace SMTP relay.
# It assumes the sending server's static IP address is authorized in Google Workspace.
# The recipient email address is collected as user input from the command line.
# Original script by Mike Augustyniak, modified for Google Workspace SMTP Relay.

param (
    [string]$recipientEmail, # Changed parameter name for clarity
    [string]$senderEmail = "alerts@escapeplanpartners.com", # <-- IMPORTANT: Change this to your authorized sending email address
    [string]$subject = "TEST: ⚠️ Weather ALERT from Escape Plan Partners",
    [string]$body = "This is a test of the automated weather alerting system via escapeplanpartners.com. Your sign-up for weather alerts was successful, and you will receive real-time alerts at this address or device during your contract period."
)

# --- Configuration for Google Workspace SMTP Relay ---
$smtpServer = "smtp-relay.gmail.com"
# Common ports for SMTP relay are 25, 465, or 587.
# Adjust $smtpPort and -UseSsl based on your Google Workspace SMTP Relay configuration.
$smtpPort = 587 # Or 465 if you configured SSL, or 25 if no SSL/TLS explicitly
$priorityLevel = "High" # Send-MailMessage -Priority accepts "Normal", "Low", "High"

# --- Recipient Validation (Simple Check) ---
if (-not $recipientEmail) {
    $recipientEmail = Read-Host -Prompt "Please enter the recipient's email address"
}

if (-not ($recipientEmail -match "@")) {
    Write-Error "Invalid recipient email address provided: $recipientEmail"
    exit 1
}

# --- Send the Email ---
try {
    Write-Host "Attempting to send test email to $recipientEmail from $senderEmail via $smtpServer..."

    # Note: -Credential parameter is removed as authentication is via IP address with smtp-relay.gmail.com
    # Adjust -UseSsl and -Port based on your specific SMTP relay service configuration.
    # If using port 25 and no SSL, remove -UseSsl.
    # If using port 465, -UseSsl is typically required.
    # If using port 587, -UseSsl enables STARTTLS.

    $sendMailParams = @{
        From       = $senderEmail
        To         = $recipientEmail
        Subject    = $subject
        Body       = $body
        SmtpServer = $smtpServer
        Port       = $smtpPort
        Priority   = $priorityLevel
    }

    # Only add -UseSsl if the port is not 25 (or if your port 25 relay is set up for STARTTLS)
    # For port 465 and 587, -UseSsl is generally recommended/required.
    if ($smtpPort -ne 25) {
        $sendMailParams.UseSsl = $true
    }
    # If your relay on port 25 IS configured for STARTTLS, you would add:
    # elseif ($smtpPort -eq 25 -and $YourRelayRequiresSTARTTLSOnPort25) {
    #    $sendMailParams.UseSsl = $true
    # }


    Send-MailMessage @sendMailParams

    Write-Host "Test email sent successfully to $recipientEmail!"
}
catch {
    Write-Error "Failed to send email. Error: $($_.Exception.Message)"
    if ($_.Exception.InnerException) {
        Write-Error "Inner Exception: $($_.Exception.InnerException.Message)"
    }
    Write-Warning "Common issues with SMTP Relay:"
    Write-Warning "- Ensure this server's public static IP address is correctly whitelisted in your Google Workspace SMTP relay service settings."
    Write-Warning "- Verify the '$senderEmail' address or its domain ('escapeplanpartners.com') is authorized to send via the relay service in your Google Workspace settings."
    Write-Warning "- Check that the correct port ($smtpPort) is specified and matches your relay configuration (25, 465, or 587)."
    Write-Warning "- Ensure the -UseSsl setting is appropriate for your chosen port and relay configuration."
    Write-Warning "- Check Google Workspace audit logs for more detailed error messages if available."
}
