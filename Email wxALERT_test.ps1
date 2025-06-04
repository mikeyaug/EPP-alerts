# This script tests email and/or SMS/MMS information for automated weather alerts.
# The recipient email address is collected as user input from the command line.
# Written 6-6-2024 by Mike Augustyniak with assistance from Bing AI

param([string[]]$recipient)

$sender = "wx_alerts@cbs.com"
$subject = "TEST: Urgent Weather Alert"
$body = "This is a test of the weather alerting system. Your sign-up for weather alerts was successful, and you will now begin receiving real-time alerts at this address."
$smtpServer = "smtprelay.cbs.com"
$Priority = 2

Send-MailMessage -From $sender -To $recipient -Subject $subject -Body $body -SmtpServer $smtpServer -Priority $Priority