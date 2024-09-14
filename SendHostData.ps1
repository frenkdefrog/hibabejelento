#This script reads a specific windows registry key.
#By its value it creates a temporary html file wich with a remote login can be done.

#Set variables for powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$Hostname
)
$appname = ""
try {
    $registryPath = "HKLM:\Software\$appname\$Hostname"
    write-host "Reading registrypath: $registryPath"
    write-host "Reading host authentication data: $Hostname"
    $username = (Get-ItemProperty -Path $registryPath -Name "Username").Username
    $password = (Get-ItemProperty -Path $registryPath -Name "Password").Password
    $company = (Get-ItemProperty -Path $registryPath -Name "Company").Company
   
    
    $url = "<remote form action target url comes here>"

    $htmlContent = @"
<!DOCTYPE html>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <title>Automated Login</title>
    <script type="text/javascript">
        function submitForm() {
            document.getElementById('loginForm').submit();
        }
    </script>
</head>
<body onload="submitForm()">
    <form id="loginForm" action="$url" method="post">
        <input type="hidden" name="username" value="$username">
        <input type="hidden" name="ceg" value="$company">
        <input type="hidden" name="pass" value="$password">
        <noscript>
            <p>JavaScript is disabled in your browser. Please enable it to automatically submit the form.</p>
            <button type="submit">Login</button>
        </noscript>
    </form>
</body>
</html>
"@

    # Generating the html page by the template
    $htmlFilePath = "$env:TEMP\autologin.html"
    $htmlContent | Out-File -FilePath $htmlFilePath -Encoding UTF8

    Start-Process "chrome.exe" $htmlFilePath
    Start-Sleep  -Seconds 1
    Remove-Item $htmlFilePath

} catch {
    Write-Host "Some error occured during the process"
    $string_err = $_ | Out-String
    Write-Host $string_err
}
