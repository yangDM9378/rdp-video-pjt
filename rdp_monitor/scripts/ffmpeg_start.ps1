. "C:\rdp-video-pjt\rdp_monitor\scripts\common.ps1"
$config = Get-Config

$Ffmpeg    = $config["FFMPEG_PATH"]
$RecordDir = $config["RECORD_DIR"]
$PidDir    = $config["PID_DIR"]
$Server    = $config["SERVER_NAME"]

# ===== Session =====
try {
    $SessionId = (Get-Process -Id $PID).SessionId
}
catch {
    exit
}

$SessionDir = "$PidDir\session_$SessionId"
New-Item -ItemType Directory -Path $SessionDir -Force | Out-Null

# ===== User lookup (query user + '>' 제거) =====
$userLine = (query user | Select-String "^\s*(\S+)\s+.*\s+$SessionId\s").Matches
if (!$userLine) { exit }

# 원본 사용자명 (예: >uds_dp)
$UserRaw = $userLine[0].Groups[1].Value

# '>' 및 앞 공백 제거 → 실제 사용자명
$User = $UserRaw -replace '^[>\s]+', ''

# Windows 경로 안전 처리
$UserSafe = $User -replace '[\\/:*?"<>|]', '_'

# ===== Lock =====
$LockFile = "$SessionDir\recording.lock"
if (Test-Path $LockFile) { exit }
New-Item -ItemType File -Path $LockFile -Force | Out-Null

# ===== Path =====
$DateDir   = Get-Date -Format "yyyyMMdd"
$Timestamp = Get-Date -Format "yyyyMMddHHmmss"

$VideoDir  = "$RecordDir\$DateDir\$UserSafe"
New-Item -ItemType Directory -Path $VideoDir -Force | Out-Null

$VideoName = "${Timestamp}_session${SessionId}.webm"
$VideoPath = "$VideoDir\$VideoName"
$MetaPath  = "$VideoDir\${Timestamp}_session${SessionId}.json"

# ===== meta.json =====
$meta = @{
    server     = $Server
    user       = $User
    session    = $SessionId
    start_time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    end_time   = $null
    filename   = $VideoName
    filepath   = $VideoDir
    size       = 0
    duration   = 0
    uploaded   = 0
}

$meta | ConvertTo-Json -Depth 5 | Out-File $MetaPath -Encoding utf8

# ===== recording.json (세션 포인터) =====
@{
    meta  = $MetaPath
    video = $VideoPath
} | ConvertTo-Json -Depth 3 | Out-File "$SessionDir\recording.json" -Encoding utf8

# ===== ffmpeg 실행 =====
$args = @(
    "-y"
    "-f", "gdigrab"
    "-framerate", "30"
    "-i", "desktop"
    "-vf", "scale=1280:720"
    "-c:v", "libvpx-vp9"
    "$VideoPath"
)

$proc = Start-Process `
    -FilePath $Ffmpeg `
    -ArgumentList $args `
    -WindowStyle Hidden `
    -PassThru

$proc.Id | Out-File "$SessionDir\ffmpeg.pid" -Encoding ascii
