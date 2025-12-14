. "C:\rdp-video-pjt\rdp_monitor\scripts\common.ps1"
$config = Get-Config

$PidDir = $config["PID_DIR"]

$SessionId  = (Get-Process -Id $PID).SessionId
$SessionDir = "$PidDir\session_$SessionId"
$PidFile    = "$SessionDir\ffmpeg.pid"
$LockFile   = "$SessionDir\recording.lock"

if (!(Test-Path $SessionDir)) {
    exit
}

if (Test-Path $PidFile) {
    $TargetPid = Get-Content $PidFile -ErrorAction SilentlyContinue
    if ($TargetPid -and (Get-Process -Id $TargetPid -ErrorAction SilentlyContinue)) {
        cmd /c taskkill /PID $TargetPid


        if (Get-Process -Id $TargetPid -ErrorAction SilentlyContinue) {
            Stop-Process -Id $TargetPid -Force
        }
    }
}

Remove-Item $PidFile  -Force -ErrorAction SilentlyContinue
Remove-Item $LockFile -Force -ErrorAction SilentlyContinue
