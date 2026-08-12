# SysCoLab installer — Windows.
# Usage: irm <releases-repo-raw-url>/main/install.ps1 | iex

$ErrorActionPreference = "Stop"
$Repo = if ($env:SYSCOLAB_RELEASES_REPO) { $env:SYSCOLAB_RELEASES_REPO } else { "hrishi-anveshak/syscolab-releases" }
$BinDir = if ($env:SYSCOLAB_BIN_DIR) { $env:SYSCOLAB_BIN_DIR } else { "$env:USERPROFILE\.syscolab\bin" }

function Step($msg) { Write-Host "==> $msg" -ForegroundColor DarkYellow }
function Ok($msg)   { Write-Host "OK  $msg" -ForegroundColor Green }
function Die($msg)  { Write-Host "ERR $msg" -ForegroundColor Red; exit 1 }

Write-Host ""
Write-Host " S Y S C O L A B " -ForegroundColor DarkYellow
Write-Host "terminal ssh cockpit -- by Hrishikesh Jadhav" -ForegroundColor DarkGray
Write-Host ""

$arch = if ([Environment]::Is64BitOperatingSystem) { "x86_64" } else { Die "Unsupported architecture" }
$asset = "syscolab-windows-$arch.exe"
Step "detected windows/$arch"

Step "looking up latest release of $Repo"
$release = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest"
$assetInfo = $release.assets | Where-Object { $_.name -eq $asset }
if (-not $assetInfo) { Die "No release asset found for $asset. Has a release been published to $Repo?" }
Ok "found $($release.tag_name)"

New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
$dest = Join-Path $BinDir "syscolab.exe"

Step "downloading"
Invoke-WebRequest -Uri $assetInfo.browser_download_url -OutFile $dest
Ok "installed to $dest"

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$BinDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$BinDir", "User")
    Write-Host ""
    Write-Host "Added $BinDir to your PATH. Restart your terminal for it to take effect." -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "done. run it with: syscolab" -ForegroundColor Green
Write-Host ""
