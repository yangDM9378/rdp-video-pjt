#=========================================
# RDP START LOG SCRIPT (Event 25 전용)
#=========================================

# 공통 설정 로딩
. "C:\rdp_monitor\scripts\config_loader.ps1"
$config = Load-Config

# 로그 위치
$logDir = $config["LOG_DIR"]
if (-not $logDir) { $logDir = "C:\rdp_monitor\logs" }
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$logFile = Join-Path $logDir "rdp_start.log"

# 최신 Event 25 하나 읽기
$event = Get-WinEvent -LogName 'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational' `
    | Where-Object { $_.Id -eq 25 } `
    | Select-Object -First 1

# 이벤트 없으면 로그 남기고 종료
if (-not $event) {
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$time | START | Event 25 Not Found" |
        Out-File -Append -Encoding UTF8 -FilePath $logFile
    exit
}

# XML 파싱
$user = "Unknown"
$sessionID = "Unknown"
$address = "Unknown"

try {
    $xml = [xml]$event.ToXml()
    $user      = $xml.Event.UserData.EventXML.User
    $sessionID = $xml.Event.UserData.EventXML.SessionID
    $address   = $xml.Event.UserData.EventXML.Address
} catch {}

# 로그 기록
$time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"$time | START | EventID=25 | SessionID=$sessionID | User=$user | Addr=$address" |
    Out-File -Append -Encoding UTF8 -FilePath $logFile
