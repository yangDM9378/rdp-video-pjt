. "C:\rdp-video-pjt\rdp_monitor\scripts\common.ps1"
$config = Get-Config

$Ffmpeg = $config["FFMPEG_PATH"]
$OutDir = $config["RECORD_DIR"]
$PidDir = $config["PID_DIR"]

$SessionId  = (Get-Process -Id $PID).SessionId
$SessionDir = "$PidDir\session_$SessionId"
$PidFile    = "$SessionDir\ffmpeg.pid"
$LockFile   = "$SessionDir\recording.lock"
Start-Sleep -Seconds 2

@($OutDir, $PidDir, $SessionDir) | ForEach-Object {
    if (!(Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ | Out-Null
    }
}

if (Test-Path $LockFile) {
    if (Test-Path $PidFile) {
        $oldPid = Get-Content $PidFile -ErrorAction SilentlyContinue
        if ($oldPid -and (Get-Process -Id $oldPid -ErrorAction SilentlyContinue)) {
            exit
        }
    }
    Remove-Item $LockFile -Force -ErrorAction SilentlyContinue
}

New-Item -ItemType File -Path $LockFile -Force | Out-Null


# ===== Output =====
$Timestamp = Get-Date -Format "yyyyMMddHHmmss"
$Output = "$OutDir\record_$SessionId`_$Timestamp.webm"

$Args = @(
    "-y"
    "-f", "gdigrab"
    "-framerate", "30"
    "-i", "desktop"
    "-vf", "scale=1280:720"
    "-c:v", "libvpx-vp9"
    "$Output"
)

$proc = Start-Process `
    -FilePath $Ffmpeg `
    -ArgumentList $Args `
    -WindowStyle Hidden `
    -PassThru

$proc.Id | Out-File $PidFile -Encoding ascii
