. "C:\rdp-video-pjt\rdp_monitor\scripts\common.ps1"
. "C:\rdp-video-pjt\rdp_monitor\scripts\send_meta.ps1"

$config = Get-Config

$PidDir = $config["PID_DIR"]
$LogDir = $config["LOG_DIR"]

# ===== Session =====
try {
    $SessionId = (Get-Process -Id $PID).SessionId
}
catch {
    return
}

$SessionDir = "$PidDir\session_$SessionId"

$PidFile     = "$SessionDir\ffmpeg.pid"
$LockFile    = "$SessionDir\recording.lock"
$PointerFile = "$SessionDir\recording.json"

# 세션 포인터 없으면 처리 대상 아님
if (!(Test-Path $PointerFile)) {
    return
}

$pointer   = Get-Content $PointerFile -Raw | ConvertFrom-Json
$MetaFile  = $pointer.meta
$VideoPath = $pointer.video

try {
    # ===== stop ffmpeg =====
    if (Test-Path $PidFile) {
        $ffpid = Get-Content $PidFile -ErrorAction SilentlyContinue
        if ($ffpid -and (Get-Process -Id $ffpid -ErrorAction SilentlyContinue)) {

            # 프로세스 트리 포함 강제 종료
            cmd /c taskkill /PID $ffpid /T /F | Out-Null
            Start-Sleep -Seconds 2

            if (Get-Process -Id $ffpid -ErrorAction SilentlyContinue) {
                Stop-Process -Id $ffpid -Force
            }
        }
    }

    # ===== validate video file =====
    if (!(Test-Path $VideoPath)) { return }

    $fi = Get-Item $VideoPath
    if ($fi.Length -lt 1024) { return }

    # ===== update meta.json =====
    if (!(Test-Path $MetaFile)) { return }

    $meta = Get-Content $MetaFile -Raw | ConvertFrom-Json
    $meta.end_time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $meta.size     = $fi.Length

    $meta | ConvertTo-Json -Depth 5 | Out-File $MetaFile -Encoding utf8

    # ===== send meta to backend (실패해도 throw 안 함) =====
    try {
        Send-MetaToApi `
            -MetaFile $MetaFile `
            -LogDir $LogDir | Out-Null
    }
    catch {
        # 여기서는 로그만 남기고 절대 throw 하지 않음
    }
}
finally {
    # ===== cleanup은 무조건 실행 =====
    Remove-Item $PidFile     -Force -ErrorAction SilentlyContinue
    Remove-Item $LockFile    -Force -ErrorAction SilentlyContinue
    Remove-Item $PointerFile -Force -ErrorAction SilentlyContinue
}
