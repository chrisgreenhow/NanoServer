[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True)]
   [string]$serverName
)

# Script must be running as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}

if(!$ColorScheme) {
    $ColorScheme = @{
        "Help_Header"=[ConsoleColor]::Yellow
        "ConfirmText"=[ConsoleColor]::Green
    }
}

# Find the IP of the Nano Server VM using the ServerName
Write-Host -nonewline "Finding Nano Server IP"
$timeout = new-timespan -Minutes 1
$sw = [diagnostics.stopwatch]::StartNew()
while ($sw.elapsed -lt $timeout)
{
    Write-Host -nonewline "."
    if ((Get-VMNetworkAdapter $serverName).IPAddresses -ne $null)
    {
        $serverIP = (Get-VMNetworkAdapter $serverName).IPAddresses[0]
        break
    }
    start-sleep -s 2
}

# If IP is found, run the setup script on Nano Server
if($serverIP -ne $null)
{
    Write-Host -ForegroundColor $ColorScheme.Help_Header " Found."
    
    # Add the Nano Server IP to TrustedHosts
    Write-Host -nonewline "Adding IP "
    Write-Host -nonewline -ForegroundColor $ColorScheme.Help_Header $serverIP
    Write-Host " to TrustedHosts."
    
    Set-Item WSMan:\localhost\Client\TrustedHosts $serverIP -force -concatenate
    
    # Invoke the setup script on the Nano Server
    Write-Host -nonewline "Running Setup script on Nano Server..."
    $user = "~\Administrator"
    Invoke-Command -Computername $serverIP -ScriptBlock { C:\Tools\Setup.ps1 } -Credential $user
    
    Write-Host -ForegroundColor $ColorScheme.ConfirmText " Done."
}