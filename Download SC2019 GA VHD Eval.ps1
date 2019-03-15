# Download all SC 2019 GA VHD Eval
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
 
# Get free space on destination volume
$FreeSpace = (Get-Volume $Down.Split(":")[0]).SizeRemaining
 
$SC2019 = @()
$SC2019 += [PSCustomObject] @{ Products = "SCVMM"; Size = "17 GB"; URL = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=58058" }
$SC2019 += [PSCustomObject] @{ Products = "SCOM"; Size = "8 GB"; URL = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=58057" }
$SC2019 += [PSCustomObject] @{ Products = "SCORCH"; Size = "8 GB"; URL = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=58055" }
$SC2019 += [PSCustomObject] @{ Products = "SCDPM"; Size = "11 GB"; URL = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=58059" }
$SC2019 += [PSCustomObject] @{ Products = "SCSM"; Size = "7 GB"; URL = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=58056" }
$Selection = $SC2019 | Out-GridView -Title "Select SC VHDs to download (use CTRL/SHIFT to select more than one)" -OutputMode Multiple

$Size = 0
ForEach ($SC in $Selection) {
    $Size += [int]$SC.Size.Substring(0,$SC.Size.IndexOf(" "))
}

if([int]($FreeSpace/1GB) -gt $Size){
    ForEach ($SC in $Selection) {
        $Folder = New-Item -Path $Down -Name $Selection.Products -ItemType Directory -Force
        $Links = ((Invoke-WebRequest -Uri $SC.URL -UseBasicParsing).links |
        Where-Object  -Property href -Match  -Value "exe$|docx$|bin$").href |
        Select-Object -Unique
        ForEach ($Link in $Links) {
            $File = Join-Path -Path $Folder -ChildPath $($Link.split("/")[-1])
            if(!(Get-Item -Path $File -ErrorAction SilentlyContinue)){
                Start-BitsTransfer -Source $Link -Destination $Folder -Description "$File" -DisplayName "$($Selection.Products)"
            }
        }
    }
} else {
    [int]$Sum = ($Size - $FreeSpace)
    Write-Host "Free up at least $Sum GB and try again!"
}
