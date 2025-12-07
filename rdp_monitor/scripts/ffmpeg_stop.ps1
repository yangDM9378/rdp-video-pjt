# powershell -File ffmpeg_stop.ps1 -PidFile "C:\Users\user\Desktop\rdp-video-pjt\rdp_monitor\pids\pid_12345.txt"

param(
    [string]$PidFile = ""
)

if (-not (Test-Path $PidFile)) {
    Write-Host "❌ PID 파일 없음: $PidFile"
    exit
}

$pid = Get-Content $PidFile

Write-Host "🛑 Trying to stop ffmpeg PID = $pid"

try {
    Stop-Process -Id $pid -Force -ErrorAction Stop
    Write-Host "✔ ffmpeg 종료 완료 (PID: $pid)"
}
catch {
    Write-Host "⚠ ffmpeg 종료 실패 (이미 종료되었거나 권한 문제)"
}

Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
Write-Host "✔ PID 파일 삭제됨: $PidFile"
