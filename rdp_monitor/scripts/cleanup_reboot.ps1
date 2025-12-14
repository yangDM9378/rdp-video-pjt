. "C:\rdp-video-pjt\rdp_monitor\scripts\common.ps1"
$config = Get-Config

Get-Process ffmpeg -ErrorAction SilentlyContinue | Stop-Process -Force
Remove-Item "$($config["PID_DIR"])\*"  -Recurse -Force -ErrorAction SilentlyContinue
