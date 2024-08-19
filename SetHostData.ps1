#This script is for creating a windows registry key based on the provided parameters

param (
    [Parameter(Mandatory=$true)]
    [string]$Hostname,

    [Parameter(Mandatory=$true)]
    [string]$Username,

    [Parameter(Mandatory=$true)]
    [string]$Password
)
# The name of the application that will be used as the name of the registry key
$appName=""

# The path of the registry key (HKEY_CURRENT_USER)
$registryPath = "HKLM:\Software\$appName\$Hostname"

$currentDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

try{
    #Checking if the provided key already exists
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force
    }

    #Set the username and password within the created registry key
    Set-ItemProperty -Path $registryPath -Name "username" -Value $Username
    Set-ItemProperty -Path $registryPath -Name "password" -Value $Password
    Set-ItemProperty -Path $registryPath -Name "date" -Value $currentDate

    #Let the user know about the result
    Write-Host  "The username and password has been created under the wanted registry key"

    Write-Host "Creating shortcut on the Desktop"
    
    # Getting the interactive username
    $InteractiveUser = (query user | Select-String -Pattern ">" | ForEach-Object {
        $_.ToString().Trim() -replace "^>", "" -replace "\s+.*$",""
    }).Trim()

    # Getting the interactive user profile path
    $UserProfilePath = [System.Environment]::ExpandEnvironmentVariables("%SystemDrive%\Users\$InteractiveUser")
    $DesktopPath = Join-Path $UserProfilePath "Desktop"

    # Getting the directory from which this script is running
    $ScriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

    # Creating the shortcut on user's Desktop
    $ShortcutName = "Hibabejelento-$Hostname.lnk"
    $ShortcutPath = Join-Path $DesktopPath $ShortcutName
    $TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    $ScriptFilePath = Join-Path $ScriptDirectory "SendHostData.ps1"
    $Arguments = "-File `"$ScriptFilePath`" -Hostname `"$Hostname`""

    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = $TargetPath
    $Shortcut.Arguments = $Arguments
    $Shortcut.Save()
}catch{
    Write-Host "Some error occured during the process"
    $string_err = $_ | Out-String
    Write-Host $string_err
}
