<#
.Synopsis
   Starts chocolatey install and logs results to logserver.
.NOTES
   Version:        0.1
   Author:         Peter Schmid <schmidp@edith-stein-schule.net>
   Creation Date:  25.03.2022
#>

# the url of the REST api for log messages
$urlLog   = "http://192.168.105.25:1337/api/logs"

# the software list to install
$listPath = "\\ESAUSRV01\NETLOGON\chocolatey\install.txt"

# get actual timestamp
$now = Get-Date -Format "o"

# get host name
$computername = $env:computername
$computername = $computername.ToLower()

$headers = @{
    'Content-Type'  = 'application/json; charset=utf-8';
    'Authorization' = 'Bearer 8f6072a9b8f462bf83b4f7831abc4020e9e8d69fa024cf011174faf4b853e480a9b05afe2d87686a0dd7fecad07d727f89fe61691309cc28e6338252fd60b13a1d28a7a3325445f41439d4877effd706c2a24ef8a38c1625cffca610f5de23b20a07e71ba1525964fb96ee7eb860da322dadd20e3733e865050354127ff92a3c'
}

# read the software list from file
$software = Get-Content -Path $listPath

# remove all empty lines from list
$software = $software | Where-Object { -not [String]::IsNullOrWhiteSpace($_) }

#if there is something to install
if($software.Length -gt 0) {
    # run choco install and catch the output
    $installOutput = choco install $software --nocolor --acceptlicense --yes --limitoutput --no-progress --ignoredetectedreboot | Out-String

    # set log state corresponding to exit code
    $state = switch ($LASTEXITCODE) {
        0 {
            "INFO"
        }
        1641 {
            "INFO"
        }
        3010 {
            "INFO"
        }
        350 {
            "WARNING"
        }
        1604 {
            "WARNING"
        }
        1 {
            "ERROR"
        }
        -1 {
            "ERROR"
        }
        default { 'WARNING' }
    }

    # create log message
    $message = "[INSTALL] EXITCODE: " + $LASTEXITCODE + [System.Environment]::NewLine + $installOutput

    # create json oject
    $jsonString = @{ data= @{ state=$state; message=$message; computername=$computername; date=$now } } | ConvertTo-Json

    # post information to logserver
    Invoke-WebRequest -UseBasicParsing $urlLog -ContentType "application/json" -Method POST -Body $jsonString -Headers $headers
}
