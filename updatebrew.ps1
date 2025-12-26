param(
    [Parameter(Mandatory = $true)]
    [string]
    $Version
)

$osxX64Pattern = "safeincloudviewer-v$Version-osx-x64"
$osxArm64Pattern = "safeincloudviewer-v$Version-osx-arm64"
$linuxX64Pattern = "safeincloudviewer-v$Version-linux-x64"

$osxX64File = Get-ChildItem -Path $PSScriptRoot -File | Where-Object { $_.Name -eq $osxX64Pattern } | Select-Object -First 1
$osxArm64File = Get-ChildItem -Path $PSScriptRoot -File | Where-Object { $_.Name -eq $osxArm64Pattern } | Select-Object -First 1
$linuxX64File = Get-ChildItem -Path $PSScriptRoot -File | Where-Object { $_.Name -eq $linuxX64Pattern } | Select-Object -First 1

if (-not $osxX64File) {
    throw "Unable to locate $osxX64Pattern in the current directory."
}
if (-not $osxArm64File) {
    throw "Unable to locate $osxArm64Pattern in the current directory."
}
if (-not $linuxX64File) {
    throw "Unable to locate $linuxX64Pattern in the current directory."
}

Write-Output "Getting hashes for Homebrew formula..."
$osxX64Hash = (Get-FileHash -Path $osxX64File.FullName -Algorithm SHA256).Hash
$osxArm64Hash = (Get-FileHash -Path $osxArm64File.FullName -Algorithm SHA256).Hash
$linuxX64Hash = (Get-FileHash -Path $linuxX64File.FullName -Algorithm SHA256).Hash

Write-Output "macOS x64 Hash: $osxX64Hash"
Write-Output "macOS ARM64 Hash: $osxArm64Hash"
Write-Output "Linux x64 Hash: $linuxX64Hash"

$formulaPath = "Formula/safeincloudviewer.rb"
$formulaContent = Get-Content -Path $formulaPath -Raw

$formulaContent = $formulaContent -replace 'version "[\d\.]+"', "version `"$Version`""

$formulaContent = $formulaContent -replace 'url "https://github\.com/yetanotherchris/safeincloudviewer/releases/download/v[\d\.]+/safeincloudviewer-v[\d\.]+-osx-arm64"', "url `"https://github.com/yetanotherchris/safeincloudviewer/releases/download/v$Version/safeincloudviewer-v$Version-osx-arm64`""
$formulaContent = $formulaContent -replace 'url "https://github\.com/yetanotherchris/safeincloudviewer/releases/download/v[\d\.]+/safeincloudviewer-v[\d\.]+-osx-x64"', "url `"https://github.com/yetanotherchris/safeincloudviewer/releases/download/v$Version/safeincloudviewer-v$Version-osx-x64`""
$formulaContent = $formulaContent -replace 'url "https://github\.com/yetanotherchris/safeincloudviewer/releases/download/v[\d\.]+/safeincloudviewer-v[\d\.]+-linux-x64"', "url `"https://github.com/yetanotherchris/safeincloudviewer/releases/download/v$Version/safeincloudviewer-v$Version-linux-x64`""

$lines = $formulaContent -split "`n"
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match 'if Hardware::CPU\.arm\?' -and $i + 2 -lt $lines.Length -and $lines[$i + 2] -match 'sha256') {
        $lines[$i + 2] = $lines[$i + 2] -replace 'sha256 "[a-fA-F0-9]*"', "sha256 `"$($osxArm64Hash.ToLower())`""
    }
    elseif ($lines[$i] -match 'else' -and $i + 2 -lt $lines.Length -and $lines[$i + 2] -match 'sha256') {
        $lines[$i + 2] = $lines[$i + 2] -replace 'sha256 "[a-fA-F0-9]*"', "sha256 `"$($osxX64Hash.ToLower())`""
    }
    elseif ($lines[$i] -match 'on_linux do' -and $i + 2 -lt $lines.Length -and $lines[$i + 2] -match 'sha256') {
        $lines[$i + 2] = $lines[$i + 2] -replace 'sha256 "[a-fA-F0-9]*"', "sha256 `"$($linuxX64Hash.ToLower())`""
    }
}
$formulaContent = $lines -join "`n"

$formulaContent = $formulaContent -replace 'bin\.install "safeincloudviewer-v[\d\.]+-osx-arm64"', "bin.install `"safeincloudviewer-v$Version-osx-arm64`""
$formulaContent = $formulaContent -replace 'bin\.install "safeincloudviewer-v[\d\.]+-osx-x64"', "bin.install `"safeincloudviewer-v$Version-osx-x64`""
$formulaContent = $formulaContent -replace 'bin\.install "safeincloudviewer-v[\d\.]+-linux-x64"', "bin.install `"safeincloudviewer-v$Version-linux-x64`""

Write-Output "Creating Formula/safeincloudviewer.rb for version $Version..."
$formulaContent | Out-File -FilePath $formulaPath -Encoding utf8
