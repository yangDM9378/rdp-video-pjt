. "C:\rdp-video-pjt\rdp_monitor\scripts\common.ps1"
$config = Get-Config

$RecordDir   = $config["RECORD_DIR"]
$MoveRootDir = $config["MOVE_RECORD_DIR"]
$ServerName  = $config["SERVER_NAME"]
$LogDir      = $config["LOG_DIR"]

$WinSCP   = $config["WINSCP_PATH"]
$SftpHost = $config["SFTP_HOST"]
$SftpUser = $config["SFTP_USER"]
$SftpPass = $config["SFTP_KEY"]

$Yesterday = (Get-Date).AddDays(-1).ToString("yyyyMMdd")

$LocalDir  = Join-Path $RecordDir $Yesterday
$RemoteDir = Join-Path $MoveRootDir $ServerName
$RemoteDir = Join-Path $RemoteDir  $Yesterday

if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

$LogFile = Join-Path $LogDir "transfer_${ServerName}_${Yesterday}.log"

function Log($msg) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts $msg" | Out-File $LogFile -Append -Encoding utf8
}

Log "===== SFTP TRANSFER START ====="
Log "LocalDir  = $LocalDir"
Log "RemoteDir = $RemoteDir"


if (!(Test-Path $LocalDir)) {
    Log "Local directory not found. Exit."
    exit 0
}

$WinScpScript = @"
open sftp://$SftpUser@$SftpHost -password="$SftpPass"
mkdir $RemoteDir
cd $RemoteDir
lcd $LocalDir
put -resume -delete -r *
exit
"@

$tmpScript = "$env:TEMP\winscp_${ServerName}_${Yesterday}.txt"
$WinScpScript | Out-File $tmpScript -Encoding ascii

& $WinSCP /script="$tmpScript" /log="$LogDir\winscp_${ServerName}_${Yesterday}.log"

if ($LASTEXITCODE -eq 0) {
    Log "SFTP TRANSFER SUCCESS"
} else {
    Log "SFTP TRANSFER FAILED (code=$LASTEXITCODE)"
}

Remove-Item $tmpScript -Force -ErrorAction SilentlyContinue
Log "===== SFTP TRANSFER END ====="
