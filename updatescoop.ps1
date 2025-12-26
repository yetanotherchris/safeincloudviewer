param(
    [Parameter(Mandatory = $true)]
    [string]
    $Version
)

$searchPattern = "safeincloudviewer-v$Version-win-x64.exe"
$file = Get-ChildItem -Path $PSScriptRoot -File | Where-Object { $_.Name -eq $searchPattern } | Select-Object -First 1

if (-not $file) {
    throw "Unable to locate $searchPattern in the current directory."
}

$filePath = $file.FullName
Write-Output "File found: $filePath, getting hash..."
$hash = (Get-FileHash -Path $filePath -Algorithm SHA256).Hash
Write-Output "Hash: $hash"

$manifest = @{
    version = $Version
    architecture = @{
        '64bit' = @{
            url = "https://github.com/yetanotherchris/safeincloudviewer/releases/download/v$Version/safeincloudviewer-v$Version-win-x64.exe"
            bin = @("safeincloudviewer.exe")
            hash = $hash
            extract_dir = ""
            pre_install = @("Rename-Item `"`$dir\safeincloudviewer-v$Version-win-x64.exe`" `"safeincloudviewer.exe`"")
        }
    }
    homepage = "https://github.com/yetanotherchris/safeincloudviewer"
    license = "MIT License"
    description = "A command line tool for viewing SafeInCloud password database files."
}

Write-Output "Creating safeincloudviewer.json for version $Version..."
$manifest | ConvertTo-Json -Depth 5 | Out-File -FilePath "safeincloudviewer.json" -Encoding utf8
