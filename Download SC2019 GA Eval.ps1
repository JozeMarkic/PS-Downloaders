# Download all SC 2019 GA Eval
function Read-FolderBrowserDialog ([string]$Message, [string]$InitialDirectory, [switch]$NoNewFolderButton) {
    $browseForFolderOptions = 0
    if ($NoNewFolderButton) { $browseForFolderOptions += 512 }
 
    $app = New-Object -ComObject Shell.Application
    $folder = $app.BrowseForFolder(0, $Message, $browseForFolderOptions, $InitialDirectory)
    if ($folder) { $selectedDirectory = $folder.Self.Path } else { $selectedDirectory = '' }
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($app) > $null
    return $selectedDirectory
}

# Download folder
$Down = Read-FolderBrowserDialog
if ($Down.Length -eq 0) {
    Write-Output -InputObject "No folder selected..."
    break
} elseif (-not (Test-Path -Path $Down)) {
    Write-Output -InputObject "No folder selected..."
    break
} else {
    Write-Output -InputObject "Destination folder selected: $Down"
    pause
}
 
$SC2019 = @()
$SC2019 += [PSCustomObject] @{ Products = "SCVMM"; URL = "http://download.microsoft.com/download/C/4/E/C4E93EE0-F2AB-43B9-BF93-32E872E0D9F0/SCVMM_2019.exe" }
$SC2019 += [PSCustomObject] @{ Products = "SCOM"; URL = "http://download.microsoft.com/download/C/4/E/C4E93EE0-F2AB-43B9-BF93-32E872E0D9F0/SCOM_2019.exe" }
$SC2019 += [PSCustomObject] @{ Products = "SCORCH"; URL = "http://download.microsoft.com/download/C/4/E/C4E93EE0-F2AB-43B9-BF93-32E872E0D9F0/SCO_2019.exe" }
$SC2019 += [PSCustomObject] @{ Products = "SCDPM"; URL = "http://download.microsoft.com/download/C/4/E/C4E93EE0-F2AB-43B9-BF93-32E872E0D9F0/SCDPM_2019.exe" }
$SC2019 += [PSCustomObject] @{ Products = "SCSM"; URL = "http://download.microsoft.com/download/C/4/E/C4E93EE0-F2AB-43B9-BF93-32E872E0D9F0/SCSM_2019.exe" }
$SC2019 += [PSCustomObject] @{ Products = "SCSM-Auth"; URL = "http://download.microsoft.com/download/C/4/E/C4E93EE0-F2AB-43B9-BF93-32E872E0D9F0/SCSM_Auth_2019.exe" }
$Selection = $SC2019 | Out-GridView -Title "Select SC EXEs to download (use CTRL/SHIFT to select more than one)" -OutputMode Multiple


ForEach ($SC in $Selection) {
    $File = Join-Path -Path $Down -ChildPath $($SC.URL.split("/")[-1])
    if(!(Get-Item -Path $File -ErrorAction SilentlyContinue)){
        Start-BitsTransfer -Source $SC.URL -Destination $Down -Description "$File" -DisplayName "$($Selection.Products)"
    }
}
