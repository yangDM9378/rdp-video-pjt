. "C:\rdp-video-pjt\rdp_monitor\scripts\common.ps1"
$config = Get-Config

$FLAG_DIR = $config["FLAG_DIR"]
$LOG_DIR  = $config["LOG_DIR"]

New-Item -ItemType Directory -Path $FLAG_DIR -Force | Out-Null
New-Item -ItemType Directory -Path $LOG_DIR  -Force | Out-Null

$FlagFile = "$FLAG_DIR\rdp.flag"
$LogFile  = "$LOG_DIR\rdp_flag.log"

Add-Content $FlagFile "$(Get-Date -Format o)"
Add-Content $LogFile "$(Get-Date) CREATE RDP flag"
