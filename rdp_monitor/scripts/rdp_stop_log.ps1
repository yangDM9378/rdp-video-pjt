#=========================================
# RDP STOP LOG SCRIPT (Event 24 or 23)
#=========================================

# 공통 설정 로딩
. "C:\rdp_monitor\scripts\config_loader.ps1"
$config = Load-Config

# 로그 위치
$logDir = $config["LOG_DIR"]
if (-not $logDir) { $logDir = "C:\rdp_monitor\logs" }
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$logFile = Join-Path $logDir "rdp_stop.log"

# 최신 Event 23 또는 24 조회
$event = Get-WinEvent -LogName 'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational' `
    | Where-Object { $_.Id -in 23, 24 } `
    | Select-Object -First 1

# 이벤트 없으면 기록 후 종료
if (-not $event) {
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$time | STOP | Event 23/24 Not Found" |
        Out-File -Append -Encoding UTF8 -FilePath $logFile
    exit
}

# XML 파싱
$user = "Unknown"
$sessionID = "Unknown"
$address = "Unknown"
$eventID = $event.Id

try {
    $xml = [xml]$event.ToXml()
    $user      = $xml.Event.UserData.EventXML.User
    $sessionID = $xml.Event.UserData.EventXML.EventXML.SessionID
    $address   = $xml.Event.UserData.EventXML.Address
} catch {}

# 로그 기록
$time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"$time | STOP | EventID=$eventID | SessionID=$sessionID | User=$user | Addr=$address" |
    Out-File -Append -Encoding UTF8 -FilePath $logFile
