# ffmpeg_test.ps1

$FfmpegExe = "C:\Users\user\Desktop\rdp-video-pjt\rdp_monitor\ffmpeg\bin\ffmpeg.exe"
$OutputDir = Get-Location # 스크립트가 실행된 현재 폴더를 출력 폴더로 지정합니다.

$Timestamp = Get-Date -Format "yyyyMMddHHmmss"

$OutputFile = Join-Path -Path $OutputDir -ChildPath "tester_$Timestamp.webm"
$LogFile = Join-Path -Path $OutputDir -ChildPath "log_$Timestamp.txt"

$Arguments = @(
    "-y",
    "-f", "gdigrab",
    "-framerate", "30",
    "-i", "desktop",
    "-vf", "scale=1280:720",
    "-c:v", "libvpx-vp9",
    $OutputFile
)

Write-Host "======================================="
Write-Host "FFmpeg 실행 시작 ($Timestamp)"
Write-Host "로그 파일: $LogFile"
Write-Host "======================================="

& $FfmpegExe @Arguments 2>&1 | Out-File $LogFile -Encoding UTF8 -Append

Write-Host "======================================="
Write-Host "FFmpeg 실행이 완료되었습니다."
Write-Host "녹화 성공/실패 여부를 확인하려면 $LogFile 내용을 확인하세요."
Write-Host "======================================="