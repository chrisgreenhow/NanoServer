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

# Paths & Variables
$nanoPath = "c:\nano"
$vhdMinBytes = 256MB
$vhdMaxBytes = 2GB

$isoPath = "$nanoPath\iso"
$basePath = "$nanoPath\Base"
$targetPath = "$nanoPath\$serverName\Nano.vhdx"

if(!$ColorScheme) {
    $ColorScheme = @{
        "Help_Header"=[ConsoleColor]::Yellow
        "ConfirmText"=[ConsoleColor]::Green
    }
}

# Helper function
function YesNoPrompt()
{
    $validValues = "Y","N"
    do 
    {
        write-host -nonewline "  (Y)es or (N)o: "
        $inputString = read-host
        $value = $inputString
        $ok = $validValues -contains $value[0] # Take first char of input only
        if ( -not $ok ) { write-host -nonewline "You must enter a valid option." }
    }
    until ( $ok )
    return $value
}

# Main

# Check if NanoServerImageGenerator module is imported and import it
$webmod = Get-Module NanoServerImageGenerator
if($webmod -eq $null -or $webmod.Count -eq 0)
{
    Import-Module .\NanoServerImageGenerator.psm1
}

Write-Host -nonewline "Creating Nano Server Image "
Write-Host -nonewline -ForegroundColor $ColorScheme.Help_Header $serverName
Write-Host -nonewline " in folder "
Write-Host -ForegroundColor $ColorScheme.Help_Header $targetPath

Write-Host -nonewline "`nContinue?"
$value = YesNoPrompt

if ($value -eq "Y" -or $value -eq "y")
{
    # Create the new Nano Server VHDX
    New-NanoServerImage -MediaPath $isoPath -BasePath $basePath -TargetPath $targetPath -ComputerName $serverName –GuestDrivers -ReverseForwarders -Packages Microsoft-NanoServer-IIS-Package -Language en-us -EnableRemoteManagementPort -MergePath .\Tools

    # Create a new VM and using the VHDX created above.
    New-VM -Name $serverName -Generation 2 -MemoryStartupBytes $vhdMinBytes -VHDPath $targetPath -SwitchName "Internal Virtual Switch"
    Set-VMMemory $serverName -DynamicMemoryEnabled $true -MinimumBytes $vhdMinBytes -StartupBytes $vhdMinBytes -MaximumBytes $vhdMaxBytes -Priority 50 -Buffer 20

    Write-Host -nonewline "Starting VM "
    Write-Host -nonewline -ForegroundColor $ColorScheme.Help_Header $serverName
    Write-Host -nonewline "..."
    
    Start-VM $serverName
    Write-Host -ForegroundColor $ColorScheme.ConfirmText " Done."
}