<#
.Synopsis
   Starts chocolatey install and logs results to logserver.
.NOTES
   Version:        0.1
   Author:         Peter Schmid <schmidp@edith-stein-schule.net>
   Creation Date:  25.03.2022
#>

# load configuration file
$config = Get-Content -Path ./config.json | ConvertFrom-Json

# the url of the REST api for log messages
$urlLog   = $config.urlLog

# the software list to install
$listPath = $config.listPaths.install

# get actual timestamp
$now = Get-Date -Format "o"

# get host name
$computername = $env:computername
$computername = $computername.ToLower()

$headers = @{
    'Content-Type'  = 'application/json; charset=utf-8';
    'Authorization' = $config.token
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
