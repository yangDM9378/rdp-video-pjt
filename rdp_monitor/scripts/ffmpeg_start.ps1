param(
    [string]$Timestamp = ""
)

# === 경로 설정 ===
$Ffmpeg = "C:\Users\user\Desktop\rdp-video-pjt\rdp_monitor\ffmpeg\bin\ffmpeg.exe"
$OutDir = "C:\Users\user\Desktop\rdp-video-pjt\rdp_monitor\record_test"
$PidDir = "C:\Users\user\Desktop\rdp-video-pjt\rdp_monitor\pids"

# === 폴더 생성 ===
if (!(Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }
if (!(Test-Path $PidDir)) { New-Item -ItemType Directory -Path $PidDir | Out-Null }

# === timestamp 미지정 시 현재 시간 사용 ===
if ([string]::IsNullOrWhiteSpace($Timestamp)) {
    $Timestamp = Get-Date -Format "yyyyMMddHHmmss"
}

# === 파일명 설정 ===
$FileName = "tester_$Timestamp.webm"
$OutputFile = "$OutDir\$FileName"
$LogFile = "$OutDir\log_$Timestamp.txt"

# === cmd.exe로 ffmpeg 실행 ===
$cmd = "`"$Ffmpeg`" -y -f gdigrab -framerate 30 -i desktop -vf scale=1280:720 -c:v libvpx-vp9 `"$OutputFile`" > `"$LogFile`" 2>&1"

$proc = Start-Process `
    -FilePath "cmd.exe" `
    -ArgumentList "/c $cmd" `
    -WindowStyle Normal `
    -PassThru

# === PID 저장 ===
$PidFile = "$PidDir\pid_$($proc.Id).txt"
$proc.Id | Out-File $PidFile -Encoding ascii

Write-Host "======================================="
Write-Host "ffmpeg STARTED - Check log file for details"
Write-Host "PID       = $($proc.Id)"
Write-Host "PID File  = $PidFile"
Write-Host "Output    = $OutputFile"
Write-Host "Log File  = $LogFile"
Write-Host "======================================="