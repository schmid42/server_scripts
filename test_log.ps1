<#
.Synopsis
   Starts chocolatey upgrade and logs results to logserver.
.NOTES
   Version:        0.2
   Author:         Peter Schmid <schmidp@edith-stein-schule.net>
   Creation Date:  25.03.2022
#>

# the url of the REST api for log messages
$urlLog   = "http://192.168.105.25:1337/api/logs"

# the software list to upgrade
$listPath = "\\ESAUSRV01\NETLOGON\chocolatey\upgrade.txt"

# get actual timestamp
$now = Get-Date -Format "o"

# create log message
$message = "TESTMESSAGE"

# create json oject
$jsonString = @{ data= @{ state="DEBUG"; message=$message; computername=$env:computername; date=$now } } | ConvertTo-Json

# post information to logserver
Invoke-WebRequest -UseBasicParsing $urlLog -ContentType "application/json" -Method POST -Body $jsonString -Headers @{ 'Content-Type' = 'application/json; charset=utf-8'; 'Authorization' = 'Bearer 8f6072a9b8f462bf83b4f7831abc4020e9e8d69fa024cf011174faf4b853e480a9b05afe2d87686a0dd7fecad07d727f89fe61691309cc28e6338252fd60b13a1d28a7a3325445f41439d4877effd706c2a24ef8a38c1625cffca610f5de23b20a07e71ba1525964fb96ee7eb860da322dadd20e3733e865050354127ff92a3c' }

