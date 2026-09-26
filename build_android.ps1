# =====================================================================
#  YOGO POS - Android APK build script
#
#  Usage (project root theke):
#     .\build_android.ps1 -Label Y1
#     .\build_android.ps1 -Label Y1-DUAL
#
#  Output name: ANDROID-YOGOPOS-<LABEL>-<MMM_DD>-<version>.apk
#               (e.g. ANDROID-YOGOPOS-Y1-SEP_24-1.07.11+05.apk)
# =====================================================================

param(
    [Parameter(Mandatory = $true)]
    [string]$Label
)

$ErrorActionPreference = 'Stop'

# ---------- Paths ----------
$ProjectRoot = $PSScriptRoot
$ApkSource   = Join-Path $ProjectRoot 'build\app\outputs\flutter-apk\app-release.apk'
$OutputDir   = Join-Path $ProjectRoot 'installer\android'
$DropboxRoot = 'C:\Users\Zubair\Dropbox\YOGO- A1\Zee\APP\Android'

# ---------- Date (e.g. SEP_24) - always English month ----------
$En      = [System.Globalization.CultureInfo]::GetCultureInfo('en-US')
$DateTag = (Get-Date).ToString('MMM_dd', $En).ToUpper()

# ---------- Version from pubspec.yaml ----------
$Version = (Select-String -Path (Join-Path $ProjectRoot 'pubspec.yaml') -Pattern '^version:\s*(\S+)').Matches[0].Groups[1].Value

$OutName = "ANDROID-YOGOPOS-$Label-$DateTag-$Version".ToUpper() + '.apk'

function Step($n, $msg) { Write-Host "`n[$n/6] $msg" -ForegroundColor Cyan }
function Run($cmd) {
    Invoke-Expression $cmd
    if ($LASTEXITCODE -ne 0) { throw "Failed: $cmd" }
}

Write-Host "Label   : $Label"
Write-Host "Date    : $DateTag"
Write-Host "Version : $Version"
Write-Host "Output  : $OutName"

Push-Location $ProjectRoot
try {
    # 1. flutter clean
    Step 1 'flutter clean'
    Run 'flutter clean'

    # 2. flutter pub get
    Step 2 'flutter pub get'
    Run 'flutter pub get'

    # 3. flutter build apk --release
    Step 3 'flutter build apk --release'
    Run 'flutter build apk --release'
    if (-not (Test-Path $ApkSource)) { throw "APK not found: $ApkSource" }

    # 4. Remove old .apk files from installer\android
    Step 4 'Removing old APKs from installer\android\'
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
    Get-ChildItem -Path $OutputDir -Filter '*.apk' -File | ForEach-Object {
        Write-Host "   deleted $($_.Name)"
        Remove-Item $_.FullName -Force
    }

    # 5. Copy + rename APK into installer\android
    Step 5 "Saving $OutName"
    $Apk = Join-Path $OutputDir $OutName
    Copy-Item $ApkSource $Apk -Force
    Write-Host "   $Apk"

    # 6. Copy APK to Dropbox\Android\<DATE>
    Step 6 "Copying to Dropbox\Android\$DateTag"
    $DropDir = Join-Path $DropboxRoot $DateTag
    if (-not (Test-Path $DropDir)) {
        New-Item -ItemType Directory -Path $DropDir | Out-Null
        Write-Host "   created folder $DropDir"
    }
    Copy-Item $Apk $DropDir -Force
    Write-Host "   copied to $DropDir"
}
finally {
    Pop-Location
}

Write-Host "`nDONE: $OutName" -ForegroundColor Green
