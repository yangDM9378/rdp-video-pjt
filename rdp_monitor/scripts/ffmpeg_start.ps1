param(
    [string]$Timestamp = ""
)

# === Path Settings ===
$Ffmpeg = "C:\rdp-video-pjt\rdp_monitor\ffmpeg\bin\ffmpeg.exe"
$OutDir = "C:\rdp-video-pjt\rdp_monitor\record_test"
$BasePidDir = "C:\rdp-video-pjt\rdp_monitor\pids"

# === Current Username ===
$UserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name.Split('\')[-1]
$PidDir = "$BasePidDir\$UserName"

# === Create directories if missing ===
@( $OutDir, $BasePidDir, $PidDir ) | ForEach-Object {
    if (!(Test-Path $_)) { New-Item -ItemType Directory -Path $_ | Out-Null }
}

# === Timestamp ===
if ([string]::IsNullOrWhiteSpace($Timestamp)) {
    $Timestamp = Get-Date -Format "yyyyMMddHHmmss"
}

# === Output video filename ===
$FileName = "record_$Timestamp.webm"
$OutputFile = "$OutDir\$FileName"

# === FFmpeg Arguments ===
$Args = @(
    "-y"
    "-f", "gdigrab"
    "-framerate", "30"
    "-i", "desktop"
    "-vf", "scale=1280:720"
    "-c:v", "libvpx-vp9"
    "$OutputFile"
)

# === Start FFmpeg directly ===
$proc = Start-Process `
    -FilePath $Ffmpeg `
    -ArgumentList $Args `
    -WindowStyle Hidden `
    -PassThru

# === Save PID ===
$PidFile = "$PidDir\pid_$($proc.Id).txt"
$proc.Id | Out-File $PidFile -Encoding ascii

# === Console Output ===
Write-Host "======================================="
Write-Host "FFmpeg Recording Started"
Write-Host "User      : $UserName"
Write-Host "PID       : $($proc.Id)"
Write-Host "PID File  : $PidFile"
Write-Host "Output    : $OutputFile"
Write-Host "======================================="
